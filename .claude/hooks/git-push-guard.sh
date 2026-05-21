#!/usr/bin/env bash
# PreToolUse(Bash) guard: enforces CLAUDE.md Imperative 5.
# Blocks any `git push` / `git fetch` that is not authenticated by sourcing
# git-init-session.sh in the same command. Registered in .claude/settings.json.
#
# Contract: exit 0 = allow; exit 2 = block (stderr is fed back to the agent).
set -uo pipefail

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

# Nothing to inspect - allow.
[ -z "$CMD" ] && exit 0

# Match `git [global-opts] (push|fetch)` - the subcommand must be the first
# non-option token after `git`, so `git commit -m "fetch ..."` does NOT match.
GIT_REMOTE_OP='git([[:space:]]+(-c[[:space:]]+[^[:space:]]+|--[A-Za-z][A-Za-z-]*(=[^[:space:]]+)?|-[A-Za-z]+))*[[:space:]]+(push|fetch)([[:space:]]|$)'

if printf '%s' "$CMD" | grep -Eq "$GIT_REMOTE_OP"; then
  if ! printf '%s' "$CMD" | grep -q 'git-init-session.sh'; then
    {
      echo "BLOCKED by git-push-guard (CLAUDE.md Imperative 5):"
      echo "git push/fetch must be authenticated via git-init-session.sh."
      echo ""
      echo "Re-issue as a SINGLE Bash call (Bash tool does not persist shell state):"
      echo "  source ./git-init-session.sh \"\$(cat <pat-file>)\" && \\"
      echo "    git push https://github.com/<org>/<repo>.git <branch>"
      echo ""
      echo "Do not write ad-hoc /tmp askpass scripts. Do not embed the PAT in the URL."
    } >&2
    exit 2
  fi
fi
exit 0
