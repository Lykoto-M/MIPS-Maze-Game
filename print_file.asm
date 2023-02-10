 .globl main

.data
filename1: .asciiz "test_file_1.txt"
filename2: .asciiz "test_file_2.txt"
content: .space 2048

.text

main:
     # open file for reading
     li $v0, 13
     la $a0, filename1
     li $a1, 0
     li $a2, 0
     syscall
     
     move $s6, $v0
     
     # read from file to content
     li $v0, 14
     move $a0, $s6	
     la $a1, content
     li $a2, 2048
     syscall
     
     # print content to terminal
     li $v0, 4
     la $a0, content
     syscall
    
     #close file
     li $v0, 16
     move $a0, $s6
     syscall

exit:
    # syscall to end the program
    li $v0, 10    
    syscall
