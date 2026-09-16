from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .client import OpenAICompatibleChatClient, OpenAICompatibleConfig
from .errors import AuditError
from .loop import AuditAgentLoop
from .policy import PolicyDocument
from .report import (
    render_report,
    render_teacher_review_report,
    write_report,
    write_teacher_review_report,
)
from .repository import StudentAuditRepository
from .tools import AuditTools
from .validation import AssessmentValidator


def _workspace_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _defaults() -> dict[str, Path]:
    root = _workspace_root()
    return {
        "data_root": root / "操作系统实验数据记录-已清洗",
        "policy": root / "lab0课程规则边界.md",
        "output_dir": root / "诚信审核报告草稿",
        "teacher_output_dir": root / "教师复核报告草稿",
        "trace_dir": root / "诚信审核运行日志",
    }


def _add_common_input_options(parser: argparse.ArgumentParser) -> None:
    defaults = _defaults()
    parser.add_argument("--data-root", type=Path, default=defaults["data_root"], help="清洗数据根目录")
    parser.add_argument("--policy", type=Path, default=defaults["policy"], help="Lab0 审核规则 Markdown")


def _add_report_output_options(parser: argparse.ArgumentParser) -> None:
    defaults = _defaults()
    parser.add_argument("--output-dir", type=Path, default=defaults["output_dir"])
    parser.add_argument("--teacher-output-dir", type=Path, default=defaults["teacher_output_dir"])


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Lab0 诚信审核 Agent Loop")
    subcommands = parser.add_subparsers(dest="command", required=True)

    students = subcommands.add_parser("students", help="列出可处理的学生目录")
    students.add_argument("--data-root", type=Path, default=_defaults()["data_root"])

    inspect = subcommands.add_parser("inspect", help="查看单个学生单个 lab 的清洗数据范围")
    _add_common_input_options(inspect)
    inspect.add_argument("--student", required=True, help="学生目录名或学号")
    inspect.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")

    audit = subcommands.add_parser("audit", help="运行模型工具循环并生成审核草稿")
    _add_common_input_options(audit)
    audit.add_argument("--student", required=True, help="学生目录名或学号")
    audit.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")
    audit.add_argument("--baseline-manifest", type=Path, help="可选的已发布基线哈希清单")
    _add_report_output_options(audit)
    audit.add_argument("--trace-dir", type=Path, default=_defaults()["trace_dir"])
    audit.add_argument("--max-turns", type=int, default=20)
    audit.add_argument(
        "--dry-run",
        action="store_true",
        help="只验证输入和规则，不调用模型或写入报告",
    )

    render_trace = subcommands.add_parser("render-trace", help="从已验证运行日志重新生成两份报告")
    _add_common_input_options(render_trace)
    render_trace.add_argument("--student", required=True, help="学生目录名或学号")
    render_trace.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")
    render_trace.add_argument("--trace", type=Path, required=True, help="包含 validated_assessment 的 JSONL 日志")
    _add_report_output_options(render_trace)
    return parser


def _make_repository(args: argparse.Namespace) -> StudentAuditRepository:
    return StudentAuditRepository(args.data_root, args.student, args.lab)


def _json_print(value: dict[str, Any]) -> None:
    print(json.dumps(value, ensure_ascii=False, indent=2))


def _load_trace_assessment(
    trace_path: Path,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
) -> tuple[dict[str, Any], dict[str, Any]]:
    if not trace_path.is_file():
        raise AuditError(f"运行日志不存在：{trace_path}")

    assessment: dict[str, Any] | None = None
    turns = 0
    tool_calls = 0
    for line_number, line in enumerate(trace_path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as error:
            raise AuditError(f"运行日志第 {line_number} 行不是合法 JSON") from error
        if not isinstance(record, dict):
            continue
        if record.get("event") == "model_response":
            turns += 1
        elif record.get("event") == "tool_result":
            tool_calls += 1
        elif record.get("event") == "validated_assessment":
            payload = record.get("payload")
            if isinstance(payload, dict):
                assessment = payload

    if assessment is None:
        raise AuditError("运行日志中没有通过宿主校验的 assessment")
    if assessment.get("lab") != repository.lab:
        raise AuditError("运行日志的实验标签与当前 --lab 不一致")
    if assessment.get("student_id") != repository.reference.student_id:
        raise AuditError("运行日志的学生标识与当前 --student 不一致")
    if assessment.get("policy_sha256") != policy.sha256:
        raise AuditError("运行日志的规则版本与当前规则文件不一致")

    validated = AssessmentValidator(repository, policy).validate(assessment)
    return validated, {"turns": turns, "tool_calls": tool_calls, "trace_path": str(trace_path)}


def _write_reports(
    assessment: dict[str, Any],
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    run_metadata: dict[str, Any],
    output_dir: Path,
    teacher_output_dir: Path,
) -> tuple[Path, Path]:
    full_report = render_report(assessment, repository, policy, run_metadata)
    teacher_report = render_teacher_review_report(assessment, repository, policy, run_metadata)
    return (
        write_report(output_dir, repository, full_report),
        write_teacher_review_report(teacher_output_dir, repository, teacher_report),
    )


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "students":
            students = StudentAuditRepository.list_students(args.data_root)
            _json_print(
                {
                    "students": [
                        {"student_id": item.student_id, "directory": item.directory_name} for item in students
                    ]
                }
            )
            return 0

        repository = _make_repository(args)
        policy = PolicyDocument(args.policy)
        if args.command == "inspect":
            _json_print(
                {
                    "inventory": repository.inventory(),
                    "data_quality": repository.data_quality(),
                    "policy": policy.inventory(),
                }
            )
            return 0

        if args.command == "render-trace":
            assessment, run_metadata = _load_trace_assessment(args.trace, repository, policy)
            report_path, teacher_report_path = _write_reports(
                assessment=assessment,
                repository=repository,
                policy=policy,
                run_metadata=run_metadata,
                output_dir=args.output_dir,
                teacher_output_dir=args.teacher_output_dir,
            )
            _json_print(
                {
                    "report": str(report_path),
                    "teacher_review_report": str(teacher_report_path),
                    "overall_disposition": assessment["overall_disposition"],
                    "trace": str(args.trace),
                }
            )
            return 0

        tools = AuditTools(repository, policy, args.baseline_manifest)
        if args.dry_run:
            _json_print(
                {
                    "dry_run": True,
                    "inventory": repository.inventory(),
                    "data_quality": repository.data_quality(),
                    "baseline": repository.baseline_status(args.baseline_manifest),
                    "policy_sha256": policy.sha256,
                }
            )
            return 0

        model = OpenAICompatibleChatClient(OpenAICompatibleConfig.from_environment())
        result = AuditAgentLoop(
            model=model,
            repository=repository,
            policy=policy,
            tools=tools,
            max_turns=args.max_turns,
            trace_dir=args.trace_dir,
        ).run()
        report_path, teacher_report_path = _write_reports(
            assessment=result.assessment,
            repository=repository,
            policy=policy,
            run_metadata={
                "turns": result.turns,
                "tool_calls": result.tool_calls,
                "trace_path": result.trace_path,
            },
            output_dir=args.output_dir,
            teacher_output_dir=args.teacher_output_dir,
        )
        _json_print(
            {
                "report": str(report_path),
                "teacher_review_report": str(teacher_report_path),
                "overall_disposition": result.assessment["overall_disposition"],
                "turns": result.turns,
                "tool_calls": result.tool_calls,
                "trace": result.trace_path,
            }
        )
        return 0
    except AuditError as error:
        print(f"审核 Agent 未完成：{error}", file=sys.stderr)
        return 2
    except OSError as error:
        print(f"本地文件操作失败：{error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
