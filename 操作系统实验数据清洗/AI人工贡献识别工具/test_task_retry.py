from __future__ import annotations

import io
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from contribution_recognition import cli
from contribution_recognition.analysis import TransientProtocolError
from contribution_recognition.protocol import NimConfig, NimConfigurationError, NimResponse
from contribution_recognition.repository import (
    COMMAND_STATISTICS_DIRECTORY,
    ContributionRepository,
    SIMPLE_TIMELINE_DIRECTORY,
    TERMINAL_QA_DIRECTORY,
)
from contribution_recognition.storage import ContributionStorage

from test_semantic_protocol import _assessment_payload, _review_payload


# --- fixtures ---------------------------------------------------------------


def _read_timeline() -> dict:
    return {
        "action": "read_material",
        "requests": [
            {"source_id": "source:lab0:timeline", "start_line": 1, "end_line": 4}
        ],
    }


def _submit_assessment(payload: dict | None = None) -> dict:
    return {"action": "submit_assessment", "assessment": payload or _assessment_payload()}


def _submit_review(payload: dict | None = None) -> dict:
    return {"action": "submit_review", "review": payload or _review_payload()}


class _ScriptedClient:
    def __init__(self, script: list) -> None:
        self.script = list(script)
        self.calls: list[list[dict]] = []

    def complete(self, messages):
        self.calls.append([dict(message) for message in messages])
        if not self.script:
            raise AssertionError("unexpected NIM completion")
        item = self.script.pop(0)
        if isinstance(item, BaseException):
            raise item
        content = item if isinstance(item, str) else json.dumps(item, ensure_ascii=False)
        return NimResponse(
            content=content,
            model="test-nim",
            usage=None,
            request_id=f"request-{len(self.calls)}",
            attempts=1,
            elapsed_seconds=0.0,
        )


class _ClientFactory:
    """Stand-in for NimStreamingClient; one fresh scripted client per task attempt."""

    def __init__(self, scripts: list) -> None:
        self.scripts = list(scripts)
        self.clients: list[_ScriptedClient] = []

    def __call__(self, config):
        if not self.scripts:
            raise AssertionError("unexpected NimStreamingClient construction")
        client = _ScriptedClient(self.scripts.pop(0))
        self.clients.append(client)
        return client


class _TaskTestCase(unittest.TestCase):
    student = "student-a"

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.repository = ContributionRepository(self.root)
        self.storage = ContributionStorage(self.root)

    def tearDown(self) -> None:
        self.temp.cleanup()

    @staticmethod
    def _write(path: Path, body: str) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")

    def _write_lab0(self, *, with_timeline: bool = True) -> None:
        student = self.root / self.student
        if with_timeline:
            self._write(
                student / SIMPLE_TIMELINE_DIRECTORY / "timeline_lab0.md",
                "line one\nline two\nline three\nline four\n",
            )
        self._write(
            student / TERMINAL_QA_DIRECTORY / "terminal_qa_report_lab0.md",
            "Q\nA\n",
        )
        self._write(
            student / COMMAND_STATISTICS_DIRECTORY / "command_statistics_lab0.md",
            "cmd\n1\n",
        )

    def _run(self, scripts, *, retry_failed: bool = False, force: bool = False,
             lab: str = "lab0"):
        factory = _ClientFactory(scripts)
        with patch.object(cli, "NimStreamingClient", factory), patch.object(
            NimConfig, "from_environment", return_value=NimConfig(api_key="test-key")
        ):
            result = cli._execute_task(
                repository=self.repository,
                storage=self.storage,
                student_reference=self.student,
                lab=lab,
                force=force,
                dry_run=False,
                retry_failed=retry_failed,
            )
        return result, factory

    def _assessment(self, lab: str = "lab0") -> dict:
        return json.loads(
            self.storage.assessment_path(self.student, lab).read_text(encoding="utf-8")
        )

    def _run_logs(self) -> list[dict]:
        records = []
        for path in self.root.rglob("*.jsonl"):
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.strip():
                    records.append(json.loads(line))
        return records


# --- T02 --------------------------------------------------------------------


class LocalRepairWithinOneTaskTests(_TaskTestCase):
    def test_local_repair_needs_only_one_task_attempt(self) -> None:
        self._write_lab0()
        script = [
            _read_timeline(),
            {"action": "submit_review", "review": _review_payload()},
            _submit_assessment(),
            _read_timeline(),
            _submit_review(),
        ]
        result, factory = self._run([script])
        self.assertEqual(result["status"], "complete")
        self.assertEqual(len(factory.clients), 1)
        self.assertEqual(len(factory.clients[0].calls), 5)
        assessment = self._assessment()
        self.assertEqual(assessment["analysis_status"], "complete")
        self.assertEqual(assessment["review"]["status"], "agreed")
        repair_call = json.dumps(factory.clients[0].calls[2], ensure_ascii=False)
        self.assertIn("protocol_repair", repair_call)


# --- T03 --------------------------------------------------------------------


class TaskLevelRerunTests(_TaskTestCase):
    def test_envelope_failure_after_local_repair_triggers_fresh_rerun(self) -> None:
        self._write_lab0()
        failing = [_read_timeline(), {"action": "submit_review"}, {"action": "submit_review"}]
        succeeding = [_read_timeline(), _submit_assessment(), _read_timeline(), _submit_review()]
        result, factory = self._run([failing, succeeding])
        self.assertEqual(result["status"], "complete")
        self.assertEqual(len(factory.clients), 2)
        self.assertIsNot(factory.clients[0], factory.clients[1])
        first_attempt = json.dumps(factory.clients[0].calls, ensure_ascii=False)
        self.assertIn("protocol_repair", first_attempt)
        second_attempt = json.dumps(factory.clients[1].calls, ensure_ascii=False)
        self.assertNotIn("protocol_repair", second_attempt)
        self.assertEqual(self._assessment()["analysis_status"], "complete")
        self.assertTrue(
            (self.storage.full_report_path(self.student, "lab0")).is_file()
        )
        self.assertTrue(
            (self.storage.teacher_report_path(self.student, "lab0")).is_file()
        )


# --- T04 --------------------------------------------------------------------


class RetryExhaustionTests(_TaskTestCase):
    def test_two_envelope_failures_end_as_retryable_failed(self) -> None:
        self._write_lab0()
        failing = [{"action": "submit_review"}, {"action": "submit_review"}]
        result, factory = self._run([list(failing), list(failing)])
        self.assertEqual(result["status"], "failed")
        self.assertEqual(len(factory.clients), 2)
        assessment = self._assessment()
        self.assertEqual(assessment["analysis_status"], "failed")
        self.assertEqual(assessment["errors"][0]["code"], "TransientProtocolError")
        self.assertTrue(assessment["errors"][0]["retryable"])
        self.assertNotEqual(assessment["analysis_status"], "complete")

        logs = self._run_logs()
        attempt_events = [r for r in logs if r.get("event") == "analysis_attempt_failed"]
        final_events = [r for r in logs if r.get("event") == "analysis_failed"]
        self.assertEqual(len(attempt_events), 1)
        self.assertEqual(attempt_events[0]["task_attempt"], 1)
        self.assertEqual(attempt_events[0]["max_task_attempts"], 2)
        self.assertEqual(attempt_events[0]["stage"], "semantic_analysis_or_review")
        self.assertTrue(attempt_events[0]["retryable"])
        self.assertEqual(len(final_events), 1)
        self.assertEqual(final_events[0]["task_attempt"], 2)
        self.assertEqual(final_events[0]["max_task_attempts"], 2)


# --- T05 --------------------------------------------------------------------


class DeterministicErrorsAreNotRetriedTests(_TaskTestCase):
    def test_content_validation_error_stops_after_one_attempt(self) -> None:
        self._write_lab0()
        payload = _assessment_payload()
        payload["contribution_units"][0]["evidence_refs"][0]["end_line"] = 99
        # The validator-level submission repair also receives the bad payload, so
        # the deterministic content error survives both allowed local repairs.
        result, factory = self._run(
            [[_read_timeline(), _submit_assessment(payload), _submit_assessment(payload)]]
        )
        self.assertEqual(result["status"], "failed")
        self.assertEqual(len(factory.clients), 1)
        self.assertEqual(len(factory.clients[0].calls), 3)
        self.assertFalse(self._assessment()["errors"][0]["retryable"])

    def test_insufficient_material_never_calls_the_model(self) -> None:
        self._write_lab0(with_timeline=False)
        result, factory = self._run([])
        self.assertEqual(result["status"], "insufficient_data")
        self.assertEqual(len(factory.clients), 0)
        assessment = self._assessment()
        self.assertEqual(assessment["analysis_status"], "insufficient_data")
        self.assertEqual(assessment.get("errors"), [])

    def test_configuration_error_stops_after_one_attempt(self) -> None:
        self._write_lab0()
        factory = _ClientFactory([])
        with patch.object(cli, "NimStreamingClient", factory), patch.object(
            NimConfig,
            "from_environment",
            side_effect=NimConfigurationError("未配置模型服务凭据"),
        ):
            result = cli._execute_task(
                repository=self.repository,
                storage=self.storage,
                student_reference=self.student,
                lab="lab0",
                force=False,
                dry_run=False,
                retry_failed=False,
            )
        self.assertEqual(result["status"], "failed")
        self.assertEqual(len(factory.clients), 0)
        assessment = self._assessment()
        self.assertEqual(assessment["analysis_status"], "failed")
        self.assertFalse(assessment["errors"][0]["retryable"])


# --- T07 --------------------------------------------------------------------


class BatchConservativePolicyTests(_TaskTestCase):
    def _seed_failure(self) -> None:
        self._write_lab0()
        failing = [{"action": "submit_review"}, {"action": "submit_review"}]
        result, _ = self._run([list(failing), list(failing)])
        self.assertEqual(result["status"], "failed")

    def _batch(self, *, retry_failed: bool = False, force: bool = False, scripts=()):
        factory = _ClientFactory(list(scripts))
        args = SimpleNamespace(
            jobs=1,
            cleaned_root=Path(self.root),
            student=None,
            lab="lab0",
            force=force,
            dry_run=False,
            retry_failed=retry_failed,
            resume=False,
        )
        buffer = io.StringIO()
        with patch.object(cli, "NimStreamingClient", factory), patch.object(
            NimConfig, "from_environment", return_value=NimConfig(api_key="test-key")
        ), redirect_stdout(buffer):
            code = cli._batch(args)
        return code, json.loads(buffer.getvalue()), factory

    def test_plain_batch_skips_existing_failure_without_model_call(self) -> None:
        self._seed_failure()
        code, summary, factory = self._batch()
        self.assertEqual([r["status"] for r in summary["results"]], ["skipped_failed"])
        self.assertEqual(len(factory.clients), 0)

    def test_retry_failed_reexecutes(self) -> None:
        self._seed_failure()
        succeeding = [_read_timeline(), _submit_assessment(), _read_timeline(), _submit_review()]
        code, summary, factory = self._batch(retry_failed=True, scripts=[succeeding])
        self.assertEqual(summary["results"][0]["status"], "complete")
        self.assertEqual(len(factory.clients), 1)

    def test_force_reexecutes(self) -> None:
        self._seed_failure()
        succeeding = [_read_timeline(), _submit_assessment(), _read_timeline(), _submit_review()]
        code, summary, factory = self._batch(force=True, scripts=[succeeding])
        self.assertEqual(summary["results"][0]["status"], "complete")
        self.assertEqual(len(factory.clients), 1)


# --- T08 --------------------------------------------------------------------


class CacheAndAtomicityTests(_TaskTestCase):
    def test_success_is_reused_without_a_model_call(self) -> None:
        self._write_lab0()
        succeeding = [_read_timeline(), _submit_assessment(), _read_timeline(), _submit_review()]
        first, factory = self._run([succeeding])
        self.assertEqual(first["status"], "complete")
        self.assertEqual(len(factory.clients), 1)
        second, factory2 = self._run([])
        self.assertIn(second["status"], {"cached", "rerendered"})
        self.assertEqual(len(factory2.clients), 0)

    def test_failure_never_leaves_a_complete_assessment(self) -> None:
        self._write_lab0()
        failing = [{"action": "submit_review"}, {"action": "submit_review"}]
        result, _ = self._run([list(failing), list(failing)])
        self.assertEqual(result["status"], "failed")
        assessment = self._assessment()
        self.assertEqual(assessment["analysis_status"], "failed")
        entry = self.storage.cache_entry(self.student, "lab0")
        self.assertEqual(entry["analysis_status"], "failed")
        self.assertFalse(
            self.storage.cache_hit(self.student, "lab0", entry["assessment_fingerprint"])
        )
        # The failed assessment and both reports were committed together.
        self.assertTrue(self.storage.reports_are_current(
            self.student, "lab0", entry["render_fingerprint"]
        ))


# --- T09 --------------------------------------------------------------------


class RedactionRegressionTests(_TaskTestCase):
    TOKEN = "nvapi-abcdefgh12345678"

    def _student_blob(self) -> str:
        parts = []
        for path in (self.root / self.student).rglob("*"):
            if path.is_file():
                parts.append(path.read_text(encoding="utf-8", errors="replace"))
        return "\n".join(parts)

    def test_token_and_thinking_fields_never_persist(self) -> None:
        self._write_lab0()
        payload = _assessment_payload()
        payload["contribution_units"][0]["summary"] = f"api_key={self.TOKEN} leaked"
        payload["lab_conclusion"]["summary"] = f"token {self.TOKEN} appears"
        payload["reasoning_content"] = "chain-of-thought secret"
        script = [
            _read_timeline(),
            {"action": "submit_assessment", "assessment": payload,
             "reasoning_content": "secret reasoning"},
            _read_timeline(),
            {"action": "submit_review", "review": _review_payload(),
             "reasoning_content": "secret reasoning"},
        ]
        result, _ = self._run([script])
        self.assertEqual(result["status"], "complete")
        blob = self._student_blob()
        self.assertNotIn(self.TOKEN, blob)
        self.assertIn("[REDACTED]", blob)
        self.assertNotIn("reasoning_content", blob)
        self.assertNotIn("chain-of-thought secret", blob)

    def test_error_message_is_redacted(self) -> None:
        self._write_lab0()
        boom = TransientProtocolError(f"模型泄漏 api_key={self.TOKEN}")
        result, factory = self._run([[boom], [boom]])
        self.assertEqual(result["status"], "failed")
        self.assertEqual(len(factory.clients), 2)
        assessment = self._assessment()
        blob = json.dumps(assessment, ensure_ascii=False)
        self.assertNotIn(self.TOKEN, blob)
        self.assertIn("[REDACTED]", assessment["errors"][0]["message"])


if __name__ == "__main__":
    unittest.main()
