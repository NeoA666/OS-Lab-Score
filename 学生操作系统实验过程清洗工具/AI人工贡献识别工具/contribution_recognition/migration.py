"""Offline migration of legacy AI contribution-recognition artifacts."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from output_layout import AI_TOOL, ensure_layout, paired_paths, tool_paths, write_bytes_pair


_ARTIFACTS = (
    ("assessment", "assessment_{lab}.json"),
    ("完整贡献识别报告", "完整贡献识别报告_{lab}.md"),
    ("教师贡献复核报告", "教师贡献复核报告_{lab}.md"),
)
_LEGACY_DIRECTORY = "AI人工贡献识别"


def _sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def _preserve(source: Path, target: Path) -> str:
    """Copy unchanged bytes to both views, refusing conflicting new results."""

    content = source.read_bytes()
    for candidate in paired_paths(target):
        if candidate.exists() and candidate.read_bytes() != content:
            raise ValueError(f"目标已有不同内容，未覆盖：{candidate}")
    write_bytes_pair(target, content)
    return _sha256(content)


def _legacy_artifact(old_directory: Path, category: str, filename: str) -> Path | None:
    categorized = old_directory / category / filename
    if categorized.is_file():
        return categorized
    flat = old_directory / filename
    return flat if flat.is_file() else None


def migrate_legacy(cleaned_root: Path) -> dict[str, object]:
    """Preserve legacy artifacts in both views without analyzing or deleting.

    The migration deliberately copies original bytes and records source hashes.
    It does not construct a v3 cache manifest and never instantiates a model
    client, so migrated findings cannot be mistaken for a fresh assessment.
    """

    root = Path(cleaned_root).resolve()
    if not root.is_dir():
        raise ValueError(f"已清洗根目录不存在：{root}")
    ensure_layout(root)
    records: list[dict[str, str]] = []
    for student_directory in sorted(root.iterdir(), key=lambda path: path.name):
        if not student_directory.is_dir() or student_directory.is_symlink():
            continue
        legacy = student_directory / _LEGACY_DIRECTORY
        if not legacy.is_dir() or legacy.is_symlink():
            continue
        for number in range(9):
            lab = f"lab{number}"
            target_directory = tool_paths(root, student_directory.name, lab, AI_TOOL)[0]
            migrated = False
            for category, template in _ARTIFACTS:
                filename = template.format(lab=lab)
                source = _legacy_artifact(legacy, category, filename)
                if source is None:
                    continue
                target = target_directory / filename
                records.append(
                    {
                        "student": student_directory.name,
                        "lab": lab,
                        "source": source.relative_to(root).as_posix(),
                        "target": target.relative_to(root).as_posix(),
                        "sha256": _preserve(source, target),
                    }
                )
                migrated = True
            if migrated:
                write_bytes_pair(
                    target_directory / "历史结果说明.md",
                    (
                        "# 历史 AI 人工贡献识别结果\n\n"
                        "本目录由旧版产物离线迁移，未调用模型，也未重新验证结论。"
                        "这些结果不作为新版有效缓存。\n"
                    ).encode("utf-8"),
                )

    summary = {
        "mode": "historical_offline_migration",
        "model_called": False,
        "source_files_preserved": True,
        "artifact_count": len(records),
        "artifacts": records,
    }
    summary_path = root / "汇总报告" / "AI人工贡献识别_历史迁移清单.json"
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {"artifact_count": len(records), "summary": str(summary_path), "model_called": False}
