## Video Link
https://drive.google.com/file/d/1HCRFZeb2YT2hERByI_wB5E5b1L1Vektu/view?usp=sharing

## Test Code
The test code consists of 3 sections
### lines 15-51
Initializing and setting up the UART serial port on computer.

### lines 7-13
Function that creates a 4x4 array containing random usigned integers between 0-255.

### lines 64-end
In the for function it will repeatedly  
1. lines 164-192: reset the FPGA 
2. lines 193-236: generate two random arrays, A & B, and write them to the FPGA.
3. lines 237-248: calculates the correct array multiplication result of AxB.
4. lines 256-end: compare the found values in the previous step to the values read from the FPGA:  
   prints success if all the numbers match, prints fail if it detects inconsistency.
  
