# Moldes de nó (`agf node add`) prontos para copiar

Substitua os `<…>`. Todos os moldes passam em `agf check` se o AC tiver valor observável.
Regras de caminho (valem para todo molde): **soletre cada arquivo**, nunca glob com chaves
(`{a,b}`); **nunca coloque dois-pontos logo depois de um caminho** (`src/x.ts:` dispara
`phantom_pointer`) — escreva `EXPAND o arquivo src/x.ts — …`. Linha: `lines 337-386` em palavras separadas.

## Épico (Objective + KR)

```bash
agf node add --type epic --title "<Épico: resultado do usuário>" \
  --description "Objective: <o que muda para QUEM>. KR: <métrica com número>. Fora de escopo: <…>." \
  --tags must --priority 1
```

Depois: `agf node add --type constraint --parent <epic> --title "Guardrails: arquivo<800, fn<50, sem any" --description "…"`.

## Requisito / NFR (mensurável)

```bash
agf node add --type requirement --parent <epic> --title "NFR: <atributo> <limite>" \
  --ac "Given <cenário> When <ação> Then <valor exato, ex.: latência p95 ≤ 300 ms>"
```

Toda task que cumpre o requisito tem `agf edge add <task> <req> --type related_to` (ou `implements` se o tipo existir no `--help`).

## Task (leaf de 2-3 min)

```bash
agf node add --type task --parent <epic> --size XS --estimate 15 --tags must \
  --title "WIRE: <controle visível faz <resultado>>" \
  --description "Por quê: <1 linha>. EXPAND o arquivo <src/caminho/a.ts> — <função/símbolo a estender>. NÃO recriar <símbolo existente>." \
  --ac "Given <fixture concreta> When <ação> Then <valor exato>" \
  --ac "Given <caso de erro> When <ação> Then <código/mensagem exata>" \
  --ac "Given <fronteira> When <ação> Then <número/booleano>"
```

Teste da task: a descrição cita o arquivo de teste exato `src/tests/<stem>.test.ts` e o
fixture (`new Database(':memory:')`, stub de LLM com contador). Título: `IMPLEMENT:`,
`WIRE:`, `FIX:` ou `DOCS:`, seguido de **um** resultado.

## Subtask (quando a task é M ou maior)

```bash
agf node add --type subtask --parent <task> --size XS --title "IMPLEMENT: <parte 1 do resultado>" \
  --ac "Given … When … Then …"
```

Ou deixe `agf decompose --apply` gerar as filhas XS/S a partir de um M/L/XL.

## Risco (com mitigação em AC)

```bash
agf node add --type risk --title "Risco: <falha concreta>" \
  --description "Impacto: <…>. Probabilidade: <baixa|média|alta>. Mitigação: vira AC da task <id>."
agf edge add <risk-id> <task-id> --type related_to
```

A mitigação **precisa** aparecer como `--ac` numa task (`agf node update <task-id> --ac "…"`). Risco sem AC de mitigação é lacuna (`risk_without_mitigation_ac`).

## Contrato (fronteira entre módulos)

```bash
agf node add --type contract --title "Contrato: <nome>" \
  --description "Forma exata: { campo: tipo, … }. Origem de cada campo: <helper>@<arquivo>. Erros tipados: <lista>."
agf edge add <task-id> <contract-id> --type implements
agf edge add <consumer-id> <contract-id> --type consumes
```

## Decisão (escolha de rumo registrada)

```bash
agf node add --type decision --title "Decisão: <escolha>" \
  --description "Opções: A (…) / B (…). Escolhida: <X> porque <motivo>. Custo se errado: <…>. Reversível: <sim|não>."
```

Decisão registrada = o agente segue sem perguntar ao Dono (regra de decisão da colônia).

## Bug (achado durante o dreno)

```bash
agf node add --type bug --title "FIX: <sintoma observado>" \
  --description "Reprodução: <comando>. Causa-raiz (provada): <…>. EXPAND o arquivo <src/…>." \
  --ac "Given <reprodução> When <comando> Then <saída correta exata>"
```

## Arestas (ordem e contexto)

```bash
agf edge add <b> <a> --type depends_on --reason "B precisa de A"   # B só sai depois de A
agf edge add <task> <epic> --type parent_of                        # hierarquia, se não usou --parent
agf edge add <risk> <task> --type related_to                       # contexto
agf edge add <a> <b> --type sequence                               # ordena sem bloquear
```

## Checagem depois de criar

```bash
agf check <id>                 # AC score ≥ 60, DoR
agf gaps --severity required --json   # lacunas; rodar o applyVia de cada uma
agf brief <id> --format markdown      # spec de delegação, se for mandar a um executor
```
