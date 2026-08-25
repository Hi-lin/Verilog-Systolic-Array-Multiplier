`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2026 11:29:18 PM
// Design Name: 
// Module Name: rx_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx_fifo
#(parameter CLKS_PER_BIT= 10417)
(
    input clk,
    input read,
    input rx,
    output reg [7:0] byte,
    output full,
    output reg [4:0] size
    );
    reg [7:0] vals[15:0];
    reg [3:0] head = 0;
    reg [3:0] tail = 0;
    reg[4:0] size = 0;
    wire rx_done;
    wire [7:0] rx_byte;
    wire contains = (size != 0);
    assign full = size[4];
    reg [2:0] sm = 0;
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)      // 100 MHz / 115200 baud
    ) RX (
        .i_Clock(clk),
        .i_Rx_Serial(rx),
        .o_Rx_DV(rx_done),
        .o_Rx_Byte(rx_byte),
        .sm()
    );
    
    reg last = 0;
    wire trig = read&~last;
    wire push = rx_done & ~full;
    wire pop  = trig && contains;
    always@(posedge clk) begin
        if(push) begin
            head<=head+1;
            vals[head]<=rx_byte;
        end
        
        // send out
        
        if(pop)begin
            tail<=tail+1;
            
        end
        last <= read;
        //change
        
        case({push,pop}) 
            2'b10: size<=size+1;
            2'b01: size<=size-1;
            default: size<=size;
        endcase
    end
    always@(*) begin
        byte<=vals[tail];
    end
endmodule
