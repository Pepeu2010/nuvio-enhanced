A meta deste projeto é pegar os clientes reais e existentes do Nuvio Desktop e Android TV e transformá-los em uma evolução muito mais avançada do próprio Nuvio, preservando o que já funciona na infraestrutura, login, sync, biblioteca, progresso, addons Stremio, streaming, player e ecossistema, mas reconstruindo completamente a experiência visual e de uso.\
\
A interface final não pode parecer uma modificação, skin, tema ou pequena evolução do Nuvio atual. Visualmente, quero 0% de aparência do Nuvio atual. Use o código existente como fundação técnica, mas redesenhe completamente Home, navegação, cards, menus, player, perfis, detalhes de filmes e séries, busca, biblioteca, configurações, addons, downloads, TV, EPG e todas as superfícies importantes.\
\
O resultado precisa parecer um novo media center premium desenvolvido sobre a infraestrutura do Nuvio, com identidade visual própria e nível de acabamento superior ao cliente oficial.\
\
Não preserve componentes visuais simplesmente porque já existem. Preserve lógica e infraestrutura úteis, mas quando a UI atual limitar a nova experiência, refatore ou substitua a camada visual.\
\
A interface precisa ser sofisticada, cinematográfica, extremamente fluida e reativa, com design system consistente, tipografia bem trabalhada, hierarquia visual forte, dark mode, OLED mode, backdrops de alta qualidade, iluminação contextual, gradientes bem controlados, blur moderado, profundidade, motion design e transições naturais.\
\
As animações precisam existir em toda a experiência onde agregarem feedback: entrada e saída de telas, cards, mudança de conteúdo selecionado, abertura de detalhes, expansão de menus, player, overlays, troca de perfil, carregamentos e estados de foco. Evite animações gratuitas ou lentas. A meta é transmitir velocidade e qualidade.\
\
A Home precisa ser completamente redesenhada, com hero cinematográfico, seções reorganizáveis, Continue Assistindo muito mais rico, Minha Lista, filmes, séries, anime, lançamentos, 4K, HDR, recomendações, TV ao vivo e Smart Collections.\
\
Ao permanecer com o mouse sobre um filme ou série no Desktop, ou deixar o foco parado sobre ele na TV, o card precisa reagir e depois iniciar um preview silencioso da obra, semelhante ao comportamento de serviços premium. O preview deve usar trailer, teaser ou preview disponível, possuir preload controlado e garantir apenas um preview ativo por vez.\
\
O card deve poder se transformar em uma experiência expandida com título, ano, duração, qualidade, ações rápidas e reprodução do preview, retornando suavemente ao estado original ao sair.\
\
A página de um filme ou série precisa ser uma das partes mais sofisticadas do aplicativo. Quero backdrop cinematográfico, logo ou título, metadata, qualidade, progresso, ações principais, sinopse, elenco, direção, temporadas, episódios, recomendações e informações contextuais, organizados sem poluição visual.\
\
Implemente um sistema de Scene Info inspirado no conceito do X-Ray do Prime Video, sem copiar identidade ou utilizar a marca X-Ray como nome do recurso. Durante uma cena, ao pausar ou abrir o painel contextual, o aplicativo deve conseguir apresentar dados disponíveis daquela parte do conteúdo, como atores, personagens, música, capítulo, curiosidades e metadata temporal.\
\
Esse recurso deve ser arquitetado através de timed metadata e SceneMetadataProvider, permitindo múltiplas fontes confiáveis de informação. Quando uma informação não puder ser determinada com confiança, não invente.\
\
A timeline do player precisa ser muito mais avançada que a atual. Ao passar o mouse sobre qualquer posição do filme, mostre uma thumbnail correspondente àquela cena e ao timestamp selecionado.\
\
Durante o seek, a imagem precisa mudar conforme o usuário avança ou retrocede. Ao arrastar a timeline ou fazer scrubbing mais longo, mostre um filmstrip com múltiplos frames próximos, facilitando encontrar visualmente uma cena.\
\
Na Android TV, ao avançar ou retroceder com o controle, mostre uma thumbnail grande da cena atual do seek, timestamp e posição visual. Seek contínuo deve poder evoluir para filmstrip e acelerar progressivamente.\
\
A timeline também deve suportar visualização de intro, recap, capítulos, bookmarks, créditos e outros timed events disponíveis.\
\
Crie Scene Bookmarks para salvar momentos específicos de filmes e episódios, incluindo media ID, episódio, timestamp, nome e data. O usuário deve conseguir voltar diretamente àquela cena.\
\
Renove completamente a UI do player sem substituir os motores de reprodução existentes sem necessidade técnica. O Desktop continua aproveitando libmpv e a TV continua aproveitando Media3 quando adequado.\
\
O player precisa possuir áudio, legendas, offsets, velocidade, qualidade, capítulos, PiP, fullscreen, próximo episódio, autoplay, skip intro, skip recap, skip credits e painel técnico opcional contendo resolução, codec, HDR, FPS, bitrate, decoder, buffer e dropped frames.\
\
Crie Source Intelligence para analisar as fontes disponíveis e selecionar automaticamente a mais adequada com base em resolução, HDR, codec, bitrate, idioma, áudio, compatibilidade com hardware, latência, disponibilidade e estabilidade.\
\
A decisão não pode ser uma caixa-preta. O score precisa ser explicável.\
\
Ofereça modos Best Quality, Balanced, Data Saver e Manual.\
\
Implemente pre-flight antes da reprodução quando necessário, validando fonte, codec, decoder, HDR, áudio e legenda sem aumentar desnecessariamente o tempo de início.\
\
Implemente Seamless Failover. Se uma fonte parar de funcionar durante a reprodução, registre a posição, procure rapidamente alternativas compatíveis, escolha outra fonte e tente continuar do mesmo timestamp sem jogar imediatamente um erro para o usuário.\
\
Evite ciclos infinitos de troca de fonte.\
\
Crie DeviceCapabilities centralizado para detectar capacidades relevantes de GPU, codecs, HDR, resolução, refresh rate, memória e decoder. Use isso para adaptar reprodução, previews, cache e efeitos visuais.\
\
A experiência precisa se adaptar automaticamente ao aparelho. Uma máquina potente pode utilizar experiência Cinematic completa. Uma TV Box com 2 GB de RAM e 1080p precisa continuar fluida através de modo Auto ou Performance, reduzindo blur, preload e efeitos pesados sem destruir a identidade visual.\
\
O sistema de perfis precisa ser completamente evoluído através do Profile Studio.\
\
Não quero ficar limitado aos avatares padrões do Nuvio nem ter que acessar outro site, procurar uma imagem, copiar uma URL e colar no aplicativo.\
\
Permita escolher qualquer imagem local compatível, arrastar e soltar, colar pelo clipboard e escolher avatares em uma biblioteca integrada do próprio aplicativo. URL pode permanecer como alternativa avançada.\
\
Crie editor de avatar com crop, zoom, reposicionamento, preview, compressão e geração de versões otimizadas.\
\
Inclua uma biblioteca grande de avatares devidamente licenciados ou originais, com categorias como abstratos, animais, pixel art, fantasia, sci-fi, minimalistas, natureza e personagens originais.\
\
Prepare posteriormente suporte para webcam e avatares animados.\
\
Cada perfil pode possuir aparência, accent, tema, capa, idioma, preferência de áudio, preferência e tamanho de legenda, qualidade e configurações do player.\
\
Inclua perfil normal, convidado, infantil e proteção por PIN.\
\
Crie Clonar Perfil para copiar configurações selecionadas entre perfis. Histórico, biblioteca e progresso não devem ser copiados silenciosamente.\
\
A tela de seleção de perfis também precisa ser totalmente redesenhada com visual cinematográfico, avatares grandes, animações, background relacionado ao perfil e ótima experiência tanto no Desktop quanto na TV.\
\
A compatibilidade com addons Stremio existente no Nuvio é obrigatória.\
\
Preserve suporte aos addons existentes e evolua a experiência.\
\
Crie um Addon Manager completo com Descobrir, Instalados, Atualizações, Configuração e Desenvolvedor.\
\
Mostre nome, ícone, versão, descrição, origem, status, capabilities, latência, último erro e opção de habilitar ou desabilitar.\
\
Falha em um addon nunca deve derrubar a interface inteira.\
\
Preserve compatibilidade com manifest, catalog, meta, stream, subtitles, configuração, autenticação e URLs compatíveis existentes.\
\
Crie uma área própria de TV.\
\
Ela deve incluir Agora, Guia, Canais, Favoritos e Recentes.\
\
Prepare suporte para TV ao vivo proveniente exclusivamente de fontes configuradas pelo usuário ou providers compatíveis.\
\
Não distribua canais, listas ou conteúdo protegido dentro do aplicativo.\
\
Implemente EPG com suporte adequado para XMLTV e providers compatíveis, timezone, logos, cache, atualização, programa atual, próximo programa e progresso.\
\
A experiência do guia precisa ser sofisticada e utilizável com mouse no Desktop e D-pad na TV.\
\
Prepare troca rápida de canais, favoritos, canais recentes, mini-player e evolução posterior para timeshift e multi-view quando tecnicamente suportados.\
\
Crie também uma experiência Android TV realmente própria.\
\
Não pegue simplesmente a interface Desktop e aumente tudo.\
\
Home, hero, rails, detalhes, perfis, busca, player, TV e EPG precisam ser projetados para navegação por D-pad.\
\
Toda a aplicação TV deve funcionar corretamente com cima, baixo, esquerda, direita, OK, Back e Play/Pause.\
\
O sistema de foco é infraestrutura central. O foco precisa ser previsível, visualmente evidente e restaurado corretamente ao voltar de detalhes, player, dialogs e outras telas.\
\
A UI da TV deve possuir cards maiores, tipografia adequada à distância, menos ruído visual e animações rápidas.\
\
O Cinematic Preview também deve funcionar na TV após foco estável.\
\
Crie Living Room Mode para experiência de sofá e Cinema Mode no Desktop para PCs conectados a uma televisão.\
\
Crie Ambient UI para que backdrops influenciem discretamente gradientes, iluminação e atmosfera da interface conforme o conteúdo selecionado.\
\
Crie Ambient Mode para períodos de inatividade, funcionando como uma experiência visual cinematográfica com backdrops, horário e informações discretas.\
\
Implemente busca universal. No Desktop, Ctrl+K deve permitir pesquisar conteúdo e executar ações.\
\
A busca pode localizar filmes, séries, episódios, pessoas, biblioteca e comandos como continuar um filme, abrir downloads, mudar perfil ou encontrar conteúdo HDR.\
\
Melhore completamente Continue Assistindo, exibindo episódio, progresso, tempo restante e ações como continuar, recomeçar, próximo episódio, marcar como assistido e remover.\
\
Crie Spoiler Shield para proteger thumbnails, títulos e descrições de episódios futuros de acordo com níveis configuráveis.\
\
Crie Smart Collections baseadas em regras combináveis, permitindo coleções automáticas como filmes de terror não assistidos com nota acima de 7 e duração abaixo de duas horas.\
\
Crie um recurso Escolha Para Mim totalmente local, baseado em filtros como tipo, gênero, duração, nota, ano e estado assistido, sem depender de LLM ou API paga.\
\
Crie histórico visual com timeline de consumo e estatísticas locais como horas assistidas, filmes, episódios, gêneros e conteúdos reassistidos.\
\
Melhore o Download Manager com progresso, velocidade, ETA, tamanho, qualidade, áudio, legendas, diretório e espaço disponível. Prepare suporte para gerenciamento inteligente de episódios quando permitido pela fonte.\
\
Crie posteriormente Phone Remote para transformar qualquer celular da rede local em controle remoto através de QR Code, sessão segura e WebSocket.\
\
O celular deve permitir D-pad, teclado, play/pause, seek, volume, legendas e outros controles úteis.\
\
O pareamento precisa exigir token temporário, confirmação explícita, revogação e proteção contra dispositivos não autorizados na mesma rede.\
\
Centralize políticas de cache para posters, backdrops, avatars, previews, thumbnails da timeline, filmstrip, metadata, respostas de addons, EPG e Scene Info.\
\
Os limites iniciais podem partir de 1 GiB no Desktop e 256 MiB na TV, mas devem ser configuráveis e possuir modo Auto baseado em armazenamento e capacidades do aparelho.\
\
Não deixe cache crescer indefinidamente.\
\
O produto precisa continuar funcionando de maneira coerente offline sempre que os dados necessários estiverem armazenados localmente.\
\
Downloads, metadata em cache, imagens, histórico local, bookmarks e configurações não devem desaparecer porque o servidor ficou temporariamente indisponível.\
\
Preserve a mesma conta e o ecossistema do Nuvio sempre que suportado pelo backend atual, mas mantenha os dados exclusivos deste fork em armazenamento próprio e versionado.\
\
O Nuvio oficial e este fork precisam poder ficar instalados simultaneamente sem compartilhar indevidamente cache, banco local, configurações, updater ou package ID.\
\
Use diretamente os arquivos existentes dos forks do Nuvio Desktop e Nuvio TV.\
\
Antes de criar qualquer componente, model, repository, player, manager ou tela nova, procure uma implementação atual relacionada e evolua o que já existe.\
\
Se o Nuvio já possuir parte do recurso, amplie aquela implementação.\
\
Não construa uma versão paralela sem motivo.\
\
Não substitua libmpv, Media3, arquitetura de estado, repositories ou outras partes funcionais só porque outra tecnologia parece mais interessante.\
\
Refatore apenas quando existir ganho técnico concreto.\
\
Visualmente, entretanto, não existe obrigação de manter a aparência antiga. A camada de interface deve ser redesenhada profundamente.\
\
O resultado final precisa ter identidade própria e não pode parecer o Nuvio atual com componentes reposicionados.\
\
Não use mocks permanentes.\
\
Não deixe botões sem implementação.\
\
Não marque uma funcionalidade como pronta se ela apenas possui UI.\
\
Cada feature precisa possuir comportamento real, persistência quando aplicável, loading state, empty state, error state, teclado ou D-pad adequado, acessibilidade, testes e validação visual.\
\
Crie testes de regressão para login, sync, perfis, biblioteca, progresso, histórico, addons, streams, legendas e reprodução.\
\
Execute builds reais de Windows e Android TV.\
\
Valide também que as alterações compartilhadas não destroem a portabilidade Linux/macOS existente no Desktop.\
\
Faça revisão visual nas principais resoluções Desktop e em 720p, 1080p e 4K na TV.\
\
Valide overscan, clipping, tipografia, focus, cards, player, dialogs, loading states e Reduced Motion.\
\
Trate segurança como requisito do produto.\
\
Audite addons, metadata, URLs, downloads, arquivos de avatar, path traversal, SSRF, tokens, logs, remote pairing, deep links e acesso ao filesystem.\
\
Nunca envie tokens, passwords, cookies ou headers sensíveis para logs.\
\
Não execute comandos do sistema diretamente a partir de dados provenientes de addons.\
\
Telemetria externa deve permanecer desativada por padrão.\
\
Não dependa de API paga, IA cloud ou serviços comerciais para funcionalidades essenciais.\
\
Priorize implementações open source, locais e gratuitas.\
\
Continue trabalhando milestone por milestone até que o escopo definido esteja realmente entregue.\
\
Não pare depois de auditoria.\
\
Não pare depois do design system.\
\
Não pare depois de uma Home nova.\
\
Não pare depois do player.\
\
Não pare porque uma fase compilou.\
\
Após concluir uma fase, execute testes e builds, corrija regressões, registre o que foi entregue e avance para a próxima fase.\
\
Só interrompa a execução antes do escopo completo se existir um bloqueio externo real que não possa ser resolvido através do código disponível, como ausência inevitável de credencial, dispositivo físico obrigatório, limitação de serviço externo ou decisão que realmente exija minha intervenção.\
\
Nesse caso, documente claramente o bloqueio, deixe todo o restante executável concluído e continue nas partes não bloqueadas.\
\
O objetivo final não é entregar um protótipo.\
\
Não é entregar apenas um MVP visual.\
\
Não é entregar uma prova de conceito.\
\
Não é entregar uma lista de ideias.\
\
É entregar um produto utilizável e profundamente desenvolvido sobre os clientes existentes do Nuvio.\
\
No final, preciso conseguir abrir o programa e perceber imediatamente que a experiência inteira foi transformada: Home, perfis, cards, previews, detalhes, player, timeline, thumbnails das cenas, filmstrip, Scene Info, addons, busca, biblioteca, downloads, configurações, TV, EPG e Android TV.\
\
Tecnicamente ele continua aproveitando o ecossistema Nuvio.\
\
Visualmente e na experiência de uso, precisa parecer uma geração muito mais avançada do produto.\
\
Não busque equivalência com o Nuvio atual.\
\
Use o Nuvio atual como baseline que precisa ser superado.