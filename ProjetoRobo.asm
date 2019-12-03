.data    
	black:	  .word 0x00000
	white:	  .word 0xFFFFFF
	orange:   .word 0xF67F2E
	yellow:   .word 0xF5F62E
	blue: 	  .word 0x2E8CF6
	grey:	  .word 0xc2c2c2
.text

	j main
	
	set_tela: #Inicia todos os valores para a tela
		addi $t0, $zero, 65536 #65536 = (512*512)/4 pixels
		add $t1, $t0, $zero #Adicionar a distribuiÃ§Ã£o de pixels ao endereco
		lui $t1, 0x1004 #Endereco base da tela no heap, pode mudar se quiser
		jr $ra

	set_cores: #Salvar as cores em registradores
		lw $s2, grey #Cor da margem
		lw $s3, blue #Cor do preenchimento final da linha (volta)
		lw $s4, white #Cor da linha do percurso
		lw $s5, orange #Cor do Robo
		lw $s6, black #Cor do fundo da tela
		lw $s7, yellow #Cor do prenchimento inicial da linha (ida)
		jr $ra
		
	set_margem:
		add $t0, $t1, $zero
		addi $t2, $zero, 0
		marg1: 
			sw $s2, ($t0) #Pinto o pixel na posicao $t0 com cinza
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 127, endmarg1 #Termina o limite da tela, vai para a proxima margem
			j marg1 #Continua essa margem
		endmarg1:
		addi $t2, $zero, 0
		marg2: 
			sw $s2, ($t0) #Pinto o pixel na posicao $t0 com cinza
			addi $t0, $t0, 512 #Pulo +512 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 127, endmarg2 #Termina o limite da tela, vai para a proxima margem
			j marg2 #Continua essa margem
		endmarg2:
		addi $t2, $zero, 0
		marg3: 
			sw $s2, ($t0) #Pinto o pixel na posicao $t0 com cinza
			subi $t0, $t0, 4 #Volto -4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 127, endmarg3 #Termina o limite da tela, vai para a proxima margem
			j marg3 #Continua essa margem
		endmarg3:
		addi $t2, $zero, 0
		marg4: 
			sw $s2, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			subi $t0, $t0, 512 #Volto -512 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 127, endmarg4 #Termina a margem
			j marg4 #Continua essa margem
		endmarg4:
		jr $ra
		
	
	espera1: #Funcao para espera de 10 milisegundos
		li $v0, 32 #Codigo do syscall para Sleep
		li $a0, 10 #Parametro do tempo de espera em milisegundos
		syscall
		jr $ra
		
	espera2:#Funcao para espera de 100 milisegundos
		li $v0, 32 #Codigo do syscall para Sleep
		li $a0, 100 #Parametro do tempo de espera 100 em milisegundos
		syscall
		jr $ra
	
	
	moveRobo: #Movimentacao do robo (em zigzag até em baixo e volta reto para cima) input: $t3=ponto do robo;
		moveDir: #Começa movimentando para direita
		jal verifica #Funcao verifica, verifica a linha branca esta proxima
		addi $t5, $t3, 4 #Guarda em $t5 o endereço da direita do robo
		lw $s1, ($t5) #Guarda a cor do proximo endereco
		beq $s1, $s2, moveBaixo #Se for a cor da margem, move para baixo
		sw $s6, ($t3) #Posicao atual é pintada de preto
		addi $t3, $t3, 4 #Posicao atual incrementada para a proxima posicao
		sw $s5, ($t3) #Posicao atual pintada de laranja (assim é realizada a movimentacao do robo)
		jal espera1 #Apos movimentação, faz-se um delay para o programa nao ir muito rapido
		b moveDir
		
		moveBaixo: #Na margem direita, faz uma movimentacao curta para baixo
		addi $t0, $zero, 0 #$t0, contador
		loopBaixo:
		jal verifica #Funcao verifica, verifica a linha branca esta proxima
		addi $t5, $t3, 512 #Guarda em $t5 o endereço abaixo do robo
		lw $s1, ($t5) #Guarda a cor do proximo endereco
		beq $s1, $s2, moveCima #Se for a cor da margem, move para cima
		sw $s6, ($t3) #Posicao atual é pintada de preto
		addi $t3, $t3, 512 #Posicao atual incrementada para a proxima posicao
		sw $s5, ($t3) #Posicao atual pintada de laranja
		jal espera1 #Apos movimentação, faz-se um delay para o programa nao ir muito rapido
		addi $t0, $t0, 1 #Incrementa contador
		beq $t0, 20, moveEsq #Contador em 20, move para esquerda
		b loopBaixo
		
		moveEsq: #Entao movimenta para esquerda
		jal verifica#Funcao verifica, verifica a linha branca esta proxima
		subi $t5, $t3, 4 #Guarda em $t5 o endereço da esquerda do robo
		lw $s1, ($t5) #Guarda a cor do proximo endereco
		beq $s1, $s2, moveBaixo2 #Se for a cor da margem, move para baixo
		sw $s6, ($t3)#Posicao atual é pintada de preto
		subi $t3, $t3, 4 #Posicao atual incrementada para a proxima posicao
		sw $s5, ($t3) #Posicao atual pintada de laranja
		jal espera1 #Apos movimentação, faz-se um delay para o programa nao ir muito rapido
		b moveEsq
		
		moveBaixo2: #Na margem esquerda, faz uma movimentacao curta para baixo, e vai repetindo até aqui
		addi $t0, $zero, 0 #$t0, contador
		loopBaixo2:
		jal verifica #Funcao verifica, verifica a linha branca esta proxima
		addi $t5, $t3, 512 #Guarda em $t5 o endereço abaixo do robo
		lw $s1, ($t5) #Guarda a cor do proximo endereco
		beq $s1, $s2, moveCima #Se for a cor da margem, move para cima
		sw $s6, ($t3)#Posicao atual é pintada de preto
		addi $t3, $t3, 512 #Posicao atual incrementada para a proxima posicao
		sw $s5, ($t3) #Posicao atual pintada de laranja
		jal espera1 #Apos movimentação, faz-se um delay para o programa nao ir muito rapido
		addi $t0, $t0, 1 #Incrementa contador
		beq $t0, 20, moveDir #Contador em 20, move para direita (por isso foram feitas duas funcoes de movimento para baixo)
		b loopBaixo2
		
		moveCima: #Quando chega na margem inferior, volta diretamente para cima e recomeça o movimento
		jal verifica #Funcao verifica, verifica a linha branca esta proxima
		subi $t5, $t3, 512 #Guarda em $t5 o endereço acima do robo
		lw $s1, ($t5) #Guarda a cor do proximo endereco
		beq $s1, $s2, moveEsq #Se for a cor da margem, move para esquerda
		sw $s6, ($t3)#Posicao atual é pintada de preto
		subi $t3, $t3, 512 #Posicao atual incrementada para a proxima posicao
		sw $s5, ($t3) #Posicao atual pintada de laranja
		jal espera1 #Apos movimentação, faz-se um delay para o programa nao ir muito rapido
		b moveCima
		
	verifica: #Verifica se a linha branca se encontra em alguma das posicoes ao redor do robo, priorizando a cruz
		subi $t2, $t3, 512 #verifica em cima
		lw $s1, ($t2) #Guarda cor da posicao acima
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		addi $t2, $t3, 4 #verifica direita
		lw $s1, ($t2) #Guarda cor da posicao a direita
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		addi $t2, $t3, 512 #verifica em baixo
		lw $s1, ($t2) #Guarda cor da posicao abaixo
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		subi $t2, $t3, 4 #verifica esquerda
		lw $s1, ($t2) #Guarda cor da posicao a esquerda
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		
		subi $t2, $t3, 508 #verifica diagonal direita de cima
		lw $s1, ($t2) #Guarda cor da posicao na diagonal direita de cima
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		addi $t2, $t3, 516 #verifica diagonal direita de baixo
		lw $s1, ($t2)#Guarda cor da posicao na diagonal direita de baixo
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		addi $t2, $t3, 508 #verifica diagonal esquerda de baixo
		lw $s1, ($t2) #Guarda cor da posicao na diagonal esquerda de baixo
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		subi $t2, $t3, 516 #verifica diagonal esquerda de cima
		lw $s1, ($t2) #Guarda cor da posicao na diagonal esquerda de cima
		beq $s1, $s4, achaBranco #Se cor guardada for branco, entra na linha
		jr $ra
		
	
	achaBranco: #Funcao da primeria movimentacao na linha, indo ate uma das pontas e pintando de amarelo;  Input: $t3=posicao do robo
		sw $s6, ($t3) #Pinta posicao atual de preto para fazer movimentacao dentro da linha
		loopBranco:
		add $t3, $t2, $zero #Atualiza $t3 (posicao atua) para $t2 (posicao que se encontrou a linha) (entra na linha)
		sw $s5, ($t3) #Pinta posicao atual de Laranja
		jal espera2
		subi $t2, $t3, 512 #verifica em cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		addi $t2, $t3, 4 #verifica direita
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		addi $t2, $t3, 512 #verifica em baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		subi $t2, $t3, 4 #verifica esquerda
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		
		subi $t2, $t3, 508 #verifica diag dir cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		addi $t2, $t3, 516 #verifica diag dir baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		addi $t2, $t3, 508 #verifica diag esq baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		subi $t2, $t3, 516 #verifica diag esq cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAmarelo
		
		b achaAmarelo
		
		pintaAmarelo:
		sw $s7, ($t3)
		b loopBranco
		
	achaAmarelo: #$t3 esta o ponto
		subi $t2, $t3, 512 #verifica em cima
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		addi $t2, $t3, 4 #verifica direita
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		addi $t2, $t3, 512 #verifica em baixo
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		subi $t2, $t3, 4 #verifica esquerda
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		
		subi $t2, $t3, 508 #verifica diag dir cima
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		addi $t2, $t3, 516 #verifica diag dir baixo
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		addi $t2, $t3, 508 #verifica diag esq baixo
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		subi $t2, $t3, 516 #verifica diag esq cima
		lw $s1, ($t2)
		beq $s1, $s7, pintaAzul
		beq $s1, $s4, achaBranco2
		
		endAchaAmarelo:
		j endProg
		
		pintaAzul:
		sw $s3, ($t3)
		add $t3, $t2, $zero
		sw $s5, ($t3)
		jal espera2
		b achaAmarelo
			
	achaBranco2:
		sw $s3, ($t3)
		loopBranco2:
		add $t3, $t2, $zero
		sw $s5, ($t3)
		jal espera2
		subi $t2, $t3, 512 #verifica em cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		addi $t2, $t3, 4 #verifica direita
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		addi $t2, $t3, 512 #verifica em baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		subi $t2, $t3, 4 #verifica esquerda
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		
		subi $t2, $t3, 508 #verifica diag dir cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		addi $t2, $t3, 516 #verifica diag dir baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		addi $t2, $t3, 508 #verifica diag esq baixo
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		subi $t2, $t3, 516 #verifica diag esq cima
		lw $s1, ($t2)
		beq $s1, $s4, pintaAzul2
		
		j endProg
		
		pintaAzul2:
		sw $s3, ($t3)
		b loopBranco2			
	
		
		
	
	pontoAleatorio: #input: limx=$t8 limy=$t9; output: pontoAleatorio=$t7
		add $a1, $t8, $zero
		li $v0, 42
		syscall
		addi $s0, $a0, 1
		add $a1, $t9, $zero
		li $v0, 42
		syscall
		addi $t5, $a0, 1
		li $t6, 128
		mul $t5, $t5, $t6
		add $s0, $s0, $t5	
		add $s0, $s0, $s0
		add $t7, $s0, $s0
		jr $ra
		
	
	linhaZ: #limx 78 limy 78
		add $t0, $t3, $zero
		addi $t2, $zero, 0
		lz_1: 
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 49, endlz_1
			j lz_1
		endlz_1:
		addi $t2, $zero, 0
		lz_2: 
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 512 #Pulo +512 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 24, endlz_2
			j lz_2
		endlz_2:
		addi $t2, $zero, 0
		lz_3: 
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			subi $t0, $t0, 4 #Pulo -4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 49, endlz_3
			j lz_3
		endlz_3:
		addi $t2, $zero, 0
		lz_4: 
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 512 #Pulo +512 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 24, endlz_4
			j lz_4
		endlz_4:
		addi $t2, $zero, 0
		lz_5: 
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 50, endlz_5
			j lz_5
		endlz_5:
		jr $ra
	
	
	linhaL: #limx 98 limy 88
		add $t0, $zero, $t3
		addi $t2, $zero, 0
		l_1:
			sw $s4, ($t0)
			addi $t0, $t0, 512 #Ando de linha em linha, ou seja, 512
			addi $t2, $t2, 1
			beq $t2, 39, endl_1
			j l_1
		endl_1:
		addi $t2, $zero, 0
		l_2:
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 30, endl_2
			j l_2
		endl_2:
		jr $ra
		
	linhaW: #limx 88 limy 98
		add $t0, $zero, $t3
		addi $t2, $zero, 0
		w_1:
			sw $s4, ($t0)
			addi $t0, $t0, 512 #Ando de linha em linha, ou seja, 512
			addi $t2, $t2, 1
			beq $t2, 29, endw_1
			j w_1
		endw_1:
		addi $t2, $zero, 0
		w_2:
			sw $s4, ($t0)
			addi $t0, $t0, 516 #Ando de diag, ou seja, 516
			addi $t2, $t2, 1
			beq $t2, 9, endw_2
			j w_2
		endw_2:
		addi $t2, $zero, 0
		w_3:
			sw $s4, ($t0)
			subi $t0, $t0, 508 #Ando de diag, ou seja, 516
			addi $t2, $t2, 1
			beq $t2, 9, endw_3
			j w_3
		endw_3:
		addi $t2, $zero, 0
		w_4:
			sw $s4, ($t0)
			addi $t0, $t0, 516 #Ando de diag, ou seja, 516
			addi $t2, $t2, 1
			beq $t2, 9, endw_4
			j w_4
		endw_4:
		addi $t2, $zero, 0
		w_5:
			sw $s4, ($t0)
			subi $t0, $t0, 508 #Ando de diag, ou seja, 516
			addi $t2, $t2, 1
			beq $t2, 9, endw_5
			j w_5
		endw_5:
		addi $t2, $zero, 0
		w_6:
			sw $s4, ($t0)
			subi $t0, $t0, 512 #Ando de linha em linha, ou seja, 512
			addi $t2, $t2, 1
			beq $t2, 30, endw_6
			j w_6
		endw_6:
		
	
		jr $ra
	
	
main:
	jal set_tela
	jal set_cores
	jal set_margem
	
	li $a1, 3
	li $v0, 42
	syscall
	beq $a0, 2, desenhaW
	beq $a0, 1, desenhaZ
	beq $a0, 0, desenhaL
	desenhaW:
	li $t8, 78
	li $t9, 78
	jal pontoAleatorio
	add $t3, $t1, $t7
	jal linhaW
	b ponto
	desenhaZ:
	li $t8, 78
	li $t9, 78
	jal pontoAleatorio
	add $t3, $t1, $t7
	jal linhaZ
	b ponto
	desenhaL:
	li $t8, 98
	li $t9, 88
	jal pontoAleatorio
	add $t3, $t1, $t7
	jal linhaL
	ponto:
	li $t8, 126
	li $t9, 126
	jal pontoAleatorio
	add $t3, $t1, $t7
	j moveRobo
	endProg:
	
	li $v0, 10
	syscall
