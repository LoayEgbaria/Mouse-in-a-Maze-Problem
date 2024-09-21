; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X3000
main:

    LD R6, STACK

    ; Print "Please enter a number between 2 to 20: " then call a number using GetNum function
    LEA R0, MSG1
    PUTS
	LD R5, main_GetNum
    JSRR R5

    ADD R4, R0, #0 ; R4 = N

    ; Print "Please enter the maze matrix:"
    LEA R0, MSG2
    PUTS
	; Print a new line
    AND R0, R0, #0
    ADD R0, R0, #10
    OUT
    
	; now, we will try to call a legal matrix. if we have failed, then we will call again for a matrix. other, continue
    CallAMatrix:
    LEA R3, Matrix ; LOAD to R3, the address of the matrix 
    ; Load parameters
    STR R3, R6, #-2	; Store first parameter: pointer to a matrix
    STR R4, R6, #-1 ; Store second parameter: matrix size (N)
    ADD R6, R6, #-2	; Increase stack size by the number of parameters
    LD R5,main_GetMatrix
	JSRR R5 ; R0 = GetMatrix(MatrixPtr, N)
    ADD R6, R6, #2 ; Decrease stack size by the number of parameters
   
    ADD R0, R0, #0
    BRp IllegalMatrix
    ; if we made it to here, then all the matrix cells are 0 or 1.
    ; now we want to check if the value of (matrix[0][0]) and value of (matrix[N-1][N-1]) both are 1:
	
	; here we will check if (matrix[0][0]) is 1:
	LDR R1, R3, #0 ; R1 = MEM[R3 + 0], so here R1 holds the value of the first cell of the matrix (matrix[0][0])
    ADD R1, R1, #-1 ; R1--
    BRnp IllegalMatrix
	
	; here we will check if (matrix[N-1][N-1]) is 1:
	; but before, we want do (R4*R4) using Mul function, so we can get to the cell (matrix[N-1][N-1]) easily:
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N
	STR R4, R6, #-1 ; Store second parameter: N
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, main_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here: N*N
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	
	ADD R1, R0, #-1 ; R1 = R0 - 1, now R1 holds the index of the last cell. we want to add it to "matrtix" and check the number:
	ADD R3, R3, R1 ; R3 = R3 + R1, that means R3 = matrix + (index of the last cell)
	LDR R1, R3, #0 ; R1 = MEM[R3 + 0], so here R1 holds the value of the last cell of the matrix (matrix[N-1][N-1])
	ADD R1, R1, #-1 ; R1--
    BRnp IllegalMatrix
	
	; if we made it to here, then we have successfully passed the 3 test of the matrix and it is a legal matrix
    BR LegalMatrix
	
    IllegalMatrix:
	; so here, the matrix that the user entered is not legal. we will print error msg and call the matrix again
	; Print "Illegal maze! Please try again:" then print a new line
    LEA R0, MSG3
    PUTS
	AND R0, R0, #0
    ADD R0, R0, #10
    OUT
    BR CallAMatrix

    LegalMatrix:
	; here, we have called a legal matrix from the user. we will print a msg and start to find the cheese for the rat
    ; Print "The mouse is hopeful he will find his cheese." then print a new line
	LEA R0, MSG4
	PUTS
	AND R0, R0, #0
    ADD R0, R0, #10
    OUT
    
	; Load parameters
    LEA R3, Matrix
	STR R3, R6, #-2 ; Store first parameter: pointer to a matrix
	STR R4, R6, #-1 ; Store second parameter: N
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, main_Solve
	JSRR R5 ; in the same function, we will check the conditions of the code
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters


HALT

    STACK .fill xBFFF
    main_GetNum .fill X38FC
    main_GetMatrix .fill X39C4
    main_Mul .fill X3898
    main_Solve .fill X3C80
    MSG1 .stringz "Please enter a number between 2 to 20: "
    MSG2 .stringz "Please enter the maze matrix:"
	MSG3 .stringz "Illegal maze! Please try again:"
	MSG4 .stringz "The mouse is hopeful he will find his cheese."
    Matrix	.blkw #400 #-1 ; maybe we can put it in data.asm?

.END