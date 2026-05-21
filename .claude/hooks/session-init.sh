#!/usr/bin/env bash
# SessionStart hook: environment prep + init-workflow reminder.
# Registered in .claude/settings.json. Runs before Claude Code launches each session.
# Scope: sessions working in the user-prefs repo (per-repo .claude/ config).
#
# This hook does mechanical prep only. It cannot enforce agent behavior;
# Imperatives 1-5 and the init sequence are governed by CLAUDE.md / agent.md.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Integrity tool for BLAKE3 re-read guard (agent.md section 3). Prefer b3sum.
# Note: installing tools is better placed in the web-UI setup script (cached);
# kept here as a non-fatal fallback so a fresh container still has it.
if ! command -v b3sum >/dev/null 2>&1; then
  apt-get install -y b3sum >/dev/null 2>&1 || true
fi
if command -v b3sum >/dev/null 2>&1; then
  HASH_TOOL="b3sum"
elif command -v md5sum >/dev/null 2>&1; then
  HASH_TOOL="md5sum (fallback; change-detection only)"
else
  HASH_TOOL="none (integrity-unavailable)"
fi

# trusted-hosts allowlist presence (agent.md section 1 ACTION 1).
if [ -f "$PROJECT_DIR/trusted-hosts.md" ]; then
  TRUSTED_HOSTS="present"
else
  TRUSTED_HOSTS="absent"
fi

# git-init-session.sh presence (Imperative 5: git auth bootstrap).
if [ -f "$PROJECT_DIR/git-init-session.sh" ]; then
  GIT_INIT="present"
else
  GIT_INIT="absent"
fi

# System UTC datetime. Agent verifies drift against timeapi.io if egress permits.
DT="$(date -u +%Y_%m_%d-%H%M%S)"

cat <<EOF
[session-init hook | user-prefs]
datetime (system UTC, unverified): ${DT}
integrity tool: ${HASH_TOOL}
trusted-hosts.md: ${TRUSTED_HOSTS}
git-init-session.sh: ${GIT_INIT}

Agent actions:
- Run the agent.md / CLAUDE.md section 0-1 init sequence.
- Emit the 6-row init table before any substantive output.
- Imperatives 1-5 are in effect; see CLAUDE.md.

Git auth (Imperative 5): for any push/fetch, use ONE Bash call -
  source ./git-init-session.sh "\$(cat <pat-file>)" && git push https://github.com/<org>/<repo>.git <branch>
The git-push-guard.sh PreToolUse hook blocks pushes/fetches that skip the script.
EOF
exit 0
