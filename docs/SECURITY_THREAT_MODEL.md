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

Não foram executados pentest, fuzzing de native decoders nem testes de rede
hostil. As mitigações acima não serão marcadas prontas por existir documentação.
