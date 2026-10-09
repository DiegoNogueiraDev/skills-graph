# Lens — quality (GATES thresholds + refactor moves)

Lens of `graph-woodpecker` for code quality. It folds in `graph-quality-assurance` (review
thresholds) and `graph-refactor` (how to change code safely). The pillar's GATES step runs
`agf quality` and `agf harness --violations`. This lens defines the thresholds those gates
judge, and the moves for paying the debt they find.

## Smell thresholds

| Smell               | Threshold                                        | Severity | Priority        |
| ------------------- | ------------------------------------------------ | -------- | --------------- |
| Long function       | more than 50 lines                               | High     | fix now         |
| Deep nesting        | more than 3 levels                               | High     | fix now         |
| God class or file   | more than 300 lines                              | High     | fix now         |
| Dead code           | unused exports, unreachable branches             | Medium   | fix now         |
| Feature envy        | method uses another class's data more than its own | Medium | this sprint     |
| Data clumps         | same parameter group in 3 or more functions      | Medium   | this sprint     |
| Commented-out code  | code blocks inside comments                      | Low      | this sprint     |
| Primitive obsession | primitives where a domain type belongs           | Low      | defer           |

A "fix now" smell written in the current session must be resolved before the quality report.

## Complexity (McCabe)

Count decision points per function: `if`, `else if`, `case`, `while`, `for`, `&&`, `||`,
`catch`, `?:`.

| Decision points | Rating    | Action               |
| --------------- | --------- | -------------------- |
| 1 to 5          | Low       | None                 |
| 6 to 10         | Moderate  | Monitor              |
| 11 to 20        | High      | Simplify             |
| More than 20    | Very high | Decompose before merge |

Size ceilings are enforced by `agf lint-files`: 800 lines per file, exit 1 on violation.
Functions stay at 50 lines or fewer.

## SOLID check (per modified module)

| Principle                     | Question to ask                                                  |
| ----------------------------- | ---------------------------------------------------------------- |
| S: single responsibility      | One reason to change? Flag more than one.                        |
| O: open/closed                | Does a switch or if-chain grow with each new type?               |
| L: Liskov substitution        | Do implementations throw errors the base type does not?          |
| I: interface segregation      | Interfaces with more than 7 methods, or unused implementations?  |
| D: dependency inversion       | Direct instantiation where injection fits?                       |

## DRY and conventions

- Flag identical or near-identical blocks longer than 5 lines, and string literals repeated
  more than 3 times without a constant.
- Formatting, import order and kebab-case file names are enforced by the linter and formatter.
  Do not spend review time on them.
- Manual checks: PascalCase types, camelCase functions, named exports only, the project logger
  instead of `console.log`, typed error classes instead of a bare `new Error("msg")`, and
  `unknown` with type guards instead of `any`.
- Typecheck: `npm run typecheck` with zero errors. No `@ts-ignore` without approval.

## Review questions before marking done

- **Correctness:** are edge cases handled and errors propagated rather than swallowed?
- **Tests:** does every new behaviour have a test that fails when the code is wrong?
- **Design:** is the change self-contained, and does it avoid a layering violation?
- **Docs:** could a newcomer understand the module in five minutes? Are non-obvious decisions
  written down next to the code?

## Refactor moves

- **Two hats.** Structure or behaviour in one commit, never both. Name refactor commits after the
  move, for example `refactor: extract pricing logic into PriceCalculator`.
- **Untested code first.** Write a characterization test: assert a dummy value, let it fail,
  then pin the real output. Refactor only after that.
- **Find a seam.** Prefer an object seam: parameterize the constructor or method so a test can
  pass a fake. Break the dependency there, then refactor.
- **Catalog.** Long function: extract function. Deep nesting: guard clauses. Duplicate code:
  shared utility. Large class: extract class or split module. God object: decompose into focused
  modules. Tight coupling: interface plus injection. Feature envy: move the function to the data.
  Data clumps: parameter object.
- **Dead capability is debt.** `agf wire-dormant` lists exported code nothing reaches;
  `agf wire-check` fails when that list grows.
- **Debt ratio.** A under 5%, B 6 to 10%, C 11 to 20%, D 21 to 50%, E above 50%. A grade of D or
  E means cleanup before new features. Each debt item is a task:
  `agf node add --type task --tags "tech-debt,<category>"`.
- **Rules for the moves.** Tests green before the first structural change. One named move at a
  time, green after each, one commit per move. Do not refactor during a bug fix.
