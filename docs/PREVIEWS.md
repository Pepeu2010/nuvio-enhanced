# Telumia — ciclo de vida dos previews

Incremento sobre os componentes e resolvers existentes. Não encerra Cinematic Preview nem o redesign da Home.

## Desktop: entrega verificada

`HomePosterHoverPreview` agora possui uma vaga exclusiva por montagem do card. Abrir outro card invalida o anterior; desmontar o anterior não libera a vaga do novo. A resolução começa depois do hover estável, possui deadline de cinco segundos e é cancelada ao sair, trocar de card ou desmontar. Falha/ausência de trailer conserva a arte estática. As transições do popup e do trailer respeitam o movimento configurado no perfil. O som continua opt-in.

Commit `57385d2e92d34ff39527e38566534939d86c87ad`, publicado em `telumia-desktop/main`. Gate: 174 testes selecionados, zero falhas, erros ou skips; MSI compilado e preservado, SHA-256 `92c7c62939a4f729f59a5ed47cd259b50ce51255bdb60f71f06b50fe0a0a206b`. [Vínculo entre fontes e pacote](telumia-hover-lifecycle-desktop-bound-build-binding.json) e [inspeção do instalador](telumia-hover-lifecycle-desktop-package-inspection.json).

Cinco testes verificam ownership, timeout, falhas e propagação de cancelamento. Um teste Compose usa o popup real, transfere o mouse do card para ele, cancela um resolver controlado ao sair e verifica a liberação da vaga. A captura abaixo foi revisada; demonstra o estado estático com consulta pendente, sem afirmar disponibilidade ou reprodução de um trailer.

![Popup real durante resolução controlada](evidence/telumia-hover-lifecycle/desktop-static-pending-preview.png)

**Limite Windows:** a política herdada ainda define trailers externos, e a implementação Windows de `HeroTrailerPlayerSurface` permanece vazia. O teste de cancelamento injeta explicitamente a capacidade de resolver trailers; não habilita a reprodução Windows no produto. Habilitar essa política sem implementar e validar a superfície nativa produziria uma funcionalidade falsa. A reprodução embutida Windows continua pendente, usando o motor existente como fundação.

Tentativas anteriores com erro de compilação do teste, timeout e condição de capacidade estão preservadas em `artifacts/`; não são usadas como gate aprovado. O teste final aguarda a recomposição e simula a transferência real do ponteiro para o popup.

## TV: entrega verificada

A implementação evolui o pipeline do `HomeViewModel` e o `TrailerPlayerPool` existentes. Cancela pedidos antigos antes de consultar caches, preserva pedidos repetidos do mesmo item, aplica deadline de seis segundos e descarta respostas atrasadas. Os mapas de URLs e o cache negativo ficam limitados a 64 entradas. Cancelamento, timeout e erro transitório não se tornam ausência permanente. Consultas de fallback usam IO; publicação e retry usam Main. Sair da Home cancela consultas; parar o scroll permite repetir o preview do item ainda focado.

O pool Media3 entrega uma vaga exclusiva por componente. Trocar de card interrompe a mídia anterior; callbacks e desmontagem do card antigo não param o novo. Entregar o decoder ao player principal invalida a vaga e impede aquisição até sua devolução. A preparação começa silenciosa, com alvo de buffer de 16 MiB, até dez segundos e seleção adaptativa limitada inicialmente a 720p/4 Mbps. Esse alvo não é um teto de memória total nem a implementação definitiva de DeviceCapabilities. As transições respeitam movimento reduzido/desligado. Sem primeiro frame em doze segundos, retorna à arte estática.

Commit `e593acdd8ab0b906a9cf99aff51c751bf3cea5fb`: 137 testes selecionados, zero falhas/erros/skips, cinco APKs e APK de instrumentação compilados e preservados. APK universal SHA-256 `7ddd3c50b5ea8e7281e9702f024efe390092ea63fecfb553582d98030f34d7f5`. [Build e vínculo de fontes](telumia-preview-owner-tv-build-binding.json), [inspeção dos APKs](telumia-preview-owner-tv-package-inspection.json) e [testes nativos](telumia-preview-owner-native.json).

Quatro testes nativos passaram em cada API, Android 7 e Android 16, com os mesmos APKs. O Media3 real prepara áudio WAV local; são verificados ownership, desmontagem de dois componentes Compose sobrepostos, silêncio inicial e entrega/retorno do decoder. Isso não comprova frames de vídeo, trailers remotos, HDR ou desempenho físico. Uma tentativa anterior falhou por comparação de identidade de um conjunto no teste; o teste foi corrigido para comparar seu conteúdo. [Histórico dos gates](telumia-hover-lifecycle-results.json) e [gate final](telumia-preview-owner-results.json).

## Pendências

Ainda é necessário implementar trailers embutidos Windows e validar vídeo remoto, todas as superfícies de preview, DeviceCapabilities e desempenho físico. O código desta entrega é posterior à release `v0.2.1-alpha.1`; seus binários públicos continuam fixos nos commits originais. As falhas herdadas da suíte completa e os fluxos de conta/sync não são cobertos por este gate.
