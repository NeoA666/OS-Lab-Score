"""Explicit offline preservation of historical AI results; never calls a model."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from output_layout import AI_TOOL, ensure_layout, paired_paths, tool_paths, write_bytes_pair, _validate_target


def _preserve(source: Path, target: Path) -> str:
    _validate_target(source)
    content = source.read_bytes()
    for destination in paired_paths(target):
        if destination.exists() and destination.read_bytes() != content:
            raise ValueError(f"目标已有不同内容，未覆盖：{destination}")
    write_bytes_pair(target, content)
    return hashlib.sha256(content).hexdigest()


def migrate_legacy(cleaned_root: Path) -> dict:
    """Preserve original bytes in both views, leaving old source files in place.

    Original manifests are archived separately so old evidence paths and hashes
    cannot be mistaken for a current-layout cache hit.
    """
    root = cleaned_root.resolve()
    if not root.is_dir():
        raise ValueError(f"已清洗根目录不存在：{root}")
    ensure_layout(root)
    summary_path = root / "汇总报告" / "AI人工贡献识别_历史迁移清单.json"
    records_by_source = {}
    if summary_path.is_file():
        _validate_target(summary_path)
        previous = json.loads(summary_path.read_text(encoding="utf-8"))
        for record in previous.get("artifacts", []):
            target = root / record["target"]
            if not target.resolve().is_relative_to(root):
                raise ValueError("历史迁移清单目标越过根目录")
            for candidate in paired_paths(target):
                _validate_target(candidate)
            valid = next((candidate for candidate in paired_paths(target)
                          if candidate.is_file() and hashlib.sha256(candidate.read_bytes()).hexdigest() == record["sha256"]), None)
            if valid is None:
                raise ValueError(f"历史迁移结果无法通过哈希校验：{target}")
            # Refuse different contents; repair only a missing counterpart.
            _preserve(valid, target)
            records_by_source[record["source"]] = record
    for student in sorted(root.iterdir()):
        if not student.is_dir() or student.is_symlink():
            continue
        old = student / "AI人工贡献识别"
        if not old.is_dir():
            continue
        _validate_target(old)
        for number in range(9):
            lab = f"lab{number}"
            target = tool_paths(root, student.name, lab, AI_TOOL)[0]
            candidates = (("assessment", f"assessment_{lab}.json"),
                          ("完整贡献识别报告", f"完整贡献识别报告_{lab}.md"),
                          ("教师贡献复核报告", f"教师贡献复核报告_{lab}.md"))
            copied = False
            for category, name in candidates:
                source = old / category / name
                if not source.is_file():
                    source = old / name
                if not source.is_file():
                    continue
                digest = _preserve(source, target / name)
                source_name = str(source.relative_to(root))
                records_by_source[source_name] = {"student": student.name, "lab": lab,
                                                  "source": source_name,
                                                  "target": str((target / name).relative_to(root)), "sha256": digest}
                copied = True
            if copied:
                write_bytes_pair(target / "历史结果说明.md", (
                    "# 历史 AI 人工贡献识别结果\n\n"
                    "本目录结果由旧版输出离线迁移，JSON 和报告正文保持原始字节。"
                    "迁移未调用模型，也未重新验证结论。旧证据路径、行号和哈希保留历史含义，"
                    "不代表本次重新清洗后的材料；这些结果不作为新版有效缓存。\n"
                ).encode("utf-8"))
        manifest = old / ".contribution_manifest.json"
        if manifest.is_file():
            _preserve(manifest, root / "运行日志" / AI_TOOL / "历史迁移" / student.name / manifest.name)
    for old_name, new_parent in (("AI人工贡献识别汇总", root / "汇总报告" / "AI人工贡献识别_历史汇总"),
                                  ("AI人工贡献识别运行日志", root / "运行日志" / AI_TOOL / "历史运行日志")):
        old = root / old_name
        if old.is_dir():
            _validate_target(old)
            for source in sorted(old.rglob("*")):
                if source.is_file():
                    _preserve(source, new_parent / source.relative_to(old))
    records = sorted(records_by_source.values(), key=lambda item: item["source"])
    summary = {"mode": "historical_offline_migration", "model_called": False,
               "source_files_preserved": True, "artifact_count": len(records), "artifacts": records}
    write_bytes_pair(summary_path, (json.dumps(summary, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))
    assessments = [record for record in records if Path(record["target"]).name.startswith("assessment_")]
    lines = ["# AI 人工贡献识别历史迁移总览", "",
             f"保留 {len(assessments)} 个历史识别结果、{len(records)} 份原始产物，每份保存于两种分类。", "",
             "本次仅进行离线迁移，未调用模型、未重新分析或验证结论。旧证据路径和哈希保留历史含义，不作为新版有效缓存。", "",
             "| 学生 | 历史 Lab |", "| --- | --- |"]
    for student in sorted({record["student"] for record in assessments}):
        labs = sorted({record["lab"] for record in assessments if record["student"] == student})
        lines.append(f"| {student.replace('|', '/')} | {', '.join(labs)} |")
    write_bytes_pair(root / "汇总报告" / "AI人工贡献识别_历史迁移总览.md", ("\n".join(lines) + "\n").encode("utf-8"))
    return {"artifact_count": len(records), "summary": str(summary_path), "model_called": False}
