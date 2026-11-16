#!/usr/bin/env bash
# 0-Token Auto-Changelog, PR Description & QA Release Summary Generator
# สร้างโพยสรุปการเปลี่ยนแปลง (Changelog / PR / รายงานส่งผู้ทดสอบ) จาก TASK_STATE.md และ git log ทันทีโดยไม่เสียโควต้า AI
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIMIT_COMMITS="${1:-15}"
PROJECT_ROOT="$(git --no-optional-locks -C "$SCRIPT_ROOT" rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_ROOT")"

python3 - "$PROJECT_ROOT" "$LIMIT_COMMITS" <<'PYEOF'
import sys, os, re, subprocess
from datetime import datetime

root = os.path.realpath(sys.argv[1])
try:
    limit = int(sys.argv[2])
except Exception:
    limit = 15

proj_name = os.path.basename(root)
branch = "main"
head_sha = ""
try:
    branch = subprocess.check_output(["git", "--no-optional-locks", "rev-parse", "--abbrev-ref", "HEAD"], cwd=root, stderr=subprocess.DEVNULL, timeout=1.5).decode("utf-8", errors="ignore").strip()
    head_sha = subprocess.check_output(["git", "--no-optional-locks", "rev-parse", "--short", "HEAD"], cwd=root, stderr=subprocess.DEVNULL, timeout=1.5).decode("utf-8", errors="ignore").strip()
except Exception:
    pass

commits = []
try:
    raw_log = subprocess.check_output(["git", "--no-optional-locks", "log", f"-n{limit}", "--pretty=format:%h|%ad|%s", "--date=short"], cwd=root, stderr=subprocess.DEVNULL, timeout=2.0).decode("utf-8", errors="ignore").splitlines()
    for ln in raw_log:
        parts = ln.split("|", 2)
        if len(parts) == 3:
            commits.append((parts[0], parts[1], parts[2]))
except Exception:
    pass

ts_path = os.path.join(root, "TASK_STATE.md")
phase_line = ""
completed_lines = []
verified_lines = []
next_lines = []
if os.path.isfile(ts_path):
    try:
        mode = ""
        for raw_ln in open(ts_path, encoding="utf-8", errors="ignore"):
            ln = raw_ln.rstrip()
            if ln.startswith("## 🔄 Auto-Synced"):
                break
            if "**Current Phase:**" in ln:
                phase_line = ln.split("**Current Phase:**", 1)[1].strip()
                mode = ""
            elif "**Recent Completed Work" in ln:
                mode = "completed"
            elif "**Verified" in ln:
                verified_lines.append(ln.lstrip("- ").strip())
                mode = ""
            elif "**Next Immediate Step" in ln:
                mode = "next"
            elif ln.startswith("- **"):
                mode = ""
            elif mode == "completed" and ln.strip().startswith("- "):
                completed_lines.append(ln.strip())
            elif mode == "next" and re.match(r"^\s*(\d+\.|-)\s+", ln):
                next_lines.append(ln.strip())
    except Exception:
        pass

feats, fixes, others = [], [], []
for sha, dt, subj in commits:
    low = subj.lower()
    entry = f"- `{sha}` ({dt}): {subj}"
    if low.startswith("feat"):
        feats.append(entry)
    elif low.startswith("fix"):
        fixes.append(entry)
    else:
        others.append(entry)

now_s = datetime.now().strftime("%Y-%m-%d %H:%M")
print(f"# 📋 สรุปผลงาน & Release Changelog — {proj_name} (`{branch}@{head_sha}`)")
print(f"> สร้างอัตโนมัติ (0-Token) เมื่อ: `{now_s}`\n")

if phase_line:
    print(f"## 🎯 สถานะปัจจุบัน (Current Phase)\n- {phase_line}\n")

if completed_lines:
    print("## ✅ งานที่ส่งมอบแล้ว (Completed Milestones)")
    for c in completed_lines:
        print(c)
    print("")

if verified_lines:
    print("## 🧪 หลักฐานการตรวจสอบล่าสุด (Verification Evidence)")
    for v in verified_lines:
        print(f"- {v}")
    print("")

print(f"## 📦 รายการแก้ไขแยกตามหมวด (Git Changelog ล่าสุด {len(commits)} Commits)")
if feats:
    print("### ✨ ฟีเจอร์ใหม่ (Features)")
    for f in feats:
        print(f)
if fixes:
    print("### 🐛 แก้ไขข้อบกพร่อง (Bug Fixes)")
    for fx in fixes:
        print(fx)
if others:
    print("### 🔧 โครงสร้าง/เอกสาร/อื่นๆ (Chore & Docs)")
    for o in others:
        print(o)
print("")

if next_lines:
    print("## ⏭️ ขั้นตอนถัดไป (Next Steps)")
    for n in next_lines:
        print(n)
PYEOF
