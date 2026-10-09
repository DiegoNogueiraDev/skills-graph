# Architecture lens (DESIGN) — graph-backlog-generation

Use during DESIGN when the backlog touches structure: a new module, a new external
dependency, a layer crossing, or a refactor. The output is graph nodes, not a
document: each decision is an ADR, each debt item is a `risk`, each fix is a task.

Absorbed from the retired `graph-architecture` skill (2026-10-09 curation).

## Flow

```
C4 context → C4 container → C4 component → ADR inventory → fitness functions
→ layer boundaries → drift → nodes (adr / risk / task)
```

1. **C4 context** — users, external systems, data in/out.
   `agf export --format mermaid --direction LR`.
2. **C4 container / component** — map each container to a top-level source
   directory and check that the map matches the tree. Real dependencies, not
   assumed ones: `agf code impact <file>`, `agf code callers <file:line>`.
3. **ADR inventory** — `agf adr list` and
   `agf query --type decision --limit 50 --select data.nodes`. A missing decision:
   `agf adr create "<title>"`, constrained by `agf constitution list`.
4. **Fitness functions** — the table below.
5. **Layer boundaries** — the dependency direction is domain ← adapters ← entry
   points (CLI, server, UI). Flag any import against that direction.
6. **Drift** — `agf code index`, then `agf gaps --kind design_drift --json` and
   `agf gaps --kind phantom_done --json`.
7. **Nodes** — every debt item: `agf node add --type risk`; every fix: a task with
   testable AC.

## Fitness functions

| Function | Tool | Pass | Warn | Fail |
|---|---|---|---|---|
| No circular dependencies | `agf harness --violations --select data.violations` | 0 | — | ≥ 1 |
| Layer isolation | the project's import-boundary test | 0 violations | — | ≥ 1 |
| Coupling (0–1) | `agf harness --select data.breakdown.fitness` | ≤ 0.3 | 0.31–0.5 | > 0.5 |
| Public contracts typed | `agf harness --select data.breakdown.types` | 100% | 80–99% | < 80% |
| Reachable from a surface | `agf harness --select data.breakdown.connectivity` | no dormant capability | — | any dormant |
| Undocumented external deps | ADR inventory | 0 | 1 | ≥ 2 |
| Stale ADRs (> 90 days Proposed) | ADR inventory | 0 | 1 | ≥ 2 |

All pass = A · one warn = B · one fail = C · two or more fails = D.

## ADR quality (0–2 per criterion, max 10)

| Criterion | 0 | 1 | 2 |
|---|---|---|---|
| Context | missing | vague | problem + constraints |
| Forces | missing | one | ≥ 2 competing forces |
| Decision | missing | what, no why | what + why this option |
| Alternatives | missing | one | ≥ 2 with trade-offs |
| Consequences | missing | positive only | positive and negative |

8–10 publish · 5–7 complete before next review · 0–4 block the merge.

## Drift severity

| Signal | Severity | Action |
|---|---|---|
| 1 new undocumented module | monitor | update C4 when it stabilizes |
| 3+ new undocumented modules | flag | update C4 before more feature work |
| any layer violation | block | remediate (below) before merge |
| deprecated module still imported | flag | removal task, or ADR if kept on purpose |
| responsibility shift without ADR | flag | write the ADR retroactively |
| new external dependency without ADR | block | ADR + C4 container update |

## Layer violation remediation (cheapest first)

1. **Move** the code to the layer it belongs to.
2. **Invert** — an interface in the lower layer, implemented by the upper one.
3. **Adapter** — a thin translation module at the seam.
4. **Extract** — shared code both layers need goes to a shared module.

Never leave a violation as a comment only: it becomes a `risk` node with an owner.

## Early decay signals

- `TODO: move this` comments on boundary-crossing imports.
- One module growing much faster than the rest (lines or dependents).
- Unit tests that need two layers running to pass.
- More than 20% of ADRs Proposed for over 30 days.
- The same library at different versions in different modules.
