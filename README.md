# Telumia

![Telumia](assets/brand/telumia-banner.png)

**Seu cinema, suas séries e novelas — com foco no Brasil.**

Telumia é um aplicativo open source para PC e Android TV. Reúne catálogos, biblioteca, perfis e reprodução de fontes configuradas por você, com uma experiência cinematográfica e navegação por controle remoto.

## Downloads

Os instaladores Windows e APKs universal/por arquitetura ficam na [página de releases](https://github.com/Pepeu2010/telumia/releases). A nova identidade Telumia usa a versão **0.2.0-alpha.1**. Releases anteriores preservam seus arquivos e nomes históricos; não contêm a marca ou as alterações Brasil desta entrega.

Os APKs disponíveis nesta etapa são Android TV Full Debug, assinados para desenvolvimento. Não há interface específica para celulares nem pacotes Linux/macOS publicados. Cada release informa o alcance da validação e inclui checksums SHA-256.

## Marca própria e prioridade para o Brasil

- Logo original, nome Telumia, ícones, banners de TV e instalador próprios.
- Português do Brasil como idioma inicial dos metadados TMDB em perfis novos, preservando preferências salvas.
- Busca por **Iludida** também consulta **Sadakatsiz**, **The Unfaithful** e **A Woman Scorned**, sem confundir a série com obras de identidade diferente.
- A resolução de metadados procura a edição brasileira de 78 capítulos entre as fontes instaladas. Preserva os IDs de reprodução e a numeração da origem. Se o catálogo instalado só oferecer a edição de 31 episódios, conserva essa edição; não cria capítulos fictícios.
- Proteção contra aplicar títulos/resumos/miniaturas de episódios da edição original sobre a numeração do corte brasileiro.

As edições têm durações e divisões diferentes. Para assistir aos 78 capítulos é necessário configurar uma fonte que ofereça essa edição. [Implementação, fontes e limites](docs/TELUMIA.md).

## Recursos existentes e melhorias em andamento

Os clientes nativos preservam contas, perfis, biblioteca, addons, busca e seus players. A fundação acrescenta movimento completo/reduzido/desligado e intensidade por perfil, proteção de diagnósticos e melhorias de foco/menu lateral. A escolha de menu clássico/moderno na TV preserva configurações abertas, foco e a ação Voltar.

A implementação integral continua em execução. O redesign completo de Home/detalhes, Profile Studio, cache Auto, thumbnails/timeline, Source Intelligence, Live TV/EPG, Scene Info e controle local pelo celular **ainda não estão concluídos**. Não apresentamos controles de funcionalidades inexistentes. Os critérios completos permanecem no [roadmap aprovado](docs/ROADMAP.md) e na [especificação](docs/APPROVED_SPEC.md).

## Código e desenvolvimento

| Repositório | Plataforma |
|---|---|
| [telumia](https://github.com/Pepeu2010/telumia) | Documentação, evidências e releases |
| [telumia-desktop](https://github.com/Pepeu2010/telumia-desktop) | Kotlin Multiplatform/Compose, libmpv e ponte nativa Windows |
| [telumia-tv](https://github.com/Pepeu2010/telumia-tv) | Kotlin/Compose TV e Media3 |

Cada cliente mantém seu build e histórico. Não há um aplicativo paralelo. Os commits upstream, builds baseline e auditorias estão documentados nesta árvore. As 46 falhas herdadas das suítes completas permanecem registradas; testes direcionados não equivalem à validação integral de conta, sincronização, playback ou performance em aparelho físico. [Fundação e evidências](docs/NATIVE_FOUNDATION.md).

## Conteúdo e licenças

O aplicativo não inclui canais, listas ou conteúdo protegido. Configure fontes que você tenha autorização para usar. Código GPL-3.0, com avisos e [créditos de origem preservados](docs/UPSTREAM_CREDITS.md). A identidade visual Telumia é própria.
