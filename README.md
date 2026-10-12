<div align="center">

# 🐜 skills-graph

**As Agent Skills oficiais do [agent-graph-flow (`agf`)](https://graph-flow.cloud)** — o ciclo de vida
de engenharia em três pilares (**PLAN · BUILD · HARDEN**), prontas para qualquer agente de código.

[![site](https://img.shields.io/badge/site-graph--flow.cloud-f5a623)](https://graph-flow.cloud)
[![skills](https://img.shields.io/badge/skills-28-2ea44f)](#as-28-skills)

</div>

---

## O que é

O **agent-graph-flow** (`agf`) é uma ferramenta de linha de comando que dá aos agentes de código
(Claude Code, GitHub Copilot CLI, Codex, Cursor, Gemini, OpenCode…) um **grafo persistente de execução**
como fonte única de verdade. Em vez de "vibe coding" — pedir um sistema inteiro num prompt e torcer —,
o `agf` obriga o trabalho a fluir por um grafo: cada tarefa vira um nó com critérios de aceite testáveis,
segue TDD (Red → Green → Refactor) e só é dada como concluída quando **AC ↔ código ↔ teste** batem no disco.

Este repositório contém **todas as 28 skills do agf + os protocolos compartilhados** — a camada
de conhecimento que ensina o agente *como* conduzir cada fase. **Este repositório é a fonte pública**:
clone-o, não baixe um arquivo compactado. Um `git clone` diz exatamente qual versão você tem e permite
`git pull` amanhã; um `.zip` não diz nem uma coisa nem outra.

## De onde nasceu

O `agf` nasceu de uma dor concreta: agentes de código são potentes para escrever, mas **péssimos em disciplina**
— duplicam trabalho já em andamento, marcam tarefas como "prontas" sem teste, esquecem o que decidiram, e
gastam tokens à toa. A ideia foi materializar as práticas de engenharia (Clean Code, SOLID, TDD, Lean/Kanban,
Little's Law, Teoria das Restrições) e de economia de tokens **dentro de um grafo determinístico**, para que
a disciplina não dependa do agente "lembrar" — ela é cobrada por gatilhos (gates, hooks, harness).

As skills abaixo são a destilação desse ciclo em linguagem que qualquer agente consegue seguir.

## As 28 skills

Requer `agf >= 0.27.0`. Cada pasta traz o `SKILL.md` e, quando precisa, `references/` e `scripts/`.

### Os 3 pilares (comece por aqui)

| Skill | Pilar | Quando usar |
|-------|-------|-------------|
| [`graph-backlog-generation`](graph-backlog-generation/SKILL.md) | 🐦 **PLAN** | Início de ciclo, ideia vaga, ou "o que construir a seguir?". Investiga o projeto (grafo, git e código) e gera o backlog no grafo: épicos, tasks e AC testáveis. Não escreve código. |
| [`graph-builder-leafcutter`](graph-builder-leafcutter/SKILL.md) | 🐜 **BUILD** | Existe uma task desbloqueada. Implementa o backlog de ponta a ponta com TDD, uma task por vez (WIP = 1), até esgotar a fila. |
| [`graph-woodpecker`](graph-woodpecker/SKILL.md) | 🪶 **HARDEN** | O código funciona, mas precisa endurecer: caça bugs, vulnerabilidades (OWASP/STRIDE), dívida técnica e pontos cegos, e prova cada correção com teste de regressão. |

### Fases do ciclo de vida

| Skill | Fase | Quando usar |
|-------|------|-------------|
| [`graph-prd`](graph-prd/SKILL.md) | 0 · PRD | Transformar uma ideia vaga num PRD pronto para `agf import-prd`. |
| [`graph-analyze`](graph-analyze/SKILL.md) | ANALYZE | Requisitos, PRD e Definition of Ready. |
| [`graph-design`](graph-design/SKILL.md) | DESIGN | ADRs, decisões de arquitetura e contratos. |
| [`graph-plan`](graph-plan/SKILL.md) | PLAN | Decompor, planejar a sprint e estimar com DORA. |
| [`graph-implement`](graph-implement/SKILL.md) | IMPLEMENT | TDD Red → Green → Refactor no loop com gates. |
| [`graph-validate`](graph-validate/SKILL.md) | VALIDATE | Validação unificada, integridade do done e cenários. |
| [`graph-review`](graph-review/SKILL.md) | REVIEW | Blast radius, sincronia com o código e diagramas. |
| [`graph-handoff`](graph-handoff/SKILL.md) | HANDOFF | PR, captura de memória e exportação de conhecimento. |
| [`graph-deploy`](graph-deploy/SKILL.md) | DEPLOY | Release, métricas DORA, escolha de provider e prova de custo. |
| [`graph-listening`](graph-listening/SKILL.md) | LISTENING | Coletar feedback, guardar o aprendizado e semear o próximo ciclo. |
| [`graph-mega-brain`](graph-mega-brain/SKILL.md) | 1 → 9 | Orquestrar uma feature pelas 9 fases, delegando o build e validando gate a gate. |

### Auditorias

| Skill | Foco | Quando usar |
|-------|------|-------------|
| [`graph-bugs`](graph-bugs/SKILL.md) | Bugs | Achar e corrigir bugs com 5 porquês e teste de regressão. |
| [`graph-security`](graph-security/SKILL.md) | Segurança | OWASP, STRIDE e segredos, quando a mudança toca autenticação, entrada externa ou dados. |
| [`graph-quality`](graph-quality/SKILL.md) | Refatoração | SOLID, DRY, complexidade de McCabe e economia de tokens. |
| [`graph-tests`](graph-tests/SKILL.md) | Testes | Pirâmide de testes, princípios FIRST e cobertura. |
| [`graph-docs`](graph-docs/SKILL.md) | Documentação | JSDoc, README atualizado e exemplos que rodam. |
| [`graph-platform`](graph-platform/SKILL.md) | Plataforma | Web Vitals, acessibilidade e harness, quando há tela. |

### Colônia: vários agentes no mesmo grafo

Cada sessão abre **uma** skill de papel. Ela aponta para os 3 pilares em cada passo, sem repeti-los.

| Skill | Papel | Quando usar |
|-------|-------|-------------|
| [`colony-cto`](colony-cto/SKILL.md) | 🧭 **CTO** | Dimensiona o time, define prioridade e escopo, avalia o placar e dá feedback a cada agente. |
| [`colony-leader`](colony-leader/SKILL.md) | 👑 **LEADER** | Atribui tasks sem sobrepor arquivos (`agf assign`), conduz as rodadas e limpa worktrees. |
| [`colony-ant`](colony-ant/SKILL.md) | 🐜 **FORMIGA** | Puxa uma task (`agf next --agent`), faz o TDD no próprio worktree, prova como usuário e reporta. |
| [`colony-reviewer`](colony-reviewer/SKILL.md) | 🔍 **REVISOR** | Revisa sem editar, mergeia no main o que aprova e faz push. |
| [`scrum-master`](scrum-master/SKILL.md) | ⏱️ Ritmo | Standup de 30 min tirado do grafo, status da sprint e retrospectiva. |
| [`kanban-orchestrator`](kanban-orchestrator/SKILL.md) | 📋 Fluxo | Quadro Kanban com limite de WIP, gargalos e métricas de fluxo. |

### Operação do próprio agf

| Skill | Quando usar |
|-------|-------------|
| [`agf-report-lead-time`](agf-report-lead-time/SKILL.md) | Relatório da rodada da colônia: vazão e lead time contra a linha de base gravada. |
| [`agf-release-site`](agf-release-site/SKILL.md) | Fluxo de release do agf: tag, binários, site e espelho de skills. Modelo para o release do seu próprio projeto. |

### Protocolos compartilhados (shareds)

- [`_shared.md`](_shared.md) — regras de ouro, economia de tokens, perfis e anti-padrões (referenciado por todas as skills).
- [`_pilot-protocol.md`](_pilot-protocol.md) · [`_pilot-protocol-template.md`](_pilot-protocol-template.md) — protocolo de delegação condutor ↔ executor.
- [`_rag-protocol.md`](_rag-protocol.md) — recuperação de comandos sob demanda (intenção em linguagem natural → comando exato).

## Instalação — passo a passo

### 1. Instale o `agf` (cross-platform)

**macOS / Linux:**
```bash
curl -fsSL https://graph-flow.cloud/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://graph-flow.cloud/install.ps1 | iex
```

O instalador detecta o SO/arquitetura e baixa o binário self-contained correto
(`darwin-arm64`, `darwin-x64`, `linux-x64`, `linux-arm64`, `windows-x64`). Não requer Node nem dependências.
Depois, `agf upgrade` mantém você sempre na última versão.

### 2. Instale as skills (cross-agents)

Clone este repositório e copie as pastas para o diretório de skills do seu agente:

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
Documentação: **[graph-flow.cloud](https://graph-flow.cloud)**.
