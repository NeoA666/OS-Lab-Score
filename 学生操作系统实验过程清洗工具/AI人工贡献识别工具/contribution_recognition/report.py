"""Safe Markdown renderers for the breaking v3 contribution contract.

The JSON assessment is the only machine interface. Markdown deliberately keeps
only bounded, redacted excerpts and source locations; it never renders full
source material, raw NIM output, or model-private reasoning.
"""

from __future__ import annotations

from typing import Any

from .redaction import redact_sensitive_text
from .storage import REPORT_TEMPLATE_VERSION


V3_SCHEMA_VERSION = "ai-human-contribution-assessment/v3"
EXCERPT_LIMIT = 280
SUMMARY_LIMIT = 600

UNIT_LABELS = {
    "ai_dominant": "AI 贡献为主",
    "human_dominant": "人工贡献为主",
    "mixed": "AI 与人工共同贡献",
    "indeterminate": "无法判断贡献归属",
}
CONFIDENCE_LABELS = {"strong": "强", "moderate": "中等", "weak": "弱"}
REVIEW_LABELS = {
    "agreed": "NIM 主分析与独立 NIM 复核一致",
    "disagreed": "独立 NIM 复核存在分歧，相关单元已降级为无法判断",
    "not_run": "未执行独立 NIM 复核",
}
ROLE_LABELS = {
    "ai_explanation": "AI 解释",
    "ai_advice": "AI 建议",
    "ai_guidance": "AI 指导",
    "ai_code_generation": "AI 生成代码",
    "ai_execution": "AI 执行建议",
    "human_question": "人工提问",
    "human_prompting": "人工提问",
    "human_implementation": "人工实现",
    "human_editing": "人工查看或编辑",
    "human_code_editing": "人工编辑代码",
    "human_execution": "人工执行命令",
    "human_debugging": "人工调试",
    "human_verification": "人工验证",
    "human_testing": "人工测试",
}


def _dict(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else {}


def _list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []


def _text(value: Any, limit: int = SUMMARY_LIMIT) -> str:
    text = redact_sensitive_text(str(value or "")).replace("\r", "").replace("\n", " ").strip()
    return text if len(text) <= limit else text[: max(0, limit - 1)].rstrip() + "…"


def _ids(value: Any, limit: int = 12) -> str:
    items = [_text(item, 120) for item in _list(value)]
    items = [item for item in items if item]
    if len(items) > limit:
        return ", ".join(items[:limit]) + f"，另有 {len(items) - limit} 项"
    return ", ".join(items) or "无"


def _require_v3(assessment: dict[str, Any]) -> None:
    if assessment.get("schema_version") != V3_SCHEMA_VERSION:
        raise ValueError(f"报告只支持 {V3_SCHEMA_VERSION}")


def _coverage_lines(assessment: dict[str, Any]) -> list[str]:
    coverage = _dict(assessment.get("coverage"))
    status = _text(coverage.get("status"), 80) or "unknown"
    lines = [f"- 资料覆盖：{status}"]
    for value in _list(coverage.get("missing_or_limited")):
        text = _text(value, 300)
        if text:
            lines.append(f"- 限制：{text}")
    return lines


def _source_manifest_lines(assessment: dict[str, Any], include_hunks: bool) -> list[str]:
    sources = [item for item in _list(assessment.get("source_manifest")) if isinstance(item, dict)]
    lines = _coverage_lines(assessment)
    if not sources:
        return lines + ["- 未提供来源清单。"]
    for source in sources:
        source_id = _text(source.get("source_id"), 120) or "未命名来源"
        kind = _text(source.get("kind"), 80) or "unknown"
        path = _text(source.get("relative_path"), 300) or "未提供路径"
        sha = _text(source.get("sha256"), 128) or "未提供哈希"
        count = _text(source.get("line_count"), 32) or "未知"
        availability = _text(source.get("availability"), 80) or "unknown"
        reason = _text(source.get("reason"), 300)
        suffix = f"；原因：{reason}" if reason else ""
        lines.append(f"- `{source_id}`（{kind}）：{availability}；`{path}`；SHA-256 `{sha}`；{count} 行{suffix}")
    if not include_hunks:
        return lines
    hunks = [item for item in _list(assessment.get("diff_hunks")) if isinstance(item, dict)]
    if hunks:
        lines.extend(["", "### Diff 定位", ""])
        for hunk in hunks[:80]:
            hunk_id = _text(hunk.get("hunk_id"), 120) or "未命名 hunk"
            path = _text(hunk.get("file_path"), 300) or "未提供文件"
            source_id = _text(hunk.get("source_id"), 120) or "未知来源"
            start = _text(hunk.get("line_start"), 32) or "?"
            end = _text(hunk.get("line_end"), 32) or start
            lines.append(f"- `{hunk_id}`：`{path}`，来源 `{source_id}` 第 {start}-{end} 行")
        if len(hunks) > 80:
            lines.append(f"- 其余 {len(hunks) - 80} 个 hunk 未在 Markdown 中展开。")
    return lines


def _evidence_lines(value: Any, limit: int) -> list[str]:
    refs = [item for item in _list(value) if isinstance(item, dict)]
    if not refs:
        return ["- 证据引用：无"]
    lines: list[str] = []
    for ref in refs[:limit]:
        source_id = _text(ref.get("source_id"), 120) or "未知来源"
        path = _text(ref.get("relative_path"), 300) or "未提供路径"
        sha = _text(ref.get("sha256"), 128) or "未提供哈希"
        start = _text(ref.get("line_start"), 32) or "?"
        end = _text(ref.get("line_end"), 32) or start
        excerpt = _text(ref.get("excerpt"), EXCERPT_LIMIT)
        lines.append(f"- 证据 `{source_id}`：`{path}`；SHA-256 `{sha}`；第 {start}-{end} 行")
        if excerpt:
            lines.append(f"  - 脱敏短摘录：{excerpt}")
    if len(refs) > limit:
        lines.append(f"- 其余 {len(refs) - limit} 条证据仅保留在 JSON assessment 中。")
    return lines


def _scope_lines(unit: dict[str, Any]) -> list[str]:
    scope = _dict(unit.get("scope"))
    hunk_id = _text(scope.get("hunk_id"), 120)
    if hunk_id:
        return [f"- 代码 hunk：`{hunk_id}`"]
    source_id = _text(scope.get("source_id"), 120) or "未知来源"
    start = _text(scope.get("line_start"), 32) or "?"
    end = _text(scope.get("line_end"), 32) or start
    return [f"- 过程范围：`{source_id}` 第 {start}-{end} 行"]


def _roles(value: Any) -> str:
    roles = _dict(value)
    ai = [ROLE_LABELS.get(item, item) for item in (_text(item, 100) for item in _list(roles.get("ai"))) if item]
    human = [ROLE_LABELS.get(item, item) for item in (_text(item, 100) for item in _list(roles.get("human"))) if item]
    groups = []
    if ai:
        groups.append("AI：" + "、".join(ai))
    if human:
        groups.append("人工：" + "、".join(human))
    return "；".join(groups) or "未记录"


def _unit_lines(unit: dict[str, Any], index: int, evidence_limit: int, include_limitations: bool) -> list[str]:
    label = str(unit.get("label") or "indeterminate")
    confidence = str(unit.get("confidence") or "weak")
    lines = [
        f"### {index}. {UNIT_LABELS.get(label, _text(label) or '无法判断')}",
        "",
        f"- 单元 ID：`{_text(unit.get('unit_id'), 120) or '未提供'}`",
        f"- 类型：{_text(unit.get('unit_type'), 80) or '未知'}",
        f"- 置信度：{CONFIDENCE_LABELS.get(confidence, _text(confidence) or '未知')}",
        f"- 可观察角色：{_roles(unit.get('behavior_roles'))}",
        f"- 摘要：{_text(unit.get('summary')) or '未提供摘要。'}",
        f"- 替代解释：{_text(unit.get('alternative_explanation')) or '现有材料不足以排除其他解释。'}",
        *_scope_lines(unit),
        *_evidence_lines(unit.get("evidence_refs"), evidence_limit),
    ]
    if include_limitations:
        limitations = [_text(item) for item in _list(unit.get("limitations"))]
        lines.append("- 单元局限：" + ("；".join(item for item in limitations if item) or "未额外记录。"))
    return lines + [""]


def _conclusion_lines(assessment: dict[str, Any]) -> list[str]:
    conclusion = _dict(assessment.get("lab_conclusion"))
    label = str(conclusion.get("label") or "indeterminate")
    confidence = str(conclusion.get("confidence") or "weak")
    lines = [
        f"- 总体画像：{UNIT_LABELS.get(label, _text(label) or '材料不足或无法判断')}",
        f"- 画像置信度：{CONFIDENCE_LABELS.get(confidence, _text(confidence) or '未知')}",
        f"- 自动摘要：{_text(conclusion.get('summary')) or '当前材料不足以形成稳定的贡献画像。'}",
        *_evidence_lines(conclusion.get("evidence_refs"), 4),
    ]
    alternative = _text(conclusion.get("alternative_explanation"))
    if alternative:
        lines.append(f"- 替代解释：{alternative}")
    limitations = [_text(item) for item in _list(conclusion.get("limitations"))]
    limitations = [item for item in limitations if item]
    if limitations:
        lines.append("- 实验级局限：" + "；".join(limitations))
    return lines


def _review_lines(assessment: dict[str, Any]) -> list[str]:
    review = _dict(assessment.get("review"))
    status = str(review.get("status") or "not_run")
    return [
        f"- 复核状态：{REVIEW_LABELS.get(status, _text(status) or '未知')}",
        f"- 复核总体决策：{_text(review.get('overall_decision')) or '未提供'}",
        f"- 复核摘要：{_text(review.get('summary')) or '未提供'}",
        f"- 已复核单元：{_ids(review.get('reviewed_unit_ids'))}",
        f"- 存在分歧的单元：{_ids(review.get('disagreement_unit_ids'))}",
    ]


def _unit_review_lines(assessment: dict[str, Any]) -> list[str]:
    review = _dict(assessment.get("review"))
    unit_reviews = [item for item in _list(review.get("unit_reviews")) if isinstance(item, dict)]
    if not unit_reviews:
        return ["- 未提供单元级独立复核记录。"]
    lines: list[str] = []
    for item in unit_reviews[:16]:
        unit_id = _text(item.get("unit_id"), 120) or "未提供"
        decision = _text(item.get("decision"), 160) or "未提供"
        reason = _text(item.get("reason")) or "未提供"
        lines.extend([
            f"- 单元 `{unit_id}`：{decision}；理由：{reason}",
            *_evidence_lines(item.get("evidence_refs"), 4),
        ])
    if len(unit_reviews) > 16:
        lines.append(f"- 其余 {len(unit_reviews) - 16} 条单元复核记录仅保留在 JSON assessment 中。")
    return lines


def _limitations(value: Any) -> list[str]:
    items = [_text(item) for item in _list(value)]
    return [f"- {item}" for item in items if item] or ["- 未额外记录局限；这不表示材料足以证明实际作者身份。"]


def _run_metadata(assessment: dict[str, Any]) -> list[str]:
    metadata = _dict(assessment.get("run_metadata"))
    allowed = ("tool_version", "prompt_version", "validator_version", "completed_at", "model", "analysis_mode", "review_rounds")
    lines = [f"- Schema：`{_text(assessment.get('schema_version'), 120) or '未知'}`"]
    for key in allowed:
        if key in metadata:
            lines.append(f"- {key}：{_text(metadata.get(key), 300)}")
    return lines


def _header(assessment: dict[str, Any], title: str) -> list[str]:
    student = _dict(assessment.get("student"))
    return [
        title, "",
        f"- 学号：{_text(student.get('student_id'), 120) or '未知'}",
        f"- 学生目录：{_text(student.get('directory_name'), 300) or '未知'}",
        f"- 实验：{_text(assessment.get('lab'), 80) or '未知'}",
        f"- 分析状态：{_text(assessment.get('analysis_status'), 80) or '未知'}", "",
    ]


def _next_steps(assessment: dict[str, Any]) -> list[str]:
    status = str(assessment.get("analysis_status") or "")
    review = _dict(assessment.get("review"))
    units = [item for item in _list(assessment.get("contribution_units")) if isinstance(item, dict)]
    steps: list[str] = []
    if status == "insufficient_data":
        steps.append("补齐当前 Lab 的规定清洗材料后再进行贡献识别；资料缺失不能解释为未使用 AI。")
    elif status == "failed":
        steps.append("先处理本任务的运行失败，再使用新的 assessment 进行教学或审核复核。")
    if review.get("status") == "disagreed":
        steps.append("优先检查复核分歧单元的源文件哈希、行范围和脱敏短摘录。")
    if any(str(unit.get("label")) == "indeterminate" for unit in units):
        steps.append("对无法判断的单元，仅将其作为补充材料和教学沟通线索，不作作者或诚信推断。")
    if not steps:
        steps.append("按需要回到 source_id、路径、哈希与行范围复核关键证据。")
    return [f"- {step}" for step in steps]


def _method_statement(assessment: dict[str, Any]) -> str:
    """Describe exactly which NIM stages ran without inventing a review result."""

    status = str(assessment.get("analysis_status") or "")
    review_status = str(_dict(assessment.get("review")).get("status") or "not_run")
    if status == "complete" and review_status in {"agreed", "disagreed"}:
        return "该结果由 NIM 主分析和独立 NIM 复核产生，且仅作为补充证据材料。"
    if status == "complete":
        return "该结果包含 NIM 主分析；独立 NIM 复核未完成，因此只能作为受限的补充证据材料。"
    if status == "insufficient_data":
        return "当前结果仅记录规定清洗材料不足；未形成 NIM 贡献归因，资料缺失不能解释为未使用 AI。"
    return "本次识别未完成，未形成可供教学、诚信或评分使用的 NIM 贡献归因。"


def render_teacher_report(assessment: dict[str, Any]) -> str:
    """Render the compact v3 teacher-facing report."""

    _require_v3(assessment)
    lines = _header(assessment, "# 教师贡献复核报告")
    lines.extend([
        "## 自动结论", "", *_conclusion_lines(assessment), "",
        _method_statement(assessment) + "它不认定真实作者、手打或复制粘贴行为，也不输出诚信结论或分数。", "",
        "## 教师下一步", "", *_next_steps(assessment), "",
        "## 资料覆盖", "", *_source_manifest_lines(assessment, False), "",
        "## 关键贡献项", "",
    ])
    units = [item for item in _list(assessment.get("contribution_units")) if isinstance(item, dict)]
    if not units:
        lines.append("无可复核的贡献单元。")
    else:
        for index, unit in enumerate(units[:6], 1):
            lines.extend(_unit_lines(unit, index, 2, False))
        if len(units) > 6:
            lines.append(f"其余 {len(units) - 6} 个贡献单元见完整报告和 JSON assessment。")
    lines.extend([
        "## 代码变化与复核", "", *_review_lines(assessment), "",
        "## 局限与追溯", "", *_limitations(assessment.get("limitations")),
        *_run_metadata(assessment), f"- 报告模板版本：{REPORT_TEMPLATE_VERSION}", "",
    ])
    return "\n".join(lines)


def render_full_report(assessment: dict[str, Any]) -> str:
    """Render the complete v3 report without full source or NIM traces."""

    _require_v3(assessment)
    lines = _header(assessment, "# 完整贡献识别报告")
    lines.extend([
        "## 使用边界", "",
        _method_statement(assessment) + "它只可作为后续教学、诚信判别或评分机制的补充输入；下游必须自行复核源文件、哈希与行范围，并应用自身规则。", "",
        "## 输入材料清单", "", *_source_manifest_lines(assessment, True), "",
        "## 总体贡献画像", "", *_conclusion_lines(assessment), "",
        "## 独立复核", "", *_review_lines(assessment), *_unit_review_lines(assessment), "",
        "## 贡献单元", "",
    ])
    units = [item for item in _list(assessment.get("contribution_units")) if isinstance(item, dict)]
    if not units:
        lines.append("无可复核的贡献单元。")
    else:
        for index, unit in enumerate(units, 1):
            lines.extend(_unit_lines(unit, index, 8, True))
    lines.extend([
        "## 全局局限", "", *_limitations(assessment.get("limitations")), "",
        "## 运行追溯", "", *_run_metadata(assessment),
        f"- 报告模板版本：{REPORT_TEMPLATE_VERSION}", "",
    ])
    return "\n".join(lines)
