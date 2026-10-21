# Mapa de comandos `agf` por fase

Referência de consulta — o SKILL.md diz *quando*; aqui está *qual comando* e *qual flag*.
Fonte da verdade: `agf <cmd> --help` (ou `agf retrieve-command "<intenção>"`). Se um
comando daqui não bater com o `--help`, o `--help` vence e esta tabela é corrigida.

No repo do agf use `node scripts/agf-fast.mjs <cmd>` (ou `npm run dev -- <cmd>`), nunca o
binário instalado. Antes do primeiro comando: `export AGF_AGENT_ID=<id>`.

Coluna **Modo rápido**: `sim` = usar no dreno · `lote` = só por épico/lote · `não` = pesado
ou cerimonial, só com pedido explícito do Dono.

## Começar

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf genesis "<ideia>"` | projeto do zero: ideia → grafo → primeiro brief | `--review` (pausa no PRD) | não |
| `agf deliver "<pedido>"` | pedido → PRD → grafo → build TDD autônomo | `--file`, `--image`, `--live`, `--pin <model>` | não (autônomo, custo) |
| `agf status` | painel: provider, modelo, cache, tokens/$ | `--select` | sim |
| `agf start` | pipeline: wake-up + next + context + in_progress | — | sim (1 chamada) |
| `agf done <id>` | pipeline: DoD + memória + done + sugere próxima | — | sim |
| `agf build` | PRD.md → grafo → decompõe → autopilot | `--live` | não |

## Planejar (pedido → backlog)

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf preflight "<tema>"` | dedupe + WIP + git: wip-conflict / duplicate-risk = PARE | `--node <id>`, `--max-behind` | sim (sempre antes) |
| `agf generate-prd "<desc>" [--import]` | PRD a partir de texto | `--import` | lote |
| `agf import-prd <arquivo>` | PRD md/pdf/html/docx → grafo | `--build-tree` | lote |
| `agf node add` | cria epic/task/subtask/risk/contract/… | `--type`, `--parent`, `--ac` (repetível), `--size`, `--estimate`, `--tags`, `--priority`, `--service-class`, `--adr` | sim |
| `agf node update <id>` | ajusta campos (sem status) | `--ac`, `--description`, `--size`, `--estimate`, `--reason` (com `--codeless`/`--base-sha`/`--allow-weak-ac`) | sim |
| `agf node show <id>` | nó + arestas | `--select data.node` | sim (sempre com `--select`) |
| `agf node status <id> <st>` | transição validada (status_flow) | — | sim |
| `agf node-phase`, `agf node-spec`, `agf node-structure` | fase, spec viva, estrutura do nó | ver `--help` | lote |
| `agf edge add <from> <to> --type <rel>` | aresta | `--type` (`depends_on`, `blocks`, `related_to`, `parent_of`, `child_of`, `priority_over`, `sequence`, …), `--reason` | sim |
| `agf edge ls` / `agf edge rm` | listar / remover aresta | `--from`, `--to` | sim |
| `agf epic` | épico (Objective + KR) | ver `--help` | sim |
| `agf okr` | KR mensurável por épico | ver `--help` | lote |
| `agf template apply` | aplica template de backlog | ver `--help` | lote |
| `agf estimate` | estimativa PERT (o/m/p) | `--estimate o/m/p` no node | lote |
| `agf sprint` / `agf kanban` | recorte da rodada / visão do fluxo | ver `--help` | lote |
| `agf risk-triage` | triagem dos nós `risk` | ver `--help` | lote |
| `agf question` | pergunta aberta → nó | ver `--help` | sim |
| `agf adr` | decisão arquitetural registrada | ver `--help` | lote |
| `agf mission` | missão/estágio (agrupa épicos) | ver `--help` | lote |
| `agf scenario` / `agf ac` / `agf verify-ac` / `agf migrate-ac` | cenários, AC, verificação e migração de AC | ver `--help` | lote |
| `agf spec --generate <tpl>` / `agf spec --validate <file>` / `agf spec-sync link <specId> <nodeId>` | spec de fase para épico de alto risco | — | não |
| `agf constitution --show colony-constitution` | princípios governantes (não restate) | — | sim (ler) |
| `agf preset --apply <nome>` | default / strict-tdd / agile-light / enterprise | — | lote |

## Qualidade do backlog (fechar lacunas)

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf decompose` | acha tasks grandes | `--apply` (M/L/XL → XS/S), `--backfill`, `--backfill-files` (+ `--dry-run`), `--width <epic>`, `--plan --goal <g>` | sim |
| `agf gaps` | lacunas de completude + `applyVia` | `--severity required`, `--kind <k>`, `--json`, `--limit` | sim (loop) |
| `agf gate <fase>` | prontidão de fase | ver `agf help` | lote |
| `agf phase` | fase atual / transição | ver `--help` | lote |
| `agf check <id>` | DoD + AC score ≥ 60 + aderência TDD | `--tests`, `--lock-tests`, `--consumer-proof "<cmd>"`, `--stub-check`, `--mutation --source <f>` (pesado) | sim (sem `--mutation`) |
| `agf brief <id>` | spec de delegação (ExecutorBrief) | `--format markdown|json|claude-prompt`, `--full` | sim |
| `agf search` / `agf query` | o que já existe (não duplicar) | `--type`, `--status`, `--select` | sim |
| `agf retrieve-command "<intenção>"` | intenção em linguagem natural → comando exato | — | sim |
| `agf harness --violations` | violações de qualidade | `--dormant` | não (pesado; só lote) |
| `agf exec chain "<cmd1>; <cmd2>"` | várias consultas em 1 round-trip | — | sim |

## Construir (TDD e fechamento)

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf next --agent <id> --peek` | espia a próxima sem reivindicar | `--scope frente-<x>` | sim |
| `agf next --agent <id>` | reivindica (WIP=1) | `--scope` | sim |
| `agf context <id> --select data.summary,data.acceptanceCriteria,data.files` | contexto mínimo | `--select` obrigatório | sim |
| `agf tdd-score` | pontuação de aderência TDD | ver `--help` | sim |
| `agf submit <id> --result '<json>'` | fecha tarefa delegada (mesmos portões do done) | `--result`, `--skip-test` | sim |
| `agf claims` / `agf claims --colony` | arquivos reivindicados (overlap) | ver `--help` | sim (antes de paralelizar) |
| `agf assign <id> <formiga>` | atribui (sem overlap de arquivo) | — | lote (colônia) |
| `agf autopilot --executor <cli>` / `--agentless` | executor headless para task XS/S | `--executor`, `--agentless`, `--simulate`, `--live` | lote (XS/S) |
| `agf ant spawn <id>` / `agf ant list` / `agf ant rm <id>` / `agf ant gc` | worktree por formiga | `gc` = dry-run por padrão | lote |
| `agf ant verdict <node> APROVADO --reason "…"` | veredito antes do merge | — | não (só colônia/revisor) |
| `agf ant merge <branch> --push` | merge do revisor (gates + push) | `--queue --train 10 --watch 2m --push` | não (colônia) |
| `agf exec`, `agf exec-run`, `agf exec-worktree`, `agf exec-supervise` | execução de tarefa em worktree isolado | ver `--help` | lote |
| `agf swarm` | enxame de agentes (paralelismo) | ver `--help` | não |
| `agf run "<prompt>"` / `agf implementer` | execução one-shot | ver `--help` | não |

## Validar e revisar

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `npm run test:blast` | testes afetados (vitest --changed) | — | lote/por task, em background |
| `npm run test:node` | suíte do épico | — | lote (promoção de épico) |
| `npm test` / `npm run test:all` / `agf harness` | suíte completa / gate pré-PR | — | **não** (só pré-PR, revisor) |
| `agf quality` | gate de qualidade 95/95 | — | lote |
| `agf lint-files` | teto de 800 linhas por arquivo | `--staged` | sim |
| `agf wire-check` / `agf wire-dormant` | código exportado sem consumidor | — | lote |
| `agf proof` | prova no modo do consumidor | — | sim (1 linha) |
| `agf review` / `agf review-crossver` | revisão de diff / cruzada | — | lote |
| `agf insights` | métricas de fluxo | `--select` | lote |
| `agf immune` / `agf suite` / `agf ci` | imunidade a regressão / suíte / CI | ver `--help` | lote |
| skill `graph-security` | OWASP/STRIDE/segredos (não é comando `agf`) | — | sob demanda |
| skill `graph-bugs` | bug + 5-Whys + teste de regressão (não é comando `agf`) | — | sob demanda |
| skills `graph-quality` / `graph-tests` / `graph-woodpecker` | qualidade / testes / hardening (não são comandos `agf`) | — | sob demanda |

## Entregar (release, handoff, deploy)

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf memory write <name>` / `read` / `list` / `search` | memória do projeto | conteúdo inline ou de arquivo | lote (HANDOFF) |
| `agf snapshot create` / `list` / `restore <id>` | snapshot do grafo | `--out <arquivo>` | lote |
| `agf adr` | registrar decisão | ver `--help` | lote |
| `agf changelog` | changelog a partir dos nós done | ver `--help` | lote |
| `agf export` | exporta o grafo/relatório | ver `--help` | lote |
| `agf release` | versão/release | ver `--help` | **só com confirmação do Dono** |
| `agf forecast` / `agf dora` | previsão / métricas DORA | ver `--help` | lote |
| `agf deps` | dependências | ver `--help` | lote |
| `agf gc` | limpeza de worktrees/branches contidos no main | `--apply` (cuidado) | com confirmação |

## Aprender e medir

| Comando | Para quê | Flag-chave | Modo rápido |
|---|---|---|---|
| `agf leadtime --window 1 --top 5` | lead time da janela | `--window`, `--top` | sim (a cada rodada) |
| `agf bottlenecks` | gargalos com ação fixa | — | sim |
| `agf retro` | retrospectiva | ver `--help` | lote (LISTENING) |
| `agf learn` / `agf learn-eval` / `agf learning` | aprendizado a partir do fluxo | ver `--help` | lote |
| `agf metrics` | tokens/$ por task e sessão | `--economy-report`, `--simulate` | lote |
| `agf savings` | economia cumulativa | `--reset` | lote |
| `agf economy list` / `on` / `off` | alavancas de economia | `--select data.levers` | lote |
| `agf compress run -- <cmd>` | compressão de saída (só CLIs sem hook) | — | sim (se hookless) |
| `agf dashboard` | painel web do grafo | — | lote |
| `agf quality` | gate 95/95 sobre `src/` (relatório do analisador traz `performanceBudgets`) | `--min-tests`, `--min-logs`, `--dir` | **não** (pesado: testes + logs; lote/pré-PR) |
| `agf insights` | relatório do analisador (`performanceBudgets`, fluxo) | `--select data.performanceBudgets` (confira o nome) | lote |
| `agf learning stats` | performance por agente (acerto, retrabalho, tempo) | ver `--help` | lote |
| `agf learning route` / `agf learning explain` | roteamento por histórico e o porquê | ver `--help` | lote |
| `agf profile resolve --model <provider/modelo>` | tier de modelo e flow do perfil | `--model`, `--dir` | sim |
| `agf bottlenecks --trend` | variação de throughput, lead time e fila de merge | `--trend` | sim |
| `agf bottlenecks --apply` | executa só as ações seguras (ex.: renice) | `--apply` | com confirmação |
| `agf leadtime --window 1 --top 5` | p50/p90 do lead time e as caudas | `--window <dias>`, `--top <n>` | sim (a cada rodada) |
| `agf colony*` / `agf assign` / `agf claims --colony` | operação da colônia | ver `agf help` | só colônia |

## Regras de uso

- Sempre `--select` em comandos que devolvem listas grandes (`node show`, `query`, `context`).
- `--json` força o envelope JSON quando o default é humano.
- Comando novo ou flag duvidosa: `agf <cmd> --help` antes de chutar. Nunca invente flag.
- Comando que grava no grafo central em produção: confirme `AGF_GRAPH_ROOT` antes (ver memória *smoke-never-migrates-live-graph*).
