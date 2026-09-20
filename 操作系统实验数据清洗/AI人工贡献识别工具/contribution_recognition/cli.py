"""CLI for the AI/human contribution-recognition cleaning stage."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .analysis import (
    AssessmentValidationError,
    ContributionAnalyzer,
    TransientProtocolError,
    _parse_json_object,
    analysis_fingerprint,
    failed_assessment,
    host_insufficient_data_assessment,
    host_insufficient_fingerprint,
    model_analysis_skip_reason,
)
from .errors import ContributionRecognitionError
from .nim_client import NimStreamingClient
from .protocol import NimAnalysisSettings, NimConfig, NimError
from .redaction import redact_sensitive_text
from .report import render_full_report, render_teacher_report
from .repository import ContributionRepository
from .storage import (
    REPORT_TEMPLATE_VERSION,
    ContributionStorage,
    stable_sha256,
    validate_v3_assessment,
)


TOOL_DIRECTORY = Path(__file__).resolve().parents[1]
CLEANING_DIRECTORY = TOOL_DIRECTORY.parent
DEFAULT_CLEANED_ROOT = CLEANING_DIRECTORY / "操作系统实验数据记录-已清洗"
MAX_TASK_ATTEMPTS = 2


def _json_print(value: dict[str, Any]) -> None:
    print(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True))


def _safe_error_message(error: BaseException) -> str:
    return redact_sensitive_text(str(error))[:2_000]


def _render_fingerprint(assessment: dict[str, Any]) -> str:
    return "sha256:" + stable_sha256(
        {
            "assessment": assessment,
            "report_template_version": REPORT_TEMPLATE_VERSION,
            "renderer_contract": "contribution-v3-full-and-teacher",
        }
    )


def _load_assessment(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("assessment 文件根节点不是对象")
    validate_v3_assessment(value)
    return value


def _assessment_summary(assessment: dict[str, Any]) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    conclusion = assessment.get("lab_conclusion")
    coverage = assessment.get("coverage")
    review = assessment.get("review")
    return (
        conclusion if isinstance(conclusion, dict) else {},
        coverage if isinstance(coverage, dict) else {},
        review if isinstance(review, dict) else {},
    )


def _result_for_assessment(
    *,
    task_identity: dict[str, str],
    status: str,
    message: str,
    assessment: dict[str, Any],
    storage: ContributionStorage,
    run_log: Path | None = None,
) -> dict[str, Any]:
    conclusion, coverage, review = _assessment_summary(assessment)
    result: dict[str, Any] = {
        **task_identity,
        "status": status,
        "analysis_status": assessment.get("analysis_status", "unknown"),
        "lab_conclusion": conclusion,
        "review": review,
        "coverage": coverage,
        "message": message,
        "assessment": str(storage.assessment_path(task_identity["student_directory"], task_identity["lab"])),
        "full_report": str(storage.full_report_path(task_identity["student_directory"], task_identity["lab"])),
        "teacher_report": str(storage.teacher_report_path(task_identity["student_directory"], task_identity["lab"])),
    }
    if run_log is not None:
        result["run_log"] = str(run_log)
    return result


def _task_result_row(result: dict[str, Any]) -> dict[str, Any]:
    return {
        "student_directory": result["student_directory"],
        "lab": result["lab"],
        "analysis_status": result.get("analysis_status", result["status"]),
        "execution_status": result["status"],
        "lab_conclusion": result.get("lab_conclusion", {}),
        "review": result.get("review", {}),
        "coverage": result.get("coverage", {}),
        "message": result.get("message", ""),
    }


def _write_assessment(
    *,
    storage: ContributionStorage,
    snapshot: Any,
    assessment: dict[str, Any],
    input_fingerprint: str,
) -> tuple[Path, Path, Path]:
    render_fingerprint = _render_fingerprint(assessment)
    return storage.write_assessment_and_reports(
        snapshot.student.directory_name,
        snapshot.lab,
        assessment,
        render_full_report(assessment),
        render_teacher_report(assessment),
        input_fingerprint,
        render_fingerprint,
    )


def _persist_failure(
    *,
    storage: ContributionStorage,
    snapshot: Any,
    input_fingerprint: str,
    error: BaseException,
    stage: str,
    task_attempt: int | None = None,
    max_task_attempts: int | None = None,
) -> dict[str, Any]:
    retryable = isinstance(error, TransientProtocolError) or (
        isinstance(error, NimError) and error.retryable
    )
    assessment = failed_assessment(
        snapshot,
        input_fingerprint,
        stage=stage,
        error_code=type(error).__name__,
        message=_safe_error_message(error),
        retryable=retryable,
    )
    _write_assessment(
        storage=storage,
        snapshot=snapshot,
        assessment=assessment,
        input_fingerprint=input_fingerprint,
    )
    record: dict[str, Any] = {
        "event": "analysis_failed",
        "stage": stage,
        "input_fingerprint": input_fingerprint,
        "error_code": type(error).__name__,
        "retryable": retryable,
    }
    if task_attempt is not None:
        record["task_attempt"] = task_attempt
    if max_task_attempts is not None:
        record["max_task_attempts"] = max_task_attempts
    log_path = storage.write_run_log(
        snapshot.student.directory_name,
        snapshot.lab,
        [record],
    )
    return _result_for_assessment(
        task_identity={"student_directory": snapshot.student.directory_name, "lab": snapshot.lab},
        status="failed",
        message=_safe_error_message(error),
        assessment=assessment,
        storage=storage,
        run_log=log_path,
    )


def _cached_task_result(
    *,
    storage: ContributionStorage,
    snapshot: Any,
    input_fingerprint: str,
    task_identity: dict[str, str],
) -> dict[str, Any] | None:
    """Return a checked cache entry without reading NIM credentials."""

    if not storage.cache_hit(snapshot.student.directory_name, snapshot.lab, input_fingerprint):
        return None
    try:
        assessment = _load_assessment(storage.assessment_path(snapshot.student.directory_name, snapshot.lab))
        render_fingerprint = _render_fingerprint(assessment)
        rebuilt = False
        if not storage.reports_are_current(
            snapshot.student.directory_name,
            snapshot.lab,
            render_fingerprint,
        ):
            storage.write_reports_only(
                snapshot.student.directory_name,
                snapshot.lab,
                assessment,
                render_full_report(assessment),
                render_teacher_report(assessment),
                render_fingerprint,
            )
            rebuilt = True
        return _result_for_assessment(
            task_identity=task_identity,
            status="rerendered" if rebuilt else "cached",
            message="输入未变，仅重渲染双报告。" if rebuilt else "输入未变，未调用 NIM。",
            assessment=assessment,
            storage=storage,
        )
    except (OSError, ValueError, json.JSONDecodeError):
        return None


def _previous_failed_result(
    *,
    storage: ContributionStorage,
    snapshot: Any,
    task_identity: dict[str, str],
) -> dict[str, Any] | None:
    """Preserve an earlier failure until batch explicitly requests a retry."""

    entry = storage.cache_entry(snapshot.student.directory_name, snapshot.lab)
    if not entry or entry.get("analysis_status") != "failed":
        return None
    try:
        assessment = _load_assessment(storage.assessment_path(snapshot.student.directory_name, snapshot.lab))
    except (OSError, ValueError, json.JSONDecodeError):
        return None
    return _result_for_assessment(
        task_identity=task_identity,
        status="skipped_failed",
        message="保留已有失败记录；使用 --retry-failed 或 --force 后重新调用 NIM。",
        assessment=assessment,
        storage=storage,
    )


def _persist_host_insufficient_assessment(
    *,
    storage: ContributionStorage,
    snapshot: Any,
    input_fingerprint: str,
    reason: str,
    task_identity: dict[str, str],
) -> dict[str, Any]:
    assessment = host_insufficient_data_assessment(snapshot, input_fingerprint, reason)
    _write_assessment(
        storage=storage,
        snapshot=snapshot,
        assessment=assessment,
        input_fingerprint=input_fingerprint,
    )
    log_path = storage.write_run_log(
        snapshot.student.directory_name,
        snapshot.lab,
        [
            {
                "event": "analysis_skipped_insufficient_material",
                "input_fingerprint": input_fingerprint,
                "reason": reason,
            }
        ],
    )
    return _result_for_assessment(
        task_identity=task_identity,
        status="insufficient_data",
        message="资料不足，未调用主分析或独立复核 NIM。",
        assessment=assessment,
        storage=storage,
        run_log=log_path,
    )


def _execute_task(
    *,
    repository: ContributionRepository,
    storage: ContributionStorage,
    student_reference: str,
    lab: str,
    force: bool,
    dry_run: bool,
    retry_failed: bool = True,
) -> dict[str, Any]:
    snapshot = repository.build_snapshot(student_reference, lab)
    task_identity = {"student_directory": snapshot.student.directory_name, "lab": snapshot.lab}
    if dry_run:
        return {
            **task_identity,
            "status": "dry_run",
            "analysis_status": "not_run",
            "coverage": {
                "status": "complete" if snapshot.analysis_ready else "insufficient",
                "materials": [material.to_dict() for material in snapshot.materials],
            },
            "source_manifest": [material.to_dict() for material in snapshot.materials],
            "diff_hunks": [hunk.to_dict() for hunk in snapshot.diff_hunks],
            "message": "输入快照已验证，未调用 NIM 或写入产物。",
            "snapshot_fingerprint": snapshot.assessment_fingerprint,
        }

    skip_reason = model_analysis_skip_reason(snapshot)
    if skip_reason is not None:
        fingerprint = host_insufficient_fingerprint(snapshot)
        if not force:
            cached = _cached_task_result(
                storage=storage,
                snapshot=snapshot,
                input_fingerprint=fingerprint,
                task_identity=task_identity,
            )
            if cached is not None:
                return cached
        try:
            return _persist_host_insufficient_assessment(
                storage=storage,
                snapshot=snapshot,
                input_fingerprint=fingerprint,
                reason=skip_reason,
                task_identity=task_identity,
            )
        except (ContributionRecognitionError, OSError, ValueError) as error:
            return _persist_failure(
                storage=storage,
                snapshot=snapshot,
                input_fingerprint=fingerprint,
                error=error,
                stage="host_insufficient",
            )

    fallback_fingerprint = "sha256:" + snapshot.assessment_fingerprint
    if not force and not retry_failed:
        previous_failure = _previous_failed_result(
            storage=storage,
            snapshot=snapshot,
            task_identity=task_identity,
        )
        if previous_failure is not None:
            return previous_failure
    try:
        settings = NimAnalysisSettings.from_environment()
    except (ContributionRecognitionError, OSError, ValueError) as error:
        return _persist_failure(
            storage=storage,
            snapshot=snapshot,
            input_fingerprint=fallback_fingerprint,
            error=error,
            stage="configuration",
        )
    fingerprint = analysis_fingerprint(snapshot, settings)
    if not force:
        cached = _cached_task_result(
            storage=storage,
            snapshot=snapshot,
            input_fingerprint=fingerprint,
            task_identity=task_identity,
        )
        if cached is not None:
            return cached

    try:
        config = NimConfig.from_environment()
    except (ContributionRecognitionError, OSError, ValueError) as error:
        return _persist_failure(
            storage=storage,
            snapshot=snapshot,
            input_fingerprint=fingerprint,
            error=error,
            stage="configuration",
        )

    for task_attempt in range(1, MAX_TASK_ATTEMPTS + 1):
        try:
            # A retry must not inherit the failed exchange's messages, excerpts,
            # or repair instruction. Recreate both objects for a clean session.
            run = ContributionAnalyzer(NimStreamingClient(config), config).analyze(
                snapshot,
                fingerprint,
                material_reader=repository.read_snapshot_material,
            )
            assessment = run.assessment
            _write_assessment(
                storage=storage,
                snapshot=snapshot,
                assessment=assessment,
                input_fingerprint=fingerprint,
            )
            log_path = storage.write_run_log(
                snapshot.student.directory_name,
                snapshot.lab,
                [
                    {
                        "event": "analysis_completed",
                        "input_fingerprint": fingerprint,
                        "analysis_status": assessment["analysis_status"],
                        "task_attempt": task_attempt,
                        "max_task_attempts": MAX_TASK_ATTEMPTS,
                        "primary_request_ids": [
                            response.request_id for response in run.primary_responses
                        ],
                        "reviewer_request_ids": [
                            response.request_id for response in run.reviewer_responses
                        ],
                        "primary_attempts": [
                            response.attempts for response in run.primary_responses
                        ],
                        "reviewer_attempts": [
                            response.attempts for response in run.reviewer_responses
                        ],
                        "primary_usage": [
                            response.usage for response in run.primary_responses
                        ],
                        "reviewer_usage": [
                            response.usage for response in run.reviewer_responses
                        ],
                        "primary_read_count": run.primary_read_count,
                        "reviewer_read_count": run.reviewer_read_count,
                        "primary_repaired": run.primary_repaired,
                        "reviewer_repaired": run.reviewer_repaired,
                        "model": config.model,
                    }
                ],
            )
            return _result_for_assessment(
                task_identity=task_identity,
                status=assessment["analysis_status"],
                message="NIM 主分析与独立 NIM 复核已完成。",
                assessment=assessment,
                storage=storage,
                run_log=log_path,
            )
        except TransientProtocolError as error:
            if task_attempt < MAX_TASK_ATTEMPTS:
                storage.write_run_log(
                    snapshot.student.directory_name,
                    snapshot.lab,
                    [
                        {
                            "event": "analysis_attempt_failed",
                            "stage": "semantic_analysis_or_review",
                            "input_fingerprint": fingerprint,
                            "task_attempt": task_attempt,
                            "max_task_attempts": MAX_TASK_ATTEMPTS,
                            "error_code": type(error).__name__,
                            "retryable": True,
                        }
                    ],
                )
                continue
            return _persist_failure(
                storage=storage,
                snapshot=snapshot,
                input_fingerprint=fingerprint,
                error=error,
                stage="semantic_analysis_or_review",
                task_attempt=task_attempt,
                max_task_attempts=MAX_TASK_ATTEMPTS,
            )
        except (ContributionRecognitionError, OSError, ValueError) as error:
            return _persist_failure(
                storage=storage,
                snapshot=snapshot,
                input_fingerprint=fingerprint,
                error=error,
                stage="semantic_analysis_or_review",
                task_attempt=task_attempt,
                max_task_attempts=MAX_TASK_ATTEMPTS,
            )

    raise AssertionError("任务重试循环未返回结果")


def _add_root_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--cleaned-root",
        type=Path,
        default=DEFAULT_CLEANED_ROOT,
        help="已清洗数据根目录",
    )


def _add_task_arguments(parser: argparse.ArgumentParser, *, multiple_students: bool = False) -> None:
    _add_root_argument(parser)
    parser.add_argument(
        "--student",
        required=not multiple_students,
        action="append" if multiple_students else None,
        help="学生目录名；批处理可重复指定",
    )
    parser.add_argument(
        "--lab",
        required=not multiple_students,
        action="append" if multiple_students else None,
        help="实验标签 lab0 至 lab8；批处理可重复指定",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="操作系统实验 AI/人工贡献识别清洗工具")
    commands = parser.add_subparsers(dest="command", required=True)

    migrate = commands.add_parser("migrate-legacy", help="离线保留旧版 AI 结果至双分类目录，不调用模型")
    _add_root_argument(migrate)

    inspect = commands.add_parser("inspect", help="检查单个学生/Lab 的 v2 输入清单")
    _add_task_arguments(inspect)

    analyze = commands.add_parser("analyze", help="分析单个学生/Lab 的贡献")
    _add_task_arguments(analyze)
    analyze.add_argument("--force", action="store_true", help="忽略增量缓存并重新调用 NIM")
    analyze.add_argument("--dry-run", action="store_true", help="只验证输入，不调用模型或写入文件")

    batch = commands.add_parser("batch", help="批量分析已发现的学生/Lab")
    _add_task_arguments(batch, multiple_students=True)
    batch.add_argument("--force", action="store_true", help="忽略增量缓存")
    batch.add_argument("--dry-run", action="store_true", help="只验证输入，不调用模型或写入文件")
    batch.add_argument("--resume", action="store_true", help="显式复用输入未变的成功结果")
    batch.add_argument("--retry-failed", action="store_true", help="重新尝试已有失败记录")
    batch.add_argument("--jobs", type=int, default=1, help="首期仅支持 1，保持 NIM 请求顺序")

    doctor = commands.add_parser("doctor", help="验证 NIM 配置和受控读取 JSON 协议")
    doctor.add_argument("--no-network", action="store_true", help="仅验证本地 NIM 配置")
    return parser


def _inspect(args: argparse.Namespace) -> int:
    repository = ContributionRepository(args.cleaned_root)
    snapshot = repository.build_snapshot(args.student, args.lab)
    _json_print(
        {
            "task": {"student_directory": snapshot.student.directory_name, "lab": snapshot.lab},
            "snapshot_schema_version": snapshot.schema_version,
            "snapshot_fingerprint": snapshot.assessment_fingerprint,
            "analysis_ready": snapshot.analysis_ready,
            "source_manifest": [material.to_dict() for material in snapshot.materials],
            "diff_hunks": [hunk.to_dict() for hunk in snapshot.diff_hunks],
            "limitations": list(snapshot.limitations),
        }
    )
    return 0


def _doctor(args: argparse.Namespace) -> int:
    config = NimConfig.from_environment()
    if args.no_network:
        _json_print(
            {
                "status": "configured",
                "endpoint": config.endpoint,
                "model": config.model,
                "stream": True,
                "thinking": True,
                "protocol": "host-mediated-read-material-json",
            }
        )
        return 0
    response = NimStreamingClient(config).complete(
        [
            {
                "role": "system",
                "content": (
                    "Return exactly one JSON object and no Markdown. The object must be exactly "
                    '{"action":"read_material","requests":[{"source_id":"source:doctor:timeline",'
                    '"start_line":1,"end_line":1}]}. Use integer keys start_line and end_line; '
                    "do not use a lines field or any other range format."
                ),
            },
            {
                "role": "user",
                "content": (
                    "This is a synthetic protocol check. There is no student material and "
                    "the requested source is only a test identifier."
                ),
            },
        ]
    )
    payload = _parse_json_object(response.content)
    requests = payload.get("requests")
    valid = (
        payload.get("action") == "read_material"
        and isinstance(requests, list)
        and len(requests) == 1
        and isinstance(requests[0], dict)
        and requests[0].get("source_id") == "source:doctor:timeline"
        and requests[0].get("start_line") == 1
        and requests[0].get("end_line") == 1
    )
    if not valid:
        raise AssessmentValidationError("NIM doctor 未返回有效的受控读取请求")
    _json_print(
        {
            "status": "ok",
            "model": response.model,
            "request_id": response.request_id,
            "attempts": response.attempts,
            "usage": response.usage,
            "protocol": "host-mediated-read-material-json",
        }
    )
    return 0


def _single_analyze(args: argparse.Namespace) -> int:
    repository = ContributionRepository(args.cleaned_root)
    result = _execute_task(
        repository=repository,
        storage=ContributionStorage(args.cleaned_root),
        student_reference=args.student,
        lab=args.lab,
        force=args.force,
        dry_run=args.dry_run,
    )
    _json_print(result)
    return 2 if result["status"] == "failed" else 0


def _batch(args: argparse.Namespace) -> int:
    if args.jobs != 1:
        raise ContributionRecognitionError("首期批处理只支持 --jobs 1")
    repository = ContributionRepository(args.cleaned_root)
    storage = ContributionStorage(args.cleaned_root)
    tasks = repository.discover_tasks(args.student, args.lab)
    results: list[dict[str, Any]] = []
    for task in tasks:
        try:
            result = _execute_task(
                repository=repository,
                storage=storage,
                student_reference=task.student_reference.directory_name,
                lab=task.lab,
                force=args.force,
                dry_run=args.dry_run,
                retry_failed=args.retry_failed or args.force,
            )
        except (ContributionRecognitionError, OSError, ValueError) as error:
            result = {
                "student_directory": task.directory_name,
                "lab": task.lab,
                "status": "failed",
                "analysis_status": "failed",
                "lab_conclusion": {"label": "indeterminate", "confidence": "weak"},
                "review": {"status": "not_run"},
                "coverage": {"status": "insufficient"},
                "message": _safe_error_message(error),
            }
        results.append(result)
    overview_paths: tuple[Path, Path] | None = None
    batch_summary_path: Path | None = None
    if not args.dry_run:
        overview_paths = storage.write_overview([_task_result_row(result) for result in results])
        batch_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
        batch_summary_path = storage.write_batch_summary(
            batch_id,
            {
                "batch_id": batch_id,
                "created_at": datetime.now(timezone.utc).isoformat(),
                "task_count": len(results),
                "resume": bool(args.resume),
                "retry_failed": bool(args.retry_failed),
                "force": bool(args.force),
                "results": results,
            },
        )
    summary = {
        "task_count": len(results),
        "completed": sum(result["status"] in {"complete", "insufficient_data"} for result in results),
        "cached": sum(result["status"] in {"cached", "rerendered"} for result in results),
        "skipped_failed": sum(result["status"] == "skipped_failed" for result in results),
        "failed": sum(result["status"] == "failed" for result in results),
        "dry_run": args.dry_run,
        "results": results,
    }
    if overview_paths is not None:
        summary["overview_markdown"] = str(overview_paths[0])
        summary["overview_csv"] = str(overview_paths[1])
    if batch_summary_path is not None:
        summary["batch_summary"] = str(batch_summary_path)
    _json_print(summary)
    return 1 if summary["failed"] else 0


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "migrate-legacy":
            from .migration import migrate_legacy
            _json_print(migrate_legacy(args.cleaned_root))
            return 0
        if args.command == "inspect":
            return _inspect(args)
        if args.command == "analyze":
            return _single_analyze(args)
        if args.command == "batch":
            return _batch(args)
        if args.command == "doctor":
            return _doctor(args)
        raise ContributionRecognitionError(f"未知命令：{args.command}")
    except (ContributionRecognitionError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"贡献识别未完成：{_safe_error_message(error)}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
