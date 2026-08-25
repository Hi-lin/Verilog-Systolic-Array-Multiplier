# Overview

This section provides a broad overview of the system architecture. For more details on each component, see the corresponding module-specific files in the docs folder.

<img width="2500" height="1406" alt="Structual_Overview (1)" src="https://github.com/user-attachments/assets/d7a5fcd4-85f3-4408-bf92-42516331bc03" />

## Systolic Array
The systolic array is a design that optimizes matrix calculations by utilizing parallelism between multiple individual calculations in an array.   
This project contains a 4x4 systolic array of MAC (Multiply Accumulate) modules. Each of these MAC modules: 
1. Receives two numbers (X and Y) as inputs.
2. Multiplies the numbers
3. Adds the product to a running total
4. Propagates X and Y to the next module in the row and column respectively
  
The heart of the systolic array is the propagation of numbers along each individual row and column. By precisely timing when to propagate each number across a row/column, the systolic array can often perform matrix operations in fewer clock cycles than the baseline multiplier used.
  
## MAC Modules  
As previously mentioned these modules are used to multiply two numbers and add the value to a running sum. To optimize performance while minimizing hardware resource usage, this module includes the following steps for data calculation.
1. **Radix 4 Booth Encoding**  
  This step converts the multiplication operation into a set of partial products.
2. **Carry Save Reduction**  
   This step takes in three numbers and returns two numbers whose sum is equal to the sum of the original three numbers. While it is a very powerful reduction technique it cannot reduce the number of operands below two so an addition adder is needed.
3. **Kogge-Stone Adder**
  The Kogge-Stone adder adds the final two operands to produce the multiplication result.
  
## TX/RX FIFO  
The TX FIFO is the transmit FIFO module. This module will store the data that needs to be transmitted in the order it was received.  
The RX FIFO is the receive FIFO module, it stores the incoming data. In addition there is a size variable on the RX FIFO which will be used for conditionals in state machine.

**UART TX/RX:**
Transmits/Receives data from the FPGA. It uses standard UART protocol with 1 start bit, one stop bit, zero parity bits, and 9600 Baud Rate.

## Interfacing State Machine
This is the overarching state machine for this project. This state machine interfaces with the TX/RX FIFO modules and the systolic array to communicate the computer's instructions to the array and send data from the array back to the computer.   
Essentially, it defines how instructions and data are communicated between the computer and the systolic array over UART.

