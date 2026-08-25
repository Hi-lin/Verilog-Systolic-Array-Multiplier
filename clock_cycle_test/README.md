# Clock Cycle Testing  
## Test Files  
The source files used to test the clock cycles.
### Baseline Multiplier  
The baseline multiplier works similarly to software implementations of matrix multiplication. The multiplier systematically 
computes each output element by taking the dot product of a row from the first matrix with a column from the second matrix. 
Each multiply-accumulate operation is performed sequentially, with the resulting product added to the corresponding element 
of the output matrix.  
Clock cycles are counted from start of matrix computation to completion.
### Systolic Array Multiplier  
The systolic array multiplier uses the same module as the one provided in the deliverables, with an additional register 
to count the clock cycles required for the operation.  
Clock cycles are counted from start of matrix computation to completion.
### C host program
Same program as the test code provided in deliverables/tests/Test_Code.

### Videos
A recording of the clock cycle comparison between baseline and systolic array multiplier. The measured cycles is displayed on
the LEDs at the bottom of the FPGA in base 2.
