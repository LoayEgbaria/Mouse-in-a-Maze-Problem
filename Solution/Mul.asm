; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X3898
Mul:

    ; first of all, we increase stack size by number of registers to backup + local variables
	ADD R6, R6, #-4
	
	; Backup registers for local use
	STR R1, R6, #0
	STR R2, R6, #1
	STR R3, R6, #2
	STR R7, R6, #3 ; Backup return address like any other register
	
	LDR R1, R6, #4 ; R1 = first number
	LDR R2, R6, #5 ; R2 = second number
	
	
	; Here's what's going to happen next:
	; R0 <- Mul(num1, num2)
	
    AND R3, R3, #0 ; R3=0, it will initialized by zero so we can use it as a result register
    ADD R1, R1, #0 ; R1= R1+0, we do this to check the changes on CC
    BRz FinishMul
    ADD R2, R2, #0 ; R2= R2+0, we do this to check the changes on CC
    BRz FinishMul
    BRp R2isPos
    BRn R2isNeg

    R2isPos: ; if we made it to here, then R2 is positive 
    ADD R1, R1, #0 ; R1= R1+0, we do this to check the changes on CC
    BRp MulTwoPos
    ;if we made it to here, then R1 is neg and R2 is pos
    NOT R1, R1 
    ADD R1, R1, #1 ; now, new R1 = - old R1
    BR MulOnePosOneNeg

    R2isNeg: ; if we made it to here, then R2 is negative
    ADD R1, R1, #0 ; R1= R1+0, we do this to check the changes on CC
    BRn MulTwoNeg
    ;if we made it to here, then R1 is pos and R2 is neg
    NOT R2, R2 
    ADD R2, R2, #1 ; now, new R2 = - old R2
    BR MulOnePosOneNeg

    MulTwoNeg: ; if we made it to here, then here we are multiplying two negative numbers: R1 and R2 
    ; what we are going to do here is that we are flipping the signs of R1 and R2 from negative sign to positive sign
    NOT R1, R1
    ADD R1, R1, #1 ; now, new R1 = - old R1
    NOT R2, R2 
    ADD R2, R2, #1 ; now, new R2 = - old R2
    BR MulTwoPos

    MulOnePosOneNeg: ; if we made it to here, then R1 or R2 is negative number, and not both of them
    ; here, we are adding to R3 (initialized by value 0), R2 times the value of R1
    ; that means that we use R2 as a counter and R3 as a sum
    ; never forget that here, we have already flipped the sign of the negative number to a positive one 
    ADD R2, R2, #0 ; R2= R2+0, we do this to check the changes on CC
    BRz ChangeR3toNeg
    ADD R3, R3, R1
    ADD R2, R2, #-1
    BR MulOnePosOneNeg

    ChangeR3toNeg: ; here, we are flipping the sign of R3 from positive sign to negative sign
    NOT R3, R3
    ADD R3, R3, #1 ; now, new R3 = - old R3
    BR FinishMul

    MulTwoPos: ; if we made it to here, then here we are multiplying two positive numbers: R1 and R2
    ; here, we are adding to R3 (intialized by value 0), R2 times the value of R1
    ; that means that we use R2 as a counter and R3 as a sum
    ADD R2, R2, #0 ; R2= R2+0, we do this to check the changes on CC
    BRz FinishMul
    ADD R3, R3, R1
    ADD R2, R2, #-1
    BR MulTwoPos

    FinishMul:
	; before we finish, since we are using Haifa convention: we have to load to R0 the return value (which is stored in R3)
	ADD R0, R3, #0 ; R0 = R3
	
	; at the end, we restore the backed up registers from the stack
	LDR R7, R6, #3
	LDR R3, R6, #2
	LDR R2, R6, #1
	LDR R1, R6, #0
	
	; Pop current stack frame (local variables + backed up registers)
	ADD R6, R6, #4	; In this case, we had 0 local variables and 4 registers backed up
	
RET

.END