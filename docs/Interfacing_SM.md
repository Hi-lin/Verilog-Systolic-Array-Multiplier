# Interfacing State Machine
### FPGA Interfacing
1. **Idle:**  
   a. Wait until RX FIFO has size of 1, then go to state **CFM1** (Confirmation).  
   b. Send a confirmation bit containing value 0x05.
   c. Read the input bit.  
2. **CFM1:**  
   a. Set read and readin bit back to low, so the FIFO's don't leak data.  
   b. If the input bit has a LSB of 1 go to state **TD** (Transmit Data), the MAC module to transfer from dertermined by bits [4:1] in the input byte.
   c. If the input bit has a LSB of 0, wait for the RX FIFO to fill up, then go to state **RA1** (Read Array 1). 
3. **RA!:**  
   a. Reads the values in the FIFO to Array arrA. The reading process is controlled by a seperate state register RA state.  
   b. When RA state reaches the end send a confirmation bit with value 0x0A and go to state **RCFM** (Read Confirm).
4. **RCFM:**
   a. Set readin back to low.  
   b. Wait until RX FIFO is filled up, then go to state **RA2**.
5. **RA2:**
   a. Reads the values in the FIFO to Array arrB. The reading process is controlled by state registers in RAstate.  
   b. Trigger the Systolic Array calculation state machine: calcSM. To see how it works refer to Systolic_Array.md.  
   c. When RA state reaches the end send a confirmation bit with value 0x0A and go to state **FCFM** (Final Confirm).  
6. **TD:**
   a. Sends the data of the requested MAC module, this is controled by state registers in tx_state.  
   b. When finished go to state **FCFM**.  
7. **FCFM**
   a. set readin back to 0 and return to state **Idle**.
  
