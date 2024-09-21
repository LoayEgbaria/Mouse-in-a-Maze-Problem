; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X3C80
Solve:

    ; first of all, we increase stack size by number of registers to backup + local variables
	ADD R6, R6, #-5
	
	; Backup registers for local use
	STR R1, R6, #0
	STR R2, R6, #1
	STR R3, R6, #2
	STR R4, R6, #3
	STR R7, R6, #4 ; Backup return address like any other register
	
	LDR R3, R6, #5 ; R3 = pointer to a matrix
	LDR R4, R6, #6 ; R4 = N
	
	; Here's what's going to happen next:
	; R0 <- Solve(MatrixPtr, N)
	
	
	AND R1, R1, #0 ; R1 = 0
	AND R2, R2, #0 ; R2 = 0
	
	; now we will call for the main backtracking function
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i (0)
	STR R2, R6, #-1 ; Store fourth parameter: j (0)
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR SolveMaze ; call for the main backtracking function
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters

    ; we want to check if the return value of SolveMaze is 0 or 1 or (-1)
	; if 1, then print "OH NO! It seems the mouse could not find another solution for this maze." and finish
	; if 0, then print "OH NO! It seems the mouse has no luck in this maze." and finish
	; if (-1), then just finish the function bcz the user has entered "No" after asking him if he want another solution
	ADD R0, R0, #0
	BRp PrintedASolution
	BRn FinishSolve
	LEA R0, MSG6
	PUTS
	; print a new line
	AND R0, R0, #0
    ADD R0, R0, #10
    OUT
	BR FinishSolve
	
	PrintedASolution:
	; we have already printed a solution of the maze and we could not find another solution for it
	; so we print "OH NO! It seems the mouse could not find another solution for this maze." and finish the function
	LEA R0, MSG5
	PUTS
	; print a new line
	AND R0, R0, #0
    ADD R0, R0, #10
    OUT
	
	
	FinishSolve:
	; at the end, we restore the backed up registers from the stack
	LDR R7, R6, #4
	LDR R4, R6, #3
	LDR R3, R6, #2
	LDR R2, R6, #1
	LDR R1, R6, #0
	
	; Pop current stack frame (local variables + backed up registers)
	ADD R6, R6, #5	; In this case, we had 0 local variables and 5 registers backed up
	
RET
    
	MSG5 .stringz "OH NO! It seems the mouse could not find another solution for this maze."
	MSG6 .stringz "OH NO! It seems the mouse has no luck in this maze."


SolveMaze:

    ; first of all, we increase stack size by number of registers to backup + local variables
	ADD R6, R6, #-7
	
	; Backup registers for local use
	STR R1, R6, #0
	STR R2, R6, #1
	STR R3, R6, #2
	STR R4, R6, #3
	STR R5, R6, #4
	STR R7, R6, #5 ; Backup return address like any other register
    ; here we want to use PrintFlag as local variable, and we will initialize it by 0
    AND R5, R5, #0 ; R5 = 0
    STR R5, R6, #6 ; PrintFlag = 0
	
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	LDR R4, R6, #8 ; R4 = N
	LDR R1, R6, #9 ; R1 = i
	LDR R2, R6, #10 ; R2 = j
	
	; Here's what's going to happen next:
	; R0 <- SolveMaze(MatrixPtr, N, i, j) 
	; in the first call to this function: we call for SolveMaze(matrixPtr, N, 0, 0)
	; so we will backtrack over the matrix searcing for a solution of the maze.
	; and when we find a solution, we print it and ask the user if he want another solution
	; if he said "No", we simply finish. if he said "Yes", we return 2 in order to update PrintFlag to be 2.
    ; this function return 4 types for itself (recursively):
	; (-1) if the user entered "No" after asking him if he want another solution
	; 0 if we did not find any solution at all
	; 1 if we already printed a solution in the same iteration (means we have returned 2 before that, and we will save the value 2 in PrintFlag)
	; 2 if we founded a solution and the user entered "Yes" after asking him if he want another solution
	; but, the function returns 3 types for Solve:
	; (-1) if the user entered "No" after asking him if he want another solution
	; 0 if we did not find any solution at all
	; 1 if we have not found more solutions of the maze
   
    ; now we want to check if (i == N - 1 && j == N - 1), so we check if we have reached the last cell and its value is 1:
   
    ; Check if i == N - 1: if yes, keep checking other conditions. if no, then go to CheckIsItSafe
    ADD R5, R1, #0 ; R5 = i
    NOT R5, R5
	ADD R5, R5, #1 ; R5 = -i
	ADD R5, R4, R5 ; R5 = N - i
	ADD R5, R5, #-1 ; R5--, so we get: R5 = N - i - 1: if R5=0 then (i == N - 1) and keep checking other conditions. other, go to CheckIsItSafe
	BRnp CheckStar
	
	; Check if j == N - 1: if yes, keep checking other conditions. if no, then go to CheckIsItSafe
	ADD R5, R2, #0 ; R5 = j
	NOT R5, R5
	ADD R5, R5, #1 ; R5 = -j
	ADD R5, R4, R5 ; R5 = N - j
	ADD R5, R5, #-1 ; R5--, so we get: R5 = N - j - 1: if R5=0 then (j == N - 1) and keep checking other conditions. other, go to CheckIsItSafe
	BRnp CheckStar
	
	
	; if we made it to here, then we have successfully passed the 2 tests and we have to enter in the "if" condition:

	; now, we want to make R3 points to the currrent cell:
	ADD R3, R3, R2 ; R3 += j
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N (columns)
	STR R1, R6, #-1 ; Store second parameter: i
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, SolveMaze_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)
	
	LD R5, SolveMaze_StarASCII ; R5 = 42
	STR R5, R3, #0 ; MEM[R3 + 0] = R5, so we get (matrix[i][j] = *)
	
	; now we want to print "Yummy! The mouse has found the cheese!" then print a new line
	LEA R0, MSG7
	PUTS
	AND R0, R0, #0
    ADD R0, R0, #10
    OUT
	
	; now we want to print the matrix using PrintMatrix function
	; Load parameters
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
    STR R3, R6, #-2	; Store first parameter: pointer to a matrix
    STR R4, R6, #-1 ; Store second parameter: matrix size (N)
    ADD R6, R6, #-2	; Increase stack size by the number of parameters
    LD R5, SolveMaze_PrintMatrix
	JSRR R5 ; R0 = PrintMatrix(MatrixPtr, N)
    ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	
	; now we will print "Would you like to see another solution? " and ask the user if he want to see another solution
	; if he asnwered "Y" or "y", then we return false in order to search for another solution
	; if he asnwered "N" or "n", then we return true in order to stop searching for another solution
    LEA R0, MSG8
	PUTS
	
	GETC
	OUT
	ADD R5, R0, #0 ; SAVE the Char we entered in R5
	
	; Print a new line from the user:
    GETC
	OUT
	ADD R0, R5, #0 ; LOAD the Char we entered to R5

    ; check if the user entered yes (entered "Y" or "y"):
	LD R5, Minus_Y ; R5 = -89
	ADD R5, R0, R5 ; R5 = R0 - 89
	BRz EnteredYes
	LD R5, Minus_y ; R5 = -121
	ADD R5, R0, R5 ; R5 = R0 - 121
	BRz EnteredYes
	
	; check if the user entered no (entered "N" or "n"):
	LD R5, Minus_N ; R5 = -78
	ADD R5, R0, R5 ; R5 = R0 - 78
	BRz EnteredNo
	LD R5, Minus_n ; R5 = -110
	ADD R5, R0, R5 ; R5 = R0 - 110
	BRz EnteredNo
	
	
	EnteredYes: 
    ; if we made it to here, then we return Two (R0=2) in order to search for another solution
	; but before, we want to change the value of the last cell from "*" to 1:
	
	; now, we want to make R3 points to the last cell:
	ADD R3, R3, R2 ; R3 += j
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N (columns)
	STR R1, R6, #-1 ; Store second parameter: i
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, SolveMaze_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)
	
	AND R5, R5, #0 ; R5 = 0
	ADD R5, R5, #1 ; R5 = 1
	STR R5, R3, #0 ; MEM[R3 + 0] = R5, so we get (matrix[N-1][N-1] = 1) 
    BR RETURN_Two_SolveMaze ; return 2 bcz we have founded a solution
   
    EnteredNo:
	; we can notice that if the user has entered "No", 
	; then we have to finish everything without printing anything, so we return (-1) 	
	BR RETURN_MinusOne_SolveMaze
    
   
   
    CheckStar:
	; now, we want to check if (matrix[x][y] == *): if yes, that means that we have already visited this cell 
	; and we return 0. if no, keep checking other conditions..
	; but before that, we want to update R3 to point to the current cell:
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R3, R3, R2 ; R3 += j
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N (columns)
	STR R1, R6, #-1 ; Store second parameter: i
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, SolveMaze_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)
	
	LD R0, SolveMaze_MinusStarASCII ; R0 = -42
	LDR R5, R3, #0 ; R5 = MEM[R3 + 0], that means R5 = matrix[i][j]
	ADD R5, R5, R0 ; R5 = R5 - 42, means (MEM[R3 + 0] - 42)
	BRz RETURN_Zero_SolveMaze
	
    ; if we made it to here, then the current cell is not the last cell, and the value of it is not "*"
	; so we want to check if the current cell IsItSafe (holds the value 1 and i and j are in the matrix)

    CheckIsItSafe:
	; first of all, we want to check if (IsItSafe(matrix, N, i, j) == true): if yes, we enter the "if" condition. if no, return false
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix (points to the current cell)
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i
	STR R2, R6, #-1 ; Store fourth parameter: j
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR IsItSafe
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters
	
	ADD R0, R0, #0
	BRz RETURN_Zero_SolveMaze
	
	
    ; if we made it to here then (IsItSafe(matrix, N, i, j) == true): we want to check other conditions now:
	; but before calling recursively using backtracking, we want to convert the current cell, from 1 to "*"
	; so we update R3 to points to the current cell:
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R3, R3, R2 ; R3 += j
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N (columns)
	STR R1, R6, #-1 ; Store second parameter: i
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, SolveMaze_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)

	; now we want to convert the current cell, from 1 to "*"
	LD R5, SolveMaze_StarASCII ; R5 = 42
	STR R5, R3, #0 ; MEM[R3 + 0] = R5, so we get (matrix[i][j] = *)
	
	
	RightCell:
	; now, we will call recursively to the RIGHT cell and check if it returns 1 or (-1) or 0 or 2
	; if it return 2, then we update the PrintFlag to be 2 (that mean we have printed a solution and the user entered "Yes")
	; if it return 1, then we return 1.
    ; if it return (-1), that mean we have printed a solution and the user entered "No", so we return (-1)
	; if it return 0, then we keep checking other conditions.
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R2, R2, #1 ; R2++, so j++
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix (points to the current cell)
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i
	STR R2, R6, #-1 ; Store fourth parameter: j+1
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR SolveMaze
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters
    ADD R2, R2, #-1 ; give back to R2 (j+1) its original value (j)
	ADD R0, R0, #0
	BRn RETURN_MinusOne_SolveMaze
    BRz DownCell
    ; now R0 is positive: we want to check if R0=1 or R0=2
    ADD R5, R0, #-1 ; R5 = R0 - 1
    BRz RETURN_One_SolveMaze
    ; if we made it to here, then R0=2: now we want to update PrintFlag to be 2
    AND R5, R5, #0 ; R5 = 0
    ADD R5, R5, #2 ; R5 = 2
    STR R5, R6, #6 ; PrintFlag = 2
    
	
	DownCell:
	; now, we will call recursively to the DOWN cell and check if it returns 1 or (-1) or 0
	; if it return 2, then we update the PrintFlag to be 2 (that mean we have printed a solution and the user entered "Yes")
	; if it return 1, then we return 1.
    ; if it return (-1), that mean we have printed a solution and the user entered "No", so we return (-1)
	; if it return 0, then we keep checking other conditions.
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R1, R1, #1 ; R1++, so i++
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix (points to the current cell)
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i-1
	STR R2, R6, #-1 ; Store fourth parameter: j
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR SolveMaze
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters
    ADD R1, R1, #-1 ; give back to R1 (i+1) its original value (i)
	ADD R0, R0, #0
	BRn RETURN_MinusOne_SolveMaze
    BRz UpCell
    ; now R0 is positive: we want to check if R0=1 or R0=2
    ADD R5, R0, #-1 ; R5 = R0 - 1
    BRz RETURN_One_SolveMaze
    ; if we made it to here, then R0=2: now we want to update PrintFlag to be 2
    AND R5, R5, #0 ; R5 = 0
    ADD R5, R5, #2 ; R5 = 2
    STR R5, R6, #6 ; PrintFlag = 2
	
	UpCell:
    ; now, we will call recursively to the UP cell and check if it returns 1 or (-1) or 0
	; if it return 2, then we update the PrintFlag to be 2 (that mean we have printed a solution and the user entered "Yes")	
	; if it return 1, then we return 1.
    ; if it return (-1), that mean we have printed a solution and the user entered "No", so we return (-1)
	; if it return 0, then we keep checking other conditions.
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R1, R1, #-1 ; R1--, so i--
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix (points to the current cell)
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i+1
	STR R2, R6, #-1 ; Store fourth parameter: j
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR SolveMaze
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters
    ADD R1, R1, #1 ; give back to R1 (i-1) its original value (i)
	ADD R0, R0, #0
	BRn RETURN_MinusOne_SolveMaze
    BRz LeftCell
    ; now R0 is positive: we want to check if R0=1 or R0=2
    ADD R5, R0, #-1 ; R5 = R0 - 1
    BRz RETURN_One_SolveMaze
    ; if we made it to here, then R0=2: now we want to update PrintFlag to be 2
    AND R5, R5, #0 ; R5 = 0
    ADD R5, R5, #2 ; R5 = 2
    STR R5, R6, #6 ; PrintFlag = 2
	
	
	LeftCell:
	; now, we will call recursively to the LEFT cell and check if it returns 1 or (-1) or 0
	; if it return 2, then we update the PrintFlag to be 2 (that mean we have printed a solution and the user entered "Yes")	
	; if it return 1, then we return 1.
    ; if it return (-1), that mean we have printed a solution and the user entered "No", so we return (-1)
	; if it return 0, then we keep checking other conditions.true
	LDR R3, R6, #7 ; R3 = pointer to a matrix (pointer to the first cell)
	ADD R2, R2, #-1 ; R2--, so j--
	; Load parameters
	STR R3, R6, #-4 ; Store first parameter: pointer to a matrix (points to the current cell)
	STR R4, R6, #-3 ; Store second parameter: N
	STR R1, R6, #-2 ; Store third parameter: i
	STR R2, R6, #-1 ; Store fourth parameter: j-1
	ADD R6, R6, #-4 ; Increase stack size by the number of parameters
	JSR SolveMaze
	ADD R6, R6, #4 ; Decrease stack size by the number of parameters
    ADD R2, R2, #1 ; give back to R2 (j-1) its original value (j)
	ADD R0, R0, #0
	BRn RETURN_MinusOne_SolveMaze
    BRz ConvertTheCellToOne
    ; now R0 is positive: we want to check if R0=1 or R0=2
    ADD R5, R0, #-1 ; R5 = R0 - 1
    BRz RETURN_One_SolveMaze
    ; if we made it to here, then R0=2: now we want to update PrintFlag to be 2
    AND R5, R5, #0 ; R5 = 0
    ADD R5, R5, #2 ; R5 = 2
    STR R5, R6, #6 ; PrintFlag = 2


    ConvertTheCellToOne:
    ; at the end of the if condition, convert the current cell from "*" back to 1.
    ; but before that, we want to update R3 to point to the current cell:
    LDR R3, R6, #7 ; R3 = pointer to a matrix
    ADD R3, R3, R2 ; R3 += j
    ; Load parameters
    STR R4, R6, #-2 ; Store first parameter: N (columns)
    STR R1, R6, #-1 ; Store second parameter: i
    ADD R6, R6, #-2 ; Increase stack size by the number of parameters
    LD R5, SolveMaze_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
    ADD R6, R6, #2 ; Decrease stack size by the number of parameters
    ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)
	
	; now R3 points to the current cell. we want to give the value 1 to the register R5 and LOAD it to (matrix[i][j])
	AND R5, R5, #0 ; R5 = 0
	ADD R5, R5, #1 ; R5 = 1
	STR R5, R3, #0 ; MEM[R3 + 0] = R5, so we get (matrix[i][j] = 1)
	
    
	; here, we will check if PrintFlag=2 (means we have already printed a solution for the maze):
	; if (PrintFlag=2), then we check if we are in the first cell: 
	; if yes, then we return 1 to Solve in order to print the right MSG for that (no more solutions)
	; if no, then we return 2 in order to save the fact that we have already printed a solution
	; if(PrintFlag!=0), then we simply return 0 bcz we have failed finding a solution	
    LDR R5, R6, #6 ; R5 = PrintFlag
    ADD R5, R5, #-2 ; check if (PrintFlag=2)
    BRnp RETURN_Zero_SolveMaze
    ADD R1, R1, #0 ; check if (i=0)
    BRnp RETURN_Two_SolveMaze
    ADD R2, R2, #0 ; check if (j=0)
    BRnp RETURN_Two_SolveMaze
    BR RETURN_One_SolveMaze ; BR if we are in the first cell and PrintFlag=2


	RETURN_Zero_SolveMaze:
    AND R0, R0, #0 ; R0 = 0 
	BR FinishSolveMaze

    RETURN_One_SolveMaze:
	AND R0, R0, #0 ; R0 = 0
	ADD R0, R0, #1 ; R0 = 1
	BR FinishSolveMaze
	
    RETURN_Two_SolveMaze:
    AND R0, R0, #0 ; R0 = 0
    ADD R0, R0, #2 ; R0 = 2
    BR FinishSolveMaze
	
    RETURN_MinusOne_SolveMaze:
    AND R0, R0, #0 ; R0 = 0
    ADD R0, R0, #-1 ; R0 = -1
    BR FinishSolveMaze
   
   FinishSolveMaze:
   ; at the end, we restore the backed up registers from the stack
	LDR R7, R6, #5
	LDR R5, R6, #4
	LDR R4, R6, #3
	LDR R3, R6, #2
	LDR R2, R6, #1
	LDR R1, R6, #0
	
	; Pop current stack frame (local variables + backed up registers)
	ADD R6, R6, #7	; In this case, we had 1 local variables and 6 registers backed up
   
   
RET

    SolveMaze_Mul .fill X3898
    SolveMaze_PrintMatrix .fill X3B54
    SolveMaze_StarASCII .fill #42
	SolveMaze_MinusStarASCII .fill #-42
	Minus_Y .fill #-89
	Minus_y .fill #-121
	Minus_N .fill #-78
	Minus_n .fill #-110
	MSG7 .stringz "Yummy! The mouse has found the cheese!"
	MSG8 .stringz "Would you like to see another solution? "
	


IsItSafe:

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
	LDR R4, R6, #7 ; R4 = N
	LDR R1, R6, #8 ; R1 = i
	LDR R2, R6, #9 ; R2 = j
    
	; Here's what's going to happen next:
	; R0 <- IsItSafe(MatrixPtr, N, i, j)
	
	
	; now, we want to check if (i >= 0 && i < N && j >= 0 && j < N && matrix[i][j] == 1):
	
	; Check if i>=0: if yes, keep checking other conditions. if no, return false
	ADD R1, R1, #0
	BRn RETURN_Zero_IsItSafe
	
	; Check if i<N: if yes, keep checking other conditions. if no, return false
	ADD R5, R1, #0 ; R5 = i
	NOT R5, R5
	ADD R5, R5, #1 ; R5 = -i
	ADD R5, R4, R5 ; R5 = N - i
	BRnz RETURN_Zero_IsItSafe
	
	; Check if j>=0: if yes, keep checking other conditions. if no, return false
	ADD R2, R2, #0
	BRn RETURN_Zero_IsItSafe
	
	; Check if j<N: if yes, keep checking other conditions. if no, return false
	ADD R5, R2, #0 ; R5 = j
	NOT R5, R5
	ADD R5, R5, #1 ; R5 = -j
	ADD R5, R4, R5 ; R5 = N - j
	BRnz RETURN_Zero_IsItSafe
	
	; Check if (matrix[i][j] == 1): if yes, return true. if no, return false
	ADD R3, R3, R2 ; R3 += j
	; Load parameters
	STR R4, R6, #-2 ; Store first parameter: N (columns)
	STR R1, R6, #-1 ; Store second parameter: i
	ADD R6, R6, #-2 ; Increase stack size by the number of parameters
	LD R5, IsItSafe_Mul
	JSRR R5 ; R0 = Mul(num1, num2) which will give us here (columns*i)
	ADD R6, R6, #2 ; Decrease stack size by the number of parameters
	ADD R3, R3, R0 ; R3 += columns*i, which is (columns*i + j)
	
	LDR R5, R3, #0 ; R5 = MEM[R3 + 0], that means R5 = matrix[i][j]
	ADD R5, R5, #-1 ; R5--, so we want to check if (matrix[i][j] - 1 == 0) then (matrix[i][j] == 1)
	BRnp RETURN_Zero_IsItSafe
	
	; if we made it to here, then we have successfully passed the 5 tests and we have to return 1 in R0
	AND R0, R0, #0 ; R0 = 0
	ADD R0, R0, #1 ; R0 = 1
	BR FinishIsItSafe
	
	RETURN_Zero_IsItSafe:
	; here we will return 0 in R0 and finish the function
    AND R0, R0, #0 ; R0 = 0
	
	FinishIsItSafe:
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

    IsItSafe_Mul .fill X3898

.END
