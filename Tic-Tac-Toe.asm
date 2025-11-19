TITLE Jogo da Velha
.MODEL SMALL
.STACK 100H

;-------------- DECLARAÇÃO DE MACROS ------------
TESTA_CASA_IA MACRO CASA      ; Verifica conteúdo da casa para IA
      LOCAL VALOR_X
      LOCAL VALOR_O
      LOCAL SAI
      CMP CASA, 'X'           ; É X?
      JE VALOR_X
      CMP CASA, 'O'           ; É O?
      JE VALOR_O
      JMP SAI
      VALOR_X:
      INC DL                  ; Incrementa contador de X
      JMP SAI
      VALOR_O:
      INC DH                  ; Incrementa contador de O
      SAI:
      ENDM

;-------------- DECLARAÇÃO DE DADOS ------------
.DATA
    ; TELA INICIAL
    LinhaSeparadora DB "    +-------------------------------------+", 10, 13, '$'
    Titulojogo      DB "    |      BEM-VINDO AO JOGO DA VELHA     |", 10, 13, '$'
    Opcao1v1        DB "    |   [1] - Jogador X Jogador           |", 10, 13, '$'
    Opcap1vIA       DB "    |   [2] - Jogador X IA                |", 10, 13, '$'
    Opcaosaida      DB "    |   [0] - Sair do Jogo                |", 10, 13, '$'
    LinhaVazia      DB "    |                                     |", 10, 13, '$'

    ; TABULEIRO E ESTADO DO JOGO
    MATRIZ         DB 31h, 32h, 33h    ; Posições 1-9 como caracteres ASCII
                   DB 34h, 35h, 36h
                   DB 37h, 38h, 39h
    JOGADOR_ATUAL  DB 'X'              ; Jogador atual (X ou O)
    JOGADAS_FEITAS DB 0                ; Contador de jogadas

    ; MENSAGENS DO JOGO
    TURNO          DB 10, 13, "Agora eh o turno do jogador ", 0, 10, 13, 'Escolha uma casa!', 10, 13,'$'
    NUMEROINVALIDO DB 10, 13, "Este numero eh invaladio. Por favor escolha outra.", 10, 13, '$'
    CASAOCUPADA    DB 10, 13, "Esta casa ja esta ocupada. Por favor escolha outra.", 10, 13, '$'
    Vitoria        DB "Vitoria do jogador ", 0, '!', 10, 13, '$'
    Empate         DB "Velha! Boa sorte na proxima!$2"
    CLIQUE         DB "CLIQUE ENTER PARA VOLTAR PARA TELA INICIAL...$'

;-------------- PROGRAMA PRINCIPAL ------------
.CODE
MAIN PROC 
    MOV AX, @DATA        ; Inicializa segmento de dados
    MOV DS, AX

    ReiniciaJogo:
    XOR AX, AX           ; Limpa registradores
    XOR DX, DX
    XOR BX, BX
    XOR CX, CX
    
    CALL IMPRIMETELA     ; Mostra menu inicial

    MOV AH, 1            ; Lê escolha do usuário
    INT 21H
    AND AL, 0FH          ; Converte ASCII para número
    CMP AL, 0            ; Sair?
    JE FimJogo
    CMP AL, 1            ; PvP?
    JE VersusPvP
    CMP AL, 2            ; Vs IA?
    JE VersusIA

    JMP ReiniciaJogo     ; Opção inválida, volta ao menu
    
    VersusPvP:
    CALL JOGOPVP         ; Inicia PvP
    JMP ReiniciaJogo     ; Volta ao menu
    
    VersusIA:
    CALL JOGOPVIA        ; Inicia PvIA
    JMP ReiniciaJogo     ; Volta ao menu

    FimJogo:
    MOV AH, 4CH          ; Termina programa
    INT 21H
MAIN ENDP

;-------------- PROCEDIMENTOS DE INTERFACE ------------
IMPRIMETELA PROC
    ; Mostra tela inicial
    PUSH AX              ; Salva registradores
    PUSH BX 
    PUSH CX
    PUSH DX

    ; Limpa a tela e configura modo de vídeo
    MOV AH, 0            ; Modo vídeo
    MOV AL, 3            ; Modo texto 80x25
    INT 10H

    ; Configura cor VERDE
    MOV AH, 0BH          
    MOV BH, 0            
    MOV BL, 2            ; Cor VERDE
    INT 10H
   
    ; IMPRIME TELA INICIAL
    MOV AH, 9            
    
    LEA DX, LinhaSeparadora  ; Topo
    INT 21H
    LEA DX, LinhaVazia       ; Linha vazia
    INT 21H
    LEA DX, Titulojogo       ; Título
    INT 21H
    LEA DX, LinhaVazia       ; Linha vazia
    INT 21H
    LEA DX, LinhaSeparadora  ; Separador
    INT 21H
    LEA DX, LinhaVazia       ; Linha vazia
    INT 21H
    LEA DX, Opcao1v1         ; Opção 1
    INT 21H
    LEA DX, LinhaSeparadora  ; Separador
    INT 21H
    LEA DX, LinhaVazia       ; Linha vazia
    INT 21H
    LEA DX, Opcap1vIA        ; Opção 2
    INT 21H
    LEA DX, LinhaSeparadora  ; Separador
    INT 21H
    LEA DX, LinhaVazia       ; Linha vazia
    INT 21H
    LEA DX, Opcaosaida       ; Opção 0
    INT 21H
    LEA DX, LinhaSeparadora  ; Rodapé
    INT 21H

    POP DX               ; Restaura registradores
    POP CX
    POP BX
    POP AX
    RET                  ; Retorna
IMPRIMETELA ENDP

IMPRIMETABULEIRO PROC
    ; Mostra tabuleiro atual
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV AH, 0             ; Modo vídeo
    MOV AL, 3             ; Modo texto 80x25
    INT 10H

    ; Configura cor VERDE para o tabuleiro
    MOV AH, 0BH           
    MOV BH, 0             
    MOV BL, 2             ; Cor VERDE
    INT 10H
    
    MOV AH, 2             ; Posiciona cursor
    XOR CX,CX
    XOR BX,BX
    
    IMPRIMELINHA:
    OR CX, 19             ; Centraliza horizontalmente
    MOV DL, ' '
    
    ESPACO:               ; Espaçamento
    INT 21H
    LOOP ESPACO
    
    OR CX, 3              ; 3 colunas por linha
    XOR SI,SI
    IMPRIMECOLUNA:
    MOV DL, MATRIZ[BX][SI] ; Imprime conteúdo da casa
    INT 21H
    CMP SI, 2             ; Última coluna?
    JE PROXIMALINHA
    MOV DL, ' '           ; Separador
    INT 21H
    MOV DL, '|'
    INT 21H
    MOV DL, ' '
    INT 21H
    INC SI
    LOOP IMPRIMECOLUNA
    
    PROXIMALINHA:         ; Nova linha
    MOV DL, 10
    INT 21H
    ADD BX, 3             ; Próxima linha da matriz
    CMP BX, 6
    JBE IMPRIMELINHA
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET                   ; Retorna
IMPRIMETABULEIRO ENDP

DECLARACAORESULTADO PROC
    ; Mostra resultado final
    CALL IMPRIMETABULEIRO ; Mostra tabuleiro final

    CMP CL, 2             ; Foi empate?
    JE EMPATOU 

    MOV AH, 9             ; Vitória - monta mensagem
    MOV AL, JOGADOR_ATUAL
    MOV BX, 19
    MOV [Vitoria+BX], AL  ; Insere símbolo do vencedor
    LEA DX, Vitoria
    INT 21H
    JMP FINALIZAJOGO

    EMPATOU:              ; Empate
    MOV AH, 9
    LEA DX, Empate
    INT 21H

    FINALIZAJOGO:
    RET                   ; Retorna
DECLARACAORESULTADO ENDP

;-------------- PROCEDIMENTOS DO JOGO PVP ------------
JOGOPVP PROC
    ; Modo jogador vs jogador
    PUSH AX              ; Salva registradores
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    CICLOJOGOPVP:
    CALL IMPRIMETABULEIRO ; Mostra tabuleiro
    
    MOV AL, JOGADOR_ATUAL ; Atualiza mensagem de turno
    MOV BX, 30
    MOV [TURNO+BX], AL
    MOV AH, 9 
    LEA DX, TURNO
    INT 21h

    MOV AH, 1            ; Lê jogada
    INT 21H

    CMP AL, '9'          ; Verifica se número é válido
    JA INVALIDOPVP
    CMP AL, '1'
    JB INVALIDOPVP

    CALL CHECACASA       ; Verifica se casa está livre

    TEST CL, CL          ; CL=0 → casa ocupada
    JZ CASAINVALIDAPVP

    CALL ALTERAMATRIZ    ; Atualiza matriz
    
    CALL CHECASITUACAOJOGO ; Verifica estado do jogo
    
    TEST CL, CL          ; CL=0 → jogo continua
    JZ CONTINUAJOGOPVP
    
    CALL DECLARACAORESULTADO ; Mostra resultado
    JMP FIMDOPVP         ; Termina jogo

    CONTINUAJOGOPVP:
    CALL ALTERAJOGADOR   ; Troca jogador
    JMP CICLOJOGOPVP     ; Próximo turno
    
    FIMDOPVP:
    MOV AH, 2            ; Line feed
    MOV DL, 10
    INT 21H

    MOV AH, 9            ; Mensagem "Clique Enter"
    LEA DX, CLIQUE
    INT 21H

    MOV AH, 1            ; Espera Enter
    INT 21H

    CALL RESETAMATRIZ    ; Prepara novo jogo

    POP SI               ; Restaura registradores
    POP DX
    POP CX
    POP BX
    POP AX
    RET                  ; Retorna

    INVALIDOPVP:         ; Número inválido
    MOV AH, 9
    LEA DX, NUMEROINVALIDO
    INT 21H
    MOV AH, 1
    INT 21H
    JMP CICLOJOGOPVP     ; Volta ao ciclo

    CASAINVALIDAPVP:     ; Casa ocupada
    MOV AH, 9
    LEA DX, CASAOCUPADA
    INT 21H
    MOV AH, 1
    INT 21H
    JMP CICLOJOGOPVP     ; Volta ao ciclo
JOGOPVP ENDP

;-------------- PROCEDIMENTOS DO JOGO VS IA ------------
JOGOPVIA PROC
    ; Modo jogador vs IA
    PUSH AX              ; Salva registradores
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    CICLOJOGOPVIA:
    CALL IMPRIMETABULEIRO ; Mostra tabuleiro

    MOV AL, JOGADOR_ATUAL ; Atualiza mensagem de turno
    MOV BX, 30
    MOV [TURNO+BX],AL
    MOV AH, 9
    LEA DX, TURNO
    INT 21H
    
    MOV AH, 1            ; Lê jogada do jogador
    INT 21H

    CMP AL, '9'          ; Verifica se número é válido
    JA INVALIDOPVIA
    CMP AL, '1'
    JB INVALIDOPVIA

    CALL CHECACASA       ; Verifica se casa está livre

    TEST CL, CL          ; CL=0 → casa ocupada
    JZ CASAINVALIDAPVIA

    CALL ALTERAMATRIZ    ; Atualiza matriz
    
    CALL CHECASITUACAOJOGO ; Verifica estado do jogo

    TEST CL,CL           ; CL=0 → jogo continua
    JZ CONTINUAJOGOPVIA1
    CALL DECLARACAORESULTADO ; Mostra resultado
    JMP FIMDOPVIA

    CONTINUAJOGOPVIA1:
    CALL ALTERAJOGADOR   ; Troca para IA
    
    IAESCOLHE_OUTRA:
    CALL ESCOLHADAIA     ; IA decide jogada

    CALL CHECACASA       ; Verifica se casa está livre

    TEST CL, CL          ; CL=0 → casa ocupada
    JZ IAESCOLHE_OUTRA   ; IA tenta outra

    CALL ALTERAMATRIZ    ; Atualiza matriz com jogada da IA

    CALL CHECASITUACAOJOGO ; Verifica estado do jogo

    TEST CL, CL          ; CL=0 → jogo continua
    JZ CONTINUAJOGOPVIA2
    CALL DECLARACAORESULTADO ; Mostra resultado
    JMP FIMDOPVIA
    
    CONTINUAJOGOPVIA2:
    CALL ALTERAJOGADOR   ; Troca para jogador
    JMP CICLOJOGOPVIA    ; Próximo turno

    FIMDOPVIA:
    MOV AH, 2            ; Line feed
    MOV DL, 10
    INT 21H

    MOV AH, 9            ; Mensagem "Clique Enter"
    LEA DX, CLIQUE
    INT 21H

    MOV AH, 1            ; Espera Enter
    INT 21H

    CALL RESETAMATRIZ    ; Prepara novo jogo

    POP SI               ; Restaura registradores
    POP DX
    POP CX
    POP BX
    POP AX
    RET                  ; Retorna

    INVALIDOPVIA:        ; Número inválido
    MOV AH, 9
    LEA DX, NUMEROINVALIDO
    INT 21H
    MOV AH, 1
    INT 21H
    JMP CICLOJOGOPVIA    ; Volta ao ciclo

    CASAINVALIDAPVIA:    ; Casa ocupada
    MOV AH, 9
    LEA DX, CASAOCUPADA
    INT 21H
    MOV AH, 1
    INT 21H
    JMP CICLOJOGOPVIA    ; Volta ao ciclo
JOGOPVIA ENDP

;-------------- INTELIGÊNCIA ARTIFICIAL ------------
ESCOLHADAIA PROC
    ; IA escolhe jogada
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH SI

    MOV AL, JOGADAS_FEITAS ; Verifica turno atual
    CMP AL, 3
    JAE ESCOLHAPENSADA   ; Se turno ≥ 3, pensa estrategicamente
    JMP ESCOLHAALEATORIA ; Senão, escolhe aleatório

    ESCOLHAPENSADA:
    ; Verifica linhas para vitória/defesa
    XOR BX, BX
    CHECA_PROXIMA_LINHA:
    XOR DX, DX
    MOV CX, 3
    XOR SI, SI
    CHECA_LINHA_ATUAL:
    MOV AL, MATRIZ[BX][SI] ; Obtém conteúdo da casa
    
    TESTA_CASA_IA AL      ; Conta X e O

    INC SI 
    LOOP CHECA_LINHA_ATUAL
    
    CMP DH, 2            ; 2 O? → chance de vitória
    JNE VER_O_LINHA
    JMP DESCOBRIU_LINHA
    
    VER_O_LINHA:
    CMP DL, 2            ; 2 X? → precisa bloquear
    JNE PROXIMA_LINHA
    JMP DESCOBRIU_LINHA
    
    PROXIMA_LINHA:       ; Próxima linha
    ADD BX, 3
    CMP BX, 6
    JBE CHECA_PROXIMA_LINHA
    
    ; Verifica colunas
    XOR SI, SI
    CHECA_PROXIMA_COLUNA:
    XOR DX, DX
    MOV CX, 3
    XOR BX, BX
    CHECA_COLUNA_ATUAL:
    MOV AL, MATRIZ[BX][SI] ; Obtém conteúdo da casa

    TESTA_CASA_IA AL      ; Conta X e O

    ADD BX, 3
    LOOP CHECA_COLUNA_ATUAL

    CMP DH, 2            ; 2 O? → chance de vitória
    JNE VER_O_COLUNA
    JMP DESCOBRIU_COLUNA
    
    VER_O_COLUNA:
    CMP DL, 2            ; 2 X? → precisa bloquear
    JNE PROXIMA_COLUNA
    JMP DESCOBRIU_COLUNA
    
    PROXIMA_COLUNA:      ; Próxima coluna
    INC SI
    CMP SI, 3
    JNZ CHECA_PROXIMA_COLUNA

    ; Verifica diagonal principal
    XOR DX, DX
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
    PRIMEIRA_DIAGONAL:
    MOV AL, MATRIZ[BX][SI] ; Obtém conteúdo da casa
    
    TESTA_CASA_IA AL      ; Conta X e O
    
    ADD BX, 3
    INC SI
    LOOP PRIMEIRA_DIAGONAL
    
    CMP DH, 2            ; 2 O? → chance de vitória
    JNE VER_O_DIAGONAL1
    JMP DESCOBRIU_DIAGONAL1
    
    VER_O_DIAGONAL1:
    CMP DL, 2            ; 2 X? → precisa bloquear
    JNE PROXIMA_DIAGONAL
    JMP DESCOBRIU_DIAGONAL1
    PROXIMA_DIAGONAL:
    
    ; Verifica diagonal secundária
    XOR DX, DX
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
    SEGUNDA_DIAGONAL:
    MOV AL, MATRIZ[BX][SI] ; Obtém conteúdo da casa

    TESTA_CASA_IA AL      ; Conta X e O

    ADD BX, 3
    DEC SI
    LOOP SEGUNDA_DIAGONAL

    CMP DH, 2            ; 2 O? → chance de vitória
    JNE VER_O_DIAGONAL2
    JMP DESCOBRIU_DIAGONAL2
    
    VER_O_DIAGONAL2:
    CMP DL, 2            ; 2 X? → precisa bloquear
    JNE ESCOLHAALEATORIA ; Nenhuma jogada estratégica
    JMP DESCOBRIU_DIAGONAL2
    
    ; Encontrou linha com chance
    DESCOBRIU_LINHA:
    XOR SI, SI
    MOV CX, 3
    CHECA_CASA_LINHA:
    MOV AL, MATRIZ [BX][SI] ; Verifica se casa está vazia
    CMP AL, 39H            ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA       ; Casa encontrada
    INC SI 
    LOOP CHECA_CASA_LINHA 
    JMP PROXIMA_LINHA      ; Nenhuma vazia, continua
    
    ; Encontrou coluna com chance
    DESCOBRIU_COLUNA:
    XOR BX, BX
    MOV CX, 3
    CHECA_CASA_COLUNA:
    MOV AL, MATRIZ[BX][SI] ; Verifica se casa está vazia
    CMP AL, 39h            ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA       ; Casa encontrada
    ADD BX, 3
    LOOP CHECA_CASA_COLUNA
    JMP PROXIMA_COLUNA     ; Nenhuma vazia, continua
    
    ; Encontrou diagonal principal com chance
    DESCOBRIU_DIAGONAL1:
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
    CHECA_CASA_DIAGONAL1:
    MOV AL, MATRIZ[BX][SI] ; Verifica se casa está vazia
    CMP AL, 39h            ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA       ; Casa encontrada
    ADD BX, 3
    INC SI
    LOOP CHECA_CASA_DIAGONAL1
    JMP PROXIMA_DIAGONAL   ; Nenhuma vazia, continua
    
    ; Encontrou diagonal secundária com chance
    DESCOBRIU_DIAGONAL2:
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
    CHECA_CASA_DIAGONAL2:
    MOV AL, MATRIZ[BX][SI] ; Verifica se casa está vazia
    CMP AL, 39h            ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA       ; Casa encontrada
    ADD BX, 3
    DEC SI
    LOOP CHECA_CASA_DIAGONAL2
    JMP ESCOLHAALEATORIA   ; Erro, escolhe aleatório
        
    ESCOLHAFEITA:
    POP SI
    POP BX
    POP CX
    POP DX
    RET                   ; Retorna com jogada em AL

    ESCOLHAALEATORIA:
    MOV AH, 2CH           ; Obtém tempo do sistema
    INT 21h
    
    MOV AL, DL            ; Usa milissegundos
    XOR AH, AH            ; Limpa AH para divisão
    MOV CL, 9
    DIV CL                ; Divide por 9
    INC AH                ; Resto 0-8 → 1-9
    MOV AL, AH
    OR AL, 30H           ; Converte para ASCII
    
    JMP ESCOLHAFEITA     ; Retorna com jogada
ESCOLHADAIA ENDP

;-------------- LÓGICA DO JOGO ------------
ALTERAMATRIZ PROC
    ; Atualiza matriz com jogada
    PUSH AX
    PUSH BX 
    PUSH CX
    PUSH SI
    PUSHF

    XOR BX, BX            ; Inicializa índices
    XOR SI,SI
    MOV CL, JOGADOR_ATUAL ; Símbolo do jogador
    
    AND AL, 0FH           ; Converte ASCII para número
    CMP AL, 9             ; Verifica cada posição possível
    JE POSICAONOVE
    
    CMP AL, 8
    JE POSICAOOITO
    
    CMP AL, 7
    JE POSICAOSETE
    
    CMP AL, 6
    JE POSICAOSEIS
    
    CMP AL, 5
    JE POSICAOCINCO
    
    CMP AL, 4
    JE POSICAOQUATRO
    
    CMP AL, 3
    JE POSICAOTRES
    
    CMP AL, 2
    JE POSICAODOIS
    
    MOV MATRIZ[BX][SI], CL ; Posição 1
    JMP FIMALTERACAO

    POSICAODOIS:          ; Posição 2
    MOV SI, 1
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOTRES:          ; Posição 3
    MOV SI, 2
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOQUATRO:        ; Posição 4
    MOV BX, 3
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOCINCO:         ; Posição 5
    MOV BX, 3
    MOV SI, 1
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOSEIS:          ; Posição 6
    MOV BX, 3
    MOV SI, 2
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOSETE:          ; Posição 7
    MOV BX, 6
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAOOITO:          ; Posição 8
    MOV BX, 6
    MOV SI, 1
    MOV MATRIZ[BX][SI], CL
    JMP FIMALTERACAO

    POSICAONOVE:          ; Posição 9
    MOV BX, 6
    MOV SI, 2
    MOV MATRIZ[BX][SI], CL

    FIMALTERACAO:
    POPF
    POP SI
    POP CX
    POP BX
    POP AX
    RET                   ; Retorna
ALTERAMATRIZ ENDP

ALTERAJOGADOR PROC
    ; Alterna entre X e O
    PUSH AX
    PUSHF
    
    MOV AL, JOGADOR_ATUAL ; Obtém jogador atual
    CMP AL, 'X'           ; É X?
    JE TROCAPROO

    MOV AL, 'X'           ; Troca para X
    MOV JOGADOR_ATUAL, AL
    JMP TROCOU

    TROCAPROO:
    MOV AL, 'O'           ; Troca para O
    MOV JOGADOR_ATUAL, AL

    TROCOU:
    POPF
    POP AX
    RET                   ; Retorna
ALTERAJOGADOR ENDP

CHECACASA PROC
    ; Verifica se casa está livre
    PUSHF
    PUSH AX
    PUSH BX
    PUSH SI

    XOR BX, BX            ; Inicializa índices
    XOR SI,SI
    XOR CX, CX            ; CL=0 → ocupada
    
    AND AL, 0FH           ; Converte ASCII para número
    CMP AL, 9             ; Verifica cada posição
    JNE CONTINUACHECAOITO
    JMP CHECAPOSICAONOVE
    
    CONTINUACHECAOITO:
    CMP AL, 8
    JNE CONTINUACHECASETE 
    JMP CHECAPOSICAOOITO

    CONTINUACHECASETE:
    CMP AL, 7
    JNE CONTINUACHECASEIS
    JMP CHECAPOSICAOSETE

    CONTINUACHECASEIS:
    CMP AL, 6
    JNE CONTINUACHECACINCO
    JMP CHECAPOSICAOSEIS

    CONTINUACHECACINCO:
    CMP AL, 5
    JNE CONTINUACHECAQUATRO
    JMP CHECAPOSICAOCINCO

    CONTINUACHECAQUATRO:
    CMP AL, 4
    JNE CONTINUACHECATRES
    JMP CHECAPOSICAOQUATRO

    CONTINUACHECATRES:
    CMP AL, 3
    JNE CONTINUACHECADOIS
    JMP CHECAPOSICAOTRES

    CONTINUACHECADOIS:
    CMP AL, 2
    JNE CONTINUACHECAUM
    JMP CHECAPOSICAODOIS
    
    CONTINUACHECAUM:      ; Posição 1
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'           ; Tem X?
    JE PULACHECAGEMUM
    CMP AH, 'O'           ; Tem O?
    JE PULACHECAGEMUM
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMUM:
    JMP FIMCHECAGEM

    CHECAPOSICAODOIS:     ; Posição 2
    MOV SI, 1
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMDOIS
    CMP AH, 'O'
    JE PULACHECAGEMDOIS
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMDOIS:
    JMP FIMCHECAGEM

    CHECAPOSICAOTRES:     ; Posição 3
    MOV SI, 2
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMTRES
    CMP AH, 'O'
    JE PULACHECAGEMTRES
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMTRES:
    JMP FIMCHECAGEM

    CHECAPOSICAOQUATRO:   ; Posição 4
    MOV BX, 3
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMQUATRO
    CMP AH, 'O'
    JE PULACHECAGEMQUATRO
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMQUATRO:
    JMP FIMCHECAGEM

    CHECAPOSICAOCINCO:    ; Posição 5
    MOV BX, 3
    MOV SI, 1
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMCINCO
    CMP AH, 'O'
    JE PULACHECAGEMCINCO
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMCINCO:
    JMP FIMCHECAGEM

    CHECAPOSICAOSEIS:     ; Posição 6
    MOV BX, 3
    MOV SI, 2
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMSEIS
    CMP AH, 'O'
    JE PULACHECAGEMSEIS
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMSEIS:
    JMP FIMCHECAGEM

    CHECAPOSICAOSETE:     ; Posição 7
    MOV BX, 6
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMSETE
    CMP AH, 'O'
    JE PULACHECAGEMSETE
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMSETE:
    JMP FIMCHECAGEM

    CHECAPOSICAOOITO:     ; Posição 8
    MOV BX, 6
    MOV SI, 1
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE PULACHECAGEMOITO
    CMP AH, 'O'
    JE PULACHECAGEMOITO
    MOV CL, 1             ; Livre → CL=1
    PULACHECAGEMOITO:
    JMP FIMCHECAGEM

    CHECAPOSICAONOVE:     ; Posição 9
    MOV BX, 6
    MOV SI, 2
    MOV AH, MATRIZ[BX][SI]
    CMP AH, 'X'
    JE FIMCHECAGEM
    CMP AH, 'O'
    JE FIMCHECAGEM
    MOV CL, 1             ; Livre → CL=1
    
    FIMCHECAGEM:
    POP SI
    POP BX
    POP AX
    POPF
    RET                   ; Retorna
CHECACASA ENDP

CHECASITUACAOJOGO PROC
    ; Verifica vitória/empate
    PUSH BX
    PUSH SI
    PUSH AX
    PUSH DX
    
    XOR BX, BX            ; Inicializa índices
    XOR SI, SI
    XOR CL, CL            ; CL=0 → continua
    
    MOV AL, JOGADOR_ATUAL ; Jogador que acabou de jogar

    ; Linha 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL            ; Casa 1 tem o símbolo?
    JNE LINHA2
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL            ; Casa 2 tem o símbolo?
    JNE LINHA2
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL            ; Casa 3 tem o símbolo?
    JNE LINHA2
    MOV CL, 1             ; Linha completa → vitória
    JMP FIMSITUACAO  

    LINHA2:               ; Linha 2
    XOR SI, SI
    MOV BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE LINHA3
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE LINHA3
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE LINHA3
    MOV CL, 1             ; Linha completa → vitória
    JMP FIMSITUACAO

    LINHA3:               ; Linha 3
    XOR SI, SI
    MOV BX, 6
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA1
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA1
    ADD SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA1
    MOV CL, 1             ; Linha completa → vitória
    JMP FIMSITUACAO

    COLUNA1:              ; Coluna 1
    XOR BX, BX
    XOR SI, SI
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA2
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA2
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA2
    MOV CL, 1             ; Coluna completa → vitória
    JMP FIMSITUACAO

    COLUNA2:              ; Coluna 2
    XOR BX, BX
    MOV SI, 1
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA3
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA3
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE COLUNA3
    MOV CL, 1             ; Coluna completa → vitória
    JMP FIMSITUACAO

    COLUNA3:              ; Coluna 3
    XOR BX, BX
    MOV SI, 2
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL1
    MOV CL, 1             ; Coluna completa → vitória
    JMP FIMSITUACAO

    DIAGONAL1:            ; Diagonal \
    XOR BX, BX
    XOR SI, SI
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL2
    ADD SI, 1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL2
    ADD SI, 1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE DIAGONAL2
    MOV CL, 1             ; Diagonal completa → vitória
    JMP FIMSITUACAO

    DIAGONAL2:            ; Diagonal /
    XOR BX, BX 
    MOV SI, 2
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE INCREMENTAJOGADA
    SUB SI, 1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE INCREMENTAJOGADA
    SUB SI, 1
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI]
    CMP AL, DL
    JNE INCREMENTAJOGADA
    MOV CL, 1             ; Diagonal completa → vitória
    JMP FIMSITUACAO

    INCREMENTAJOGADA:     ; Ninguém venceu ainda
    INC JOGADAS_FEITAS    ; Incrementa contador
    MOV AL, JOGADAS_FEITAS
    CMP AL, 9             ; Todas as casas preenchidas?
    JB FIMSITUACAO        ; Menos que 9 → continua
    MOV CL, 2             ; 9 jogadas → empate

    FIMSITUACAO:
    POP DX
    POP AX
    POP SI
    POP BX
    RET                   ; Retorna
CHECASITUACAOJOGO ENDP

;-------------- PROCEDIMENTOS DE UTILIDADE ------------
RESETAMATRIZ PROC
    ; Reinicia tabuleiro para novo jogo
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

    XOR BX, BX            ; Inicializa índices
    XOR SI, SI

    ; Reinicia todas as posições para 1-9
    MOV MATRIZ[BX][SI], 31h ; Posição 1
    ADD SI, 1
    MOV MATRIZ[BX][SI], 32h ; Posição 2
    ADD SI, 1
    MOV MATRIZ[BX][SI], 33h ; Posição 3
    XOR SI, SI
    ADD BX, 3
    MOV MATRIZ[BX][SI], 34h ; Posição 4
    ADD SI, 1
    MOV MATRIZ[BX][SI], 35h ; Posição 5
    ADD SI, 1
    MOV MATRIZ[BX][SI], 36h ; Posição 6
    XOR SI, SI
    ADD BX, 3
    MOV MATRIZ[BX][SI], 37h ; Posição 7
    ADD SI, 1
    MOV MATRIZ[BX][SI], 38h ; Posição 8
    ADD SI, 1
    MOV MATRIZ[BX][SI], 39h ; Posição 9

    MOV JOGADAS_FEITAS, 0  ; Zera contador de jogadas
    MOV JOGADOR_ATUAL, 'X' ; Começa com X

    POP SI
    POP CX
    POP BX
    POP AX
    RET                   ; Retorna
RESETAMATRIZ ENDP

END MAIN
