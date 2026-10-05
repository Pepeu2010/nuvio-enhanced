# Lacunas de funcionalidades

Comparação dos commits em upstream-lock.json. **Existente** significa evidência
no código, não teste runtime concluído. **Parcial** indica uma base já útil.
**Não localizado** restringe a conclusão à busca nos source sets auditados.

Desktop: prefixo `composeApp/src/commonMain/kotlin/com/nuvio/app`; TV: prefixo
`app/src/main/java/com/nuvio/tv`. Bridges e flavors adicionais são citados abaixo.

| Requisito | Desktop atual | TV atual | Evolução Enhanced / evidência principal |
|---|---|---|---|
| Login Nuvio | Existente | Existente | Preservar AuthRepository / core/auth/AuthManager |
| Backend customizado | Existente | Existente no Full | Preservar discovery/config; core/network/ServerConfiguration e data/local/ServerConfigurationStore |
| Library/progress/watched sync | Existente, inclusive deltas | Existente, inclusive deltas | Testar reconciliação; watching/sync e core/sync |
| Addons Stremio | Existente | Existente | Preservar parser/API e configuração; features/addons e data/remote/api/AddonApi |
| Plugins executáveis | QuickJS no Full | QuickJS no Full | Preservar com auditoria separada de host APIs/quotas |
| Addon Manager | Instalação, enable, refresh, ordem | Repository e telas existentes | Evoluir descoberta/atualizações/diagnóstico, sem instalar providers embutidos |
| Tokens visuais | core/ui/Tokens e Theme | ui/theme com famílias de tokens | Evoluir; não criar segundo sistema conflitante |
| Home e detalhes | Existentes | Existentes, múltiplos layouts | Evoluir experiência preservando ações/repos e lazy loading |
| Home reorganizável | HomeCatalogSettingsRepository | HomeCatalogSettingsSyncService | Ampliar controles e manter regras do sync atual |
| Hover/focus previews | HomePosterHoverPreview/Trailer | TrailerPlayerPool, focused poster target | Coordenar globalmente, silêncio default e debounce configurável |
| Hero/trailers | HeroTrailerSelector e superfícies | TrailerService/SharedTrailerOverlay | Evoluir lifecycle/ambient, não criar resolução duplicada |
| Ambient UI | Temas/depth como base parcial | ClassicFocusGradientBackdrop como base parcial | Palette com contraste e orçamento adaptativo |
| Perfis/avatares | ProfileSelection/Edit, AvatarRepository | ProfileSelection e AvatarRepository | Profile Studio; biblioteca original/licenciada; editor local |
| PIN | RPC e verificação offline cacheada | ProfileSyncService | Preservar; não alegar Kids completo só pela presença de PIN |
| Clonar setup | Não localizado como fluxo completo | sync_copy_profile_setup em ProfileSettingsSyncService | Mapear seleção já suportada; jamais copiar dados pessoais implicitamente |
| Avatar arquivo/drop/clipboard/crop | Editor completo não localizado | Editor completo não localizado | Adicionar no Desktop e importação suportada na TV; local != sync |
| Player/áudio/legendas | Compose + native bridges/libmpv | Media3 e integrações opcionais | Renovar UX sem trocar motores |
| Seek TV progressivo | Não aplicável ao mouse | PlayerScrubRates já existente | Integrar thumbnails e filmstrip, preservar comportamento curto |
| Scene thumbnails/filmstrip | Não localizado; thumbnail de episódio não é frame de seek | Não localizado no player; metadata MKV não prova UI de seek | Implementar provider + extração isolada e indisponibilidade honesta |
| Timed metadata | Tipos de skip existentes, sem abstração genérica localizada | Regras de skip existentes | Fase 2: intervalos/eventos genéricos ligados ao player/timeline |
| Scene Bookmarks | Não localizado | Não localizado | Persistência local por conta/perfil/media/episódio |
| DeviceCapabilities | Verificações por plataforma | DisplayCapabilities e seleção de decoder | Adaptador central, preservar Unknown |
| Source Intelligence | Seleção/autoplay e informações de stream | StreamScreenViewModel e seleção | Scoring explícito/testável, sem medir o que não foi observado |
| Failover avançado | Fluxos de troca/retry como base | Fluxos de troca/retry como base | Estado/posição e tentativas finitas no MVP 2 |
| Download Manager | DownloadsRepository e plataforma | Paridade completa não verificada | Evoluir o existente; não presumir pause/resume de todas as fontes |
| Coleções | CollectionRepository/sync | CollectionSyncService | Smart Collections é evolução distinta dos agrupamentos existentes |
| Histórico/progresso | Watched/WatchProgress existentes | WatchedItems/WatchProgress existentes | Página cronológica e estatísticas locais, sem telemetria |
| Spoiler Shield | Controles pontuais; completo não localizado | Flags/blur pontuais; completo não localizado | Off/Basic/Strict sobre episódio não assistido no MVP 2 |
| Foco TV | UI Desktop/teclado | HomeScreenFocusState, FocusRestoreUtils | Ampliar testes e integrar dialogs, EPG e listas incrementais |
| Performance adaptativa | Pipeline de imagens e settings como base | Tokens, pool e capabilities como base | Auto/Performance/Balanced/Cinematic, referência 2 GB |
| Live TV/EPG | Área completa não localizada | AndroidTvChannelSync é integração com launcher, não EPG de TV ao vivo | Tokens/componentes Fase 1; implementação real Fase 6 |
| Phone Remote | Não localizado | Não localizado | Fase 8, LAN opt-in, pairing confirmado/revogável |
| Scene Info | Não localizado | Não localizado | Fase 7, metadata confiável; usar abstração da Fase 2 |
| Timeshift/multi-view | Não localizado como fluxo completo | Não localizado como fluxo completo | MVP 3 experimental, limites de disco/decoders e flags |

Não usar esta matriz para remover funcionalidades existentes: integrações de
tracking, plugins, P2P, idiomas, configurações e flavors permanecem no inventário.
Para cada fase, confirmar o call site e execução antes de classificar a entrega
como completa. Busca negativa não demonstra inexistência absoluta.
