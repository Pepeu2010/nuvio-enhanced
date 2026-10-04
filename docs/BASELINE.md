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
| Desktop configurado | mesmas tarefas, --no-configuration-cache e caminho WebView2 SDK | Em execução; local.properties ignorado, sem conta provisionada |
| TV inicial | testFullDebugUnitTest + assembleFullDebug | Em execução; SDK/NDK provisionados pelo build |

Desativar configuration cache replica a opção do CI; não é alteração de código.
Criar arquivo local ignorado é preparação de ambiente, não modificação do upstream.

## Configuração de conta e validação real

O endpoint oficial `https://api.nuvio.tv/.well-known/nuvio` respondeu e declarou
version/service/backend_url/publishable_key/capabilities. É configuração pública
de cliente, não credencial de usuário. A implementação upstream usa configuração
gerada durante build; um arquivo sem esses valores não comprova login funcional.
Nenhuma senha, sessão, token de usuário ou conta de teste foi usada nesta fase.

Não executar/installar o app upstream sobre a instalação do usuário como parte
do baseline. Instalação independente só será verificada após a fundação.
