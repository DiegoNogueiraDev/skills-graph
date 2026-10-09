# Lens — dependency (audit, licenses, freshness, supply chain)

Lens of `graph-woodpecker` for third-party packages. It folds in `graph-dependency`. The
pillar's GATES step runs the security and quality checks; this lens defines the dependency
audit those checks do not cover.

## Audit

- Run `npm audit --json`. Count findings by severity (critical, high, moderate, low), and split
  production from dev dependencies.
- A critical or high CVE in a production dependency blocks deploy.
- `npm audit fix` resolves the auto-fixable ones. Everything else needs a manual decision.
- Compare with the last audit in memory to separate new CVEs from recurring ones.
- Every unresolved CVE or license conflict becomes a risk:
  `agf node add --type risk --title "SEC: <package> <CVE>" --ac "<mitigation>"`.

## One version, no diamonds

- Target: exactly one installed version of each third-party package.
- Check with `npm ls --all`, grouping by package name. More than one version is a
  One-Version violation.
- A diamond is when two libraries pin incompatible versions of a shared base. Types and APIs
  break silently across the boundary. For each diamond: upgrade one side, dedupe, or replace.

## Licenses

- Allow: MIT, ISC, BSD-2-Clause, BSD-3-Clause, Apache-2.0, 0BSD, CC0-1.0.
- Deny in an MIT project: GPL-2.0-only, GPL-3.0-only, AGPL-3.0, SSPL-1.0.
- Flag for review: `UNLICENSED`, `SEE LICENSE IN`, and a missing license field.
- The license is read from each package's own `package.json`; `npm ls --all --json` gives the
  tree to walk.

## Freshness

Each major version behind is months of unpatched CVEs and API drift. Score each production
dependency with `npm outdated --json`:

| State                      | Score | Security implication                   |
| -------------------------- | ----- | -------------------------------------- |
| Latest installed           | 100   | Baseline                               |
| 1 minor behind             | 80    | Short CVE exposure window              |
| 2 or more minor behind     | 60    | Moderate unpatched surface             |
| 1 major behind             | 50    | About 6 to 12 months of CVE lag        |
| 2 or more major behind     | 20    | Over a year unpatched, likely breaking |
| No release in 12+ months   | 0     | Unmaintained: supply chain risk        |

Average the scores. The bottom 10 are the priority update targets.

## Supply chain

- Typosquatting: names one or two characters away from a popular package.
- Dependency confusion: an internal package name that also exists on the public npm registry.
- Low-trust packages: under 100 weekly downloads, a single maintainer (bus factor 1), or an
  ownership transfer in the last six months.
- Tree integrity: no `extraneous` or `missing` entries in `npm ls`.

## SBOM and shipped binaries

- Generate a CycloneDX SBOM: `npm sbom --sbom-format cyclonedx > sbom.json`.
- The component count must match `npm ls --all`, and `package-lock.json` must carry an
  integrity hash for every dependency.
- `agf scan-binaries` checks the shipped binaries: sha256, signature and provenance.

## Upgrade process

- Automated upgrade PRs (Dependabot or Renovate), with CI as the gate before merge.
- Commit the lockfile, so one revert restores the previous tree.
- Pin critical dependencies to exact versions, not ranges.
- Read the changelog for every breaking change before merging. Automation fetches the notes; a
  person still reads them.

## Record

Save the report with `agf memory write dependency-audit-<date>`. Grade it A to F on audit,
licenses, freshness and supply chain. A and B need no critical CVEs and no unresolved diamonds.
