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

la $a0, 0x6534EA14	#W
la $a1, 0xC67178F2	#K
addi $sp, $sp, -12
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($ra)
jal BOX_KW




# Exit Program	
li $v0, 10		
syscall

######################
#"The red boxes perform **32-bit addition**, generating new values for A and E. The input Wt is based on the input data, slightly processed."
#"(This is where the input block gets fed into the algorithm.) The input Kt is a constant defined for each round."
# Como o valor de w será sempre o mesmo, já que não existe input para este programa, basta-nos somar os dois e somar essa quantidade a cada iteração
BOX_KW:

	
addu $a0, $a0, $a1	#$a0 holds sum value
addu $t7, $t7, $a0	#add $a0 value to $t7
	
jr $ra


