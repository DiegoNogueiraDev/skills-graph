---
name: agf-report-lead-time
description: "Use when the owner asks for the colony status report: lead time and throughput against the recorded baseline, work per front (frente), WIP per agent, merges into main, and machine load — one short report in the owner's language. Runs one deterministic script (no LLM math) and adds the verdict and the next actions. Triggers — /agf-report-lead-time, report lead time, relatório da colônia, status do time, estamos entregando mais rápido."
triggers:
  - agf-report-lead-time
  - report lead time
  - relatório da colônia
version: 1.0.0
requires_agf: '>=0.27.0'
author: Diego Nogueira
date: 2026-10-12
---

# agf-report-lead-time — o relatório da rodada para o Dono

Uma chamada, um relatório curto. Os números vêm do grafo e do git pelo script; você só
interpreta e recomenda. Nunca monte contagens à mão: elas derivam e custam tokens.

## 1. Colete

```bash
bash .agents/skills/agf-report-lead-time/scripts/report-data.sh
```

Fora do repo do agf, rode o script da cópia instalada (`~/.claude/skills/agf-report-lead-time/scripts/`).
Ele acha o grafo por `AGF_GRAPH_ROOT` ou pela raiz do git, usa o CLI do código quando o
repo é o próprio agf e o `agf` instalado nos outros projetos. Para o quadro completo
(bloqueadas e p1 por nome), complemente com `agf colony report --format markdown`.

## 2. Escreva o relatório

Na língua do Dono, nesta ordem, cada item em uma ou duas linhas:

1. **Veredito** — uma frase: entregando mais rápido ou não, e o fator contra a linha de base.
2. **Vazão** — done na última 1 h, 3 h e 24 h; done por hora contra a base (base em done por dia ÷ 24).
3. **Lead e cycle** — p50 e p90 da janela de 7 dias contra a base. A janela de 1 dia favorece
   tasks criadas e fechadas hoje: mostre-a, mas não tire o fator dela.
4. **Frentes** — tabela frente | p1 abertas | total; aponte a frente sem task em andamento.
5. **Em andamento** — agente, task, idade. Idade acima de 4 h é cobrança (constituição).
6. **Main e merges** — commits de hoje, últimos merges, branches fora do main.
7. **Carga** — load contra 2× os núcleos; acima disso, nada pesado novo.
8. **Próximas ações** — no máximo 3, cada uma com dono e comando.

## Regras

- Fator = atual ÷ base, com uma casa decimal. Sem base gravada (nó `decision` com tag
  `baseline`), diga isso e proponha gravar uma.
- Janela curta ou amostra pequena (n < 20): diga que é sinal, não prova.
- Não invente o que o script não trouxe; se uma seção sair vazia, diga que saiu vazia.
- O relatório informa; decisão de fluxo vira nó `decision` no grafo, não fica só no texto.
