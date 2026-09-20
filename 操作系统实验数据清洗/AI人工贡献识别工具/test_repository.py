from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from contribution_recognition.errors import InvalidReferenceError
from contribution_recognition.repository import (
    COMMAND_STATISTICS_DIRECTORY,
    DIFF_DIRECTORY,
    MAX_MATERIAL_READ_LINES,
    SIMPLE_TIMELINE_DIRECTORY,
    TERMINAL_QA_DIRECTORY,
    ContributionRepository,
)


_DIRECTORIES = {
    "timeline": SIMPLE_TIMELINE_DIRECTORY,
    "terminal_qa": TERMINAL_QA_DIRECTORY,
    "command_statistics": COMMAND_STATISTICS_DIRECTORY,
    "diff_report": DIFF_DIRECTORY,
}
_FILENAMES = {
    "timeline": "timeline_{lab}.md",
    "terminal_qa": "terminal_qa_report_{lab}.md",
    "command_statistics": "command_statistics_{lab}.md",
    "diff_report": "{lab}.md",
}


def _write_material(root: Path, student: str, lab: str, kind: str, body: str) -> Path:
    path = root / student / _DIRECTORIES[kind] / _FILENAMES[kind].format(lab=lab)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8")
    return path


def _write_process_bundle(root: Path, student: str, lab: str, *, marker: str = "evidence") -> None:
    _write_material(root, student, lab, "timeline", f"timeline {marker}\nline two\n")
    _write_material(root, student, lab, "terminal_qa", f"terminal {marker}\nanswer\n")
    _write_material(root, student, lab, "command_statistics", f"command {marker}\ncount\n")


def _diff_body() -> str:
    return "\n".join(
        [
            "# lab1 源码差异报告",
            "",
            "### `kernel/example.c`（修改）",
            "",
            "```diff",
            "diff --git a/kernel/example.c b/kernel/example.c",
            "@@ -10,2 +10,3 @@ static int example(void)",
            " old_line();",
            "-remove_line();",
            "+add_line();",
            "+another_line();",
            "```",
            "",
        ]
    )


class ContributionRepositoryV2Tests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.cleaned_root = Path(self.temporary_directory.name)

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def test_lab0_requires_only_the_three_process_materials(self) -> None:
        _write_process_bundle(self.cleaned_root, "student-lab0", "lab0", marker="lab0 unique source")
        # A stray legacy-style lab0 diff cannot become a v2 input.
        _write_material(self.cleaned_root, "student-lab0", "lab0", "diff_report", _diff_body())
        repository = ContributionRepository(self.cleaned_root)

        snapshot = repository.build_snapshot("student-lab0", "lab0")
        materials = {item.kind: item for item in snapshot.materials}

        self.assertTrue(snapshot.analysis_ready)
        self.assertEqual(set(materials), set(_DIRECTORIES))
        self.assertTrue(materials["timeline"].required)
        self.assertTrue(materials["terminal_qa"].required)
        self.assertTrue(materials["command_statistics"].required)
        self.assertFalse(materials["diff_report"].required)
        self.assertEqual(materials["diff_report"].availability, "not_applicable")
        self.assertEqual(snapshot.diff_hunks, ())
        self.assertNotIn("lab0 unique source", json.dumps(snapshot.to_dict(), ensure_ascii=False))
        self.assertEqual(
            [(task.directory_name, task.lab) for task in repository.discover_tasks()],
            [("student-lab0", "lab0")],
        )

    def test_lab1_missing_a_required_process_material_is_not_analysis_ready(self) -> None:
        _write_material(self.cleaned_root, "incomplete", "lab1", "timeline", "timeline only\n")
        _write_material(self.cleaned_root, "incomplete", "lab1", "diff_report", _diff_body())
        repository = ContributionRepository(self.cleaned_root)

        snapshot = repository.build_snapshot("incomplete", "lab1")
        materials = {item.kind: item for item in snapshot.materials}

        self.assertFalse(snapshot.analysis_ready)
        self.assertEqual(materials["terminal_qa"].availability, "missing")
        self.assertEqual(materials["command_statistics"].availability, "missing")
        self.assertEqual(materials["diff_report"].availability, "available")
        self.assertEqual(materials["diff_report"].relative_path, "代码差异报告/lab1.md")
        self.assertEqual(len(snapshot.diff_hunks), 1)
        hunk = snapshot.diff_hunks[0]
        self.assertEqual(hunk.source_id, "source:lab1:diff_report")
        self.assertEqual(hunk.file_path, "kernel/example.c")
        self.assertEqual((hunk.line_start, hunk.line_end), (7, 11))
        self.assertEqual((hunk.old_line_start, hunk.old_line_count), (10, 2))
        self.assertEqual((hunk.new_line_start, hunk.new_line_count), (10, 3))
        self.assertNotIn("add_line", json.dumps(snapshot.to_dict(), ensure_ascii=False))
        self.assertFalse(hasattr(hunk, "patch"))

    def test_read_api_enforces_source_scope_bounds_and_redacts_secrets(self) -> None:
        _write_process_bundle(self.cleaned_root, "reader", "lab0", marker="safe evidence")
        _write_material(
            self.cleaned_root,
            "reader",
            "lab0",
            "timeline",
            "first\napi_key = sk-123456789012345\nthird\n",
        )
        repository = ContributionRepository(self.cleaned_root)
        snapshot = repository.build_snapshot("reader", "lab0")

        excerpt = repository.read_snapshot_material(snapshot, "source:lab0:timeline", 1, 3)

        self.assertEqual((excerpt.line_start, excerpt.line_end), (1, 3))
        self.assertIn("[REDACTED]", excerpt.text)
        self.assertNotIn("sk-123456789012345", excerpt.text)
        with self.assertRaises(InvalidReferenceError):
            repository.read_snapshot_material(snapshot, "source:lab0:timeline", 0, 1)
        with self.assertRaises(InvalidReferenceError):
            repository.read_snapshot_material(snapshot, "source:lab0:timeline", 1, 4)
        with self.assertRaises(InvalidReferenceError):
            repository.read_snapshot_material(
                snapshot,
                "source:lab0:timeline",
                1,
                MAX_MATERIAL_READ_LINES + 1,
            )

    def test_discovery_unions_materials_and_reading_cannot_cross_labs(self) -> None:
        _write_material(self.cleaned_root, "union", "lab0", "terminal_qa", "lab0 terminal\n")
        _write_material(self.cleaned_root, "union", "lab1", "diff_report", _diff_body())
        _write_process_bundle(self.cleaned_root, "isolated", "lab1", marker="student one only")
        _write_material(self.cleaned_root, "isolated", "lab1", "diff_report", _diff_body())
        _write_process_bundle(self.cleaned_root, "other", "lab2", marker="student two only")
        _write_material(self.cleaned_root, "other", "lab2", "diff_report", _diff_body())
        repository = ContributionRepository(self.cleaned_root)

        tasks = {(task.directory_name, task.lab) for task in repository.discover_tasks()}
        self.assertEqual(
            tasks,
            {("union", "lab0"), ("union", "lab1"), ("isolated", "lab1"), ("other", "lab2")},
        )

        snapshot = repository.build_snapshot("isolated", "lab1")
        excerpt = repository.read_snapshot_material(snapshot, "source:lab1:timeline", 1, 2)
        self.assertIn("student one only", excerpt.text)
        self.assertNotIn("student two only", excerpt.text)
        with self.assertRaises(InvalidReferenceError):
            repository.read_snapshot_material(snapshot, "source:lab2:timeline", 1, 1)


if __name__ == "__main__":
    unittest.main()
