"""Validate real timeline output against legacy evidence, without changing reports."""
import gzip
import json
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / '学生操作系统实验数据爬取/操作系统实验数据记录'
OLD = ROOT / '操作系统实验数据记录-已清洗'

def main(output):
    docs = [json.loads(p.read_text(encoding='utf-8')) for p in sorted(output.glob('*/实验过程时间线/timeline_*.json'))]
    events = [e for doc in docs for e in doc['events']]
    ids = {e['event_id'] for e in events}
    assert len(ids) == len(events), 'Duplicate event ID'
    by_id = {e['event_id']: e for e in events}
    source_cache = {}
    recording_details = {detail['out']: detail for doc in docs for detail in doc['recording_details']}
    assert len(recording_details) == 134, len(recording_details)
    assert not [d for d in recording_details.values() if d['status'] != 'ok']
    by_recording = defaultdict(list)
    for e in events:
        assert e['type'] in ('shell_command_observed', 'claude_user_observed', 'claude_reply_observed')
        out = Path(e['source']['out'])
        assert out.is_file() and RAW.resolve() in out.resolve().parents
        assert Path(e['source']['tim']).is_file()
        assert e['recording_id'] == out.name.removesuffix('.out.gz')
        assert e.get('related_event_id') is None or e['related_event_id'] in ids
        if e.get('related_event_id'):
            related = by_id[e['related_event_id']]
            assert related['student'] == e['student']
            assert related['recording_id'] == e['recording_id']
        if e['type'] == 'claude_reply_observed':
            assert by_id[e['related_event_id']]['type'] == 'claude_user_observed'
            assert by_id[e['related_event_id']]['elapsed_seconds'] <= e['elapsed_seconds']
        if e['observed_at'] is not None:
            assert datetime.fromisoformat(e['observed_at']).utcoffset() is not None
            assert e['elapsed_seconds'] is not None
        by_recording[out.relative_to(RAW).as_posix()].append(e)
        if str(out) not in source_cache:
            raw = gzip.open(out, 'rb').read()
            cumulative = 0.0
            timings = {}
            for line_number, line in enumerate(gzip.open(e['source']['tim'], 'rt'), 1):
                delay, size = line.split()
                cumulative += float(delay)
                timings[line_number] = cumulative
            source_cache[str(out)] = (len(raw), timings)
        size, timings = source_cache[str(out)]
        for key in ('observation', 'final_text_observation'):
            observation = e['source'].get(key)
            if observation:
                begin, end = observation['decompressed_byte_range']
                assert 0 <= begin <= end <= size, (e['event_id'], observation)
                if observation.get('timing_line') is not None:
                    assert abs(observation['elapsed_seconds'] - timings[observation['timing_line']]) < 0.000001

    legacy = json.loads((ROOT / '.verification/timeline_legacy_commands.json').read_text(encoding='utf-8'))
    deltas = []
    for path, old in legacy.items():
        expected = Counter((c['command'], c['cwd']) for c in old['commands'])
        actual = Counter((e['content'], e['cwd']) for e in by_recording[path] if e['type'] == 'shell_command_observed')
        if actual != expected:
            deltas.append({'recording': path, 'legacy_error': old.get('error'),
                           'added': list((actual - expected).elements()),
                           'removed': list((expected - actual).elements())})

    old_qa = []
    for path in OLD.glob('*/claude对话/claude_qa_clean_*.md'):
        text = path.read_text(encoding='utf-8')
        student = re.search(r'^- 学号：(.+)$', text, re.M).group(1)
        lab = re.search(r'^- 实验分类：(.+)$', text, re.M).group(1)
        if lab.startswith('其他'):
            lab = 'other'
        for match in re.finditer(r'^## Session \d+：([^\n]+)\n(.*?)(?=^## Session \d+：|\Z)', text, re.M | re.S):
            rec, body = match.groups()
            for turn in re.finditer(r'^### Turn \d+\n\n#### User\n\n(.*?)\n\n#### Claude\n\n(.*?)(?=^### Turn \d+\n|\Z)', body, re.M | re.S):
                user, answer = turn.groups()
                old_qa.extend([(student, lab, rec, 'claude_user_observed', user.strip()),
                               (student, lab, rec, 'claude_reply_observed', answer.strip())])
    actual_qa = [(e['student']['student_id'], e['lab'], e['recording_id'], e['type'], e['content'].strip())
                 for e in events if e['type'].startswith('claude_')]
    missing_qa = Counter(old_qa) - Counter(actual_qa)
    assert len(old_qa) == 70, len(old_qa)
    assert not missing_qa, [(k[:4], len(k[4]), n) for k, n in missing_qa.items()]
    assert all(e['elapsed_seconds'] is not None for e in events if e['type'].startswith('claude_'))
    example = [e for e in events if e['recording_id'] == '20260910T222112-4100' and e['type'].startswith('claude_')]
    question = min((e for e in example if e['type'] == 'claude_user_observed'), key=lambda e: e['elapsed_seconds'])
    answer = min((e for e in example if e['type'] == 'claude_reply_observed'), key=lambda e: e['elapsed_seconds'])
    assert abs(question['elapsed_seconds'] - 125.961003) < 0.00001, question['elapsed_seconds']
    assert abs(answer['elapsed_seconds'] - 130.863928) < 0.00001, answer['elapsed_seconds']
    assert abs(answer['final_text_first_elapsed_seconds'] - 133.260372) < 0.00001
    yang = sorted((e for e in events if e['recording_id'] == '20260911T084036-3582' and e['type'].startswith('claude_')), key=lambda e: e['elapsed_seconds'])
    first_reply = next(e for e in yang if e['type'] == 'claude_reply_observed')
    second_question = [e for e in yang if e['type'] == 'claude_user_observed'][1]
    assert abs(first_reply['final_text_first_elapsed_seconds'] - 834.132589) < 0.00001
    assert abs(second_question['elapsed_seconds'] - 825.384924) < 0.00001
    assert first_reply['final_text_first_elapsed_seconds'] > second_question['elapsed_seconds']
    counts = Counter(e['type'] for e in events)
    status = Counter('absolute' if e['observed_at'] else 'relative_only' if e['elapsed_seconds'] is not None else 'unlocated' for e in events)
    summary = {'files_json': len(docs), 'students': len({d['student']['student_id'] for d in docs}),
               'recordings': len(recording_details),
               'events': len(events), 'types': dict(counts), 'time_status': dict(status),
               'legacy_qa_messages_preserved': len(old_qa), 'shell_deltas': deltas,
               'example_offsets': [question['elapsed_seconds'], answer['elapsed_seconds']],
               'uncertainty': dict(Counter(reason for e in events for reason in e.get('uncertainty', [])))}
    destination = ROOT / '.verification/timeline_acceptance.json'
    destination.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(summary, ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main(Path(sys.argv[1]).resolve())
