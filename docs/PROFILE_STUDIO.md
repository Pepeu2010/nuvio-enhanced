# Profile Studio — Telumia

## Incremento verificado: imagens pessoais no Desktop

O editor usa a tela de perfis existente do cliente Desktop. O avatar pessoal é uma preferência de apresentação local, separada dos campos sincronizados pelo backend. Alterar uma foto local não grava um caminho do computador, um identificador OpenMoji ou um `file:` URI no payload de perfil da conta.

O fluxo implementado permite escolher um arquivo, receber um único arquivo arrastado, colar uma imagem ou arquivo do clipboard e selecionar um dos 64 avatares licenciados integrados. A foto passa por recorte quadrado, zoom, reposicionamento, preview e exportação PNG em 64, 128, 256 e 512 pixels. Restaurar o avatar da conta remove somente os arquivos pessoais pertencentes à seleção anterior.

Arquivos importados são limitados inicialmente a 10 MiB, 8192 pixels por dimensão e 16 Mi pixels decodificados. PNG, JPEG, BMP e o primeiro quadro de GIF são aceitos pelo decoder raster do Desktop; SVG fornecido pelo usuário é recusado. O cabeçalho é inspecionado antes da decodificação. A orientação JPEG EXIF é aplicada; metadata original não é copiada para os PNGs. Arquivos originais não são alterados.

As versões pessoais ficam em `profile-studio-v1/avatars`, fora do cache de mídia, com pasta por hash da conta, índice e hash do identificador do perfil quando disponível. Um perfil de conta recriado no mesmo índice não herda a foto do identificador anterior. A exclusão local confirmada também limpa o avatar pessoal do perfil excluído. A resolução exige a conta proprietária ativa e observa trocas de conta na UI e na ponte nativa. A troca escreve as novas versões antes de substituir o manifesto. Uma falha ao publicar o manifesto mantém a seleção anterior. Dados com schema desconhecido não são apagados. Uma interrupção do processo pode deixar arquivos órfãos; a limpeza geral desses arquivos ainda precisa ser implementada.

Os SVGs OpenMoji permanecem sem alterações, com manifesto de hashes, origem fixada e licença CC BY-SA 4.0. São ilustrações de terceiros licenciadas, não arte original da Telumia. Veja [créditos dos avatares](AVATAR_ASSETS.md).

## Limites desta entrega

Fonte Desktop: `f2775da4f3722db19e0d1e2c619ff8154b87c548`, publicada no branch `main`. O conjunto final passou **138 testes, zero falhas/erros/skips**, e gerou o MSI Windows. O conjunto inclui regressões de Home, detalhes, player, timed metadata, cache e perfis. As duas primeiras tentativas registram erros corrigidos nos argumentos do `AsyncImage` e na assinatura de espera dos testes. A repetição posterior passou; o refinamento final de layout/isolamento também passou. Nenhuma release publicada contém este incremento.

Os testes adicionados exercitam decoder, recorte real por cor, dimensões exportadas, orientação EXIF, persistência, isolamento entre contas/perfis, recriação com novo identificador, falha na troca do manifesto, seleção de biblioteca, falha no clipboard e quatro viewports do editor. O teste de componente injeta a entrada de imagem e usa persistência real em diretório temporário. Foram revisadas oito capturas: recorte e biblioteca em 1366×768, 1920×1080, 2560×1440 e 3840×2160. O painel mantém largura máxima de 1440 dp; a biblioteca possui scroll e o editor continua no scroll da tela existente. Isso não comprova a interação com o seletor de arquivos do sistema, clipboard do Windows ou drag-and-drop do Explorer.

O decoder de produção foi executado por reflexão sobre uma cópia inalterada dos módulos do runtime empacotado. Como o runtime de distribuição remove o comando `java.exe`, somente o launcher do JDK de build foi adicionado à cópia isolada. PNG/JPEG e o recorte para os quatro tamanhos passaram. Os módulos e DLLs conferem com o runtime original. Esta verificação não equivale a instalar/abrir o MSI ou testar playback.

Evidências: [testes/builds](telumia-profile-studio-results.json), [pacote Windows](telumia-profile-studio-desktop-package-inspection.json), [assets e licença dentro do JAR](telumia-profile-studio-assets.json), [runtime](telumia-profile-studio-runtime.json) e [capturas/alcance da QA](telumia-profile-studio-ui-qa.json).

Continuam pendentes o suporte equivalente na TV, importação antes da criação de um perfil, categorias adicionais da biblioteca, configurações de aparência/capa/player, tipos de perfil, clonagem seletiva, redesenho completo da seleção de perfis e validação de todos os fluxos reais de autenticação e sincronização. PIN e outras funções existentes continuam disponíveis e não são creditados como novas implementações.

O escopo integral do projeto permanece em [objetivo aprovado](GOAL_OBJECTIVE_2026-10-05.md). Este incremento não encerra a fase ou o projeto.
