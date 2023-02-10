 .globl main

.data
mazeFilename:    .asciiz "input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"
invalidPosMessage: .asciiz "A wall is blocking your passage!\n"
enterChar: .asciiz "Please enter a character:\n"
invalidInput: .asciiz "Unknown input! Valid inputs: z s q d x\n"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

playerX: .word 0
playerY: .word 0

.text
#################################################################################
translate_coordinates:
	sw $fp, 0($sp)	# push old frame pointer (dynamic link)
	move $fp, $sp	# frame	pointer now points to the top of the stack
	subu $sp, $sp, 20	# allocate 20 bytes on the stack
	sw $ra, -4($fp)	# store the value of the return address
	sw $s0, -8($fp)	# save locally used registers
	sw $s1, -12($fp)
	sw $s2, -16($fp)

	move $s0, $a0		# $s0 = x coordinate
	move $s1, $a1		# $s1 = y coordinate
	move $s2, $a2		# $s2 = width for calculations
	
	mult $s1, $s2		# multiply y by width
	mflo $t0
	
	addu $t0, $t0, $s0	# (y * 32) + x = index of pixel
	
	sll $t0, $t0, 2		# multiply by 4
	
	addu $t0, $gp, $t0	# memory address = gp + offset
	
	move $v0, $t0    	# place result in return value location
	
	lw $s2, -16($fp)	# reset saved register $s2
	lw $s1, -12($fp)	# reset saved register $s1
	lw $s0, -8($fp)	# reset saved register $s0
	lw $ra, -4($fp)    # get return address from frame
	move $sp, $fp        # get old frame pointer from current fra
	lw $fp, ($sp)	# restore old frame pointer
	jr $ra 
#################################################################################
color_pixel:
	sw $fp, 0($sp)	# push old frame pointer (dynamic link)
	move $fp, $sp	# frame	pointer now points to the top of the stack
	subu $sp, $sp, 16	# allocate 16 bytes on the stack (so 4 is left for stack)
	sw $ra, -4($fp)	# store the value of the return address
	sw $s0, -8($fp)	# save locally used registers
	sw $s1, -12($fp)

	move $s0, $a0		# $s0 = color selector
	move $s1, $a1		# $s1 = pixel
	
        sw $s0, ($s1)		# move modified pixel memory address into pixel 
        
	lw $s1, -12($fp)	# reset saved register $s1
	lw $s0, -8($fp)		# reset saved register $s0
	lw $ra, -4($fp)		# get return address from frame
	move $sp, $fp        	# get old frame pointer from current frame
	lw $fp, ($sp)		# restore old frame pointer
	jr $ra 
#################################################################################

main:
#################################################################################
bitmap_display:
    # Initialize the stack frame
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $t3, 8($sp)
    sw $t4, 12($sp)
    sw $t5, 16($sp)
    sw $t6, 20($sp)
    sw $t8, 24($sp)
    sw $v0, 28($sp)

    li $t3, 0
    li $t4, 0

    # Open the file in read-only mode
    li $v0, 13          # system call code for open()
    la $a0, mazeFilename    # load address of filename into $a0
    li $a1, 0           # read-only mode
    li $a2, 0           # use default permissions
    syscall             # call open()
    move $s0, $v0       # save the file descriptor in $s0

    # Read the file character by character
    read:
        li $v0, 14      # system call code for read()
        move $a0, $s0   # file descriptor
        la $a1, buffer  # address of buffer to read into
        li $a2, 1       # read 1 byte at a time
        syscall         # call read()

        # Check if we have reached the end of the file
        beq $v0, 0, close   # if read() returned zero, go to close

        # color picker
        lb $a0, buffer  # load character from buffer
        move $t1, $a0
        beq $t1, 119, blue
        beq $t1, 112, black
        beq $t1, 115, yellow
        beq $t1, 117, green
        beq $t1, 10, newline
        blue:
            lw $t2, wallColor
            j get_coords
        black:
            lw $t2, passageColor
            j get_coords
        yellow:
            lw $t2, playerColor
            # Save the player's x and y coordinates
            sw $t3, playerX
            sw $t4, playerY
            j get_coords
        green:
            lw $t2, exitColor
            j get_coords
        newline:
            li $t3, 0
            addi $t4, $t4, 1
            j skip_newline

        get_coords:
            lw $t8, amountOfColumns
            move $a0, $t3
            move $a1, $t4
            move $a2, $t8
            jal translate_coordinates
            move $t0, $v0
            addi $t3, $t3, 1
        color_pixel_color:
            move $a0, $t2
            move $a1, $t0
            jal color_pixel
        # Repeat until end of file
        skip_newline:
        j read           # go back to read

    close:
        li $v0, 16      # system call code for close()
        move $a0, $s0   # file descriptor
        syscall         # call close

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $t3, 8($sp)
    lw $t4, 12($sp)
    lw $t5, 16($sp)
    lw $t6, 20($sp)
    lw $t8, 24($sp)
    lw $v0, 28($sp)
    addi $sp, $sp, 32
########################################################################
delay:
    li $a0, 60
    li $v0, 32
    syscall
    la	$t0, 0xffff0000
    lw	$t1, ($t0)
    beq	$t1, 1, check_input
    
no_input:
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
    lw $t3, playerX		# 15 at start
    lw $t4, playerY		# 12 at start
    subi $t4, $t4, 1
    j move_player
inputQ:
    lw $t3, playerX
    lw $t4, playerY
    subi $t3, $t3, 1
    j move_player
inputS:
    lw $t3, playerX
    lw $t4, playerY
    addi $t4, $t4, 1
    j move_player
inputD:
    lw $t3, playerX
    lw $t4, playerY
    addi $t3, $t3, 1
    j move_player
########################################################################
move_player:
  valid_check:
    lw $t8, amountOfColumns
    move $a0, $t3
    move $a1, $t4
    move $a2, $t8
    jal translate_coordinates
    move $a1, $v0
    lw $t6, 0($a1)
    beq $t6, 0x004286F4, invalid_pos
    beq $t6, 0x00000000, valid_pos
    beq $t6, 0x0000FF00, victory    
  valid_pos:
    lw $t5, playerColor
    move $a0, $t5
    jal color_pixel
    lw $a0, playerX
    lw $a1, playerY
    lw $t8, amountOfColumns
    move $a2, $t8
    jal translate_coordinates
    move $a1, $v0
    lw $t5, passageColor
    move $a0, $t5
    jal color_pixel
    sw $t3, playerX
    sw $t4, playerY
    j delay
  invalid_pos:
    lw $t3, playerX
    lw $t4, playerY
    li $v0, 4
    la $a0, invalidPosMessage
    syscall
    j delay
  victory:
    lw $t5, playerColor
    move $a0, $t5
    jal color_pixel
    lw $a0, playerX
    lw $a1, playerY
    lw $t8, amountOfColumns
    move $a2, $t8
    jal translate_coordinates
    move $a1, $v0
    lw $t5, passageColor
    move $a0, $t5
    jal color_pixel
    sw $t3, playerX
    sw $t4, playerY
    li $v0, 4
    la $a0, victoryMessage
    syscall
    j exit
exit:
    # syscall to end the program
    li $v0, 10    
    syscall
