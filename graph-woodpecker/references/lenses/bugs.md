# Lens — bugs (HUNT extras + structured FIX)

Lens of `graph-woodpecker` for finding and fixing defects. It folds in `graph-bug-hunter`
(discovery) and `graph-fix-bugs` (structured fix). The pillar's own HUNT, FILE, REPRODUCE and
FIX steps still apply. This file adds only what they do not say.

## Discovery signals beyond the pillar's HUNT

### LSP diagnostics, by priority

| Tier | Level        | Action                              |
| ---- | ------------ | ----------------------------------- |
| 1    | error        | Block: fix before anything else     |
| 2    | warning      | Schedule in the current sprint      |
| 3    | hint / info  | Track; batch with low-severity bugs |

Files with 3 or more errors are high-attention targets. Files with 5 or more warnings and
no errors are smell targets. Collect the full list with `npx tsc --noEmit`. For symbol-level
work use `agf code def`, `agf code refs`, `agf code impact` and `agf code affected`.

### High-signal grep patterns

Each hit goes straight to triage with a confidence tier (below).

```bash
grep -rn '!\.' src/ --include='*.ts' --include='*.tsx'          # non-null assertion: crash waiting
grep -rn 'catch\s*{[[:space:]]*}' src/                          # empty catch: swallowed error
grep -rn ': any' src/ --include='*.ts'                          # any: type-safety hole
grep -rn 'async.*=>' src/ | grep -v 'await\|return'             # floating promise candidates
grep -rn 'TODO\|FIXME\|HACK' src/                               # acknowledged debt (file as Low)
grep -rn 'readFileSync\|writeFileSync\|execSync' src/           # sync I/O on an async path
grep -rn 'console\.log' src/ --include='*.ts' --include='*.tsx' # logging on production paths
grep -rn '[^a-zA-Z_][0-9]\{3,\}[^0-9]' src/ --include='*.ts'    # magic numbers: undocumented rules
```

### Hotspot risk score

```
Risk = change frequency × complexity × (1 − coverage)
```

- Change frequency: `git log --since="30 days" --format="" --name-only | sort | uniq -c | sort -rn`
- Complexity: LSP diagnostic count as a proxy (or cyclomatic complexity when available)
- Coverage: fraction from the last test run, 0 to 1

A file changed more than 5 times in 30 days with coverage below 0.5 is an immediate hotspot.
Hotspots without tests are the likeliest source of the next bug.

### Error history

Files that appear in 3 or more bug-fix commits in 90 days are recurrence hotspots. Static
analysis will miss the next bug there, so they need regression tests written against the
failure class, not only the fix.

```bash
git log --oneline --since="90 days" | grep -iE 'fix:|bug:|error:|crash:|revert' | \
  awk '{print $1}' | xargs -I{} git diff-tree --no-commit-id -r --name-only {} | \
  sort | uniq -c | sort -rn | head -20
agf memory search "pheromone-fix"                          # root cause + fix of past hunts
agf query --type bug --status done --limit 20 --select data.nodes
```

## Confidence tiers: what becomes a node

| Tier | Label    | Criteria                                                       | Action                                  |
| ---- | -------- | -------------------------------------------------------------- | --------------------------------------- |
| A    | Definite | Reproducible crash, type error, empty catch with evidence      | File as a Critical/High node            |
| B    | Probable | Pattern plus hotspot overlap, or more than 3 LSP errors in file | File as Medium; confirm before fixing  |
| C    | Possible | Pattern only, no hotspot or LSP signal                         | Log in the report; no node              |

Promote C to B only when two independent sources agree (pattern plus git history, or pattern
plus LSP warning). Never file nodes for Tier C alone: they inflate the count without signal.

## Severity

| Severity | Criteria                                    | Action                    |
| -------- | ------------------------------------------- | ------------------------- |
| Critical | Security hole, data loss, Tier A            | Fix now                   |
| High     | Wrong behaviour, logic error                | Fix this sprint           |
| Medium   | Smell, Tier B                               | Next sprint               |
| Low      | Style, Tier C, TODO/FIXME                   | Track and batch           |

Create a node for each Critical, High and confirmed Medium bug:

```bash
agf node add --type bug --title "BUG: <symptom> em <file>" --tags "<severity>" \
  --ac "<the failing behaviour, stated so a regression test can assert it>"
```

Risks the hunt surfaced but did not confirm drain later through `agf risk triage`.

## Root cause and fix (added to REPRODUCE and FIX)

- **Falsifiable whys.** Each level of the 5 Whys needs evidence: a log or error for the first,
  a code path or debugger trace for the second, an isolating reproducer for the third, the
  input or state for the fourth, the design decision for the fifth. An unverified level is a
  hypothesis: mark it and design an experiment. Record the verified chain in the bug node.
- **Impact before editing.** `agf code impact <file> <symbol>` for the blast radius;
  `agf code affected <file>` for the tests that already cover it.
- **Verify the fix beyond green tests.** (1) Other paths that exercise the same logic.
  (2) Boundaries: empty, null, max, concurrent. (3) The same pattern at other call sites: fix
  the class, not only the instance. (4) The original behaviour: `agf verify-ac <bug_node_id>`
  and `agf check <bug_node_id>`.
- **Regression test by bug category.**

| Bug category                                   | Test to add                                  |
| ---------------------------------------------- | -------------------------------------------- |
| Logic error (wrong condition, off-by-one)      | Unit test with boundary inputs               |
| Timing / async (race, stale state)             | Integration test with a concurrent run       |
| Configuration / environment                    | Smoke test over config variations            |
| Data shape (null, missing field, wrong type)   | Unit test with null, empty and malformed inputs |
| Integration contract (API or schema drift)     | Contract test against the real contract      |
| UI state (wrong render, stale prop)            | Component test over the interaction sequence |

- **Minimal diff.** One bug, one fix, one commit. No refactor inside the fix commit.
- **Prevention.** `agf memory write pheromone-fix-<slug>` with the root cause, the fix, and the
  gotcha. The gotcha is what stops the next hunt from walking the same dead end.
