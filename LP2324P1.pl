% IST1109685 Joao Sergio Abreu Viegas
:- use_module(library(clpfd)). % para poder usar transpose/2
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- ["puzzlesAcampar.pl"]. % Ficheiro dado. No Mooshak tera mais puzzles.
% Atencao: nao deves copiar nunca os puzzles para o teu ficheiro de codigo
% Segue-se o codigo

/*--------------------------------------------------------------------------------
vizinhanca/3
vizinhanca((L, C), Vizinhanca) -> recebe as coordenadas (L,C) e retorna Vizinhanca,
uma lista de elemento unicos ordenados de cima para baixo e da esquerda para a direita, 
com as coordenadas das posicoes imediatamente acima, a esquerda, a direita e abaixo de (L, C).
----------------------------------------------------------------------------------*/

vizinhanca((Linha, Coluna), Vizinhanca) :-

    L1 is Linha - 1, % Cima
    C1 is Coluna - 1, % Esquerda
    C2 is Coluna + 1, % Direita
    L2 is Linha + 1, % Baixo
    Vizinhanca = [(L1, Coluna),(Linha, C1),(Linha, C2),(L2, Coluna)].

/*--------------------------------------------------------------------------------
vizinhancaAlargada/2
vizinhancaAlargada((L, C), VizinhancaAlargada) -> recebe as coordenadas (L,C) e retorna 
VizinhancaAlargada, uma lista de elementos unicos ordenados de cima para baixo e da esquerda para a direita
com todas as coordenadas adjacentes a (L, C).
----------------------------------------------------------------------------------*/

vizinhancaAlargada((L, C), VizinhancaAlargada) :-

    vizinhanca((L, C), [(L1, C), (L, C1), (L, C2), (L2, C)]), % Obtem a Vizinhanca
    arg(2,vizinhanca((L, C), [(L1, C), (L, C1), (L, C2), (L2, C)]), Vizinhanca), % Extrai-se a Vizinhanca

    Diagonais = [(L1, C1), (L1, C2), (L2, C1), (L2, C2)], % Obtem as diagonais de (L,C)
    append(Vizinhanca, Diagonais, Resultado), % Junta as listas
    sort(Resultado, VizinhancaAlargada). % Ordena as celulas

/*--------------------------------------------------------------------------------
todasCelulas/2
todasCelulas(Tabuleiro, TodasCelulas) -> recebe um tabuleiro Tabuleiro (lista de listas) 
e devolve TodasCelulas, uma lista de elementos unicos ordenada de cima para baixo e da 
esquerda para a direita, com todas as coordenadas das celulas do tabuleiro.
----------------------------------------------------------------------------------*/

todasCelulas([], []).
todasCelulas(Tabuleiro, TodasCelulas) :-

    findall((L, C),
        (nth1(L, Tabuleiro, Linhas), % Obtem todos os indices das linhas
        nth1(C, Linhas, _)), % E das colunas do tabuleiro
        TodasCelulas).

/*--------------------------------------------------------------------------------
todasCelulas/3
todasCelulas(Tabuleiro, TodasCelulas, Objeto) -> recebe um tabuleiro Tabuleiro e 
devolve TodasCelulas, uma lista de elementos unicos ordenada de cima para baixo e da 
esquerda para a direita, com todas as coordenadas das celulas do tabuleiro em que existe um objeto 
do tipo Objeto (tenda (t), relva (r), arvore (a) ou ainda uma variavel, para os espacos vazios).
----------------------------------------------------------------------------------*/

todasCelulas([], [], _).
todasCelulas(Tabuleiro, TodasCelulas, Objeto) :-

    var(Objeto), ! , % Se estivermos a procura de espacos vazios 
    findall((L, C),
        (nth1(L, Tabuleiro, Linhas),
        nth1(C, Linhas, Elemento),
        var(Elemento)), % Procura os que sao variaveis
        TodasCelulas).

todasCelulas(Tabuleiro, TodasCelulas, Objeto) :-

    findall((L, C),
        (nth1(L, Tabuleiro, Linhas),
        nth1(C, Linhas, Elemento),
        Elemento == Objeto), % Senao, procura os que sao iguais ao Objeto
        TodasCelulas).

/*--------------------------------------------------------------------------------
aux_obtemCelula/3
aux_obtemCelula(Tabuleiro, (L,C), Objeto) -> e verdade se Tabuleiro for um tabuleiro que
possui nas coordenadas (L, C) um dos objetos do tipo Objeto, devolvendo esse objeto.
----------------------------------------------------------------------------------*/

aux_obtemCelula(Tabuleiro, (L, C), []) :-

    length(Tabuleiro, Tamanho),
    (\+ between(1, Tamanho, L); % Se estiver fora do tabuleiro, devolve vazio
    \+ between(1, Tamanho, C)), !.

aux_obtemCelula(Tabuleiro, (L, C), Objeto) :-

    nth1(L, Tabuleiro, Linhas), % Obtem a linha
    nth1(C, Linhas, Objeto). % Obtem o elemento

/*--------------------------------------------------------------------------------
celculaVazia/2
celulaVazia(Tabuleiro, (L, C)) -> recebe um tabuleiro Tabuleiro e devolve false se nao tiver
relva nas coordenadas (L, C), de resto, devolve o proprio tabuleiro.
----------------------------------------------------------------------------------*/

celulaVazia(T, (L, C)) :- % Se estiver fora do tabuleiro

    length(T, Tamanho), % Se nao estiver entre o 0 e o tamanho do tabuleiro
    (\+ between(1, Tamanho, L); 
    \+ between(1, Tamanho, C)), !.
    
celulaVazia(T, (L, C)) :- % Se estiver dentro do tabuleiro e for uma variavel

    aux_obtemCelula(T, (L,C), Objeto), % Obtem a variavel na celula
    var(Objeto), !.

celulaVazia(T, (L, C)) :-

    aux_obtemCelula(T, (L, C), Objeto), % Obtem o elemento na celula
    Objeto == r. % Verifica-se se e relva

/*--------------------------------------------------------------------------------
aux_contaObjetos/3
aux_contaObjetos(Lista, Contagem, Objeto) -> recebe uma lista Lista e um objeto 
do tipo Objeto e retorna Contagem, sendo esse o numero de vezes que Objeto aparece na lista.
----------------------------------------------------------------------------------*/

aux_contaObjetos([], 0, _).
aux_contaObjetos(Lista, Contagem, Objeto) :-

        var(Objeto), ! , % Se estivermos a contar as variaveis
        findall(E,
            (member(E, Lista),
            var(E)), % Coloca-as todas as aparicoes numa lista
            Apar),
        length(Apar, Contagem). % Retorna o comprimento da lista

aux_contaObjetos(Lista, Contagem, Objeto) :-

        findall(E, % Se for um objeto, utiliza o mesmo processo
            (member(E, Lista),
            E == Objeto), % Desta vez verificando se o elemento e igual ao objeto
            Apar),
        length(Apar, Contagem).

/*--------------------------------------------------------------------------------
calculaObjetosTabuleiro/4
calculaObjectosTabuleiro(Tabuleiro, ContagemLinhas, ContagemColunas, Objeto) -> 
recebe um tabuleiro Tabuleiro, e um objeto do tipo Objeto,devolvendo as listas 
ContagemLinhas e ContagemColunas, essas listas contem o numero de vezes que o Objeto 
aparece nas linhas e colunas do tabuleiro, respetivamente.
----------------------------------------------------------------------------------*/

calculaObjectosTabuleiro([],[],[],_).
calculaObjectosTabuleiro(Tabuleiro, ContagemLinhas, ContagemColunas, Objeto) :-

    findall(Num, % Encontra todos os numeros de aparicoes nas linhas
        (nth1(I, Tabuleiro, Linha),
        aux_contaObjetos(Linha, Num, Objeto)),
        ContagemLinhas),

    transpose(Tabuleiro, Transposto), % Faz o tabuleiro transposto
    findall(Num,
        (nth1(I, Transposto, Coluna),
        aux_contaObjetos(Coluna, Num, Objeto)),
        ContagemColunas). % Encontra todos os numeros de aparicoes nas colunas

/*--------------------------------------------------------------------------------
insereObjectoCelula/3
insereObjectoCelula(Tabuleiro, TendaOuRelva, (L, C)) -> recebe um tabuleiro Tabuleiro 
e sas coordenadas (L, C), se insere o objeto TendaOuRelva.
----------------------------------------------------------------------------------*/  

insereObjectoCelula(Tabuleiro, _, (L, C)) :- % Verifica-se se e possivel substituir

    aux_obtemCelula(Tabuleiro, (L, C), Objeto), % Obtem o que ocupa a celula
    nonvar(Objeto), !. % Se nao for variavel, nao substitui

insereObjectoCelula(Tabuleiro, TendaOuRelva, (L, C)) :-

    nth1(L, Tabuleiro, Linha), % Obtem a linha que se quer substituir
    nth1(C, Linha, TendaOuRelva). % Substitui-se 

/*--------------------------------------------------------------------------------
insereObjectoEntrePosicoes/4
insereObjectoEntrePosicoes(Tabuleiro, TendaOuRelva, (L, C1), (L, C2)) -> recebe um 
tabuleiro Tabuleiro e as coordenadas (L, C1) e (L, C2) da Linha L, entre as quais 
(inclusive) se insere o objeto TendaOuRelva.
----------------------------------------------------------------------------------*/

insereObjectoEntrePosicoes(Tabuleiro, TendaOuRelva, (L, C1), (L, C2)) :-

    findall((L, C), % Cria-se uma lista com todos as celulas onde queremos colocar
        (between(C1, C2, C)),
        Celulas),

    maplist(insereObjectoCelula(Tabuleiro, TendaOuRelva), Celulas).

/*--------------------------------------------------------------------------------
relva/1
relva(Puzzle) -> recebe o puzzle Puzzle, e devolve-o alterado, com relva em todas 
as linhas/colunas cujo numero de tendas ja atingiu o numero de tendas  possivel 
nessas linhas/colunas.
----------------------------------------------------------------------------------*/

relva((Tabuleiro, N_Linhas, N_Colunas)) :-

    calculaObjectosTabuleiro(Tabuleiro, C_Linhas, C_Colunas, t), % Obtem a lista como numero de tendas
    todasCelulas(Tabuleiro, Todas),

    findall((L, C),
        (nth1(L, C_Linhas, Ntendas), % Se o numero de tendas postas for igual a contagem
        nth1(L, N_Linhas, Ntendas),
        member((L, C), Todas)),
        Sub_Linhas_Celulas), % Obtem uma lista com todas as celulas dessa linha

    maplist(insereObjectoCelula(Tabuleiro, r), Sub_Linhas_Celulas), % Preenche-se com relva

    transpose(Tabuleiro, Transposto), % Mesmo raciocinio oara as colunas

    findall((C, L),
        (nth1(C, C_Colunas, Ntendas),
        nth1(C, N_Colunas, Ntendas),
        member((C, L), Todas)),
        Sub_Colunas_Celulas),

    maplist(insereObjectoCelula(Transposto, r), Sub_Colunas_Celulas).

/*--------------------------------------------------------------------------------
inacessiveis/1
inacessiveis(Tabuleiro) -> recebe o puzzle Puzzle e devolve-o alterado,
com relva em todas as celulas inacessiveis, (onde ja nao e possivel colocar tendas).
----------------------------------------------------------------------------------*/

inacessiveis(Tabuleiro) :-

    todasCelulas(Tabuleiro, Todas),
    todasCelulas(Tabuleiro, Arvores, a), % Obtem todas as arvores

    findall(Coordenada, % Obtem todas as vizinhancas das arvores
        (member(Celula, Arvores),
        vizinhanca(Celula, Vizinhanca),
        member(Coordenada, Vizinhanca),
        member(Coordenada, Todas),
        aux_obtemCelula(Tabuleiro, Coordenada, Objeto),
        var(Objeto)), % Que estao vazias
        Todas_vizinhanca),

    flatten(Todas_vizinhanca, Todas_vizinhanca_), % Junta todas numa lista
    sort(Todas_vizinhanca_, Todas_vizinhanca_ord), % Ordena e elimina-se duplicados

    findall(Celula,
        (member(Celula, Todas),
        \+ member(Celula, Todas_vizinhanca_ord),
        aux_obtemCelula(Tabuleiro, Celula, Objeto),
        var(Objeto)),
        Preencher), % Obtem todas as celulas que nao sao vizinhanca de nenhuma arvore

    maplist(insereObjectoCelula(Tabuleiro, r), Preencher). % Coloca-se relva nas celulas obtidas

/*--------------------------------------------------------------------------------
aproveita/1
aproveita(Puzzle) -> recebe um puzzle Puzzle e devolve-o alterado, com tendas em 
todas as linhas e colunas as quais faltavam colocar X tendas e que tinham exatamente 
X posicoes livres.
----------------------------------------------------------------------------------*/

aproveita((Tabuleiro, N_Linhas, N_Colunas)) :-

    todasCelulas(Tabuleiro, Todas),

    findall((L, C),
        (nth1(L, N_Linhas, Tendas), % Numero de tendas total
        nth1(L, Tabuleiro, Linha),
        aux_contaObjetos(Linha, Ntendas, t), % Numero de tendas postas
        aux_contaObjetos(Linha, Nvazio, _), % Numero de espacos vazios
        Tendas =\= 0,
        Tendas is Ntendas + Nvazio,
        member((L, C), Todas)),
        T_Linhas_Celulas),

    maplist(insereObjectoCelula(Tabuleiro, t), T_Linhas_Celulas), % Colocam-se as tendas

    transpose(Tabuleiro, Transposto), % Mesmo raciocinio para as colunas

    findall((C, L),
        (nth1(C, N_Colunas, Tendas),
        nth1(C, Transposto, Coluna),
        aux_contaObjetos(Coluna, Ntendas, t),
        aux_contaObjetos(Coluna, Nvazio, _),
        Tendas =\= 0,
        Tendas is Ntendas + Nvazio,
        member((C, L), Todas)),
        T_Colunas_Celulas),

    maplist(insereObjectoCelula(Transposto, t), T_Colunas_Celulas).

/*--------------------------------------------------------------------------------
limpaVizinhancas/1
limpaVizinhancas(Puzzle) -> recebe um puzzle Puzzle e devolve-o alterado,
com relva em todas as posicoes a volta de uma tenda.
----------------------------------------------------------------------------------*/

limpaVizinhancas((Tabuleiro, _, _)) :-
    
    todasCelulas(Tabuleiro, Tendas, t),
    todasCelulas(Tabuleiro, Todas),

    findall(Coordenada, % Obtem todas as vizinhancas alargadas das tendas
        (member(Celula, Tendas),
        vizinhancaAlargada(Celula, Vizinhanca),
        member(Coordenada, Vizinhanca),
        member(Coordenada, Todas),
        aux_obtemCelula(Tabuleiro, Coordenada, Objeto),
        var(Objeto)),
        Todas_vizinhanca_al),

    maplist(insereObjectoCelula(Tabuleiro, r), Todas_vizinhanca_al). % Preecnhe-as

/*--------------------------------------------------------------------------------
unicaHipotese/1
unicaHipotese(Puzzle) -> recebe um puzzle Puzzle e devolve-o alterado,
onde todas as arvores que tinham apenas uma posicao livre na sua vizinhanca que lhes
permitia ficar ligadas a uma tenda, tem agora uma tenda nessa posicao.
----------------------------------------------------------------------------------*/   

unicaHipotese((Tabuleiro, _, _)) :-

    todasCelulas(Tabuleiro, Arvores, a),

    findall(Vizinhanca, % Obtem todas as vizinhancas das arvores
        (member(Celula, Arvores),
        vizinhanca(Celula, Vizinhanca),
        maplist(aux_obtemCelula(Tabuleiro), Vizinhanca, Objetos), % Obtem os objetos nas celulas
        aux_contaObjetos(Objetos, 1, _), % Apenas as vizinhancas que tem 1 celula disponivel
        aux_contaObjetos(Objetos, 0, t)), % Apenas as vizinhancas que ainda nao tem tenda
        Hipotese),

    flatten(Hipotese, Hipotese_),
    sort(Hipotese_, Hipotese_ord),

    maplist(insereObjectoCelula(Tabuleiro, t), Hipotese_ord).

/*--------------------------------------------------------------------------------
valida/2
valida(LArv, LTen) -> e verdade se LArv e LTen sao listas com todas as coordenadas em
que existem, respectivamente, arvores e tendas, e e avaliado para verdade se for possivel
estabelecer uma relacao em que existe uma e uma unica tenda para cada arvore nas suas
vizinhancas.
----------------------------------------------------------------------------------*/ 

valida(LArv, LTen) :- 

    findall(Celulas, % Verifica se ha repetidos
        (member(Celulas, LArv),
        member(Celulas, LTen)),
        Repetidos),

    length(Repetidos, 0), % Se nao houver repetidos

    findall(Viz, % Obtem todas as vizinhancas das arvores
        (member(Celula, LArv),
        vizinhanca(Celula, Viz)),
        Vizinhanca),

    % Apenas mantem as celulas da vizinhanca que sao tendas
    maplist(include(aux_member(LTen)), Vizinhanca, VizTendas),

    aux_valida(LArv, VizTendas, []).

aux_member(Lista, Elemento) :- % Para utilizar no include/3

    member(Elemento, Lista). % Troca os elementos do member/2

aux_valida([], [], _).
aux_valida([_|ResArv], [PriViz|ResViz], Associadas) :-

    member(Tenda, PriViz), % Retira um elemento qualquer
    \+ member(Tenda, Associadas), % Se a tenda ainda nao estiver associada a nenhuma arvore
    append([Tenda], Associadas, Associadas1), % Adiciona a lista de ja associadas
    aux_valida(ResArv, ResViz, Associadas1).

/*--------------------------------------------------------------------------------
resolve/1
resolve(Puzzle) -> recebe um puzzle Puzzle e devolve-o alterado, ficando resolvido.
----------------------------------------------------------------------------------*/ 

resolve((Tabuleiro, N_Linhas, N_Colunas)) :-

    aux_estrategias((Tabuleiro, N_Linhas, N_Colunas)), % Implementa as estrategias
    resolve_repetir((Tabuleiro, N_Linhas, N_Colunas)). % Faz recursao com varias tentativas

resolve_repetir((Tabuleiro, N_Linhas, N_Colunas)) :-

    aux_resolve_valida((Tabuleiro, N_Linhas, N_Colunas)). % Primeiro verifica se ja ficou valido

resolve_repetir((Tabuleiro, N_Linhas, N_Colunas)) :-

    aux_resolve_tentativa((Tabuleiro, N_Linhas, N_Colunas)). % Senao, faz uma tentativa
    
aux_estrategias(Puzzle) :-

    inacessiveis(Puzzle), % Primeiro preenche as celulas inacessiveis
    relva(Puzzle), % Tenta fazer o relva
    unicaHipotese(Puzzle), % Verifica se surge alguma unica hipotese
    aproveita(Puzzle), % Verifica se surge alguma linha/coluna onde por tendas
    limpaVizinhancas(Puzzle), % Preenche de relva a volta das tendas
    relva(Puzzle). % Tenta novamente o relva

aux_resolve_valida((Tabuleiro, _, _)) :-
    
    todasCelulas(Tabuleiro, LArv, a),
    todasCelulas(Tabuleiro, LTen, t),
    valida(LArv, LTen), !. % Se estiver ja um tabuleiro valido, termina

aux_resolve_tentativa((Tabuleiro, N_Linhas, N_Colunas)) :-

    todasCelulas(Tabuleiro, Hipoteses, _), % Ve as celulas que faltam preencher
    member(Tentativa, Hipoteses), % Escolhe uma delas para colocar uma
    insereObjectoCelula(Tabuleiro, t, Tentativa),

    resolve((Tabuleiro, N_Linhas, N_Colunas)). % Experimenta resolver essa hipotese