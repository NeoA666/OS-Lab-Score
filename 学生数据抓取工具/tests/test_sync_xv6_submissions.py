from __future__ import annotations

import hashlib
import io
import json
import os
import stat
import sys
import tarfile
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from datetime import datetime, timezone
from pathlib import Path
from types import SimpleNamespace
from unittest import mock


TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))
import sync_xv6_submissions as sync  # noqa: E402


class FakeSFTP:
    def __init__(
        self,
        indexes: dict[str, bytes] | None = None,
        archives: dict[str, bytes] | None = None,
        date_dirs: list[str] | None = None,
    ) -> None:
        self.indexes = indexes or {}
        self.archives = archives or {}
        self.date_dirs = date_dirs or []
        self.get_calls: list[tuple[str, str]] = []
        self.download_error: Exception | None = None

    def listdir_attr(self, remote_root: str) -> list[SimpleNamespace]:
        dates = sorted({Path(path).parent.name for path in self.indexes} | set(self.date_dirs))
        return [
            SimpleNamespace(filename=date, st_mode=stat.S_IFDIR | 0o755)
            for date in dates
        ]

    def open(self, path: str, mode: str) -> io.BytesIO:
        if path not in self.indexes:
            raise FileNotFoundError(path)
        return io.BytesIO(self.indexes[path])

    def get(self, remote_path: str, local_path: str) -> None:
        self.get_calls.append((remote_path, local_path))
        if self.download_error:
            raise self.download_error
        Path(local_path).write_bytes(self.archives[remote_path])

    def close(self) -> None:
        pass


class DummyClient:
    def close(self) -> None:
        pass


class SyncTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.output_root = Path(self.temp.name) / "output"
        self.original_output_root = sync.OUTPUT_ROOT
        sync.OUTPUT_ROOT = self.output_root

    def tearDown(self) -> None:
        sync.OUTPUT_ROOT = self.original_output_root
        self.temp.cleanup()

    def submission(
        self,
        *,
        student_id: str = "2406080104",
        name: str = "fangruxuan",
        stamp: str = "20260919-1856",
        filename: str | None = None,
        remote_path: str | None = None,
        index_time: str = "2026-09-19T10:56:00Z",
        size: int = 0,
        sha256: str = "a" * 64,
    ) -> sync.Submission:
        filename = filename or f"{student_id}-{name}-实验提交-{stamp}.tar.gz"
        return sync.Submission(
            student_id=student_id,
            name=name,
            filename=filename,
            remote_path=remote_path or f"/remote/20260919/{filename}",
            index_time=index_time,
            index_datetime=datetime.fromisoformat(index_time.replace("Z", "+00:00")),
            size=size,
            sha256=sha256,
            submission_stamp=stamp,
        )

    def tar_bytes(self, files: dict[str, bytes]) -> bytes:
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode="w:gz") as archive:
            for name, content in files.items():
                info = tarfile.TarInfo(name)
                info.size = len(content)
                archive.addfile(info, io.BytesIO(content))
        return stream.getvalue()

    def archive_submission(self, files: dict[str, bytes], **changes: object) -> tuple[sync.Submission, bytes]:
        archive = self.tar_bytes(files)
        changes.setdefault("size", len(archive))
        changes.setdefault("sha256", hashlib.sha256(archive).hexdigest())
        return self.submission(**changes), archive

    def make_directory(
        self,
        name: str,
        files: dict[str, bytes] | None = None,
        marker_submission: sync.Submission | None = None,
        marker_changes: dict[str, object] | None = None,
    ) -> Path:
        self.output_root.mkdir(exist_ok=True)
        directory = self.output_root / name
        directory.mkdir()
        for filename, content in (files or {}).items():
            path = directory / filename
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
        if marker_submission:
            sync.write_source_marker(directory, marker_submission)
            if marker_changes:
                marker_path = directory / sync.SOURCE_MARKER
                marker = json.loads(marker_path.read_text(encoding="utf-8"))
                marker.update(marker_changes)
                marker_path.write_text(json.dumps(marker), encoding="utf-8")
        return directory

    def student_directories(self, student_id: str) -> list[Path]:
        return sorted(
            child
            for child in self.output_root.iterdir()
            if child.is_dir() and sync.LOCAL_DIR_RE.fullmatch(child.name)
            and child.name.startswith(f"{student_id}-")
        )

    def marker(self, directory: Path) -> dict[str, object]:
        return json.loads((directory / sync.SOURCE_MARKER).read_text(encoding="utf-8"))

    def test_read_remote_indexes_selects_latest_and_warns_for_invalid_records(self) -> None:
        first, _ = self.archive_submission(
            {"data.txt": b"old"}, stamp="20260917-1729", name="old",
            index_time="2026-09-17T09:29:00Z",
        )
        second, _ = self.archive_submission(
            {"data.txt": b"new"}, stamp="20260919-1856", name="new"
        )
        tie_a, _ = self.archive_submission(
            {"data.txt": b"a"}, student_id="2406080118", name="alpha"
        )
        tie_b, _ = self.archive_submission(
            {"data.txt": b"b"}, student_id="2406080118", name="zeta"
        )
        row = lambda submission: json.dumps({
            "file": submission.filename,
            "time": submission.index_time,
            "size": submission.size,
            "sha256": submission.sha256,
        })
        indexes = {
            "/remote/20260917/index.jsonl": (row(first) + "\nnot json\n").encode(),
            "/remote/20260919/index.jsonl": (
                row(second) + "\n" + row(tie_a) + "\n" + row(tie_b) + "\n" +
                json.dumps({"file": "bad.tar.gz", "time": second.index_time, "size": 1, "sha256": "a" * 64}) + "\n" +
                json.dumps({"file": second.filename, "time": second.index_time, "size": 1, "sha256": "x" * 64}) + "\n"
            ).encode(),
        }
        latest, warnings = sync.read_remote_indexes(
            FakeSFTP(indexes=indexes, date_dirs=["20260920"]), "/remote"
        )

        self.assertEqual(latest[first.student_id].filename, second.filename)
        self.assertEqual(latest[tie_a.student_id].filename, max(tie_a.filename, tie_b.filename))
        self.assertGreaterEqual(len(warnings), 4)

    def test_added_downloads_and_publishes_complete_marker(self) -> None:
        submission, archive = self.archive_submission({"nested/data.txt": b"fresh"})
        sftp = FakeSFTP(archives={submission.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, submission), "ADDED")
        target = sync.target_dir_for(submission)
        self.assertEqual((target / "nested/data.txt").read_bytes(), b"fresh")
        self.assertEqual(len(sftp.get_calls), 1)
        marker = self.marker(target)
        self.assertEqual(marker["archive_name"], submission.filename)
        self.assertEqual(marker["remote_path"], submission.remote_path)
        self.assertEqual(marker["archive_sha256"], submission.sha256)
        self.assertIn("synced_at", marker)
        self.assertEqual(self.student_directories(submission.student_id), [target])

    def test_exact_match_is_skipped_without_download(self) -> None:
        submission, archive = self.archive_submission({"data.txt": b"current"})
        target = self.make_directory(sync.target_dir_for(submission).name, {"data.txt": b"current"}, submission)
        marker_before = (target / sync.SOURCE_MARKER).read_bytes()
        sftp = FakeSFTP(archives={submission.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, submission), "SKIPPED")
        self.assertEqual(sftp.get_calls, [])
        self.assertEqual((target / sync.SOURCE_MARKER).read_bytes(), marker_before)

    def test_same_sha_reconciles_metadata_and_directory_without_download(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"reused"})
        old = self.submission(
            name="old-name",
            stamp="20260916-1215",
            filename="2406080104-old-name-实验提交-20260916-1215.tar.gz",
            remote_path="/remote/20260916/old.tar.gz",
            index_time="2026-09-16T04:15:00Z",
            size=current.size,
            sha256=current.sha256,
        )
        old_directory = self.make_directory(sync.target_dir_for(old).name, {"data.txt": b"reused"}, old)
        sftp = FakeSFTP(archives={current.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, current), "RECONCILED")
        target = sync.target_dir_for(current)
        self.assertFalse(old_directory.exists())
        self.assertEqual(sftp.get_calls, [])
        self.assertEqual((target / "data.txt").read_bytes(), b"reused")
        marker = self.marker(target)
        self.assertEqual(marker["name"], current.name)
        self.assertEqual(marker["archive_name"], current.filename)
        self.assertEqual(marker["remote_path"], current.remote_path)
        self.assertEqual(marker["submission_time"], current.index_time)

    def test_reconcile_uses_valid_candidate_not_stale_target_and_removes_duplicates(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"unused"})
        target = self.make_directory(sync.target_dir_for(current).name, {"data.txt": b"stale target"})
        old = self.submission(
            name="older", stamp="20260917-1729", size=current.size, sha256=current.sha256
        )
        candidate = self.make_directory(sync.target_dir_for(old).name, {"data.txt": b"candidate"}, old)
        sftp = FakeSFTP(archives={current.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, current), "RECONCILED")
        self.assertEqual(sftp.get_calls, [])
        self.assertEqual((sync.target_dir_for(current) / "data.txt").read_bytes(), b"candidate")
        self.assertFalse(candidate.exists())
        self.assertEqual(self.student_directories(current.student_id), [sync.target_dir_for(current)])
        self.assertFalse(target.exists() and target != sync.target_dir_for(current))

    def test_updated_downloads_when_sha_differs_and_removes_old_versions(self) -> None:
        old, _ = self.archive_submission({"data.txt": b"old"}, stamp="20260916-1215")
        self.make_directory(sync.target_dir_for(old).name, {"data.txt": b"old"}, old)
        current, archive = self.archive_submission({"data.txt": b"new"})
        sftp = FakeSFTP(archives={current.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, current), "UPDATED")
        self.assertEqual(len(sftp.get_calls), 1)
        self.assertEqual((sync.target_dir_for(current) / "data.txt").read_bytes(), b"new")
        self.assertEqual(self.student_directories(current.student_id), [sync.target_dir_for(current)])

    def test_untrusted_marker_directories_are_downloaded_then_cleaned(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"fresh"})
        for suffix, marker in (("20260916-1215", None), ("20260917-1729", current)):
            with self.subTest(suffix=suffix):
                self.output_root.mkdir(exist_ok=True)
                for child in list(self.output_root.iterdir()):
                    if child.is_dir():
                        sync.shutil.rmtree(child)
                directory = self.make_directory(
                    f"{current.student_id}-old-{suffix}", {"data.txt": b"untrusted"}, marker,
                    {"student_id": "wrong"} if marker else None,
                )
                sftp = FakeSFTP(archives={current.remote_path: archive})
                self.assertEqual(sync.sync_one(sftp, current), "UPDATED")
                self.assertEqual(len(sftp.get_calls), 1)
                self.assertFalse(directory.exists())
                self.assertEqual(self.student_directories(current.student_id), [sync.target_dir_for(current)])

    def test_multiple_reusable_candidates_use_stable_directory_order(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"unused"})
        alpha = self.submission(name="alpha", stamp="20260916-1215", size=current.size, sha256=current.sha256)
        beta = self.submission(name="beta", stamp="20260917-1729", size=current.size, sha256=current.sha256)
        alpha_dir = self.make_directory(sync.target_dir_for(alpha).name, {"data.txt": b"alpha"}, alpha)
        self.make_directory(sync.target_dir_for(beta).name, {"data.txt": b"beta"}, beta)

        self.assertEqual(sync.sync_one(FakeSFTP(archives={current.remote_path: archive}), current), "RECONCILED")
        self.assertEqual((sync.target_dir_for(current) / "data.txt").read_bytes(), b"alpha")
        self.assertFalse(alpha_dir.exists())
        self.assertEqual(self.student_directories(current.student_id), [sync.target_dir_for(current)])

    def test_target_match_with_extra_old_directory_reconciles_without_download(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"current"})
        target = self.make_directory(
            sync.target_dir_for(current).name, {"data.txt": b"current"}, current
        )
        old = self.make_directory(
            f"{current.student_id}-old-20260916-1215", {"data.txt": b"old"}
        )
        sftp = FakeSFTP(archives={current.remote_path: archive})

        self.assertEqual(sync.sync_one(sftp, current), "RECONCILED")
        self.assertEqual(sftp.get_calls, [])
        self.assertTrue(target.exists())
        self.assertFalse(old.exists())
        self.assertEqual(self.student_directories(current.student_id), [target])

    def test_linked_student_directory_fails_without_changes(self) -> None:
        self.output_root.mkdir()
        link = self.output_root / "2406080104-name-20260916-1215"
        link.mkdir()
        submission, archive = self.archive_submission({"data.txt": b"new"})
        sftp = FakeSFTP(archives={submission.remote_path: archive})
        real_is_symlink = Path.is_symlink

        def report_link(path: Path) -> bool:
            return path == link or real_is_symlink(path)

        # The current Windows session cannot create directory symlinks without an
        # elevated privilege.  Simulate the filesystem classification so the
        # refusal branch is still covered without changing the real output tree.
        with mock.patch.object(Path, "is_symlink", autospec=True, side_effect=report_link):
            with self.assertRaises(sync.SyncError):
                sync.sync_one(sftp, submission)
        self.assertTrue(link.exists())
        self.assertEqual(sftp.get_calls, [])

    def test_download_validation_and_extract_failures_preserve_old_data(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"new"})
        old = self.submission(stamp="20260916-1215", sha256="b" * 64)
        old_directory = self.make_directory(sync.target_dir_for(old).name, {"data.txt": b"old"}, old)
        cases = [
            ("download", FakeSFTP(archives={}), OSError("network"), current),
            ("size", FakeSFTP(archives={current.remote_path: archive[:-1]}), None, current),
            ("sha", FakeSFTP(archives={current.remote_path: archive}), None, self.submission(size=len(archive), sha256="0" * 64)),
            ("tar", FakeSFTP(archives={current.remote_path: b"not a tar"}), None, self.submission(size=9, sha256=hashlib.sha256(b"not a tar").hexdigest())),
        ]
        for label, sftp, download_error, submission in cases:
            with self.subTest(label=label):
                sftp.download_error = download_error
                with self.assertRaises(Exception):
                    sync.sync_one(sftp, submission)
                self.assertTrue(old_directory.exists())
                self.assertEqual((old_directory / "data.txt").read_bytes(), b"old")
                self.assertFalse(sync.target_dir_for(submission).exists())

    def test_transaction_failures_restore_reusable_directory(self) -> None:
        current, archive = self.archive_submission({"data.txt": b"new"})
        old = self.submission(name="old", stamp="20260916-1215", size=current.size, sha256=current.sha256)

        def reset_old() -> tuple[Path, bytes]:
            self.output_root.mkdir(exist_ok=True)
            for child in list(self.output_root.iterdir()):
                if child.is_dir():
                    sync.shutil.rmtree(child)
            directory = self.make_directory(sync.target_dir_for(old).name, {"data.txt": b"old"}, old)
            return directory, (directory / sync.SOURCE_MARKER).read_bytes()

        with self.subTest(failure="marker"):
            directory, original_marker = reset_old()
            with mock.patch.object(sync, "write_source_marker", side_effect=OSError("marker failed")):
                with self.assertRaises(OSError):
                    sync.sync_one(FakeSFTP(archives={current.remote_path: archive}), current)
            self.assertTrue(directory.exists())
            self.assertEqual((directory / sync.SOURCE_MARKER).read_bytes(), original_marker)
            self.assertFalse(sync.target_dir_for(current).exists())

        with self.subTest(failure="target move"):
            directory, original_marker = reset_old()
            real_rename = Path.rename

            def fail_target_move(path: Path, destination: str | Path) -> Path:
                if Path(destination) == sync.target_dir_for(current) and path.name.startswith(".xv6-commit-"):
                    raise OSError("target move failed")
                return real_rename(path, destination)

            with mock.patch.object(Path, "rename", autospec=True, side_effect=fail_target_move):
                with self.assertRaises(OSError):
                    sync.sync_one(FakeSFTP(archives={current.remote_path: archive}), current)
            self.assertTrue(directory.exists())
            self.assertEqual((directory / sync.SOURCE_MARKER).read_bytes(), original_marker)
            self.assertFalse(sync.target_dir_for(current).exists())

        with self.subTest(failure="backup cleanup"):
            directory, original_marker = reset_old()
            real_rmtree = sync.shutil.rmtree
            failed = False

            def fail_backup_cleanup(path: str | Path, *args: object, **kwargs: object) -> None:
                nonlocal failed
                if Path(path).name.startswith(".xv6-old-") and not failed:
                    failed = True
                    raise OSError("backup cleanup failed")
                real_rmtree(path, *args, **kwargs)

            with mock.patch.object(sync.shutil, "rmtree", side_effect=fail_backup_cleanup):
                with self.assertRaises(OSError):
                    sync.sync_one(FakeSFTP(archives={current.remote_path: archive}), current)
            self.assertTrue(directory.exists())
            self.assertEqual((directory / sync.SOURCE_MARKER).read_bytes(), original_marker)
            self.assertFalse(sync.target_dir_for(current).exists())

    def test_missing_remote_students_are_retained_and_warned(self) -> None:
        missing = self.make_directory("2406080999-name-20260916-1215", {"data.txt": b"keep"})
        unrelated = self.make_directory("not-a-student", {"data.txt": b"ignore"})
        current, _ = self.archive_submission({"data.txt": b"current"})
        stderr = io.StringIO()

        with redirect_stderr(stderr):
            sync.warn_about_missing_remote_students({current.student_id: current})
        self.assertTrue(missing.exists())
        self.assertTrue(unrelated.exists())
        self.assertIn("2406080999", stderr.getvalue())
        self.assertNotIn("not-a-student", stderr.getvalue())

    def test_main_counts_reconciled_as_success(self) -> None:
        current, _ = self.archive_submission({"data.txt": b"current"})
        stdout = io.StringIO()
        with mock.patch.object(sync, "connect", return_value=(DummyClient(), FakeSFTP(), "/remote")), \
             mock.patch.object(sync, "read_remote_indexes", return_value=({current.student_id: current}, [])), \
             mock.patch.object(sync, "sync_one", return_value="RECONCILED"), \
             redirect_stdout(stdout):
            self.assertEqual(sync.main(), 0)
        self.assertIn("整理 1", stdout.getvalue())
        self.assertIn("失败 0", stdout.getvalue())


if __name__ == "__main__":
    unittest.main()
