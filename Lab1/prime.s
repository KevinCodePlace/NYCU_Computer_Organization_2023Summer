.data
	input_msg:	.asciiz "Please input a number: "
	prime_msg:	.asciiz "It's a prime\n"
	not_prime_msg:	.asciiz "It's not a prime\n"

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
	move    $a0, $v0      		# store input in $a0 (set argument of procedure prime), a0 = n

# jump to procedure prime
	jal 	prime
	move 	$t0, $v0		# save return value in t0 (because v0 will be used by system call)

# if return value is 1, print "It's a prime", else print "It's not a prime"
	beq	$t0, $zero, NotPrime
	li      $v0, 4			# call system call: print string
	la      $a0, prime_msg		# load address of string into $a0
	syscall                 	# run the syscall
	j	Exit

NotPrime:	
	li      $v0, 4			# call system call: print string
	la      $a0, not_prime_msg	# load address of string into $a0
	syscall                 	# run the syscall
# exit the program
Exit:
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall
	
#------------------------- prime  factorial -----------------------------
# load argument n in $a0, return value in $v0. 
.text
prime:
# Function argument presevation
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)

# Base cases
	beq $a0, 1, ReturnZero
	li $t1, 2

Loop:
	mul $t2, $t1, $t1		# $t2 = i * i 
	bgt $t2, $a0, ReturnOne		# if i * i  > n , return 1 
	rem $t0, $a0, $t1		# rem rd, rs, rt ; rd = rs MOD rt ; $t0 = n % i
	beq $t0, $zero, ReturnZero 	# if n%i ==0, return 0
	addi $t1, $t1, 1		# i = i + 1
	j Loop				

ReturnZero:
	li $v0, 0
	j Return
ReturnOne:
	li $v0, 1

Return:
# Function end
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
