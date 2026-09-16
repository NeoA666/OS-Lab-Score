from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .policy import PolicyDocument
from .repository import StudentAuditRepository


TEACHER_REVIEW_LEVELS = {"R1", "R2"}
DISPOSITION_LABELS = {
    "N0": "不进入诚信复核",
    "N1": "教学过程提示",
    "R1": "学习能力复核",
    "R2": "正式诚信核实建议",
}


def _bullet(items: list[str]) -> str:
    return "\n".join(f"- {item}" for item in items)


def _table_cell(value: Any) -> str:
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def _table(headers: list[str], rows: list[list[Any]]) -> list[str]:
    lines = [
        "| " + " | ".join(_table_cell(item) for item in headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    lines.extend("| " + " | ".join(_table_cell(item) for item in row) + " |" for row in rows)
    return lines


def _blockquote(text: str) -> str:
    return "\n".join(f"> {line}" for line in text.splitlines())


def _source_locator(provenance: dict[str, Any]) -> str:
    observation = provenance.get("observation")
    pieces = []
    if provenance.get("out"):
        pieces.append(f"录像：`{provenance['out']}`")
    if provenance.get("tim"):
        pieces.append(f"计时：`{provenance['tim']}`")
    if isinstance(observation, dict):
        timing_line = observation.get("timing_line")
        byte_range = observation.get("decompressed_byte_range")
        if timing_line is not None:
            pieces.append(f"timing 行：`{timing_line}`")
        if byte_range is not None:
            pieces.append(f"解压字节范围：`{byte_range}`")
    return "；".join(pieces) or "清洗材料未提供可展示的原始定位"


def _evidence_counts(findings: list[dict[str, Any]]) -> dict[str, int]:
    counts = {"E1": 0, "E2": 0}
    for finding in findings:
        for evidence in finding.get("evidence", []):
            level = evidence.get("evidence_level")
            if level in counts:
                counts[level] += 1
    return counts


def _disposition_counts(findings: list[dict[str, Any]]) -> dict[str, int]:
    counts = {"N0": 0, "N1": 0, "R1": 0, "R2": 0}
    for finding in findings:
        disposition = finding.get("disposition")
        if disposition in counts:
            counts[disposition] += 1
    return counts


def _short_text(text: str, limit: int = 60) -> str:
    text = " ".join(text.split())
    return text if len(text) <= limit else f"{text[:limit - 3]}..."


def _finding_index_rows(findings: list[dict[str, Any]]) -> list[list[str]]:
    rows: list[list[str]] = []
    for finding in findings:
        evidence_counts = _evidence_counts([finding])
        observation = finding.get("observations", [""])[0]
        rows.append(
            [
                finding["id"],
                f"`{finding['disposition']}`",
                "、".join(finding["rule_refs"]),
                f"E1 {evidence_counts['E1']} / E2 {evidence_counts['E2']}",
                _short_text(observation),
            ]
        )
    return rows


def _render_evidence(evidence: list[dict[str, Any]], include_locator: bool) -> list[str]:
    lines: list[str] = []
    for index, item in enumerate(evidence, start=1):
        lines.extend(
            [
                f"#### 证据 {index}：`{item['evidence_level']}` / `{item['event_id']}`",
                "",
                _blockquote(item["quote"]),
                "",
            ]
        )
        locator = _source_locator(item["provenance"])
        if include_locator:
            lines.extend([f"**来源定位**：{locator}", ""])
        else:
            lines.extend(
                [
                    "<details>",
                    "<summary>展开查看来源定位</summary>",
                    "",
                    locator,
                    "",
                    "</details>",
                    "",
                ]
            )
    return lines


def _render_full_finding(finding: dict[str, Any]) -> list[str]:
    disposition = finding["disposition"]
    lines = [
        f"### {finding['id']} / `{disposition}` / {DISPOSITION_LABELS[disposition]}",
        "",
        "**规则依据**：" + "、".join(f"第 {item} 节" for item in finding["rule_refs"]),
        "",
        "#### Agent 归纳的观察",
        "",
        _bullet(finding["observations"]),
        "",
        "#### 可引用证据",
        "",
    ]
    lines.extend(_render_evidence(finding["evidence"], include_locator=False))
    lines.extend(
        [
            "#### 证据边界",
            "",
            _bullet(finding["limitations"]),
            "",
            "#### 有利替代解释",
            "",
            _bullet(finding["alternative_explanations"]),
            "",
            "#### 建议的教师动作",
            "",
            _bullet(finding["teacher_verification"]),
            "",
            f"**处理说明**：`{disposition}` 表示{DISPOSITION_LABELS[disposition]}，不构成违规认定。",
            "",
        ]
    )
    return lines


def _render_collapsed_full_finding(finding: dict[str, Any]) -> list[str]:
    disposition = finding["disposition"]
    detail = _render_full_finding(finding)
    return [
        "<details>",
        f"<summary>{finding['id']} / {disposition} / {DISPOSITION_LABELS[disposition]}</summary>",
        "",
        *detail[2:],
        "</details>",
        "",
    ]


def render_report(
    assessment: dict[str, Any],
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    run_metadata: dict[str, Any],
) -> str:
    """Render the complete, evidence-indexed audit draft for internal review."""

    generated_at = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    student_id = assessment.get("student_id") or repository.reference.directory_name
    quality = repository.data_quality()
    findings = assessment["findings"]
    dispositions = _disposition_counts(findings)
    evidence_counts = _evidence_counts(findings)
    quality_summary = quality.get("summary") if isinstance(quality.get("summary"), dict) else {}

    lines = [
        f"# {repository.lab} 完整诚信审核报告（草稿）",
        "",
        "> 本报告保留全部审核条目，供审核人员阅读与留档。它不是违规认定、处分或评分决定。",
        "",
        "## 一页摘要",
        "",
    ]
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["学生标识", f"`{student_id}`"],
                ["实验", f"`{repository.lab}`"],
                ["综合处理路径", f"`{assessment['overall_disposition']}` / {DISPOSITION_LABELS[assessment['overall_disposition']]}"],
                ["审核条目", f"{len(findings)} 项：N0 {dispositions['N0']}，N1 {dispositions['N1']}，R1 {dispositions['R1']}，R2 {dispositions['R2']}"],
                ["可引用证据", f"E1 {evidence_counts['E1']} 条，E2 {evidence_counts['E2']} 条"],
                ["时间线", f"状态：`{quality.get('status', '未提供')}`；事件：`{quality_summary.get('events', '未提供')}`"],
                ["规则版本", f"`{policy.sha256}`"],
            ],
        )
    )
    lines.extend(
        [
            "",
            "### Agent 综合说明",
            "",
            "综合处理路径和条目索引见上表。模型生成的完整说明保留在下方，供需要时复核。",
            "",
            "<details>",
            "<summary>展开查看 Agent 完整说明</summary>",
            "",
            assessment["summary"],
            "",
            "</details>",
            "",
            "## 条目索引",
            "",
        ]
    )
    if findings:
        lines.extend(_table(["编号", "级别", "规则", "证据", "观察主题"], _finding_index_rows(findings)))
    else:
        lines.append("本次未提交具体审核条目。")
    lines.extend(
        [
            "",
            "## 数据质量与适用边界",
            "",
            f"- 时间线可用：`{quality.get('timeline_available')}`。",
            f"- 时间语义：{quality.get('time_semantics', '未提供')}",
            "- 当前清洗目录的可引用事件默认是 `E2`；原始终端归档不可访问时不得将其升级为 `E1`。",
            "",
            "### Agent 声明的数据局限",
            "",
            _bullet(assessment["data_limitations"]),
            "",
        ]
    )
    errors = quality.get("errors")
    if isinstance(errors, list) and errors:
        lines.extend(
            [
                "<details>",
                f"<summary>展开查看清洗或时间异常（{len(errors)} 项）</summary>",
                "",
                _bullet([str(error) for error in errors]),
                "",
                "</details>",
                "",
            ]
        )

    lines.extend(["## 审核条目", ""])
    if not findings:
        lines.extend(["综合处理路径为 `N0`，没有需要展开的审核条目。", ""])
    review_findings = [finding for finding in findings if finding["disposition"] in TEACHER_REVIEW_LEVELS]
    non_review_findings = [finding for finding in findings if finding["disposition"] not in TEACHER_REVIEW_LEVELS]
    if review_findings:
        lines.extend(["### 需要教师复核的条目", ""])
    for finding in review_findings:
        lines.extend(_render_full_finding(finding))
    if non_review_findings:
        lines.extend(
            [
                "### N0/N1 内部审阅记录",
                "",
                "以下条目不进入教师诚信复核，默认折叠以便保留完整审计轨迹。",
                "",
            ]
        )
    for finding in non_review_findings:
        lines.extend(_render_collapsed_full_finding(finding))

    lines.extend(
        [
            "## 运行追溯",
            "",
        ]
    )
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["生成时间", generated_at],
                ["Agent 轮次", run_metadata.get("turns", "未提供")],
                ["工具调用数", run_metadata.get("tool_calls", "未提供")],
                ["运行日志", run_metadata.get("trace_path") or "未保存"],
            ],
        )
    )
    lines.append("")
    return "\n".join(lines)


def render_teacher_review_report(
    assessment: dict[str, Any],
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    run_metadata: dict[str, Any],
) -> str:
    """Render a teacher-facing report containing only R1 and R2 review items."""

    generated_at = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    student_id = assessment.get("student_id") or repository.reference.directory_name
    findings = [
        finding for finding in assessment["findings"] if finding["disposition"] in TEACHER_REVIEW_LEVELS
    ]
    dispositions = _disposition_counts(findings)

    lines = [
        f"# {repository.lab} 教师诚信复核报告（草稿）",
        "",
        "> 本报告只列出需要教师进一步复核的 `R1`、`R2` 条目。它不是违规认定、处分或评分决定。",
        "",
        "## 复核概览",
        "",
    ]
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["学生标识", f"`{student_id}`"],
                ["实验", f"`{repository.lab}`"],
                ["待复核条目", f"R1 {dispositions['R1']} 项，R2 {dispositions['R2']} 项"],
                ["规则版本", f"`{policy.sha256}`"],
                ["生成时间", generated_at],
            ],
        )
    )

    lines.extend(["", "## 教师复核条目", ""])
    if not findings:
        lines.extend(["当前无须进入教师诚信复核的条目。", ""])
    for finding in findings:
        e1_evidence = [item for item in finding["evidence"] if item["evidence_level"] == "E1"]
        supporting_e2 = [item for item in finding["evidence"] if item["evidence_level"] == "E2"]
        lines.extend(
            [
                f"### {finding['id']} / `{finding['disposition']}` / {DISPOSITION_LABELS[finding['disposition']]}",
                "",
                "#### 风险点",
                "",
                _bullet(finding["observations"]),
                "",
                "#### 规则依据",
                "",
                "、".join(f"第 {item} 节" for item in finding["rule_refs"]),
                "",
                "#### E1 原始证据",
                "",
            ]
        )
        if e1_evidence:
            lines.extend(_render_evidence(e1_evidence, include_locator=True))
        else:
            lines.extend(["该条没有可引用的 E1 原始证据，不能作为教师诚信复核条目。", ""])
        if supporting_e2:
            lines.extend(
                [
                    "<details>",
                    "<summary>展开查看补充清洗材料（E2）</summary>",
                    "",
                ]
            )
            lines.extend(_render_evidence(supporting_e2, include_locator=True))
            lines.extend(["</details>", ""])
        lines.extend(
            [
                "#### 需排除的替代解释",
                "",
                _bullet(finding["alternative_explanations"]),
                "",
                "#### 教师核实点",
                "",
                _bullet(finding["teacher_verification"]),
                "",
                "#### 证据边界",
                "",
                _bullet(finding["limitations"]),
                "",
            ]
        )

    lines.extend(
        [
            "## 运行追溯",
            "",
        ]
    )
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["Agent 轮次", run_metadata.get("turns", "未提供")],
                ["工具调用数", run_metadata.get("tool_calls", "未提供")],
                ["运行日志", run_metadata.get("trace_path") or "未保存"],
            ],
        )
    )
    lines.append("")
    return "\n".join(lines)


def _write_markdown(
    output_dir: Path,
    repository: StudentAuditRepository,
    content: str,
    report_kind: str,
) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    identifier = repository.reference.student_id or repository.reference.directory_name
    safe_identifier = "".join(character for character in identifier if character.isalnum() or character in "-_")
    target = output_dir / f"{repository.lab}-{report_kind}-{safe_identifier or 'student'}-{stamp}.md"
    suffix = 1
    while target.exists():
        target = output_dir / f"{repository.lab}-{report_kind}-{safe_identifier or 'student'}-{stamp}-{suffix}.md"
        suffix += 1
    target.write_text(content, encoding="utf-8")
    return target


def write_report(output_dir: Path, repository: StudentAuditRepository, content: str) -> Path:
    return _write_markdown(output_dir, repository, content, "full")


def write_teacher_review_report(
    output_dir: Path,
    repository: StudentAuditRepository,
    content: str,
) -> Path:
    return _write_markdown(output_dir, repository, content, "teacher-review")
