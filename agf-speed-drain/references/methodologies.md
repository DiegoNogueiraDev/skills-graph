# Metodologias → comando que as materializa

Cada linha: **regra** em uma frase · **comando/campo** que a aplica · **por que** (uma linha).
Profundidade (fundamentação, papers, exemplos) fica na skill `graph-backlog-generation`
(`references/methodologies.md` dela) — consulte só quando a regra não bastar.

## Enquadrar o pedido

- **Impact Mapping + OKR** — todo épico tem Objective + 1 KR numérico. → `agf node add --type epic --description "Objective: … KR: <número>"`. Por quê: sem KR o épico entrega saída, não resultado.
- **JTBD / 5W2H** — enquadrar em 3 linhas: QUEM precisa · O QUÊ muda · MEDIDA. → texto da descrição do épico. Por quê: força o alvo antes do código.
- **Pareto 80/20** — escopar o que entrega 80% do valor; o resto vira `could`. → tag `--tags should|could`. Por quê: corta o escopo antes de decompor.
- **Cynefin** — incerteza alta → spike antes de tasks. → `agf node add --type risk --title "spike: investigar <X>"`. Por quê: não planeje o que não se conhece.

## Priorizar

- **MoSCoW** — `must` = bloqueia os outros; `should` = valor claro; `could` = desejável. → `--tags must|should|could` (uma tag, não duas).
- **WSJF (Custo do atraso ÷ tamanho)** — ordena o must por valor/tamanho. → `--priority` (1 = mais urgente) + `--size`; desempate: menor job primeiro.
- **Lean / JIT** — puxar, não empurrar; só o próximo passo fica detalhado. → `agf next` (pull), nunca `assign` em massa antes de precisar.

## Fatiar

- **User Story Mapping / Walking Skeleton** — a primeira fatia é a ponta a ponta mais fina que roda. → 1º épico = skeleton; épicos seguintes = profundidade.
- **Outside-in (consumer-surface-first)** — leaf = 1 controle na superfície (tela/comando/endpoint) provado ponta a ponta; backend só puxado por AC de superfície. → título `WIRE:`/`IMPLEMENT:` com o comportamento visível.
- **SPIDR** (Spike · Paths · Interfaces · Data · Rules) — divide história grande por eixo. → `agf decompose --apply` ou subtasks com `--parent`.
- **Distill to atomic (≤ 2-3 min)** — 1 arquivo de produção + 1 de teste, 1 comportamento observável. → `agf decompose --apply` + `agf check <id>`.

## Escrever critério de aceite

- **Example Mapping → Given-When-Then** — regra → exemplo concreto → 1 AC GWT com número/fixture. → `--ac "Given … When … Then <valor exato>"` (2-4 por leaf). Regra sem exemplo não entra no backlog.
- **Questão aberta vira risco** — pergunta sem resposta = nó `risk`, nunca lacuna silenciosa. → `agf question` ou `agf node add --type risk`.
- **Risk Matrix** — todo risco tem mitigação escrita **como AC** de uma task. → `agf node add --type risk` + `agf edge add <risk> <task> --type related_to`; a mitigação vira `--ac` da task.
- **INVEST / DoR** — AC testável, dependências prontas, arquivos declarados. → `agf gaps --severity required` + `agf check <id>` (AC score ≥ 60).
- **Definition of Done por leaf** — teste do arquivo + blast + tsc + lint + check + prova no consumidor. → `agf check <id> --tests` e `agf check <id> --consumer-proof "<cmd>"`.

## Construir

- **TDD red-first** — o teste falha antes do código; sem RED não há GREEN. → `npx vitest run --project=node <arquivo.test.ts>` com o RED confirmado; `agf tdd-score` para a aderência.
- **Mínimo que passa** (KISS/YAGNI) — nenhuma abstração sem segundo uso. → `ponytail:` no comentário quando houver atalho consciente.
- **DRY / Rule-of-Three** — ao ver o mesmo bloco pela 3ª vez, extrair. → `agf search` antes de criar função nova.
- **Expand, never recreate** — estender o módulo dono, não criar gêmeo. → `agf search "<símbolo>"` + `agf code-callers <símbolo>` antes de escrever.
- **Mikado / strangler (legado)** — tocar legado exige teste de caracterização antes. → task `FIX:`/`IMPLEMENT:` com "teste de caracterização" no primeiro AC.
- **Arquivo < 800 linhas, função < 50, sem `any`** — gate determinístico. → `agf lint-files` (ou `--staged`) + `npm run lint`.

## Fluxo e gestão

- **Little's Law / WIP = 1** — cycle time = WIP ÷ throughput; um in_progress por agente. → `agf next` recusa o 2º claim; nunca `--force`.
- **Theory of Constraints** — o gargalo manda; validar se VALIDATE acumula. → `agf bottlenecks` + `agf leadtime --window 1 --top 5`.
- **Gargalo sem ação fixa vira nó decision** — nada de gargalo sem dono. → `agf node add --type decision`.
- **Determinístico antes de LLM** — o que é regra vira gate/comando; LLM só onde não há caminho. → `agf gaps`, `agf decompose`, `agf check` (zero token).

## Segurança e robustez (sob demanda)

- **STRIDE / OWASP** — auditar quando a task toca authn/authz, I/O externo ou segredo. → skill `graph-security`; não entra no modo rápido.
- **Five Whys** — bug vira causa-raiz + teste de regressão. → skill `graph-bugs`.
- **PERT** — estimativa com otimista/provável/pessimista. → `--estimate <o>/<m>/<p>`.
- **Clean Code / SOLID** — 1 responsabilidade por arquivo, dependências injetáveis. → checar no DoD (`agf quality`), não na task.

## Arestas (semântica)

- `parent_of` / `child_of` — hierarquia épico → task → subtask.
- `depends_on` — ordem obrigatória (bloqueia o next).
- `blocks` — bloqueio explícito.
- `related_to` — contexto (risco → task que ele ameaça).
- `priority_over` — preferência sem bloqueio.
- `sequence` — ordena sem bloquear (`A sequence B` = B vem antes no next).
