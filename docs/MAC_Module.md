# MAC_Module
This module is able to multiply two numbers and add it to a running total. The following is a step by step of what it module does.

Only when readinA and readinB are high will this module start execution, this mechanism is used to control the timing of each module in the systolic array.  
The input numbers for this module are A and B

### 1. Radix 4 Booth encoding
The first step is booth encoding. The goal of this step is to find 4 numbers which sum to the product of A*B. Each MAC module contains 4 booth encoder modules refered to as "b1, b2, b3, and b4" each boothcoder contains  
**Inputs:**  
1. 3 bits of input A<<1: booth encoder i will recieve bits 2i-2 to 2i inclusive of shifted input A<<1. For example, if A = 11001010 it would be partitioned from 4-1 [110], [001], [101], and [100] with the last bit caused by the shift.
2. The value of input B left shifted by 2i-2.
3. The value of 2B left shifted by 2i-2.
4. The value of -B left shifted by 2i-2.
5. The value of -2B left shifted by 2i-2.
  
**Outputs:**
This module is essentially a mux, outputing a direct copy of inputs 2,3,4, or 5 depending on the input of 1. The output follows the rules below.  
**case (input 1)**  
            3'b000: out = 0;    
            3'b001: out = input 2;  
            3'b010: out = input 2;  
            3'b011: out = input 3;  
            3'b100: out = input 5;   
            3'b101: out = input 4;  
            3'b110: out = input 4;  
            3'b111: out = 0;
   
Adding all of these outputs would yield the product of A*B.  

### 2. Carry-Save Reduction (module adder2 in verilog file)
The next step is carry save reduction. We have already created a list of things to add in out last step. By using carry save reduction, we can reduce the number of things to add down to two.  

**Input:**  Each carry save adder module in the project takes in 3 inputs (3 things needed to add).  
**output:** The output returns two numbers o1 and c1
