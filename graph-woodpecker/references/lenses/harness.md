# Lente: harness (agent-readiness e órfãos)

**Quando usar:** antes de fechar uma task de qualidade, antes de deploy (`agf gate deploy`
exige grade B, score ≥ 70), ou quando o `agf harness --violations` do HUNT apontar uma
dimensão baixa. O HUNT já roda o scan; esta lente diz o que fazer com cada resultado.

**Pesos e dimensões** vêm do scorer vivo, `src/core/harness/harnessability-score.ts`.
Não copie números daqui: eles mudaram mais de uma vez.

| Dimensão | Quando estiver baixa |
|----------|----------------------|
| types | tipos de retorno em funções públicas; `as unknown as` esconde problema, confira com `tsc --noEmit` |
| tests | falta `src/tests/<módulo>.test.ts` com o basename do módulo. Um teste fraco não passa no TDD, então escreva teste de verdade |
| fitness | `core/` importando camada de borda (regra de dependências em `.claude/rules/architecture.md`); ciclo de import; arquivo > 800 linhas |
| docs | JSDoc só onde o porquê não é óbvio. Docstring que repete o nome não ajuda o próximo agente |
| naming | `data`, `result`, `temp`, `res`; nome de uma letra fora de laço curto |
| errors | `throw new Error` cru → erro tipado de `utils/errors.ts`; `catch {}` vazio → logar ou relançar |
| context | JSDoc ausente em export (mesma regra de docs) |
| provenance | mudança sem atribuição; corrija a convenção, não só o histórico |
| connectivity | símbolo exportado sem consumidor de produção. Veja a triagem abaixo antes de codar |

**Grade:** A ≥ 85 manter · B ≥ 70 abrir task para a dimensão mais baixa · C ≥ 55 bloquear
entrega até uma dimensão subir · D < 55 refatorar antes de qualquer feature.

**Órfãos (`agf harness --dormant`).** Sinal bruto, não backlog. Antes de escrever uma
linha, classifique cada um:

1. **Falso positivo.** Um teste real importa e exercita o símbolo. Feche sem código.
2. **Superado, não incompleto.** Um irmão já resolve, e é o que está ligado. Leia a lógica
   dos dois: o órfão pode ter o conserto que o ligado não tem (ver a lente de bugs).
3. **Metade de épico.** O mecanismo existe, mas o consumidor nomeado nunca foi feito.
   Abra task de planejamento; não invente o consumidor inline.
4. **Família scaffoldada.** O mesmo formato se repete em vários diretórios. Nomeie a
   família uma vez, não abra N achados.
5. **Sobrepõe sistema ligado.** Um motor genérico que duplica um checker ativo. Ligar
   confunde o usuário. Ache a capacidade que diferencia, se houver, e escope só ela.
6. **Fio seguro.** Puro, correto, com ponto natural de chamada. Só aqui se escreve código,
   com TDD como qualquer feature.

Achado de 1 a 5 é achado válido: registre com a evidência (qual irmão, qual família, qual
sobreposição). "Investigado, não ficou claro" não serve.

**Não faça:** teste falso para subir o score de testes; ligar órfão sem triagem; copiar
pesos ou contagens para outro doc; tratar o irmão ligado como correto sem ler os dois.
