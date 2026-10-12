---
name: agf-release-site
description: 'Use when you must ship a new agf version end to end: close the backlog, run the gates, tag, publish binaries, update the graph-flow.cloud site (features, architecture diagram, skills page, llms.txt) and refresh the public skills-graph mirror. It orchestrates the three repos (agent-graph-flow, graph-cloud-flow, skills-graph) in a fixed order and lists what any agent must know to operate agf well.'
triggers:
  - agf-release-site
  - release
  - publicar versão
  - atualizar site
version: 1.0.0
requires_agf: '>=0.27.0'
author: Diego Nogueira
date: 2026-10-11
---

# agf-release-site — release, site e conhecimento de agentes

Três repositórios, uma ordem. Quem pula etapa publica um site que mente sobre a versão.

| Repo             | Caminho                       | Papel                                                                        |
| ---------------- | ----------------------------- | ---------------------------------------------------------------------------- |
| agent-graph-flow | `~/projects/agent-graph-flow` | Código, grafo, tag, binários. Fonte das skills (`.agents/skills/`).          |
| graph-cloud-flow | `~/projects/graph-cloud-flow` | Site `graph-flow.cloud` (Next.js, pt/en). Deploy no host `agent-graph-flow`. |
| skills-graph     | `~/projects/skills-graph`     | Espelho público das skills do ciclo de vida.                                 |

Regras que valem aqui: tag, push e publicação só com **confirmação explícita do Dono**
(`agf constitution --show colony-constitution`). O checkout principal do agf fica em `main` e limpo;
trabalhe num worktree em `agent-graph-flow-ants/<id>`.

## 1. Portão de entrada (agf)

```bash
export AGF_AGENT_ID=<id>; a(){ npx tsx src/cli/index.ts "$@"; }
a stats --select data.byStatus          # task/bug fora de done = 0 (exceto o nó REL)
a suite triage --run                    # sem nó main-red novo e real; flaky de carga é P3 e não bloqueia
```

Backlog não zerou ou a suíte tem vermelho real: **pare**, o release espera. Suíte completa só com
load < 20 e uma por vez (`AGF_HEAVY_SLOTS`).

## 2. Changelog e versão

- Changelog sai dos nós `done` desde a última tag: `git log v<anterior>..HEAD` + `a query --status done`.
- Suba a versão em `package.json`; o resto do repo lê dali. Commit `chore(release): X.Y.Z`.

## 3. Tag e binários (agf) — pedir confirmação do Dono antes

```bash
git tag vX.Y.Z && git push origin main vX.Y.Z      # só com OK do Dono
npm run pack:bun                                    # 4 binários: darwin/linux × arm64/x64
node scripts/pack-offline.mjs --target-platform win32 --target-arch x64 --target-abi 127   # e 137
```

Windows: o worktree precisa de `node_modules` real (`cp -cR`), symlink gera tarball quebrado.
Envie ao servidor (`ssh agent-graph-flow`, `~/graph-cloud-flow/public/releases/`, com `.sha256` e `BUILDINFO`),
rode `pm2 restart graph-flow` (o Next só serve o que existia ao subir) e confira baixando pela URL
pública com `shasum -c`. O npm só publica com `vars.PUBLISH_NPM == 'true'` (hoje desligado).

## 4. Site (graph-cloud-flow)

Tudo que cita a versão: `grep -rl "<versão anterior>" app components public`. Em geral:

| O quê                                              | Onde                                                                            |
| -------------------------------------------------- | ------------------------------------------------------------------------------- |
| Novidades da versão e números                      | `app/i18n/{pt,en}.json`, `components/landing/Sections.tsx`                      |
| Funcionalidades (um item por comando e subcomando) | `components/features/featuresData.ts`                                           |
| Diagrama de arquitetura                            | `public/architecture/agf-<versão>-{pt,en}.html` (+ `.jpg`), `app/architecture/` |
| Skills mostradas                                   | `app/skills/`, `app/i18n/*.json`                                                |
| Índice para IA                                     | `public/llms.txt`, `app/sitemap.ts`, `app/structured-data.ts`                   |

**Funcionalidades:** liste os comandos reais (`a help`), compare com `featuresData.ts` e adicione o que falta
(pt e en, linguagem simples, sem jargão). Cada comando novo da versão entra nas "novidades".

**Diagrama:** rode `/archify` sobre a tag nova, com `--repo-root` no checkout real e cwd no scratchpad
(ele cria `.archify/` no cwd e sujaria o main, o que barra todo `done`). Gere pt e en, salve em
`public/architecture/`. Diagrama novo embutido precisa ficar nessa pasta, senão o CSP o bloqueia no iframe.

**Revisão visual:** o build local falha (Google Fonts sem rede aqui). Use `next dev -p 3999` e Chrome
headless com `--virtual-time-budget`; a captura sai em branco às vezes, repita. Rode `npm test` do site.

**Deploy:** rsync dos arquivos alterados, depois
`ssh agent-graph-flow 'cd ~/graph-cloud-flow && npm run build && pm2 restart graph-flow'`.
Confira em produção: `/`, `/features`, `/architecture`, `/skills` respondem 200 e mostram a versão nova.

## 5. Skills (agf → skills-graph → site)

1. Edite só em `.agents/skills/` (fonte única). `.claude/skills` e o skills-graph são espelhos gerados.
2. `npm run skills:sync` copia para `~/.claude/skills`. Confira com `a skill list`.
3. Copie as skills do ciclo de vida alteradas para `~/projects/skills-graph`, atualize o README
   (contagem e versão `requires_agf`) e faça push **com confirmação do Dono**.
4. Atualize `app/skills/` no site se o conjunto ou o texto mudou.

## 6. O que todo agente precisa saber para operar o agf

Ponha isto no `CLAUDE.md`/`AGENTS.md` do projeto e na página de primeiros passos do site.

- **Identidade primeiro:** `export AGF_AGENT_ID=<id>` antes do primeiro comando. O papel decide o que o git permite.
- **Grafo é a fonte de verdade:** nenhum código sem nó. Ciclo: `next` → `preflight "<tema>"` →
  `node status <id> in_progress` → teste que falha → código mínimo → `check <id>` → `node status <id> done`.
  WIP = 1 por agente; nunca `--force`.
- **Toda saída é JSON** `{ok, data, meta}`; use `--select data.campo` para gastar menos tokens.
- **Descoberta sob demanda:** `agf help`, `agf help <cmd>`, `agf retrieve-command "<intenção>"`, `agf skill list`,
  `agf constitution --show colony-constitution`. Não decore comandos.
- **No repo do agf** rode pelo código (`npx tsx src/cli/index.ts`), nunca o binário instalado.
- **Custo:** `agf metrics`, `agf savings`, `agf economy list`. Nada liga sem medição.
- **Honestidade:** ponta solta vira nó `risk`; "done" só vale com critério ↔ código ↔ teste no disco.

## Armadilhas já pagas

- Archify no checkout principal suja o grafo da colônia (BLAST_RADIUS_EXCEEDED).
- Nó do site/release vive em outro repo: o `done` reprova com `NO_DECLARED_FILES`; deixe `blocked` com o motivo e os commits.
- `pm2 restart` esquecido = binário novo dando 404.
- Sempre confirme na URL pública, não só no rsync.
