# claude-code-agent.md

Claude Code session config: imperatives + condensed init workflow. Imported by
the root `CLAUDE.md` manifest and concatenated into `.claude/claude.md` for
single-file harnesses. Companion to `agent.md` (full spec).

## Imperatives

Active in every session working in this repo.

1. `.pat` secrecy. Never reveal, echo, summarize, or store the content of a
   `.pat` file in chat output or context. Treat any `.pat` strictly as a secret;
   use only as a secret environment variable. Never commit a `.pat` file to a
   repo. Defensive rule only - no credential auto-loader.

2. Commit then await. After any local commit in a repo, display the suggested
   commit message, then await explicit push approval before pushing.

3. Hold commits quietly. Keep local commits. Do not be eager to push to origin.
   Do not repeat pending-push notifications.

4. No ephemerality caveats. Do not add "container is ephemeral" notes; it is
   understood.

5. Git auth. Every `git push` / `git fetch` to a remote MUST be authenticated by
   sourcing `git-init-session.sh` in the SAME Bash call as the git command
   (Claude Code's Bash tool does not persist shell state between calls):
   `source ./git-init-session.sh "$(cat <pat-file>)" && git push <url> <branch>`
   Never write ad-hoc `/tmp` askpass scripts. Never embed the PAT in a remote
   URL. Push to the explicit `https://github.com/<org>/<repo>.git` - `origin` is
   the local proxy and denies ecological-codes writes. The `git-push-guard.sh`
   PreToolUse hook blocks any push/fetch that skips the script.

Imperative 2 + 3 combined: on a commit, show the message once and await
approval; then hold silently - no re-notification.

## Session Init Workflow

Full spec: `agent.md` section 0-1. Condensed sequence:

1. Scan first message for `tersy` / `sessionlog` triggers - load skill if found.
2. Load `ecological-codes-compact.md` - absent: `⚠️`, non-blocking.
3. Load `trusted-hosts.md` if present - sets outbound allowlist.
4. Datetime: system UTC; cross-check `timeapi.io` if egress permits; else
   `⚠️ datetime-unverified`.
5. Skills probe + load prompteng (`prompteng/SKILL.md` -> `prompteng-SKILL.md`).
6. Init file registry; ensure `b3sum` (fallback `md5sum`).
7. Memory scan for file conflicts - surface, never silently resolve.
8. Emit 6-row init table. Init incomplete = no substantive output.

The SessionStart hook (`.claude/hooks/session-init.sh`) does mechanical prep
(`b3sum`, trusted-hosts check, datetime stamp) and reminds the agent to run this
sequence. The hook cannot enforce agent behavior - this file does.

## Files

- `.claude/settings.json` - registers hooks + Read deny rules.
- `.claude/hooks/session-init.sh` - SessionStart: mechanical init prep.
- `.claude/hooks/git-push-guard.sh` - PreToolUse(Bash): enforces Imperative 5.
- `.claude/environment.env.template` - env-config reference; paste into the web
  UI. No secrets - see Imperative 1.

## Scope

Per-repo: `.claude/` config applies to sessions working in the user-prefs repo.
To apply elsewhere, replicate `.claude/` in that repo or use environment config.

---
*claude-code-agent.md - Imperatives + init workflow. See `agent.md` for full spec.*
