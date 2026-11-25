#!/usr/bin/env python3
"""Unit tests for .claude/hooks/lib/guard_helpers.py."""

import json
import os
import subprocess
import sys
import tempfile
import time
import unittest

LIB_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", ".claude", "hooks", "lib")
)
if LIB_DIR not in sys.path:
    sys.path.insert(0, LIB_DIR)

import guard_helpers as gh  # noqa: E402


class GuardHelpersTest(unittest.TestCase):
    def test_template_stage_guard_blocks_explicit_and_blanket_in_consumer_repo(self):
        with tempfile.TemporaryDirectory(prefix="consumer-repo-") as tmp:
            subprocess.check_call(["git", "init", "-b", "main"], cwd=tmp, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.check_call(["git", "config", "user.email", "t@example.com"], cwd=tmp)
            subprocess.check_call(["git", "config", "user.name", "Test"], cwd=tmp)
            with open(os.path.join(tmp, "AGENTS.md"), "w", encoding="utf-8") as f:
                f.write("local template\n")
            with open(os.path.join(tmp, "app.ts"), "w", encoding="utf-8") as f:
                f.write("export const x = 1;\n")

            blocked, reason = gh.check_template_stage_guard("git add AGENTS.md", tmp)
            self.assertTrue(blocked)
            self.assertIn("AGENTS.md", reason)

            blocked_dot, reason_dot = gh.check_template_stage_guard("git add .", tmp)
            self.assertTrue(blocked_dot)
            self.assertIn("AGENTS.md", reason_dot)

            blocked_app, _ = gh.check_template_stage_guard("git add app.ts", tmp)
            self.assertFalse(blocked_app)

            blocked_override, _ = gh.check_template_stage_guard(
                "ALLOW_TEMPLATE_COMMIT=1 git add AGENTS.md", tmp
            )
            self.assertFalse(blocked_override)

    def test_template_stage_guard_allows_inside_template_master_repo(self):
        master_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        blocked, _ = gh.check_template_stage_guard("git add AGENTS.md CLAUDE.md", master_root)
        self.assertFalse(blocked)

    def test_reconcile_subagent_counts_prevents_cmd_exceeding_session(self):
        cmd_sub, sess_sub = gh.reconcile_subagent_counts(
            cmd_sub_tot=6,
            sub_tot=5,
            cmd_roles={"explorer": 3, "implementer": 2, "debugger": 0, "reviewer": 0},
            session_roles={"explorer": 3, "implementer": 2, "debugger": 0, "reviewer": 0},
        )
        self.assertEqual(cmd_sub, 6)
        self.assertEqual(sess_sub, 6)

    def test_scan_5hr_antigravity_burn_counts_recent_transcripts(self):
        with tempfile.TemporaryDirectory(prefix="ag-brain-") as brain:
            logs_dir = os.path.join(brain, "11111111-2222-3333-4444-555555555555", ".system_generated", "logs")
            os.makedirs(logs_dir, exist_ok=True)
            tf = os.path.join(logs_dir, "transcript.jsonl")
            now_iso = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
            with open(tf, "w", encoding="utf-8") as f:
                f.write(json.dumps({"created_at": now_iso, "type": "PLANNER_RESPONSE", "content": "/dev_bos/reference_sudjab"}) + "\n")
                f.write(json.dumps({"created_at": now_iso, "type": "PLANNER_RESPONSE", "tool_calls": [{"name": "invoke_subagent"}]}) + "\n")
            p, s, projs = gh.scan_5hr_antigravity_burn(time.time() - 3600, brain_root=brain)
            self.assertEqual(p, 2)
            self.assertEqual(s, 1)
            self.assertIn("reference_sudjab", projs)

    def test_mark_stale_objective_if_head_moved_idempotent(self):
        base = "# Active Task Handoff State\n- **Objective:** Finish Slice 3F"
        marked = gh.mark_stale_objective_if_head_moved(base, "bb302e6", "7da69b0")
        self.assertIn("7da69b0", marked)
        # Re-running with same cur_head does not duplicate marker
        marked2 = gh.mark_stale_objective_if_head_moved(marked, "bb302e6", "7da69b0")
        self.assertEqual(marked, marked2)
        # Moving head again replaces previous stale tag cleanly
        marked3 = gh.mark_stale_objective_if_head_moved(marked, "7da69b0", "abc1234")
        self.assertIn("abc1234", marked3)
        self.assertNotIn("7da69b0", marked3)


if __name__ == "__main__":
    unittest.main()
