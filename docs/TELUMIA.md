# Telumia — identidade própria e catálogo brasileiro

Solicitação aprovada em 05/10/2026: substituir a marca do produto por **Telumia**, com logo original, repositórios próprios e prioridade para o Brasil. Esta alteração complementa o plano aprovado; não remove nenhum requisito anterior.

## Identidade

- Projeto: `Pepeu2010/telumia`.
- Cliente PC: `Pepeu2010/telumia-desktop`.
- Cliente TV: `Pepeu2010/telumia-tv`.
- Pasta solicitada: `Telumia - Open source`.
- Versão inicial da nova identidade: `0.2.0-alpha.1`, código 200 no PC e 2000 na TV. A versão publicada posterior é `0.2.1-alpha.1`, código 201 no PC e 2010 na TV.
- Identificador TV: `io.github.pepeu2010.telumia.tv`, com sufixo `.debug` nos APKs Full Debug.
- Dados/cache/atalhos/instalador Desktop usam Telumia. A nova identidade TV tem dados locais separados da antiga alpha; não desinstale a instalação anterior antes de recuperar suas preferências.
- Os recursos de launcher, ícones de tema e wordmarks são substituídos pelo novo símbolo. A escolha de tema mantém suas ações e semântica.

Namespaces internos e contratos de conta/sync/addons permanecem compatíveis. Créditos e licenças de código upstream devem ser preservados; não constituem a marca apresentada ao usuário. Releases anteriores são registros históricos e contêm os binários antigos, sem rebatizar seu conteúdo.

## Brasil e Iludida

Novos perfis usam `pt-BR` como idioma inicial dos metadados TMDB. Preferências explícitas existentes continuam válidas. A busca dos addons existentes consulta também aliases curados de Iludida: Sadakatsiz, The Unfaithful e A Woman Scorned. Resultados da mesma identidade/tipo são deduplicados dentro da origem. O título brasileiro é aplicado apenas à identidade verificada da série, evitando confusão com filmes ou obras de nome parecido.

As duas edições não possuem correspondência simples de capítulo. A [distribuidora](https://madd.tv/contents/detail/46) informa 149 capítulos de 45 minutos para a edição internacional; a [Apple TV Brasil](https://tv.apple.com/br/episode/episodio-78/umc.cmc.5yz3xsab8n2o014qobqqf3c00?showId=umc.cmc.g05tq9qgc2t19ewne06jiog2) identifica o capítulo 78 da primeira temporada. A identidade IMDb é [tt12879200](https://www.imdb.com/title/tt12879200/).

Para essa obra, a resolução de metadados procura a edição de pelo menos 78 capítulos entre as fontes de metadados instaladas; se não existir, conserva a edição disponível de 31, sem criar capítulos ou IDs fictícios. IDs de reprodução e números vêm da própria fonte. O enriquecimento de episódios TMDB da edição original é desativado quando a fonte oferece o corte internacional, para não copiar o resumo/thumbnail do episódio original 20 sobre o capítulo brasileiro 20.

Limites: aliases curados não substituem um catálogo brasileiro completo. A reprodução dos 78 capítulos exige uma fonte configurada que disponibilize essa edição. Um teste controlado com respostas de addon de 31/78 verifica a escolha e a preservação de IDs; não prova disponibilidade de conteúdo ou reprodução em serviço real. A paginação adicional continua vinculada à consulta principal do catálogo, sem misturar páginas das diferentes consultas de alias.

## Logo

Gerado com a ferramenta integrada `image_gen`: símbolo de televisão com fita em T, tons marfim/âmbar/coral, identidade original e fundo transparente. O banner usa o símbolo com o texto TELUMIA sobre fundo azul escuro. Os arquivos mestres estão em `assets/brand/`; as conversões PNG/WebP/ICO/ICNS são usadas pelos clientes nativos. Prompts registrados em `assets/brand/PROMPTS.md`.

## Continuidade

A implementação integral continua sendo a meta. Fase 1 completa, Profile Studio, cache Auto, timed metadata/player, Source Intelligence, Live TV/EPG, Scene Info e Phone Remote continuam com seus critérios originais. A mudança de marca e o ajuste Brasil não equivalem à conclusão dessas funcionalidades.
## Validação da entrega 0.2.0-alpha.1

Builds finais: 44 testes direcionados Desktop e 53 TV, sem falhas, erros ou skips; MSI Windows e cinco APKs Full Debug compilados. A inspeção confirma Produto Telumia, ponte Windows empacotada idêntica à compilada, cache WebView2 isolado e assinaturas dos APKs. O guard de compatibilidade passou. Tentativas anteriores e limites de suíte completa permanecem registrados em `telumia-results.json` e nos documentos baseline.

A captura de sidebar Desktop vem do teste Compose nativo com navegação por teclado. Não equivale a uma instalação Windows ou teste de reprodução real. O ambiente TV é um emulador Android TV API 36; não comprova desempenho em aparelho físico de 2 GB. A escala de movimento Windows ainda não acompanha automaticamente a preferência do sistema operacional.

## Publicação e pasta local

As três pré-releases `v0.2.0-alpha.1` estão publicadas. Os 22 assets remotos tiveram tamanho e digest SHA-256 comparados com os arquivos locais, conforme `telumia-release-verification.json`.

A pré-release posterior `v0.2.1-alpha.1` também está publicada nos três repositórios, com MSI Windows, APK universal e quatro APKs por arquitetura. Seus 22 assets tiveram digest, tamanho e commits dos clientes conferidos em [verificação da publicação](telumia-profile-studio-release-verification.json). Ela inclui os editores de avatar e as correções de persistência/GIF descritas em [Profile Studio](PROFILE_STUDIO.md). Alterações posteriores na seleção de perfis permanecem em `main` e não substituem os binários daquela release.

A renomeação física solicitada está pendente de liberação do Windows: o aplicativo Codex e seus processos MCP mantêm handles na pasta atual. A inspeção read-only com Microsoft Sysinternals Handle confirmou os bloqueios; nenhum handle foi fechado à força. `scripts/Rename-TelumiaWorkspace.ps1` foi iniciado como helper oculto, com destinos absolutos validados, sem copiar checkouts nem substituir diretórios. Ele efetua a renomeação quando a pasta for liberada e registra `telumia-workspace-rename.json` no diretório pai. Até esse registro existir, a pasta permanece com o nome anterior.
