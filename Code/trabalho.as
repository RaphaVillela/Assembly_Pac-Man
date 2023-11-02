;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d
TEMPO_CONTAGEM	EQU		FFF6h
TEMPO_CONTROLE	EQU		FFF7h
INTERVALO		EQU		10d
INICIO			EQU		1615h					;Posicao inicial Pacman
PontoCentena	EQU		0209h					;Posicao da centena de pontos na tela
PontoDezena	    EQU		020ah					;Posicao da dezena de pontos na tela
PontoUnidade	EQU		020bh					;Posicao da unidade de pontos na tela
POSICAOVIDA		EQU		0108h					;Posicao da Vida na tela
PAREDE			EQU		'#'
FANTASMA		EQU		'?'
BANANA			EQU		'('
COMIDA			EQU		'.'
VAZIO			EQU		' '
PAC				EQU		'@'
PARADO			EQU		0d
CIMA			EQU		1d
ESQUERDA        EQU		2d
BAIXO           EQU		3d
DIREITA         EQU		4d
PACTEMP			EQU		'$'
FANTASMATEMP	EQU		'!'

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

					ORIG    8000h
RowIndex			WORD	1d
ColumnIndex			WORD	1d
PosicaoPac			WORD	0d
DirecaoPac			WORD	PARADO
PacTela				WORD	INICIO
DirecaoFantasma		WORD	CIMA
ContadorFantasma	WORD	0d						;Conta as andadas para mudar a direcao
Vidas				WORD	3d						;Vidas inicia como 3

Linha1				STR		'Vidas: 3                   ( = +10 pontos'
Linha2				STR		'Pontos: 000                . = +1 pontos '
Linha3				STR		'#########################################'
Linha4				STR		'#(....?..(....#....(.....#.....(..?....(#'
Linha5				STR		'##..............#...?...#..............##'
Linha6				STR		'#(#...............#...#...............#(#'
Linha7				STR		'#..#...(###(........#........(###(...#..#'
Linha8				STR		'#...#..# . #.................# . #  #...#'
Linha9				STR		'#......# . #.................# . #......#'
Linha10				STR		'##..#...###(........?........(###...#..##'
Linha11				STR		'#........(.....................(........#'
Linha12				STR		'#.....?..#..........#..........#....?...#'
Linha13				STR		'#........#.......#..(..#.......#........#'
Linha14				STR		'#........(.....#.........#.....(........#'
Linha15				STR		'#........#...#.............#...#........#'
Linha16				STR		'#........#.#.........?.......#.#........#'
Linha17				STR		'#........#.(................(..#........#'
Linha18				STR		'#......#.........................#......#'
Linha19				STR		'#....#.............................#....#'
Linha20				STR		'#..#.................................#..#'
Linha21				STR		'#.#####################################.#'
Linha22				STR		'#...................@.................. #'
Linha23				STR		'#########################################'


;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
				ORIG    FE00h
INT0           	WORD    Pac_cima
INT1          	WORD    Pac_esquerda
INT2           	WORD    Pac_baixo
INT3           	WORD    Pac_direita

				ORIG 	FE0Fh
INT15			WORD	CicloJogo

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;Parte para colocar o mapa na tela
FazMapa:		MOV R1, 1						;Bota o valor inicial de R1(linha)
				MOV R3, Linha1					;Inicia pela linha1

While1: 		CMP R1, 24d						;Compara para ver se viu todas as linhas
				JMP.Z Final1					;Se ja viu tudo vai pro final1

				MOV R2, 1						;Valor inicial de R2(coluna)


While2:			CMP R2, 42d						;Verifica se viu todas as colunas
				JMP.Z Final2					;Se ja viu todas as colunas vai pra final2

				MOV R4, M[R3]					;Pegar o caracter para R4
				MOV R5, R1						;R5 pega o valor da linha
				SHL R5, 8						;Coloca pra esquerda
				OR R5, R2						;Adiciona o valor da coluna

				MOV M[CURSOR], R5				;Coloca o cursor na posicao desejada
				MOV M[IO_WRITE], R4				;Escreve o caracter R4

				INC R2							;+1 R2(coluna)
				INC R3							;+1 R3(caracter)

				JMP While2						;Volta pro While2
;Acabou uma linha
Final2:			INC R1							;+1 R1(linha)

				JMP While1						;Volta pra While1

;Acabou tudo
Final1:			RET

;Ciclo de tempo do jogo
CicloJogo:		DSI

				MOV R1, 4						;Bota o valor inicial de R1(linha4), pois e a primeira linha que pode ter algo alterado
				MOV R3, Linha4					;Inicia pela linha4

Loop1: 			CMP R1, 23d						;Compara para ver se viu todas as linhas
				JMP.Z Acaba1					;Se ja viu tudo vai pro final1

				MOV R2, 1						;Valor inicial de R2(coluna)


Loop2:			CMP R2, 42d						;Verifica se viu todas as colunas
				JMP.Z Acaba2					;Se ja viu todas as colunas vai pra final2

				MOV R4, M[R3]					;Pegar o caracter para R4
				MOV R5, R1						;R5 pega o valor da linha
				SHL R5, 8						;Coloca pra esquerda
				OR R5, R2						;Adiciona o valor da coluna

				PUSH R1
				PUSH R2
				PUSH R4
				PUSH R3
				PUSH R5

				CMP R4, PAC						;Verifica se achou o Pacman
				JMP.NZ Else1

				CALL MovePac

				JMP AcabaIf1

Else1:			CMP R4, FANTASMA				;Verifica se achou um fantasma
				JMP.NZ Else2			

				CALL MoveFantasma
				
				JMP AcabaIf1
				
Else2:			CMP R4, PACTEMP
				JMP.NZ Else3
				
				MOV R6, PAC
				MOV M[R3], R6
				
				MOV M[CURSOR], R5
				MOV M[IO_WRITE], R6
				
				JMP AcabaIf1
				
Else3:			CMP R4, FANTASMATEMP
				JMP.NZ AcabaIf1
				
				MOV R6, FANTASMA
				MOV M[R3], R6
				
				MOV M[CURSOR], R5
				MOV M[IO_WRITE], R6
								

AcabaIf1:		POP R5
				POP R3
				POP R4
				POP R2
				POP R1

				INC R2							;+1 R2(coluna)
				INC R3							;+1 R3(caracter)

				JMP Loop2						;Volta pro While2
;Acabou uma linha
Acaba2:			INC R1							;+1 R1(linha)

				JMP Loop1						;Volta pra While1

;Acabou tudo
Acaba1:			INC M[ContadorFantasma]			;+1 para ContadorFantasma

				MOV R6, 3d
				CMP M[ContadorFantasma], R6			;Verifica se ContadorFantasma chegou a 3
				JMP.NZ TerminouFantasma

				MOV R6, 4d
				CMP M[DirecaoFantasma], R6			;Verifica se DirecaoFantasma chegou a 4
				JMP.NZ AjeitarDirecaoFantasma

				MOV M[DirecaoFantasma], R0			;Direcao fantasma recebe 0

AjeitarDirecaoFantasma: INC M[DirecaoFantasma]		;R4 recebe 1

				MOV M[ContadorFantasma], R0			;Direcao fantasma recebe 0
				
TerminouFantasma:CALL SetaTimer

				ENI
				RTI

MovePac:		MOV R1, M[DirecaoPac]				;R1 recebe a direcao do Pac

				MOV R2, M[SP+3]						;R2 pega a memoria
				MOV R3, M[SP+2]						;R3 pega a posicao da tela
				
				MOV R6, PAC

				CMP R1, PARADO
				JMP.NZ Verifica1
				
				RET

Verifica1:		CMP R1, CIMA
				JMP.NZ Verifica2

				MOV R4, R2							;R4 recebe a memoria
				SUB R4, 41							;R4 atualiza a memoria para a proxima

				MOV R5, R3							;R5 recebe a posicao na tela
				SUB R5, 0100h						;R5 atualiza a posicao na tela para a proxima

				JMP FimVerifica

Verifica2:		CMP R1, ESQUERDA
				JMP.NZ Verifica3

				MOV R4, R2							;R4 recebe a memoria
				SUB R4, 1							;R4 atualiza a memoria para a proxima

				MOV R5, R3							;R5 recebe a posicao na tela
				SUB R5, 1							;R5 atualiza a posicao na tela para a proxima

				JMP FimVerifica

Verifica3:		CMP R1, BAIXO
				JMP.NZ Verifica4

				MOV R4, R2							;R4 recebe a memoria
				ADD R4, 41							;R4 atualiza a memoria para a proxima

				MOV R5, R3							;R5 recebe a posicao na tela
				ADD R5, 0100h						;R5 atualiza a posicao na tela para a proxima
				
				MOV R6, PACTEMP

				JMP FimVerifica

Verifica4:		CMP R1, DIREITA
				JMP.NZ FimVerifica

				MOV R4, R2							;R4 recebe a memoria
				ADD R4, 1							;R4 atualiza a memoria para a proxima

				MOV R5, R3							;R5 recebe a posicao na tela
				ADD R5, 1							;R5 atualiza a posicao na tela para a proxima
				
				MOV R6, PACTEMP

FimVerifica:	PUSH R6
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5

				CALL ColisaoPac

				POP R5
				POP R4
				POP R3
				POP R2
				POP R6

				RET
				
Mais1Ponto:		MOV R1, Linha2
				ADD R1, 10d
				
				MOV R2, M[R1]						; Tem a unidade
				
				CMP R2, '9'
				JMP.NZ Foi1
				
				MOV R2, '0'
				
				PUSH R1
				PUSH R2
				
				CALL Mais10Pontos
				
				POP R2
				POP R1
				
				JMP FinalUnidade
				
Foi1:			INC R2

FinalUnidade:	MOV M[R1], R2
				
				MOV R3, PontoUnidade
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R2
				
				RET
				
Mais10Pontos:	MOV R1, Linha2
				ADD R1, 9d
				
				MOV R2, M[R1]						; Tem a Dezena
				
				CMP R2, '9'
				JMP.NZ Foi10
				
				MOV R2, '0'
				
				PUSH R1
				PUSH R2
				
				CALL Mais100Pontos
				
				POP R2
				POP R1
				
				JMP FinalDezena
				
Foi10:			INC R2

FinalDezena:	MOV M[R1], R2
				
				MOV R3, PontoDezena
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R2
				
				RET
				
Mais100Pontos:	MOV R1, Linha2
				ADD R1, 8d
				
				MOV R2, M[R1]						; Tem a Centena
				
				CMP R2, '9'
				JMP.NZ Foi100
				
				MOV R2, '0'
				
				JMP FinalCentena
				
Foi100:			INC R2

FinalCentena:	MOV M[R1], R2
				
				MOV R3, PontoCentena
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R2
				
				RET

ColisaoPac:		MOV R1, M[SP+5]						;R1 pega a memoria
				MOV R2, M[SP+4]						;R2 pega a posicao da tela
				MOV R3, M[SP+3]						;R3 pega a proxima memoria
				MOV R4, M[SP+2]						;R4 pega a proxima posicao da tela

				MOV  R5, M[R3]

				CMP R5, PAREDE
				JMP.NZ PacFantasma
				RET

PacFantasma:	CMP R5, FANTASMA
				JMP.NZ PacComida

				MOV R3, Linha22
				ADD R3, 20
				MOV R4, INICIO
				
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5

				CALL Menos1Vida
				
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				
				CMP M[Vidas], R0
				JMP.NZ FimColisao			
				
				MOV R6, VAZIO
				MOV M[R1], R6
				
				MOV M[CURSOR], R2
				MOV M[IO_WRITE], R6
				
				RET

PacComida:		CMP R5, COMIDA
				JMP.NZ PacBanana
				
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				
				CALL Mais1Ponto
				
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				
				JMP FimColisao

PacBanana:		CMP R5, BANANA
				JMP.NZ FimColisao
				
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				
				CALL Mais10Pontos
				
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1

FimColisao:		MOV R5, M[SP+6]					;Pega o que tem que printar, PAC ou PACTEMP

				MOV R6, VAZIO					;R6 recebe ' '
				MOV M[R1], R6					;O endereco de memoria atual recebe vazio

				MOV M[R3], R5					;O proximo endereco recebe o que tem que printar, PAC ou PACTEMP

				MOV M[CURSOR], R2				;Coloca o cursor na posicao da tela atual
				MOV M[IO_WRITE], R6				;Escreve o caracter R6 nela

				MOV M[CURSOR], R4				;Coloca o cursor na posicao da proxima tela
				MOV M[IO_WRITE], R5				;Escreve o caracter R5 nela

				RET

MoveFantasma:	MOV R1, M[SP+3]						;R1 pega a memoria
				MOV R2, M[SP+2]						;R2 pega a posicao da tela
				
				MOV R3, FANTASMA

				MOV R5, CIMA
				CMP M[DirecaoFantasma], R5
				JMP.NZ FantasmaProx1

				MOV R6, R1							;R6 sera a memoria para onde o fantasma ta indo
				SUB R6, 41d

				MOV R7, R2							;R7 sera a posicao da tela de onde o fantasma vai
				SUB R7, 0100h

				MOV R5, BAIXO
				MOV M[DirecaoFantasma], R5			;Muda a direcao para o proximo fantasma

				JMP ColideFantasma

FantasmaProx1:	MOV R5, ESQUERDA
				CMP M[DirecaoFantasma], R5
				JMP.NZ FantasmaProx2

				MOV R6, R1							;R6 sera a memoria para onde o fantasma ta indo
				SUB R6, 1d

				MOV R7, R2							;R7 sera a posicao da tela de onde o fantasma vai
				SUB R7, 1d

				MOV R5, DIREITA
				MOV M[DirecaoFantasma], R5			;Muda a direcao para o proximo fantasma

				JMP ColideFantasma

FantasmaProx2:	MOV R5, BAIXO
				CMP M[DirecaoFantasma], R5
				JMP.NZ FantasmaProx3

				MOV R6, R1							;R6 sera a memoria para onde o fantasma ta indo
				ADD R6, 41d

				MOV R7, R2							;R7 sera a posicao da tela de onde o fantasma vai
				ADD R7, 0100h

				MOV R5, CIMA
				MOV M[DirecaoFantasma], R5			;Muda a direcao para o proximo fantasma
				
				MOV R3, FANTASMATEMP

				JMP ColideFantasma

FantasmaProx3:	MOV R5, DIREITA
				CMP M[DirecaoFantasma], R5
				JMP.NZ ColideFantasma

				MOV R6, R1							;R6 sera a memoria para onde o fantasma ta indo
				INC R6

				MOV R7, R2							;R7 sera a posicao da tela de onde o fantasma vai
				INC R7

				MOV R5, ESQUERDA
				MOV M[DirecaoFantasma], R5			;Muda a direcao para o proximo fantasma
				
				MOV R3, FANTASMATEMP
				
;Temos R1(MemoriaAtual), R2(TelaAtual), R6(ProximaMemoria), R7(ProximaTela)
ColideFantasma:	PUSH R3							;Guarda a variavel
				
				MOV R3, PAREDE
				CMP M[R6], R3					;Verifica se ta indo pra parede
				JMP.NZ FantasmaPac

				POP R3
				
				RET

FantasmaPac:	MOV R3, PAC
				CMP M[R6], R3					;Verifica se ta indo pra cima do pac
				JMP.NZ FimFantasma
				
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6

				CALL Menos1Vida
				
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				
				CMP M[Vidas], R0
				JMP.Z FimFantasma

				MOV R4, Linha22
				ADD R4, 20d
				MOV M[R4], R3

				MOV R5, INICIO
				MOV M[CURSOR], R5
				MOV M[IO_WRITE], R3
				
				

FimFantasma:	POP R4							;Pega o valor do antigo R3 e bota em R4

				MOV R3, VAZIO
				MOV M[R1], R3					;Memoria atual vai pra vazio

				MOV M[R6], R4					;Memoria Prox vai para FANTASMATEMP

				MOV M[CURSOR], R2				;Cursor vai pra tela atual
				MOV M[IO_WRITE], R3				;Escreve vazio em tela atual

				MOV M[CURSOR], R7				;Cursor vai pra tela prox
				MOV M[IO_WRITE], R4				;Escreve FANTASMATEMP em tela prox

				RET

Menos1Vida:	    DEC M[Vidas]					;Atualiza o valor de vidas

				MOV R1, Linha1
				ADD R1, 7d
				DEC M[R1]
				
				MOV R2, POSICAOVIDA
				MOV M[CURSOR], R2
				MOV R3, M[R1]
				MOV M[IO_WRITE], R3
				
				RET

SetaTimer:		PUSH R1

				MOV R1, INTERVALO				;R3 recebe o intervalo de tempo
				MOV M[TEMPO_CONTAGEM], R1		;Define o tempo de intervalo em 0.5s
				MOV R1, 1						;R4 recebe 1
				MOV M[TEMPO_CONTROLE], R1		;Inicia a contagem de tempo

				POP R1
				RET

Pac_cima:		DSI								;Desabilita as interrupções

				PUSH R1

				MOV R1, CIMA					;R1 Recebe a direcao cima
				MOV M[DirecaoPac], R1			;Coloca R1 na direcao do Pac

				POP	R1

				ENI								;Habilita as interrupções novamente
				RTI								;Retornar da interrupção

Pac_esquerda:	DSI

				PUSH R1

				MOV R1, ESQUERDA				;R1 Recebe a direcao esquerda
				MOV M[DirecaoPac], R1			;Coloca R1 na direcao do Pac

				POP	R1

				ENI								;Habilita as interrupções novamente
				RTI								;Retornar da interrupção

Pac_baixo:		DSI

				PUSH R1

				MOV R1, BAIXO					;R1 Recebe a direcao baixo
				MOV M[DirecaoPac], R1			;Coloca R1 na direcao do Pac

				POP	R1

				ENI								;Habilita as interrupções novamente
				RTI								;Retornar da interrupção

Pac_direita:	DSI

				PUSH R1

				MOV R1, DIREITA					;R1 Recebe a direcao direita
				MOV M[DirecaoPac], R1			;Coloca R1 na direcao do Pac

				POP	R1

				ENI								;Habilita as interrupções novamente
				RTI								;Retornar da interrupção

Main:			MOV		R1, INITIAL_SP
				MOV		SP, R1		 			; We need to initialize the stack

				MOV		R2, CURSOR_INIT			; We need to initialize the cursor
				MOV		R3, INICIO
				MOV		M[ CURSOR ], R2			; with value CURSOR_INIT

				;Iniciar o mapa
				CALL FazMapa					; Funcao para fazer o mapa
				CALL SetaTimer

				ENI

End: 			JMP		End
