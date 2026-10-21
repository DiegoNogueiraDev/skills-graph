---
name: agf-speed-drain
description: "Use when the goal is raw delivery speed — drenar o backlog do agf o mais rápido possível, uma task na main a cada 2-3 minutos, ciclo completo (next → TDD → check → done → commit → merge). Troca investigação profunda e suíte completa por escopo mínimo: só o arquivo tocado, nunca shell bloqueante sem log, nunca test:blast/npm test em primeiro plano. Use em qualquer projeto com workflow-graph/graph.db quando o pedido for 'rápido', 'o mais rápido possível', 'drenar backlog', 'entregar na main agora', ou quando sessões anteriores estão travando em gates lentos ou cerimônia de merge. NÃO use para task L/XL, mudança em store/gateway/segurança, ou quando o Dono pediu profundidade/robustez (aí é graph-builder-leafcutter). Triggers — agf-speed-drain, drenagem rápida, ciclo rápido, entrega rápida, entregar rápido na main, speed drain."
triggers:
  - agf-speed-drain
  - speed drain
  - drenagem rápida
  - ciclo rápido
  - entrega rápida
  - entregar rápido
version: 1.0.0
requires_agf: '>=0.27.0'
author: Diego Nogueira
date: 2026-10-21
---

# agf-speed-drain — uma task na main a cada 2-3 minutos

Nasceu de uma sessão onde o ciclo normal (`agf ant merge` com revisor, `test:blast` em
primeiro plano, lint de repo inteiro, retries de `NO_REVIEW_VERDICT`) levava 1-2 minutos
só nos gates, por task — e travava de vez em `self-approval` quando a mesma sessão que
implementava tentava também aprovar. Esta skill troca profundidade por velocidade: é o
modo "dreno" para quando a prioridade é throughput, não robustez.

Quando a task for L/XL, tocar store/gateway/segurança, ou o Dono pedir qualidade/robustez
explicitamente, pare e use `graph-builder-leafcutter` (ciclo completo) em vez desta.

## Regra de ouro: nunca shell silencioso e longo

Todo comando que pode passar de ~15s roda em background (`run_in_background: true` ou
`&` com log em arquivo) — nunca um `sleep N && cat` bloqueante, nunca esperar um gate de
60-100s em primeiro plano sem fazer outra coisa enquanto isso. Prepare a próxima task
(leia o próximo node, escreva o próximo teste) enquanto o gate da anterior roda atrás.
Para esperar de verdade, use Monitor com um loop de `until`, nunca `sleep` encadeado.

## 1. Escolha a task certa pro modo rápido

```bash
agf next --agent <id> --peek          # espia sem reivindicar
```

Pegue só XS/S com AC testável e sem dependência em store/gateway/segurança. Se o peek
devolver L/XL ou algo ambíguo, pule para a próxima com `--scope` ou registre `blocked` e
siga — não gaste os 2-3 minutos investigando o que não serve pro dreno.

```bash
agf next --agent <id>                 # agora reivindica de verdade
agf node status <id> in_progress
```

## 2. Contexto mínimo, nunca dump

```bash
agf context <id> --select data.summary,data.acceptanceCriteria,data.files
```

Nunca `agf node show` sem `--select`, nunca ler o arquivo inteiro se `grep`/`graft`
resolve em uma linha. Se o node já tem `implementationFiles`/`testFiles` declarados,
confie neles — não releia o módulo inteiro pra confirmar o óbvio.

## 3. TDD de escopo cirúrgico

- Um teste, o menor que prova o AC. RED primeiro, confirmado com o arquivo isolado:
  ```bash
  npx vitest run --project=node <arquivo.test.ts>   # 1 worker, 1 arquivo, nunca a suíte
  ```
- Código mínimo pro GREEN. Sem refactor-pass separado a menos que seja 1 linha óbvia.
- Nunca rode `npm test`, `npm run test:all`, `agf harness` ou a suíte completa no modo
  rápido — isso é tarefa do revisor/CI, não de quem está drenando.

## 4. Gate de task, em background

```bash
npm run test:blast > /tmp/blast-<id>.log 2>&1 &     # background, nunca em primeiro plano
```
Enquanto isso, rode typecheck/lint **só dos arquivos tocados**, nunca do repo inteiro:
```bash
npx tsc --noEmit <arquivos-tocados>      # ou o alias do projeto pra typecheck incremental
npx eslint <arquivos-tocados>
```
Só depois confira o resultado do blast em background (Monitor ou leitura do log) antes
de seguir pro `check`.

## 5. Check + prova mínima

```bash
agf check <id>
```
Prova no modo do consumidor: **um comando, uma linha**, nunca um script de cenário
elaborado. O objetivo é mostrar o delta real (base vs HEAD), não documentar o feature.

```bash
agf node status <id> done
```

## 6. Commit e merge sem cerimônia

Em sessão solo (sem colônia ativa, ou com autorização do Dono pra esta rodada de dreno):
commit direto, um commit, mensagem curta citando o node id:
```bash
git add <arquivos-tocados-só>
git commit -m "fix(<escopo>): <resumo> (<node_id>)"
```

Evite a cerimônia completa de `agf ant merge` quando está drenando sozinho: ela existe
pra colônia com revisor separado e pode travar em `NO_REVIEW_VERDICT` (nós citados sem
veredito) ou em `self-approval` (a mesma sessão não pode aprovar o próprio trabalho).
Se precisar passar por ela mesmo assim, registre o veredito ANTES de tentar o merge pra
não gastar um round-trip:
```bash
agf ant verdict <node_id> APROVADO --reason "<1 linha>"
```
e se o merge citar outro node sem veredito, aprove e repita — mas isso é sinal de que
o modo rápido devia era commitar direto, não brigar com a ceremônia.

Push para main: só com confirmação do Dono a cada rodada de dreno (não a cada task —
bata um lote de N tasks e confirme uma vez), salvo autorização explícita de sessão
contínua.

## 7. Loop

Volte ao passo 1 imediatamente. Não pare pra narrar cada task — reporte em lote a cada
~5 tasks ou a cada poucos minutos: quantas done, quantas blocked e por quê, tempo médio.

## Sinais de que o modo rápido não serve mais

- Lint ou blast started growing warnings (`LINT_WARNINGS_GREW`) — branch desatualizado
  ou mudança não tão cirúrgica quanto parecia. Pare, volte pro modo normal nessa task.
- Gate pedindo veredito de nó que você não reconhece — branch carrega histórico alheio;
  não é mais uma task isolada de 2-3 minutos.
- Duas rodadas seguidas de retry no merge — pare de tentar forçar, commit direto ou peça
  pro Dono decidir.
