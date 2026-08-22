# UART FIFO
### RX FIFO
The RX FIFO is a wrap around FIFO.  
When the UART FIFO recieves data it will.   
1. Update the size of the RX FIFO, the size would be used for control signals in other sections
2. Adds value to the UART FIFO  

When the read line is set to HIGH the RX FIFO will.
1. Update the size of the RX FIFO.
2. Changes the RX data byte to the memory at the new "head" index
  

### TX FIFO  
The TX FIFO is also a wrap around FIFO.
The TX FIFO will automatically send the next bit to transmit when it contains relevant data and when the transmitter module is ready. To add values to the TX FIFO.
1. Update RX Byte with the value you want to add.
2. set the readin wire to high for one clock cycle.
3. set the readin wire to low for the next clock cycle  
  


### RX/TX Modules
The actual RX and TX modules were heavily influenced by the UART code in this repository  
[Link to Repo](https://github.com/nandland/nandland/tree/master/uart/Verilog)  
  
TX module sends 
