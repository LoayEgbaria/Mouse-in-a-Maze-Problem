; *********, 50%
; *********, 50%
; Convention: Haifa
.ORIG X38FC
GetNum:
 
	; first of all, we increase stack size by number of registers to backup + local variables
	ADD R6, R6, #-6
	
	; Backup registers for local use
	STR R1, R6, #0
	STR R2, R6, #1
	STR R3, R6, #2
	STR R4, R6, #3
	STR R5, R6, #4
	STR R7, R6, #5 ; Backup return address like any other register


	; Here's what's going to happen next:
	; R0 <- GetNum()
	
	Start:
	AND R5, R5, #0 ; we will use R5 as a counter for the legal values (number from 0 to 9)
    AND R1, R1, #0 ; R1 is the number sign flag (1 if negative, 0 if positive)
    AND R2, R2, #0 ; R2 is the result register: we initialize it by 0

	ENTERING:
	GETC
	OUT
	
	; we check here if R0=10 (10 in ASCII is a new line):
	; if yes, then we entered ENTER on the keyboard. that mean we FINISH the program.
	; if no, continue
	ADD R0, R0, #-10 
	BRz FinishGetNum
	; if we made it to here, then we did not enter new line
	ADD R0, R0, #10 ; give back to R0 its original value
	
	; we want to check if we entered SPACE: if yes, then we call again. if no, we just continue
    LD R4, GetNum_MinusSpaceAscii
	ADD R0, R0, R4
	BRz FinishGetNum
	; if we made it to here, then we did not enter a SPACE
	LD R4, GetNum_SpaceAscii
	ADD R0, R0, R4
	
		
	; we check here if we entered "-":
	; if yes, we add 1 to the sign register (R1) that is the number sign flag:
	LD R4, GetNum_MinusSubSignAscii ; R4=-45
	ADD R0, R0, R4
	
	BRp NotMinusSign:
	ADD R1, R1, #1 ; our R1=0. so here we make it R1=1 bcz we use R1 as a sign register.
	BR ENTERING
	
	; if we made it to here, then we have called a number the ASCII value of a number between 0 and 9 (and not a minus sign).
	; what we are going to do is give to R0, the numeric value of the number itself.
	; how we do that? we just substract 48 from R0:
	NotMinusSign:
	LD R4, GetNum_SubSignAscii ; R4=45
    ADD R0, R0, R4	; R0=R0+45, give back to R0 its original value
	
	LD R4, GetNum_MinusZeroAscii ; R4-48
	ADD R0, R0, R4 ; R0=R0-48
	
	ADD R5, R5, #1 ; R5++, we will increase R5 by one bcz the user has entered a valid number
	CheckTheSign:
	; now, we need to check the sign of the number, so we can go to the right case:
	; if the number is positive: we go to PosNum label 
	; if the number is negative: we go to NegNum label 
	AND R1, R1, R1 
	BRp NegNum
	BRz PosNum
	
	NegNum:
	; here, the number is negative: R3 will be equal to 10 (so we do R2*R3), and R4 will holds R2 value (R4=R2)
	AND R3, R3, #0 ; R3=0
	ADD R3, R3, #9 ; R3=9
	AND R4, R4, #0 ; R4=0
	ADD R4, R2, #0 ; R4=R2
	
	LoopForNeg:
	ADD R2, R4, R2 ; in every LOOP, we add to R2 its original value which stored in R4
	ADD R3, R3, #-1 ; R3--
	BRp LoopForNeg
    ; now we will flip the sign of R0 in order to add it to (R2*10) and get (R2*10 - R0)
	NOT R0, R0
	ADD R0, R0, #1 ; R0 = -R0 
    ADD R2, R2, R0 ; we did here R2=R2-R0. notice that the R2 here equals to ( (previousR2=R4) * 10 )
	; if we make it to here, then the number is okay and we did update R2 very well. we can just Call again
	BR ENTERING 

	PosNum:
	; here, the number is positive: R3 will be equal to 10 (so we do R2*10), and R4 will holds R2 value (R4=R2)
	AND R3, R3, #0 ; R3=0
	ADD R3, R3, #9 ; R3=9
	AND R4, R4, #0 ; R4=0
	ADD R4, R2, #0 ; R4=R2
	
	LoopForPos:
	ADD R2, R4, R2 ; in every LOOP, we add to R2 its original value which stored in R4
	ADD R3, R3, #-1 ; R3--
	BRp LoopForPos
    ADD R2, R2, R0 ; we did here R2=R2+R0. notice that the R2 here equals to ( (previousR2=R4) * 10 )
	; if we make it to here, then the number is okay and we did update R2 very well. we can just Call again
	BR ENTERING
	

    FinishGetNum:
	; we want to check if we have entered a valid number until now:
	ADD R5, R5, #0
	BRz Start
	
	; before we finish, since we are using Haifa convention: we have to load to R0 the return value (which is stored in R2)
	ADD R0, R2, #0 ; R0 = R2
	
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

	 GetNum_MinusZeroAscii .fill #-48
     GetNum_SubSignAscii .fill #45
     GetNum_MinusSubSignAscii .fill #-45
	 GetNum_SpaceAscii .fill #32
	 GetNum_MinusSpaceAscii .fill #-32

.END