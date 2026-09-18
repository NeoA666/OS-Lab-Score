from __future__ import annotations

import os
import re
import tempfile
from pathlib import Path
from typing import Any

from .policy import PolicyDocument
from .repository import StudentAuditRepository


TEACHER_REVIEW_LEVELS = {"R1", "R2"}
FULL_REPORT_FILENAME = "完整诚信审核报告.md"
TEACHER_REPORT_FILENAME = "教师诚信复核报告.md"
DISPOSITION_LABELS = {
    "N0": "不进入诚信复核",
    "N1": "教学过程提示",
    "R1": "学习能力复核",
    "R2": "正式诚信核实建议",
}
INTEGRITY_LABELS = {
    "完全诚信": "当前材料未形成诚信复核线索",
    "基本诚信": "存在教学提醒或资料边界，未形成高风险结论",
    "存在疑点": "贡献材料形成待教师核实线索",
    "高风险待核实": "满足独立证据门槛后进入正式核实",
    "资料不足/无法判定": "当前材料不足以作出诚信判断",
}
_SECRET_TEXT_RE = re.compile(
    r"(?i)(?:nvapi-[A-Za-z0-9_-]+|bearer\s+[A-Za-z0-9._~+/=-]+|"
    r"(?:api[_ -]?key|token|password)\s*[:=]\s*[^\s,;]+)"
)


def _bullet(items: list[str]) -> str:
    return "\n".join(f"- {_safe_text(item)}" for item in items)


def _safe_text(value: Any, limit: int | None = None) -> str:
    text = _SECRET_TEXT_RE.sub("[已脱敏]", str(value))
    if limit is not None and len(text) > limit:
        return text[: max(0, limit - 3)] + "..."
    return text


def _table_cell(value: Any) -> str:
    return _safe_text(value).replace("|", "\\|").replace("\n", "<br>")


def _table(headers: list[str], rows: list[list[Any]]) -> list[str]:
    lines = [
        "| " + " | ".join(_table_cell(item) for item in headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    lines.extend("| " + " | ".join(_table_cell(item) for item in row) + " |" for row in rows)
    return lines


def _blockquote(text: str) -> str:
    return "\n".join(f"> {_safe_text(line)}" for line in str(text).splitlines())


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
    return _safe_text("；".join(pieces) or "清洗材料未提供可展示的原始定位")


def _v3_ref_locator(reference: dict[str, Any]) -> str:
    """Render only bounded v3 identity fields, never the complete source."""

    source_id = reference.get("source_id", "未知 source")
    path = reference.get("relative_path", "未知路径")
    sha256 = reference.get("sha256", "未知哈希")
    line_start = reference.get("line_start", "?")
    line_end = reference.get("line_end", "?")
    return (
        f"source：`{_safe_text(source_id)}`；路径：`{_safe_text(path)}`；"
        f"SHA-256：`{_safe_text(sha256)}`；行：`{line_start}-{line_end}`"
    )


def _render_v3_evidence(item: dict[str, Any], index: int, include_locator: bool) -> list[str]:
    unit_id = _safe_text(item.get("unit_id", "未知单元"), 200)
    label = _safe_text(item.get("unit_label", "indeterminate"), 80)
    confidence = _safe_text(item.get("unit_confidence", "weak"), 40)
    lines = [
        f"#### 证据 {index}：`{_safe_text(item.get('evidence_level', 'E2'))}` / 贡献单元 `{unit_id}`",
        "",
        f"贡献画像：`{label}`；置信度：`{confidence}`",
        "",
    ]
    references = item.get("evidence_refs", [])
    if not isinstance(references, list) or not references:
        lines.extend(["来源引用：未提供可展示的范围引用。", ""])
        return lines
    for ref_index, reference in enumerate(references, start=1):
        if not isinstance(reference, dict):
            continue
        excerpt = _safe_text(reference.get("excerpt", ""), 600)
        if include_locator:
            lines.extend(
                [
                    f"**来源 {ref_index}**：{_v3_ref_locator(reference)}",
                    "",
                    _blockquote(excerpt),
                    "",
                ]
            )
        else:
            # The complete report keeps the same bounded identity in a
            # collapsible block so the first screen remains scannable.
            lines.extend(
                [
                    "<details>",
                    "<summary>展开查看来源定位</summary>",
                    "",
                    f"**来源 {ref_index}**：{_v3_ref_locator(reference)}",
                    "",
                    "</details>",
                    "",
                    _blockquote(excerpt),
                    "",
                ]
            )
    return lines


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


_CONTRIBUTION_LABELS = {
    "ai_dominant": "AI 主导线索",
    "human_dominant": "人工主导线索",
    "mixed": "混合贡献线索",
    "indeterminate": "无法区分",
}


def _integrity_assessment_payload(assessment: dict[str, Any]) -> dict[str, Any] | None:
    value = assessment.get("integrity_assessment")
    if isinstance(value, dict):
        return value
    # Keep compatibility with an early flat producer while the host is being
    # migrated to the nested contract.
    if isinstance(assessment.get("integrity_label"), str):
        return {
            "overall_label": assessment.get("integrity_label"),
            "overall_disposition": assessment.get("integrity_disposition"),
            "coverage": assessment.get("coverage", {}),
            "contribution_access": assessment.get("contribution_access", {}),
            "teacher_actions": assessment.get("teacher_actions", []),
            "limitations": assessment.get("integrity_limitations", []),
            "contribution_units": assessment.get("contribution_units", []),
        }
    return None


def _render_integrity_assessment(assessment: dict[str, Any]) -> list[str]:
    """Render the host-owned conclusion and bounded v3 context near the top."""

    payload = _integrity_assessment_payload(assessment)
    if payload is None:
        return []
    label = _safe_text(payload.get("overall_label", "资料不足/无法判定"), 80)
    description = INTEGRITY_LABELS.get(label, "由宿主规则和证据门槛生成的处理标签")
    coverage = payload.get("coverage") if isinstance(payload.get("coverage"), dict) else {}
    access = payload.get("contribution_access") if isinstance(payload.get("contribution_access"), dict) else {}
    review_status = access.get("review_status", "未运行")
    lines = [
        "## 诚信结论（宿主判定）",
        "",
        "> 该标签是当前材料和规则门槛下的复核分流结果，不是违规认定、处分或评分决定。",
        "",
    ]
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["诚信标签", f"**{label}**"],
                ["标签说明", description],
                ["宿主处理路径", payload.get("overall_disposition", "未提供")],
                ["贡献材料状态", access.get("analysis_status", "未提供")],
                ["独立复核状态", review_status],
                ["材料覆盖", coverage.get("status", "未提供")],
                ["有效贡献单元", access.get("valid_unit_count", 0)],
            ],
        )
    )
    missing = coverage.get("missing_or_limited")
    if isinstance(missing, list) and missing:
        lines.extend(["", "**覆盖限制**：", _bullet([_safe_text(item, 500) for item in missing]), ""])

    actions = payload.get("teacher_actions")
    if isinstance(actions, list) and actions:
        lines.extend(["", "### 教师动作", "", _bullet([_safe_text(item, 800) for item in actions]), ""])
    limits = payload.get("limitations")
    if isinstance(limits, list) and limits:
        lines.extend(["", "### 宿主限制", "", _bullet([_safe_text(item, 800) for item in limits]), ""])

    units = payload.get("contribution_units")
    if not isinstance(units, list):
        units = payload.get("units")
    if isinstance(units, list) and units:
        rows: list[list[Any]] = []
        for unit in units[:96]:
            if not isinstance(unit, dict):
                continue
            raw_label = str(unit.get("label", "indeterminate"))
            refs = unit.get("evidence_refs", [])
            rows.append(
                [
                    f"`{_safe_text(unit.get('unit_id', '未知'), 120)}`",
                    _CONTRIBUTION_LABELS.get(raw_label, raw_label),
                    unit.get("confidence", "weak"),
                    len(refs) if isinstance(refs, list) else 0,
                    _short_text(_safe_text(unit.get("summary", ""), 120), 80),
                ]
            )
        if rows:
            lines.extend(["", "### 贡献单元（补充材料）", ""])
            lines.extend(_table(["单元", "画像", "置信度", "引用数", "摘要"], rows))
            lines.append("")

    # Show source identity and short redacted excerpts only.  We deliberately
    # do not render arbitrary nested model fields or complete source files.
    refs: list[dict[str, Any]] = []
    for container in (payload.get("evidence"),):
        if isinstance(container, list):
            for item in container:
                if isinstance(item, dict):
                    refs.extend(ref for ref in item.get("evidence_refs", []) if isinstance(ref, dict))
    if isinstance(units, list):
        for unit in units:
            if isinstance(unit, dict):
                refs.extend(ref for ref in unit.get("evidence_refs", []) if isinstance(ref, dict))
    lab_conclusion = access.get("lab_conclusion")
    if isinstance(lab_conclusion, dict):
        refs.extend(
            ref for ref in lab_conclusion.get("evidence_refs", []) if isinstance(ref, dict)
        )
    seen: set[tuple[Any, ...]] = set()
    bounded_refs: list[dict[str, Any]] = []
    for ref in refs:
        key = tuple(ref.get(name) for name in ("source_id", "line_start", "line_end", "sha256"))
        if key in seen:
            continue
        seen.add(key)
        bounded_refs.append(ref)
    if bounded_refs:
        lines.extend(["### 贡献来源定位", ""])
        for ref in bounded_refs[:96]:
            lines.extend(
                [
                    f"- {_v3_ref_locator(ref)}；摘录：{_safe_text(ref.get('excerpt', ''), 600)}",
                ]
            )
        lines.append("")
    return lines


def _render_evidence(evidence: list[dict[str, Any]], include_locator: bool) -> list[str]:
    lines: list[str] = []
    for index, item in enumerate(evidence, start=1):
        if item.get("kind") == "v3" or "unit_id" in item or "evidence_refs" in item:
            lines.extend(_render_v3_evidence(item, index, include_locator))
            continue
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
    lines.extend(_render_integrity_assessment(assessment))
    if lines and lines[-1] != "":
        lines.append("")
    lines.extend(["## 审核摘要", ""])
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
    lines.extend(_render_integrity_assessment(assessment))
    if lines and lines[-1] != "":
        lines.append("")
    lines.extend(
        _table(
            ["项目", "内容"],
            [
                ["学生标识", f"`{student_id}`"],
                ["实验", f"`{repository.lab}`"],
                ["待复核条目", f"R1 {dispositions['R1']} 项，R2 {dispositions['R2']} 项"],
                ["规则版本", f"`{policy.sha256}`"],
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
    """Write a report to its stable student/lab location.

    The previous implementation appended a timestamp to every report name,
    which made the current result difficult to locate and left stale runs in
    the output directory.  The path is now the current result for one
    student/lab; run timestamps remain in the trace and manifest.
    """

    target = report_path(output_dir, repository, report_kind)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="\n",
            dir=target.parent,
            prefix=".audit-report-",
            suffix=".tmp",
            delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(content)
        os.replace(temporary, target)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()
    return target


def _safe_component(value: str | None, fallback: str) -> str:
    """Return a path component that cannot escape the report root."""

    text = str(value or "").strip()
    cleaned = "".join(
        character if (character.isalnum() or character in "-_.") else "_"
        for character in text
    ).strip(".")
    return cleaned[:160] or fallback


def report_path(output_dir: Path, repository: StudentAuditRepository, report_kind: str) -> Path:
    """Return the stable path for one report without creating it.

    Reports are separated by the student directory name and the lab label.
    The directory name is used instead of a timestamp or only the student ID,
    because it is the identity used by the cleaned-data tree and remains
    unique when a data set contains duplicate or missing IDs.
    """

    filename = {
        "full": FULL_REPORT_FILENAME,
        "teacher-review": TEACHER_REPORT_FILENAME,
    }.get(report_kind)
    if filename is None:
        raise ValueError(f"未知报告类型：{report_kind}")
    student_component = _safe_component(repository.reference.directory_name, "student")
    lab_component = _safe_component(repository.lab, "lab")
    return Path(output_dir) / student_component / lab_component / filename


def write_report(output_dir: Path, repository: StudentAuditRepository, content: str) -> Path:
    return _write_markdown(output_dir, repository, content, "full")


def write_teacher_review_report(
    output_dir: Path,
    repository: StudentAuditRepository,
    content: str,
) -> Path:
    return _write_markdown(output_dir, repository, content, "teacher-review")
