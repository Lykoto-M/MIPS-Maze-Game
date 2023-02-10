 .globl main

.data

enterChar: .asciiz "Please enter a character:\n"
directions: .asciiz "up\n", "down\n", "left\n", "right\n"
invalidInput: .asciiz "Unknown input! Valid inputs: z s q d x\n"
.text 

main:
j delay

delay:
    li $a0, 2000
    li $v0, 32
    syscall
    la	$t0, 0xffff0000
    lw	$t1, ($t0)
    beq	$t1, 1, check_input
    
no_input:
    la $a0, enterChar
    li $v0, 4
    syscall
    j delay
    
check_input:
    la $t0, 0xffff0004		# load keyboard input
    lw $t1, ($t0)
    beq	$t1, 122, inputZ	# if keyboard input = 122 -> jump to inputZ
    beq	$t1, 113, inputQ	# if keyboard input = 113 -> jump to inputQ
    beq	$t1, 115, inputS	# if keyboard input = 115 -> jump to inputS
    beq	$t1, 100, inputD	# if keyboard input = 100 -> jump to inputD
    beq $t1, 120, exit 		# if keyboard input = 120 -> jump to exit
    
    la $a0, invalidInput
    li $v0, 4
    syscall
    j delay

inputZ:
    la $a0, directions+0
    li $v0, 4
    syscall
    j delay
inputQ:
    la $a0, directions+4
    li $v0, 4
    syscall
    j delay
inputS:
    la $a0, directions+10
    li $v0, 4
    syscall
    j delay
inputD:
    la $a0, directions+16
    li $v0, 4
    syscall
    j delay

exit:
    # syscall to end the program
    li $v0, 10    
    syscall
