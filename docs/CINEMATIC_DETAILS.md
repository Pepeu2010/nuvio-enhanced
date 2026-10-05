# Interface de filmes — incremento nativo 1-B.1

## Fluxo existente e lacunas

Desktop já possuía backdrop/gradientes, trailer, ratings, metadados, biblioteca, ações assistido, seleção de fontes, tabs de elenco e seções configuráveis. O hero fixo de 660 dp cortava a sinopse em quatro linhas sem acesso direto à versão integral; biblioteca e assistido ficavam dentro do menu expandido. TV já tinha sinopse com overlay, foco/restauração, watched/library/trailer, artwork e tabs; seu hero fixo de 540 dp e o botão de trailer apenas por ícone dificultavam hierarquia em filmes.

## Integração

Desktop: `DesktopDetailHero` usa o viewport real, altura mínima adaptativa e crescimento conforme o conteúdo. `CinematicMovieActions` expõe assistir/continuar, biblioteca, trailer disponível e assistido, chamando os mesmos callbacks. Long press/clique secundário continuam abrindo as ações existentes. `CinematicSynopsis` abre a descrição completa num `DialogSurface` nativo com scroll, seleção de texto e botão Fechar. O trailer direto usa `resolveTrailer` e o mesmo popup/resolver existente. Séries conservam suas ações de shuffle e menu.

TV: `HeroContentSection` adapta a altura mínima em filmes e permite crescimento; metadados aparecem antes das ações; o trailer existente ganha texto e foco visível; a sinopse compacta reutiliza `SynopsisDescription` e `SynopsisOverlay`. Em viewports abaixo de 480 dp de altura, título, logo, padding superior e descrição reservam espaço para a ação Ler mais. O grafo de navegação, ViewModel, playback, long press, restore tokens e callbacks são preservados. Séries mantêm a altura e ações anteriores.

## Gate

Sete testes Compose Desktop verificam callbacks por teclado/long press, ausência de trailer, playback indisponível, sinopse integral e troca de obra, e acesso às ações no hero de produção em viewports de 1366x768, 1920x1080, 2560x1440 e 3840x2160. Três testes instrumentados TV verificam controle remoto, long press da biblioteca, trailer ausente e sinopse pelo D-pad. Fixtures existem apenas dentro dos testes; não há dados ou ações fictícios na interface de produção.

Passaram 18 testes direcionados Desktop e 52 TV, com MSI e cinco APKs compilados. Os sete testes novos Desktop renderizaram os quatro viewports indicados. Os três testes instrumentados TV passaram em cada uma das resoluções 1280x720, 1920x1080 e 3840x2160, com dimensões reais dos PNGs verificadas. A captura em 720p revelou uma ação Ler mais cortada; a correção compacta foi recompilada e o teste passou a exigir visibilidade antes da interação por D-pad. A tentativa anterior de 4K com apenas `wm size` manteve o framebuffer em 1080p e falhou; esse resultado não conta como gate. A validação final configurou o framebuffer físico do emulador em 3840x2160 e restaurou a configuração original depois.

No APK instalado, o fluxo existente abriu o filme Unabomber com artwork/metadados reais, iniciou seu trailer público, retornou do trailer e adicionou/removeu o filme da biblioteca do perfil Guest de teste. Sem fonte de streaming configurada, o app informou reprodução indisponível. Não se declara playback integral do filme, conta/sync, desempenho de TV Box, HDR ou hardware decoder. As capturas controladas dos testes não são catálogos de produção.

Código publicado: Desktop `7ee9c38ddf34531074a7b2a0d6042f0c74d3cb48`; TV `9df177abe8d827690e3227539905050d0b61173e`. As releases `v0.2.0-alpha.1` distribuídas anteriormente ainda não incluem este incremento. Evidências: [builds](cinematic-details-results.json), [pacotes](cinematic-details-package-inspection.json), [QA TV](cinematic-details-ui-qa.json) e [capturas](evidence/cinematic-details).

Este incremento não conclui Home, Profile Studio, cache/timeline ou Scene Info. Os providers de cena precisam de dados confiáveis e de uma timeline ligada à identidade da mídia/edição. O objetivo integral permanece ativo.
