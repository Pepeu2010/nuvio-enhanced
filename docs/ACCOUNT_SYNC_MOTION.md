# Conta Nuvio, atualização contínua e navegação Telumia

A solicitação de 08/10/2026 prioriza a sincronização bidirecional com a mesma
conta Nuvio, a mesclagem dos dados existentes, movimento nas principais telas e
uma barra lateral melhor. Depois desses incrementos, a meta integral continua.

Os incrementos de conta, reconciliação de coleções/addons e navegação descritos abaixo foram distribuídos na **0.2.2-alpha.1**: fontes Desktop `b39b6ea79d37b7c9eb1383ef68692dd2309d664d` e TV `e1962f736410a288f3a8db92fa6d2eaa4eaaa66b`. Os gates finais passaram 268/200 testes selecionados e builds reais; os 22 assets remotos foram conferidos. A conta oficial autenticada e os limites de concorrência do backend continuam pendentes. [Entrega](ALPHA_022.md), [publicação](RELEASES.md). Os registros seguintes preservam a sequência dos incrementos anteriores.

## Incremento em validação

Os clientes usam os repositories e o backend Nuvio existentes. Não se cria outra
conta Telumia nem se juntam dados privados de usuários com credenciais diferentes.
Perfis correspondem aos índices existentes no backend; uma troca de conta ou
perfil invalida o trabalho anterior.

- PC: retorno ao primeiro plano e consulta periódica de dois minutos agora pedem
  a atualização completa de perfis, configurações suportadas, credenciais de
  providers, addons, plugins, biblioteca, fonte de progresso/histórico selecionada,
  coleções e organização da Home. A consulta periódica acompanha o ciclo de vida
  do app. Os pushes continuam nos mecanismos de mutação existentes.
- PC: addons, plugins, coleções, configurações e Home deixam de esconder falhas
  de consulta do coordenador. Respostas antigas são verificadas contra a conta,
  o perfil e o job antes da publicação. Progresso e biblioteca mantêm os reducers,
  cursores, tombstones e a escolha de provider existentes.
- TV: a consulta periódica e o retorno ao app passam a incluir o setup completo,
  antes do progresso. Falha de uma superfície não representa sincronização
  completa; as demais consultas independentes ainda são tentadas. A gravação
  remota de nomes/estado de addons é atômica no DataStore do perfil capturado.
  Coleções também verificam ownership dentro da transação.
- PC: menu lateral de 72/224 dp, espaço maior para os rótulos, superfície elevada,
  estados de hover/foco/seleção, feedback de pressionar e expansão pelo foco do
  teclado. As abas existentes recebem entrada com fade e deslocamento curto.
  O host continua preservando estado, medindo apenas a aba ativa e suspendendo
  o lifecycle das demais.
- TV: menu moderno com foco de alto contraste, borda visível, escala limitada,
  seleção semântica e superfície própria. Novas configurações usam esse menu por
  padrão; preferências explícitas existentes são respeitadas. Rotas comuns recebem
  entrada suave; o player conserva seu tratamento de transição. Reduced Motion
  elimina deslocamento/escala e o blur do painel; Off elimina a duração.

## Evidência já concluída no PC

Commit `9fc55558aa50a1b30ceca42701689ca68b637182`: **208 testes selecionados,
zero falhas/erros/skips**, com APPDATA novo e isolado. Inclui testes do coordenador,
ownership, reconciliação/paginação da biblioteca e dois testes Compose da navegação
real. A barra lateral passou por mouse e Enter nos três modos de movimento;
as quatro abas preservaram suas montagens e esconderam a semântica inativa.
Três capturas estáticas foram revisadas; elas não provam fluidez em hardware físico.

MSI compilado e preservado: 215.442.200 bytes, SHA-256
`8d7675ef3d3fcb4b000ab22016f3875f328d0e548832fa9c368894e9cffaf8bb`.
Build de desenvolvimento posterior à release; nenhum asset/tag público foi
substituído. Registros: `telumia-account-sync-sidebar-desktop-build-binding.json`
e `telumia-account-sync-sidebar-desktop-package-inspection.json`.

## Evidência concluída na TV

Commit `4c594514c5b85ee9ecbdb13bdb5305246a83dbef`: **162 testes selecionados,
zero falhas/erros/skips**, cinco APKs do app e APK de instrumentação compilados
com checkout limpo. APK universal preservado: 185.529.246 bytes, SHA-256
`b11c75e6b573759bc02a3d70948cba0ac2b73027de7e8a216f4a8e0d5da66744`.
Registros: `telumia-account-sync-sidebar-tv-build-binding.json` e
`telumia-account-sync-sidebar-tv-package-inspection.json`. Não é uma nova release.

A instrumentação do componente real de menu moderno passou em Android 36,
720p, 1080p e framebuffer 3840×2160: três testes por resolução, com DPAD Down e
Center, foco/seleção e capturas para Full, Reduced e Off. As nove capturas foram
revisadas; o teste controlado usa quatro opções com ícones de fixture e não
representa uma sessão completa na Activity principal. Android 24 passou pelos
mesmos três modos em 1080p, com mais três capturas revisadas: **12 execuções
nativas no total**, zero falhas. Registros em `telumia-sidebar-native-results.json`;
as capturas públicas estão em `evidence/telumia-account-sync-sidebar/`.
Os sete testes novos de sync usam dependências controladas e DataStore em
memória; não são comprovação de uma conta real no serviço oficial.

## Reconciliação de coleções no PC compilada e testada

O próximo incremento utiliza os RPCs existentes e acrescenta um journal privado
por backend/conta/perfil. Registra a edição local antes do snapshot comum, faz
mesclagem em três vias com a última base remota conhecida e mantém alterações
pendentes após falha de rede ou edição durante upload. Preserva campos desconhecidos
e IDs de pastas; uma lista remota vazia confirmada representa exclusão, enquanto
uma linha ainda inexistente permite semear coleções locais. O journal não muda o
protocolo oficial e não oferece uma transação global entre aparelhos concorrentes.
Commit `e87ba370bed18a47ed7e31e71a514be7967cbd49`: **225 testes selecionados,
zero falhas/erros/skips**, 51 relatórios JUnit, APPDATA novo e isolado. Os 15
testes novos incluem nove do journal/mesclagem e seis do repository, serviço e
armazenamento Desktop reais, com RPC controlado. Dois testes existentes do
repository também passaram. O ensaio de interrupção escreve o journal real e
simula a ausência do snapshot comum antes de recriar o repository; não é um
crash forçado do processo instalado.

MSI dessa rodada: 215.479.064 bytes, SHA-256
`64aa3c2abd6345cee1f73f6d14de4b05d6e04002443f773a2fc96c75fdd6a1fd`,
preservado em `telumia-collection-reconciliation-desktop-build-binding.json` e
inspecionado em `telumia-collection-reconciliation-desktop-package-inspection.json`.
Fonte publicada em `telumia-desktop/main`; não substitui a release anterior.
As implementações auxiliares Android/iOS do armazenamento Desktop não foram
compiladas nesta máquina.

Na primeira tentativa TV, os nove testes novos passaram. Uma fixture existente
de validação Trakt falhou porque o `Context` mockado devolvia mensagem vazia;
a fixture agora fornece a mensagem esperada, mantendo as duas asserções de
rejeição e erro. A tentativa completa, com 176 testes/uma falha e builds de APKs,
ficou preservada em `telumia-collection-reconciliation-tv`; a repetição `-r2`
passou. Não se publica binding de uma tentativa com falha.

## Reconciliação de coleções na TV compilada e testada

Commit `33ee38fbfffb382a800d095a2e430c1a7d7cb922`: **176 testes selecionados,
zero falhas/erros/skips**, 36 relatórios JUnit, cinco APKs do app e APK de testes
compilados com checkout limpo. Os nove testes novos exercitam o serviço e
DataStore reais com RPC controlado: edição offline, mudança durante upload,
conta/perfil incorretos, exclusão confirmada, migração de linha remota inexistente,
journal futuro recusado, wire fields desconhecidos e recuperação de um arquivo
Preferences real após recriar o store. Esse ensaio de disco roda na JVM; não
substitui teste de interrupção/rede em uma conta instalada na TV.

Snapshot e journal são publicados na mesma transação DataStore. O envio consulta
e mescla antes de substituir a lista no servidor. Providers futuros de fontes
de coleção que a UI atual não renderiza são preservados no JSON ao editar campos
conhecidos. O journal continua privado por backend/conta/perfil e é removido pelo
reset explícito de dados locais da conta já existente no cliente.

APK universal: 185.529.246 bytes, SHA-256
`6ba301e0922c1fe3068da3140317bbdb85dc5c91cdd814dae4a71d2f1fe36162`.
Binding e inspeção em `telumia-collection-reconciliation-tv-r2-build-binding.json`
e `telumia-collection-reconciliation-tv-r2-package-inspection.json`. Fonte enviada
a `telumia-tv/main`. Resultados das duas tentativas em
`telumia-collection-reconciliation-results.json`. As 12 execuções nativas do menu
anterior pertencem ao source `4c594514`; esta rodada não altera o código desse
componente e não declara QA de login/Activity/player completo.

## Reconciliação de addons PC compilada e testada

O próximo incremento troca o push cego de addons por consulta, mesclagem e envio
nos mesmos `addons`/`sync_push_addons` existentes. O journal utiliza a URL de
transporte completa como identidade, preservando configurações diferentes em
query strings. Nomes e estados de ativação passam a integrar um snapshot local
durável; a ordem de envio é recalculada após mesclar adições independentes.
Edições durante upload ficam pendentes. O perfil secundário que usa os addons
do principal permanece sem autorização para enviá-los. A instalação iniciada
antes de uma troca de conta/perfil/backend é recusada ao terminar a consulta.

Commit `61134a422908118dd1cabd6f4ff49e44795e44ca`: **240 testes selecionados,
zero falhas/erros/skips**, 55 relatórios JUnit, APPDATA novo e isolado e MSI
compilado com checkout limpo. Sete testes novos exercitam repository,
armazenamento real e RPC controlado: remoção offline, adição/nome remotos,
estado de ativação, ordem, query strings distintas, recuperação e edição durante
upload. O gate read-only do perfil que usa addons do principal é exercitado no
coordenador; login/fluxo completo de perfis e manifest fetch remoto não são
validados por esses testes.

MSI dessa rodada: 215.495.448 bytes, SHA-256
`06be49f5d07abdd8289a184fa0762e0be57b5c24e1452e27199537c064f80762`.
Binding em `telumia-addon-reconciliation-desktop-build-binding.json`, inspeção em
`telumia-addon-reconciliation-desktop-package-inspection.json` e resultados em
`telumia-addon-reconciliation-results.json`. A reconciliação equivalente de
addons TV continua pendente. Os binários são de desenvolvimento; a release
publicada anterior permanece com seus próprios commits e hashes.

Na mesma rodada, a biblioteca passa a propagar falhas para o coordenador sem
alterar o comportamento padrão dos demais callers existentes. Um teste do
repository e adapter controlado verifica falha, retry e recuperação. A atualização
da fonte de progresso selecionada respeita o cooldown existente dos providers;
dois minutos é a cadência de pedido de atualização, não uma obrigação de furar
limites de cada serviço. A TV também mantém a política de freshness do serviço
de perfis existente. O teste da biblioteca passou nessa rodada; o gate também
inclui as regressões existentes de modelos e URLs de addons.

## Reconciliação de addons TV

O incremento TV consulta a tabela `addons`, mescla as alterações pendentes e
envia apenas URL, nome, ativação e ordem pelo `sync_push_addons` existente.
Nomes, estados, URLs e journal agora são publicados juntos no DataStore do perfil
capturado. Startup, atualização manual, realtime e login usam essa publicação;
não reaplicam uma segunda lista que poderia sobrescrever uma edição concorrente.
O repository também consome um único snapshot de preferências, evitando tratar
uma nova URL desativada como habilitada enquanto o fluxo de estados ainda chega.
Um teste do repository real acompanha as emissões e exige zero manifest fetch
para os addons desativados recebidos na atualização.

Cada instalação, remoção, ordem, nome ou ativação local grava sua revisão na
mesma transação da preferência. Falha de upload deixa a revisão pendente, e uma
edição durante o envio não é confirmada por aquele envio antigo. As consultas
recusam respostas de conta/perfil/backend antigos. A tarefa de envio com debounce
captura o dono antes de esperar. URLs de configuração preservam os caracteres e
a capitalização da query, inclusive parâmetros que terminam em `/`.

Perfis secundários com addons do principal consultam o perfil 1, mas não podem
modificar nem enviar seus dados. A consulta pode exibir uma edição pendente do
principal; não a descarta nem a confirma em nome do secundário. Uma resposta
válida vazia remove os addons, nomes e estados antigos. Indisponibilidade da rede
produz falha e preserva os dados locais, sem ser interpretada como lista vazia.

A tabela de addons não distingue uma primeira lista vazia de uma exclusão
confirmada por outro dispositivo. Não se reinserem automaticamente defaults nem
se fundem caches de outra conta. Importar dados do modo sem conta para uma conta
existente ainda exige tratamento próprio. O journal permanece no armazenamento
local do perfil; a limpeza explícita ao sair da conta já existente também o
remove. Uma queda de rede ou reinício do processo não executa essa limpeza.

Os RPCs substituem snapshots completos e não oferecem CAS neste cliente. A
mesclagem preserva alterações independentes observadas antes do upload, mas não
constitui transação global entre dispositivos editando exatamente ao mesmo tempo.
Teste de conta oficial ↔ fork e manifest fetch remoto continuam necessários.
O commit `c0695add859d5ad12303ec2ea01de4aacc3d17a1` passou em **193 testes
selecionados, 38 relatórios JUnit, zero falhas, erros ou skips**, além da montagem
dos cinco APKs de aplicativo e APK de instrumentação. O gate preservado é
`telumia-addon-reconciliation-tv-r4`. Onze novos testes exercitam a reconciliação
real, inclusive reinício de um DataStore em disco, alterações durante upload,
remoção offline, lista remota vazia, herança somente leitura, mudança de conta e
emissão atômica ao repository sem buscar manifests desabilitados. Os testes
restantes cobrem regressões selecionadas; não equivalem à suíte inteira nem a
uma conta autenticada no servidor oficial.
A primeira compilação, com checkout limpo `86321ad1`, foi interrompida após
compilar o código principal para corrigir essa observação por fluxos separados;
não executou o gate unitário nem constitui build aprovado. Seu resultado e log
ficam preservados em `telumia-addon-reconciliation-tv`.
A segunda execução, no commit `876d5b43`, terminou sem mensagem final do Gradle
nem registro de término. Em 09/10, o handle já não existia e uma consulta dos
processos Win32 confirmou a ausência do wrapper/daemon desta execução. Sua causa
e horário de término não são conhecidos: `telumia-addon-reconciliation-tv-r2`
foi registrado como interrompido, preservando o registro inicial. O novo gate
usou `telumia-addon-reconciliation-tv-r3`, sem reaproveitar uma aprovação ausente.
Essa terceira tentativa compilou o aplicativo e os APKs, mas falhou ao compilar
os testes por uma referência antiga de variável na fixture de coleções. A
referência foi corrigida; a quarta tentativa passou e seus pacotes foram
preservados com hashes no [build binding](telumia-addon-reconciliation-tv-r4-build-binding.json).
O APK universal preservado também foi instalado no AVD próprio Android 7/API 24.
A MainActivity real permaneceu ativa e retomada após 30 segundos sem crash no
buffer do aplicativo. A [evidência de inicialização](telumia-addon-reconciliation-tv-startup-api24.json)
registra o mesmo commit e hash do APK; a captura e os logs brutos permanecem privados.
Esse gate comprova startup e wiring de runtime, sem login, reprodução ou sync remoto.

## Trabalho ainda necessário para a solicitação completa

A cobertura de atualização não equivale a resolver todos os conflitos offline.
Addons e coleções PC e TV possuem os incrementos descritos acima. Importação
inicial do modo sem conta e conflito global de uploads simultâneos continuam
com os limites documentados, sem prometer uma transação distribuída ausente no backend.
A remoção de coleções vazias passa a
ser aplicada em vez de preservar indefinidamente uma cópia local antiga.
Também falta comprovação ponta a ponta Nuvio oficial ↔ Telumia com uma conta de
teste, reentrada, mudança de perfil, perda/retorno de rede e edição simultânea.

As funções específicas do Telumia que não possuem representação no cliente ou
backend Nuvio (como arquivo de avatar local e momentos salvos) continuam com seu
alcance explicitamente local. Não enviar caminhos locais nem afirmar que o
cliente oficial entende um formato que não implementa. Recursos compartilhados
devem usar os contratos existentes; sem inventar endpoints do servidor oficial.

A consulta periódica completa também funciona como reconciliação quando um
evento em tempo real não chega. O suporte a Postgres Changes depende da publicação
e autorização configuradas no servidor, conforme a [documentação Supabase](https://supabase.com/docs/guides/realtime/postgres-changes).
Este incremento não modifica a configuração do backend oficial.

A meta completa e as demais fases de `ROADMAP.md` permanecem abertas. Login remoto,
playback real, todas as telas, desempenho físico, bookmarks PC e os demais recursos
não são declarados concluídos por estes testes.
