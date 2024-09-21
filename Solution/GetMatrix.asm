; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X39C4
GetMatrix:
	
    ; first of all, we increase stack size by number of registers to backup + local variables
	ADD R6, R6, #-6
	
	; Backup registers for local use
	STR R1, R6, #0
	STR R2, R6, #1
	STR R3, R6, #2
	STR R4, R6, #3
	STR R5, R6, #4
	STR R7, R6, #5 ; Backup return address like any other register
	
	LDR R3, R6, #6 ; R3 = pointer to a matrix
	LDR R4, R6, #7 ; R4 = matrix size (N)
	
	
	; Here's what's going to happen next:
	; R0 <- GetMatrix(MatrixPtr, N)
	; We will return in R0: 0 if all the cells are 0 or 1. or we return 1 if not all the cells are 0 or 1.
	
	; here, we want do (R4*R4) using Mul function. we do this so we go over (R4*R4) cells and insert there the values:
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N
	STR R4, R6, #-1 ; Store second parameter: N
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, GetMatrix_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (N*N)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	
	ADD R4, R0, #0 ; R4 = R4*R4 (cols*rows) = N*N
	AND R1, R1, #0 ; R1 = 0, we will use R1 to be a flag if we have entered a number other than 1 or 0
	
	; now, we will loop on the matrix, cell by cell, and insert values to it using GetNum function:
	GetMatrixLoop:
    LD R5,GetMatrix_GetNum
	JSRR R5
	ADD R0, R0, #0
    BRn GetMatrixIllegalNum ; if the num is negative, means the matrix is illegal
	BRz GetMatrixSkip ; if zero, then skip checking if the num is 1
	; if we made it to here, then the user has entered a postitive number. we want to check if is it 1:
	ADD R2, R0, #-1
	BRz GetMatrixSkip
	
	GetMatrixIllegalNum:
	ADD R1, R1, #1 ; R1++
    
	GetMatrixSkip:
    STR R0, R3, #0 ; MEM[R3 + 0] = R0, so here we are inserting the entered value to the matrix
	ADD R3, R3, #1 ; R3++
	ADD R4, R4, #-1 ; R4--
	BRz TheMatrixIsFull  ; if zero, then we have passed on all the cells. if no, keep looping..
	BR GetMatrixLoop 
	
	TheMatrixIsFull:
    ; before we finish, since we are using Haifa convention: we have to load to R0 the return value
	; we have decided that the return value be: 0 if all the cells contain 0 or 1. else, we return 1.
	AND R0, R0, #0 ; R0 = 0
	ADD R1, R1, #0 ; we will check the sign flag: if zero then return zero (legal matrix). else, return one (illegal matrix)
	BRz FinishGetMatrix
	ADD R0, R0, #1 ; R0 = 1
	BR FinishGetMatrix
	
	FinishGetMatrix:
	; at the end, we restore the backed up registers from the stack
	LDR R7, R6, #5
	LDR R5, R6, #4
	LDR R4, R6, #3
	LDR R3, R6, #2
	LDR R2, R6, #1
	LDR R1, R6, #0
	
	; Pop current stack frame (local variables + backed up registers)
	ADD R6, R6, #6	; In this case, we had 0 local variables and 6 registers backed up

RET 
	 
    GetMatrix_GetNum .fill X38FC
    GetMatrix_Mul .fill X3898

.END