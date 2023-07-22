.data
	option_msg:    .asciiz "Please enter option (1: triangle, 2: inverted triangle): "
	size_msg:      .asciiz "Please input a triangle size: "
	space_char:    .asciiz " "
	star_char:     .asciiz "*"
	newline_char:  .asciiz "\n"

 .text
.globl main

main:
    # print option message and get option
    li      $v0, 4
    la      $a0, option_msg
    syscall
    li      $v0, 5
    syscall
    move    $t0, $v0    # save option to t0

    # print size message and get size
    li      $v0, 4
    la      $a0, size_msg
    syscall
    li      $v0, 5
    syscall
    move    $t1, $v0    # save size to t1

    # print triangle
    li      $t2, 0      # initialize i to 0
loop:
    bge     $t2, $t1, end_loop    # if i >= n, jump to end_loop
    beq     $t0, 1, print_triangle
    j	print_inverted_triangle

print_triangle:
    move    $a1, $t2    # calculate l = i
    j       print_layer

print_inverted_triangle:
    sub     $a1, $t1, $t2    # calculate l = n - i
    sub     $a1, $a1, 1      # calculate l = (n-i) - 1
    j       print_layer

print_layer:
    # print leading spaces
    li      $t3, 1      # initialize j to 1
    sub     $a2, $t1, $a1    # calculate end = n - l
print_spaces:
    bge     $t3, $a2, print_stars    # if j >= end, jump to print_stars
    li      $v0, 4
    la      $a0, space_char
    syscall
    addi    $t3, $t3, 1
    j       print_spaces

    # print stars
    move    $t3, $a2    # set j to end
print_stars:
    add     $t4, $t1, $a1    # calculate end = n + l
    bgt     $t3, $t4, print_newline    # if j > end, jump to print_newline
    li      $v0, 4
    la      $a0, star_char
    syscall
    addi    $t3, $t3, 1
    j       print_stars

print_newline:
    # print newline character
    li      $v0, 4
    la      $a0, newline_char
    syscall

    # increment i and go to next loop iteration
    addi    $t2, $t2, 1
    j       loop

end_loop:
    # exit program
    li      $v0, 10
    syscall
