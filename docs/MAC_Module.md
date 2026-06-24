# MAC_Module
This module is able to multiply two numbers and add it to a running total. The following is a step by step of what it module does.

Only when readinA and readinB are high will this module start execution, this mechanism is used to control the timing of each module in the systolic array.  
The input numbers for this module are A and B, and their product is added to running total out_num.

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
   
Booth encoder b1 returns partial[0], b2 returns partial[1], and so on until b4.  
Adding all of these outputs would yield the product of A*B.  

### 2. Carry-Save Reduction (module adder2 in verilog file)
The next step is carry save reduction. We have already created a list of things to add in out last step. By using carry save reduction, we can reduce the number of things to add down to two.  

**Input:**  Each carry save adder module in the project takes in 3 inputs (X1, X2, X2).  
**output:** The output returns two numbers o1(base output) and c1 (carry output).
1. o1 = X1^X2^X3
2. o2 = (X1&X2)|(X1&X3)|(X2&C3)

The output is such that o1+(o2<<1) is equal to the sum of X1+X2+X3  

**The module contains 3 carry save adders:** 
1. add1 takes partial[0], partial[1], partial[2] and returns res1[0] as o1 and res1[1] as c1  
2. add2 takes partial[3], res1[0], res1[1]<<1 and returns res2[0] as o1 and res2[1] as c1
3. add3 takes out_num, res2[0], res2[1]<<1 and returns res3[0] as o1 and res3[1] as c1  

By including out_num in step 3 we don't have to add the running total later.

### 3. Kogge-Stone Adder
The final step is to add the two remaining values. In this project this is done using the Kogge-Stone adder. First I'll go over some information.  
1. The two numbers I will add in this last step will be called X1 and X2.
2. G[i:j] - if true it means that X1[i:j]+X2[i:j] will create a carry in bit i+1.
3. P[i:j] - if true it means that X1[i:j]+X2[i:j] will result in 1 bits from i to j. Or in otherwords, adding any additional number will create a carry.
4. To merge two intervals we realize that G[i1:j2] = G[i1:j1] | (P[i1:j1]&G[i2:j2])
5. We also realize that merging two P terms is just P(i1:j2) = P(i1:j1) & P(i2:j2)
6. Initially, I will populate **G0** with:  res3[0] & (res3[1]<<1)
7. Initially, I will populate **P0** with:  res3[0] * (res3[1]<<1)

Since the sum is 17 bits I will use ceil(log(17))= 5 stages for the Kogge-Stone Adder, I will call then stages 1-5.

**For stage 1 of the Kogge-Stone Adder:**  
In this stage we will take inputs G0 and P0 and merge each bit with bit i-1 to create G1 and P1 such that G1[i] = G[i:i-1] for all bits in G1 and P1[i] = P[i:i-1] for all bits in P1.  
  
**For stage 2 of the Kogge-Stone Adder:** 
In this stage we will take inputs G1 and P1 and merge each bit with bit i-2 to create G2 and P2. Remember each bit in G1 is already equal to G[i:i-1] so after merging: G2[i] = G[i:i-3] for all bits in G2 and P2[i] = P[i:i-3] for all bits in P2.  
  
**For stage k of the Kogge-Stone Adder:** 
Repeat the previous steps 5 times, taking G<sub>k-1(/sub) and P<sub>k-1(/sub) and merge each bit with bit i-2<sup>k-1(/sup) and save the result in G<sub>K</sub> and Pk<sub>K</sub>.  
  
By the the value of G[i:0] for all i is stored in G5[i]. Then, the module gets the final answer which is just  
**G5[15:0]^P0[16:1] for bits 1-17**  
**P0[0] for bit 0**  
