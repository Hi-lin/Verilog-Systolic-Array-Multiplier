# Overview

This is a broad overview of the structure, for more specifics of each component go see the module specific files inside the docs folder.

<img width="2500" height="1406" alt="Structual_Overview (1)" src="https://github.com/user-attachments/assets/d7a5fcd4-85f3-4408-bf92-42516331bc03" />

## Systolic Array
The Systolic Array is a design that optimizes matrix calculations by utilizing parallelism between multiple individual calculations in an array.   
This project contains a 4x4 systolic array of MAC (Multiply Accumulate) modules. Each of these MAC modules will 
1. be able to recieve two numbers (X and Y) as input
2. multiply the numbers
3. add the product to a running total
4. propogate X and Y to the next module in the row and column resptectively
  
The heart of the systolic array is the propogation of numbers along each individual row and column. By percisely timing when to propogate each number across a row/column the systolic array is able to do matrix operations in O(n) clock cycles, much faster than traditional CPU's.
  
## MAC Modules  
As previously mentioned these modules are required to moltiply two numbers and add the value to a running sum. To try and optimize speed and gate space, this modules includes the following steps for data calculation.
1. **Radix 4 Booth Encoding**  
  This step turns a gate multiplication problem into a list of numbers to add.
2. **Carry Save Reduction**  
   This step takes in 3 numbers and returns two numbers whose sume is equal to the sum of the original 3 numbers. So, this decreases the numbers the module needs to add by one. Unfortunately, this method is unable to decrease the numbers to add past 2.  
3. **Kogge-Stone Adder**
  The Kogge-Stone Adder will add the last two numbers to find the final result of the multiplication.
  
## TX/RX FIFO  
The TX FIFO is the transmit FIFO module. This module will store the data that needs to be transmitted in the order it was recieved.  
The RX FIFO is the recieve FIFO module, it stores the incoming data. In addition there is a size variable on the RX FIFO which will be used for consitionals in state machiens.

**UART TX/RX:**
Transmits/Recieves data from the FPGA. It uses stardard UART protocol with 1 start bit, one stop bit, zero parity bits, and 9600 Baud Rate.

## Interfacing State Machine
This is the overarching state machine for this project. This state machine interfaces with the TX/RX FIFO modules and the systolic array to communicate the computer's instructions to the Array and send data from the Array back to the computer.   
Essentially it outlines how to communicate with the systolic array using UART connections.

