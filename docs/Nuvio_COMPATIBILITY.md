# Compatibilidade com o ecossistema Nuvio

Contratos abaixo foram encontrados nos clientes fixados; migrations self-host
servem para conferir assinaturas, não para afirmar o estado do backend oficial.
Esta auditoria não usou uma conta real nem escreveu no servidor.

## Fronteira de integração

- Preservar autenticação Supabase, sessão/refresh, email e linking existentes.
- Manter backend oficial e customizado conforme configuração suportada.
- Não inventar endpoints, expandir limite de perfis nem reutilizar credenciais
  privadas oficiais para builds do fork.
- Não enviar preferências/caminhos locais Enhanced no payload oficial.
- Isolar dados por backend + conta + perfil. Uma troca de conta invalida jobs e
  resultados tardios; uma falha de rede não equivale a exclusão remota.

## Contratos encontrados

| Superfície | Operações existentes | Fonte / invariantes a preservar |
|---|---|---|
| Autenticação | signInWith(Email), signUpWith, sessionStatus, clearSession; linking RPCs | Desktop core/auth; TV core/auth; manter política de sessão inválida vs offline |
| Perfis | sync_pull_profiles, sync_push_profiles, sync_delete_profile_data | ProfileRepository / ProfileSyncService; índices e limite atual |
| PIN | verify_profile_pin, set_profile_pin, clear_profile_pin, sync_pull_profile_locks | Preservar confirmação/estado offline; não enfraquecer por troca de UI |
| Library | sync_pull_library, sync_push_library_items, sync_delete_library_items; cursor/delta | SupabaseLibrarySyncAdapter / LibrarySyncService; tombstones/reconciliação |
| Progresso | sync_pull_watch_progress, sync_push_watch_progress, sync_delete_watch_progress; cursor/delta | SupabaseProgressSyncAdapter / WatchProgressSyncService; identity e posição |
| Watched/histórico | sync_pull_watched_items, sync_push_watched_items, sync_delete_watched_items; cursor/delta | SupabaseWatchedSyncAdapter / WatchedItemsSyncService; não inferir de bookmark |
| Addons | leitura de addons; sync_push_addons | AddonRepository / AddonSyncService; URLs/config por perfil e primary addons |
| Plugins | leitura de plugins; sync_push_plugins | Plugins Full e PluginSyncService; distinto de addon HTTP |
| Configurações | sync_pull_profile_settings_blob, sync_push_profile_settings_blob | ProfileSettingsSync; namespaces/schemas suportados e credenciais separadas |
| Setup de perfil | sync_copy_profile_setup no cliente TV | Descobrir parâmetros antes de expor clone; não presumir cópia de histórico |
| Home | sync_pull_home_catalog_settings, sync_push_home_catalog_settings | HomeCatalogSettingsSyncService; ordem/catalog identity |
| Coleções | sync_pull_collections, sync_push_collections | CollectionSyncService; preservar representação existente |
| Credenciais providers | sync_pull_provider_credentials; TV seed/push | ProviderCredentialSync; política de segredos e seleção de tracking |
| Catálogo de avatar | get_avatar_catalog; member catalog em cliente Desktop | AvatarRepository; manter entitlement do servidor; biblioteca local nova independente |

Provider credentials já são parte do código de sync. Sua presença não autoriza
logá-las, duplicá-las para o Phone Remote ou transmitir para addons arbitrários.

## Addons Stremio

Preservar manifest/catalog/meta/stream/subtitles, resources string/object,
types/idPrefixes, catalogs/extras, behaviorHints, configuração, autenticação,
URL de transporte e assets relativos. Não remover query/path da URL operacional
quando redigindo logs. Não inventar endpoints para thumbnails ou EPG.

Fixtures de regressão terão servidor HTTP local e respostas autorizadas,
incluindo URL configurada com segredo sintético, HTTP de usuário/LAN, falha de
um addon, cancelamento, payload inválido, campos opcionais/desconhecidos e
configuração necessária. Diagnóstico não fará instalação ou chamada invasiva.

## Dados exclusivos Enhanced

Tema/cover local, preview/motion, performance, cache Auto, bookmarks, timed
metadata cache, Smart Collections e avatares locais ficam na camada própria.
`file:` ou paths locais nunca viram avatar_url sincronizado. A UI identificará
alcance local/cross-device com honestidade. A biblioteca de avatares incluída será
original ou licenciada e não desbloqueará catálogo member do backend.

## Matriz de verificação

| Cenário | Evidência atual | Gate de release |
|---|---|---|
| Contratos em source | Inspecionados e registrados | Fixtures e testes passam em ambos os clientes |
| Login existente | Código preservado; conta real não testada | Login/refresh/logout e reentrada em conta de teste autorizada |
| Sync oficial ↔ fork | Não executado | Biblioteca/progresso/histórico sem perda, inclusive offline e troca de perfil |
| Playback/provider real | Não executado | Fonte autorizada; tracks, resume, seek e saída limpa |
| Instalação lado a lado | Planejada, ainda sem alteração | Dados/updater/signing/protocolos separados; dados oficiais intactos |
| Avatar local | Planejado | Importação validada; sem payload local no sync |

Não considerar testes com servidor local como validação do serviço oficial.
Configurações públicas de cliente podem ser provisionadas por mecanismo oficial
documentado; senhas de usuário, cookies, service-role e chaves de release não
serão coletados nem colocados no repositório.
