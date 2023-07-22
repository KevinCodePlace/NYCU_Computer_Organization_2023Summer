.data
	input_msg:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
	first_num_msg:	.asciiz "Please enter the first number: "
	second_num_msg:	.asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a0 (set arugument of operand)
	
# print first_num_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, first_num_msg	# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2 (set first num)
	
# print second_num_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, second_num_msg	# load address of string into $a0
	syscall                 	# run the syscall

# read the second integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a3, $v0      		# store input in $a3 (set second num)

# jump to procedure calculator
	jal 	calculator
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 
	
# print output_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	move 	$a0, $t0			
	li 	$v0, 1				
	syscall 

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure calculator-----------------------------
# load operand in $a1, first num in $a2, second num in $a3, return value in $v0. 
.text
calculator:	
	addi 	$sp, $sp, -16			# adjust stack for 4 items
	sw 	$ra, 12($sp)			# save the return address
	sw 	$a3, 8($sp)			# save the argument a3(second num)
	sw 	$a2, 4($sp)			# save the argument a2(first num)
	sw 	$a1, 0($sp)			# save the argument a1(operand)
	beq	$a1, 1, addfunc
	beq	$a1, 2, subfunc
	beq	$a1, 3, mulfunc
addfunc:
	add	$v0, $a2, $a3
	j 	Return
subfunc:
	sub	$v0, $a2, $a3
	j	Return
mulfunc:
	mul	$v0, $a2, $a3
	j	Return
Return:
	lw 	$ra,12($sp)
	addi	$sp, $sp, 16
	jr	$ra
