---
name: agf-speed-drain
description: "Use to run a full software-delivery cycle on the agf graph at speed — from a request to tasks, subtasks, ACs and risks, then implement, test, validate, hand off and listen — with each task closed in 2-3 minutes. Covers backlog creation and enrichment (decompose, gaps, check, brief), the TDD drain loop (next → RED → GREEN → check → done → commit) and the delivery gates (gate, harness, release) by epic. Use in any project with workflow-graph/graph.db when the request is 'rápido', 'o mais rápido possível', 'entrega completa', 'decompor', 'enriquecer backlog', 'drenar backlog', 'entregar na main agora', or when earlier sessions are stuck in slow gates or merge ceremony. NÃO use for L/XL tasks, store/gateway/security changes, or when the owner asked for depth/robustness (use graph-builder-leafcutter instead). Triggers — agf-speed-drain, entrega completa, entrega rápida, drenagem rápida, ciclo rápido, enriquecer backlog, decompor, speed drain."
triggers:
  - agf-speed-drain
  - speed drain
  - entrega completa
  - entrega rápida
  - drenagem rápida
  - ciclo rápido
  - enriquecer backlog
  - decompor
version: 2.4.0
requires_agf: '>=0.27.0'
author: Diego Nogueira
date: 2026-10-21
---

# agf-speed-drain — do pedido à main, task a task em 2-3 minutos

Versão 1 cobria só o dreno (`next → TDD → check → done → commit`). Esta versão cobre o
ciclo de SWE inteiro pelo `agf`: pedido → backlog completo → enriquecimento → implementação
→ teste → validação → revisão → handoff → release → listening. A velocidade vem de três
coisas: **decompor agressivamente** (leaf = 1 arquivo de produção + 1 de teste), **nascer
enriquecido** (a task não reinvestiga nada) e **nunca bloquear em shell longo**.

Referências sob demanda (leia só quando precisar, zero custo até lá):
- `references/commands.md` — qual comando, qual flag, em qual fase.
- `references/methodologies.md` — cada metodologia em uma regra + o comando que a aplica.
- `references/node-templates.md` — moldes copiáveis de `agf node add` (épico, task, subtask, risco, contrato, decisão, bug).

Quando a task for L/XL, tocar store/gateway/segurança, ou o Dono pedir robustez explícita,
pare e use `graph-builder-leafcutter` (ciclo completo) para essa task.

## 0. Identidade e guard-rails (antes do primeiro comando)

- `export AGF_AGENT_ID=<id>` — sem identidade o `agf` não sabe quem está puxando.
- Repo do agf: `node scripts/agf-fast.mjs <cmd>` (ou `npm run dev -- <cmd>`), nunca o binário instalado.
- Sem nó no grafo = sem código. WIP = 1 por agente. Nunca `--force`.
- Comando ou flag duvidosa: `agf <cmd> --help` ou `agf retrieve-command "<intenção>"`. Nunca chute flag.
- Sem `git stash` (compartilhado entre worktrees). Commit/push/tag só com confirmação do Dono por rodada.
- Em colônia, o papel manda: formiga não faz push/merge/tag; revisor não segura implementação.
- `export`/`env`/`printenv` sem filtro imprimem segredos — nunca. Para checar variável: `echo ${VAR:+definida}`.
- Antes de cada rodada: `agf andon status`. Se `stopped` for `true`, pare e reporte o motivo ao Dono: a linha
  está parada e nada novo é escrito até o `agf andon clear`. Não contorne o andon.

## Regra de ouro: nunca shell silencioso e longo

Todo comando que pode passar de ~15 s roda em background (`run_in_background: true` ou
`&` com log em arquivo). Nunca `sleep N && cat` bloqueante. Enquanto um gate roda, leia a
próxima task e escreva o RED dela. Para esperar de verdade, use Monitor com `until`.

## Orçamento de tempo

| Etapa | Alvo | Estourou |
|---|---|---|
| Intake do pedido (Fase A + B, pedido pequeno) | ≤ 3 min | dividir o pedido em épicos menores |
| Contexto da task | 15 s | ler só `--select` |
| RED | 30 s | AC vago → volta à Fase B |
| GREEN | 45 s | task grande → `agf decompose --apply` |
| Gates (blast, tsc, lint em background) | 45 s | rodar só o arquivo tocado |
| `check` + `done` + commit | 30 s | — |
| **Total por task** | **≈ 2:45** | 2 estouros seguidos → `blocked` com motivo e decompor |

O alvo de 2-3 min é **por task**. Pedido grande: cada leaf cabe no alvo; o intake cresce com o pedido.

## Fase A — Intake e backlog do pedido (plan-only, sem código)

Use quando o pedido não tem épico/tasks prontos. Se já existe backlog pronto, pule para a Fase C.
Se `agf bottlenecks` mostrar `queue-inflow` ou `done-unmerged`, drene a fila antes de criar tasks novas.

1. **Investigue antes de planejar** (não duplique):
   ```bash
   agf preflight "<tema>"                       # wip-conflict / duplicate-risk → PARE
   agf stats --select data.byStatus
   agf query --type epic --status backlog --select 'data[].{id,title}'
   agf gaps --severity required --json          # já existe backlog pronto? → Fase C
   ```
2. **Enquadre em 3 linhas**: QUEM precisa · O QUÊ muda para ele · MEDIDA (1 KR com número).
3. **Crie a estrutura** (`references/node-templates.md` tem os moldes):
   - `agf generate-prd "<pedido>" --import` ou `agf import-prd <arquivo>` para pedidos longos;
   - ou direto: `agf node add --type epic` (Objective + KR) → `requirement` (NFR mensurável) → `task` → `subtask` (`--parent`).
   - Antes de cada `agf node add`, rode `agf search "<termo do título>"`. `DUPLICATE_RISK` significa que o nó já
     existe: use o existente. Repetição intencional só com `--adr <decisionId>`, apontando um nó `decision` que a justifique. Nunca force.
   - `node add` com 2+ `--ac` numa task M já a decompõe em filhas cujo título é o texto do AC. Renomeie cada filha logo
     em seguida: `agf node update <childId> --title "IMPLEMENT: <resultado>"`. Os ids vêm em `data.decomposition.childIds`.
4. **Checklist de completude — todo pedido sai com isto**:
   - 1 épico com Objective + KR numérico
   - ≥ 1 `requirement` ligado a ele (NFR com limite: latência, cobertura, tamanho)
   - tasks XS/S; subtasks onde a task é M ou maior
   - 2-4 ACs Given-When-Then por leaf, cada um com valor exato (número, booleano, string, código)
   - ≥ 1 desses ACs é de erro ou limite (entrada inválida, vazio, limite excedido). Sem ele, `gaps` aponta `missing_edge_case` depois e custa um ciclo extra.
   - ≥ 1 `risk` por épico, com a mitigação escrita como AC de uma task
   - `constraint` no épico (arquivo < 800 linhas, função < 50, sem `any`)
   - `contract` em toda fronteira entre módulos
   - `decision` para cada escolha de rumo (o agente segue sem perguntar)
   - `depends_on` para ordem; arquivos de implementação e teste declarados
5. **Fatie outside-in**: a leaf é um controle visível (tela, comando, endpoint) provado ponta a ponta. Backend só entra como leaf puxada por um AC de superfície que falha sem ele.

## Fase B — Enriquecer e decompor até caber em 2-3 min (determinístico, ~0 token)

1. **Decompor**:
   ```bash
   agf decompose                                 # acha tasks grandes
   agf decompose --apply                         # M/L/XL → filhas XS/S
   agf decompose --backfill                      # preenche descrição/arquivos das filhas
   agf decompose --backfill-files --dry-run      # revisa quais arquivos seriam declarados
   agf decompose --backfill-files                # grava
   agf decompose --width <epicId>                # largura paralela (arquivo comum = sequencial)
   ```
2. **Fechar lacunas em loop** até `ready: true`:
   ```bash
   agf gaps --severity required --json           # lista com applyVia
   # rodar o applyVia de cada gap (ex.: agf edge add … / agf node update … --ac "…")
   agf gaps --severity required --json           # repetir até ready:true
   ```
   Kinds que mais importam neste ciclo: `non_atomic_task`, `weak_ac_testability`,
   `ac_count_out_of_range`, `missing_edge_case`, `missing_nfr`, `risk_without_mitigation_ac`,
   `traceability_break`, `narrow_test`, `broad_test`, `phantom_pointer`.
3. **Validar cada leaf**: `agf check <id>` (AC score ≥ 60; senão reescreva o AC com número/fixture).
   Para delegar: `agf brief <id> --format markdown`.
4. **Critério de "cabe em 3 min"**: 1 arquivo de produção + 1 de teste, 1 comportamento
   observável, zero decisão de design aberta. Se falhar, divida (SPIDR: Spike · Paths ·
   Interfaces · Data · Rules). Dúvida de design vira `decision` ou `risk`, nunca fica implícita.
5. **Mini-critic** (3 varreduras, cada uma com um comando; achado sem saída de ferramenta é descartado):
   - cada seta do fluxo `A → B → C` tem um épico/task dono? (`agf query`, `agf edge ls --from <id>`)
   - cada consumidor do `contract` tem os campos que precisa? (`agf node show <contract-id> --select data.node`)
   - qual a implementação preguiçosa que ainda passaria no AC? → vira AC mais forte ou `risk`.

## Fase C — Dreno (uma task a cada 2-3 min)

### C1. Escolher

```bash
agf next --agent "$AGF_AGENT_ID" --peek      # espia sem reivindicar
agf next --agent "$AGF_AGENT_ID"             # reivindica (WIP=1)
agf node update <id> --implementation-files <src/…> --test-files <src/tests/…>   # ANTES de editar
agf node status <id> in_progress
```

Pegue só XS/S com AC testável, sem dependência em store/gateway/segurança. L/XL ou ambíguo:
`agf node status <id> blocked` com motivo e siga.

Declare o escopo **antes** da primeira edição: sem `--implementation-files` o `in_progress` sai
com `SCOPE_UNDECLARED`, e sem `--test-files` o `check` reprova `has_test_files`. Os caminhos
são soletrados, um por argumento (sem glob).

### C2. Contexto mínimo

```bash
agf context <id> --select data.summary,data.acceptanceCriteria,data.files
```

Nunca `agf node show` sem `--select`. Se `implementationFiles`/`testFiles` estão declarados,
confie neles e não releia o módulo inteiro.

### C3. RED → GREEN

- Um teste, o menor que prova o AC. Rode só o arquivo:
  ```bash
  node scripts/heavy-slot.mjs -- npx vitest run --project=node src/tests/<stem>.test.ts    # 1 worker, pelo semáforo
  ```
  Vitest direto, sem `scripts/heavy-slot.mjs`, é o `heavy-slot-bypass` que o `agf bottlenecks` aponta.
- Confirme o RED (falha pelo motivo certo). Código mínimo para GREEN. Refactor só se for 1 linha óbvia.
- Sem `npm test`, `npm run test:all`, `agf harness` ou suíte completa no dreno.

### C4. Gates em background

```bash
npm run test:blast > "$TMPDIR/blast-<id>.log" 2>&1 &     # background; já passa pelo semáforo
node scripts/heavy-slot.mjs -- npx tsc --noEmit            # typecheck pelo semáforo (mesmo escopo de antes)
npx eslint <arquivos-tocados>                             # só os arquivos tocados
```

Vitest e tsc sem `scripts/heavy-slot.mjs` ficam fora do limite de slots da máquina e causam o gargalo
`heavy-slot-bypass`. Nunca chame direto.

Enquanto o blast roda: leia a próxima task e escreva o RED dela. Antes do `check`, confira o log.
Blast com aviso novo (`LINT_WARNINGS_GREW`) = mudança não tão cirúrgica; volte ao modo normal nessa task.

### C5. Check, prova e fechamento

```bash
agf check <id> --tests                        # DoD + aderência TDD (+ teste real, se quiser recibo)
agf check <id> --consumer-proof "<comando de 1 linha>"   # base vs HEAD: exit 0 + saída diferente
agf node status <id> done
```

Prova no modo do consumidor: **um comando, uma linha**, o delta real. Sem script de cenário elaborado.
Se a task não tem efeito observável, ela espera (`blocked`) a task que a torna observável — não fecha com prova inventada.

### C6. Commit

Sessão solo, com autorização da rodada: commit direto, mensagem curta com o node id.
```bash
git add <arquivos-tocados-só>
git commit -m "fix(<escopo>): <resumo> (<node_id>)"
```
Em colônia: commit só na branch `ant/*` da formiga e aviso ao leader com `branch@sha`. Não passe por `agf ant merge` se você for o único agente (a cerimônia trava em `NO_REVIEW_VERDICT` e `self-approval`); se for obrigatório, registre o veredito antes: `agf ant verdict <node_id> APROVADO --reason "<1 linha>"`.

### C7. Paralelismo (sem overlap)

- Enquanto o gate da task N roda, a N+1 avança até o RED.
- Tasks independentes (sem overlap de arquivo e sem `depends_on` entre si) rodam em lote de swarm:
  `agf swarm init --max 3 --topology hierarchical` → `agf swarm start <sessionId>` → `agf swarm batch -k 3`
  reivindica o conjunto independente. Antes de subir o `k`, prove o ganho com `agf swarm bench` (serial vs batch).
- Tasks XS/S sem overlap de arquivo podem ir a executor: `agf claims` (confirme sem overlap) → `agf autopilot --agentless` (XS com AC testável) ou `agf autopilot --executor <cli> --model claude-haiku-5-5` → worktree próprio via `agf ant spawn <id>`. Executor Claude é **sempre** `claude-haiku-5-5`, passado explícito via `--model`; nunca herde o modelo padrão da sessão.
- Executor não faz push nem merge. O retorno passa pelos mesmos gates.

### C8. Loop

Volte a C1 imediatamente. Reporte em lote (~5 tasks ou poucos minutos): quantas done, blocked e por quê, tempo médio.

## Fase D — Fechar o ciclo de SWE (por épico ou lote, não por task)

Rode quando o épico (ou a rodada) estiver com todas as tasks `done`.

1. **VALIDATE**
   - `agf gate` (prontidão da fase) e `npm run test:node` (suíte do épico, em background).
   - `agf lint-files` (teto de 800 linhas) e `agf wire-check` (código exportado sem consumidor).
   - `agf harness --violations` e `npm test` **só em pré-PR** — pesados, reservados ao revisor/CI.
2. **REVIEW**
   - `agf review` (ou `agf review crossver`) no diff do épico; `agf insights` para métricas do fluxo.
   - Especialistas sob demanda (skills): `graph-security` se tocou authn/segredo/I-O externo; `graph-bugs` para bug com causa-raiz; `graph-quality` para dívida; `graph-tests` para cobertura de caminhos de erro.
3. **HANDOFF**
   - `agf memory write <nome>` com o que foi decidido e por quê.
   - `agf adr` para cada `decision` que virou arquitetura.
   - `agf changelog` a partir dos nós done; `agf snapshot create --out <arquivo>` antes de mudança grande.
4. **DEPLOY** (sempre com confirmação do Dono)
   - `agf release` / `agf forecast` / `agf dora`. Tag, push e publicação não saem sem confirmação explícita.
5. **LISTENING**
   - Achados viram nós (`risk`, `bug`, `task`) para o próximo ciclo: `agf node add`.
   - `agf retro`, `agf leadtime --window 1 --top 5`, `agf bottlenecks`.

## Performance (três alvos: código, agentes, fluxo)

Performance aqui tem três alvos distintos. Cada um tem comando próprio; não misture.

**1. Performance do código (budgets)** — o analisador calcula `performanceBudgets` no relatório
(`src/core/analyzer/performance-budget-check.ts`, montado em `analyzer-report.ts`).
- `agf quality` — gate 95/95 sobre `src/`; **pesado** (roda testes + logs), só em lote ou pré-PR, nunca no dreno.
- `agf insights` — relatório do analisador com a chave `performanceBudgets` (confira o nome no `--select` antes de confiar).
- Budget violado vira task com AC de número (ex.: "p95 ≤ 300 ms") e nó `requirement` ligado a ela. Medição roda **uma vez**, pelo semáforo; o número vai para o nó.

**2. Performance dos agentes (quem entrega melhor)** — aprendizado persistido por agente.
- `agf learning stats` — performance por agente (acerto, retrabalho, tempo).
- `agf learning route` / `agf learning explain` — roteamento baseado no histórico; `explain` mostra o porquê.
- `agf profile resolve --model <provider/modelo>` — tier de modelo e flow do perfil; use para escolher o modelo barato do executor.

**3. Performance do fluxo (quanto tempo uma task leva)** — é o alvo deste skill (2-3 min por task).
- `agf leadtime --window 1 --top 5` — p50/p90 do lead time e as caudas; rode a cada rodada.
- `agf bottlenecks` — gargalos com ação fixa; `agf bottlenecks --trend` (variação de throughput e lead time); `agf bottlenecks --apply` executa sozinho só as ações seguras.
- `agf metrics` e `agf savings` — tokens e custo por task (custo também é performance de entrega).
- `agf forecast` e `agf dora` — previsão e métricas DORA, na fase DEPLOY.

Leitura da medição: lead time p90 acima de 3 min = a cauda manda; abra `agf leadtime --top 5` e
decomponha o item da cauda antes de qualquer outra coisa. Gargalo sem ação fixa vira nó `decision`.

## Gestão da entrega (placar a cada ~5 tasks)

Comandos: `agf stats`, `agf leadtime`, `agf bottlenecks`, `agf metrics` (ver Performance, item 3).
Gargalo com ação fixa: fazer a ação. Gargalo sem ação fixa: `agf node add --type decision`
com o custo se errado. Task `in_progress` há mais de 4 h: cobra o dono ou reatribui.

## Sinais de que o modo rápido não serve mais

- Task estoura 3 min duas vezes → decompor (`agf decompose --apply`) ou `blocked` com motivo.
- AC não observável (`check` < 60) → volta à Fase B, não entra no dreno.
- `LINT_WARNINGS_GREW` ou gate pedindo veredito de nó desconhecido → branch carrega histórico alheio; não é task isolada.
- Duas rodadas seguidas de retry no merge → pare; commit direto ou o Dono decide.
- Task de L/XL, store/gateway/segurança, ou pedido de robustez → `graph-builder-leafcutter`.

## Auto-melhoria da rodada

A regra de auto-melhoria mora numa só fonte: a seção 9 de `agf-mass-delivery/SKILL.md` (duas rodadas
seguidas, uma mudança por rodada, snapshot, validate, rollback). Esta skill só aponta para ela. Não copie a regra aqui.

Ao fim de cada rodada de dreno, meça:
```bash
AGF_SKILL_DIR=/Users/diegonogueira/.claude/skills/agf-speed-drain \
  node /Users/diegonogueira/.claude/skills/agf-mass-delivery/scripts/loop.mjs monitor
```
Se `verdict` for `act`, siga a seção 9 da outra skill. Mudanças nesta skill passam pelo mesmo ciclo:
`snapshot` antes, `validate` depois (mesmo prefixo `AGF_SKILL_DIR=…`), `rollback <N>` se reprovar.
As seções protegidas desta skill são `Quando parar e perguntar ao Dono`, `Regra de ouro` e `Performance (três alvos`.

## Quando parar e perguntar ao Dono (só estes 4)

1. Ação irreversível ou destrutiva (apagar, reescrever histórico, `gc --apply`).
2. Segurança ou credenciais.
3. Efeito fora do worktree além do que o papel permite (push, merge, tag, publicação, banco remoto).
4. Quando toda saída possível é chute.

Fora disso: decida, registre como nó `decision` (o quê, por quê, custo se errado) e siga.
