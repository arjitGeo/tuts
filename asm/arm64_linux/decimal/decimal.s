.text
.align 8
.global _start

//READ A STRING FROM TERMINAL (stdin) AND TURN IT INTO A DECIMAL NUMBER
//AND PRINT THAT DECIMAL NUMBER TO THE SCREEN
_start:	
	ldr x1, =input_cleaned		//set x1 to a pointer that can hold the input 
	ldr x2, =10			//set x2 to the maximum length for input
	bl input			//read the keyboard
	
	ldr x1, =input_cleaned
	mov x2, x0			//x0 holds the actual number of bytes read
	bl atoi				//print the string to the screen
	bl printUInt			//print that number in decimal

	mov X0, #0			//set the exit code to 0
	bl exit				//call exit

	//x0 will hold result
	//x1 points to the string
	//x2 holds the number of butes 
atoi:
	stp x29, x30, [sp, #-16]!       //store frame pointer and  stack pointer on the stack
        stp x5, x6, [sp, #-16]!         //push x5 and x7 to stack (so they won't be globbered)
        stp x3, x4, [sp, #-16]!         //push x2 and x3 to stack (so they won't be globbered)
        stp x1, x2, [sp, #-16]!         //push x0 and x1 to stack (so they won't be globbered)

	mov x5, #1			//multiplier
	mov x0, #0			//The decimal result that will be returned, is set to 0 to allow base10 operations
	mov x3, #0			//intermediate value to calulator decimnal part
	mov x6, #10			//the decimal multiplier
atoi_readchar:
	subs x2, x2, #1			//subtract 1 from the byte counter
	ldrb w3, [x1, x2]		//load the byte from the heap (from highest byte on the heap (least significat decimal) to the beginning
	sub x3, x3, #48			//turn char into integer
	mul x3, x3, x5			//multiply the value by it's decimal denominator (1, 10, 100, 1000 etc)
	add x0, x0, x3			//add that decimal posiiton to the result
	mul x5, x5, x6			//mulitply the multiplier by 10, to get the next decimal denominator
	cmp x2, #0
	bne atoi_readchar
	
	ldp x1, x2, [sp], #16           //pop x0 and x1 from stack (so they won't be globbered)
        ldp x3, x4, [sp], #16           //pop x2 and x3 from stack (so they won't be globbered)
        ldp x5, x6, [sp], #16           //pop x5 and x7 from stack (so they won't be globbered)
        ldp x29, x30, [sp], #16         //pop fp and sp from stack (so they won't be globbered)
	ret

//Print value in X0 as an unisgned int to screen
printUInt:
	stp x29, x30, [sp, #-16]!	//store frame pointer and  stack pointer on the stack
	stp x5, x7, [sp, #-16]!		//push x5 and x7 to stack (so they won't be globbered)
	stp x2, x3, [sp, #-16]!		//push x2 and x3 to stack (so they won't be globbered)
	stp x0, x1, [sp, #-16]!		//push x0 and x1 to stack (so they won't be globbered)

	mov x7, #10			//x7 will contain the divider (10) used in udiv and msub
	mov x5, #0			//x5 counts the number of digits stored on stackl
	sub sp, sp, #128		//move stack pointer down 128 bytes, so we have space to store the to print digits
	
	cmp x0, #0			//if x0=0 then the division algorith will not work
	beq printUInt_Zero		//we set the value on the stack to 0

printUInt_Count:
	udiv x2, x0, x7			//divide the value x0 by 10
	msub x3, x2, x7, x0		//obtain the remainder (x3) and the Quotient (x2)
	add x5, x5, #1			//increment the digit counter (x5)
	strb w3, [sp, x5]		//store the digit on the stack as single byte
	mov x0, x2			//copy the Quotient (x2) into x0 which is the new value to divide by 10
	cmp x0, #0			//if the Quotient (x0) is 00 then we found all individual digits
	bne printUInt_Count		//if x0 is not yet zero than there's more digits to extract
	b printUInt_print			//we set all the digits on the stack now we can pop them off and print them

printUInt_Zero:				//this is the exceptional case when x0 is 0 then we need to push this ourselves to the stack
	add x5, x5, #1 			//x5 is not used so still 0, there for we need to offset it by 1 for the sp offset
	strb w0, [sp, x5]		//set the value 0 to the stack, so that it can be printed to the screen

	//using the stacl guarantees that the digits are printed in the right order (from large to smallest_
printUInt_print:
	ldrb w3, [sp, x5]		//pop the last digit from the stack (the biggest value)
	ldr X1,=char			//set X1 to the char variable address, so we can store the char there later on
	add w3, w3, 48			//add 48 to the number, turning it into an ASCII char 0-9
	strb w3, [x1]			//store the ASCII char in the char variable (pointed to by X1)
	mov x2,#1 			//set the length to write() to 1
	bl print			//call the writer() system call wrapper 
	subs x5, x5, #1			//reduce x5 by 1, pointing to the next digit on the stack 
	bne printUInt_print		//if x5 is not 0 then there are still digits on the stack, that should be printed

printUInt_exit:
	add sp, sp, #128		//reclaim the 128 bytes local storage on the stack 
	ldp x0, x1, [sp], #16		//pop x0 and x1 from stack (so they won't be globbered)
	ldp x2, x3, [sp], #16		//pop x2 and x3 from stack (so they won't be globbered)
	ldp x5, x7, [sp], #16		//pop x5 and x7 from stack (so they won't be globbered)
	ldp x29, x30, [sp], #16		//pop fp and sp from stack (so they won't be globbered)
	ret 				//return

//Print to STDOUT the message pointed by X1
//X1 is string ptr 
//X2 is string length of the string
print:
	stp x29, x30, [sp, #-16]!	//store fp and sp on the stack
	stp x2, x8, [sp, #-16]!		//store x2 and x8 on the stack (so they won't be globbered)
	stp x0, x1, [sp, #-16]!		//store x0 and x1 on the stack (so they won't be globbered)

	mov X0, #1			//set X0 to point to standard out
	mov X8, #64			//write syscall 
	svc #0				//call system call (64 => write)

	ldp x0, x1, [sp], #16		//pop x0 and x1 from stack (so they won't be globbered)
	ldp x2, x8, [sp], #16		//pop x2 and x8 from stack (so they won't be globbered)
	ldp x29, x30, [sp], #16		//pop fp and sp from stacl
	ret				//return to caller

//Read from STDIN
//FD is 0 (stdin)
//x1 is the pointer for the buffer
//x2 is number of bytes
//Return: x0 contains number of bytes read
input:
	stp x29, x30, [sp, #-16]!       //store fp and sp on the stack
	stp x2, x8, [sp, #-16]!		//store x2 and x8 on the stack (so they won't be globbered)

        mov X0, #0                      //set X0 to point to standard out
        mov X8, #63                     //write syscall 
        svc #0                          //call system call (64 => write)

	subs x0, x0, #1			//length starts at 1 and we need to check last read char, so we subtract 1
	ldrb w8, [x1, x0]		//did we read the maximum amount of chars then we don't need to subtract \n
	cmp w8, #'\n'			//is the last character not a \n than we need to add 1 back to the total length
	beq input_exit		//we already subtracted 1 from the length read so we are good
	add x0, x0, #1			//we now have more chars than actually defined so we need to add 1 back to the length

input_exit:
        ldp x2, x8, [sp], #16         //pop fp and sp from stacl
        ldp x29, x30, [sp], #16         //pop fp and sp from stacl
        ret                

//Exit to operating system, X0 will contain the exit code
//X0 contains exit code
exit:
	mov X8, #93			//exit system call
	svc #0				//call system call (93 => exit)
	ret				//this won't be called because exit will terminate program before we get here

.data
char:		.byte 0
input_cleaned:	.fill 20,1,0
