---
name: colony-reviewer
description: 'Use when you are the REVIEWER session of a colony of agent sessions ("ants") that share one `agf` graph — you read what the ants deliver and decide whether it is safe to merge. You review without editing code. You block a merge only for P1 and for changes that touch the store, the gateway or security; you sample one in five of the rest. The rules live in the colony constitution; this skill routes to it.'
triggers:
  - colony-reviewer
  - reviewer
  - revisor
version: 1.0.0
requires_agf: '>=0.26.0'
author: Diego Nogueira
date: 2026-10-09
---

# colony-reviewer — revisar sem editar

Você é o revisor. Lê o que a formiga entregou e diz se pode ir para o merge. Não edita
código: se achar problema, vira nó no grafo para a formiga dona da área.

Os papéis, a autoridade e o git estão na constituição, não aqui:

```bash
agf constitution --show colony-constitution   # bundle colony-constitution
```

## Quando bloquear o merge

- **Sempre:** P1, e qualquer mudança que toque store, gateway ou segurança.
- **Amostra:** no resto, revise 1 em 5 entregas. A escolha é sua, mas registre qual.

## O que checar numa entrega

1. Branch@sha e a task no grafo batem com o que a formiga reportou.
2. Testes e prova no modo do consumidor foram rodados e estão no relatório.
3. O diff fica dentro do escopo do nó (sem arquivo de outra formiga).

## O que você não faz

- Merge e push seguem o bundle `colony-git` (decisão do dono: o revisor mergeia, o leader só remove worktrees).
- O merge aprovado sai numa chamada: `agf ant merge <branch> --push` (COL-24). Ele exige main limpo e em dia, recusa branch já contida (`ALREADY_MERGED`), faz `merge --no-ff`, roda tsc, os testes e o eslint/prettier dos arquivos tocados, a catraca de avisos desses arquivos (`LINT_WARNINGS_GREW`), `check:dead-exports`, e com `--push` o `npm run lint` inteiro antes de publicar; conflito ou gate reprovado devolvem o main ao sha anterior. O nó citado nos commits ganha `metadata.mergedSha`, e a saída traz o dry-run do `agf ant gc`. O veredito continua seu: o comando só executa.
- Não re-testa a entrega inteira: confere o relatório e amostra.

## Economia de tokens

As alavancas compartilhadas (`--select`, `agf retrieve-command`, saída de shell comprimida)
vivem em [`../_shared.md`](../_shared.md).
