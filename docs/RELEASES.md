# Releases da Telumia

## v0.2.2-alpha.1 — conta, navegação, momentos e player

A [nova pré-release](https://github.com/Pepeu2010/telumia/releases/tag/v0.2.2-alpha.1) está publicada nos três repositórios: MSI Windows x64, APK TV universal/quatro ABIs, fontes, manifesto e SHA256SUMS. **22 assets remotos verificados por tamanho, estado e digest SHA-256.** [Verificação](telumia-v022-release-verification.json), [entrega e limites](ALPHA_022.md).

Distribui Desktop `b39b6ea79d37b7c9eb1383ef68692dd2309d664d` e TV `e1962f736410a288f3a8db92fa6d2eaa4eaaa66b`; tag central `62fa214f37300ca42759042a14fb4597eb40e5d7`. Passaram 268 testes selecionados Windows e 200 TV, sem falhas/erros/skips, com builds em árvores limpas. O renderer PC passou oito execuções/1.052 verificações; o painel TV passou 12 casos em 720p/1080p/4K, com seis capturas revisadas. A MainActivity real passou nas APIs 24 e 36 com o mesmo APK, sem crash/ANR nos 30 segundos observados.

Reúne os incrementos de seleção de perfis, motion/navegação, reconciliação durável de coleções/addons nos contratos existentes, momentos salvos e thumbnails/filmstrip/composição do player Windows. Inclui validação nativa de headers HTTP e remoção de uma injeção não utilizada na Application TV. ZIP Desktop com 142 objetos LFS conferidos; os APKs continuam Android TV Full Debug de desenvolvimento.

Essa alpha não encerra o plano. Conta oficial autenticada, WebView2 completo, hardware físico/HDR/DPI, execução Linux/macOS, thumbnails TV e as demais fases continuam pendentes. Rascunhos tiveram seus uploads conferidos por ID antes da publicação; a primeira tentativa de consulta pela tag retornou 404 e foi preservada. [Publicação e recuperação](telumia-v022-publication-results.json). Nenhum asset de versão anterior foi substituído.

## v0.2.1-alpha.1 — Home, cache e editores locais de avatar

A [pré-release](https://github.com/Pepeu2010/telumia/releases/tag/v0.2.1-alpha.1) está publicada nos três repositórios. Inclui MSI Windows x64, APK Android TV universal e variantes ARM64/ARM32/x86/x86_64, fontes correspondentes, manifesto e SHA256SUMS. Foram verificados os 22 assets remotos por tamanho e digest SHA-256. [Registro da publicação](telumia-profile-studio-release-verification.json).

Distribui Desktop `0a3b34aff26f032caf7b5b7b5296c840cdc70e5d` e TV `bb3faa3877a33db46eea3e08ac65ff1e21e291a0`, com 149 e 111 testes selecionados, sem falhas/erros/skips, e builds sobre árvores limpas. O incremento inclui Home/detalhes cinematográficos, base de timed metadata, orçamento de cache Auto/Manual e editores de avatar nos fluxos existentes. Os APKs continuam Full Debug de desenvolvimento para TV.

O manifesto e as fontes foram conferidos antes da publicação. O ZIP Desktop contém 142 objetos LFS com hashes/tamanhos verificados, sem ponteiros pendentes; o ZIP TV foi verificado sem objetos LFS. Os APKs de aplicativo e testes conferem byte a byte com os quatro testes raster Android e 15 testes de interface em três resoluções, com 12 capturas revisadas. [Gates](telumia-profile-studio-release-results.json), [pacotes](telumia-profile-studio-release-package-inspection.json) e [alcance do Profile Studio](PROFILE_STUDIO.md).

A release não encerra o produto: previews de vídeo, thumbnails/filmstrip, Scene Info, Source Intelligence, Live TV/EPG e o Profile Studio completo continuam pendentes. O redesenho posterior da seleção de perfis não está nestes binários. As suítes selecionadas não comprovam todos os fluxos de conta/reprodução ou desempenho em TV física. Não há cliente específico de celular nem instaladores Linux/macOS nesta entrega.

## v0.2.0-alpha.1 — marca própria e catálogos brasileiros

A [pré-release Telumia](https://github.com/Pepeu2010/telumia/releases/tag/v0.2.0-alpha.1) inclui o MSI Windows, APK Android TV universal e quatro variantes por arquitetura, fontes correspondentes, manifesto e checksums. Foram conferidos 22 assets entre o repositório central e os dois clientes, por tamanho e SHA-256. [Registro da publicação](telumia-release-verification.json).

As fontes distribuídas são Desktop `fdeaddfe3d0dc026ecd3d632210ce4dd212783ad` e TV `0355dfe4366ebce3067718eaf9dfb3139dd8f243`. Esta entrega inclui nome, logo, IDs e caminhos próprios, aliases brasileiros de Iludida e seleção da edição brasileira quando uma fonte configurada a disponibiliza. Não contém os incrementos posteriores de Home, detalhes, timed metadata, cache ou Profile Studio. Os APKs são Full Debug de desenvolvimento; não há pacote específico para celular, Linux ou macOS.

As releases históricas abaixo conservam seus arquivos e metadados. A nova geração utiliza os [repositórios Telumia](../README.md); os URLs antigos podem redirecionar no GitHub.

## Verificação dos próximos arquivos de fonte

O preparador agora confere os objetos Git LFS dentro do ZIP e recusa ponteiros sem os binários correspondentes. Na validação Desktop do commit `f2775da4f3722db19e0d1e2c619ff8154b87c548`, passaram os hashes e tamanhos de **142 objetos, 293.336.120 bytes**, sem ponteiros pendentes. Neste ambiente o próprio Git já expandiu esses arquivos; não foi necessário reidratá-los. [Evidência do arquivo de fonte](telumia-desktop-source-archive-inspection.json).

Essa validação não publica uma nova versão nem comprova execução em Linux/macOS. O binário libmpv também foi encontrado no ZIP da release Telumia já publicada; a hipótese inicial de que aquele arquivo conteria apenas um ponteiro não se confirmou.

## v0.1.0-alpha.2 — incremento nativo 1-A.1

[Pré-release publicada](https://github.com/Pepeu2010/nuvio-enhanced/releases/tag/v0.1.0-alpha.2).
Os dez assets foram conferidos no GitHub por tamanho e digest SHA-256 antes de
publicar; registro em [motion-release-publication.json](motion-release-publication.json).
Acrescenta à fundação 0-C o movimento completo/reduzido/desligado nas configurações
de Aparência dos clientes existentes, salvo por perfil e fora do payload oficial
de sync. Não representa o redesign completo de 1-A.

MSI Windows x64, APK TV universal e variantes ARM32/ARM64/x86/x86_64, fontes
correspondentes, manifest e checksums acompanham a entrega. Os APKs continuam
Full Debug de desenvolvimento e as versões internas continuam herdadas.

| Cliente | Commit distribuído |
|---|---|
| Desktop | `a704c6d7b1761484d163f809e27e6af6a72f4757` |
| TV | `024e60aca0d6edf190c6eab465c4e335e16a8da4` |

**22 testes Desktop e 19 TV aprovados** e pacotes recompilados. O APK universal
foi instalado em emulador 1080p: seleção por D-pad, retorno de foco e persistência
após reinício foram observados. A imagem disponível é phone Android API 37.1
x86_64/16 KB com preset TV; não valida Android TV OS, TV Box física ou performance.
O sistema avisou sobre alinhamento nativo e executou em page size compatible
mode. Não se declara compatibilidade nativa com 16 KB. O login original por QR
falhou nessa sessão; conta/sync/playback e MSI instalado permanecem pendentes.
As 46 falhas completas herdadas do baseline continuam registradas.

Detalhes/capturas: [NATIVE_FOUNDATION.md](NATIVE_FOUNDATION.md),
[motion-results.json](motion-results.json), [motion-ui-qa.json](motion-ui-qa.json)
e [motion-package-inspection.json](motion-package-inspection.json).
Para reconstruir, siga os passos dos forks e faça checkout dos commits acima
com Git LFS; os ZIPs podem conter ponteiros LFS. Esta release central exige
download manual, pois os updaters consultam os repositórios dos clientes.

Os MSIs alpha.1 e alpha.2 mantêm ProductVersion `1.1.27` e ProductCode
`{06995AB3-8E6B-3211-9441-084EA9B585D5}`. Para trocar entre eles, remova a instalação
anterior do **Nuvio Enhanced** antes de instalar alpha.2. Os APKs mantêm versionCode
1066 e assinatura própria de desenvolvimento: instale com substituição da versão
anterior. A tag central ainda não substitui um versionamento interno por entrega.

O rascunho só foi publicado após verificação dos uploads por tamanho e SHA-256.

## v0.1.0-alpha.1 — fundação 0-C

[Pré-release publicada](https://github.com/Pepeu2010/nuvio-enhanced/releases/tag/v0.1.0-alpha.1).
Os dez assets foram conferidos no GitHub por tamanho, estado de upload e digest
SHA-256 antes da publicação; registro em [release-publication.json](release-publication.json).

Entrega experimental dos clientes existentes do Nuvio com a fundação do fork.
Não contém ainda o redesign, Profile Studio, nova timeline, Source Intelligence,
Scene Info, Live TV/EPG ou Phone Remote. A tag do repositório central identifica
o conjunto; não altera as versões internas herdadas dos aplicativos.

### Pacotes

- Windows x64: `NuvioEnhanced-Windows-x64-foundation.msi`, app `0.1.27-alpha`.
- Android TV: `NuvioEnhanced-TV-universal-debug.apk` e APKs específicos
  arm64-v8a, armeabi-v7a, x86_64 e x86. Flavor Full Debug, app `1.1.0-beta.3`,
  ID `io.github.pepeu2010.nuvioenhanced.tv.debug`, assinatura de desenvolvimento.
- Código-fonte dos clientes nos commits exatos indicados abaixo.
- `CHECKSUMS-SHA256.txt` e `release-assets.json` para integridade/proveniência.

### Fontes correspondentes e build

| Cliente | Commit distribuído |
|---|---|
| Desktop | `5674b49d67817a20aef33a5878412f52163c1e3f` |
| TV | `023edae7aeb403e6bf1dd5cb1bef4e6546fa2430` |

Os ZIPs de fonte preservam os arquivos rastreados, GPL e avisos. Arquivos geridos
por Git LFS podem estar representados por ponteiros no ZIP; para obter os inputs
binários do upstream, use o clone com Git LFS no commit exato. Nenhuma chave de
assinatura, credencial, configuração privada ou log local integra os arquivos.

```powershell
git clone https://github.com/Pepeu2010/nuvio-enhanced-desktop.git
git -C nuvio-enhanced-desktop checkout 5674b49d67817a20aef33a5878412f52163c1e3f
git -C nuvio-enhanced-desktop lfs pull

git clone https://github.com/Pepeu2010/nuvio-enhanced-tv.git
git -C nuvio-enhanced-tv checkout 023edae7aeb403e6bf1dd5cb1bef4e6546fa2430
git -C nuvio-enhanced-tv lfs pull
```

Os passos/versões de ferramentas e fontes de dependências são registrados nos
READMEs dos forks, em [BASELINE.md](BASELINE.md), [upstream-lock.json](upstream-lock.json)
e nos build scripts. O repositório central contém ferramentas para restaurar o
workspace, provisionar configurações locais e executar as tarefas Gradle.
Os testes direcionados e limites de prova estão em [FOUNDATION.md](FOUNDATION.md).

### Validação e limites

31 testes direcionados Desktop e 84 TV passaram. MSI e cinco APKs foram compilados;
metadados do MSI, isolamento da DLL empacotada e identificadores/assinaturas dos
APKs foram inspecionados. Os hashes dos arquivos de publicação são conferidos
contra [package-inspection.json](package-inspection.json) antes do upload.

Há 26 falhas Desktop e 20 TV herdadas do baseline completo. Instalação, conta/sync,
reprodução com fontes reais, validação visual, D-pad e TV Box física permanecem
pendentes. Os APKs Debug não são uma distribuição de produção. Linux/macOS não
foram empacotados neste host Windows. As atualizações automáticas dos clientes
consultam seus forks específicos; esta entrega está na aba Releases central.

A publicação usa um rascunho até todos os assets terem tamanho/hash conferidos.
Só depois o rascunho é publicado como pré-release.
