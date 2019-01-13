##############################################################################
##
##		A program that calls linked list utility functions,
##		 depending on user selection, outputs a 
##		message, then lists the menu options and get the user
##		selection, then calls the chosen routine, and repeats
##
##	a0 - used for input arguments to syscalls and for passing the 
##		pointer to the linked list to the utility functions
##   
##	TODO: Add other registers and their description as needed!
##
##      linked list consists of 0 or more elements, in 
##		dynamic memory segment (i.e. heap)
##	elements of the linked list contain 2 parts:
##
##		at address z: pointerToNext element (unsigned integer), 4 bytes
##		at address z+4: value of the element (signed integer), 4 bytes
############################# text segment ####################################	
.text		
#function to read integer input
.macro readInt
	li $v0, 5
	syscall
.end_macro

#function to print a string defined in data, "%y" is for the label parameter of string defined
.macro say(%y)
	li $v0, 4
	la $a0,  %y
	syscall
.end_macro
 
####### the program code section #####

####### PART 1.1 starts here ####### also uses functions above as helper for syscalls often used #######
.globl _Lab2main

# execution starts here
_Lab2main:		

	#outputs a message, then lists the menu options and get the user selection; 
	#then calls the chosen routine, and repeats
	say(mess)

main_menu_process:
	#show available list of menu options
	li $v0, 4
	la $a0, opList
	syscall

	#ask for input for menu option number
	li $v0, 4
	la $a0, optNo
	syscall

	#read user selection
	li $v0, 5
	syscall

	#call chosen routine
	beq $v0, 1, create_list_check #create array
	beq $v0, 2, display 
	beq $v0, 3, clear_list_check
	beq $v0, 4, showSize
	beq $v0, 0, exit #exit

	#else repeat
	j main_menu_process

#display condition
display:
	#if array head is NULL, print message and return to main menu
	bnez $a1, display_list	
	say(return)							
	j main_menu_process
	
#option 3 as exit
exit:
	li $v0, 10
	syscall

############################# PART 1.2 ###############################
#### create_list - a linked list utility routine, 
##			which creates the contents, element 
##			by element, of a linked list
##
##	TODO: Add other registers and their description as needed!
######################################################################   

#s0 size
#a1 linkedlist
#a2 pointerToNext( cur->next)
#t0 node with value
#v0 syscall register
create_list_check:
	beqz $s0, create_list
	say(memLeakWarn)
	
	j main_menu_process		    	

create_list:		# entry point for this utility routine
	#ask for input for menu option number
	say(input)
	
	#create array
    	la $a1, linkedlist   	

read_numbers:	  
	#read number
    	readInt	
    	move $t0, $v0 #get input
	
	#allocate memory for pointerToNext
	li $a0, 4
	li $v0, 9
	syscall 
	
	#add number to current array element
    	sw $t0, 0($a1)
    	addiu $a1, $a1, 4
	
	#go to list if 0 is entered
    	beqz $t0, main_menu_process		
    	
    	#update size
	addi $s0, $s0, 1
    	
    	j read_numbers

############################# end of PART 1.2 ########################

clear_list_check:
	#check whether linkedlist is empty
				
	bnez $s0, clear_list
	say(invalidClear)
	j main_menu_process

clear_list: 
	#deletes current head, updates linked list and size; then, repeats process till head node is NULL

	la $a1, linkedlist 	#get the linkedlist	
	lw $t0, 0($a1)     	#current node is head 
	beqz $t0, clear_done	#exists loop in case head is NULL

	inner_loop:
		# current node advances till it reaches NULL node
		beqz $t0, end_inner_loop	# break inner loop if current node is NULL
		
		#head = head->next
		la $a2,4($a1)			# a2 = cur->next
		lw $t0,0($a2)			# cur = head->next; (cur had been declared head)
			
		sw $t0,0($a1)			# head = cur;       (which means current head has next head->next value)
	
		addi $a1, $a1, 4		# cur = cur ->next;
    	
    		j inner_loop 			# continue; (repeats inner loop)
    		
    	end_inner_loop:
    		
    	addi $s0, $s0, -1 	#decrease size by one: size--;
    	
    	j clear_list		# continue; (repeats outer loop)
    	
clear_done:
	#displays message and returns to main menu
	say(messClear)
	j main_menu_process

######################## PART 1.3 ###################################
#### display_list - a linked list utility routine, 
##			which shows the contents, element 
##			by element, of a linked list
##
##	TODO: Add other registers and their description as needed!
##
##################################################################### 
 
display_list:			# function to display values stored in linkedlist nodes in order
	
	#get array
    	la $a1, linkedlist
	
	#message for list
    	say(text)
    	
while:    	    		# while current node is not NULL, display current value, advance to next Node

	#get current(t0) element 
    	lw $t0, 0($a1)       	
   	
   	#exit loop if t0 is NULL
   	beqz $t0, while_done
   	
   	# update array
   	addiu $a1, $a1, 4
	#if element is zero ask for option
    	li $v0, 1
    	move $a0, $t0
    	syscall
	
	#space between displayed values
 	say(space)		
 	
    	j while  		# advance to next Node
 
while_done:			# exit loop, show size and return to main menu

	# message for size
	say(size)
	
	# show size
    	li  $v0, 1           	# service 1 is print integer
    	move $a0, $s0  	     	# load desired value into argument register $a0, using pseudo-op
    	syscall

    	# message for linkedlist display
    	say(msg)
    	
    	# exit loop, show size and return to main menu
    	j main_menu_process	
	
showSize:

	# show message and the size
	say(size)
	
	li $v0, 1
    	move $a0, $s0
    	syscall
    	
    	# return to main menu
    	j main_menu_process
    	
################################################ data segment ################################################

.data
#linked list has non-allocated space in memory at the beginning, size will return 0 
linkedlist:	
mess: 		.asciiz "\nWelcome to Lab2! In this program you will select an option to initiate the utilization of linkedlist. Enjoy!\n"
opList: 	.asciiz "\n1)create linked list\n2)display linked list elements\n3)clear linked list\n4)size\n0)exit\n"
input:		.asciiz "\nEnter a number(0 to stop):\n"
optNo:		.asciiz "\nEnter an option:\n"
text:   	.asciiz "\nList: "
return:		.asciiz "\nThe linked list is not declared,returning to main menu...\n"
size:		.asciiz "\nSize: "
space: 		.asciiz " "
newLine: 	.asciiz "\n"
messClear:	.asciiz "\nThe linked list has been purged\n"
memLeakWarn:	.asciiz "\nWarning: Attempting to overwrite a linkedlist head will result with memory leak. Please clear existing linkedlist first. Returning to main menu\n"
invalidClear:	.asciiz "\nValid linked list has not been found\n"
msg:		.asciiz "\nThe linked list has completely been displayed\n"

## end of main
