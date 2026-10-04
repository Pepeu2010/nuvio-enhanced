# Roadmap e milestones verificáveis

Source of truth: APPROVED_SPEC.md + PRODUCT_REQUIREMENTS.md. Não há autorização
para trocar stack, login/backend, remover recursos ou publicar como oficial.

## Estado desta execução

- Checkouts oficiais dos seis projetos concluídos e commits registrados.
- Auditoria estática e matriz de lacunas/contratos produzidas.
- Builds baseline Desktop e TV executados em fontes sem alterações. MSI e APKs
  gerados; suítes com 26/20 falhas herdadas, preservadas em BASELINE.md e JSONs.
- 0-A e 0-B concluídos com ressalvas; 0-C implementado, testado e compilado.
- Fundação: 31 testes direcionados Desktop e 84 TV aprovados; MSI/APKs do fork
  gerados. Código e commits independentes publicados no GitHub; detalhes e limites
  em FOUNDATION.md. Pré-release 0-C publicada com MSI, APK universal/quatro ABIs,
  fontes e hashes; registro em RELEASES.md.
- 1-A em execução: incremento 1-A.1 de movimento por perfil integrado a Aparência,
  tokens e navegação existentes; 22 testes Desktop e 19 TV aprovados, MSI/APKs
  compilados. QA do seletor Desktop e do APK instalado em emulador concluído,
  com seleção por D-pad, retorno de foco e persistência após reinício.
  Incremento distribuído na alpha.2; detalhes/limites em NATIVE_FOUNDATION.md.
  A identidade/shell completa e o QA global continuam pendentes; não se avançou
  para 1-B nem se declarou o redesign concluído.
- Nenhuma fase de produto é declarada concluída apenas pela auditoria.

## Gates e entregas

| Milestone | Entrega concreta | Gate |
|---|---|---|
| 0-A | Checkouts, source lock, inventário real, cinco documentos | Todos os commits identificados; ausência de edits de aplicação no baseline |
| 0-B | Tests/build MSI Desktop e APK TV baseline | Exit codes, logs, outputs e alterações registrados; falhas classificadas |
| 0-C | Primeira fundação: identidade, paths, updater, redaction e regressão de contratos | Testes direcionados + builds; nenhuma alteração em conta/sync/engine |
| 1-A | Tokens/motion e shell nativo próprio por plataforma | Sem rotas perdidas; Reduced Motion/off; QA teclado/D-pad |
| 1-B | Home e detalhes preservando repositories/actions | Loading/empty/error e navegação real; lazy rendering |
| 1-C | Profile Studio/import/crop + biblioteca original/licenciada | Validação de arquivos; isolamento e alcance local explícito |
| 1-D | Image/cache foundation Auto e configurável; tokens/componentes EPG/Live TV | Quotas, eviction e storage reserve testados; nenhuma rota falsa de TV exposta |
| 2-A | Timed metadata genérica integrada a player/timeline | Intervalos/eventos e proveniência; adapters de chapter/skip/bookmark |
| 2-B | Player UI, thumbnails e filmstrip básico | Superfície JNI/WebView2 Windows e Media3 TV realmente testadas; timestamps corretos |
| 2-C | Bookmarks, áudio/subtitles/chapters/stats/transições | Persistência por profile/media; valores técnicos não inventados |
| 3 | PreviewCoordinator, hero, Ambient UI e transições | Um preview, silêncio default, lifecycle e cancelamento; perf budget |
| 4 | DeviceCapabilities, scoring/pre-flight/modos | Unknown explícito, parcelas do score testadas, escolha manual mantida |
| 5 | Completar TV UX e performance adaptativa | D-pad integral, retorno de foco, hardware 2 GB e QA 720p/1080p/4K |
| MVP 1 | Todos os requisitos obrigatórios do primeiro release | Login/sync/playback reais e builds; nenhum requisito obrigatório omitido |
| 6 | Live TV, source integration, channel model, EPG, favoritos/recents/troca rápida | Fonte legítima configurada; timezone/cache/foco do grid testados |
| 7 | Scene Info via providers confiáveis sobre timed metadata da Fase 2 | Proveniência/confiança; ausência não vira identidade inferida |
| 8 | Phone Remote local, QR/pairing/WS/teclado/controles | Confirmação, expiração/revogação, Origin, limites e sem exposição WAN default |
| MVP 2 | Live TV/EPG, failover avançado, remote, Smart Collections, downloads/Spoiler Shield | Integrações reais e limites das fontes documentados |
| MVP 3 | Advanced filmstrip, Scene Info, análise local, timeshift/multi-view/recomendações | Experimental flags e orçamento de decoders/disco; dados licenciados |

## Implementação incremental

Cada milestone: inspecionar call sites → registrar impacto → implementar →
testar → compilar → corrigir regressões → QA → documentar → commit.
PRs serão feitos no fork quando houver remoto próprio; não enviar redesign ao
upstream. Branches locais seguem `codex/`. O usuário autorizou criar e publicar
os repositórios GitHub em 2026-10-04; releases instaláveis terão gates próprios.

A Fase 2 fornece `TimedMetadata` genérica com media/episode identity, intervalo
ou instante, tipo, origem e dados do item; providers Scene Info entram depois.
Não acoplar playback a IMDb ou a um serviço de reconhecimento.

Cache Auto considera espaço livre, capacidade de memória/decoder e uso atual;
1 GiB/256 MiB são defaults ajustáveis, não constantes definitivas. Override do
usuário é validado contra condições operacionais e não apaga downloads.

Fase 1 prepara estilo/foco de channel tile, now-next, progress e program cell;
somente storybook/previews/testes internos até haver implementação real na Fase 6.

## Evidência e critérios

Baseline limpo não é aceitação de produto. Usar fixtures de protocolo locais,
fontes autorizadas e medições separadas. Visual QA: Desktop 1366x768, 1080p,
1440p e 4K; TV 720p, 1080p e 4K, texto grande/overscan/foco.
Meta de navegação 60 FPS e focus p95 abaixo de 100 ms; medir aparelho/contexto.
Emulador não demonstra performance de TV Box, HDR nem hardware decoder.

Funções secundárias do documento original — busca Ctrl+K, histórico visual,
Escolha para mim, Guest/Kids, webcam/animated avatars, Cinema/Living Room/Ambient
Mode — recebem incrementos próprios, preservando seu comportamento/capability.
Nunca anunciá-las como prontas antes de implementação/QA.
