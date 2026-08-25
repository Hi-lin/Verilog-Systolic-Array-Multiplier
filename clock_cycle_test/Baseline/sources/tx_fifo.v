`timescale 1ns / 1ps

module tx_fifo
#(parameter CLKS_PER_BIT= 1041)
(
    input clk,
    input [7:0] byte,
    input readin,
    output full,
    output UART_TXD
    );
    reg [7:0] vals[15:0];
    reg [3:0] head = 0;
    reg [3:0] tail = 0;
    reg [4:0] size = 0;
    wire txdone;
    reg [7:0] txbyte;
    reg txd = 0;
    wire contains = (size != 0);
    reg smtx = 0; 
    reg [1:0] change;
    assign full = size[4];
    wire txA;
        uart_tx2 #(
        .CLKS_PER_BIT(CLKS_PER_BIT)       // 100 MHz / 115200
    ) TX (
        .i_Clock(clk),
        .i_Tx_DV(txd),
        .i_Tx_Byte(txbyte),
        .o_Tx_Active(txA),
        .o_Tx_Serial(UART_TXD),
        .o_Tx_Done(txdone),
        .sm1()
    );
    
    reg last = 0;
    wire trig = readin&~last;
    wire push = trig;
    wire pop  = !smtx && contains;
    always@(posedge clk) begin
        if(trig ==1) begin
            head<=head+1;
            vals[head]<=byte;
        end
        last <= readin;
        
        // send out
        
        if(txdone)begin
            smtx <= 0;
        end
        if(!smtx && contains)begin
            smtx<=1;
            tail<=tail+1;
            txd<=1;
            txbyte<=vals[tail];
        end
        else begin
            txd<=0;
        end
        
        //change
        
        case({push,pop}) 
            2'b10: size<=size+1;
            2'b01: size<=size-1;
            default: size<=size;
        endcase
    end
    
    
endmodule
