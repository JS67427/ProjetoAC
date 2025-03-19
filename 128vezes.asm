# Tempor�rios t�m os valores do block
# Valores para conferir o block est�o na stack

.data
newline: .asciiz "\n"
A:.asciiz "A = "
B:.asciiz "B = "
C:.asciiz "C = "
D:.asciiz "D = "
E:.asciiz "E = "
F:.asciiz "F = "
G:.asciiz "G = "
H:.asciiz "H = "

.text
main:
# Load block values
# Estes s�o os valores do block inicial
la $t0, 0x87564C0C	#A
la $t1, 0xF1369725	#B
la $t2, 0x82E6D493	#C
la $t3, 0x63A6B509	#D
la $t4, 0xDD9EFF54	#E
la $t5, 0xE07C2655	#F
la $t6, 0xA41F32E7 	#G
la $t7, 0xC7D25631	#H

# Load default values
# Estes ser�o utilizados para verificar se obtivemos um novo block ap�s o algoritmo hash-256
la $s0, 0x6a09e667
la $s1, 0xbb67ae85
la $s2, 0x3c6ef372
la $s3, 0xa54ff53a
la $s4, 0x510e527f
la $s5, 0x9b05688c
la $s6, 0x1f83d9ab
la $s7, 0x5be0cd19

# counters for_loop
#addi $t8, $t8, 1	#test 1st step
addi $t8, $t8, 128	#128 into $t8

for:
beq $t8, $t9, exit_step	#condition for_loop

jal BOX_KW		#adds value to $t7

jal Ch			#adds value to $t7

jal SUM_1		#adds value to $t7

addu $t3, $t3, $t7	#$t3 holds value of (H + KW + Ch + SUM_1) + D = new D

jal MA			#adds value to $t7

jal SUM_0		#adds value to $t7

jal REORDER

addi $t9, $t9, 1	#increment counter

#jal SUM_NSA

#jal VERIFICATION

j for

exit_step:

jal print		#Print values

# Exit Program	
li $v0, 10		
syscall

###############################################################################
######################### Modular Fuctions ####################################
###############################################################################
 
MA:

#la $t0, 0x87564C0C	#A
#la $t1, 0xF1369725	#B
#la $t2, 0x82E6D493	#C

and $a0, $t0, $t1	#$t1 holds (A and B)
and $a1, $t1, $t2	#$t2 holds (B and C)
and $a2, $t0, $t2	#$t3 holds (A and C)

xor $a3, $a0, $a2	#$t2 holds (A and B) xor (A and C)
xor $a3, $a3, $a1	#$t2 holds ((A and B) xor (A and C)) xor (B and C)

addu $t7, $t7, $a3

jr $ra			#Link function

######################
# "The three values in the *sum* are A rotated rigth by 2 bits, 13 bits and 22 bits"
# "Pretendemos somar os bits das 3 opera��es, ent�o pretendemos uma opera��o "xor".!"
SUM_0:

#la $t0, 0x87564C0C	#A

ror $a0, $t0, 2		#$t4 holds A >>> 2
ror $a1, $t0, 13	#$t5 holds A >>> 13
ror $a2, $t0, 22	#$t6 holds A >>> 22

xor $a3, $a0, $a1	# (A >>> 2) xor (A >>> 13)
xor $a3, $a3, $a2	# ((A >>> 2) xor (A >>> 13)) xor (A >>> 22)

addu $t7, $t7, $a3

jr $ra

######################
#"If a bit of E is 0, the output bit is the corresponding bit of G"
#"If a bit of E is 1, the output bit is the corresponding bit of F"
#"In this way, the bits of F and G are shuffled together based on the value of E"
#Desta forma escolhemos o valor do bit de acordo com "0" ou "1", e pegamos o bit equivalente � posi��o em G ou F
#No final obtemos um novo n�mero que dever� ser: "1110 0000 0001 1101 0010 0110 1111 0111" = 0xe01d26f7
Ch:

#la $t4, 0xDD9EFF54	#E
#la $t5, 0xE07C2655	#F
#la $t6, 0xA41F32E7 	#G

and $a0, $t4, $t5 	#$a0 holds (E and F)
not $a1, $t4		#$a1 holds (Not E)
and $a2, $a1, $t6	#$a2 holds (Not E and G)
	
xor $a3, $a0, $a2	#$a3 holds (E and F) xor (Not E and G)
addu $t7, $t7, $a3	#Add previous value in $t7 with Ch operation

jr $ra

######################
#"The next box_1 rotates and sums the bits of E, similar to SUM_0 except the shifts are 6, 11, and 25 bits"
SUM_1:

#la $t4, 0xDD9EFF54	#E

ror $a0, $t4, 6		#$t4 holds E >>> 6	-> 0x53767bfd
ror $a1, $t4, 11	#$t5 holds E >>> 11	-> 0xea9bb3df
ror $a2, $t4, 25	#$t6 holds E >>> 25	-> 0xcf7faa6e

xor $a3, $a0, $a1	# (A >>> 6) xor (A >>> 11)	-> 0xb9edc822
xor $a3, $a3, $a2	# ((A >>> 6) xor (A >>> 11)) xor (A >>> 25)	-> 0x7692624c

addu $t7, $t7, $a3

jr $ra

######################
#"The red boxes perform **32-bit addition**, generating new values for A and E. The input Wt is based on the input data, slightly processed."
#"(This is where the input block gets fed into the algorithm.) The input Kt is a constant defined for each round."
# Como o valor de w ser� sempre o mesmo, j� que n�o existe input para este programa, basta-nos somar os dois e somar essa quantidade a cada itera��o
BOX_KW:

la $a0, 0x6534EA14	#W
la $a1, 0xC67178F2	#K -> constant
	
addu $a0, $a0, $a1	#$a0 holds W + K = 0x2ba66306
addu $t7, $t7, $a0	#$t7 holds sum $t7 + (W + K)
	
jr $ra

######################
# Como vemos na imagem, temos reordenar os valores de A at� H
# Para efectuarmos essa opera��o temos que colocar 1 dos valores em "stand by"
# Temos tamb�m que realizar a opera��o ao contr�rio para libertar os registos que precisamos
REORDER:

move $a0, $t7		#hold in $a0 "stand by" value of H
move $t7, $t6
move $t6, $t5
move $t5, $t4
move $t4, $t3
move $t3, $t2
move $t2, $t1
move $t1, $t0
move $t0, $a0		#Place in $t0 "stand by"

jr $ra

######################
# Como observamos atrav�s do calculo feito na folha quadriculada em anexo, percebemos que existe um valor default que temos que adicionar
# a cada valor calculado atrav�s do algoritmo, e temos que verificar se esse valor final, possui 17bits zero.
NEWBLOCK:

jr $ra

######################
#Print Numbers!
print:

la $a0, A
li $v0, 4
syscall

move $a0, $t0
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, B
li $v0, 4
syscall

move $a0, $t1
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, C
li $v0, 4
syscall

move $a0, $t2
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, D
li $v0, 4
syscall

move $a0, $t3
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, E
li $v0, 4
syscall

move $a0, $t4
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, F
li $v0, 4
syscall

move $a0, $t5
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, G
li $v0, 4
syscall

move $a0, $t6
li $v0, 34			
syscall

la $a0, newline
li $v0, 4
syscall	

la $a0, H
li $v0, 4
syscall

move $a0, $t7
li $v0, 34			
syscall

jr $ra

######################
VERIFICATION:

addu $t0, $s0, $t0
addu $t1, $s1, $t1
addu $t2, $s2, $t2
addu $t3, $s3, $t3
addu $t4, $s4, $t4
addu $t5, $s5, $t5
addu $t6, $s6, $t6
addu $t7, $s7, $t7

beqz $t0, exit_step
beqz $t1, exit_step
beqz $t2, exit_step
beqz $t3, exit_step
beqz $t4, exit_step
beqz $t5, exit_step
beqz $t6, exit_step
beqz $t7, exit_step

jr $ra

######################
SUM_NSA:

addu $t0, $s0, $t0
addu $t1, $s1, $t1
addu $t2, $s2, $t2
addu $t3, $s3, $t3
addu $t4, $s4, $t4
addu $t5, $s5, $t5
addu $t6, $s6, $t6
addu $t7, $s7, $t7

jr $ra
