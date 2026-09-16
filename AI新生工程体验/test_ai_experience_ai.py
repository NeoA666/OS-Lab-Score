import json
import unittest

from ai_experience_ai import build_ai_report


def encoded(value):
    return json.dumps(value, ensure_ascii=False).encode('utf-8')


class AIReportTests(unittest.TestCase):
    def render(self, records, index=None):
        return build_ai_report({'ai/sessions.json': encoded(index or [{'session_id': 's', 'messages': len(records)}]),
                                'ai/s.jsonl': b'\n'.join(encoded(r) for r in records)}, {'student_id': '123', 'name': '某人'})

    def test_roles_blocks_and_tool_link(self):
        report, stats = self.render([
            {'role': 'assistant', 'content': [{'type': 'tool_use', 'id': 'tool-1', 'name': 'read', 'input': {'path': 'x'}}]},
            {'role': 'user', 'content': [{'type': 'tool_result', 'tool_use_id': 'tool-1', 'content': 'returned'}, {'type': 'text', 'text': 'hello'}]},
            {'role': 'assistant', 'content': []},
            {'role': 'assistant', 'content': [{'type': 'thinking', 'thinking': 'abc'}, {'type': 'novel', 'data': 42}]}])
        self.assertEqual(stats['messages'], 4)
        self.assertIn('第 1 行工具调用', report)
        self.assertIn('工具返回（tool_result）', report)
        self.assertIn('用户文本', report)
        self.assertIn('空消息', report)
        self.assertIn('"data": 42', report)
        self.assertLess(report.index('returned'), report.index('hello'))
        self.assertIn('逐条时间：未提供', report)

    def test_corruption_orphans_and_missing_isolation(self):
        report, stats = build_ai_report({'ai/sessions.json': encoded([{'session_id': 'missing'}]),
                                        'ai/orphan.jsonl': b'bad\n' + encoded({'role': 'user', 'content': 'survives'})}, {})
        self.assertEqual(stats['messages'], 1)
        self.assertEqual(stats['sessions'], 2)
        self.assertIn('survives', report)
        self.assertIn('第 2 行', report)
        self.assertTrue(any('缺失' in i for i in stats['issues']))
        self.assertTrue(any('解析失败' in i for i in stats['issues']))

    def test_payload_cannot_break_fence_or_details(self):
        payload = '```\n</details><script>x</script>\n' + ('a' * 1600)
        report, _ = self.render([{'role': 'user', 'content': [{'type': 'tool_result', 'content': payload}]}])
        self.assertIn('````text', report)
        self.assertIn('<summary>展开完整工具返回</summary>', report)
        self.assertIn('script', report)

    def test_aware_timestamps_sort_without_reordering_messages(self):
        files = {'ai/sessions.json': encoded([
            {'session_id': 'later', 'lab_id': 'x', 'created_at': '2026-01-01T10:00:00+08:00'},
            {'session_id': 'earlier', 'lab_id': 'x', 'created_at': '2026-01-01T01:00:00Z'}]),
            'ai/later.jsonl': encoded({'content': 'later text'}),
            'ai/earlier.jsonl': encoded({'content': 'earlier text'})}
        report, _ = build_ai_report(files, {})
        self.assertLess(report.index('会话：earlier'), report.index('会话：later'))

    def test_multiline_tool_result_and_extra_metadata(self):
        report, _ = self.render([{'role': 'user', 'content': [{
            'type': 'tool_result', 'tool_use_id': 't', 'content': '第一行\n第二行',
            'is_error': False, 'unknown_metadata': {'value': 12}}]}])
        self.assertIn('第一行\n第二行', report)
        self.assertNotIn('第一行\\n第二行', report)
        self.assertIn('"unknown_metadata"', report)
        self.assertIn('"is_error": false', report)

    def test_utf8_error_retains_other_lines(self):
        report, stats = build_ai_report({'ai/x.jsonl': b'\xff\n' + encoded({'content': 'ok'})}, {})
        self.assertEqual(stats['messages'], 1)
        self.assertIn('ok', report)
        self.assertIn('\\xff', report)


if __name__ == '__main__':
    unittest.main()
