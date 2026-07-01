# \_shared.md — agent-graph-flow Common Skill Content

System file. Not a skill itself. Referenced by lifecycle and domain skills via `<!-- shared:section_name -->`.

**Skills não duplicam mais esta seção.** Cada skill tem apenas 4 linhas de referência compacta.
Consulte esta seção para detalhes completos de economia de tokens, perfis e anti-padrões.

**CLI-first:** every workflow drives the `agf` CLI — there is NO MCP server. Commands below are real `agf <cmd>` invocations.

---

## Lifecycle Phases

9 fases: **ANALYZE → DESIGN → PLAN → IMPLEMENT → VALIDATE → REVIEW → HANDOFF → DEPLOY → LISTENING**

| #   | Phase     | Purpose                                         |
| --- | --------- | ----------------------------------------------- |
| 1   | ANALYZE   | PRD, requisitos, Definition of Ready (7 checks) |
| 2   | DESIGN    | Arquitetura, ADRs, C4 Model                     |
| 3   | PLAN      | Sprint planning, decomposição atômica           |
| 4   | IMPLEMENT | TDD Red→Green→Refactor, pipeline v8.0           |
| 5   | VALIDATE  | E2E, AC, DORA quality metrics                   |
| 6   | REVIEW    | Blast radius, code review, mermaid              |
| 7   | HANDOFF   | PR, snapshot, export knowledge                  |
| 8   | DEPLOY    | CI pipeline, release, post-release              |
| 9   | LISTENING | Retrospective, next cycle seeding               |

---

## Phase Gates

Antes de mudar de fase, rodar o gate correspondente (`agf gate <phase>`):

| De → Para            | Gate (`agf`)                         | Pré-requisitos                            |
| -------------------- | ------------------------------------ | ----------------------------------------- |
| ANALYZE → DESIGN     | `agf gate design`                    | ≥1 epic/requirement no grafo              |
| DESIGN → PLAN        | `agf gate design`                    | ADRs, interfaces, coupling + harness ≥ 55 |
| PLAN → IMPLEMENT     | `agf decompose`                      | tasks atômicas com AC testável            |
| IMPLEMENT → VALIDATE | `agf check <id>`                     | ≥50% tasks done com AC testável           |
| VALIDATE → REVIEW    | `agf check <id>` (DoD + status_flow) | Todos checks passam                       |
| REVIEW → HANDOFF     | `agf gate review`                    | `agf export` + blast radius ok            |
| HANDOFF → DEPLOY     | `agf gate handoff`                   | `agf snapshot create` + memórias salvas   |
| DEPLOY → LISTENING   | `agf gate deploy`                    | Release validado + harness ≥ 70           |

---

## Pipeline

**Primário (2 calls — obrigatório):**

```
agf start → [implementar com TDD] → agf done <id>
```

**Granular (controle fino):**

```
agf next → agf context <id> → [TDD] → agf check <id> → agf node status <id> done
```

**WIP = 1** — Máximo 1 task `in_progress` por agente. Lei de Little: `cycle_time = WIP / throughput`.

---

## Mapa de Decisão de Ferramentas (intent → comando/skill)

**O agente externo conduz** (delegate-first: o LLM é seu, não do agf). Use esta tabela para escolher a ferramenta certa por intenção. Não lembra o comando exato? **`agf retrieve-command "<intenção>"`** (RAG-IN) resolve qualquer caso abaixo.

| Sua intenção                                                              | Ferramenta agf                                                           |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Ideia vaga / "o que construir?" / planejar do zero                        | skill **graph-backlog-generation** (PLAN) → vira backlog                 |
| Implementar o backlog (task pronta) end-to-end                            | skill **graph-builder-leafcutter** (BUILD) · `agf start`                 |
| Endurecer: bugs/segurança/cobertura/observabilidade                       | skill **graph-woodpecker** (HARDEN)                                      |
| "O que faço agora?"                                                       | `agf next` (pull) · `agf start` (next+context+in_progress)               |
| Antes de codar — não duplicar trabalho/stream                             | `agf preflight "<tópico>"` (git+grafo+WIP)                               |
| Entender uma task antes de tocar código                                   | `agf context <id> --compressed` + `agf search`/`rg`                      |
| Criar estrutura (epic/tasks/edges) antes de codar                         | `agf import-prd` · `agf node add` · `agf edge add`                       |
| Validar antes de fechar                                                   | `agf check <id>` (DoD) → `agf done <id>` (blast gate)                    |
| Delegar uma task a um executor                                            | `agf brief <id>` → executor → `agf submit <id> --result`                 |
| Achar lacunas de completude (req↔task↔test, AC, NFR)                      | `agf gaps --severity required --select data`                             |
| Medir prontidão/qualidade do código                                       | `agf harness` (8 dimensões, A–D)                                         |
| Encadear vários passos agf (1 round-trip)                                 | `agf exec chain "a; b; c"` · `agf exec pipe`                             |
| **Rodar QUALQUER shell** (git/ls/dir/grep/find/cat/test/build/powershell) | **`agf compress run -- <cmd>`** (hookless) · Claude Code = hook auto     |
| Ver/gerenciar o cache de prompt (RAG-cache)                               | `agf cache stats` (hit rate, tokens/$ poupados) · `agf cache plan-store` |
| Escolher provider/custo da chamada LLM (modo `--live`)                    | `agf provider use <id>` · `--pin <model>` · tier-router                  |
| Ver economia (tokens/$/levers)                                            | `agf metrics --economy-report` · `agf savings` · web `agf dashboard`     |
| Scaffold/boilerplate pronto (não gerar do zero)                           | `agf montar-output "<objetivo>"` (RAG-OUT)                               |
| Criar skill/agent/hook                                                    | `agf skill new` · `agf agent create` · `agf hooks add`                   |
| Descobrir comandos / não sei por onde começar                             | `agf help` · `agf retrieve-command "<intenção>"`                         |

> Regra de ouro: **se não tem nó no grafo, crie primeiro** (`agf node add`/`import-prd`) — nenhuma implementação fora do grafo. Tudo via CLI `agf` — zero MCP.

---

## Definition of Done

9 checks executados em `agf check <id>` (e em `agf done <id>`):

| #   | Check                     | Severidade   | O que verifica                                                                                                    |
| --- | ------------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------- |
| 1   | `has_acceptance_criteria` | **required** | Task ou parent tem AC                                                                                             |
| 2   | `ac_quality_pass`         | **required** | Score AC ≥ 60 (INVEST)                                                                                            |
| 3   | `no_unresolved_blockers`  | **required** | Nenhum `depends_on` para node não-done                                                                            |
| 4   | `status_flow_valid`       | **required** | Passou por `in_progress` antes de `done`                                                                          |
| 5   | `has_description`         | recommended  | Descrição não-vazia                                                                                               |
| 6   | `not_oversized`           | recommended  | Sem L/XL sem subtasks                                                                                             |
| 7   | `has_testable_ac`         | recommended  | ≥1 AC testável                                                                                                    |
| 8   | `has_estimate`            | recommended  | xpSize ou estimateMinutes preenchido                                                                              |
| 9   | `has_test_files`          | recommended  | testFiles populated                                                                                               |
| 10  | `economy_awareness`       | recommended  | Lê o `llm_call_ledger`: só falha se a task GASTOU tokens LLM sem lever/cache/projeção (0 gasto = delegate, passa) |

Grades: A (85-100%), B (70-84%), C (55-69%), D (<55%).

---

## Definition of Ready

7 checks — gate ANALYZE → DESIGN:

| #   | Check                     | O que verifica                   |
| --- | ------------------------- | -------------------------------- |
| 1   | `has_requirements`        | ≥1 epic ou requirement no grafo  |
| 2   | `has_acceptance_criteria` | Tasks ou AC nodes existem        |
| 3   | `no_orphans`              | Sem requirements ou tasks órfãos |
| 4   | `no_cycles`               | Sem ciclos de dependência        |
| 5   | `has_constraints`         | ≥1 constraint node               |
| 6   | `has_risks`               | ≥1 risk node                     |
| 7   | `prd_quality_score`       | Score PRD ≥ 60                   |

---

## Token Economy (Economia de Tokens)

**Aplique em TODA interação com o grafo. O ganho é acumulativo e brutal.**

### Flags de Projeção (~80-90% redução de tokens)

| Flag           | Quando usar                                                             | Exemplo                                          | Economia        |
| -------------- | ----------------------------------------------------------------------- | ------------------------------------------------ | --------------- |
| `--select`     | Sempre que só precisa de campos específicos                             | `agf next --select data.node.id,data.node.title` | ~80-90%         |
| `--profile`    | Preset de campos por agente (`claude-code\|copilot\|opencode\|minimal`) | `agf next --profile claude-code`                 | ~70-90%         |
| `--compressed` | Contexto de task (sempre)                                               | `agf context <id> --compressed`                  | ~50-70%         |
| `--limit`      | Query com muitos resultados                                             | `agf query --limit 10`                           | Evita overflow  |
| `--pretty`     | Debug humano apenas                                                     | `agf next --pretty`                              | 0% (gasta mais) |
| `--format`     | Export específico                                                       | `agf export -o file.json`                        | N/A             |

`--select` sempre vence quando `--profile` e `--select` são dados juntos. Path inválido em `--select` → cai no envelope completo (nunca quebra).

**Regra de ouro:** `agf query` sem `--select` = desperdício. `agf context` sem `--compressed` = desperdício.

### Delegação & RAG (recupera, não despeja)

| Comando                             | Quando usar                     | Por quê                                                                        |
| ----------------------------------- | ------------------------------- | ------------------------------------------------------------------------------ |
| `agf brief <id>`                    | Delegar uma task a um executor  | Spec ≤500 tokens (intenção/AC/contrato/blast) em vez de re-ler arquivos        |
| `agf retrieve-command "<intenção>"` | Não lembra o comando exato      | RAG-IN: devolve o comando certo em vez de paginar `--help`                     |
| `agf montar-output "<objetivo>"`    | Precisa de scaffold/boilerplate | RAG-OUT: scaffold com slots preenchidos em vez de gerar do zero                |
| `agf cache stats`                   | Ver/reusar o cache de prompt    | RAG-cache: hit rate + tokens/$ poupados pelo prefix-cache (reuso, não regerar) |

### Composição Nativa (zero shell, cross-platform)

| Modo             | Quando usar                | Exemplo                                    |
| ---------------- | -------------------------- | ------------------------------------------ |
| `agf exec pipe`  | Precisa do `.data` interno | `agf exec pipe next --select data.node.id` |
| `agf exec chain` | Sequência de comandos      | `agf exec chain "next; check <id>"`        |

**Regra:** Nunca use `&&` ou `|` do shell. Sempre `agf exec`.

### Compressão de Output (TODO comando shell externo)

**Regra dura:** TODO comando de shell — `git`, `ls`, `dir`, `cat`, `grep`/`rg`, `find`, `npm`/`pnpm`, `cargo`, build, test, **PowerShell**, etc. — passa pela compressão determinística do agf antes de você LER a saída. Saída bruta de shell = tokens desperdiçados.

- `agf compress run -- <cmd>` — roda o comando e comprime o stdout (ou `cmd | agf compress run --stdin`). Reversível via `agf retrieve <hash>` (CCR).
- `agf compress` / `agf rtk` — mesma engine; `discover` (acha filtros) · `test <file>` (preview). Nunca envolva `agf` em `agf compress` — a saída do próprio agf já é mínima.
- `agf compress discover` — descobre filtros automáticos
- `agf compress test <file>` — comprime output de teste

> **⚠️ GUARDRAIL CLI-AWARE (obrigatório):**
>
> - **Claude Code** — o hook `PostToolUse` comprime automaticamente. **NÃO** prefixe manualmente com `agf compress run --`; isso causaria dupla-compressão.
> - **CLIs sem hook (Copilot CLI / Codex / OpenCode / etc.)** — envolver output de shell em `agf compress run -- <cmd>` é **OBRIGATÓRIO** antes de ler qualquer output volumoso. Exemplo: `agf compress run -- npm test` em vez de `npm test` diretamente.
>
> Regra: Claude Code = hook automático (não tocar); hookless = prefixo `agf compress run --` obrigatório.

### Medir & calibrar (transforma promessa em número)

- `agf metrics --economy-report` — tokens/$ por task + o que as alavancas pouparam.
- `agf metrics --simulate` — re-precifica a fatura real sob TODOS os modelos (qual provider sairia mais barato).
- `agf savings` — economia cumulativa (ledger real, cached tokens contabilizados).
- `agf calibrate` — calibra o limiar do portão RAG por score×saved.

### Provider & Tier Routing (3º pilar — a maior alavanca de CUSTO)

A _mesma_ chamada custa 10–100× menos no provider/modelo certo. Roteie por custo **antes** de gastar:

| Comando                              | Quando usar                                           | Ganho                                   |
| ------------------------------------ | ----------------------------------------------------- | --------------------------------------- |
| `agf doctor --providers`             | Início de sessão — ver quais providers há no env      | Evita escolher um provider sem chave    |
| `agf provider use <id>`              | Escolher por onde a chamada LLM vai (qualquer agente) | Troca o gateway sem MCP                 |
| `--pin <model>` (em `run`/`deliver`) | Fixar um modelo barato p/ a task                      | Ex.: `--pin deepseek/deepseek-v4-flash` |
| tier-router (automático)             | Deixe o agf escolher: cheap→build→frontier            | Modelo proporcional à complexidade      |
| `agf eval --models <ids> --live`     | Decidir o melhor custo-por-sucesso                    | Scorecard resolve% × $                  |

> **Regra:** tarefa trivial/mecânica → tier cheap (deepseek-v4-flash); build → llama-4-maverick; só o que exige raciocínio profundo → frontier. Nunca queime um modelo frontier num lint/rename.

### Levers de Economia (opt-in, bio/matemáticas — default OFF)

- `agf economy list` — lista cada lever com `enabled` + tokens `saved` cumulativos.
- `agf economy on <lever>` / `agf economy off <lever>` — liga/desliga (entra no `economy_lever_ledger`).
- Catálogo (fundamentado em papers): `memory_salience` (ACT-R), `ncd_dedup` (Kolmogorov/NCD), `forage_stop` (MVT de Charnov), `budget_kleiber` (lei de Kleiber 3/4), `heat_kernel` (difusão), `mdl_select` (MDL de Rissanen).

### Levers automáticas do gateway (GRÁTIS — agem sozinhas, sem comando)

Já operam em toda chamada LLM via agf; o agente não precisa acionar, só **saber que existem** e preferir o caminho agf:

- **diff-edits** — emite só a região alterada, não o arquivo todo.
- **repo-map ranqueado por PageRank** (~1k tok) — mapa do repo em vez de despejar arquivos.
- **lossy-gate** — auto-reverte se a compressão quebra o sentido.
- **content-router / SmartCrusher** — comprime arrays JSON homogêneos + AST de código.
- **CCR reversível** — cacheia o original + marcador `⟨ccr:hash⟩`; resgate com `agf retrieve <hash>`.
- **AAAK + retry com feedback compacto** — menos reprocessamento.

> Cada economia entra no `llm_call_ledger`/`economy_lever_ledger` → visível em `agf metrics --economy-report`, `agf savings` e na aba **Economy** da web (`agf dashboard`).

### Exemplos Práticos (cópie e cole)

```bash
# Puxar próxima task com projeção
agf next --select data.node.id,data.node.title

# Contexto compacto de task
agf context node_abc123 --compressed

# Query com projeção
agf query --status ready --select data[].id,data[].title

# Composição nativa (sem shell: nada de $(), &&, |, /tmp) — encadeia no próprio agf
agf exec chain "next --select data.node.id; context <id> --compressed"

# Comprimir output de ferramenta EXTERNA (grep/test/build) — nunca o do próprio agf
agf compress test src/tests/foo.test.ts
```

### Anti-Padrões de Economia

- ❌ `agf query` sem `--select` → gera JSON completo
- ❌ `agf context` sem `--compressed` → gera contexto pesado
- ❌ `agf next` sem `--select` → gera envelope completo
- ❌ Shell `&&` ao invés de `agf exec chain`
- ❌ `cat` + `grep` ao invés de `agf compress`
- ❌ Re-ler arquivos no contexto ao invés de `agf brief <id>` para delegar
- ❌ Paginar `--help` ao invés de `agf retrieve-command "<intenção>"`
- ❌ Rodar tarefa trivial num modelo frontier → roteie p/ tier cheap (`agf provider use` / `--pin`)
- ❌ Gerar do zero o que `agf montar-output` (RAG-OUT) entrega como scaffold pronto
- ❌ Ignorar `agf metrics --simulate` antes de um lote caro (não sabe qual provider é mais barato)

---

## XP Principles

1. **TDD mandatory** — Teste antes do código. Sem teste = sem implementação.
2. **Anti-one-shot** — Nunca gere sistemas inteiros em um prompt. Decomponha em tasks atômicas.
3. **Atomic decomposition** — Cada task deve ser completável em ≤2h.
4. **Code detachment** — Se a IA errou, explique o erro via prompt. Nunca edite manualmente.
5. **Pull, not Push** — Usar `agf next` para puxar a próxima task (pull system).

---

## Flow Principles (Lean + TOC)

- **WIP = 1** — Um agente, uma task ativa.
- **Bottleneck first** — Se VALIDATE acumula, parar de implementar e validar.
- **Eliminar desperdício**: overproduction, waiting, overprocessing, defects.

---

## Harness Engineering

Agent Readiness Score (0-100). 8 dimensões: Type Coverage (25%), Test Coverage (25%), Architecture Fitness (15%), Docs Coverage (10%), Naming Clarity (10%), Error Handling (5%), Context Density (5%), Provenance Coverage (5%).

Grades: A ≥ 85, B ≥ 70, C ≥ 55, D < 55.

---

## Error Recovery

- **DoD gate fails:** Corrigir checks com falha → re-run `agf check <id>` → `agf done <id>`
- **Missing node:** Criar via `agf node add` ANTES de codar
- **Test failures:** Diagnosticar root cause, nunca pular testes
- **Blocked task:** Resolver blockers ou `agf next` para a próxima desbloqueada
