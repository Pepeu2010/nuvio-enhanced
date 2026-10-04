# Builds baseline e ambiente

Sources rastreados dos dois clientes permaneceram intactos durante as tentativas.
SHAs: upstream-lock.json. Comando reproduzível: scripts/Invoke-Baseline.ps1.
Os logs completos e JSONs de resultado estão em artifacts/, ignorados no Git;
o resumo final será registrado aqui e em baseline-results.json.

## Ambiente encontrado

- Windows; MSVC 2022 BuildTools instalado.
- Java padrão do shell: JRE 8. Builds usam JDK 17 já presente no cache Gradle.
- Android SDK 36 instalado. Gradle TV provisionou NDK 29.0.14206865 e
  Build-Tools 35.0.0 automaticamente, com licenças previamente aceitas.
- WebView2 SDK 1.0.4078.44, versão do workflow upstream, baixado do NuGet oficial
  para .tooling/. libmpv Windows já presente no checkout Git LFS.
- Nenhum aparelho ADB conectado e nenhum AVD disponível na inspeção inicial.
- Test files encontrados: Desktop commonTest 189 + desktopTest 15; TV 263.
  Contagem de arquivos não é contagem de testes executados.

## Tentativas

| Tentativa | Comando | Estado |
|---|---|---|
| Desktop inicial | desktopTest + packageReleaseMsi | Falhou: local.properties inexistente, WebView2 SDK ausente; problemas de configuration cache reportados |
| Desktop configurado | mesmas tarefas, --no-configuration-cache e caminho WebView2 SDK | Interrompido deliberadamente por pressão de memória; main Kotlin e ponte nativa chegaram a compilar; MSI/testes ainda não concluídos |
| TV inicial | testFullDebugUnitTest + assembleFullDebug | Falhou em assinatura (keystore ausente) e compileFullDebugKotlin (GC overhead / heap de 2 GiB insuficiente) |
| TV configurado | mesmas tarefas, worker único, compiler heap 6 GiB | APKs Full Debug gerados; 1839 testes, 20 falhas, 1 skipped; exit 1 devido aos testes |
| Desktop sequencial | desktopTest + packageReleaseMsi, --no-configuration-cache, WebView2, heaps 2/6 GiB | MSI gerado; 1402 testes, 26 falhas, 1 skipped; exit 1 devido aos testes |

Desativar configuration cache replica a opção do CI; não é alteração de código.
Criar arquivo local ignorado é preparação de ambiente, não modificação do upstream.

A primeira execução simultânea pressionou memória física/virtual da máquina de
16 GB. A tentativa Desktop configurada foi encerrada por decisão do agente para
liberar recursos; a mensagem daemon disappeared não é atribuída a bug do upstream.
As novas tentativas são sequenciais, com limites separados para Gradle/Kotlin.
Nenhum teste foi considerado passado pela simples existência de classes compiladas.

## Resultado TV e pendências herdadas

`assembleFullDebug` concluiu no commit auditado, com assinatura local própria.
Foram gerados APKs arm64-v8a, armeabi-v7a, x86, x86_64 e universal; não instalados.
A suíte completa executou 1839 testes: 1818 passaram, 20 falharam, 1 foi ignorado.
O build combinado saiu com código 1 por causa de `testFullDebugUnitTest`.

As 20 falhas estão preservadas em `tv-baseline-failures.json`. Incluem expectativas
de player/allocator/Dolby Vision/probes, posters/collections/airing/post-play,
refresh Trakt, dois testes por reflection com assinatura de plugin inexistente,
um mock de catálogo incompleto e um cast de mock em stream info. A classificação
é inicial: não atribuir todas ao ambiente nem alterar expectativas para obter verde.
Elas precedem qualquer implementação do fork e permanecem pendências explícitas.

O baseline de TV não bloqueia mudanças isoladas de identidade/dados/privacidade.
Nenhuma dessas falhas será escondida ou descrita como suíte aprovada; mudanças
futuras exigem testes direcionados e comparação com esta referência.

## Resultado Desktop e pendências herdadas

A suíte no commit Desktop auditado executou 1402 testes: 1375 passaram, 26
falharam, 1 foi ignorado. As falhas estão em `desktop-baseline-failures.json`:
continuidade/identidade de episódios, títulos de biblioteca, assertions de
componentes/imagens, timeout de concorrência QuickJS e três testes de instalação
Linux executados no host Windows. `packageReleaseMsi` concluiu e gerou
`Nuvio-Windows-x64-0.1.27-alpha.msi`; nenhum MSI foi instalado.
O build combinado saiu com código 1 por causa dos testes. O snapshot imutável
está em `phase-0-results.json`; hashes/bytes dos artefatos em `baseline-outputs.json`.

## Gate da Fase 0

Checkouts, commits de referência, cinco documentos e execução dos builds/testes
baseline concluídos. Ambos os empacotamentos funcionaram, mas ambas as suítes
contêm falhas herdadas. Fase 0 encerra com essas ressalvas e permite iniciar 0-C;
não representa aprovação de release ou de login/playback/sync em runtime.

## Configuração de conta e validação real

O endpoint oficial `https://api.nuvio.tv/.well-known/nuvio` respondeu e declarou
version/service/backend_url/publishable_key/capabilities. É configuração pública
de cliente, não credencial de usuário. A implementação upstream usa configuração
gerada durante build; um arquivo sem esses valores não comprova login funcional.
Nenhuma senha, sessão, token de usuário ou conta de teste foi usada nesta fase.

Não executar/installar o app upstream sobre a instalação do usuário como parte
do baseline. Instalação independente só será verificada após a fundação.
