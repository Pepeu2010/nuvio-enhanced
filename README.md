# Telumia

![Telumia](assets/brand/telumia-banner.png)

**Seu cinema, suas séries e novelas — com foco no Brasil.**

Telumia é um media center open source para PC e Android TV, com marca própria e uma experiência cinematográfica em evolução. Usa os clientes nativos e o ecossistema do Nuvio como base técnica, preservando contas, biblioteca, progresso, addons Stremio e os motores de reprodução.

O projeto acrescenta busca voltada ao Brasil, editores de avatar, cache configurável, navegação por teclado/controle, movimento adaptável e melhorias de Home, detalhes, timeline e sincronização. O redesign integral e os demais recursos do [plano aprovado](docs/ROADMAP.md) continuam em implementação.

## Baixar e instalar

Na [release 0.2.1-alpha.1](https://github.com/Pepeu2010/telumia/releases/tag/v0.2.1-alpha.1), escolha:

| Aparelho | Arquivo |
|---|---|
| PC Windows de 64 bits | Instalador `.msi` |
| Android TV, sem precisar identificar a arquitetura | APK **universal** |
| Android TV, quando a arquitetura for conhecida | APK `arm64-v8a`, `armeabi-v7a`, `x86` ou `x86_64` |

Confira os checksums SHA-256 incluídos na release. Os APKs atuais são **Android TV Full Debug**, assinados para desenvolvimento. Ainda não há interface específica para celulares nem pacotes Linux/macOS publicados.

**A release publicada e o código atual têm alcances diferentes.** A `0.2.1-alpha.1` inclui a identidade Telumia, busca Brasil, incrementos de Home/detalhes, metadata temporal, cache configurável e editores locais de avatar. As entregas posteriores de perfis, previews, momentos salvos e sincronização ainda aguardam uma nova release. Os arquivos das versões anteriores são preservados.

## Melhorias já implementadas

- **Brasil:** português do Brasil como idioma inicial dos metadados em perfis novos e busca com nomes alternativos de obras. Preferências salvas são preservadas.
- **Home e detalhes:** destaque cinematográfico, metadata real, ações de reprodução/biblioteca e foco próprio para teclado e D-pad. [Entrega e capturas](docs/TELUMIA_HOME.md), [detalhes](docs/CINEMATIC_DETAILS.md).
- **Profile Studio:** 64 avatares licenciados e editor local com importação, recorte, zoom e versões otimizadas. O PC também oferece clipboard e drag-and-drop. Avatares pessoais ficam isolados por conta/perfil no aparelho. [Alcance e validação](docs/PROFILE_STUDIO.md).
- **Cache Auto/Manual:** orçamento ajustável ao aparelho e espaço livre. 1 GiB no PC e 256 MiB na TV são defaults iniciais configuráveis. A integração de todos os caches e o funcionamento offline completo continuam pendentes. [Política de cache](docs/MEDIA_CACHE.md).
- **Navegação e movimento:** menu lateral com feedback de foco/seleção, transições nas principais rotas e movimento Completo, Reduzido ou Desligado. [Conta, menu e motion](docs/ACCOUNT_SYNC_MOTION.md).
- **Movimento no player PC:** painéis e controles nativos seguem a preferência de movimento e intensidade do perfil, com navegação por teclado e tempos de interação preservados. [Builds e validação visual](docs/NATIVE_PLAYER_MOTION.md).
- **Timeline e momentos salvos:** eventos temporais disponíveis de intro, recap e créditos nos dois players; momentos com nome/data, renomear, remover e voltar à cena no código PC e TV. No PC, o botão do player e a tecla D abrem o painel; a tecla B continua alternando áudio. Os momentos ficam neste aparelho, por conta/perfil/episódio, com confirmação para outra fonte. A reprodução e o seek reais continuam com gates próprios. [Timeline](docs/TIMED_METADATA.md), [momentos](docs/SCENE_BOOKMARKS.md).
- **Miniaturas no player PC:** a timeline solicita frames a um decoder libmpv separado, com cancelamento e cache por conta/perfil/fonte. A imagem aparece somente quando corresponde à posição solicitada. A extração JNI real de vídeo local passou pelos testes; filmstrip, TV, fontes remotas/HDR e validação do player completo ainda estão pendentes. [Evidências](docs/NATIVE_TIMELINE_FRAMES.md).
- **Mesma conta:** atualização de perfis, configurações suportadas, addons, plugins, biblioteca, progresso, coleções e Home ao retornar ao app e periodicamente em atividade. Coleções e addons nos dois clientes possuem mesclagem durável de alterações pendentes. A comprovação ponta a ponta com a conta nos clientes oficial e Telumia continua pendente. [Evidências e limites](docs/ACCOUNT_SYNC_MOTION.md).

### Novelas e edições brasileiras

Buscar **Iludida** também consulta **Sadakatsiz**, **The Unfaithful** e **A Woman Scorned**, preservando a identidade da obra. Quando um catálogo instalado oferece a edição brasileira de **78 capítulos**, o Telumia usa seus IDs de reprodução e numeração. Se a fonte só oferece a edição de **31 episódios**, conserva essa edição, sem inventar capítulos.

As edições têm durações e divisões diferentes. É necessário configurar uma fonte que ofereça o corte desejado. A proteção de metadados evita aplicar resumos e miniaturas de outra edição sobre essa numeração. [Implementação e limites](docs/TELUMIA.md).

## O que continua em desenvolvimento

O objetivo é transformar toda a experiência dos clientes existentes, conforme a [meta integral](docs/GOAL_OBJECTIVE_2026-10-05.md). Ainda não estão concluídos o redesign completo de todas as telas, previews de vídeo embutidos no Windows, thumbnails/filmstrip, Scene Info, Source Intelligence, Live TV/EPG, Phone Remote, downloads avançados, Smart Collections e os demais critérios do plano. Os componentes preparatórios de TV/EPG não aparecem como funcionalidades prontas.

Os incrementos de previews já têm exclusividade, cancelamento, timeout e preload conservador; vídeo remoto e desempenho físico ainda precisam de validação. [Previews](docs/PREVIEWS.md). Recursos locais exclusivos, como arquivos de avatar e momentos salvos, não são anunciados como sincronizados com formatos que o cliente oficial não suporta.

## Código e evidências

| Repositório | Plataforma |
|---|---|
| [telumia](https://github.com/Pepeu2010/telumia) | Documentação, evidências e releases |
| [telumia-desktop](https://github.com/Pepeu2010/telumia-desktop) | Kotlin Multiplatform/Compose, libmpv e ponte nativa Windows |
| [telumia-tv](https://github.com/Pepeu2010/telumia-tv) | Kotlin/Compose TV e Media3 |

Cada cliente mantém seu histórico e build; a implementação amplia os aplicativos existentes. Commits de referência e binários de desenvolvimento ficam vinculados nos [registros do projeto](docs/fork-lock.json). Testes selecionados, builds e QA nativa têm evidências próprias; não equivalem a prova integral de conta, playback ou desempenho em aparelho físico. As falhas herdadas das suítes completas permanecem documentadas na [fundação](docs/NATIVE_FOUNDATION.md).

## Conteúdo e licenças

O aplicativo não inclui canais, listas ou conteúdo protegido. Configure fontes que você tenha autorização para usar. Código GPL-3.0, com avisos e [créditos de origem preservados](docs/UPSTREAM_CREDITS.md). O nome, logo, ícones e identidade visual Telumia são próprios.
