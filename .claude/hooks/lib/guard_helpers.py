#!/usr/bin/env python3
"""Shared, unit-testable helper functions for Agent Guard Template hooks.

Zero external dependencies (Python 3 stdlib only). Used by:
- .claude/hooks/validate-bash.sh (Template local-state commit guard)
- .claude/hooks/audit-session-proof.sh (Subagent counter reconciliation,
  cross-engine 5hr burn scanner, and TASK_STATE stale-Objective detector)
"""

from __future__ import annotations

import glob
import json
import os
import re
import shlex
import subprocess
from datetime import datetime, timezone
from typing import Dict, Set, Tuple

TEMPLATE_GUARDED_FILES = frozenset(
    {
        "AGENTS.md",
        "CLAUDE.md",
        "GEMINI.md",
        "TASK_STATE.md",
        ".claude/.telemetry.json",
        ".claude/.read_buf.cnt",
    }
)


def is_template_master_repo(repo_root: str) -> bool:
    """Return True when repo_root is the agent-guard-template repo itself."""
    if os.path.isfile(os.path.join(repo_root, "tests", "test-hooks.sh")):
        return True
    if os.path.basename(os.path.abspath(repo_root)) == "agent-guard-template":
        return True
    return False


def _normalize_git_path(tok: str) -> str:
    clean = tok.strip().strip('"').strip("'").lstrip("./")
    return clean


def check_template_stage_guard(
    cmd: str, project_root: str
) -> Tuple[bool, str]:
    """Block staging/committing local Agent Guard template files in consumer repos.

    Returns (blocked: bool, reason: str).
    Automatically allows inside agent-guard-template itself, or when
    ALLOW_TEMPLATE_COMMIT=1 is set in env or command string.
    """
    if os.environ.get("ALLOW_TEMPLATE_COMMIT") == "1" or "ALLOW_TEMPLATE_COMMIT=1" in cmd:
        return False, ""

    for seg in re.split(r"[;&|]+", cmd):
        seg = seg.strip()
        if not seg:
            continue
        try:
            toks = shlex.split(seg)
        except Exception:
            toks = seg.split()
        i = 0
        while i < len(toks):
            if toks[i] == "git":
                repo = project_root
                j = i + 1
                while j < len(toks) and toks[j].startswith("-"):
                    if toks[j] == "-C" and j + 1 < len(toks):
                        cand = toks[j + 1]
                        repo = cand if os.path.isabs(cand) else os.path.abspath(os.path.join(project_root, cand))
                        j += 2
                    elif toks[j].startswith("-C") and len(toks[j]) > 2:
                        cand = toks[j][2:]
                        repo = cand if os.path.isabs(cand) else os.path.abspath(os.path.join(project_root, cand))
                        j += 1
                    else:
                        j += 1

                if j < len(toks) and toks[j] in ("add", "stage"):
                    if is_template_master_repo(repo):
                        i = j + 1
                        continue
                    args = toks[j + 1 :]
                    flags = [t for t in args if t.startswith("-")]
                    paths = [t for t in args if not t.startswith("-")]

                    # 1. Explicit staging of template-managed files
                    matched_explicit = []
                    for p in paths:
                        norm = _normalize_git_path(p)
                        if norm in TEMPLATE_GUARDED_FILES or os.path.basename(norm) in (
                            "AGENTS.md",
                            "CLAUDE.md",
                            "GEMINI.md",
                            "TASK_STATE.md",
                        ):
                            matched_explicit.append(norm)
                    if matched_explicit:
                        return (
                            True,
                            f"ห้าม stage ไฟล์เทมเพลต/สถานะเฉพาะเครื่อง ({', '.join(matched_explicit)}) เข้าสู่ repo โปรเจกต์ — หากตั้งใจ commit จริงให้ใส่ ALLOW_TEMPLATE_COMMIT=1 นำหน้าคำสั่ง",
                        )

                    # 2. Blanket `git add .` / `git add -A` / `git add --all` when guarded files are dirty
                    is_blanket = any(f in ("-A", "--all", "-a") for f in flags) or any(
                        p in (".", "./", "*") for p in paths
                    )
                    if is_blanket:
                        try:
                            st_out = subprocess.check_output(
                                ["git", "--no-optional-locks", "-C", repo, "status", "--porcelain"],
                                stderr=subprocess.DEVNULL,
                                timeout=2.0,
                            ).decode("utf-8", errors="ignore")
                            dirty_guarded = []
                            for ln in st_out.splitlines():
                                if len(ln) >= 4:
                                    rel = _normalize_git_path(ln[3:].split(" -> ")[-1])
                                    if rel in TEMPLATE_GUARDED_FILES or os.path.basename(rel) in (
                                        "AGENTS.md",
                                        "CLAUDE.md",
                                        "GEMINI.md",
                                        "TASK_STATE.md",
                                    ):
                                        dirty_guarded.append(rel)
                            if dirty_guarded:
                                return (
                                    True,
                                    f"ระงับ git add แบบเหมาหมด (พบไฟล์เทมเพลตค้างแก้: {', '.join(dirty_guarded[:4])}) — กรุณา stage เฉพาะไฟล์งานจริงทีละไฟล์ หรือใส่ ALLOW_TEMPLATE_COMMIT=1",
                                )
                        except Exception:
                            pass
                i = j
            i += 1
    return False, ""


def reconcile_subagent_counts(
    cmd_sub_tot: int,
    sub_tot: int,
    cmd_roles: Dict[str, int],
    session_roles: Dict[str, int],
) -> Tuple[int, int]:
    """Ensure per-command and cumulative subagent counts remain mathematically consistent.

    Fixes the bug where per-command invocation count exceeded cumulative unique
    subagent count (e.g. `6` in command vs `5` in session).
    """
    cmd_role_sum = sum(max(0, int(v or 0)) for v in (cmd_roles or {}).values())
    sess_role_sum = sum(max(0, int(v or 0)) for v in (session_roles or {}).values())
    fixed_cmd = max(0, int(cmd_sub_tot or 0), cmd_role_sum)
    fixed_tot = max(0, int(sub_tot or 0), sess_role_sum, fixed_cmd)
    return fixed_cmd, fixed_tot


def scan_5hr_antigravity_burn(
    cutoff_epoch: float,
    brain_root: str = "",
) -> Tuple[int, int, Set[str]]:
    """Scan Antigravity brain transcripts modified within the last 5 hours.

    Returns (parent_turns, subagent_invocations, project_labels).
    """
    root = brain_root or os.path.expanduser("~/.gemini/antigravity/brain")
    parent_turns = 0
    sub_turns = 0
    projs: Set[str] = set()
    if not os.path.isdir(root):
        return 0, 0, projs

    cutoff_iso = datetime.fromtimestamp(cutoff_epoch, timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%S"
    )
    for tf in glob.glob(os.path.join(root, "*", ".system_generated", "logs", "transcript.jsonl")):
        try:
            if os.path.getmtime(tf) < cutoff_epoch:
                continue
        except OSError:
            continue

        file_parent = 0
        file_sub = 0
        detected_proj = ""
        try:
            with open(tf, "r", encoding="utf-8", errors="ignore") as fp:
                for ln in fp:
                    m_ts = re.search(
                        r'"created_at"\s*:\s*"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', ln
                    )
                    if m_ts and m_ts.group(1) < cutoff_iso:
                        continue
                    if '"type":"PLANNER_RESPONSE"' in ln.replace(" ", ""):
                        file_parent += 1
                    if "invoke_subagent" in ln:
                        file_sub += 1
                    if not detected_proj:
                        m_ws = re.search(r"/dev_bos/([A-Za-z0-9_.-]+)", ln)
                        if m_ws:
                            detected_proj = m_ws.group(1)
        except Exception:
            continue

        if file_parent > 0 or file_sub > 0:
            parent_turns += file_parent
            sub_turns += file_sub
            projs.add(detected_proj or "antigravity")

    return parent_turns, sub_turns, projs


def mark_stale_objective_if_head_moved(
    base_content: str, prev_head: str, cur_head: str
) -> str:
    """Flag top Objective line in TASK_STATE.md when git HEAD advances past previous sync."""
    if not base_content or not prev_head or not cur_head or prev_head == cur_head:
        return base_content
    if cur_head in base_content:
        return base_content

    stale_re = re.compile(r"\s*\*?\(⚠️ HEAD เปลี่ยนเป็น [0-9a-f]+[^)]*\)\*?")
    lines = base_content.splitlines()
    updated = False
    for idx, ln in enumerate(lines):
        if "**Objective:**" in ln:
            cleaned = stale_re.sub("", ln).rstrip()
            lines[idx] = f"{cleaned} *(⚠️ HEAD เปลี่ยนเป็น {cur_head} — อัปเดต Objective เมื่อเริ่มงานใหม่)*"
            updated = True
            break
    return "\n".join(lines) if updated else base_content


if __name__ == "__main__":
    import sys

    if len(sys.argv) >= 4 and sys.argv[1] == "check-template-stage":
        blocked, reason = check_template_stage_guard(sys.argv[2], sys.argv[3])
        print(json.dumps({"blocked": blocked, "reason": reason}, ensure_ascii=False))
