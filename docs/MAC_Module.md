# MAC_Module
This module multiplies two numbers and adds the result to a running total. The following section provides a step-by-step explanation of the module.

The module begins execution only when both readinA and readinB are high. These signals control the timing of each MAC module within the systolic array.
The input numbers for this module are A and B, and their product is added to running total out_num.

### 1. Radix 4 Booth encoding
The first step is Booth encoding. The goal of this step is to find 4 numbers which sum to the product of A*B. Each MAC module contains four Booth encoder modules, referred to as b1, b2, b3, and b4. Each Booth encoder contains the following inputs:
**Inputs:**  
1. 3 bits of input A<<1: Booth encoder i will receive bits 2i-2 to 2i inclusive of shifted input A<<1. For example, if A = 11001010, then A << 1 = ..., which is partitioned into the groups [110], [001], [101], and [100] using the specified indexing convention.
2. The value of input B left shifted by 2i-2.
3. The value of 2B left shifted by 2i-2.
4. The value of -B left shifted by 2i-2.
5. The value of -2B left shifted by 2i-2.
  
**Outputs:**
The Booth encoder selects one of the five possible values based on the 3-bit Booth encoding:
**case (input 1)**  
            3'b000: out = 0;    
            3'b001: out = input 2;  
            3'b010: out = input 2;  
            3'b011: out = input 3;  
            3'b100: out = input 5;   
            3'b101: out = input 4;  
            3'b110: out = input 4;  
            3'b111: out = 0;
   
Booth encoder b1 returns partial[0], b2 returns partial[1], and so on until b4.  
Adding all of these outputs would yield the product of A*B.  

### 2. Carry-Save Reduction (module adder2 in verilog file)
The next step is carry save reduction. We have already created a list of operands to add in out previous step. By using carry save reduction, we can reduce the number of things to add down to two.  

**Input:**  Each carry save adder module in the project takes three inputs (X1, X2, X3).  
**output:** The output returns two numbers o1(base output) and c1 (carry output).
1. o1 = X1^X2^X3
2. c1 = (X1&X2)|(X1&X3)|(X2&X3)

The output is such that o1+(c1<<1) is equal to the sum of X1+X2+X3  

**The module contains 3 carry save adders:** 
1. add1 takes partial[0], partial[1], partial[2] and returns res1[0] as o1 and res1[1] as c1  
2. add2 takes partial[3], res1[0], res1[1]<<1 and returns res2[0] as o1 and res2[1] as c1
3. add3 takes out_num, res2[0], res2[1]<<1 and returns res3[0] as o1 and res3[1] as c1  

By including out_num in the third carry-save reduction, the running total is incorporated into the multiplication during the same reduction process, eliminating the need for a separate addition afterward.

### 3. Kogge-Stone Adder
The final step is to add the two remaining values. In this project this is done using the Kogge-Stone adder. First I'll go over some information.  
1. The two numbers I will add in this last step will be called X1 and X2.
2. G[i:j] indicates whether the bit range from i through j generates a carry out of the group.
3. P[i:j] indicates whether an incoming carry will propagate through the entire bit range from i to j.
4. To merge two intervals we realize that G[i1:j2] = G[i1:j1] | (P[i1:j1]&G[i2:j2])
5. We also realize that merging two P terms is just P[i1:j2] = P[i1:j1] & P[i2:j2]
6. Initially, I will populate **G0** with:  res3[0] & (res3[1]<<1)
7. Initially, I will populate **P0** with:  res3[0] ^ (res3[1]<<1)

Since the sum is 17 bits I will use ceil(log₂(17))= 5 stages for the Kogge-Stone Adder, I will call then stages 1-5.

**For stage k of the Kogge-Stone Adder:**  
For each stage k, each bit is merged with the bit 2^(k-1) positions earlier. This doubles the range covered by the prefix calculation at each stage. 
  
By the end of the fifth stage, the carry information for every bit has been calculated. The final sum is then calculated as: 
**G5[15:0]^P0[16:1] for bits 1-17**  
**P0[0] for bit 0**  
