# Telumia — cache configurável por aparelho

Incremento nativo de 6 de outubro de 2026. Os dois clientes foram compilados e testados. A política central completa para todos os tipos de dados ainda não está concluída.

## Comportamento implementado no Desktop

O modo Auto começa em 1 GiB, adapta o orçamento à memória detectada e ao armazenamento disponível e mantém reserva de 2 GiB. Manual permite escolher outro orçamento, inclusive superior ao default, respeitando o espaço disponível. A configuração pertence ao aparelho, em armazenamento Telumia versionado, e vale a partir da próxima abertura.

Os carregadores existentes de imagens/badges e o cache de GIFs usam quotas da política central. GIFs têm limites de bytes, quantidade e tamanho por entrada; nomes derivados de hash; substituição atômica e eviction por uso recente. Arquivos antigos de GIF são lidos e migrados sob demanda, sem exigir rede. Eles ainda precisam de contabilização/migração global para assegurar um teto sobre todo o legado.

Quando a reserva impede escrita, os carregadores preservam leitura dos caches disponíveis. Requests individuais de fundos/badges respeitam a política. Downloads, bookmarks, histórico, configurações e arquivos de usuário não pertencem às quotas de mídia. As outras categorias possuem quotas preparadas, mas seus consumidores ainda precisam ser integrados.

Salvar uma preferência ocorre fora da thread de interface, desabilita novas edições durante a operação e mantém a seleção anterior se falhar. A gravação existente de preferências Desktop agora substitui o arquivo de maneira atômica quando suportado; um erro em `putString` restaura também o valor em memória.

## Gates Desktop

- 106 testes selecionados, sem falhas/erros/skips, e MSI real após revisão visual e correção do contraste do aviso de reinício.
- 13 testes adicionais de armazenamento/tema/persistência, sem falhas/erros/skips, com APPDATA temporário isolado. Uma primeira execução sem habilitar esse sandbox pulou corretamente o teste que protege o diretório real do usuário; a execução isolada cobriu esse teste.
- O runtime distribuído contém `java.management` e `jdk.management`, necessários à leitura da memória no JVM existente.
- [Resultados do cache](telumia-cache-results.json), [armazenamento isolado](storage-isolated-results.json) e [inspeção MSI](telumia-cache-desktop-package-inspection.json).

![Configuração Desktop](evidence/telumia-cache/desktop-cache-settings.png)

A captura usa um orçamento controlado para verificar os controles e a informação de que alterações exigem reinício. Não demonstra a operação completa do aplicativo offline nem o uso total de disco de todas as features.

## Continuidade obrigatória

A TV integra default de 256 MiB, Auto baseado em RAM/armazenamento, escolha Manual por D-pad e reserva de 256 MiB. Seus carregadores existentes de imagens/badges recebem quotas e política somente leitura quando a reserva impede escrita; backgrounds e revalidação respeitam a mesma política. A configuração é local ao aparelho, possui estado de gravação/erro e aplica mudanças na próxima abertura.

Passaram 96 testes unitários selecionados, sem falhas/erros/skips, e foram gerados os cinco APKs e o APK de instrumentação. Nove testes nativos em 720p/1080p/4K verificaram D-pad, seleção Manual/Auto, persistência real em SharedPreferences e fallback de schema futuro. Capturas e hashes estão na [instrumentação TV](telumia-cache-tv-ui-qa.json); a [inspeção dos APKs](telumia-cache-tv-package-inspection.json) registra sua identidade própria.

![Cache TV 720p](evidence/telumia-cache/tv-cache-settings-720.png)
![Cache TV 4K](evidence/telumia-cache/tv-cache-settings-2160.png)

Ainda faltam contabilização global de legado, integração das caches de metadata/addons/EPG/previews/thumbnails/filmstrip/Scene Info e avatar remoto, adaptação dinâmica durante a sessão e QA de fluxos offline reais. O limite de armazenamento antes de baixar imagens e a validação de arquivos/URLs também exigem revisão própria. O índice de metadata temporal não substitui um cache de Scene Info.

Esta entrega não encerra a Fase 1-D nem a [meta integral](GOAL_OBJECTIVE_2026-10-05.md). A release `0.2.0-alpha.1` não inclui essas mudanças.
