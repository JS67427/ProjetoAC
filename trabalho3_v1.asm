.data
newline: .asciiz "\n"
newblock: .asciiz "We have found a new block =)"
A:.asciiz "A = "
B:.asciiz "B = "
C:.asciiz "C = "
D:.asciiz "D = "
E:.asciiz "E = "
F:.asciiz "F = "
G:.asciiz "G = "
H:.asciiz "H = "
no_newblock: .asciiz "We haven´t found a new block =("

.text

main:
#load values into stack
la $s0, 0x87564C0C	#A
la $s1, 0xF1369725	#B
la $s2, 0x82E6D493	#C
la $s3, 0x63A6B509	#D
la $s4, 0xDD9EFF54	#E
la $s5, 0xE07C2655	#F
la $s6, 0xA41F32E7 	#G
la $s7, 0xC7D25631	#H

#Check results according calculations
#jal MA
#jal BOX_0
#jal Ch
#jal BOX_1
#jal BOX_KW

# "Uma ‘hash’ total consiste em repetir isso 128 vezes."
addi $t8, $t8, 1	#test 1st step
#addi $t8, $t8, 128	#128 into $t8

for:
beq $t8, $t9, exit_step	#counter for loop

jal BOX_KW		#get value in $a0
addu $s7, $s7, $a0	#$s7 holds value of H + KW	

jal Ch			#get value in $t3
addu $s7, $s7, $t3	#$s7 holds value of (H + KW) + Ch

jal BOX_1		#get value in $t6
addu $s7, $s7, $t6	#$s7 holds value of (H + KW + Ch) + BOX_1

#move $a0, $s7		#check number -> obtive no papel 0x4a28427a
#li $v0, 34
#syscall

#Como observamos na imagem, agora adicionamos este valor H ao D
addu $s3, $s3, $s7	#$s3 holds value of (H + KW + Ch + BOX_1) + D

#move $a0, $s3		#check number -> obtive no papel 0xadcef783
#li $v0, 34
#syscall

#Adicionamos os restantes MA e BOX_0 ao H

jal MA			#get value in $t3
addu $s7, $s7, $t3	#holds value of (H + KW + Ch + BOX_1) + MA

jal BOX_0		#get value in $t6
addu $s7, $s7, $t6	#holds value of (H + KW + Ch + BOX_1 + MA) + BOX_0

#move $a0, $s7		#check number -> obtive no papel 0xe620b22b
#li $v0, 34
#syscall

jal REORDER

#jal NEWBLOCK

addi $t9, $t9, 1	#increment counter

j for

#Print's and exit program
exit_step:

jal print

# Exit Program	
li $v0, 10		
syscall

###############################################################################
######################### Modular Fuctions ####################################
###############################################################################
 
MA:

#la $s0, 0x87564C0C	#A	
#la $s1, 0xF1369725	#B
#la $s2, 0x82E6D493	#C

and $t1, $s0, $s1	#$t1 holds (A and B)
and $t2, $s1, $s2	#$t2 holds (B and C)
and $t3, $s0, $s2	#$t3 holds (A and C)

xor $t2, $t1, $t2	#$t2 holds (A and B) xor (A and C)
xor $t3, $t2, $t3	#$t2 holds ((A and B) xor (A and C)) xor (B and C)

#move $a0, $t3		#check number -> obtive no papel 0x8376d405
#li $v0, 34		
#syscall

jr $ra			#Link function

######################
# "The three values in the *sum* are A rotated rigth by 2 bits, 13 bits and 22 bits"
# "Pretendemos somar os bits das 3 operações, então pretendemos uma operação "xor".!"
BOX_0:

#la $s0, 0x87564C0C	#A

ror $t4, $s0, 2		#$t4 holds A >>> 2
ror $t5, $s0, 13	#$t5 holds A >>> 13
ror $t6, $s0, 22	#$t6 holds A >>> 22

#move $a0, $t4		#check number -> obitve no papel 0x21d59303
#li $v0, 34		
#syscall

#move $a0, $t5		#check number -> obitve no papel 0x60643ab2
#li $v0, 34		
#syscall

#move $a0, $t6		#check number -> obitve no papel 0x5930321d
#li $v0, 34		
#syscall

xor $t5, $t5, $t4	# (A >>> 2) xor (A >>> 13)
xor $t6, $t6, $t5	# ((A >>> 2) xor (A >>> 13)) xor (A >>> 22)

#move $a0, $t5		#check number -> obitve no papel 0x41b1a9b1
#li $v0, 34		
#syscall

#move $a0, $t6		#check number -> obitve no papel 0x18819bac
#li $v0, 34		
#syscall

jr $ra

######################
#"If a bit of E is 0, the output bit is the corresponding bit of G"
#"If a bit of E is 1, the output bit is the corresponding bit of F"
#"In this way, the bits of F and G are shuffled together based on the value of E"
#Desta forma escolhemos o valor do bit de acordo com "0" ou "1", e pegamos o bit equivalente á posição em G ou F
#No final obtemos um novo número que deverá ser: "1110 0000 0001 1101 0010 0110 1111 0111" = 0xe01d26f7
Ch:

#la $s4, 0xDD9EFF54	#E
#la $s5, 0xE07C2655	#F
#la $s6, 0xA41F32E7 	#G

and $t1, $s4, $s5 	#$t1 holds (E and F)
not $t2, $s4		#$t2 holds (Not E)
and $t2, $t2, $s6	#$t2 holds (Not E and G)
	
xor $t3, $t1, $t2	#$t3 holds (E and F) xor (Not E and G)

#move $a0, $t3		#check number -> obitve no papel 0xe01d26f7
#li $v0, 34
#syscall

jr $ra

######################
#"The next box_1 rotates and sums the bits of E, similar to BOX_0 except the shifts are 6, 11, and 25 bits"
BOX_1:

#la $s4, 0xDD9EFF54	#E

ror $t4, $s4, 6		#$t4 holds E >>> 6	-> 0x53767bfd
ror $t5, $s4, 11	#$t5 holds E >>> 11	-> 0xea9bb3df
ror $t6, $s4, 25	#$t6 holds E >>> 25	-> 0xcf7faa6e

#move $a0, $t4		#check number -> obitve no papel 0x53767bfd
#li $v0, 34		
#syscall

#move $a0, $t5		#check number -> obitve no papel 0xea9bb3df
#li $v0, 34		
#syscall

#move $a0, $t6		#check number -> obitve no papel 0xcf7faa6e
#li $v0, 34		
#syscall

xor $t5, $t5, $t4	# (A >>> 6) xor (A >>> 11)	-> 0xb9edc822
xor $t6, $t6, $t5	# ((A >>> 6) xor (A >>> 11)) xor (A >>> 25)	-> 0x7692624c

#move $a0, $t5		#check number -> obitve no papel 0xb9edc822
#li $v0, 34		
#syscall

#move $a0, $t6		#check number -> obitve no papel 0x7692624c
#li $v0, 34		
#syscall

jr $ra

######################
#"The red boxes perform **32-bit addition**, generating new values for A and E. The input Wt is based on the input data, slightly processed."
#"(This is where the input block gets fed into the algorithm.) The input Kt is a constant defined for each round."
# Como o valor de w será sempre o mesmo, já que não existe input para este programa, basta-nos somar os 2 e somar essa quantidade a cada iteração
BOX_KW:

la $a0, 0x6534EA14	#W -> message!
la $a1, 0xC67178F2	#K -> constant
	
addu $a0, $a0, $a1	#$a0 holds W + K = 0x2ba66306
	
#li $v0, 34		#check number -> obitve no papel 0x2ba66306
#syscall
	
jr $ra

######################
# Como vemos na imagem, temos reordenar os valores de A até H
# Para efectuarmos essa operação temos que colocar 1 dos valores em "stand by"
# Temos também que realizar a operação ao contrário para libertar os registos que precisamos
REORDER:

move $t0, $s7		#hold "stand by" value of H
move $s7, $s6
move $s6, $s5
move $s5, $s4
move $s4, $s3
move $s3, $s2
move $s2, $s1
move $s1, $s0
move $s0, $t0		#Place "stand by" value in $s0

jr $ra

######################
#"Um passo disto é mostrado na página a seguir. Uma ‘hash’ total consiste em repetir isso 128 vezes."
#"Caso os primeiros 17 bit do resultado final são todos 0, temos o novo block no blockchain."
# Então o maior número possível é de 1111.1111.1111.1110.0000.0000.0000.0000 = 0xFFFE0000
# Então o número possível é de 0000.0000.0000.0000.0111.1111.1111.1111 = 0x0000EFFF

########################################################################
# Quais são os números que somados a cada termo, obtemos 16 para G e H?
########################################################################
NEWBLOCK:
#la $a3, 0xFFFE0000
#Se qualquer um dos elementos do block fôr maior ou igual a 0xFFFE0000 encontramos um novo block
#bgtu $s0, $a3, exit_step
#bgtu $s1, $a3, exit_step
#bgtu $s2, $a3, exit_step
#bgtu $s3, $a3, exit_step
#bgtu $s4, $a3, exit_step
#bgtu $s5, $a3, exit_step
#bgtu $s6, $a3, exit_step
#bgtu $s7, $a3, exit_step

#bleu $s0, 0x01000000, exit_step
#bleu $s1, 0x01000000, exit_step
#bleu $s2, 0x01000000, exit_step
#bleu $s3, 0x01000000, exit_step
#bleu $s4, 0x01000000, exit_step
#beq  $s5, 0xC4FA9774, exit_step
#bleu $s6, 0x01000000, exit_step
#bleu $s7, 0x01000000, exit_step

jr $ra

print:
######################
#Print Numbers!

la $a0, A
li $v0, 4
syscall

move $a0, $s0
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, B
li $v0, 4
syscall

move $a0, $s1
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, C
li $v0, 4
syscall

move $a0, $s2
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, D
li $v0, 4
syscall

move $a0, $s3
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, E
li $v0, 4
syscall

move $a0, $s4
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, F
li $v0, 4
syscall

move $a0, $s5
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, G
li $v0, 4
syscall

move $a0, $s6
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, H
li $v0, 4
syscall

move $a0, $s7
li $v0, 34			
syscall

jr $ra
