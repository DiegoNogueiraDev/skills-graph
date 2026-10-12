---
name: graph-implement
description: Execute the IMPLEMENT phase via the `agf` CLI — TDD Red→Green→Refactor driven by the guardrailed loop. Zero MCP
triggers:
  - graph-implement
version: 2.0.0
author: auto-generated
date: 2026-06-16
category: IMPLEMENT
phase: IMPLEMENT
tokens: ~666
phases: [PLAN, VALIDATE, BUGS]
---

# graph-implement

TDD Red→Green→Refactor driven by the guardrailed loop. Drive via the `agf` CLI — **zero MCP**. Load context with `agf context <id>` before changing anything.

## When to Use

- An unblocked task exists
- WIP=1: the previous task is done
- Executing atomic tasks

## Mandatory Flow

```
agf start → [TDD: red→green→refactor] → agf check <id> → agf done <id>
```

## Steps (IMPLEMENT phase)

| Command            | Does                                            |
| ------------------ | ----------------------------------------------- |
| `agf start`        | pull next task: wake-up + context + in_progress |
| `agf context <id>` | compact context-pack + RAG                      |
| `agf check <id>`   | DoD (catálogo completo) + TDD adherence         |
| `agf done <id>`    | finish: DoD + memory + done + suggest next      |
| `agf harness`      | agent-readiness (don't regress >5pts)           |

## Workflow

1. **Pull** — `agf start`
2. **Read context** — `agf context <id>` (interfaces/decisions the task depends on)
3. **Red** — failing test from AC (Given-When-Then)
4. **Green** — minimal code to pass
5. **Refactor** — improve without breaking tests
6. **Blast** — `npm run test:blast` (<60s, required)
7. **Check DoD** — `agf check <id>` (required + recomendados; lista completa em `agf help`)
8. **Done** — `agf done <id>`

## Exit

- [ ] Tests green (`npm run test:blast`)
- [ ] DoD passes (all required checks)
- [ ] Harness no regression (>5pts)
- [ ] Committed with descriptive message

## Output Format

```
Phase: IMPLEMENT
Tasks: N done, M in_progress  Tests: blast pass <60s
DoD: 8/8  Harness: X (ΔY pts)
Status: Ready for next task or VALIDATE
```

> Loop link: delegate via `agf brief <id>` → implement → `agf submit <id> --result <json>` (validate→blast→DoD→done). Spiral: `agf savings` → `agf learning` → next. → VALIDATE (graph-validate): `agf kanban`.

## Anti-Patterns

- No implementation without a test first — TDD mandatory
- WIP ≤ 1 — finish current before pulling next
- Don't mark done without `agf check`
- Don't refactor neighbors without AC — additive changes only
- Don't skip blast test — gate every task
- Don't let harness regress >5pts

## Related Skills

- $graph-plan — `agf skill show graph-plan`
- $graph-validate — `agf skill show graph-validate`
- $graph-bugs — `agf skill show graph-bugs`

## Codex Notes

- In Codex Plan Mode, plan only — don't mutate files.
- During implementation, follow `AGENTS.md` and use `apply_patch` for manual edits.

## Token Economy

> **Economia de tokens.** Os levers compartilhados por todas as skills — `--select`,
> `agf retrieve-command`, `agf exec chain`, reuso antes de criação — vivem em
> [`_shared.md`](../_shared.md) → **Token Economy**. Fonte única: um parágrafo repetido
> em trinta arquivos é o trigésimo primeiro que envelhece sozinho.
