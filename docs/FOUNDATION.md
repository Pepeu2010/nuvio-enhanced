# Milestone 0-C: fundação independente

Referência: Fase 0 concluída com fontes originais intactas, MSI/APKs gerados e
falhas herdadas preservadas. Esta entrega mantém Compose/KMP e Compose/Media3.

## Alterações concretas

- Desktop: pacote/launcher/menu `NuvioEnhanced`, janela `Nuvio Enhanced`, UUID MSI
  próprio `1c69d968-d0e0-4b0f-b5c0-615b8ea92f90`; bundle macOS independente.
- Desktop: Roaming/Local/Application Support/Caches/XDG próprios; sem importação
  automática de dados oficiais. WebView2 usa `NuvioEnhanced/WebView2`. Ícones e
  atalhos do Windows apontam apenas ao fork; restart usa seu próprio launcher.
- Corrigido gate da compilação C++ que ignorava mudanças quando a DLL existia;
  inputs/outputs Gradle passam a determinar a recompilação da ponte Windows.
- TV: application IDs `io.github.pepeu2010.nuvioenhanced.tv` e flavor Playstore
  `.playstore`; Debug acrescenta `.debug`. Namespace Kotlin/JNI preservado.
  Labels traduzidos identificam o fork. Full mantém seus recursos existentes.
- Debug TV usa assinatura de desenvolvimento Android. Release exige configuração
  explícita própria, sem senha padrão nem fallback para keystore oficial.
- Updaters apontam aos forks `Pepeu2010/nuvio-enhanced-desktop` e
  `Pepeu2010/nuvio-enhanced-tv`. A pré-release 0-C foi posteriormente publicada
  na aba Releases central; a configuração dos updaters segue nos forks específicos.
- Crash reports desligados por padrão em novos dados, preservando opt-in explícito.
  Sentry não inicializa se desligado ou se DSN não configurado.
- Diagnósticos de addons removem URLs completas (path/query/userinfo podem conter
  tokens); rede/persistência continuam usando as URLs operacionais originais.
  Mensagens/exceptions/transactions/breadcrumbs Sentry recebem redaction e dados
  adicionais dos breadcrumbs são removidos. Isto não prova sanitização global de
  todo logger, plugin, campo arbitrário ou relatório manual existente.

## Validação

Desktop: 31 testes direcionados passaram, cobrindo caminhos/storage, redaction,
Sentry, identidade dos reports/updater, modelos/URLs Stremio e SyncManager.
MSI do fork gerado após recompilar a ponte C++. Verificação binária confirmou
`NuvioEnhanced/WebView2`, ausência do caminho oficial na DLL e mesmo hash da DLL
incluída no JAR. Leitura do MSI confirmou ProductName, Manufacturer e UpgradeCode
próprios. O pacote não foi instalado; essas provas não são QA de playback.
TV: 84 testes direcionados aprovados e APKs Full Debug gerados. O teste de
consentimento verifica o estado desligado antes/durante o carregamento, preserva
opt-in salvo e comprova persistência/desativação após uma mudança explícita.

`Test-CompatibilityFoundation.ps1` verifica ausência de alterações nos sources
protegidos de autenticação, sync, DTOs/APIs e transporte/modelos de addons.
Não comprova login ou paridade do serviço remoto. O inventário da Fase 0 permanece
como referência, incluindo diferenças conhecidas com o self-host auditado.

## Limites e próximo milestone

As 26 falhas Desktop e 20 TV do baseline não são convertidas em sucesso pelos
testes direcionados. Instalação lado a lado, login/sync/playback com fontes reais,
QA visual, D-pad e TV Box física permanecem pendentes. Nenhum app oficial foi
instalado, alterado ou executado pelo baseline. Ícones/layout upstream ainda serão
substituídos na Fase 1; nenhum controle Live TV/EPG falso foi acrescentado.

Próximo milestone: 1-A, tokens/motion e shell nativo próprio, seguido pelos gates
do roadmap. Cache adaptativo e preparação EPG entram em 1-D; timed metadata em 2-A.

Milestone 0-C implementado, testado e compilado. Commits exatos de 0-C estão em
`RELEASES.md` (alpha.1); `fork-lock.json` acompanha o incremento atual.
Resultados em `foundation-results.json`, inspeção dos pacotes
em `package-inspection.json`. Os dois forks foram publicados com `main` própria.
