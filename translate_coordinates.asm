.globl main

.data

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

promptRows: .asciiz "Please enter the row number:\n"
promptCols: .asciiz "Please enter the column number:\n"

msgShowMemoryAddress: .asciiz "The memory address for the pixel is:\n"
msgErrorValues:	.asciiz "The entered value for row/column is invalid, please enter a valid value:\n"

.text
###################################################################################
translate_coordinates:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 20	# allocate 20 bytes on the stack
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)
	sw	$s2, -16($fp)

	move $s0, $a0		# $s0 = x coordinate
	move $s1, $a1		# $s1 = y coordinate
	move $s2, $a2		# $s2 = width for calculations
	
	mult $s1, $s2		# multiply y by width
	mflo $t0
	
	addu $t0, $t0, $s0	# (y * 32) + x = index of pixel
	
	sll $t0, $t0, 2		# multiply by 4
	
	addu $t0, $gp, $t0	# memory address = gp + offset
	
	move	$v0, $t0    	# place result in return value location
	
	lw	$s2, -16($fp)	# reset saved register $s2
	lw	$s1, -12($fp)	# reset saved register $s1
	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra 
	
###################################################################################	
main:

    li $v0, 4		# print string
    la $a0, promptRows  # message to ask the user for the row number
    syscall
    
    li $v0, 5  # read integer
    syscall    # ask the user for a row number
    move $t0, $v0
    
    li $v0, 4		# print string
    la $a0, promptCols  # message to ask the user for the collumn number
    syscall
    
    li $v0, 5  # read integer
    syscall    # ask the user for a collumn number
    move $t1, $v0
    
    lw $t2, amountOfColumns	#load amountOfColumns into $t2
    
    move	$a0, $t0	# Put row in var for procedure (x)
    move	$a1, $t1	# Put col in var for procedure (y)
    move	$a2, $t2	# Put width in var for procedure
    jal		translate_coordinates	# Call procedure
	
    move 	$t0, $v0	# Get procedure result
    
    li $v0, 4
    la $a0, msgShowMemoryAddress
    syscall
    		
    move	$a0, $t0
    li	 	$v0, 1		# syscall code 1 is for print_int
    syscall

exit:

    li $v0, 10  # syscall to end the program
    syscall
