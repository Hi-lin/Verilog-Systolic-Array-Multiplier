# UART FIFO
### RX FIFO
The RX FIFO is a circular FIFO.  
When the UART receiver receives a byte, the RX FIFO:  
1. Update the size of the RX FIFO, the size would be used for control signals in other sections
2. Stores the received byte in the FIFO  

When the read signal is set HIGH the RX FIFO will.
1. Update the size of the RX FIFO
2. Changes the RX data byte to the memory at the new "head" index
  

### TX FIFO  
The TX FIFO is also a circular FIFO.
The TX FIFO will automatically send the next bit to transmit when it contains relevant data and when the transmitter module is ready. To add values to the TX FIFO.
1. Update TX Byte with the value you want to add.
2. set the readin wire to high for one clock cycle.
3. set the readin wire to low for the next clock cycle  
  


### RX/TX Modules
The actual RX and TX modules were heavily influenced by the UART code in this repository  
[Link to Repo](https://github.com/nandland/nandland/tree/master/uart/Verilog)  
  
Upon the readin wire from TX FIFO going high, the TX module would send over the data in TX Byte using the UART protocol in 9600 baud rate.  

For the RX module whenever it detects the signal being low it would wait half a bit period (sample near the center of the bit) and start reading the data into to RX Byte.
  
