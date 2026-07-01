# skills-graph

Agent skills do **[agent-graph-flow (`agf`)](https://graph-flow.cloud)** — o ciclo de vida completo
em três pilares, prontos para usar com Claude Code, Copilot CLI, Codex, Cursor, Gemini e outros agentes.

## As 3 skills

| Skill | Pilar | Quando usar |
|-------|-------|-------------|
| [`graph-backlog-generation`](graph-backlog-generation/SKILL.md) | **PLAN** | Início de ciclo / ideia vaga / "o que construir a seguir?" — investiga e gera um PRD completo como backlog no grafo. |
| [`graph-builder-leafcutter`](graph-builder-leafcutter/SKILL.md) | **BUILD** | Existe task desbloqueada — implementa o backlog ponta a ponta com TDD, autônomo e contínuo. |
| [`graph-woodpecker`](graph-woodpecker/SKILL.md) | **HARDEN** | O código funciona mas precisa endurecer — bugs, vulnerabilidades, dívida técnica, cobertura de testes. |

## Shareds

Protocolos compartilhados referenciados pelas skills:

- [`_shared.md`](_shared.md) — regras de ouro, economia de tokens, perfis e anti-padrões.
- [`_pilot-protocol.md`](_pilot-protocol.md) · [`_pilot-protocol-template.md`](_pilot-protocol-template.md) — protocolo de delegação (condutor ↔ executor).
- [`_rag-protocol.md`](_rag-protocol.md) — recuperação de comandos sob demanda (RAG-IN).

## Como usar

Instale o `agf` em [graph-flow.cloud](https://graph-flow.cloud) e copie estas skills para o diretório
de skills do seu agente (ex.: `~/.claude/skills/` no Claude Code). Cada `SKILL.md` traz um bloco de
frontmatter com `name` e `description` que dispara a skill pelo intent.

## Licença

Distribuído como parte do agent-graph-flow. Uso livre para operar o `agf`.
