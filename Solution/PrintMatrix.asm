; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X3B54
PrintMatrix:

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
	
	ADD R1, R4, #0 ; R1 = N
	
	; Here's what's going to happen next:
	; R0 <- PrintMatrix(MatrixPtr, N)
	
	
	; here, we want do (R4*R4) using Mul function. we do this so we go over (R4*R4) cells and insert there the values:
	; Load parameters 
	STR R4, R6, #-2 ; Store first parameter: N
	STR R4, R6, #-1 ; Store second parameter: N
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
    LD R5, PrintMatrix_Mul
    JSRR R5 ; R0 = Mul(num1, num2) which will give us here (N*N)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	
	ADD R4, R0, #0 ; R4 = R4*R4 =(cols*rows) = N*N
	ADD R2, R1, #0 ; R2 = R1 = N, initialized by N and we will use it as a down counter so every time R2 = 0, we print a new line and initialize it again by N
	
	PrintMatrixLoop:
	LDR R0, R3, #0 ; R0 = MEM[R3 + 0], here R0 holds the value of the current cell
	
	; now we want to check if the value is "*" so we print it:
	LD R5, PrintMatrix_MinusStarAscii ; R5 = -42
	ADD R5, R0, R5 ; R5 = R0 - 42
	BRnp NotStar
	LD R0, PrintMatrix_StarAscii ; R0 = 42 = The ASCII value of "*"
	OUT
	BR CheckIfPrintEnter
	
	NotStar:
	LDR R0, R3, #0 ; R0 = MEM[R3 + 0], so here will give back to R0, the value of the current cell
	; here, since the value of the current cell is not "*", so it is or 1 or 0. We will print it:
	LD R5, PrintMatrix_ZeroAscii ; R5 = 48
    ADD R0, R0, R5	; R0 = R0 + 48, now R0 holds the ASCII value of the number 0 or 1
	OUT
	
	
	CheckIfPrintEnter:
	; before we move to the next cell, we want to print SPACE between the current cell and the next one:
	; but before that: we want to check if we have finished the all the current row cells then we go down to another line:
	ADD R2, R2, #-1 ; R2--
	BRnp PrintSpace
	LD R0, PrintMatrix_EnterAscii
	OUT
	ADD R2, R1, #0 ; we will initialize R2 again to be N
	BR UpdateR3
	
	PrintSpace:
	LD R0, PrintMatrix_SpaceAscii
	OUT
	
	UpdateR3:
	ADD R3, R3, #1 ; R3++
	ADD R4, R4, #-1 ; R4--
	BRz FinishPrintMatrix  ; if zero, then we have passed on all the cells. if no, keep looping..
	BR PrintMatrixLoop 
	
	FinishPrintMatrix:
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

     PrintMatrix_ZeroAscii .fill #48
	 PrintMatrix_SpaceAscii .fill #32
	 PrintMatrix_EnterAscii .fill #10
     PrintMatrix_StarAscii .fill #42
	 PrintMatrix_MinusStarAscii .fill #-42
     PrintMatrix_Mul .fill X3898
	 
.END