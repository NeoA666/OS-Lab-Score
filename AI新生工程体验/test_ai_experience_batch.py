import io
import json
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import ai_experience_batch as app


def make_archive(path, entries):
    with tarfile.open(path, "w:gz") as tar:
        for name, data in entries:
            info = tarfile.TarInfo(name)
            if data is None:
                info.type = tarfile.SYMTYPE
                info.linkname = "elsewhere"
                tar.addfile(info)
            else:
                info.size = len(data)
                tar.addfile(info, io.BytesIO(data))


class BatchTests(unittest.TestCase):
    def test_path_rejections(self):
        for name in ("../x", "C:/x", "/x", "a\\b", "a/../b", "a:stream", "CON.py", "x. "):
            with self.subTest(name=name), self.assertRaises(ValueError):
                app.safe_name(name)

    def test_archive_duplicate_link_and_parent_file(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / "a.tar.gz"
            for entries in ([('A.py', b'a'), ('a.py', b'b')], [('a', None)], [('a', b'a'), ('a/b', b'b')]):
                make_archive(p, entries)
                with self.assertRaises(ValueError):
                    app.read_archive(p)

    def test_partial_validation_and_identity(self):
        manifest = dict(owner_username='123', added_files=['lab/a.py'], added_count=1,
                        changed_files=[], changed_count=0, deleted_files=[], deleted_count=0,
                        cast_files=[], ai_sessions=0, ai_messages=0)
        files = {'manifest.json': json.dumps(manifest).encode(), 'ai/sessions.json': b'[]'}
        _, checks, blocked = app.validate(files, '123')
        self.assertFalse(blocked)
        self.assertEqual(app.status_of(checks), '失败')
        self.assertTrue(app.validate(files, '456')[2])

    def test_sample_preservation_and_no_execution(self):
        archive = app.DEFAULT_INPUT / '2506080204-杜金熙.tar.gz'
        if not archive.exists():
            self.skipTest('sample missing')
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp)
            # Any accidental process launch by the pipeline fails this test.
            with patch('subprocess.Popen', side_effect=AssertionError('student execution forbidden')):
                result = app.process_student(archive, out)
            self.assertEqual(result['py_files'], 1)
            files, _ = app.read_archive(archive)
            dest = out / archive.name[:-7]
            for name, original in files.items():
                self.assertEqual((dest / '原始提交' / name).read_bytes(), original)
            self.assertEqual(app.process_student(archive, out)['action'], '跳过已有输出')
            code = dest / '原始提交/workspace/1-实验一-AI协作解题/1.py'
            code.write_bytes(b'manual edit')
            with self.assertRaises(ValueError):
                app.process_student(archive, out, regenerate=True)

    def test_batch_continues_after_invalid_archive(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            src = root / 'input'
            src.mkdir()
            (src / '100-坏包.tar.gz').write_bytes(b'bad')
            make_archive(src / '200-另一位.tar.gz', [('ai/sessions.json', b'[]')])
            with patch('subprocess.Popen', side_effect=AssertionError('student execution forbidden')):
                self.assertEqual(app.main([str(src), '-o', str(root / 'output')]), 1)
            self.assertTrue((root / 'output/200-另一位/AI对话记录.md').is_file())
            self.assertIn('100-坏包', (root / 'output/批处理汇总.md').read_text(encoding='utf-8'))

    def test_invalid_historical_marker_does_not_abort_summary(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'input').mkdir()
            for sid, value in [('100-A', []), ('200-B', {'owner': app.OWNER, 'summary': []})]:
                dest = root / 'output' / sid
                dest.mkdir(parents=True)
                (dest / '处理记录.json').write_text(json.dumps(value), encoding='utf-8')
            self.assertEqual(app.main([str(root / 'input'), '-o', str(root / 'output')]), 0)
            self.assertIn('历史记录无效', (root / 'output/批处理汇总.md').read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
