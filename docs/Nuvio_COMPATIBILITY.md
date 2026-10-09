# Compatibilidade com o ecossistema Nuvio

Contratos abaixo foram encontrados nos clientes fixados; migrations self-host
servem para conferir assinaturas, não para afirmar o estado do backend oficial.
Esta auditoria não usou uma conta real nem escreveu no servidor.

## Continuação autorizada: conta e sincronização em 08/10/2026

A solicitação vigente amplia a implementação para atualização e mesclagem
bidirecionais da mesma conta. Os incrementos de coordenador, ownership e journal
local utilizam as tabelas/RPCs existentes: não acrescentam um backend ou um
protocolo incompatível. As entradas de coleção continuam sendo o JSON existente;
addons continuam usando URL, nome, ativação e `sort_order`. Journals, revisões e
chaves de armazenamento ficam privados no aparelho, fora do payload oficial.

`Test-CompatibilityFoundation.ps1` mantém as referências upstream e aceita somente
os blobs revisados exatos de coordenadores/helper local descritos em
[ACCOUNT_SYNC_MOTION.md](ACCOUNT_SYNC_MOTION.md). Uma alteração posterior nesses
arquivos ou nos demais caminhos protegidos exige revisão concreta do source.
O teste estático não prova sync remoto; testes com dependências controladas,
builds e resultados do menu têm evidência separada. A matriz de conta real abaixo
permanece aberta. Os registros de exceções anteriores preservam sua evidência
histórica, anterior a esses incrementos.

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

## Diferenças concretas da referência self-host

O inventário automático encontrou 87 call sites literais de RPC. Dez nomes
usados pelos clientes não foram encontrados como declarações nas migrations
self-host fixadas: start_device_login_session, get_my_member_access,
get_my_membership_overview, get_member_profile_background_catalog,
get_member_profile_avatar_catalog, sync_copy_profile_setup, generate_sync_code,
get_sync_code, claim_sync_code e unlink_device.

Isso não prova ausência no backend oficial, mas impede afirmar paridade total
do self-host antigo com os clientes atuais. Linking, membership e clone de setup
precisam tratar disponibilidade de forma independente. Não criar esses endpoints
no servidor oficial nem anunciar a função como suportada a partir de sua presença
em um cliente. O inventário literal não inclui todas as chamadas multiline/dinâmicas.

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

## Exceção delimitada: diagnósticos de autenticação TV

O achado de códigos temporários nos logs exigiu mudanças no diretório protegido
`core/auth`. `AuthManager` teve somente chamadas de Log.e/Log.w alteradas: a
comparação com o baseline, removendo apenas essas linhas, permaneceu idêntica.
`AuthDiagnostics` altera a projeção de request/response, detalhes, mensagens,
URLs e exceções nos relatórios; os DTOs e endpoints permanecem intactos.
O valor usado pelo login/QR continua original; a redaction atua nas cópias de
diagnóstico. `AccountViewModel` também deixa de passar Throwable bruto ao logger.

`Test-CompatibilityFoundation.ps1` registra o blob baseline e o blob revisado
exato de somente esses dois arquivos. Qualquer outra alteração neles falha,
e o restante de auth/sync/APIs/DTOs continua comparado ao upstream. Esta exceção
não libera alterações arbitrárias no diretório nem valida conta/sync remoto.
Passaram 36 testes direcionados e os cinco APKs foram compilados. QR gerou
no APK instalado, com marcadores no log e sem o código exibido nele. Conta/sync
permanecem pendentes. Evidências em
`auth-redaction-results.json` e `auth-redaction-ui-qa.json`.

A continuação aplica a projeção segura na fila existente antes de reenviar,
em novas gravações e no upload. O blob revisado de `AuthDiagnostics` foi
atualizado especificamente; APIs/DTOs/sync continuam protegidos. Passaram 37
testes direcionados e cinco APKs compilaram. Migração e idempotência foram
testadas em arquivos temporários sintéticos, sem upload ou conta reais:
`auth-queue-results.json`. Não é uma migração automática de todos os arquivos
no startup: atua ao acessar a fila para retry/gravação.
