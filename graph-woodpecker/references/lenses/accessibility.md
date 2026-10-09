# Lente: accessibility (WCAG 2.2 AA)

**Quando usar:** a task muda uma superfície visual com interação: o dashboard
(`src/web/dashboard`, servido por `agf dashboard`), um componente, um formulário.
Pule em código sem UI.

**Como rodar:** abra a tela do próprio worktree (`agf dashboard`) e aplique:

1. Automático: `npx @axe-core/cli <url>` (e `--rules color-contrast` para só contraste).
   Pega ~35% dos problemas: `alt` ausente, label de formulário, contraste, `lang`,
   `id` duplicado, role/ARIA inválido.
2. Manual, com teclado: Tab por todos os controles. Ordem lógica; foco visível
   (sem `outline: none` sem substituto); Escape fecha modal e devolve o foco ao gatilho;
   setas em menus, tabs e listboxes; Enter e Espaço ativam; sem armadilha de teclado
   fora de modal; modal prende o Tab.
3. Leitor de tela (VoiceOver ou NVDA): título anunciado, ordem de headings, label antes
   do campo, erro anunciado na hora, toast com `aria-live` sem roubar o foco.

**Critérios que costumam falhar e não aparecem no axe:**

| SC | Nome | Teste |
|----|------|-------|
| 2.4.11 | Focus Appearance | foco com ≥2px de perímetro e ≥3:1 contra a cor vizinha |
| 2.4.12 | Focus Not Obscured | foco não some atrás de header/footer fixo |
| 2.5.7 | Dragging Movements | todo arrastar tem alternativa de um toque/clique |
| 2.5.8 | Target Size | alvo interativo ≥24×24 CSS px (ou espaçamento) |

Contraste mínimo: texto normal 4,5:1; texto grande 3:1; componentes e foco 3:1.
Informação não pode depender só de cor (erro com ícone + cor, gráfico com padrão).

**Foco em conteúdo dinâmico:** modal abre → primeiro elemento; modal fecha → gatilho;
erro de form → primeiro erro; mudança de rota → título da página; dropdown → primeira opção.

**i18n** (só se a task adiciona texto de UI): sem string fixa no componente; formatação
por `Intl`; sem concatenação de frases; layout aguenta texto 30% maior.

**Achados:** cada falha A ou AA vira nó antes de ser corrigida, com o AC que o teste vai
afirmar:

```bash
agf node add --type bug --title "A11Y: <critério> falha em <tela>" --tags a11y,wcag \
  --ac "<a asserção do teste Playwright>"
```

**Não faça:** `aria-hidden` em elemento interativo; cor como único indicador de estado;
confiar só no axe; remover outline sem substituto que atenda 2.4.11.
