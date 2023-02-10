.globl main

.data

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

colorRed:       .word 0x00FF0000
colorYellow:    .word 0x00FFFF00

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
#---------------------------------------------------------------------------------#
###################################################################################
color_pixel:
	sw	$fp, 0($sp)	# push old frame pointer (dynamic link)
	move	$fp, $sp	# frame	pointer now points to the top of the stack
	subu	$sp, $sp, 16	# allocate 16 bytes on the stack (so 4 is left for stack)
	sw	$ra, -4($fp)	# store the value of the return address
	sw	$s0, -8($fp)	# save locally used registers
	sw	$s1, -12($fp)

	move $s0, $a0		# $s0 = red/yellow selector
	move $s1, $a1		# $s1 = pixel
	
        sw $s0, ($s1)		# move modified pixel memory address into pixel 
        
	lw	$s1, -12($fp)	# reset saved register $s1
	lw	$s0, -8($fp)	# reset saved register $s0
	lw	$ra, -4($fp)    # get return address from frame
	move	$sp, $fp        # get old frame pointer from current fra
	lw	$fp, ($sp)	# restore old frame pointer
	jr	$ra 

###################################################################################

main:
              
    lw $t4, colorRed	   # load color into variable
    lw $t5, colorYellow    # load color into variable
 
    lw $t2, amountOfColumns	#load amountOfColumns into $t2
    
    li $t9, 0		   # counter for color_screen
    
    fill_loop:
    	li $t8, 1			# load int 1 to var $t8
    	addi $t7, $t7, 1
    	fill_screen:
            move $a0, $t7		# put row in var for procedure (x)
            move $a1, $t8		# put col in var for procedure (y)
            move $a2, $t2		# put width in var for procedure
    	    jal translate_coordinates	# call procedure
    	
    	    move $t0, $v0		# get procedure result
    	    
    	    move $a0, $t4		# put red in var for procedure
    	    move $a1, $t0		# put pixel in var for procedure
    	    jal color_pixel 		# run color_pixel procedure
    	    beq $t7, 448, decider	# stop at the second to last line
    	    j fill_loop			# run loop
    
    decider:
        beq $t9, 0, top_screen		# if counter is zero, go to top_screen
        beq $t9, 32, bot_screen		# if counter is 32, go to bot_screen
        beq $t9, 64, left_screen	# if counter is 64, go to left_screen
        beq $t9, 80, right_screen	# if counter is 80, go to right_screen
        beq $t9, 96, exit		# if counter is 96, go to exit
    	top_screen:
    	    li $t8, 0			# load in 0 for row
    	    li $t7, 0			# load in 0 for col
    	    j screen_loop		# jump to screen_loop to color in top border
    	bot_screen:
    	    li $t8, 15			# load in 15 for row
    	    li $t7, 0			# load in 0 for col
    	    j screen_loop		# jump to screen_loop to color in bottom border
    	left_screen:
    	    li $t7, 0			# load in 0 for col
    	    li $t8, 1			# load in 1 for row
    	    j screen_loop		# jump to screen_loop to color in left border
    	right_screen:
    	    li $t7, 31			# load in 31 for col
    	    li $t8, 1			# load in 1 for row
    	    j screen_loop  		# jump to screen_loop to color in right border
          
    color_screen:
    	screen_loop:
    	move $a0, $t7			# put col in var for procedure (x)
        move $a1, $t8			# put row in var for procedure (y)
        move $a2, $t2			# put width in var for procedure
    	jal translate_coordinates	# call procedure
    	
    	move $t0, $v0			# get procedure result
    	    
    	move $a0, $t5			# put yellow in var for procedure
    	move $a1, $t0			# put pixel in var for procedure
    	jal color_pixel 		# run color_pixel procedure
    	addi $t9, $t9, 1		# add 1 to counter for decider
    	ble $t9, 64, jump_hor		# if counter <= 64 do horizontal coloring
    	addi $t8, $t8, 1		# when doing vertical coloring add 1 to row so it colors downwards
    	j end_ver			# jump to end_ver to skip adding 1 to column (so it doesn't color horizontally/diagonally)
    	jump_hor:			
    	addi $t7, $t7, 1
    	end_ver:
    	beq $t9, 32, decider		# if counter equal to 32 jump to decider (horizontal)
    	beq $t9, 64, decider		# if counter equal to 64 jump to decider (horizontal)
    	beq $t9, 80, decider		# if counter equal to 80 jump to decider (vertical)
    	beq $t9, 96, decider		# if counter equal to 96 jump to decider (vertical)
    	j screen_loop
	 	    	
exit:
    # syscall to end the program
    li $v0, 10    
    syscall
