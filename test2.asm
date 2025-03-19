# Temporários têm os valores do block
# Valores para conferir o block estão na stack

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
newblock: .asciiz "We have found a new block =)"
no_newblock: .asciiz "We haven´t found a new block =("

.text
main:
# Load block values
# Estes são os valores do block inicial
la $t0, 0x87564C0C	#A
la $t1, 0xF1369725	#B
la $t2, 0x82E6D493	#C
la $t3, 0x63A6B509	#D
la $t4, 0xDD9EFF54	#E
la $t5, 0xE07C2655	#F
la $t6, 0xA41F32E7 	#G
la $t7, 0xC7D25631	#H

jal modular_round

jal modular_round

exit_step:

jal print		#Print values

# Exit Program	
li $v0, 10		
syscall

###############################################################################
######################### Modular Fuctions ####################################
###############################################################################

######################
# Modular Round Function
modular_round:

# counters round_for_loop
#addi $t8, $t8, 1	#test 1st step
addi $t8, $t8, 64	#64 into $t8 -> round counter

jal round		#value of output_1 diferent than zero, continue!
continue:

mul $t9, $t9, 0		#reset round counter

jal RELOAD		#Load output_1 values into $t's registers

jr $ra

######################
# Round 64x function
round:
beq $t8, $t9, continue	#condition for_loop

jal BOX_KW		#adds value to $t7

jal Ch			#adds value to $t7

jal SUM_1		#adds value to $t7

addu $t3, $t3, $t7	#$t3 holds value of (H + KW + Ch + SUM_1) + D = new D

jal MA			#adds value to $t7

jal SUM_0		#adds value to $t7

jal REORDER

beq $t9, 0, SAVEVALUES
next_step:
beq $t9, 63, ADDVALUES
next_step_two:

addi $t9, $t9, 1	#increment counter

j round

jr $ra

######################
# "For each position, if the majority of the bits are 0, it outputs 0. Otherwise it outputs 1."
# "That is, for each position in A, B, and C, look at the number of 1 bits. If it is zero or one, output 0. If it is two or three, output 1."
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
# "Pretendemos somar os bits das 3 operações, então pretendemos uma operação "xor".!"
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
#Desta forma escolhemos o valor do bit de acordo com "0" ou "1", e pegamos o bit equivalente á posição em G ou F
#No final obtemos um novo número que deverá ser: "1110 0000 0001 1101 0010 0110 1111 0111" = 0xe01d26f7
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
# Como o valor de w será sempre o mesmo, já que não existe input para este programa, basta-nos somar os dois e somar essa quantidade a cada iteração
BOX_KW:

la $a0, 0x6534EA14	#W
la $a1, 0xC67178F2	#K -> constant
	
addu $a0, $a0, $a1	#$a0 holds W + K = 0x2ba66306
addu $t7, $t7, $a0
	
jr $ra

######################
# Como vemos na imagem, temos reordenar os valores de A até H
# Para efectuarmos essa operação temos que colocar 1 dos valores em "stand by"
# Temos também que realizar a operação ao contrário para libertar os registos que precisamos
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
NEWBLOCK:

la $a0, newblock
li $v0, 4
syscall

j exit_step

######################
# Caso não encontremos nada..
NO_NEWBLOCK:

la $a0, no_newblock
li $v0, 4
syscall

j exit_step

######################
#Print Numbers!
print:

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

######################
#1st Round Value -> STACK
SAVEVALUES:

move $s0, $t0
move $s1, $t1
move $s2, $t2
move $s3, $t3
move $s4, $t4
move $s5, $t5
move $s6, $t6
move $s7, $t7

j next_step

######################
#64th Round values + 1st Round Value = Output_1
ADDVALUES:

addu $s0, $s0, $t0
addu $s1, $s1, $t1
addu $s2, $s2, $t2
addu $s3, $s3, $t3
addu $s4, $s4, $t4
addu $s5, $s5, $t5
addu $s6, $s6, $t6
addu $s7, $s7, $t7

beqz $s0, NEWBLOCK
beqz $s1, NEWBLOCK
beqz $s2, NEWBLOCK
beqz $s3, NEWBLOCK
beqz $s4, NEWBLOCK
beqz $s5, NEWBLOCK
beqz $s6, NEWBLOCK
beqz $s7, NEWBLOCK

j next_step_two

RELOAD:
move $t0, $s0
move $t1, $s1
move $t2, $s2
move $t3, $s3
move $t4, $s4
move $t5, $s5
move $t6, $s6
move $t7, $s7

jr $ra
