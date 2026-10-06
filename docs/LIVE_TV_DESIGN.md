# Preparação visual de Live TV/EPG — Fase 1

A inspeção dos dois clientes não encontrou uma rota de TV ao vivo, componentes de canal/programação ou provider XMLTV. Os componentes novos estendem os tokens e temas nativos existentes; não criam um app paralelo. A única referência EPG anterior na TV dizia respeito ao filtro de episódios sem numeração.

Foram preparados channel tile, now/next com progresso acessível, program cell e linha lazy de programação. Desktop usa Material 3 e teclado; TV usa os botões de TV Material 3, borda de foco do tema, D-pad e a política existente de movimento. Cores de conteúdo respeitam a cor de foco do tema. Canal/programa selecionado tem semântica própria. Progresso desconhecido ou não finito não recebe porcentagem inventada.

Os componentes recebem apenas apresentações e callbacks fornecidos pelo futuro adapter. Não há canais, listas, agendas ou conteúdo embutidos. Nomes, logos e horários de teste existem somente nos arquivos de teste. Nenhuma chamada foi adicionada a Home, menus, rotas ou player. O texto de próxima programação é fornecido pelo caller localizado.

Esta entrega prepara o estilo; providers M3U/XMLTV, normalização de fuso horário, cache/atualização, alinhamento temporal do grid, favoritos e zapping/reprodução continuam na Fase 6. Os callbacks de teste não representam funcionalidade de TV ao vivo disponível para usuários.

Passaram três testes de componentes Desktop, junto com 18 regressões direcionadas, e o MSI foi gerado. A inspeção visual revelou que o título atual dependia da cor herdada do host; foi definida a cor explícita do tema. A recompilação desse ajuste, agrupada com a integração da fonte Manrope licenciada, passou com 21 testes e MSI. A captura final confirma o título legível. Código Desktop: `20c53d1b`. [Builds e testes](live-design-results.json), [inspeção dos pacotes](live-design-package-inspection.json).

TV: 53 testes direcionados passaram e cinco APKs/um APK de testes foram compilados. Os três testes novos passaram em 720p, 1080p e 4K: ações por D-pad e entrega da identidade de programa ao callback, seleção/foco, ausência de programas fictícios na lista vazia e progresso acessível/Unknown. A suíte de detalhes de filmes também passou nas três resoluções neste APK, totalizando 18 execuções instrumentadas aprovadas. As dimensões reais das capturas foram verificadas. [QA](live-design-ui-qa.json), [capturas controladas](evidence/live-design). Código TV: `0bf4495efcd35225e5b22851e4831d32b518d58c`.

As versões candidatas são `0.2.1-alpha.1` (MSI numérico `1.2.1` e TV code `2010`); ainda não foram publicadas. Os downloads `0.2.0-alpha.1` permanecem intactos. Componentes visuais preparados não equivalem à implementação de Live TV/EPG, nem à aceitação do redesign integral descrito na [meta vigente](GOAL_OBJECTIVE_2026-10-05.md). A integração de Manrope nos títulos TV está no código local posterior ao APK validado e ainda requer compilação e testes no próximo conjunto de alterações.
