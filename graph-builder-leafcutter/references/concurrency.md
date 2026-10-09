# Concurrent multi-agent internals (graph-builder-leafcutter)

Claim/lease mechanics for N agents on one graph. Roles, git authorization and the
report format live in the colony-leader and colony-ant skills.

## Setup — identity is mandatory in a shared graph

```bash
# Ant A (terminal 1)
export AGF_AGENT_ID=formiga-a

# Ant B (terminal 2)
export AGF_AGENT_ID=formiga-b
```

Alternatively, pass `--agent <id>` to `agf next` AND `agf done` (next claims, done
releases — both sides need the id). Priority: `--agent` flag > `AGF_AGENT_ID` env
var > auto-generated UUID. An ant operating WITHOUT identity gets single-agent
semantics — see the hijack gotcha below.

> **GOTCHA — `--agent` belongs ONLY on `next` and `done`; `agf node status` does
> NOT accept it and silently no-ops the transition when you pass it.** Running
> `agf node status <id> in_progress --agent <you>` returns a header but the status
> stays `backlog` (the unknown flag is swallowed, the mutation dropped) — you don't
> discover it until `agf done`/`check` fails the required `status_flow_valid` DoD
> check ("deve passar por in_progress"). Transition WITHOUT the flag:
> `agf node status <id> in_progress`. Ownership (`metadata.claimedBy`) is already
> written by `agf next --agent <you>`, so the plain transition is colony-safe — the
> id doesn't need to ride on `node status`. Prefer the env var (`export
AGF_AGENT_ID=<you>`) so identity flows to every command that honors it and you
> never hand `--agent` to one that doesn't.

> **CUIDADO — isole `AGF_GRAPH_ROOT` por ant/worktree.** O shell de cada ant deve apontar
> `AGF_GRAPH_ROOT` só para o grafo que ela possui. Um incidente real (commit `1af9dd22`)
> mostra o custo de pular essa checagem: `AGF_GRAPH_ROOT` vazou para uma execução do
> `vitest` e corrompeu o `workflow-graph/graph.db` compartilhado da colônia com cerca de
> 70 projetos de fixture. Cinco ants em paralelo descobriram a corrupção por conta própria.
> Antes de spawnar ou entrar numa colônia, imprima `AGF_GRAPH_ROOT` e confirme que ele
> aponta para o único grafo que você pretende tocar.

## Claim lifecycle

```
agf next --agent formiga-a       # atomically claims a task; other ants skip it
  → claim: { agentId, leaseToken, expiresAt }

# … Ant A implements + TDD …

agf done <id> --agent formiga-a  # marks done + releases the lease
```

If an ant crashes mid-task, the lease TTL (default **5 min** — verified
`CLAIM_TTL_SECONDS = 300` in agent-claim-manager; the docs' old "30 min" was wrong)
auto-expires and the task becomes claimable again. Re-running `agf next --agent
<you>` re-claims/renews your own live task after a restart. Inspect live leases
with `agf claims`.

## Stigmergy rules (earned in real 2-ant sessions)

1. **The durable trail marker is `in_progress` status, not the lease.** The lease
   only guarantees pull-time atomicity; any real TDD task outlives 5 min. After it
   expires, the other ant's only protection is the `in_progress` status — treat it
   as pheromone: NEVER adopt a task in_progress that isn't yours, even when
   `agf claims` is empty. Live-ant signals: blast-file mtimes seconds old, a second
   agent process running, files appearing mid-investigation.
2. **Ownership lives on the node (`metadata.claimedBy`), written at claim.** A task
   in_progress owned by another ant is never handed out as `wip-idempotent` and is
   surfaced as `FOREIGN_WIP` in the pull envelope; only a LEGACY in_progress node
   with no owner still gets the old restart-recovery handoff — so identity remains
   mandatory: an id-less ant writes no ownership and gets no protection.
3. **Occupied trail ⇒ divert, don't stop.** Meeting the other ant mid-flight
   (wip-conflict, foreign in_progress, files changing under you) is not an error:
   leave that task alone, claim another with your id, keep the colony moving.
   Reserve STOP for: nothing claimable AND harvest dry, or an unsafe tree (rule 4).
4. **The shared working tree is coordinated by DECLARED FILE SCOPES — declare at
   claim, always.** (Colony rule: one worktree per ant at every size — see
   **Scaling: worktree-per-ant** below. The old rejection
   of worktrees — "the gitignored graph.db doesn't travel" — was solved by the
   central graph root: every ant points at the SAME graph.) The declared boundary
   (implementationFiles + testFiles) does double duty: other ants' pulls skip
   candidates whose declared files overlap yours (even after your lease expires —
   the in_progress+owner status protects), and their done-gate excuses your declared
   dirty files instead of flagging them as scope creep. An UNDECLARED dirty file is
   an orphan: it still blocks every other ant's done by design. Never escape with
   `--force` (it skips tests); close (done + commit with explicit paths) promptly;
   never `git checkout --`/revert dirty files you didn't author — at most report
   them. If another ant's stash/pop sweeps the tree mid-run, a false RED or a
   false NO_FILES_MODIFIED can appear — before diagnosing a revert, check the
   file's mtime and grep for your symbol: stash-pop returns everything.
   **Integrating a moved remote with foreign dirty files:** `git pull --rebase`
   (and `--autostash`) refuses or stash-sweeps the other ant's files — use
   `git fetch` + `git merge origin/main` instead: merge tolerates dirty files
   that don't overlap the incoming diff (check with `git diff --name-only
HEAD origin/main` first), so the colony's tree is never swept.
5. **Support is free.** Your blast gate re-runs the other ant's affected tests: a
   green blast re-validates their trail at zero cost; a red one on THEIR files is a
   finding to deposit as a `risk` node — not a license to touch their code.
6. **Deposit trails for the colony.** Close each task with a pheromone memory
   naming the ant-protocol gotchas you hit, so the next ant skips the diagnosis
   you already paid for.

## Scaling: worktree-per-ant (4+ formigas)

Same-tree interference (done-gate reading the whole tree, one git index, blast
seeing foreign dirt, lint-staged auto-staging across ants) saturates useful
parallelism at ~3-5 ants. Past that, give each ant its own worktree while
ALL ants share ONE central graph + memories:

```bash
agf ant spawn formiga-a     # cria <repo>-ants/formiga-a (branch ant/formiga-a),
                            # symlinka node_modules e devolve os exports prontos
cd <repo>-ants/formiga-a
export AGF_AGENT_ID=formiga-a AGF_GRAPH_ROOT=<repo raiz>   # (do envelope do spawn)
# … loop normal: next → TDD → done → commit na branch ant/formiga-a …
# fim de ciclo: formiga NÃO mergeia nem dá push — avisa o leader com branch@sha (constituição: colony-git)
```

Rules that change in this mode: the done-gate and blast see only YOUR worktree
(no foreign-dirt contortions); commits land on `ant/<id>` (one per task); the ant
never merges to `main` or pushes — the leader merges and pushes `ant/*` (constitution `colony-git`);
claims/leases/pheromones work unchanged because `AGF_GRAPH_ROOT` points every
ant at the same `workflow-graph/`. What does NOT travel into a worktree is
anything gitignored (node_modules — symlinked by spawn; local `.env`s — copy
manually if the task needs them). Env hygiene: git exports `GIT_DIR`/`GIT_INDEX_FILE`
inside hooks — any tool spawning `git` for ANOTHER repo/fixture must strip
inherited `GIT_*` env or it will silently operate on the parent repo.

## Leader + ants

Running a leader with worker sessions: the leader follows the **colony-leader**
skill and each worker follows **colony-ant** (roles, git authorization, consumer
proof, report format). This section keeps only the claim/lease internals.
## 2-ant runnable example

```bash
# Terminal 1
export AGF_AGENT_ID=formiga-a
agf next --agent formiga-a       # pulls task X, claims it

# Terminal 2 (concurrently)
export AGF_AGENT_ID=formiga-b
agf next --agent formiga-b       # pulls task Y (X is locked), claims it

# Both complete independently:
agf done <X-id> --agent formiga-a
agf done <Y-id> --agent formiga-b
```

## Override: --force

`agf next --force` bypasses the per-agent WIP=1 guard and pulls a second task
for the same agent, emitting a `WIP_OVERRIDE` warning. Use only in exceptional
circumstances (e.g. the prior task is blocked and cannot be done yet).

## The colony as a separate, installable orchestrator (delegate-first, opt-in)

The colony can be driven by a **second, separately-installable binary** that lives
in the SAME repo and reuses 100% of the core — never a rewrite. The point is
optionality: a heavy frontier model plans the backlog; a **cheap model executes** it,
task by task, routing each task's **complexity-caste → model-tier** (the smallest
caste runs on the cheapest tier). Two invariants make this safe to wire back into the
main loop:

> **Jurisprudência desta etapa** (casos reais, causa-raiz e o blind-spot que os produziu): [references/field-lessons.md](references/field-lessons.md) → seção "The colony as a separate, installable orchestrator (delegate-first, opt-in)". Carregue sob demanda.

- **Colony size is a parameter on the opt-in flag** — one ant = one worktree (the
  worktree-per-ant primitive above), all pointed at the same graph via the shared
  graph-root env. Sizing past ~3-5 is where worktree-per-ant (vs. same-tree) pays off.
