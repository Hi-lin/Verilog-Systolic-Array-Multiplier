<img width="1920" height="1440" alt="ezgif com-animated-gif-maker" src="https://github.com/user-attachments/assets/ae88113f-8d7e-47d7-aadc-4255ac7eb279" />
# Systolic Array

The Systolic Array in this module consists of a 4x4 array of MAC modules, each of these modules are able to multiply inputed numbers and propogate the numbers to modules in the next rows and columns. 
  
**Timing:**
Assuming we want to multiply two 4x4 arrays: Array X and Array Y. For notation lets say X<sub>ij</sub> means the value in array X at row i column j. The timing we want to acheive to do this is
  


Looking at the animation above pay attention to the highlighted rows and columns above. Notice that starting from clock 1.  
1. column 1 & row 1 starts to shift
2. then column 2 & row 2
3. column 3 & row 3
4. and column 4 & row 4
5. Then column 1 & row 1 stops to shift and so on

In the timing animation, whenever a MAC revieves a new value, it will always propogate the value to the value forward to the next two MACs in the row/column. So, in this project, the MACs are designed to automatically send the values forward at every clock.  
In addition, to control the timing, an array called indexing is created. When indexing[i] is high, on the next clock cycle.
1. triggers the leading MAC in row i & column i to read the next value in their respective row/column.
2. shifts all values in row<sub>i</sub> of arrA and row<sub>i</sub> of arrB forward by one.
3. indexing[i] is replaced by the value in indexing[i-1] on each clock cycle. So, by setting i[0] as high, all values in indexing would eventually be set to high.
  
A state machine called calcSM was used to time inputing the value of indexing[0]
1. at state 1 indexing[0] is set with high
2. at state 5 indexing[0] is set with low 
3. After 7 cycles all the MACs should have gotten all the numbers they need to find the product of.

This will allow all the numbers to flow with the right timing.

# Decisions  
The main decision I made in this section was how I wanted to read the values in arrA and arrB into the leading MAC. My first idea was to use gate logic to manually assign each edge MAC with the designated value inside arrA and arrB at every state. However that required a lot of gates. So, I decided to use the current design of shifting arrA and arrB. This minimizes gate usage because there is only one connection between arrA/arrB and each edge MAC.
