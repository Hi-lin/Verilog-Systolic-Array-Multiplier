# Interfacing State Machine
### FPGA Interfacing
1. **Idle:**  
   a. Wait until RX FIFO has size of 1, then transition to state **CFM1** (Confirmation).  
   b. Send a confirmation byte with a value of 0x05.
   c. Read the input byte.  
2. **CFM1:**  
   a. Set read and readin signals back to low, so the FIFOs don't leak data.  
   b. If the input byte has a LSB of 1, transition to state **TD** (Transmit Data). The MAC module to transfer from determined by bits [4:1] of the input byte.
   c. If the input byte has a LSB of 0, wait for the RX FIFO to fill up, then transition to state **RA1** (Read Array 1). 
3. **RA1:**  
   a. Reads the values in the FIFO to Array arrA. The reading process is controlled by a separate state register RA state.  
   b. When RA state reaches the end send a confirmation byte with value 0x0A and transition to state **RCFM** (Read Confirm).
4. **RCFM:**
   a. Set readin back to low.  
   b. Wait until RX FIFO is filled up, then transition to state **RA2**.
5. **RA2:**
   a. Reads the values in the FIFO to Array arrB. The reading process is controlled RAstate state register.  
   b. Trigger the systolic array calculation state machine: calcSM. For more information, refer to Systolic_Array.md.
   c. When RA state reaches the end send a confirmation byte with value 0x0A and transition to state **FCFM** (Final Confirm).  
6. **TD:**
   a. Sends the data of the requested MAC module, this is controlled by state registers in tx_state.  
   b. When finished transition to state **FCFM**.  
7. **FCFM**
   a. Set readin back to 0 and return to state **Idle**.

  ### Communicating With the FPGA
To interface with this state machine, first send the instruction corresponding to the operation you want to perform.
1. Perform a calculation  
  a. send array 1.
  b. wait for confirmation byte.
  c. send array 2.
2. Get a value
   a. Assuming the first instruction was sent correctly, wait for the requested value. The value is sent as four separate bytes, with the most significant byte sent first.
