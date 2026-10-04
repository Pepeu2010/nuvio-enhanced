# OBJETIVO

Desenvolver um fork open source do Nuvio que preserve compatibilidade com o ecossistema existente, mas transforme principalmente a experiência Desktop e Android TV em um media center muito mais avançado.

Não é para criar apenas outro tema.

Não é para reconstruir o Nuvio do zero.

Não é para remover recursos existentes para facilitar o desenvolvimento.

O produto precisa continuar utilizando a base real do Nuvio sempre que tecnicamente adequado e adicionar uma experiência de uso superior em:

- interface;
- animações;
- navegação;
- perfis;
- avatares;
- player;
- timeline;
- previews;
- descoberta;
- addons;
- streaming;
- TV ao vivo;
- Android TV;
- performance;
- personalização.

Nome temporário durante o desenvolvimento:

`Nuvio Enhanced`

Não faça rebranding definitivo agora.

---

# REPOSITÓRIOS OBRIGATÓRIOS PARA PESQUISA

Antes de modificar código, examine estes repositórios oficiais.

Principal:

`NuvioMedia/NuvioDesktop`

Android TV:

`NuvioMedia/NuvioTV`

Mobile, para comparar autenticação, perfis, addons, sync e decisões de arquitetura:

`NuvioMedia/NuvioMobile`

Backend e contratos de conta/sync:

`NuvioMedia/self-host`

Engine de streaming em desenvolvimento:

`NuvioMedia/nuvio-engine`

Smart TVs, apenas como referência adicional:

`NuvioMedia/NuvioTVSmart`

Organização completa:

`NuvioMedia`

Se GitHub CLI estiver disponível:

```bash
gh repo view NuvioMedia/NuvioDesktop --web
gh repo view NuvioMedia/NuvioTV --web
gh repo view NuvioMedia/NuvioMobile --web
gh repo view NuvioMedia/self-host --web
gh repo view NuvioMedia/nuvio-engine --web
gh repo view NuvioMedia/NuvioTVSmart --web
```

Para inspeção local:

```bash
gh repo clone NuvioMedia/NuvioDesktop
gh repo clone NuvioMedia/NuvioTV
gh repo clone NuvioMedia/NuvioMobile
gh repo clone NuvioMedia/self-host
gh repo clone NuvioMedia/nuvio-engine
```

Não copie código entre projetos cegamente.

Use os outros repositórios para entender como o ecossistema Nuvio implementa:

- autenticação;
- sessão;
- perfil;
- sync;
- addons;
- metadata;
- player;
- navegação de TV;
- downloads;
- persistência;
- networking;
- caching;
- tratamento de erros.

Sempre confirme a implementação atual do código antes de assumir comportamento.

---

# BASE TÉCNICA ATUAL

Considere o estado real atual do projeto.

Nuvio Desktop utiliza:

- Kotlin;
- Kotlin Multiplatform;
- Compose Multiplatform;
- Compose Desktop;
- integrações nativas de player;
- `commonMain` para UI, features, repositories e lógica compartilhada;
- implementações específicas para Desktop.

Nuvio TV utiliza:

- Kotlin;
- Jetpack Compose;
- TV Material 3;
- Android Media3.

Não substitua essa stack por React, Electron, Tauri ou outra tecnologia.

A evolução deve acontecer em cima da arquitetura existente, salvo quando uma mudança estiver tecnicamente justificada e documentada.

---

# PRIMEIRA REGRA

ANTES DE IMPLEMENTAR, FAÇA UMA AUDITORIA REAL DO REPOSITÓRIO.

Investigue:

```text
modules
navigation
state management
dependency injection
networking
authentication
account
profiles
sync
addons
metadata
catalogs
streams
player
subtitles
downloads
storage
cache
settings
desktop integrations
Android integrations
tests
build system
CI
release
```

Crie:

`docs/ARCHITECTURE_AUDIT.md`

Documente:

- arquitetura encontrada;
- dependências importantes;
- fluxos de dados;
- player atual;
- integração com addons;
- APIs utilizadas;
- pontos frágeis;
- código duplicado;
- possibilidades reais de compartilhamento;
- riscos de regressão.

Não comece uma reescrita grande antes dessa auditoria.

---

# LICENÇA

Nuvio Desktop e Nuvio TV utilizam GPLv3.

Preserve integralmente as obrigações da GPL.

Mantenha:

- copyright;
- notices;
- licença;
- atribuições;
- código-fonte correspondente das modificações distribuídas.

Não dê a entender que este fork é o cliente oficial do Nuvio.

Não copie identidade proprietária da Netflix, Prime Video, Apple TV, Plex ou qualquer outro serviço.

Eles servem somente como referência de UX.

---

# PRIORIDADE DE PLATAFORMAS

Fase principal:

1. Windows
2. Android TV / Google TV / TV Box

Posteriormente:

3. Linux
4. macOS

Não sacrifique a portabilidade já existente do Desktop.

---

# ARQUITETURA DE PRODUTO

Objetivo conceitual:

```text
                    SHARED DOMAIN
                          │
          ┌───────────────┼───────────────┐
          │               │               │
        Auth           Catalog          Addons
        Sync           Metadata         Streams
        Profiles       Library          Search
        History        Playback         Settings
          │               │               │
          └───────────────┬───────────────┘
                          │
                Platform capabilities
                          │
             ┌────────────┴────────────┐
             │                         │
         DESKTOP UI                 TV UI
        Mouse/Keyboard              D-pad
        Power User                Living Room
```

Compartilhe domínio e lógica quando for correto.

Não tente reutilizar a mesma tela indiscriminadamente entre Desktop e TV.

---

# LOGIN E ECOSSISTEMA NUVIO

Não criar outro sistema de autenticação.

O login utilizado pelo usuário no Nuvio deve continuar funcionando neste fork sempre que suportado pelo backend atual.

Preserve compatibilidade com o backend oficial existente.

Mapeie exatamente o que hoje sincroniza.

Exemplos:

- conta;
- perfis;
- biblioteca;
- favoritos;
- watch progress;
- histórico;
- listas;
- addons;
- configurações sincronizadas.

Não invente campos ou endpoints do servidor.

Não altere o backend oficial.

Recursos exclusivos do nosso cliente devem ser armazenados numa camada própria quando não houver suporte oficial.

Exemplo:

```text
Nuvio Sync
├── account
├── profiles
├── library
├── progress
├── history
└── supported settings

Enhanced Client
├── UI customization
├── preview preferences
├── Smart Collections
├── motion settings
├── Scene Bookmarks
├── hardware profile
├── timeline cache
├── avatar local extensions
└── experimental features
```

---

# ADDONS STREMIO

Compatibilidade com addons Stremio é OBRIGATÓRIA.

O usuário deve continuar conseguindo utilizar o mesmo ecossistema de addons compatíveis já suportado pelo Nuvio.

Investigue a implementação atual antes de alterar.

Preserve pelo menos o suporte existente para:

```text
manifest
catalog
meta
stream
subtitles
configuration
authentication
addon URLs
```

Crie testes de regressão para garantir compatibilidade.

---

# NOVO ADDON MANAGER

Criar uma área completa:

```text
Addons

├── Descobrir
├── Instalados
├── Atualizações
├── Configurar
└── Desenvolvedor
```

Cada addon pode mostrar:

- nome;
- ícone;
- versão;
- descrição;
- origem;
- status;
- capabilities;
- latência;
- última comunicação;
- erro atual;
- habilitar/desabilitar;
- configuração.

Adicionar diagnóstico.

Exemplo:

```text
Torrentio

Status
● Online

Resposta
184 ms

Capabilities

Catalog      ✓
Meta         ✓
Stream       ✓
Subtitles    ✓
```

Uma falha em addon nunca deve derrubar a Home inteira.

---

# SEGURANÇA DE ADDONS

Quando tecnicamente possível, criar isolamento e uma camada clara de permissões/capabilities.

Não permitir que um addon ganhe acesso arbitrário ao sistema operacional simplesmente porque fornece metadata ou stream.

Registrar erros de forma segura.

Nunca logar:

- tokens;
- passwords;
- session cookies;
- authorization headers;
- chaves privadas;
- URLs contendo segredos sem redaction.

---

# VISUAL

Queremos um media center cinematográfico.

Referências conceituais:

- Apple TV;
- Netflix;
- Plex;
- interfaces premium de streaming.

Não copiar interfaces 1:1.

Visual:

- dark;
- OLED opcional;
- limpo;
- cinematográfico;
- backdrops grandes;
- boa hierarquia;
- tipografia legível;
- cards com profundidade;
- gradientes;
- blur moderado;
- iluminação contextual;
- sem neon exagerado;
- sem aspecto genérico de IA.

---

# DESIGN SYSTEM

Defina tokens reais para:

```text
color
typography
spacing
radius
elevation
focus
opacity
blur
motion
duration
easing
```

Desktop e TV devem compartilhar identidade visual.

---

# MOTION SYSTEM

A interface precisa reagir imediatamente.

Referência inicial:

```text
micro interaction
120–180ms

standard
180–280ms

large transition
280–450ms

ambient
500–900ms
```

Utilize springs onde melhorarem naturalidade.

Criar:

- Reduced Motion;
- Animation Intensity;
- Disable Animations.

Nenhuma animação deve bloquear interação.

Target:

`60 FPS` consistente.

Aproveitar refresh rates maiores quando possível.

---

# HOME NOVA

A Home precisa ser reconstruída visualmente.

Possíveis seções:

```text
Continue assistindo
Minha lista
Em alta
Filmes
Séries
Anime
Lançamentos
Adicionados recentemente
Assistir novamente
4K
HDR
Recomendados
TV ao vivo
```

Permitir reorganizar seções.

Não carregar todos os conteúdos e imagens simultaneamente.

Aplicar lazy rendering, preload inteligente e cache.

---

# HERO CINEMATOGRÁFICO

Criar hero com:

- backdrop;
- logo/título;
- descrição curta;
- ano;
- duração;
- classificação;
- rating;
- qualidade;
- continuar;
- assistir;
- trailer;
- adicionar à lista.

O hero deve reagir ao conteúdo selecionado.

Backdrops devem trocar suavemente.

---

# CINEMATIC PREVIEW

Recurso central.

## Desktop

Quando o mouse permanecer aproximadamente `750 ms` sobre um título:

1. expandir o card;
2. revelar metadata;
3. carregar preview;
4. iniciar trailer/preview silencioso;
5. mostrar controles rápidos.

## TV

Quando o foco permanecer aproximadamente `1200 ms`:

executar comportamento equivalente adaptado a D-pad.

Prioridade:

```text
trailer
↓
teaser
↓
preview do provider
↓
backdrop estático
```

Nunca tocar áudio automaticamente por padrão.

Nunca iniciar vários players simultaneamente.

Criar `PreviewCoordinator` ou abstração equivalente para:

- debounce;
- cancelamento;
- preload;
- lifecycle;
- cache;
- memória.

---

# CARDS

Estados obrigatórios:

```text
idle
hover
focused
preview-loading
preview-playing
selected
disabled/error
```

Foco deve ser imediatamente perceptível na TV.

Evite escalas exageradas.

---

# AMBIENT UI

Analisar palette do backdrop atual e aplicar discretamente na interface.

Pode afetar:

- gradient;
- background;
- ambient light;
- highlight.

Mudança deve ser gradual.

Não deixar a interface virar da cor da capa.

---

# SHARED ELEMENT TRANSITIONS

Quando possível, fazer card/capa participar da transição para a tela de detalhes.

Evitar:

```text
click
black screen
new screen
```

Buscar sensação de continuidade espacial.

---

# PÁGINA DE DETALHES

Filmes:

- backdrop;
- title/logo;
- metadata;
- rating;
- quality badges;
- progresso;
- Play/Continue;
- Minha Lista;
- Trailer;
- sinopse;
- elenco;
- direção;
- recomendações;
- relacionados.

Séries:

adicionar:

- temporadas;
- episódios;
- progresso;
- preview individual.

---

# SPOILER SHIELD

Implementar:

```text
Off
Basic
Strict
```

Pode ocultar de episódios não assistidos:

- thumbnail;
- título;
- descrição;
- determinados metadados.

O usuário controla o nível.

---

# PROFILE STUDIO

Perfis precisam ser completamente melhorados.

Não limitar o usuário aos avatares padrões existentes.

Não obrigar o usuário a entrar em um site, encontrar uma imagem, copiar URL e voltar ao app.

Permitir selecionar avatar através de:

- arquivo local;
- drag-and-drop;
- clipboard;
- webcam quando disponível;
- biblioteca embutida;
- URL como opção avançada;
- WebP/GIF animado quando tecnicamente seguro.

---

# EDITOR DE AVATAR

Implementar:

- crop;
- zoom;
- reposition;
- preview;
- background;
- otimização;
- compressão;
- thumbnails derivadas.

Validar:

- magic bytes;
- MIME real;
- dimensão;
- filesize;
- formato;
- conteúdo inválido.

Não confiar somente na extensão do arquivo.

---

# BIBLIOTECA DE AVATARES

Incluir avatares licenciados/apropriados diretamente no aplicativo.

Categorias:

```text
Abstract
Animals
Pixel
Fantasy
Sci-Fi
Minimal
Nature
Original Characters
```

Não usar personagens protegidos sem autorização.

---

# PERFIL PERSONALIZÁVEL

Permitir por perfil:

- avatar;
- profile cover;
- accent;
- tema;
- idioma;
- áudio preferido;
- legenda preferida;
- tamanho da legenda;
- player preferences;
- qualidade;
- layout.

Também preparar:

- Guest;
- Kids;
- PIN.

---

# CLONAR PERFIL

Adicionar:

`Clonar perfil`

Selecionar:

```text
✓ addons
✓ idiomas
✓ legendas
✓ player
✓ aparência
✓ preferências

□ histórico
□ biblioteca
□ progresso
```

Dados pessoais não devem ser clonados silenciosamente.

---

# PLAYER

O player é infraestrutura crítica.

Antes de alterar qualquer motor, audite o player atual do Desktop e o Media3 usado na TV.

Não substitua apenas porque existe outra biblioteca conhecida.

Precisamos suportar, conforme capacidade real da plataforma:

- hardware decoding;
- H264;
- HEVC;
- VP9;
- AV1;
- HDR;
- áudio multicanal;
- audio tracks;
- subtitles;
- subtitle offset;
- audio offset;
- playback speed;
- chapters;
- fullscreen;
- PiP;
- autoplay;
- skip intro;
- skip recap;
- skip credits;
- next episode.

---

# NOVA UI DO PLAYER

Desktop:

```text
← Duna: Parte Dois



               VÍDEO



──────────────●────────────────
      01:42:31 / 02:46:00

⏮     ▶     ⏭      🔊   CC   ⚙   ⛶
```

Controles desaparecem suavemente quando inativos.

TV deve ter uma composição própria para distância de sofá.

---

# THUMBNAILS DA TIMELINE

Esse recurso é obrigatório.

Ao passar sobre ou avançar pela timeline, mostrar a cena correspondente àquele timestamp.

```text
          ┌───────────────────┐
          │                   │
          │      FRAME        │
          │                   │
          └───────────────────┘
               01:42:31
                   ↓
───────────────●────────────────
```

Prioridade de obtenção:

```text
thumbnail fornecida pela fonte
↓
sprite sheet disponível
↓
preview metadata disponível
↓
geração local
↓
cache
```

A geração local precisa respeitar CPU, disco e memória.

---

# FILMSTRIP

Durante scrubbing maior:

```text
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ 1:21:20  │ │ 1:21:30  │ │ 1:21:40  │ │ 1:21:50  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
                              ▲
```

Desktop:

```text
hover → thumbnail
drag → filmstrip
```

TV:

```text
seek curto → thumbnail
seek contínuo → filmstrip
```

---

# SEEK NA TV

Implementar aceleração progressiva.

Exemplo:

```text
tap →
+10s

continuar pressionando
+30s
+1m
+5m
```

Sempre mostrar timestamp e thumbnail correspondente.

---

# TIMELINE SEMÂNTICA

Preparar marcadores para:

```text
intro
recap
chapter
bookmark
credits
```

Exemplo:

```text
INTRO          CHAPTER                    CREDITS
  │               │                          │
──┼───────────────┼──────────────────────────┼──
```

---

# SCENE BOOKMARKS

Permitir salvar cenas.

Exemplo:

```text
00:32:18 — Cena favorita
01:12:43 — Luta
02:01:07 — Rever depois
```

Persistir:

- media ID;
- episode ID;
- timestamp;
- label;
- createdAt.

Screenshot da cena apenas quando tecnicamente e legalmente apropriado.

---

# SCENE INFO

Criar uma arquitetura para um recurso semelhante conceitualmente à informação contextual de cena do Prime Video, mas NÃO usar a marca `X-Ray`.

Nome temporário:

`Scene Info`

Ao pausar ou abrir painel:

```text
Nesta cena

[ator] Timothée Chalamet — Paul Atreides
[ator] Zendaya — Chani
[ator] Javier Bardem — Stilgar

Música
A Time of Quiet Between the Storms

Capítulo
Deserto Sul

Curiosidades
...
```

Preparar arquitetura:

```text
SceneMetadataProvider
├── provider metadata
├── community metadata
├── timed metadata
└── local analysis experimental
```

Não acoplar o recurso ao IMDb.

Não usar scraping frágil ou dados sem licença.

---

# RECONHECIMENTO LOCAL EXPERIMENTAL

Arquitetura pode futuramente permitir reconhecimento local de rostos presentes na cena.

Não tornar isso requisito do MVP.

Não identificar pessoas fora do contexto de elenco conhecido daquela obra.

Quando confiança não for suficiente, não afirmar identidade como fato.

Esse processamento deve permanecer local.

---

# SOURCE INTELLIGENCE

Criar um sistema para avaliar fontes de reprodução.

Avaliar:

- disponibilidade;
- latência;
- resolução;
- HDR;
- codec;
- bitrate;
- idioma;
- áudio;
- tamanho;
- compatibilidade de hardware;
- estabilidade histórica.

Exemplo:

```text
4K HDR • HEVC • PT-BR
Score 96

4K • AV1 • EN
Score 91

1080p • H264 • PT-BR
Score 81
```

A fórmula deve ser explícita e testável.

Não transformar o score em caixa-preta.

---

# MODOS DE QUALIDADE

Adicionar:

```text
Best Quality
Balanced
Data Saver
Manual
```

Usuário avançado pode sempre sobrescrever seleção automática.

---

# PRE-FLIGHT

Antes da reprodução, quando necessário:

```text
✓ Source online
✓ Codec supported
✓ Hardware decoder
✓ HDR supported
✓ Preferred audio found
✓ Subtitle found
```

Não adicionar atraso perceptível desnecessário.

---

# SEAMLESS FAILOVER

Se uma fonte falhar:

1. registrar posição;
2. identificar alternativas;
3. testar rapidamente;
4. escolher alternativa adequada;
5. continuar aproximadamente no mesmo timestamp.

Modos:

```text
Quality First
Balanced
Never Downgrade
```

Nunca ficar em loop infinito tentando fontes quebradas.

---

# DETECÇÃO DE HARDWARE

Detectar quando disponível:

- GPU;
- hardware codecs;
- HDR;
- resolução;
- refresh rate;
- memória;
- capacidades de decoder.

Criar um `DeviceCapabilities` centralizado.

Não espalhar verificações específicas por dezenas de telas.

---

# SMART HOME

Permitir ao usuário reorganizar a Home.

Criar futuramente Smart Collections.

Exemplo:

```text
type = movie
genre contains horror
watched = false
rating >= 7
runtime <= 120m
```

Resultado:

`Terror bom com menos de duas horas`

Tudo atualiza automaticamente.

---

# BUSCA UNIVERSAL

Desktop:

`Ctrl + K`

Deve pesquisar:

- filmes;
- séries;
- episódios;
- pessoas;
- biblioteca;
- ações.

Exemplos:

```text
Duna

filmes HDR

continuar Duna

abrir downloads

mudar perfil

configurar legenda
```

---

# CONTINUE ASSISTINDO

Mostrar:

- título;
- temporada/episódio;
- progresso;
- tempo restante.

Ações rápidas:

```text
Continuar
Recomeçar
Próximo episódio
Marcar assistido
Remover
```

---

# HISTÓRICO VISUAL

Criar página cronológica.

Preparar estatísticas locais:

- minutos/horas assistidos;
- filmes;
- episódios;
- gêneros;
- conteúdo reassistido.

Não enviar esses dados para serviço externo desnecessariamente.

---

# ESCOLHA PARA MIM

Criar filtro local:

```text
Movie / Series
Genre
Maximum duration
Minimum rating
Watched / Unwatched
Year
```

Selecionar um resultado compatível.

Não exigir LLM ou API paga.

---

# DOWNLOAD MANAGER

Melhorar experiência existente.

Mostrar:

- progresso;
- velocidade;
- ETA;
- tamanho;
- qualidade;
- áudio;
- legenda;
- diretório;
- espaço livre.

Ações:

```text
pause
resume
cancel
retry
```

Preparar download inteligente de episódio seguinte apenas quando a fonte e o comportamento permitido suportarem.

---

# ANDROID TV

Android TV é um produto de primeira classe.

Não transformar a UI Desktop em uma tela gigante.

Toda tela deve funcionar com:

```text
↑
↓
←
→
OK
Back
Play/Pause
```

Mouse não pode ser obrigatório.

---

# HOME DA TV

Estrutura:

```text
Sidebar / Rail

Início
Filmes
Séries
Anime
TV
Minha Lista
Buscar
Configurações


                 HERO

            DUNA: PARTE DOIS

       ▶ Continuar     + Minha Lista


Continue assistindo

[CARD] [CARD] [CARD] [CARD]


Recomendados

[CARD] [CARD] [CARD] [CARD]
```

---

# FOCUS ENGINE

Foco na TV é infraestrutura crítica.

Precisamos garantir:

- foco inicial;
- foco restaurado ao voltar;
- navegação horizontal;
- navegação vertical;
- modais;
- dialogs;
- player;
- EPG;
- listas lazy;
- carregamento incremental;
- foco após recomposição.

Criar testes específicos.

A tela pode ser bonita e ainda assim ser péssima se o D-pad for ruim.

---

# PERFORMANCE ADAPTATIVA NA TV

Nem todo TV Box possui bom hardware.

Criar perfis:

```text
Performance
Balanced
Cinematic
Auto
```

Auto deve considerar capacidade do aparelho.

Performance:

- menos blur;
- preview reduzido;
- menor image preload;
- menos elementos simultâneos.

Cinematic:

- ambient UI;
- previews melhores;
- transições completas.

A identidade visual não pode desaparecer no modo Performance.

---

# ÁREA TV

Adicionar uma área dedicada:

```text
TV
├── Agora
├── Guia
├── Canais
├── Favoritos
└── Recentes
```

Não incluir canais piratas ou listas embutidas.

O cliente recebe apenas fontes configuradas legitimamente pelo usuário/providers.

---

# EPG

Preparar suporte arquitetural para:

- XMLTV;
- EPG via addon/provider;
- cache;
- timezone;
- logos;
- atualização.

UI:

```text
             20:00       21:00       22:00

Canal A    Jornal      Novela       Jornal
Canal B    Filme────────────────    Série
Canal C    Futebol──────────────    Debate
```

D-pad precisa navegar corretamente pelo grid.

---

# TV AO VIVO

Mostrar:

- canal;
- logo;
- programa atual;
- início/fim;
- progresso;
- próximo programa.

Permitir favoritos.

Adicionar canais recentes.

---

# TROCA RÁPIDA DE CANAIS

Durante reprodução:

`↑ / ↓`

pode abrir seletor rápido de canais.

Exemplo:

```text
12 Canal A
13 Canal B
14 Canal C ← atual
15 Canal D
```

---

# TIMESHIFT

Preparar para fase posterior.

Quando a fonte permitir:

```text
pause live TV
rewind
resume
go live
```

Buffer deve possuir limites claros.

Nunca consumir disco sem controle.

---

# MULTI-VIEW

Fase posterior.

Suportar potencialmente:

- 2 streams;
- 4 streams.

Quantidade deve depender de `DeviceCapabilities`.

Especialmente útil para esportes.

---

# PHONE REMOTE

Criar controle remoto local.

Fluxo:

```text
PC/TV
↓
Generate QR
↓
Phone opens local page
↓
Temporary pairing
↓
WebSocket
↓
Remote control
```

Sem cloud obrigatório.

Interface móvel:

```text
       ↑

    ←  OK  →

       ↓

Back      Home

⏮   ▶   ⏭

Volume
Subtitles
Keyboard
```

---

# SEGURANÇA DO PHONE REMOTE

Não permitir que qualquer dispositivo da LAN controle o player automaticamente.

Exigir:

- token aleatório;
- curta validade;
- pairing explícito;
- confirmação;
- revogação;
- remembered devices opcional.

Nunca expor servidor de controle diretamente para internet por padrão.

---

# BUSCA POR VOZ NA TV

Usar primeiro mecanismos suportados pelo próprio Android TV quando disponíveis.

O celular pareado pode funcionar como teclado/microfone auxiliar.

---

# LIVING ROOM MODE

Criar experiência otimizada para sofá:

- tipografia maior;
- cards maiores;
- menos ruído;
- foco evidente;
- ações essenciais;
- menos configurações técnicas na superfície principal.

---

# CINEMA MODE DESKTOP

Para PC conectado à TV:

- fullscreen;
- monitor preferido;
- impedir screensaver durante playback;
- ocultar UI desnecessária;
- restaurar estado depois.

---

# AMBIENT MODE

Após período configurável sem interação:

```text
                 20:43

          sábado, 3 de outubro


          cinematic backdrop


                 DUNE
```

Movimento do mouse/controle retorna imediatamente.

---

# CACHE

Centralizar políticas para:

```text
posters
backdrops
avatars
preview videos
timeline thumbnails
filmstrip
metadata
addon responses
EPG
Scene Info
```

Cada cache precisa possuir:

- max size;
- TTL quando necessário;
- eviction;
- cleanup;
- observabilidade.

Não permitir crescimento infinito.

---

# IMAGENS

Nunca carregar original 4K para um card pequeno sem necessidade.

Criar pipeline de tamanhos adequados.

Exemplo:

```text
avatar-sm
avatar-md
avatar-lg

poster-sm
poster-md

backdrop-md
backdrop-lg
```

---

# OFFLINE

O aplicativo deve degradar corretamente sem internet.

Recursos locais como:

- downloads;
- metadata cache;
- imagens cacheadas;
- histórico local;
- settings;
- bookmarks;

não devem desaparecer simplesmente porque o backend está offline.

---

# ACCESSIBILITY

Implementar:

- Reduced Motion;
- escala adequada;
- contraste;
- foco visível;
- labels;
- keyboard navigation;
- screen reader quando suportado;
- subtitle customization.

---

# SEGURANÇA

Realizar threat model.

Cobrir:

- addon injection;
- malicious metadata;
- XSS equivalente em conteúdo renderizado;
- path traversal;
- SSRF quando aplicável;
- URLs maliciosas;
- arquivos de avatar;
- downloads;
- archive extraction;
- command execution;
- token leakage;
- logs;
- local remote pairing;
- arbitrary filesystem access;
- insecure deep links.

Não adicionar shell execution baseada em dados vindos de addons.

Não colocar secrets no repositório.

---

# OBSERVABILIDADE

Logs estruturados.

Níveis:

```text
debug
info
warn
error
```

Redaction obrigatória.

Criar debugging screen opcional mostrando:

- player state;
- source;
- decoder;
- addon;
- cache;
- networking;
- dropped frames.

Sem revelar credenciais.

---

# PLAYER STATS

Adicionar painel técnico opcional:

```text
Resolution
3840x2160

Codec
HEVC Main10

HDR
HDR10

FPS
23.976

Bitrate
18.4 Mbps

Decoder
Hardware

Buffer
42s

Dropped Frames
0
```

---

# TESTES

Não considerar funcionalidade pronta sem testes adequados.

Cobrir:

## Unit

- source scoring;
- Smart Collection filters;
- playback state;
- profile settings;
- addon parsing;
- cache;
- Scene Bookmarks.

## Integration

- Nuvio login;
- sync;
- addons;
- stream resolution;
- playback;
- downloads;
- failover.

## UI

Desktop:

- keyboard;
- mouse;
- hover previews;
- dialogs;
- player.

TV:

- D-pad;
- focus restoration;
- horizontal rails;
- EPG;
- player controls.

## Performance

Medir:

- startup;
- Home;
- memory;
- preview startup;
- image loading;
- scroll;
- TV focus latency;
- player startup.

---

# VISUAL QA

Testar pelo menos:

Desktop:

```text
1366×768
1920×1080
2560×1440
3840×2160
```

TV:

```text
720p
1080p
4K
```

Verificar:

- clipping;
- overscan;
- text;
- focus;
- poster ratios;
- gradients;
- loading;
- animations.

---

# FASE 0 — AUDITORIA

Entregar:

```text
docs/ARCHITECTURE_AUDIT.md
docs/FEATURE_GAP.md
docs/Nuvio_COMPATIBILITY.md
docs/SECURITY_THREAT_MODEL.md
docs/ROADMAP.md
```

`FEATURE_GAP.md` deve comparar:

```text
Nuvio Desktop atual
Nuvio TV atual
Nuvio Enhanced planejado
```

Não invente ausência de recurso.

Confirme pelo código atual.

---

# FASE 1 — FUNDAÇÃO VISUAL

Implementar:

- design system;
- motion system;
- shell;
- navigation;
- nova Home;
- nova tela de detalhes;
- profile selection;
- Profile Studio foundation;
- image pipeline;
- cache foundation.

---

# FASE 2 — PLAYER EXPERIENCE

Implementar:

- player UI;
- timeline;
- scene thumbnails;
- filmstrip;
- chapters;
- bookmarks;
- subtitle/audio UX;
- technical stats;
- playback transitions.

---

# FASE 3 — CINEMATIC EXPERIENCE

Implementar:

- Cinematic Preview;
- Hero preview;
- Ambient UI;
- advanced card states;
- shared transitions;
- preload manager.

---

# FASE 4 — INTELLIGENT PLAYBACK

Implementar:

- DeviceCapabilities;
- Source Intelligence;
- pre-flight;
- quality modes;
- failover.

---

# FASE 5 — ANDROID TV

Implementar/refatorar:

- TV design system;
- Home;
- hero;
- rails;
- focus engine;
- details;
- profiles;
- player;
- thumbnail seek;
- adaptive performance.

Use o repositório Nuvio TV atual como referência real.

---

# FASE 6 — LIVE TV

Implementar:

- TV area;
- channel model;
- EPG architecture;
- favorites;
- recents;
- quick channel switching;
- source integration.

Timeshift e Multi-view ficam atrás de feature flag inicialmente.

---

# FASE 7 — SCENE INFO

Criar arquitetura de providers.

Não bloquear as fases anteriores esperando esse recurso.

Implementar inicialmente apenas quando houver metadata confiável.

Reconhecimento local fica experimental.

---

# FASE 8 — PHONE REMOTE

Implementar:

- local pairing;
- QR;
- secure tokens;
- WebSocket;
- mobile web controller;
- keyboard;
- playback controls.

---

# MVP 1

O primeiro release funcional deve obrigatoriamente possuir:

```text
✓ login Nuvio existente
✓ sync existente preservado
✓ addons Stremio preservados
✓ nova Home
✓ nova identidade visual
✓ motion system
✓ nova página de detalhes
✓ Profile Studio
✓ avatar por arquivo/drag/clipboard
✓ biblioteca interna de avatares
✓ player renovado
✓ timeline renovada
✓ thumbnails durante seek
✓ filmstrip básico
✓ Cinematic Preview
✓ Ambient UI
✓ Source Intelligence básico
✓ nova experiência Android TV
✓ D-pad corretamente implementado
✓ performance adaptativa
```

---

# MVP 2

Adicionar:

```text
TV ao vivo
EPG
Failover avançado
Phone Remote
Smart Collections
download improvements
Spoiler Shield completo
```

---

# MVP 3

Adicionar:

```text
Scene Info
timed cast metadata
music metadata
advanced filmstrip
local analysis experimental
timeshift
multi-view
advanced recommendations
```

---

# CRITÉRIOS DE ACEITE

Não considerar a nova UI pronta apenas porque compila.

O MVP só está aceitável quando:

1. login existente continua funcionando;
2. biblioteca existente não é perdida;
3. progresso não sofre regressão;
4. addons Stremio continuam funcionando;
5. reprodução básica não piorou;
6. Home permanece fluida;
7. preview não dispara múltiplos players;
8. cache possui limites;
9. timeline mostra thumbnails corretamente;
10. TV funciona integralmente com D-pad;
11. foco não se perde após navegação;
12. TV Box modesto continua utilizável;
13. Reduced Motion funciona;
14. arquivos de avatar são validados;
15. nenhuma credencial aparece nos logs;
16. testes principais passam;
17. não existem botões falsos;
18. funcionalidades incompletas ficam atrás de feature flags;
19. build Windows funciona;
20. build Android TV funciona.

---

# DEFINIÇÃO DE PRONTO

Uma funcionalidade só está pronta quando existir:

```text
implementation
loading state
empty state
error state
keyboard/D-pad behavior
accessibility
performance verification
tests
documentation
```

---

# PROCESSO DE IMPLEMENTAÇÃO

Não tente fazer tudo em um commit.

Divida em PRs/fases pequenas e verificáveis.

Antes de cada fase:

1. inspecione o código relacionado;
2. documente o impacto;
3. implemente;
4. teste;
5. execute build;
6. corrija regressões;
7. revise visualmente;
8. só depois avance.

Não pare depois de gerar documentação ou planejamento.

Depois da auditoria, comece a implementação real.

---

# RESTRIÇÕES

Não:

- criar outro login;
- remover compatibilidade Nuvio;
- remover Stremio addons;
- distribuir conteúdo;
- incluir listas piratas;
- hardcodar providers ilegais;
- copiar assets da Netflix/Amazon/Apple;
- criar dependência de APIs pagas;
- depender de IA na nuvem;
- mandar dados de consumo do usuário sem consentimento;
- inserir telemetria obrigatória;
- inventar endpoints;
- sacrificar segurança para acelerar desenvolvimento.

Priorizar soluções:

- open source;
- locais;
- gratuitas;
- existentes na stack atual.

---

# RESULTADO ESPERADO

A experiência final não deve parecer:

`Nuvio + tema novo`

Ela deve parecer:

`uma evolução completa do cliente Nuvio`

Mantendo a compatibilidade que já torna o Nuvio útil, mas adicionando:

```text
Cinematic Preview
Profile Studio
Custom Avatars
Ambient UI
Scene Thumbnails
Filmstrip
Scene Bookmarks
Scene Info
Source Intelligence
Seamless Failover
Smart Home
Smart Collections
Android TV UX
Live TV
EPG
Phone Remote
Adaptive Performance
Advanced Player
```

A sensação final precisa ser de um media center open source de alto nível para PC e televisão.

Comece agora pela auditoria dos repositórios oficiais listados no início, identifique exatamente o que já existe e o que precisa ser alterado e, em seguida, execute as fases de implementação sem reconstruir recursos que o Nuvio já resolve corretamente.

## Instruções adicionais aprovadas — 2026-10-04


A partir daqui, não crie uma implementação paralela, um protótipo separado ou uma recriação do Nuvio.

Use diretamente os arquivos, módulos, componentes, players, repositories, models, navegação, sistema de perfis, addons, sync, cache e infraestrutura já existentes nos forks oficiais do Nuvio Desktop e Nuvio TV.

A regra principal deste projeto é:

EVOLUIR O NUVIO EXISTENTE, NÃO RECONSTRUIR O NUVIO.

Antes de criar qualquer arquivo novo, procure no código atual se já existe algo que possa ser estendido, refatorado ou reutilizado.

Se já existir:

- componente;
- tela;
- ViewModel;
- repository;
- model;
- player;
- sistema de preview;
- sistema de avatar;
- sistema de perfil;
- navegação;
- focus manager;
- addon manager;
- stream resolver;
- cache;
- download manager;
- settings;
- integração com backend;

trabalhe em cima disso.

Não duplique funcionalidades existentes só para implementar uma versão nossa.

Desktop e Android TV continuam sendo forks separados, preservando o histórico e a arquitetura de cada upstream.

Não transforme tudo em um monorepo.

Compartilhe somente regras novas realmente independentes de plataforma através de uma biblioteca pequena quando isso for tecnicamente útil.

==================================================
BASE EXISTENTE QUE DEVE SER PRESERVADA
==================================================

No Desktop, preserve a arquitetura atual em:

- Kotlin Multiplatform;
- Compose Multiplatform;
- commonMain;
- implementação Desktop atual;
- libmpv;
- bridge JNI;
- infraestrutura atual do player;
- integração WebView2 onde já existir.

No Android TV, preserve:

- Kotlin;
- Jetpack Compose;
- TV Material 3;
- Android Media3;
- arquitetura de navegação atual;
- focus restoration existente;
- seek progressivo existente;
- trailer pool existente.

Não troque libmpv ou Media3 sem existir um problema técnico comprovado que realmente exija isso.

==================================================
COMPATIBILIDADE
==================================================

O Nuvio Enhanced deve continuar utilizando o ecossistema Nuvio.

Preserve:

- login;
- sessão;
- perfis;
- biblioteca;
- progresso;
- histórico;
- sync;
- addons;
- metadata;
- streams;
- legendas;
- downloads;
- configurações existentes.

Não crie outro login.

Não invente endpoints.

Não modifique contratos do backend sem necessidade.

O Nuvio oficial e o Nuvio Enhanced precisam poder ficar instalados juntos.

Use:

- package ID próprio;
- application ID próprio;
- diretórios próprios;
- cache próprio;
- banco/configurações locais próprias;
- updater próprio.

Mesmo assim, mantenha o mesmo login e sync Nuvio sempre que o backend atual suportar.

==================================================
ADDONS STREMIO
==================================================

A compatibilidade com addons Stremio é obrigatória.

Não substitua o sistema atual.

Preserve e amplie o suporte existente para:

- manifest;
- catalog;
- meta;
- stream;
- subtitles;
- configuration;
- authentication;
- addon URLs;
- parâmetros;
- tratamento de erros.

Crie uma área de Addons melhor:

Addons
├── Descobrir
├── Instalados
├── Atualizações
├── Configurar
└── Desenvolvedor

Cada addon pode mostrar:

- nome;
- ícone;
- versão;
- descrição;
- origem;
- status;
- capabilities;
- latência;
- último erro;
- habilitado/desabilitado.

Um addon quebrado nunca pode derrubar a Home inteira.

==================================================
INTERFACE
==================================================

Use as telas e componentes existentes como ponto de partida e transforme a experiência visual.

Não simplesmente aplique novas cores.

A interface precisa ter uma linguagem cinematográfica própria inspirada na qualidade de:

- Apple TV;
- Netflix;
- Plex;

sem copiar identidade, assets ou layouts 1:1.

Criar um design system consistente para:

- cores;
- tipografia;
- spacing;
- radius;
- elevation;
- blur;
- focus;
- motion;
- duration;
- easing.

Visual:

- dark;
- OLED opcional;
- backdrops grandes;
- boa profundidade;
- gradientes contextuais;
- blur controlado;
- tipografia forte;
- cards bem definidos;
- sem aparência genérica;
- sem neon excessivo.

==================================================
ANIMAÇÕES
==================================================

Todas as interações importantes precisam ter feedback fluido.

Use aproximadamente:

micro:
120–180 ms

standard:
180–280 ms

large:
280–450 ms

ambient:
500–900 ms

Use springs quando fizer sentido.

Criar:

- Reduced Motion;
- animações reduzidas;
- animações desativadas.

Target de navegação:

60 FPS.

==================================================
HOME
==================================================

Evolua a Home atual.

Criar suporte para seções como:

- Continue assistindo;
- Minha lista;
- Filmes;
- Séries;
- Anime;
- Em alta;
- Lançamentos;
- 4K;
- HDR;
- Adicionados recentemente;
- Assistir novamente;
- Recomendações;
- TV ao vivo.

Permitir reorganização das seções.

Não carregar tudo simultaneamente.

Usar lazy rendering, cache e preload controlado.

==================================================
HERO
==================================================

Criar hero cinematográfico contendo:

- backdrop;
- logo/título;
- descrição;
- ano;
- duração;
- classificação;
- rating;
- qualidade;
- assistir;
- continuar;
- minha lista;
- trailer.

O hero deve reagir ao conteúdo atualmente selecionado.

==================================================
CINEMATIC PREVIEW
==================================================

O Nuvio já possui base de preview.

Não recrie do zero.

Centralize e evolua o sistema existente.

Desktop:

ao deixar o mouse aproximadamente 750 ms sobre filme, série ou episódio:

- card expande;
- aparecem informações;
- preview começa a carregar;
- trailer ou preview começa silencioso;
- aparecem ações rápidas.

Android TV:

mesmo conceito após aproximadamente 1200 ms de foco estável.

Nunca permitir vários previews ativos ao mesmo tempo.

Criar ou consolidar uma abstração como:

PreviewCoordinator

Responsável por:

- debounce;
- cancelamento;
- preload;
- lifecycle;
- ownership;
- cache;
- release dos recursos.

Prioridade:

trailer
→ teaser
→ preview do provider
→ backdrop estático.

Som desligado por padrão.

==================================================
AMBIENT UI
==================================================

Usar o backdrop atual para extrair uma pequena paleta.

Aplicar discretamente em:

- gradientes;
- background;
- ambient light;
- highlights.

Não transformar a tela inteira na cor dominante.

Fazer transições suaves quando o conteúdo selecionado mudar.

==================================================
PROFILE STUDIO
==================================================

Aproveite o sistema de perfil, avatar, PIN e sync já existente.

Amplie.

Não obrigue o usuário a acessar um site para encontrar avatar e copiar uma URL.

Permitir:

- escolher arquivo;
- drag-and-drop;
- Ctrl+V;
- biblioteca interna;
- URL como opção avançada;
- webcam futuramente;
- avatar animado futuramente.

Criar editor de avatar com:

- crop;
- zoom;
- reposition;
- preview;
- compressão;
- geração de tamanhos derivados.

Validar o conteúdo real do arquivo.

Criar biblioteca de avatares integrada com assets permitidos.

Categorias:

- Abstract;
- Animals;
- Pixel;
- Fantasy;
- Sci-Fi;
- Minimal;
- Nature;
- Original Characters.

==================================================
PERFIS
==================================================

Permitir configurações específicas por perfil:

- avatar;
- capa;
- accent;
- tema;
- idioma;
- áudio preferido;
- legenda;
- tamanho da legenda;
- qualidade;
- player;
- layout.

Preparar:

- perfil normal;
- Guest;
- Kids;
- PIN.

Adicionar:

Clonar perfil.

O usuário escolhe o que copiar.

Por padrão:

copiar:
- addons;
- idioma;
- legendas;
- player;
- aparência;
- preferências.

não copiar automaticamente:
- histórico;
- biblioteca;
- progresso.

==================================================
PLAYER
==================================================

Melhore o player existente.

Não substitua os motores atuais sem justificativa.

Criar nova interface para:

- play/pause;
- seek;
- áudio;
- legendas;
- qualidade;
- velocidade;
- capítulos;
- PiP;
- fullscreen;
- próximo episódio;
- skip intro;
- skip recap;
- skip credits;
- autoplay.

Adicionar painel técnico opcional:

Resolution
Codec
HDR
FPS
Bitrate
Decoder
Buffer
Dropped Frames

==================================================
TIMELINE
==================================================

A timeline precisa ser um dos principais diferenciais.

Mostrar:

- progresso;
- duração;
- intro;
- recap;
- capítulos;
- bookmarks;
- créditos.

==================================================
THUMBNAILS DAS CENAS
==================================================

Ao passar o mouse pela timeline, mostrar uma thumbnail real correspondente ao timestamp.

Ao avançar ou retroceder, mostrar a cena correspondente.

Prioridade:

thumbnail fornecida pela fonte
→ sprite sheet
→ metadata existente
→ geração local
→ cache.

Não reposicione o player principal para gerar thumbnails.

No Desktop, use a infraestrutura libmpv de maneira isolada.

No TV, utilize mecanismos compatíveis com Media3/Android sem interferir no playback atual.

Cancelar solicitações antigas se o usuário mover rapidamente o seek.

==================================================
FILMSTRIP
==================================================

Hover simples:

uma thumbnail.

Ao arrastar a timeline:

mostrar sequência de frames próximos.

Exemplo:

[01:21:20]
[01:21:30]
[01:21:40]
[01:21:50]
[01:22:00]

Na TV:

seek curto:
thumbnail grande.

seek contínuo:
filmstrip.

==================================================
SEEK NA TV
==================================================

Evolua o seek progressivo já existente.

Exemplo:

tap:
+10s

continuar pressionando:
+30s
+1m
+5m

Mostrar sempre:

- thumbnail;
- timestamp;
- posição na timeline.

==================================================
SCENE BOOKMARKS
==================================================

Permitir salvar momentos.

Persistir:

- media ID;
- episode ID;
- timestamp;
- label;
- createdAt.

Exemplo:

00:32:18 — Cena favorita
01:12:43 — Rever depois.

==================================================
TIMED METADATA
==================================================

Mesmo que Scene Info completo seja implementado depois, prepare desde já na camada do player uma abstração genérica de timed metadata.

Ela deve poder representar informações relacionadas a intervalos de tempo do conteúdo.

Isso evita refatorar toda a timeline futuramente.

==================================================
SCENE INFO
==================================================

Criar depois uma experiência contextual semelhante ao conceito de X-Ray do Prime Video, mas não usar o nome X-Ray.

Nome temporário:

Scene Info.

Ao pausar ou abrir o painel:

mostrar quando houver dados confiáveis:

- atores;
- personagens;
- música;
- capítulo;
- curiosidades;
- metadata daquela cena.

Arquitetura:

SceneMetadataProvider
├── metadata provider
├── timed metadata
├── community metadata
└── análise local experimental.

Não usar IMDb através de scraping.

Não afirmar que determinada pessoa está na cena sem metadata ou análise confiável.

==================================================
SOURCE INTELLIGENCE
==================================================

Evolua a resolução atual de streams.

Criar score explicável.

Avaliar:

- disponibilidade;
- resolução;
- HDR;
- codec;
- bitrate;
- idioma;
- áudio;
- latência;
- compatibilidade do hardware;
- estabilidade.

Score inicial:

qualidade: 30
idioma/áudio: 20
hardware: 20
disponibilidade/latência: 20
estabilidade: 10

Mostrar a decomposição do score quando o usuário quiser.

Modos:

- Best Quality;
- Balanced;
- Data Saver;
- Manual.

==================================================
PRE-FLIGHT
==================================================

Antes da reprodução, verificar quando necessário:

- fonte disponível;
- codec;
- hardware decoder;
- HDR;
- áudio preferido;
- legenda.

Não adicionar atraso perceptível sem necessidade.

==================================================
FAILOVER
==================================================

Preparar troca automática de fonte.

Se a fonte atual falhar:

- salvar timestamp;
- encontrar alternativas;
- testar rapidamente;
- trocar;
- continuar aproximadamente do mesmo ponto.

Modos:

- Quality First;
- Balanced;
- Never Downgrade.

Evitar loops infinitos.

==================================================
DEVICE CAPABILITIES
==================================================

Centralizar capacidades do dispositivo:

- GPU;
- codecs;
- HDR;
- resolução;
- refresh rate;
- memória;
- decoder.

Criar uma abstração central como:

DeviceCapabilities.

Não espalhar verificações específicas pelo projeto.

==================================================
ANDROID TV
==================================================

Não reutilize simplesmente a UI Desktop.

A experiência Android TV deve continuar sendo própria.

Tudo deve funcionar através de:

↑
↓
←
→
OK
Back
Play/Pause

Mouse não pode ser obrigatório.

==================================================
FOCUS ENGINE
==================================================

Aproveite e melhore os mecanismos de restauração de foco já existentes.

Testar:

- foco inicial;
- voltar de detalhes;
- voltar do player;
- rail horizontal;
- troca entre rails;
- dialogs;
- modais;
- lazy lists;
- carregamento;
- recomposição;
- EPG.

Não aceite uma tela visualmente boa com navegação ruim por D-pad.

==================================================
TV BOX FRACO
==================================================

Referência mínima principal:

2 GB RAM
1080p.

Criar modos:

- Auto;
- Performance;
- Balanced;
- Cinematic.

Auto decide de acordo com DeviceCapabilities.

Performance reduz:

- blur;
- previews;
- preload;
- imagens;
- efeitos.

Cinematic libera mais efeitos em hardware capaz.

==================================================
ÁREA TV
==================================================

Preparar uma área dedicada:

TV
├── Agora
├── Guia
├── Canais
├── Favoritos
└── Recentes.

Não distribuir canais ou listas dentro do aplicativo.

Utilizar somente fontes configuradas pelo usuário ou providers compatíveis.

==================================================
LIVE TV E EPG
==================================================

Preparar suporte para:

- XMLTV;
- provider de EPG;
- logos;
- timezone;
- cache;
- atualização;
- programa atual;
- próximo programa;
- progresso.

Criar componentes visuais já durante a fundação, mas não mostrar funcionalidades falsas antes de estarem prontas:

- ChannelCard;
- ProgramCard;
- EPGCell;
- LiveBadge;
- ChannelLogo;
- ProgramProgress.

==================================================
PHONE REMOTE
==================================================

Posteriormente adicionar controle pelo celular.

Fluxo:

PC/TV
→ QR Code
→ celular abre página local
→ pareamento
→ WebSocket
→ controle.

Sem cloud obrigatória.

Exigir:

- token aleatório;
- expiração;
- confirmação;
- revogação;
- rate limiting;
- remembered devices opcional.

==================================================
CACHE
==================================================

Centralizar:

- posters;
- backdrops;
- avatars;
- previews;
- timeline thumbnails;
- filmstrip;
- metadata;
- addons;
- EPG;
- Scene Info.

Defaults iniciais:

Desktop:
1 GiB.

TV:
256 MiB.

Mas não trate isso como limite rígido.

Adicionar:

Auto
512 MB
1 GB
2 GB
Personalizado

conforme plataforma.

Auto considera:

- armazenamento livre;
- memória;
- capacidade do dispositivo.

Downloads ficam fora desse cache.

==================================================
SMART COLLECTIONS
==================================================

Criar depois filtros combináveis.

Exemplo:

type = movie
genre = horror
watched = false
rating >= 7
runtime <= 120

Resultado:

"Terror bom com menos de duas horas".

==================================================
BUSCA UNIVERSAL
==================================================

No Desktop, Ctrl+K.

Pesquisar:

- filmes;
- séries;
- episódios;
- pessoas;
- biblioteca;
- comandos.

Exemplos:

Duna
filmes HDR
continuar Duna
abrir downloads
mudar perfil
configurar legenda.

==================================================
CONTINUE ASSISTINDO
==================================================

Melhorar a área existente.

Mostrar:

- título;
- episódio;
- progresso;
- tempo restante.

Ações:

- continuar;
- recomeçar;
- próximo episódio;
- marcar assistido;
- remover.

==================================================
HISTÓRICO
==================================================

Criar histórico visual.

Preparar estatísticas locais:

- horas assistidas;
- filmes;
- episódios;
- gêneros;
- reassistidos.

Não depender de IA ou API paga.

==================================================
ESCOLHA PARA MIM
==================================================

Criar seletor local por:

- tipo;
- gênero;
- duração;
- rating;
- assistido/não assistido;
- ano.

Nada de depender de LLM.

==================================================
SEGURANÇA
==================================================

Revisar:

- addon injection;
- metadata maliciosa;
- path traversal;
- SSRF;
- URLs;
- downloads;
- avatares;
- arquivos locais;
- logs;
- tokens;
- remote pairing;
- deep links;
- command execution.

Nunca execute comandos do sistema baseados diretamente em dados vindos de addons.

Redigir nos logs:

- tokens;
- authorization;
- cookies;
- passwords;
- URLs contendo secrets.

==================================================
NÃO FAZER
==================================================

Não criar outro app paralelo dentro do fork.

Não duplicar componentes existentes sem necessidade.

Não substituir arquitetura funcional apenas porque uma biblioteca diferente parece mais moderna.

Não criar outro login.

Não quebrar sync.

Não quebrar addons Stremio.

Não remover recursos atuais.

Não colocar botão falso.

Não declarar feature pronta sem funcionar.

Não usar API paga como requisito.

Não depender de IA cloud.

Não adicionar telemetria externa por padrão.

Não distribuir conteúdo protegido.

==================================================
FLUXO DE TRABALHO
==================================================

Para cada funcionalidade:

1. encontre a implementação atual relacionada;
2. leia os arquivos existentes;
3. identifique o melhor ponto de extensão;
4. reutilize o que já funciona;
5. refatore apenas quando necessário;
6. implemente;
7. teste;
8. compile;
9. valide visualmente;
10. documente;
11. só então avance.

Se perceber que um recurso solicitado já existe parcialmente no Nuvio, não recrie.

Liste:

- o que já existe;
- o que falta;
- quais arquivos serão modificados;
- como será evoluído.

==================================================
REGRA FINAL
==================================================

O resultado não deve ser:

"um app novo inspirado no Nuvio".

Também não deve ser:

"Nuvio com outro tema".

Tem que ser literalmente a evolução dos clientes existentes:

Nuvio atual
+
nova experiência visual
+
novas interações
+
player melhorado
+
timeline com thumbnails
+
filmstrip
+
Cinematic Preview
+
Profile Studio
+
avatares livres
+
Ambient UI
+
Source Intelligence
+
Scene Info
+
Android TV melhor
+
Live TV
+
EPG
+
Phone Remote
+
novas funcionalidades.

Comece trabalhando nos arquivos existentes dos forks.

Não recrie a base.

Preserve tudo que já funciona e faça as novas funcionalidades nascerem integradas à arquitetura real do Nuvio.

https://github.com/NuvioMedia
