# Threat model — Nuvio Enhanced

Fase 0: análise estática, não auditoria de segurança completa. Fonte de verdade:
commits em upstream-lock.json. Reavaliar antes de cada nova fronteira de IO.

## Ativos e trust boundaries

Ativos: sessão/refresh, credenciais de providers, histórico/biblioteca por perfil,
arquivos do usuário, downloads, chaves de assinatura, memória/decoder/disco e
controle de reprodução. Fronteiras: backend confiável configurado; addon HTTP;
plugin QuickJS; imagens/subtitles/media; bridge nativa/WebView2; filesystem;
updater; browser/dispositivo LAN pareado.

Metadata e nomes vindos de addon são dados não confiáveis. Um manifest não é
permissão para filesystem, shell, câmera, clipboard, conta ou controle remoto.
Imports/câmera/clipboard sempre partem de ação do usuário e capability real.

## Ameaças e mitigação por milestone

| Ameaça | Observação concreta / risco | Controle e teste requerido |
|---|---|---|
| Token leakage | Desktop AddonRepository imprime manifestUrl; HTTP traces podem conter URLs configuradas | Redigir userinfo, query/path secret e exceptions antes do sink; usar ID opaco de addon; testar segredos sintéticos |
| MITM addon | TV NetworkModule mantém trust-all/hostnameVerifier permissivo no cliente separado de addons | Nunca usar em first-party; evolução para política por origem com consentimento e migração; testar TLS válido/inválido |
| Malicious metadata / HTML | Player Windows usa UI local WebView2, comunicação por mensagens | Tratar texto como texto, validar esquema de mensagem/origem e não aceitar navegação arbitrária |
| URL maliciosa / SSRF equivalente | App local aceita URLs de addons/providers | Permitir fontes HTTP/HTTPS configuradas, inclusive LAN legítima; rejeitar esquemas executáveis e expansão de redirects não autorizada em novos serviços |
| Plugin injection/exaustão | QuickJS possui timeout e limites parciais; isolamento de processo não comprovado | Auditar host APIs, fetch, WASM e quotas; sem host shell/fs arbitrário; testar cancelamento e payloads excessivos |
| Avatar inválido/decompression bomb | Novo arquivo local/URL e decoder | Magic bytes/MIME real, byte/pixel/frame limits, tempo, orientação, crop e thumbnails; reject paths/formatos não suportados |
| Path traversal/download/archive | Arquivos e nomes vindos de fonte | Canonicalizar destino dentro da pasta escolhida, validar nomes, escrita atômica; não extrair arquivo sem política de symlink/path |
| Command execution | Downloader Desktop abre diretório com ProcessBuilder de argumentos | Nenhuma concatenação para shell; allowlist de operações nativas e paths; não aceitar executable/argumentos de addon |
| Cross-account data leak | Repositories globais e jobs assíncronos | Ownership backend/conta/perfil, cancelamento e descarte de resposta tardia; testar troca durante request |
| Cache/storage exhaustion | Várias categorias/cache providers | Auto + override configurável, quotas, reserve space, TTL/eviction e cleanup; downloads fora do cache |
| Decoder/memory exhaustion | Preview/thumbnail/player disputam recursos | Um preview, workers limitados, cancellation e yield; testar scrubbing/foco rápido e 2 GB |
| Updater hijack / regressão de identidade | Feed oficial e signing default do upstream | Feed próprio não configurado não faz update; assinatura própria; verificar asset/versão/origem antes de instalar |
| Deep links inseguros | Instalação independente requer protocolos e callbacks auditados | Validar ação/parâmetros; não sequestrar protocolos oficiais; testar inputs maliciosos |
| LAN remote takeover | Novo servidor/WS na Fase 8 | Opt-in, pairing aleatório curto, confirmação no host, sessão revogável, Origin/limits, nenhuma exposição WAN default |
| Scene recognition/privacy | Análise local experimental | Opt-in; contexto de elenco conhecido, confiança e proveniência; não enviar frames/consumo à nuvem |
| Mandatory telemetry | Sentry/reporting/integrações já aparecem no build | Identificar todas as chamadas; default externo off, consentimento separado e payload redigido |

## Regras de implementação

- Nunca logar passwords, tokens, cookies, Authorization, private keys ou URLs
  completas de fontes configuradas. Redaction é para apresentação; a request
  precisa continuar recebendo os headers/URL corretos sem transformação.
- Configuração local, artefatos, dumps, keys e logs estão ignorados. Não copiar
  secrets oficiais nem signing defaults para a distribuição do fork.
- PIN não é garantia de parental controls; não anunciar Kids até os controles
  reais existirem. Dados pessoais não são clonados automaticamente.
- Storyboards/caches devem identificar media/episódio e origem sem usar URL
  secreta como nome de arquivo ou texto de diagnóstico.
- Não remover compatibilidade de LAN/self-host por um bloqueio indiscriminado
  de endereço privado. As fronteiras têm políticas distintas.

## Achados iniciais e estado

1. **P1 — URL sensível em logs de addon:** confirmado em Desktop; correção da
   fundação com testes de redaction antes de distribuição.
2. **P1 — TLS permissivo para addons na TV:** confirmado e separado de endpoints
   first-party; requer política dedicada, não mudança silenciosa de todo o client.
3. **P1 — Coexistência/updater:** paths e feeds oficiais confirmados; identidade
   deve ser separada antes de executar/distribuir o fork lado a lado.
4. **P2 — Quotas unificadas inexistentes na superfície auditada:** cache/memória
   têm limites pontuais; falta uma política abrangente que considere storage.
5. **P1 — Crash reports ligados por default:** confirmado no fallback de settings
   Desktop e TV; no fork, nova instalação precisa iniciar com consentimento off.
6. **P1 — Diagnósticos de login TV preservam códigos temporários:** inspeção de
   `core/logging/LogDiagnostics.kt` confirmou que `rawForLog` e `urlForLog`
   retornam o valor original. Call sites em `AuthManager` e `AccountViewModel`
   passam nonce, device/user code e URL de verificação. A correção de redaction
   de addons da fundação não cobre esses helpers. Também precisam ser revisados
   corpos, mensagens e exceções dos diagnósticos de auth. A mitigação dos logs
   novos e da fila antiga está descrita abaixo; não se declara ausência global
   de credenciais nos logs. As evidências publicadas
   de QR excluem esses valores e não incluem logcat de auth.

Não foram executados pentest, fuzzing de native decoders nem testes de rede
hostil. As mitigações acima não serão marcadas prontas por existir documentação.

### Correção de diagnósticos de login TV novos

Foram estendidos os helpers existentes de log e a projeção de `AuthDiagnostics`.
Escalares, URLs e corpos recebem marcadores; exceções mantêm tipos e frames,
sem mensagem/causas brutas. Cabeçalhos não reconhecidos e valores de string
dos corpos/detalhes são excluídos, inclusive JSON inválido. Status HTTP,
timing, booleanos e contadores permanecem em campos próprios. Foram retirados
26 overloads de logger que passavam Throwable bruto em AuthManager/AccountViewModel.
Não foram alterados os valores operacionais dos requests, DTOs ou endpoints.

A comparação de AuthManager com o upstream é idêntica ao retirar apenas as
linhas Log.e/Log.w. O verificador protege os dois blobs revisados de auth com
hash exato, mantendo a comparação do restante do diretório e de sync/APIs/DTOs.
Passaram **36 testes direcionados**; os cinco APKs foram compilados. O primeiro
teste do relatório serializado encontrou um corpo com código puro: o parser
aceitava um literal fora do schema esperado. A correção passou a excluir corpos
escalares e literais não numéricos/booleanos, com regressão preservada. O teste
captura o payload passado ao repository usando dados sintéticos; nenhum upload
real de teste é feito. Tipos de exceção, status HTTP e classificação de timeout
continuam disponíveis sem suas mensagens. Tentativas em `auth-redaction-results.json`.

No APK instalado em Android TV API 36, QR e código foram gerados e os marcadores
nonce/deviceCode/userCode/URL apareceram nos logs novos. O código da tela não
apareceu no log e o crash buffer ficou vazio. Não houve login de conta/sync;
logs brutos e árvores com QR permanecem ignorados. `auth-redaction-ui-qa.json`
contém somente os resultados e o hash do APK.

A continuação sanitiza a fila existente em `AuthDiagnosticReportRepository`
antes de reenviar. A leitura regrava relatórios antigos com a projeção segura,
remove linhas inválidas conforme o comportamento anterior, e gravação/upload
aplicam novamente a proteção. URLs, mensagens, raw logs e stacks antigos recebem
marcadores; status HTTP, tipo de exceção e classificação de rede continuam úteis.
Não houve alteração em DTOs, endpoints ou valores operacionais do login.

Passaram **37 testes direcionados**, incluindo arquivo legado sintético com
códigos/tokens, migração no disco, leitura idempotente, limite da fila e remoção
quando vazia; cinco APKs recompilados e inspecionados. A primeira tentativa
identificou que o parser leniente reinterpretava o marcador como array na segunda
sanitização. A correção preserva o marcador e o teste de leitura repetida passou.
Tentativas e hashes: `auth-queue-results.json` e
`auth-queue-package-inspection.json`. Não houve upload real nem QA de migração
de dados de uma conta em aparelho. A proteção ocorre ao acessar a fila para
reenvio/gravação; não se afirma que arquivos nunca acessados já foram migrados.

O achado 6 foi mitigado nos logs novos e na fila revisada. Esta mudança não apaga
logs antigos nem demonstra ausência global de dados sensíveis. Os pacotes da
alpha.2 não foram substituídos pela correção.
