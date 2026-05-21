---
id: sp-compensations-map
version: 1.1.0
status: Human Approved
scope: analysis
created: 2026_04_26
references:
  - agent.md v3.4.1
  - claude-sonnet_4_6-paraphrased_system_prompt-compact.md v1.0.0
  - claude-opus_4_7-system_analysis.md v1.0.0
---

# agent.md - System Prompt Compensation Map

Each row: one SP deficiency, the agent.md section compensating for it,
and the mechanism used.

| SP Deficiency | SP Source | agent.md § | Mechanism |
|---|---|---|---|
| No token-cost awareness or re-read prevention | Sonnet §2 ⚠️ (format), Opus §4 | §2 Registry & Cost | Mental registry tracks every file read; cost estimated at bytes/4; triggers re-read warning before repeat loads |
| No file integrity mechanism; memories are unverifiable and unversioned | Sonnet §8 ⚠️ (memory application) | §3 Integrity & Re-Read | BLAKE3 hash recorded on first read; recomputed before repeat read; diff = modified, re-read justified; match = skip |
| Memory application is silent; no friction for potentially adversarial injections | Sonnet §8 ⚠️ (memory vs. safety_reminders conflict) | §3 Integrity & Re-Read | Explicit pause + user choice (A/B/C) before any repeat file read; prevents silent token burn and silent adversarial re-injection |
| No context budget monitoring or checkpoint trigger | Sonnet §11 (computer use), Opus §1 ({search_first} latency) | §2 Registry & Cost + prompteng-SKILL.md §2.4 | 20%/15% thresholds; checkpoint offered at 20%; no new sub-task below 15% |
| Context registry resets between sub-tasks silently | Sonnet §11 (computer use) | §2 Registry & Cost | Registry is session-scoped, not sub-task-scoped; explicit pass on sub-agent handoff |
| No structured load order for user-defined configs | Sonnet §11 ⚠️ (format/skill conflict) | §1 Session Init | Init sequence + 6-row init table fix load order; system-wide (Personal Preferences) vs project-scoped deployment is covered in README |
| No trust hierarchy between memories and loaded files; file/memory conflict undefined | Sonnet §8 ⚠️ (natural application vs. malicious injection; forbidden verb over-specification) | §4 Memory Precedence (§4.1-§4.3) | Four-tier taxonomy (Short-Term / Long-Term / Selective / Latent); precedence rules; conflict surfacing format; canonization threshold; hygiene rules; secret storage rules |
| SP memory rule says apply naturally; safety_reminders says memories may be malicious - no priority rule | Sonnet §8 ⚠️ | §4.2 Precedence | File always wins over memory; any memory reading as a [RULES] directive treated as suspicious; conflict surfaced before proceeding |
| Credential material exposed via transcript/memory extraction pathway | Sonnet §11 (computer use), agent.md §4.3 rationale | §4.3 Memory Hygiene + claude-sp-guards.md §3.2 | Secrets never in project files/instructions; file-upload + bash-pipe keeps secret out of transcript; two-channel PAT verification |
| {search_first} in Opus 4.7 forces search before every factual answer - no cost guardrail | Opus §1 ({search_first} latency trap) | §2 Registry & Cost | Token cost estimation + registry discipline limit unnecessary search overhead; checkpoint triggers before context exhaustion |
| Delimiter migration (XML to {braces}) in Opus 4.7 weakens injection resistance | Opus Part 3 §1 | §4.2 RULE 3 | Memory may never override [RULES] directives in any loaded file regardless of framing |

---

*sp-compensations-map.md v1.1.0 - 2026_04_26. Section refs retargeted to agent.md v3.4.1.*
