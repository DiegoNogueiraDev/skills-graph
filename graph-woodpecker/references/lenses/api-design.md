# Lente: api-design (contrato de superfície)

**Quando usar:** a task muda uma superfície que outro consumidor lê: o envelope JSON
dos comandos `agf`, as flags, as rotas em `src/api/routes`, ou os schemas de entrada em
`src/schemas`. Em trabalho interno que não muda contrato, esta lente não se aplica.

No agf, o contrato principal é o CLI: cada comando devolve `{ ok, data, meta }`, e
agentes lêem isso por `--select`. Trate cada campo e cada código de erro como API.

**Passos**

1. **Inventário.** Comandos novos ou alterados (`src/cli/commands/*-cmd.ts`) e rotas
   (`grep -rn "router\.\(get\|post\|put\|delete\|patch\)" src/api/routes`). Se houver
   OpenAPI, `agf parse-api <spec> --select data.endpoints` extrai endpoints e schemas.
2. **Nomes.** Caminhos REST em kebab-case, recurso no plural, sem verbo no caminho
   (o verbo é o método HTTP). Flags do CLI em kebab-case; o mesmo conceito tem o mesmo
   nome em todo comando (`--dir`, `--select`, `--limit`).
3. **Validação na borda.** Toda entrada de fora (flag, body, query, arquivo importado)
   passa por schema Zod antes de chegar ao núcleo. Conte o que não passa.
4. **Mudança quebra?** Classifique cada diff antes de decidir versão:

   | Mudança | Classe |
   |---------|--------|
   | Campo novo opcional na resposta, comando novo | aditiva, segura |
   | Remover ou renomear campo, comando ou flag | quebra, precisa de migração |
   | Trocar tipo (string → número) | quebra |
   | Parâmetro opcional passa a obrigatório | quebra |
   | Mudar código de erro ou texto que cliente compara | quebra por Hyrum |

   Comando para ver o que mudou: `git diff <base>..HEAD -- src/cli/commands src/api/routes src/schemas`.

5. **Hyrum.** Com consumidores suficientes, todo comportamento observável vira contrato:
   ordem dos campos, texto de erro, latência, campos não documentados, status code de borda,
   formato de paginação, idempotência. Cada um sem teste é dívida. Campo não documentado
   não é "seguro para mudar".
6. **Deprecação.** Anuncie → avise em tempo de chamada (campo `warnings` no envelope) →
   pare de aceitar novos dependentes → remova. Aviso que não diz o substituto não serve.

**Achados:** cada quebra vira risco, para o leader decidir a versão:

```bash
agf node add --type risk --title "API: <mudança> quebra <consumidor>" --tags api,breaking
```

Validação de spec, quando houver OpenAPI: `agf spec --validate <arquivo>`.

**Não faça:** verbo em caminho REST; parâmetro renomeado sem período de deprecação;
endpoint removido sem alternativa; "não está documentado" como licença para mudar.
