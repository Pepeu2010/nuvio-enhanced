# Nuvio Enhanced

**Uma evolução open source do Nuvio para PC e Android TV, com mais recursos e uma experiência cinematográfica em desenvolvimento.**

O Nuvio Enhanced amplia os clientes existentes do [Nuvio](https://github.com/NuvioMedia). Os forks preservam a arquitetura nativa, o histórico do código e os sistemas de conta, perfis, biblioteca, addons e reprodução. As melhorias são integradas a essa base, mantendo os contratos existentes de login e sincronização. É um projeto independente, sem vínculo oficial com o Nuvio.

## Baixar e experimentar

A entrega atual é a **pré-release `v0.1.0-alpha.2` — incremento nativo 1-A.1**. Ela contém a fundação do fork e acrescenta a escolha de movimento de navegação nas configurações de Aparência dos clientes existentes. O visual completo e os demais recursos abaixo serão entregues progressivamente.

| Plataforma | Download |
|---|---|
| PC — Windows 64 bits | [Instalador MSI](https://github.com/Pepeu2010/nuvio-enhanced/releases/download/v0.1.0-alpha.2/NuvioEnhanced-Windows-x64.msi) |
| Android TV — recomendado quando não sabe a arquitetura | [APK universal de desenvolvimento](https://github.com/Pepeu2010/nuvio-enhanced/releases/download/v0.1.0-alpha.2/NuvioEnhanced-TV-universal-debug.apk) |
| Android TV — ARM 64 bits | [APK arm64-v8a](https://github.com/Pepeu2010/nuvio-enhanced/releases/download/v0.1.0-alpha.2/NuvioEnhanced-TV-arm64-v8a-debug.apk) |
| Android TV — ARM 32 bits | [APK armeabi-v7a](https://github.com/Pepeu2010/nuvio-enhanced/releases/download/v0.1.0-alpha.2/NuvioEnhanced-TV-armeabi-v7a-debug.apk) |
| Android — x86_64 / x86 | [Todos os arquivos da release](https://github.com/Pepeu2010/nuvio-enhanced/releases/tag/v0.1.0-alpha.2) |

Os APKs são builds **Full Debug**, assinados para desenvolvimento, destinados à experiência Android TV. O APK universal inclui as quatro arquiteturas. Ainda não há pacote Linux/macOS nem uma interface específica para celulares. Checksums SHA-256 e arquivos de código-fonte estão na [release](https://github.com/Pepeu2010/nuvio-enhanced/releases/tag/v0.1.0-alpha.2).

Esta versão é experimental: instalação, login, sync, reprodução e navegação por controle remoto ainda precisam de validação em aparelhos reais. A tag identifica a entrega do projeto; as versões internas herdadas são `0.1.27-alpha` no Desktop e `1.1.0-beta.3` na TV.

Ao trocar a alpha.1 pela alpha.2 no Windows, remova a instalação anterior do **Nuvio Enhanced** antes de instalar o novo MSI, pois a versão interna/identidade do MSI ainda é a mesma. No Android, instale o APK substituindo o build de desenvolvimento anterior. [Detalhes dos pacotes](docs/RELEASES.md).

No emulador, o APK universal instalou e o seletor funcionou por D-pad, incluindo persistência após reinício. A imagem Android x86_64 de 16 KB exigiu modo de compatibilidade para bibliotecas nativas; o login por QR falhou nesta sessão. Suporte nativo a 16 KB e conta/sync/playback permanecem pendentes. [Evidências e limitações](docs/NATIVE_FOUNDATION.md).

## O que já foi entregue

- Instalador, identificadores, diretórios de dados/cache e configuração de atualização próprios, para permitir a coexistência com o Nuvio oficial.
- Relatórios externos de falhas desligados por padrão, com a opção existente de consentimento preservada.
- Proteção de URLs com informações sensíveis nos diagnósticos de addons e sanitização dos campos Sentry revisados.
- Correção da recompilação da ponte nativa Windows quando seu código muda.
- Checkouts e commits de referência, auditoria de arquitetura/compatibilidade/segurança e builds baseline documentados.

Foram aprovados **31 testes direcionados Desktop e 84 TV**, além da compilação e inspeção dos pacotes. As **46 falhas herdadas** encontradas nas suítes completas do baseline continuam registradas. Esses resultados não substituem testes de reprodução e de uso em dispositivos. Veja [a entrega 0-C](docs/FOUNDATION.md) e [o baseline](docs/BASELINE.md).

O primeiro incremento **1-A.1** amplia Aparência e navegação existentes com movimento completo/reduzido/desligado salvo localmente por perfil. Foram aprovados **22 testes Desktop e 19 TV**, com novo MSI e APKs compilados e QA do seletor TV instalado em emulador. O incremento integra a alpha.2; o milestone visual completo continua em execução. [Implementação e alcance da validação](docs/NATIVE_FOUNDATION.md).

O código atual dos forks também contém **1-A.2, ainda fora da alpha.2**: motion no shell, foco dos cards e skeletons, com 25 testes Desktop e 15 TV aprovados e novos pacotes compilados. No APK novo, D-pad e geração do QR foram verificados em emulador após corrigir o provisionamento público. Conta/sync/playback e o restante do milestone visual continuam pendentes. [Evidências deste incremento](docs/motion-shell-ui-qa.json).

O incremento **1-A.3, também fora da alpha.2**, acrescenta intensidade Sutil, Padrão e Cinemática por perfil, com prioridade dos modos Reduzido/Desligado. Passaram 32 testes Desktop e 17 TV; MSI e cinco APKs foram compilados. O seletor Desktop passou por mouse/teclado; na imagem Android TV API 36, o APK universal passou por D-pad e persistência após reiniciar o app. O projeto continua na Fase 1: Home/redesign completo, Profile Studio, cache Auto, timeline, Live TV/EPG, Scene Info e Phone Remote permanecem pendentes. [Evidências e limites](docs/intensity-ui-qa.json).

## O que queremos acrescentar ao Nuvio

As próximas entregas ampliam os componentes existentes; os itens desta seção **ainda estão previstos**, não fazem parte da fundação publicada:

- **Experiência cinematográfica:** Home, hero e detalhes aprimorados, linguagem visual própria, feedback de foco e opções de animação reduzida ou desligada.
- **Cinematic Preview e Ambient UI:** evolução dos previews existentes, um preview silencioso por vez e cores discretas derivadas do backdrop.
- **Profile Studio:** arquivos locais, colar/arrastar imagens, biblioteca de avatares permitidos e editor de recorte, ampliando perfis/avatar/PIN existentes.
- **Player e timeline:** thumbnails reais, filmstrip, capítulos, bookmarks e painel técnico sobre libmpv no PC e Media3 na TV. Uma base genérica de timed metadata prepara o futuro Scene Info.
- **Source Intelligence:** escolha explicável de fontes, preferências de qualidade/idioma e compatibilidade do aparelho, preservando a escolha manual.
- **Cache adaptativo:** modo Auto e limites configuráveis; 1 GiB no Desktop e 256 MiB na TV são defaults iniciais. Downloads ficam separados.
- **Android TV:** foco/D-pad aprimorados e modos adequados a aparelhos modestos, com referência de 2 GB de RAM e 1080p.
- **Live TV e EPG:** canais e guia de fontes legítimas configuradas pelo usuário. Os componentes visuais serão preparados antes da integração, sem botões falsos.
- **Scene Info, Phone Remote e coleções:** informações de cena com origem confiável, controle local pelo celular e filtros/coleções sem dependência de IA cloud ou API paga.

A ordem de entrega e os critérios de aceitação estão no [roadmap](docs/ROADMAP.md). O app não inclui canais, listas ou conteúdo protegido; as fontes são configuradas pelo usuário.

## Código e arquitetura

| Repositório | Papel |
|---|---|
| [Nuvio Enhanced Desktop](https://github.com/Pepeu2010/nuvio-enhanced-desktop) | Cliente PC: Kotlin Multiplatform, Compose, libmpv/JNI e WebView2 |
| [Nuvio Enhanced TV](https://github.com/Pepeu2010/nuvio-enhanced-tv) | Cliente Android TV: Kotlin, Jetpack Compose, TV Material 3 e Media3 |
| Este repositório | Especificação aprovada, auditorias, referências e ferramentas de validação |

Desktop e TV permanecem forks separados, com seus históricos e licenças. Neste workspace, `repos/desktop` e `repos/tv` são checkouts independentes e ignorados pelo Git central. Não há uma terceira implementação do aplicativo.

## Desenvolver e validar

Os commits oficiais de referência estão em [upstream-lock.json](docs/upstream-lock.json); os commits da fundação estão em [fork-lock.json](docs/fork-lock.json). Os requisitos são mantidos em [APPROVED_SPEC.md](docs/APPROVED_SPEC.md) e [PRODUCT_REQUIREMENTS.md](docs/PRODUCT_REQUIREMENTS.md).

```powershell
# Restaura os checkouts sem descartar trabalho existente
.\scripts\Initialize-Workspace.ps1
.\scripts\Test-Workspace.ps1

# Execute na mesma sessão para manter a configuração local de build
.\scripts\Initialize-Development.ps1 -Target tv
.\scripts\Invoke-Baseline.ps1 -Target tv -Label development
```

Use JDK 17 e as versões de SDK/NDK registradas em [BASELINE.md](docs/BASELINE.md). O Desktop também exige o SDK WebView2 registrado nesse documento, passado com `-GradleArgs` como `-Pnuvio.webview2.dir=<caminho do SDK>`, e `--no-configuration-cache`. Execute builds grandes em sequência em máquinas com pouca memória. Consulte os scripts e READMEs de cada fork para os passos específicos.

Logs completos, outputs, configurações locais e chaves de assinatura ficam fora do Git. Antes de uma melhoria, localize a implementação existente, identifique seu ponto de extensão e preserve os fluxos de conta, sync, addons e reprodução.

## Licença e créditos

Os clientes derivados preservam a **GPL-3.0** e os avisos dos upstreams. Veja [LICENSE](LICENSE), [NOTICE.md](NOTICE.md) e os avisos de cada fork. Obrigado aos contribuidores do [NuvioMedia](https://github.com/NuvioMedia) pela base que este projeto evolui. Nuvio Enhanced é um nome provisório de um fork não oficial.
