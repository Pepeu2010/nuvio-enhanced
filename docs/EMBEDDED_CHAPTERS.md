# Capítulos embutidos na timeline Desktop

O incremento `e4ec9bfa7660339e8c533fb1b237ba0c7e5bb9e7` amplia a abstração temporal e o player existentes. O bridge libmpv lê `chapter-list` do arquivo aberto; o controller recebe um snapshot UTF-8, e o adapter projeta capítulos nomeados nos mesmos marcadores da timeline utilizados pelos skips. Não há outro player, pesquisa externa, título inferido da sinopse ou painel fictício.

## Comportamento e limites

- Posições vêm do libmpv e são convertidas para milissegundos. Identidade, título e ordem do arquivo são preservados; títulos vazios não recebem conteúdo inventado.
- Um capítulo sem título ainda limita o intervalo anterior. Posições negativas/duplicadas/inválidas, títulos excessivos e dados incompletos são tratados conservadoramente. O último capítulo só recebe o fim da duração quando o snapshot é completo; corte desconhecido/truncado mantém esse fim desconhecido.
- O leitor limita 512 capítulos, 64 campos por entrada e 1024 bytes por título. O canal JNI é limitado a 1 MiB e decodifica UTF-8 estrito, incluindo Unicode fora do BMP. Dados malformados viram snapshot vazio, sem publicar conteúdo parcial ou logs do payload.
- O controller verifica o source capturado antes/depois da consulta, além de handle e estado de release. A troca de source invalida o snapshot anterior. A prova de uma sequência completa de trocas de episódio/fonte na UI real continua como gate próprio.
- A origem é `embedded-mpv`. Não há confiança fabricada nem fallback para elenco global: os títulos de capítulos não viram afirmações de ator/música/Scene Info. A UI mantém escape por `textContent` e descrição acessível no seek.

Os wrappers equivalentes Linux/macOS estão no código e nos inputs de build, sem afirmar execução dessas plataformas. O caminho Media3 TV, seleção de capítulos com seek pela interface, Scene Info e o restante de 2-B/2-C continuam pendentes.

## Evidência

[Build preservado](telumia-embedded-chapters-r1-build-binding.json): **279 testes selecionados**, 64 arquivos JUnit, zero falhas/erros/skips; MSI de desenvolvimento com árvore limpa antes/depois. [Resultado](telumia-embedded-chapters-results.json), [inspeção](telumia-embedded-chapters-r1-package-inspection.json).

Os [seis casos JNI](telumia-embedded-chapters-native-cases.json) usam o libmpv empacotado, vídeo original gerado e HWND oculto próprio. O novo caso criou Matroska/MJPEG local, leu dois capítulos reais em 0/3000 ms, preservou acentos/aspas/newline/emoji e projetou intervalos 0–3000/3000–6000 no índice temporal. Também extraiu um frame do mesmo arquivo com o worker separado. O caso passou em 1,021 segundo; isso não é benchmark de hardware.

[Renderer](telumia-embedded-chapters-renderer-qa.json): oito execuções, quatro resoluções, dois estados OS de movimento reduzido, 72 pares de política/intensidade, **1.084 verificações**, zero erros JS. Os checks adicionais verificam bounds/rótulo do capítulo, descrição acessível, texto HTML tratado como texto e remoção da descrição/marcadores ao limpar uma fonte. São fixtures controladas da ponte do renderer; não equivalem a interação completa WebView2 com o arquivo reproduzido.

## Distribuição

O código está em `main`, **posterior à release 0.2.2-alpha.1**. O MSI preservado deste incremento ainda usa o nome de versão de desenvolvimento 0.2.2-alpha.1; não foi publicado nem substitui o MSI da release, que permanece ligado ao commit `b39b6ea79d37b7c9eb1383ef68692dd2309d664d`. Uma próxima release terá outra versão e seus próprios gates. A meta integral permanece em execução.
