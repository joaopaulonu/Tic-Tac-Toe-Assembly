TITLE Jogo da Velha
.MODEL SMALL
.STACK 100H

;-------------- DECLARAÇÃO DE MACROS ------------
TESTA_CASA_IA MACRO CASA      ; Macro para contar X/O
      LOCAL VALOR_X
      LOCAL VALOR_O
      LOCAL SAI
      CMP CASA, 'X'           ; Verifica se é X
      JE VALOR_X
      CMP CASA, 'O'           ; Verifica se é O
      JE VALOR_O
      JMP SAI
      VALOR_X:
      INC DL                  ; Incrementa contador X
      JMP SAI
      VALOR_O:
      INC DH                  ; Incrementa contador O
      SAI:
      ENDM

.DATA
    COR_VERDE EQU 2           ; Código cor verde
    MODO_TEXTO EQU 3          ; Modo texto 80x25

    ; Elementos de interface
    LinhaSeparadora DB "    +-------------------------------------+", 10, 13, '$'
    Titulojogo      DB "    |      BEM-VINDO AO JOGO DA VELHA     |", 10, 13, '$'
    Opcao1v1        DB "    |   [1] - Jogador X Jogador           |", 10, 13, '$'
    Opcap1vIA       DB "    |   [2] - Jogador X IA                |", 10, 13, '$'
    Opcaosaida      DB "    |   [0] - Sair do Jogo                |", 10, 13, '$'
    LinhaVazia      DB "    |                                     |", 10, 13, '$'

    ; Estado do jogo
    MATRIZ         DB  '1','2','3','4','5','6','7','8','9' ; Tabuleiro 3x3
    JOGADOR_ATUAL  DB 'X'              ; Jogador inicial
    JOGADAS_FEITAS DB 0                ; Contador para empate

    ; Mensagens do sistema
    TURNO          DB 10, 13, "Agora eh o turno do jogador ", 0, 10, 13, 'Escolha uma casa!', 10, 13,'$'
    NUMEROINVALIDO DB 10, 13, "Numero invalido. Escolha outra.", 10, 13, '$'
    CASAOCUPADA    DB 10, 13, "Casa ocupada. Escolha outra.", 10, 13, '$'
    Vitoria        DB "Vitoria do jogador ", 0, '!', 10, 13, '$'
    Empate         DB "Empate! Boa sorte na proxima!$"
    CLIQUE         DB "Pressione ENTER para voltar ao menu...$'

.CODE
MAIN PROC 
    MOV AX, @DATA        ; Inicializa segmento de dados
    MOV DS, AX

MAIN_LOOP:
    CALL LIMPAR_REGISTRADORES  ; Limpa registradores
    CALL IMPRIMIR_TELA_INICIAL ; Mostra menu
    CALL LER_ESCOLHA_USUARIO   ; Lê opção
    
    CMP AL, 0            ; Verifica saída
    JE FIM_PROGRAMA
    CMP AL, 1            ; Verifica PvP
    JE INICIAR_PVP
    CMP AL, 2            ; Verifica PvIA
    JE INICIAR_PVIA
    JMP MAIN_LOOP        ; Opção inválida

INICIAR_PVP:
    CALL JOGO_PVP        ; Inicia PvP
    JMP MAIN_LOOP

INICIAR_PVIA:
    CALL JOGO_PV_IA      ; Inicia PvIA
    JMP MAIN_LOOP

FIM_PROGRAMA:
    MOV AH, 4CH          ; Termina programa
    INT 21H
MAIN ENDP

; ========== PROCEDIMENTOS DE UTILIDADE ==========
LIMPAR_REGISTRADORES PROC
    XOR AX, AX           ; Zera registradores
    XOR DX, DX  
    XOR BX, BX
    XOR CX, CX
    RET
LIMPAR_REGISTRADORES ENDP

LER_ESCOLHA_USUARIO PROC
    MOV AH, 1            ; Lê tecla
    INT 21H
    AND AL, 0FH          ; Converte ASCII para número
    RET
LER_ESCOLHA_USUARIO ENDP

; ========== PROCEDIMENTOS DE INTERFACE ==========
IMPRIMIR_TELA_INICIAL PROC
    PUSH AX
    PUSH BX 
    PUSH CX
    PUSH DX

    CALL CONFIGURAR_TELA ; Configura tela
    MOV AH, 9            ; Função imprimir string
    
    LEA DX, LinhaSeparadora
    INT 21H
    LEA DX, LinhaVazia
    INT 21H
    LEA DX, Titulojogo
    INT 21H
    LEA DX, LinhaVazia
    INT 21H
    LEA DX, LinhaSeparadora
    INT 21H
    LEA DX, LinhaVazia
    INT 21H
    LEA DX, Opcao1v1
    INT 21H
    LEA DX, LinhaSeparadora
    INT 21H
    LEA DX, LinhaVazia
    INT 21H
    LEA DX, Opcap1vIA
    INT 21H
    LEA DX, LinhaSeparadora
    INT 21H
    LEA DX, LinhaVazia
    INT 21H
    LEA DX, Opcaosaida
    INT 21H
    LEA DX, LinhaSeparadora
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_TELA_INICIAL ENDP

CONFIGURAR_TELA PROC
    MOV AH, 0            ; Modo vídeo
    MOV AL, MODO_TEXTO   ; Texto 80x25
    INT 10H
    MOV AH, 0BH          ; Cor de fundo
    MOV BH, 0
    MOV BL, COR_VERDE    ; Verde
    INT 10H
    RET
CONFIGURAR_TELA ENDP

IMPRIMIR_TABULEIRO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL CONFIGURAR_TELA ; Limpa tela
    MOV AH, 2            ; Função imprimir char
    XOR CX, CX
    XOR BX, BX           ; Índice linha

IMPRIMIR_LINHA_TAB:
    MOV CX, 19           ; Espaçamento esquerdo
    MOV DL, ' '
    
IMPRIMIR_ESPACOS_TAB:
    INT 21H              ; Imprime espaço
    LOOP IMPRIMIR_ESPACOS_TAB
    
    MOV CX, 3            ; 3 colunas
    XOR SI, SI           ; Índice coluna

IMPRIMIR_COLUNA_TAB:
    MOV DL, MATRIZ[BX][SI] ; Caractere da posição
    INT 21H
    CMP SI, 2            ; Última coluna?
    JE PROXIMA_LINHA_TAB
    MOV DL, ' '          ; Separador
    INT 21H
    MOV DL, '|'          ; Divisória
    INT 21H
    MOV DL, ' '
    INT 21H
    INC SI               ; Próxima coluna
    LOOP IMPRIMIR_COLUNA_TAB
    
PROXIMA_LINHA_TAB:
    MOV DL, 10           ; Nova linha
    INT 21H
    ADD BX, 3            ; Próxima linha matriz
    CMP BX, 6            ; Todas as linhas?
    JBE IMPRIMIR_LINHA_TAB
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_TABULEIRO ENDP

EXIBIR_RESULTADO_FINAL PROC
    CALL IMPRIMIR_TABULEIRO ; Mostra tabuleiro final
    CMP CL, 2            ; É empate?
    JE EXIBIR_EMPATE

    MOV AH, 9            ; Imprime vitória
    MOV AL, JOGADOR_ATUAL
    MOV BX, 19           ; Posição na string
    MOV [Vitoria+BX], AL ; Insere jogador vencedor
    LEA DX, Vitoria
    INT 21H
    JMP FINALIZAR_EXIBICAO

EXIBIR_EMPATE:
    MOV AH, 9            ; Imprime empate
    LEA DX, Empate
    INT 21H

FINALIZAR_EXIBICAO:
    RET
EXIBIR_RESULTADO_FINAL ENDP

; ========== MODO PLAYER VS PLAYER ==========
JOGO_PVP PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
CICLO_PVP:
    CALL IMPRIMIR_TABULEIRO ; Mostra tabuleiro
    CALL EXIBIR_TURNO_ATUAL ; Mostra turno
    CALL LER_JOGADA         ; Lê jogada
    CALL VALIDAR_JOGADA     ; Valida jogada
    JC JOGADA_INVALIDA_PVP  ; Se inválida

    CALL ATUALIZAR_MATRIZ   ; Atualiza tabuleiro
    CALL VERIFICAR_ESTADO_JOGO ; Verifica fim
    TEST CL, CL             ; Jogo acabou?
    JZ CONTINUAR_PVP        ; Não, continua
    CALL EXIBIR_RESULTADO_FINAL ; Mostra resultado
    JMP FINALIZAR_PVP

CONTINUAR_PVP:
    CALL ALTERNAR_JOGADOR   ; Troca jogador
    JMP CICLO_PVP

JOGADA_INVALIDA_PVP:
    CALL TRATAR_ERRO_JOGADA ; Mostra erro
    JMP CICLO_PVP

FINALIZAR_PVP:
    CALL FINALIZAR_JOGO     ; Finaliza jogo
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
JOGO_PVP ENDP

; ========== MODO PLAYER VS IA ==========
JOGO_PV_IA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
CICLO_PV_IA:
    CALL IMPRIMIR_TABULEIRO ; Mostra tabuleiro
    CALL EXIBIR_TURNO_ATUAL ; Mostra turno
    CALL LER_JOGADA         ; Lê jogada jogador
    CALL VALIDAR_JOGADA     ; Valida jogada
    JC JOGADA_INVALIDA_PV_IA ; Se inválida

    CALL ATUALIZAR_MATRIZ   ; Atualiza tabuleiro
    CALL VERIFICAR_ESTADO_JOGO ; Verifica fim
    TEST CL, CL             ; Jogo acabou?
    JNZ FINALIZAR_COM_RESULTADO ; Sim, finaliza
    CALL ALTERNAR_JOGADOR   ; Troca para IA

TURNO_IA:
    CALL ESCOLHER_JOGADA_IA ; IA joga
    CALL VALIDAR_JOGADA     ; Valida jogada IA
    JNC ATUALIZAR_IA        ; Se válida
    JMP TURNO_IA            ; Tenta novamente

ATUALIZAR_IA:
    CALL ATUALIZAR_MATRIZ   ; Atualiza tabuleiro
    CALL VERIFICAR_ESTADO_JOGO ; Verifica fim
    TEST CL, CL             ; Jogo acabou?
    JNZ FINALIZAR_COM_RESULTADO ; Sim, finaliza
    CALL ALTERNAR_JOGADOR   ; Volta para jogador
    JMP CICLO_PV_IA

FINALIZAR_COM_RESULTADO:
    CALL EXIBIR_RESULTADO_FINAL ; Mostra resultado

FINALIZAR_PV_IA:
    CALL FINALIZAR_JOGO     ; Finaliza jogo
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

JOGADA_INVALIDA_PV_IA:
    CALL TRATAR_ERRO_JOGADA ; Mostra erro
    JMP CICLO_PV_IA
JOGO_PV_IA ENDP

; ========== LÓGICA DO JOGO ==========
EXIBIR_TURNO_ATUAL PROC
    MOV AL, JOGADOR_ATUAL
    MOV BX, 30            ; Posição na string
    MOV [TURNO+BX], AL    ; Insere jogador atual
    MOV AH, 9
    LEA DX, TURNO
    INT 21H
    RET
EXIBIR_TURNO_ATUAL ENDP

LER_JOGADA PROC
    MOV AH, 1             ; Lê tecla
    INT 21H
    RET
LER_JOGADA ENDP

VALIDAR_JOGADA PROC
    CMP AL, '1'           ; Menor que 1?
    JB JOGADA_INVALIDA_VAL
    CMP AL, '9'           ; Maior que 9?
    JA JOGADA_INVALIDA_VAL
    CALL VERIFICAR_CASA_LIVRE ; Casa livre?
    CMP CL, 0             ; CL=0 se ocupada
    JE JOGADA_INVALIDA_VAL
    CLC                   ; Limpa carry (válida)
    RET

JOGADA_INVALIDA_VAL:
    STC                   ; Seta carry (inválida)
    RET
VALIDAR_JOGADA ENDP

TRATAR_ERRO_JOGADA PROC
    MOV AH, 9
    CMP AL, '1'           ; Número inválido?
    JB NUMERO_INVALIDO_ERR
    CMP AL, '9'
    JA NUMERO_INVALIDO_ERR
    LEA DX, CASAOCUPADA   ; Casa ocupada
    INT 21H
    RET

NUMERO_INVALIDO_ERR:
    LEA DX, NUMEROINVALIDO ; Número inválido
    INT 21H
    RET
TRATAR_ERRO_JOGADA ENDP

VERIFICAR_CASA_LIVRE PROC
    PUSHF
    PUSH AX
    PUSH BX
    PUSH SI
    XOR BX, BX
    XOR SI, SI
    XOR CX, CX
    AND AL, 0FH           ; Converte para número

    CMP AL, 1             ; Verifica posição 1
    JE VER_POS1
    CMP AL, 2             ; Verifica posição 2
    JE VER_POS2
    CMP AL, 3             ; Verifica posição 3
    JE VER_POS3
    CMP AL, 4             ; Verifica posição 4
    JE VER_POS4
    CMP AL, 5             ; Verifica posição 5
    JE VER_POS5
    CMP AL, 6             ; Verifica posição 6
    JE VER_POS6
    CMP AL, 7             ; Verifica posição 7
    JE VER_POS7
    CMP AL, 8             ; Verifica posição 8
    JE VER_POS8
    CMP AL, 9             ; Verifica posição 9
    JE VER_POS9

VER_POS1:
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 1
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS2:
    MOV SI, 1              ; Coluna 1
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 2
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS3:
    MOV SI, 2              ; Coluna 2
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 3
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS4:
    MOV BX, 3              ; Linha 1
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 4
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS5:
    MOV BX, 3              ; Linha 1
    MOV SI, 1              ; Coluna 1
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 5
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS6:
    MOV BX, 3              ; Linha 1
    MOV SI, 2              ; Coluna 2
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 6
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS7:
    MOV BX, 6              ; Linha 2
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 7
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS8:
    MOV BX, 6              ; Linha 2
    MOV SI, 1              ; Coluna 1
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 8
    JMP VERIFICAR_SIMBOLO_LIVRE

VER_POS9:
    MOV BX, 6              ; Linha 2
    MOV SI, 2              ; Coluna 2
    MOV AH, MATRIZ[BX][SI] ; Pega valor posição 9

VERIFICAR_SIMBOLO_LIVRE:
    CMP AH, 'X'           ; Tem X?
    JE CASA_OCUPADA_LIVRE
    CMP AH, 'O'           ; Tem O?
    JE CASA_OCUPADA_LIVRE
    MOV CL, 1             ; Casa livre
    JMP FIM_VERIFICACAO_LIVRE

CASA_OCUPADA_LIVRE:
    MOV CL, 0             ; Casa ocupada

FIM_VERIFICACAO_LIVRE:
    POP SI
    POP BX
    POP AX
    POPF
    RET
VERIFICAR_CASA_LIVRE ENDP

ATUALIZAR_MATRIZ PROC
    PUSH AX
    PUSH BX 
    PUSH CX
    PUSH SI
    PUSHF
    XOR BX, BX
    XOR SI, SI
    MOV CL, JOGADOR_ATUAL ; Símbolo do jogador
    AND AL, 0FH           ; Converte para número

    CMP AL, 1             ; Posição 1
    JE ATUALIZAR_POS1
    CMP AL, 2             ; Posição 2
    JE ATUALIZAR_POS2
    CMP AL, 3             ; Posição 3
    JE ATUALIZAR_POS3
    CMP AL, 4             ; Posição 4
    JE ATUALIZAR_POS4
    CMP AL, 5             ; Posição 5
    JE ATUALIZAR_POS5
    CMP AL, 6             ; Posição 6
    JE ATUALIZAR_POS6
    CMP AL, 7             ; Posição 7
    JE ATUALIZAR_POS7
    CMP AL, 8             ; Posição 8
    JE ATUALIZAR_POS8
    CMP AL, 9             ; Posição 9
    JE ATUALIZAR_POS9

ATUALIZAR_POS1:
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 1
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS2:
    MOV SI, 1              ; Coluna 1
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 2
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS3:
    MOV SI, 2              ; Coluna 2
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 3
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS4:
    MOV BX, 3              ; Linha 1
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 4
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS5:
    MOV BX, 3              ; Linha 1
    MOV SI, 1              ; Coluna 1
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 5
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS6:
    MOV BX, 3              ; Linha 1
    MOV SI, 2              ; Coluna 2
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 6
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS7:
    MOV BX, 6              ; Linha 2
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 7
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS8:
    MOV BX, 6              ; Linha 2
    MOV SI, 1              ; Coluna 1
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 8
    JMP FIM_ATUALIZACAO

ATUALIZAR_POS9:
    MOV BX, 6              ; Linha 2
    MOV SI, 2              ; Coluna 2
    MOV MATRIZ[BX][SI], CL ; Atualiza posição 9

FIM_ATUALIZACAO:
    INC JOGADAS_FEITAS    ; Incrementa contador
    POPF
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ATUALIZAR_MATRIZ ENDP

ALTERNAR_JOGADOR PROC
    PUSH AX
    PUSHF
    MOV AL, JOGADOR_ATUAL
    CMP AL, 'X'           ; É X?
    JE TROCAR_PARA_O
    MOV JOGADOR_ATUAL, 'X' ; Troca para X
    JMP FIM_TROCA_JOGADOR
    
TROCAR_PARA_O:
    MOV JOGADOR_ATUAL, 'O' ; Troca para O

FIM_TROCA_JOGADOR:
    POPF
    POP AX
    RET
ALTERNAR_JOGADOR ENDP

; ========== INTELIGÊNCIA ARTIFICIAL ==========
ESCOLHER_JOGADA_IA PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH SI

    MOV AL, JOGADAS_FEITAS
    CMP AL, 3             ; Tem jogadas suficientes?
    JAE ESCOLHAPENSADA    ; Sim, usa lógica
    JMP ESCOLHAALEATORIA  ; Não, aleatório

ESCOLHAPENSADA:
    XOR BX, BX            ; Zera índice linha
CHECA_PROXIMA_LINHA:
    XOR DX, DX            ; Zera contadores
    MOV CX, 3             ; 3 posições por linha
    XOR SI, SI
CHECA_LINHA_ATUAL:
    MOV AL, MATRIZ[BX][SI] ; Pega valor
    TESTA_CASA_IA AL      ; Conta X/O
    INC SI 
    LOOP CHECA_LINHA_ATUAL
    
    CMP DH, 2             ; 2 O? → chance vitória
    JNE VER_O_LINHA
    JMP DESCOBRIU_LINHA
    
VER_O_LINHA:
    CMP DL, 2             ; 2 X? → precisa bloquear
    JNE PROXIMA_LINHA
    JMP DESCOBRIU_LINHA
    
PROXIMA_LINHA:
    ADD BX, 3             ; Próxima linha
    CMP BX, 6
    JBE CHECA_PROXIMA_LINHA
    
    XOR SI, SI            ; Zera índice coluna
CHECA_PROXIMA_COLUNA:
    XOR DX, DX            ; Zera contadores
    MOV CX, 3             ; 3 posições por coluna
    XOR BX, BX
CHECA_COLUNA_ATUAL:
    MOV AL, MATRIZ[BX][SI] ; Pega valor
    TESTA_CASA_IA AL      ; Conta X/O
    ADD BX, 3             ; Próxima linha
    LOOP CHECA_COLUNA_ATUAL

    CMP DH, 2             ; 2 O? → chance vitória
    JNE VER_O_COLUNA
    JMP DESCOBRIU_COLUNA
    
VER_O_COLUNA:
    CMP DL, 2             ; 2 X? → precisa bloquear
    JNE PROXIMA_COLUNA
    JMP DESCOBRIU_COLUNA
    
PROXIMA_COLUNA:
    INC SI                ; Próxima coluna
    CMP SI, 3
    JNZ CHECA_PROXIMA_COLUNA

    XOR DX, DX            ; Zera contadores
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
PRIMEIRA_DIAGONAL:
    MOV AL, MATRIZ[BX][SI] ; Pega valor diagonal
    TESTA_CASA_IA AL      ; Conta X/O
    ADD BX, 3             ; Próxima linha
    INC SI                ; Próxima coluna
    LOOP PRIMEIRA_DIAGONAL
    
    CMP DH, 2             ; 2 O? → chance vitória
    JNE VER_O_DIAGONAL1
    JMP DESCOBRIU_DIAGONAL1
    
VER_O_DIAGONAL1:
    CMP DL, 2             ; 2 X? → precisa bloquear
    JNE PROXIMA_DIAGONAL
    JMP DESCOBRIU_DIAGONAL1

PROXIMA_DIAGONAL:
    XOR DX, DX            ; Zera contadores
    XOR BX, BX
    MOV SI, 2             ; Última coluna
    MOV CX, 3
SEGUNDA_DIAGONAL:
    MOV AL, MATRIZ[BX][SI] ; Pega valor diagonal
    TESTA_CASA_IA AL      ; Conta X/O
    ADD BX, 3             ; Próxima linha
    DEC SI                ; Coluna anterior
    LOOP SEGUNDA_DIAGONAL

    CMP DH, 2             ; 2 O? → chance vitória
    JNE VER_O_DIAGONAL2
    JMP DESCOBRIU_DIAGONAL2
    
VER_O_DIAGONAL2:
    CMP DL, 2             ; 2 X? → precisa bloquear
    JNE ESCOLHAALEATORIA
    JMP DESCOBRIU_DIAGONAL2
    
DESCOBRIU_LINHA:
    XOR SI, SI
    MOV CX, 3
CHECA_CASA_LINHA:
    MOV AL, MATRIZ[BX][SI] ; Pega posição
    CMP AL, '9'           ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA      ; Encontrou casa vazia
    INC SI 
    LOOP CHECA_CASA_LINHA 
    JMP PROXIMA_LINHA
    
DESCOBRIU_COLUNA:
    XOR BX, BX
    MOV CX, 3
CHECA_CASA_COLUNA:
    MOV AL, MATRIZ[BX][SI] ; Pega posição
    CMP AL, '9'           ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA      ; Encontrou casa vazia
    ADD BX, 3
    LOOP CHECA_CASA_COLUNA
    JMP PROXIMA_COLUNA
    
DESCOBRIU_DIAGONAL1:
    XOR BX, BX
    XOR SI, SI
    MOV CX, 3
CHECA_CASA_DIAGONAL1:
    MOV AL, MATRIZ[BX][SI] ; Pega posição
    CMP AL, '9'           ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA      ; Encontrou casa vazia
    ADD BX, 3
    INC SI
    LOOP CHECA_CASA_DIAGONAL1
    JMP PROXIMA_DIAGONAL
    
DESCOBRIU_DIAGONAL2:
    XOR BX, BX
    MOV SI, 2
    MOV CX, 3
CHECA_CASA_DIAGONAL2:
    MOV AL, MATRIZ[BX][SI] ; Pega posição
    CMP AL, '9'           ; ≤ '9'? → vazia
    JBE ESCOLHAFEITA      ; Encontrou casa vazia
    ADD BX, 3
    DEC SI
    LOOP CHECA_CASA_DIAGONAL2
    JMP ESCOLHAALEATORIA
        
ESCOLHAFEITA:
    POP SI
    POP BX
    POP CX
    POP DX
    RET

ESCOLHAALEATORIA:
    MOV AH, 2CH           ; Pega tempo do sistema
    INT 21H
    MOV AL, DL            ; Usa centésimos
    XOR AH, AH
    MOV CL, 9
    DIV CL                ; Divide por 9
    INC AH                ; 1-9
    MOV AL, AH
    OR AL, 30H            ; Converte para ASCII
    JMP ESCOLHAFEITA
ESCOLHER_JOGADA_IA ENDP

; ========== VERIFICAÇÃO DE VITÓRIA/EMPATE ==========
VERIFICAR_ESTADO_JOGO PROC
    PUSH BX
    PUSH SI
    PUSH AX
    PUSH DX
    XOR BX, BX
    XOR SI, SI
    XOR CL, CL            ; CL=0 sem vitória
    MOV AL, JOGADOR_ATUAL ; Jogador a verificar

    CALL VERIFICAR_LINHA_VITORIA
    JC VITORIA_ENCONTRADA_ESTADO
    CALL VERIFICAR_COLUNA_VITORIA
    JC VITORIA_ENCONTRADA_ESTADO
    CALL VERIFICAR_DIAGONAL_VITORIA
    JC VITORIA_ENCONTRADA_ESTADO

    MOV AL, JOGADAS_FEITAS
    CMP AL, 9             ; Todas casas preenchidas?
    JB FIM_VERIFICACAO_ESTADO
    MOV CL, 2             ; Empate

VITORIA_ENCONTRADA_ESTADO:
    MOV CL, 1             ; Vitória

FIM_VERIFICACAO_ESTADO:
    POP DX
    POP AX
    POP SI
    POP BX
    RET
VERIFICAR_ESTADO_JOGO ENDP

VERIFICAR_LINHA_VITORIA PROC
    PUSH BX
    PUSH SI
    XOR BX, BX
    XOR SI, SI
    CALL VERIFICAR_TRES_POSICOES
    JC VITORIA_LINHA_VER
    MOV BX, 3
    XOR SI, SI
    CALL VERIFICAR_TRES_POSICOES
    JC VITORIA_LINHA_VER
    MOV BX, 6
    XOR SI, SI
    CALL VERIFICAR_TRES_POSICOES
    JC VITORIA_LINHA_VER
    CLC
    JMP FIM_VERIFICAR_LINHA_VER

VITORIA_LINHA_VER:
    STC

FIM_VERIFICAR_LINHA_VER:
    POP SI
    POP BX
    RET
VERIFICAR_LINHA_VITORIA ENDP

VERIFICAR_COLUNA_VITORIA PROC
    PUSH BX
    PUSH SI
    XOR BX, BX
    XOR SI, SI
    CALL VERIFICAR_TRES_POSICOES_COLUNA
    JC VITORIA_COLUNA_VER
    XOR BX, BX
    MOV SI, 1
    CALL VERIFICAR_TRES_POSICOES_COLUNA
    JC VITORIA_COLUNA_VER
    XOR BX, BX
    MOV SI, 2
    CALL VERIFICAR_TRES_POSICOES_COLUNA
    JC VITORIA_COLUNA_VER
    CLC
    JMP FIM_VERIFICAR_COLUNA_VER

VITORIA_COLUNA_VER:
    STC

FIM_VERIFICAR_COLUNA_VER:
    POP SI
    POP BX
    RET
VERIFICAR_COLUNA_VITORIA ENDP

VERIFICAR_DIAGONAL_VITORIA PROC
    PUSH BX
    PUSH SI
    XOR BX, BX
    XOR SI, SI
    CALL VERIFICAR_TRES_POSICOES_DIAGONAL
    JC VITORIA_DIAGONAL_VER
    XOR BX, BX
    MOV SI, 2
    CALL VERIFICAR_TRES_POSICOES_DIAGONAL_INVERSA
    JC VITORIA_DIAGONAL_VER
    CLC
    JMP FIM_VERIFICAR_DIAGONAL_VER

VITORIA_DIAGONAL_VER:
    STC

FIM_VERIFICAR_DIAGONAL_VER:
    POP SI
    POP BX
    RET
VERIFICAR_DIAGONAL_VITORIA ENDP

VERIFICAR_TRES_POSICOES PROC
    MOV DL, MATRIZ[BX][SI] ; Posição 1
    CMP AL, DL
    JNE FALHA_TRES_POSICOES
    INC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 2
    CMP AL, DL
    JNE FALHA_TRES_POSICOES
    INC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 3
    CMP AL, DL
    JNE FALHA_TRES_POSICOES
    STC                   ; Vitória
    RET

FALHA_TRES_POSICOES:
    CLC                   ; Sem vitória
    RET
VERIFICAR_TRES_POSICOES ENDP

VERIFICAR_TRES_POSICOES_COLUNA PROC
    MOV DL, MATRIZ[BX][SI] ; Posição 1
    CMP AL, DL
    JNE FALHA_TRES_COLUNA
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI] ; Posição 2
    CMP AL, DL
    JNE FALHA_TRES_COLUNA
    ADD BX, 3
    MOV DL, MATRIZ[BX][SI] ; Posição 3
    CMP AL, DL
    JNE FALHA_TRES_COLUNA
    STC                   ; Vitória
    RET

FALHA_TRES_COLUNA:
    CLC                   ; Sem vitória
    RET
VERIFICAR_TRES_POSICOES_COLUNA ENDP

VERIFICAR_TRES_POSICOES_DIAGONAL PROC
    MOV DL, MATRIZ[BX][SI] ; Posição 1
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL
    ADD BX, 3
    INC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 2
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL
    ADD BX, 3
    INC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 3
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL
    STC                   ; Vitória
    RET

FALHA_TRES_DIAGONAL:
    CLC                   ; Sem vitória
    RET
VERIFICAR_TRES_POSICOES_DIAGONAL ENDP

VERIFICAR_TRES_POSICOES_DIAGONAL_INVERSA PROC
    MOV DL, MATRIZ[BX][SI] ; Posição 1
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL_INVERSA
    ADD BX, 3
    DEC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 2
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL_INVERSA
    ADD BX, 3
    DEC SI
    MOV DL, MATRIZ[BX][SI] ; Posição 3
    CMP AL, DL
    JNE FALHA_TRES_DIAGONAL_INVERSA
    STC                   ; Vitória
    RET

FALHA_TRES_DIAGONAL_INVERSA:
    CLC                   ; Sem vitória
    RET
VERIFICAR_TRES_POSICOES_DIAGONAL_INVERSA ENDP

; ========== FINALIZAÇÃO ==========
FINALIZAR_JOGO PROC
    MOV AH, 2
    MOV DL, 10            ; Nova linha
    INT 21H
    MOV AH, 9
    LEA DX, CLIQUE        ; Mensagem continuação
    INT 21H
    MOV AH, 1             ; Espera ENTER
    INT 21H
    CALL REINICIAR_MATRIZ ; Reseta tabuleiro
    RET
FINALIZAR_JOGO ENDP

REINICIAR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH SI
    MOV MATRIZ[0], '1'    ; Posição 1
    MOV MATRIZ[1], '2'    ; Posição 2
    MOV MATRIZ[2], '3'    ; Posição 3
    MOV MATRIZ[3], '4'    ; Posição 4
    MOV MATRIZ[4], '5'    ; Posição 5
    MOV MATRIZ[5], '6'    ; Posição 6
    MOV MATRIZ[6], '7'    ; Posição 7
    MOV MATRIZ[7], '8'    ; Posição 8
    MOV MATRIZ[8], '9'    ; Posição 9
    MOV JOGADAS_FEITAS, 0 ; Zera contador
    MOV JOGADOR_ATUAL, 'X' ; Reinicia com X
    POP SI
    POP BX
    POP AX
    RET
REINICIAR_MATRIZ ENDP

END MAIN
