`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 08:58:16 PM
// Design Name: 
// Module Name: new_top
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


module new_top(
    input CLK100MHZ,
    input [5:0]sw,
    input rx,
    output UART_TXD,
    output reg [12:0]LED
    );
    reg read = 0;
    wire [7:0]rx_byte;
    wire rx_full;
    wire[4:0] rx_size;
    rx_fifo #(
    .CLKS_PER_BIT(10417)      // 100 MHz / 115200 baud
    ) rx_fifo1 (
        .clk(CLK100MHZ),
        .read(read),
        .rx(rx),
        .byte(rx_byte),
        .full(rx_full),
        .size(rx_size)
        );
        
    reg[7:0] tx_byte;
    reg readin = 0;
    tx_fifo #(
    .CLKS_PER_BIT(10417)      // 100 MHz / 115200 baud
    ) tx_fifo1 (
        .clk(CLK100MHZ),
        .byte(tx_byte),
        .readin(readin),
        .full(),
        .UART_TXD(UART_TXD)
        );

    reg [7:0]A[3:0][3:0];
    reg [7:0]B[3:0][3:0];
    reg readinTTY[3:0][3:0];
    reg readinTTX[3:0][3:0];
    wire [31:0]out_num[3:0][3:0];
    reg [31:0] finout;
    reg reset = 0;
    genvar i;
genvar j;
generate
    for(i = 0; i<4; i = i+1) begin: stage1
        for(j = 0; j<4; j = j+1) begin: stage2
            AddCore core(
                .clk(CLK100MHZ),
                .iA1(A[i][j]),
                .iB1(B[i][j]),
                .reset(reset),
                .readinA(readinTTX[i][j]),
                .readinB(readinTTY[i][j]),
                .out_num(out_num[i][j]),
                .A(),
                .B(),   
                .readoutA(),
                .readoutB()
            );
        end
    end
endgenerate
            
            reg [2:0]mainSM = 0;
            parameter IDLE = 3'b000;
            parameter CFM1 = 3'b001;
            parameter RA1 = 3'b010;
            parameter RCFM = 3'b011;
            parameter RA2 = 3'b100;
            parameter TD = 3'b101;
            parameter FCFM = 3'b111;
            reg [7:0]inVal = 0;
            
            reg [4:0]RAstate = 0;
            wire [1:0]x = RAstate[2:1];
            wire [1:0]y = RAstate[4:3];
            reg [7:0]arrA[3:0][3:0];
            reg [7:0]arrB[3:0][3:0];
            reg [2:0] tx_state = 0;
            wire [1:0]trans_x;
            wire [1:0]trans_y;
            reg CALC= 0;
            reg [6:0] calcSM = 64;
            wire [1:0]calcSMx;
            wire [1:0]calcSMy;
            wire [1:0]calcSMz;
            assign calcSMx = calcSM[5:4];
            assign calcSMy = calcSM[3:2];
            assign calcSMz = calcSM[1:0];
            reg [3:0] indexing = 0;
            assign trans_x = inVal[4:3];
            assign trans_y = inVal[2:1];
            reg [7:0] cycle_count = 0;
            reg counting = 0;
            reg [7:0] latency = 0;
            integer ai, aj;
            
    always@(posedge CLK100MHZ) begin
        for (ai = 0; ai < 4; ai = ai + 1) begin
            for (aj = 0; aj < 4; aj = aj + 1) begin
                readinTTX[ai][aj] <= 0;
                readinTTY[ai][aj] <= 0;
            end
        end
        if(mainSM == IDLE)begin
            reset<=0;
            if(rx_size != 4'b0000) begin
                inVal<=rx_byte;
                mainSM<=CFM1;
                read<=1;
                tx_byte<=5;
                readin<=1;
            end
        end
        if(mainSM == CFM1) begin
            read<=0;
            readin<=0;
            if(inVal==8'b11111111) begin
                reset<=1;
                mainSM<=FCFM;
            end
            else begin
                if(inVal[0]) begin
                    finout<=out_num[trans_y][trans_x];
                    mainSM<=TD;
                end
                if(~inVal[0] && rx_size[4]) begin
                    mainSM<=RA1;
                end
            end
        end
        
        if(mainSM == RA1) begin
            if(RAstate == 5'b11111) begin
                mainSM<=RCFM;
                RAstate<=0;
                read<=0;
                tx_byte<=10;
                readin<=1;
            end
            else begin
                RAstate<=RAstate+1;
                arrA[x][y]<=rx_byte;
                read<=~RAstate[0];
            end
        end
        
        if(mainSM == RCFM) begin
            readin<=0;
            if(rx_size[4])begin
                mainSM<=RA2;
            end
        end
        
        if(mainSM == RA2) begin
            if(RAstate == 5'b11111) begin
                mainSM<=FCFM;
                RAstate<=0;
                read<=0;
                tx_byte<=10;
                readin<=1;
                calcSM<=0;
            end
            else begin
                RAstate<=RAstate+1;
                arrB[x][y]<=rx_byte;
                read<=~RAstate[0];
            end
        end
        
        if(mainSM == TD) begin
            if(tx_state == 3'b111) begin
                tx_state<=0;
                mainSM<=FCFM;
                readin<=0;
            end
            else begin
                tx_state<=tx_state+1;
                case({tx_state[2:1]}) 
                    2'b00: tx_byte<=finout[31:24];
                    2'b01: tx_byte<=finout[23:16];
                    2'b10: tx_byte<=finout[15:8];
                    2'b11: tx_byte<=finout[7:0];
                    default: tx_byte<=finout[31:24];
                endcase
                readin<=~tx_state[0];
            end
        end
        
        if(mainSM == FCFM) begin
            readin<=0;
            mainSM<=IDLE;
        end
        
        // END OF FSM

        if(calcSM != 64) begin
            if(calcSM==0) begin
                cycle_count <= 2;
                counting <= 1; //+1 because it ends right when 63 is passed in, which still requires a clock cycle to process
            end
            A[calcSMx][calcSMy]<=arrA[calcSMz][calcSMx];
            B[calcSMx][calcSMy]<=arrB[calcSMy][calcSMz];
            readinTTX[calcSMx][calcSMy]<=1;
            readinTTY[calcSMx][calcSMy]<=1;
            calcSM<=calcSM+1;
            if(calcSM == 63)begin
                LED <= cycle_count;
                counting <= 0;
                
            end
        end
        if (counting) begin
            cycle_count <= cycle_count + 1;
        end         
    end
endmodule
