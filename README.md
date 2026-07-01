<div align="center">

# 🐜 skills-graph

**As Agent Skills oficiais do [agent-graph-flow (`agf`)](https://graph-flow.cloud)** — o ciclo de vida
de engenharia em três pilares (**PLAN · BUILD · HARDEN**), prontas para qualquer agente de código.

[![site](https://img.shields.io/badge/site-graph--flow.cloud-f5a623)](https://graph-flow.cloud)
[![skills](https://img.shields.io/badge/skills-3%20pilares-2ea44f)](#as-3-skills)

</div>

---

## O que é

O **agent-graph-flow** (`agf`) é uma ferramenta de linha de comando que dá aos agentes de código
(Claude Code, GitHub Copilot CLI, Codex, Cursor, Gemini, OpenCode…) um **grafo persistente de execução**
como fonte única de verdade. Em vez de "vibe coding" — pedir um sistema inteiro num prompt e torcer —,
o `agf` obriga o trabalho a fluir por um grafo: cada tarefa vira um nó com critérios de aceite testáveis,
segue TDD (Red → Green → Refactor) e só é dada como concluída quando **AC ↔ código ↔ teste** batem no disco.

Este repositório contém **apenas as 3 skills do ciclo de vida + os protocolos compartilhados** — a camada
de conhecimento que ensina o agente *como* conduzir cada fase. Elas são o mesmo bundle distribuído em
[graph-flow.cloud](https://graph-flow.cloud) (`skills.zip`), versionado aqui para acesso público e histórico.

## De onde nasceu

O `agf` nasceu de uma dor concreta: agentes de código são potentes para escrever, mas **péssimos em disciplina**
— duplicam trabalho já em andamento, marcam tarefas como "prontas" sem teste, esquecem o que decidiram, e
gastam tokens à toa. A ideia foi materializar as práticas de engenharia (Clean Code, SOLID, TDD, Lean/Kanban,
Little's Law, Teoria das Restrições) e de economia de tokens **dentro de um grafo determinístico**, para que
a disciplina não dependa do agente "lembrar" — ela é cobrada por gatilhos (gates, hooks, harness).

As três skills abaixo são a destilação desse ciclo em linguagem que qualquer agente consegue seguir.

## As 3 skills

| Skill | Pilar | Quando usar |
|-------|-------|-------------|
| [`graph-backlog-generation`](graph-backlog-generation/SKILL.md) | 🐦 **PLAN** | Início de ciclo, ideia vaga, ou "o que construir a seguir?" — investiga o projeto (grafo + git + código) e gera um **PRD completo** como backlog no grafo (épicos, tasks, AC testáveis). Não escreve código. |
| [`graph-builder-leafcutter`](graph-builder-leafcutter/SKILL.md) | 🐜 **BUILD** | Existe uma task desbloqueada — **implementa o backlog ponta a ponta** com TDD, autônomo e contínuo (WIP=1, pull, não push), até esgotar o backlog. |
| [`graph-woodpecker`](graph-woodpecker/SKILL.md) | 🪶 **HARDEN** | O código funciona mas precisa **endurecer** — caça bugs, vulnerabilidades (OWASP/STRIDE), dívida técnica e pontos cegos de observabilidade, provando cada correção com teste de regressão (→ ≥80% cobertura). |

### Protocolos compartilhados (shareds)

- [`_shared.md`](_shared.md) — regras de ouro, economia de tokens, perfis e anti-padrões (referenciado pelas 3 skills).
- [`_pilot-protocol.md`](_pilot-protocol.md) · [`_pilot-protocol-template.md`](_pilot-protocol-template.md) — protocolo de delegação condutor ↔ executor.
- [`_rag-protocol.md`](_rag-protocol.md) — recuperação de comandos sob demanda (intenção em linguagem natural → comando exato).

## Instalação — passo a passo

### 1. Instale o `agf` (cross-platform)

**macOS / Linux:**
```bash
curl -fsSL https://graph-flow.cloud/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://graph-flow.cloud/install.ps1 | iex
```

O instalador detecta o SO/arquitetura e baixa o binário self-contained correto
(`darwin-arm64`, `darwin-x64`, `linux-x64`, `linux-arm64`, `windows-x64`). Não requer Node nem dependências.
Depois, `agf upgrade` mantém você sempre na última versão.

### 2. Instale as skills (cross-agents)

Clone este repositório (ou baixe o `skills.zip` do site) e copie as pastas para o diretório de skills do seu agente:

```bash
git clone https://github.com/DiegoNogueiraDev/skills-graph.git
```

| Agente | Diretório de skills |
|--------|---------------------|
| **Claude Code** | `~/.claude/skills/` (global) ou `.claude/skills/` (projeto) |
| **GitHub Copilot CLI** | `.agents/skills/` no projeto |
| **Codex** | `.agents/skills/` no projeto |
| **Cursor** | `.agents/skills/` no projeto |
| **Gemini CLI** | ativadas via `activate_skill` a partir de `.agents/skills/` |
| **OpenCode** | `.agents/skills/` no projeto |

> Mantenha a estrutura: cada skill traz seu `SKILL.md` + a pasta `references/`, e os shareds (`_shared.md`,
> `_pilot-protocol*.md`, `_rag-protocol.md`) ficam ao lado. O agente dispara cada skill pelo `name` do
> frontmatter, guiado pela `description`.

### 3. Use

```bash
agf start        # puxa a próxima task, monta o contexto, marca in_progress
# … implemente com TDD …
agf done <id>    # valida DoD + testes (blast gate) + marca done + sugere a próxima
```

Peça ao agente: *"planeje o próximo ciclo"* (dispara **PLAN**), *"implemente o backlog"* (**BUILD**),
ou *"endureça o código / ache bugs"* (**HARDEN**).

## Cross-platform · cross-agents

- **Cross-platform:** binários self-contained para macOS (arm64/x64), Linux (x64/arm64) e Windows (x64) —
  mesmo CLI, mesmos comandos, em qualquer SO.
- **Cross-agents:** as skills são Markdown com frontmatter padrão de Agent Skills — funcionam em qualquer
  agente que suporte o formato. O `agf` é dirigido **via CLI, zero MCP** — qualquer agente pilota a mesma via.

## Licença

Distribuído como parte do agent-graph-flow. Uso livre para operar o `agf`.
Documentação e download: **[graph-flow.cloud](https://graph-flow.cloud)**.
