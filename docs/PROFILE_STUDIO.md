# Profile Studio — Telumia

## Incremento verificado: imagens pessoais no Desktop

O editor usa a tela de perfis existente do cliente Desktop. O avatar pessoal é uma preferência de apresentação local, separada dos campos sincronizados pelo backend. Alterar uma foto local não grava um caminho do computador, um identificador OpenMoji ou um `file:` URI no payload de perfil da conta.

O fluxo implementado permite escolher um arquivo, receber um único arquivo arrastado, colar uma imagem ou arquivo do clipboard e selecionar um dos 64 avatares licenciados integrados. A foto passa por recorte quadrado, zoom, reposicionamento, preview e exportação PNG em 64, 128, 256 e 512 pixels. Restaurar o avatar da conta remove somente os arquivos pessoais pertencentes à seleção anterior.

Arquivos importados são limitados inicialmente a 10 MiB, 8192 pixels por dimensão e 16 Mi pixels decodificados. PNG, JPEG, BMP e o primeiro quadro de GIF são aceitos pelo decoder raster do Desktop; SVG fornecido pelo usuário é recusado. O cabeçalho é inspecionado antes da decodificação. A orientação JPEG EXIF é aplicada; metadata original não é copiada para os PNGs. Arquivos originais não são alterados.

As versões pessoais ficam em `profile-studio-v1/avatars`, fora do cache de mídia, com pasta por hash da conta, índice e hash do identificador do perfil quando disponível. Um perfil de conta recriado no mesmo índice não herda a foto do identificador anterior. A exclusão local confirmada também limpa o avatar pessoal do perfil excluído. A resolução exige a conta proprietária ativa e observa trocas de conta na UI e na ponte nativa. A troca escreve as novas versões antes de substituir o manifesto. Uma falha ao publicar o manifesto mantém a seleção anterior. Dados com schema desconhecido não são apagados. Uma interrupção do processo pode deixar arquivos órfãos; a limpeza geral desses arquivos ainda precisa ser implementada.

Os SVGs OpenMoji permanecem sem alterações, com manifesto de hashes, origem fixada e licença CC BY-SA 4.0. São ilustrações de terceiros licenciadas, não arte original da Telumia. Veja [créditos dos avatares](AVATAR_ASSETS.md).

## Limites desta entrega

Fonte Desktop: `f2775da4f3722db19e0d1e2c619ff8154b87c548`, publicada no branch `main`. O conjunto final passou **138 testes, zero falhas/erros/skips**, e gerou o MSI Windows. O conjunto inclui regressões de Home, detalhes, player, timed metadata, cache e perfis. As duas primeiras tentativas registram erros corrigidos nos argumentos do `AsyncImage` e na assinatura de espera dos testes. A repetição posterior passou; o refinamento final de layout/isolamento também passou. O incremento foi posteriormente incluído na release 0.2.1-alpha.1.

Os testes adicionados exercitam decoder, recorte real por cor, dimensões exportadas, orientação EXIF, persistência, isolamento entre contas/perfis, recriação com novo identificador, falha na troca do manifesto, seleção de biblioteca, falha no clipboard e quatro viewports do editor. O teste de componente injeta a entrada de imagem e usa persistência real em diretório temporário. Foram revisadas oito capturas: recorte e biblioteca em 1366×768, 1920×1080, 2560×1440 e 3840×2160. O painel mantém largura máxima de 1440 dp; a biblioteca possui scroll e o editor continua no scroll da tela existente. Isso não comprova a interação com o seletor de arquivos do sistema, clipboard do Windows ou drag-and-drop do Explorer.

O decoder de produção foi executado por reflexão sobre uma cópia inalterada dos módulos do runtime empacotado. Como o runtime de distribuição remove o comando `java.exe`, somente o launcher do JDK de build foi adicionado à cópia isolada. PNG/JPEG e o recorte para os quatro tamanhos passaram. Os módulos e DLLs conferem com o runtime original. Esta verificação não equivale a instalar/abrir o MSI ou testar playback.

Evidências: [testes/builds](telumia-profile-studio-results.json), [pacote Windows](telumia-profile-studio-desktop-package-inspection.json), [assets e licença dentro do JAR](telumia-profile-studio-assets.json), [runtime](telumia-profile-studio-runtime.json) e [capturas/alcance da QA](telumia-profile-studio-ui-qa.json).

Na primeira entrega permaneciam pendentes importação antes da criação de um perfil, categorias adicionais da biblioteca, configurações de aparência/capa/player, tipos de perfil, clonagem seletiva, seleção cinematográfica e validação de todos os fluxos reais de autenticação e sincronização. Os incrementos posteriores na seleção estão registrados abaixo. PIN e outras funções existentes continuam disponíveis e não são creditados como novas implementações.

## Correções posteriores no Desktop

Fonte `0a3b34aff26f032caf7b5b7b5296c840cdc70e5d`, publicada em `main`. O salvamento e a exclusão do perfil agora retornam confirmação; o editor permanece aberto e apresenta erro quando a operação não é confirmada. A confirmação compara a configuração solicitada com a resposta e recusa troca de conta durante a operação. As mutações preservam a opção de plugins do perfil. Novos perfis locais recebem UUID próprio, impedindo que uma recriação no mesmo índice herde a foto anterior.

Passaram **149 testes selecionados, zero falhas/erros/skips**, com MSI Windows e repetição do gate sobre a árvore limpa. Incluem criação, alteração, persistência, limite de seis perfis, exclusão e recriação reais em uma conta de convidado isolada; confirmação não deve ser confundida com QA do backend remoto. O reset e a substituição de fotos recusam manifestos de versões futuras sem alterar seus bytes. A seleção de perfis usa a política central de movimento para duração, delays, escala e deslocamento; os testes do seletor de movimento passaram, mas a seleção cinematográfica completa ainda será redesenhada.

A leitura de GIFs agora limita respostas HTTP a 8 MiB, inclusive sem Content-Length, antes do decoder nativo. Cabeçalhos excessivos, mais de 512 quadros e imagens de mais de 4 Mi pixels são recusados. O cache de codecs mantém uma referência para cada card ativo, de modo que uma expulsão não libera o codec durante a leitura de um quadro. Os testes usam HTTP local com resposta chunked e erro 503 e um codec Skia real. Isso não conclui a política global de preload e concorrência de previews.

Evidências: [tentativas e testes](telumia-profile-studio-desktop-hardening-results.json) e [inspeção do MSI](telumia-profile-studio-desktop-hardening-package-inspection.json). A assinatura incorreta de dois testes novos de GIF foi corrigida antes do conjunto final. O incremento está na release `0.2.1-alpha.1`; a `0.2.0-alpha.1` preserva seus binários anteriores.

## Base inicial de imagens na Android TV

Fonte TV: `9ed0dc8b06de1db1305d066077e169d37ca8aeed`, publicada no branch `main`. A base usa o decoder Android existente da plataforma, aceita somente raster e lê entradas com limite de 10 MiB. Verifica dimensões antes de alocar pixels, aplica orientação JPEG e exporta recortes PNG em quatro tamanhos. O importador aceita somente um URI `content:` escolhido explicitamente; não baixa URLs.

Passaram **100 testes unitários selecionados**, o build dos cinco APKs e **três testes nativos Android** de pixels/recorte, cabeçalho excessivo/SVG e orientação JPEG. Os testes nativos foram repetidos após o commit, com árvore limpa. Evidências: [builds e testes](telumia-profile-studio-tv-raster-results.json), [pacotes](telumia-profile-studio-tv-raster-package-inspection.json) e [decoder nativo](telumia-profile-studio-tv-raster-native.json).

Naquele commit, a base não possuía editor visível, biblioteca integrada ou persistência de avatar na TV. A adaptação de memória também estava pendente. Testes com imagens sintéticas no emulador não comprovam importação pelo seletor do sistema nem desempenho em aparelho físico. O incremento foi posteriormente incluído na release 0.2.1-alpha.1.

## Incremento posterior: editor integrado na Android TV

O código publicado em `bb3faa3877a33db46eea3e08ac65ff1e21e291a0` acrescenta o editor ao diálogo existente de edição de perfis. Permite escolher uma imagem local, colar um URI `content:` de imagem, recortar, ampliar, reposicionar e gerar quatro versões PNG. A biblioteca integrada contém os mesmos 64 SVGs licenciados e preserva os bytes e créditos verificados dentro do APK.

Quando o aparelho não oferece um seletor de documentos utilizável, a ação de escolher imagem solicita a permissão de fotos compatível com a versão do Android e abre uma galeria local limitada a 256 entradas raster. Essa permissão não é solicitada ao iniciar o aplicativo. O teste nativo publicou uma imagem controlada no MediaStore, consultou seu URI real, escolheu-a por D-pad e verificou as quatro versões persistidas. Isso não comprova todos os seletores de fabricantes ou escolhas de permissão do usuário.

As fotos ficam no diretório privado `profile-studio-v1/avatars`, fora do cache. A identidade local do perfil e a conta proprietária delimitam a leitura e a escrita. Os dados pessoais não entram no payload remoto. O pull preserva a identidade remota do perfil para impedir herança de fotos quando outro perfil reutiliza um índice. A adoção da primeira identidade remota mantém a cópia anterior para proteger falhas de gravação de preferências; a coleta de cópias órfãs continua pendente. Manifestos desconhecidos ou de versões futuras são preservados e recusam reset e substituição.

O Android reduz a imagem decodificada para até 4 Mi pixels antes de trabalhar no recorte, respeitando também os limites de entrada de 10 MiB, 8192 pixels por dimensão e 16 Mi pixels no cabeçalho. O salvamento publica o manifesto por rename atômico no filesystem privado; uma falha mantém o avatar anterior.

Passaram **111 testes unitários selecionados**, a compilação dos cinco APKs e do APK de testes, **quatro testes nativos raster** e **cinco testes de interface em cada resolução**: 1280×720, 1920×1080 e 3840×2160. Foram revisadas 12 capturas de biblioteca, recorte, galeria local e diálogo integrado. As tentativas anteriores, inclusive a falha de visibilidade da ação Salvar e a falha de compilação do teste de recorte, permanecem registradas. O teste final exige o botão de importação inteiro após foco; a rolagem interna aninhada foi removida do diálogo real.

O conjunto nativo foi executado antes do commit. O build final sobre a árvore limpa passou e produziu APKs de aplicativo e testes byte a byte idênticos aos testados; os SHA-256 vinculam a QA ao commit publicado sem repetir os mesmos testes. [Vinculação das evidências](telumia-profile-studio-tv-build-binding.json). As capturas ainda mostram detalhes a refinar, como o nome da foto dentro do tile circular e o fallback do avatar local. Conteúdo sem foco pode ficar parcialmente visível em áreas roláveis. Isso não encerra o redesenho de perfis nem comprova desempenho físico, sincronização com conta real ou interação com todos os seletores do sistema. O incremento está na release `0.2.1-alpha.1`; a `0.2.0-alpha.1` preserva seus binários anteriores.

Evidências: [builds e tentativas](telumia-profile-studio-tv-results.json), [identidade e conteúdo dos APKs](telumia-profile-studio-tv-package-inspection.json), [assets licenciados](telumia-profile-studio-tv-assets.json), [decoder Android](telumia-profile-studio-tv-native.json) e [capturas, testes e limites visuais](telumia-profile-studio-tv-ui-qa.json).

## Seleção de perfis no Desktop

Fonte `7a476cee03d1800001c8a9cabb01a0fbdb778ee5`, posterior à release 0.2.1-alpha.1. A tela real agora usa cartões grandes com moldura própria, nome em duas linhas, destaque de foco marfim/âmbar e organização adaptativa para até seis perfis. O background acompanha o perfil focado. O conteúdo permite rolagem em janelas estreitas; carregamento, lista vazia e criação mantêm ações reais. PIN, edição e troca de perfil continuam nas rotas existentes. As transições obedecem à preferência de movimento e intensidade.

Passaram **155 testes selecionados**, sem falhas/erros/skips, e o build real do MSI Windows. Foram revisadas quatro capturas de 1366×768 até 3840×2160. O conjunto novo verifica mouse, teclado, nomes longos, foco, carregamento, criação com lista vazia e acesso a todos os itens em 360×640. As capturas usam o conteúdo do seletor de produção com nomes e avatares de letras controlados; não comprovam uma conta autenticada, download de capas ou ida e volta do PIN no aplicativo instalado. A largura máxima do conteúdo evita cartões esticados; adaptação para uso à distância continua pendente.

Evidências: [builds/testes](telumia-profile-selection-results.json), [capturas e limites](telumia-profile-selection-desktop-ui-qa.json), [MSI inspecionado](telumia-profile-selection-desktop-package-inspection.json) e [vinculação ao commit limpo](telumia-profile-selection-desktop-build-binding.json). O gate limpo reutilizou os resultados Gradle dos mesmos 155 testes; não representa uma segunda execução visual. Este incremento ainda não está nos binários publicados da 0.2.1-alpha.1.

## Seleção de perfis na TV

Fonte `633dcdae7eedcfc26e840d5c27fc4751991b0275`, publicada em `main`, posterior à release 0.2.1-alpha.1. A seleção real usa cartões com moldura própria, avatares arredondados, selo de PIN e disposição adaptativa: duas linhas em 720p e uma linha nos viewports maiores testados. O foco anterior é usado ao reconstruir o seletor após um overlay. Menu/seleção mantêm seus callbacks existentes. O título usa Manrope; o backdrop reage ao perfil focado e recebe escurecimento para leitura sobre capas. Animações da seleção respeitam movimento completo, reduzido ou desligado. Uma foto indisponível mantém a inicial visível, com contraste calculado a partir da cor do avatar.

Passaram **111 testes unitários selecionados**, os cinco APKs e o APK de testes sobre a árvore limpa. Passaram também **cinco testes nativos por resolução**, totalizando 15 em 720p, 1080p e 4K. Foram revisadas seis capturas finais. Os testes incluem acesso aos seis perfis por D-pad, Menu, criação, retorno do foco, margem de 5% para os cartões, legenda com contraste renderizado de pelo menos 4,5:1 sobre uma imagem branca realmente carregada e fallback após erro do carregador de imagens. A primeira rodada de nove testes/capturas e os builds intermediários permanecem registrados.

A QA usa os componentes de produção com dados locais controlados. A imagem local é uma fixture de capa, não uma nova UI de importação de capas. Não comprova ida e volta do PIN com uma conta real, sync remoto, reprodução, overscan superior a 5% ou desempenho em TV física. Os hashes dos APKs nativos correspondem ao build limpo. Este incremento ainda não integra os binários publicados da 0.2.1-alpha.1.

Evidências: [builds e tentativas](telumia-profile-selection-results.json), [APKs inspecionados](telumia-profile-selection-tv-package-inspection.json), [QA e seis capturas](telumia-profile-selection-tv-ui-qa.json), [vinculação ao commit](telumia-profile-selection-tv-build-binding.json) e [primeira rodada](telumia-profile-selection-tv-first-ui-qa.json).

O escopo integral do projeto permanece em [objetivo aprovado](GOAL_OBJECTIVE_2026-10-05.md). Estes incrementos não encerram a fase ou o projeto.
