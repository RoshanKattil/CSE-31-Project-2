.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
space: .asciiz " "
newline: .asciiz "\n"


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	
	li $v0, 4 
	la $a0, str0 
	syscall 
	
	li $v0, 5	# Read the number of scores from user
	syscall
	
	move $s0, $v0	# $s0 = numScores
	move $t0, $0    # t0 = 0
	
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
	
loop_in:
    	li $v0, 4 
    	la $a0, str1 
    	syscall 
    	
    	sll $t1, $t0, 2
    	add $t1, $t1, $s1
    	
    	li $v0, 5    # Read elements from user
    	syscall
    	
    	sw $v0, 0($t1)
    	
    	addi $t0, $t0, 1
    	blt $t0, $s0, loop_in

	
	move $a0, $s0   # a0 = s0 = numscores = number of elements
	jal selSort	# Call selSort to perform selection sort
	
	li $v0, 4 
	la $a0, str2 
	syscall
	
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0   # a1 holds no of elements / NumScores
	jal printArray	# Print original scores
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	
	move $a1, $v0
    	addi $a1, $a1, 1
	sub $a1, $s0, $a1	# numScores - drop
	
	move $a0, $s2
	#sub $a1, $s0, $v0 
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	move $s0, $v0
	
	# Printing
	li $v0, 4
	la $a0, str5
	syscall
	
	#ERRORS $a1 is looping 1 more than needed 
	
	
	#Currently, $v0 holds total sum, need to divide it by a0
	div $s0, $a1
	mflo $a0  # Need to switch this to mflo $a0, currently $s0 is showing sum
	
	li $v0, 1
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	la $s1, orig # $s1 = orig
	la $s2, sorted # $s2 = sorted
	move $t0, $zero # $t0 = 0
	
	beq $a3, $zero, print_original # If a3 = 0, go to print original loop
	
	# Otherwise, print sorted loop
print_sorted:
	bge $t0, $a1, done_print # If i >= length of array, exit loop

	sll $t1, $t0, 2  # t1 = i * 4 (byte offset)
    	add $t2, $t1, $s2 # t2 = address of orig[i]
    	
    	lw $a0, 0($t2) # Load element into a0 for printing
    	li $v0, 1  #syscall for printing      
    	syscall
    	li $v0, 4
    	la $a0, space
    	syscall
    	
    	addi $t0, $t0, 1        # Increment the index
    	j print_sorted
	
print_original:
	bge $t0, $a1, done_print # If i >= length of array, exit loop

	sll $t1, $t0, 2  # t1 = i * 4 (byte offset)
    	add $t2, $t1, $s1 # t2 = address of orig[i]\
    	
    	lw $a0, 0($t2) # Load element into a0 for printing
    	li $v0, 1  #syscall for printing      
    	syscall
    	li $v0, 4
    	la $a0, space
    	syscall
    	
    	addi $t0, $t0, 1 # Increment the index
    	j print_original
	
done_print:
	li $v0, 4  # syscall for print_str
    	la $a0, newline   # Load address of newline string
    	syscall
	li $a3, 1 # Placeholder for printing sorted array
	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	
# Loop through orig array and put elements in sorted array from orig array
	la $s1, orig # Reset s1 back to start of orig array
	move $t0, $zero # Set t0 = 0
	# s2 has memory address of sorted array
	
copy_loop:
	sll $t1, $t0, 2  # Multiply t1 by 4 for memory 
	add $t3, $t1, $s1 # s1 holds orig array address, t1 holds offset
	lw $t4, 0($t3) # Load value from `orig` into $t4
	add $t3, $t1, $s2 # s2 holds sorted array address
	sw $t4, 0($t3) # Load value from orig array to sorted array
	
	addi $t0, $t0, 1
	bne $t0, $a0, copy_loop #a0 holds number of elements
	#--------------------------------
	# Now sorting the sorted array by selection sort
	
    	move $t0, $zero     # t0 = i = 0 (outer loop counter)

outer_loop:
    	bge $t0, $a0, done  # if i >= len, done sorting. $a0 holds length
    	
    	move $t2, $t0 # int maxIndex = i (t2 = maxIndex )
    	addi $t3, $t2, 1 # int j = i+1, ( t3 = j )
    	
    	# Need a way to keep track of sorted[i]
    	sll $t4, $t0, 2 # t4 is offset
    	add $t5, $t4, $s2 # t5 holds address of sorted[i]
    	lw $t6, 0($t5)  # $t6 = sorted[i] 
    	
inner_loop:
	bge $t3, $a0, swap # if j >= no of elements, exit loop and swap
	sll $t7, $t3, 2     # t7 = j * 4, offset for j
	add $t8, $t7, $s2   # $t8 = address of sorted[j]
	lw $t9, 0($t8)     # $t9 = sorted[j]
	
	ble $t9, $t6, skip_element # If sorted[j] <= sorted[maxIndex], skip
	
	move $t2, $t3  # maxIndex = j (new maximum found)
    	move $t6, $t9  # Update max value to sorted[j]
	
skip_element:
    	addi $t3, $t3, 1  # j++
    	j inner_loop # Go back to start of inner loop
	
# After exiting inner loop
swap:
	bne $t0, $t2, do_swap  # If i != maxIndex, swap otherwise, no need
	j increment_outer

do_swap:
	# Beed to swap sorted[i] with sorted[maxIndex]
	sll $t4, $t0, 2  # t0 = i, t4 is offset for i
	add $t5, $t4, $s2 # $t5 = address of sorted[i]
	lw $t6, 0($t5) # $t6 = sorted[i]
	
	
	sll $t7, $t2, 2 # t2 = maxIndex, t7 = offset for maxIndex
    	add $t8, $t7, $s2 # $t8 = address of sorted[maxIndex]
    	lw $t9, 0($t8) # $t1 = sorted[maxIndex]
    	
    	#Swapping them
    	sw $t9, 0($t5) # sorted[i] = sorted[maxIndex]
    	sw $t6, 0($t8) # sorted[maxIndex] = sorted[i]
    
increment_outer: 
	addi $t0, $t0, 1    # i++
    	j outer_loop        # Go back to the outer loop
	
done: 
	move $a3, $zero # Placeholder for print function
	jr $ra
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	#a1 holds the number of elements to add, excliding the lowest x
	
	# Saving space on stack due to recursion
	addi $sp, $sp, -4       
    	sw $ra, 0($sp)        
	
	blez, $a1, return_zero # If len <= 0, return 0
	
	addi $a1, $a1, -1  # Decrement len by 1
    	jal calcSum # Recursively call calcSum(arr, len - 1)

    	sll $t0, $a1, 2  # offset for arr[len - 1]
    	add $t1, $a0, $t0 # address of arr[len - 1]
    	lw $t2, 0($t1) # t2 = arr[len - 1] 
    	add $v0, $v0, $t2 # Add arr[len - 1] to the sum 
    	
    	add $a1, $a1, 1 # Restore a1 to original value
			
	j end_calcSum
	
return_zero:
	li $v0, 0 # Set v0 = 0 to start calculations
	jr $ra
	
end_calcSum:
	lw $ra, 0($sp)   
    	addi $sp, $sp, 4         
    	jr $ra                   
	
