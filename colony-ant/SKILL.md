---
name: colony-ant
description: 'Use when you are a WORKER session ("ant") in a colony that shares one agf graph with a leader and other ants — you pull or receive one task, build it with TDD in your own worktree, prove it the way a user would, commit on your own branch, and report to the leader. The entry point for the ant role: it routes each step to the agf command and the lifecycle skill that own it (graph-builder-leafcutter for the TDD cycle, graph-woodpecker for hardening tasks) instead of repeating them. Pair with colony-leader. NOT for leading the colony (colony-leader) or working alone without a leader (graph-builder-leafcutter). Triggers — colony-ant, ant, formiga, worker session, apoio, pull my task, report to leader, sou uma formiga, trabalhar na colônia.'
triggers:
  - colony-ant
  - ant
  - formiga
version: 1.0.0
requires_agf: '>=0.26.0'
author: Diego Nogueira
date: 2026-10-09
---

# colony-ant — one task, end to end, then report

You are one of N worker sessions on one shared graph. A leader assigns work and
talks to the human; a reviewer merges branches. You own one task at a time, from
`in_progress` to a commit with proof.

Every step names the **command** and the **skill that owns the detail**. Open
that skill for the detail; do not improvise a different cycle.

## Setup (once per session)

```bash
export AGF_AGENT_ID=<your-ant-id>        # identity first: WIP and claims are per agent
export AGF_GRAPH_ROOT=<repo-root>        # the shared graph lives in the main checkout
cd <repo>-ants/<your-ant-id>             # your own worktree (agf ant spawn)
```

What you may do with git is in the colony constitution, not repeated here:
`agf constitution --show colony-constitution` (bundle `colony-constitution`).
If your session refuses a command that the constitution allows, **stop and tell the
leader** — do not work around it, and do not ask the leader to run it for you. Only
the human can unblock your session.

## The cycle

| # | Step | Command | Owner skill |
|---|------|---------|-------------|
| 1 | Get the task | `agf next --agent <you>` (your assigned task comes first) | — |
| 2 | Claim it | `agf node status <id> in_progress` | — |
| 3 | Check for duplicates | `agf preflight "<topic>"` · `agf context <id>` | graph-builder-leafcutter |
| 4 | Build with TDD | red → green → refactor | graph-builder-leafcutter |
| 5 | Verify | test file · `npm run test:blast` · `tsc` · lint · `agf check <id>` | graph-builder-leafcutter |
| 6 | Prove as a user | run the real command / open the real screen | — |
| 7 | Close and commit | `agf node status <id> done` · one commit on `ant/*` | — |
| 8 | Report | message to the leader (format below) | — |

### 1–2 — Get and claim

- `agf next --agent <you>` hands you your assigned task first and never another
  agent's. Mark it `in_progress` at once — after your parent commit exists (the
  base is recorded then).
- Opening rules (one branch per task from `origin/main`, merge not fast-forward,
  declare only your files, no `--force`): read them from `agf ant spawn <id>` →
  `data.rules`. Source: colony-constitution (`ant-rule-1` … `ant-rule-5`). Not repeated here.
- Who to escalate to (ant → leader → CTO → human): the matrix in colony-constitution
  (`colony-escalation`). Not repeated here.
- Stop and ask the leader before you start when: `next` returns `NO_TASKS`; the
  task is a parent whose children are open; the task is assigned to someone else;
  or it touches a file another ant has in flight (`agf claims --colony`).
- WIP = 1. Do not pull a second task while one is open or uncommitted in your
  worktree — a second task mixes files into the first one's commit.

### 3–5 — Build and verify

Follow graph-builder-leafcutter for the cycle. Colony-specific points:

- Test only what changed during the task; the blast gate and the pre-push hook are
  the wide net. Do not run the full suite.
- A test that fails before your change is not yours: show it fails the same on
  `HEAD` without your change, then register it as a `risk`.
- An AC you cannot meet as written (a wrong number, a missing input) is a decision
  for the leader. Stop and ask; do not quietly weaken the test.

### 6 — Prove as a user

Verification belongs to you, not to the leader. Run the behavior through the path
a user takes — the command, or your worktree's `agf dashboard` when there is a
screen — and write down what you ran and what you saw. When the AC is a failure
path (exit 1, a refusal, a deny), prove that path too.

### 7 — Close and commit

- `agf node status <id> done` goes through the DoD gates. Never `--force`. If a gate
  refuses a correct delivery, stop and report it — the leader decides.
- One commit per task, title ≤ 100 characters, on your own `ant/*` branch.
- Then `git merge origin/main` into your branch when the leader asks for it.

### 8 — Report

The report is the graph. Put the fields below in the JSON of
`agf submit <id> --result '…'`, then leave the leader a notice with the node id and
`branch@sha` (`agf colony notice leader-agf "…"`) so it shows on their next `agf next`.
Send a session message only when you are blocked and cannot wait for the next round.

```
<node id> (<title>) done.
Branch: ant/<you> @ <sha>
Tests: <file tests> · blast <files/tests> · tsc · lint
Consumer proof: <command run> → <what was seen>
DoD: ready=<true|false>, score <n>
Findings: <risk node ids, one line each>
Open questions: <only decisions that change the result>
```

Then pull the next task. Do not wait for an acknowledgement unless you asked a
question.

## Economy

The shared levers (`--select`, `agf retrieve-command`, compressed shell output)
live in [`../_shared.md`](../_shared.md). Ant-specific: `agf context <id>`
instead of reading whole files, tests of the changed files only, and a report
the leader can check without opening your code.

## Related skills

- **colony-leader** — the other half: assignment, worktree removal, and the human report.
  The reviewer merges.
- **graph-builder-leafcutter** — BUILD: the TDD cycle, DoD, and the concurrency
  internals (claims, leases, worktrees).
- **graph-woodpecker** — HARDEN: when your task is a bug hunt, security, or coverage.
- **graph-backlog-generation** — PLAN: when the leader asks you to split or write tasks.
