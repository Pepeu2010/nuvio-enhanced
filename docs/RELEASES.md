# Releases do Nuvio Enhanced

## v0.1.0-alpha.1 — fundação 0-C

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
