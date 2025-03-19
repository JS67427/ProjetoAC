#67427 Jorge Manuel Mirador Silva
#15488 Vasco Rafael Saraiva de Sousa

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
la $t0, 0x87564C0C	#A
la $t1, 0xF1369725	#B
la $t2, 0x82E6D493	#C
la $t3, 0x63A6B509	#D
la $t4, 0xDD9EFF54	#E
la $t5, 0xE07C2655	#F
la $t6, 0xA41F32E7 	#G
la $t7, 0xC7D25631	#H

# counters for_loop
addi $t8, $t8, 1	#test 1st step
#addi $t8, $t8, 128	#128x

for:
beq $t8, $t9, exit_step	#condition for_loop

addi $sp, $sp, -36	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)
sw $t4, 24($sp)
sw $t5, 28($sp)
sw $t6, 32($sp)

jal BOX_KW		#adds value to $t7

lw $t6, 32($sp)		#Pop from stack
lw $t5, 28($sp)
lw $t4, 24($sp)
lw $t3, 20($sp)
lw $t2, 16($sp)
lw $t1, 12($sp)
lw $t0, 8($sp)
sw $t8, 4($sp)
sw $t9, 0($sp)
addi $sp, $sp 36

addi $sp, $sp, -20	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)

jal Ch			#adds value to $t7

lw $t3, 20($sp)		#Pop from stack
lw $t2, 16($sp)
lw $t1, 12($sp)
lw $t0, 8($sp)
lw $t8, 4($sp)
lw $t9, 0($sp)
addi $sp, $sp 20

addi $sp, $sp, -32	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)
sw $t5, 24($sp)
sw $t6, 28($sp)

jal SUM_1		#adds value to $t7

lw $t6, 28($sp)		#Pop from stack
lw $t5, 24($sp)
lw $t3, 20($sp)
lw $t2, 16($sp)
lw $t1, 12($sp)
lw $t0, 8($sp)
lw $t8, 4($sp)
lw $t9, 0($sp)
addi $sp, $sp 32

addu $t3, $t3, $t7	#$t3 holds value of (H + KW + Ch + SUM_1) + D = new D

addi $sp, $sp, -20	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t3, 8($sp)
sw $t4, 12($sp)
sw $t5, 16($sp)
sw $t6, 20($sp)

jal MA			#adds value to $t7

lw $t6, 20($sp)		#Pop from stack
lw $t5, 16($sp)
lw $t4, 12($sp)
lw $t3, 8($sp)
lw $t8, 4($sp)
lw $t9, 0($sp)
addi $sp, $sp, 20

addi $sp, $sp, -32	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t1, 8($sp)
sw $t2, 12($sp)
sw $t3, 16($sp)
sw $t4, 20($sp)
sw $t5, 24($sp)
sw $t6, 28($sp)

jal SUM_0		#adds value to $t7

lw $t6, 28($sp)		#Pop from stack
lw $t5, 24($sp)
lw $t4, 20($sp)
lw $t3, 16($sp)
lw $t2, 12($sp)
lw $t1, 8($sp)
lw $t8, 4($sp)
lw $t9, 0($sp)
addi $sp, $sp, 32

jal REORDER		#re-position registers

addi $sp, $sp, -28	#Push into stack
sw $t9, 0($sp)
sw $t8, 4($sp)
sw $t0, 8($sp)
sw $t1, 12($sp)
sw $t2, 16($sp)
sw $t3, 20($sp)
sw $t4, 24($sp)

jal VERIFICATION	#Verify if we found a newblock

lw $t4, 24($sp)		#Pop from stack
lw $t3, 20($sp)
lw $t2, 16($sp)
lw $t1, 12($sp)
lw $t0, 8($sp)
sw $t8, 4($sp)
sw $t9, 0($sp)
addi $sp, $sp 28

addi $t9, $t9, 1	#increment counter

j for

exit_step:

jal print		#Print values

# Exit Program	
li $v0, 10		
syscall

###############################################################################
######################### Modular Fuctions ####################################
###############################################################################

######################
#1000.0111.0101.0110.0100.1100.0000.1100 -> A
#1111.0001.0011.0110.1001.0111.0010.0101 -> B
#1000.0001.0001.0110.0000.0100.0000.0100 -> Result A AND B
#Realizamos o mesmo: B AND C; A AND C
#Posteriormente temos que somar os resultados das operações utilizando XOR
#Finalmente adicionamos o resultado a H
MA:

#la $t0, 0x87564C0C	#A
#la $t1, 0xF1369725	#B
#la $t2, 0x82E6D493	#C

and $a0, $t0, $t1	#$t1 holds (A and B)
and $a1, $t1, $t2	#$t2 holds (B and C)
and $a2, $t0, $t2	#$t3 holds (A and C)

xor $a3, $a0, $a2	#$t2 holds (A and B) xor (A and C)
xor $a3, $a3, $a1	#$t2 holds ((A and B) xor (A and C)) xor (B and C)

addu $t7, $t7, $a3	#Add result to H

jr $ra			

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
#Temos que realizar então as operações: E and F ; NOT E e finalmente NOT E and G para seleccionarmos os bits que queremos.
#Finalmente, somamos tudo através da operação (E and F) xor (Not E and G).
Ch:

#la $t4, 0xDD9EFF54	#E
#la $t5, 0xE07C2655	#F
#la $t6, 0xA41F32E7 	#G

and $a0, $t4, $t5 	#$a0 holds (E and F)
not $a1, $t4		#$a1 holds (Not E)
and $a2, $a1, $t6	#$a2 holds (Not E and G)
	
xor $a3, $a0, $a2	#$a3 holds (E and F) xor (Not E and G)
addu $t7, $t7, $a3	#Add previous value in $t7 (H) with Ch operation 

jr $ra

######################
#"The next SUM_1 rotates and sums the bits of E, similar to SUM_0 except the shifts are 6, 11, and 25 bits"
SUM_1:

#la $t4, 0xDD9EFF54	#E

ror $a0, $t4, 6		#$t4 holds E >>> 6
ror $a1, $t4, 11	#$t5 holds E >>> 11
ror $a2, $t4, 25	#$t6 holds E >>> 25

xor $a3, $a0, $a1	# (A >>> 6) xor (A >>> 11)
xor $a3, $a3, $a2	# ((A >>> 6) xor (A >>> 11)) xor (A >>> 25)

addu $t7, $t7, $a3	#Add to $t7 (H)

jr $ra

######################
#"The red boxes perform **32-bit addition**, generating new values for A and E. The input Wt is based on the input data, slightly processed."
#"(This is where the input block gets fed into the algorithm.) The input Kt is a constant defined for each round."
# Basta-nos somar estes dois valores de W e K e adicionar a H
BOX_KW:

la $a0, 0x6534EA14	#W
la $a1, 0xC67178F2	#K
	
addu $a0, $a0, $a1	#$a0 holds sum value
addu $t7, $t7, $a0	#add $a0 value to $t7 (H)
	
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
# 1101.1101.1001.1110.1111.1111.0101.0100 = 0xDD9EFF54 por exemplo
# 0000.0000.0000.0000.0000.0000.0000.0001 = 0x00000001 Se fizermos uma operação AND, verificamos se o valor final é 0 ou 1.
# 0000.0000.0000.0000.0000.0000.0000.0000 = 0x00000000 Observamos então, que neste caso o ultimo bit é zero (corresponde ao 17bit)
# Assim temos uma forma de verificar se apenas o ultimo bit é zero!
VERIFICATION:

and $a0, $t5, 0x00000001	
beqz $a0, continue	#If $a0 fôr zero, continua a verificação!
continue:
beqz $t6, continue_2	#If $t6 fôr zero, continua verificação!
continue_2:
beqz $t7, exit_step	#If $t7 is zero, goto exit_step! Se falso, retorna ao main e continua.
			
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
