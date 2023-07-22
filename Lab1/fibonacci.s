.data
input_msg: .asciiz "Please input a number: "
result_msg: .asciiz "The result of fibonacci(n) is "

.text
.globl main
main:
    # Print the input message
    li      $v0, 4
    la      $a0, input_msg
    syscall

    # Read the number
    li      $v0, 5
    syscall
    move    $s0, $v0  # Store the number in $s0

    # Call fibonacci function
    move    $a0, $s0
    jal     fibonacci
    move    $t0, $v0  # Store the result in $t0

    # Print the result message
    li      $v0, 4
    la      $a0, result_msg
    syscall

    # Print the result
    li      $v0, 1
    move    $a0, $t0
    syscall

    # Terminate the program
    li      $v0, 10
    syscall

fibonacci:
    # If n is 0 or 1, return n
    beq     $a0, $zero, base_case	# n == 0
    bne     $a0, 1, recursive_case	# n != 1 -> jump to recursive_case
base_case:
    move    $v0, $a0
    jr      $ra

recursive_case:
    # Prepare for the recursive calls
    addi    $sp, $sp, -8
    sw      $ra, 4($sp)
    sw      $a0, 0($sp)

    # Call fibonacci(n-1)
    addi    $a0, $a0, -1
    jal     fibonacci
    lw      $a0, 0($sp)  # Restore the original n
    sw      $v0, 0($sp)  # Store fibonacci(n-1)

    # Call fibonacci(n-2)
    addi    $a0, $a0, -2
    jal     fibonacci
    lw      $t0, 0($sp)  # Load fibonacci(n-1)

    # Add fibonacci(n-1) and fibonacci(n-2)
    add     $v0, $v0, $t0

    # Clean the stack and return
    lw      $ra, 4($sp)
    addi    $sp, $sp, 8
    jr      $ra
