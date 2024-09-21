# Mouse in a Maze Problem (Backtracking)

## Overview

In this exercise, you will solve the classic "Mouse in a Maze" problem using exhaustive search (backtracking brute force), implemented exclusively through functions. No subroutines are allowed in the solution. Functions must adhere to a consistent coding convention.


## Problem Definition

The Mouse in a Maze problem involves finding a path from point A (top-left corner) to point B (bottom-right corner) in a maze represented by a square matrix. The cells of the matrix contain either 1 (path) or 0 (wall), and the objective is to find a valid route from the start to the goal, if it exists.

  • **Maze Representation:** A square matrix of size N x N where N is an integer between 2 and 20.

  • **Start Point:** The top-left corner (0,0).

  • **End Point:** The bottom-right corner (N-1, N-1).

  • **Valid Moves:** You can only move left, right, up, or down into cells that contain 1. No diagonal movements are allowed, and you cannot move outside the matrix bounds.


## Input Requirements

 1) Matrix Size Input (N): The user enters a positive integer N (between 2 and 20).

 2) Maze Matrix Input: The user inputs an N x N matrix where each cell is either 1 (path) or 0 (wall).

 The program will validate the following conditions:

  • The matrix must contain only 0 or 1 values.

  • The starting point (0,0) and the end point (N-1,N-1) must both contain the value 1.

If any condition fails, an error message will be displayed, and the user will be asked to input the matrix again.


## Program Flow

1) Matrix Size Input: The user will first be prompted to enter a matrix size N.

2) Maze Input: The user will input the maze matrix with correct formatting.

3) Matrix Validation: The program will check if the matrix meets the required conditions:
   
     • Only contains 0 and 1.

     • The top-left and bottom-right corners contain 1. If invalid, an error message is displayed, and the input process restarts.

4) Pathfinding: The program will search for a valid path from (0,0) to (N-1,N-1) using backtracking.
   
   • If a valid path is found, it will be printed with the path marked as *.

   • If no path is found, an appropriate message is displayed.

5) Multiple Solutions: After finding a solution, the user will be asked if they want to see another solution. The program will provide up to 3 distinct solutions if available.

6) Bonus: A 10-point bonus is awarded if the program supports finding all possible solutions.


## Functions to Implement

1) **GetNum:** Reads and returns the integer N (the size of the matrix).
   
2) **GetMatrix:** Reads and returns the maze matrix based on the size N.
   
3) **PrintMatrix:** Prints the maze matrix with spaces between the values. If a valid path is found, the path is marked with *.

  
## User Prompts and Messages

• **Matrix Size Input:** 
  "Please enter a number between 2 to 20: "

• **Maze Input:**
  "Please enter the maze matrix: "

• **Error in Matrix Input:**
  "Illegal maze! Please try again: "

• **Valid Maze:**
  "The mouse is hopeful he will find his cheese. "

• **Solution Found:**
  "Yummy! The mouse has found the cheese! "

• **No Solution Found:**
 "OH NO! It seems the mouse has no luck in this maze. "

• **•Another Solution Query:**
  "Would you like to see another solution? "

• **No Additional Solutions:**
  "OH NO! It seems the mouse could not find another solution for this maze. "


## Example Input/Output

### Example 1:

Please enter a number between 2 to 20: 3

Please enter the maze matrix:

1 0 0

1 1 1

0 1 1

The mouse is hopeful he will find his cheese.

Yummy! The mouse has found the cheese!

#### * 0 0
  
#### * * *

#### 0 1 *

Would you like to see another solution? Y

Yummy! The mouse has found the cheese!

#### * 0 0
  
#### * * 1
    
#### 0 * *

Would you like to see another solution? Y

OH NO! It seems the mouse could not find another solution for this maze.

______________________________________________________________________________

### Example 2:

Please enter a number between 2 to 20: 5

Please enter the maze matrix:

1 0 0 0 0

1 0 0 1 0

1 0 0 1 0

1 1 1 1 0

0 0 0 0 1

The mouse is hopeful he will find his cheese.

OH NO! It seems the mouse has no luck in this maze.


## Bonus Feature

If implemented, the program will find all possible solutions for the maze, instead of being limited to 3 solutions.



