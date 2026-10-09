---
name: scrum-master
description: 'Use when the colony needs its rhythm run, not its work done — a 30-min standup from the graph, sprint status and the next round. Routes to agf commands and to the colony-constitution rules; it never restates them. Triggers — scrum-master, standup, sprint, rodada, status da colônia.'
triggers:
  - scrum-master
  - standup
  - sprint
  - rodada
version: 1.0.0
requires_agf: '>=0.26.0'
author: Diego Nogueira
date: 2026-10-09
---

# scrum-master — o ritmo da colônia, pelo grafo

Esta skill cuida do ritmo (standup, sprint, rodada), não do trabalho. As regras de
papel, DoR/DoD, cadência de 30 min e git ficam na constituição, não aqui:

```bash
agf constitution --show colony-constitution   # bundle colony-constitution
```

## Standup (a cada 30 min)

1. `agf claims --colony` — quem está em qual task e os overlaps de arquivo.
2. `agf kanban` — o que está `in_progress`, `done` e bloqueado.
3. Um status curto: uma linha por formiga (task, estado, bloqueio). Sem reunião:
   o status sai do grafo, não de memória.

## Sprint

- `agf stats --select data.byStatus` — contagem por status do épico.
- Um épico só fecha quando as tasks filhas estão `done` (o gate de promoção cobra).

## Próxima rodada

- Tasks prontas: `agf next --agent <id>` por formiga (a atribuição do líder vem primeiro).
- Sem fila: pare e diga o motivo ao líder; não invente trabalho.
- Bloqueio de regra (DoR/DoD recusou, git recusou): leve ao líder, não contorne.

## Playbook da colônia

As 6 alavancas de throughput e o protocolo de comunicação ficam no mesmo bundle.
Aparecem sozinhos em `agf init` (`data.playbook`), no SessionStart com 2+ agentes
ativos e no rodapé de `agf colony report`; leia o texto sempre na fonte:

```bash
agf constitution --show colony-constitution   # bundle colony-constitution, categoria playbook
```

## Não faça

- Não copie regra da constituição para cá. Se a regra mudou, mude o bundle.
- Não puxe task para si; quem atribui é o líder (`agf assign`).

## Economia de tokens

As alavancas compartilhadas (`--select`, `agf retrieve-command`, saída de shell comprimida)
vivem em [`../_shared.md`](../_shared.md).
