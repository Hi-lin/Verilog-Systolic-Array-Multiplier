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

    reg [7:0]A1[3:0];
    reg [7:0]B1[3:0];
    wire [7:0]A[3:0][3:0];
    wire [7:0]B[3:0][3:0];
    wire readinTTY[3:0][3:0];
    wire readinTTX[3:0][3:0];
    wire [31:0]out_num[3:0][3:0];
    reg [31:0] finout;
    reg reset = 0;
    genvar i;
genvar j;
generate
    for(i = 1; i<3; i = i+1) begin: stage1
        for(j = 1; j<3; j = j+1) begin: stage2
            AddCore core(
                .clk(CLK100MHZ),
                .iA1(A[i][j]),
                .iB1(B[i][j]),
                .reset(reset),
                .readinA(readinTTX[i][j]),
                .readinB(readinTTY[i][j]),
                .out_num(out_num[i][j]),
                .A(A[i+1][j]),
                .B(B[i][j+1]),   
                .readoutA(readinTTX[i+1][j]),
                .readoutB(readinTTY[i][j+1])
            );
        end
    end
endgenerate

AddCore core00(
                .clk(CLK100MHZ),
                .iA1(arrB[0][0]),
                .iB1(arrA[0][0]),
                .reset(reset),
                .readinA(indexing[0]),
                .readinB(indexing[0]),
                .out_num(out_num[0][0]),
                .A(A[1][0]),
                .B(B[0][1]),   
                .readoutA(readinTTX[1][0]),
                .readoutB(readinTTY[0][1])
            );
AddCore core10(
                .clk(CLK100MHZ),
                .iA1(A[1][0]),
                .iB1(arrA[0][1]),
                .reset(reset),
                .readinA(readinTTX[1][0]),
                .readinB(indexing[1]),
                .out_num(out_num[1][0]),
                .A(A[2][0]),
                .B(B[1][1]),   
                .readoutA(readinTTX[2][0]),
                .readoutB(readinTTY[1][1])
            );
AddCore core20(
                .clk(CLK100MHZ),
                .iA1(A[2][0]),
                .iB1(arrA[0][2]),
                .reset(reset),
                .readinA(readinTTX[2][0]),
                .readinB(indexing[2]),
                .out_num(out_num[2][0]),
                .A(A[3][0]),
                .B(B[2][1]),   
                .readoutA(readinTTX[3][0]),
                .readoutB(readinTTY[2][1])
            );
AddCore core30(
                .clk(CLK100MHZ),
                .iA1(A[3][0]),
                .iB1(arrA[0][3]),
                .reset(reset),
                .readinA(readinTTX[3][0]),
                .readinB(indexing[3]),
                .out_num(out_num[3][0]),
                .A(),
                .B(B[3][1]),   
                .readoutA(),
                .readoutB(readinTTY[3][1])
            );
AddCore core31(
                .clk(CLK100MHZ),
                .iA1(A[3][1]),
                .iB1(B[3][1]),
                .reset(reset),
                .readinA(readinTTX[3][1]),
                .readinB(readinTTY[3][1]),
                .out_num(out_num[3][1]),
                .A(),
                .B(B[3][2]),   
                .readoutA(),
                .readoutB(readinTTY[3][2])
            );
AddCore core32(
                .clk(CLK100MHZ),
                .iA1(A[3][2]),
                .iB1(B[3][2]),
                .reset(reset),
                .readinA(readinTTX[3][2]),
                .readinB(readinTTY[3][2]),
                .out_num(out_num[3][2]),
                .A(),
                .B(B[3][3]),   
                .readoutA(),
                .readoutB(readinTTY[3][3])
            );
AddCore core33(
                .clk(CLK100MHZ),
                .iA1(A[3][3]),
                .iB1(B[3][3]),
                .reset(reset),
                .readinA(readinTTX[3][3]),
                .readinB(readinTTY[3][3]),
                .out_num(out_num[3][3]),
                .A(),
                .B(),   
                .readoutA(),
                .readoutB()
            );
AddCore core23(
                .clk(CLK100MHZ),
                .iA1(A[2][3]),
                .iB1(B[2][3]),
                .reset(reset),
                .readinA(readinTTX[2][3]),
                .readinB(readinTTY[2][3]),
                .out_num(out_num[2][3]),
                .A(A[3][3]),
                .B(),   
                .readoutA(readinTTX[3][3]),
                .readoutB()
            );
AddCore core13(
                .clk(CLK100MHZ),
                .iA1(A[1][3]),
                .iB1(B[1][3]),
                .reset(reset),
                .readinA(readinTTX[1][3]),
                .readinB(readinTTY[1][3]),
                .out_num(out_num[1][3]),
                .A(A[2][3]),
                .B(),   
                .readoutA(readinTTX[2][3]),
                .readoutB()
            );
AddCore core03(
                .clk(CLK100MHZ),
                .iA1(arrB[0][3]),
                .iB1(B[0][3]),
                .reset(reset),
                .readinA(indexing[3]),
                .readinB(readinTTY[0][3]),
                .out_num(out_num[0][3]),
                .A(A[1][3]),
                .B(),   
                .readoutA(readinTTX[1][3]),
                .readoutB()
            );
AddCore core02(
                .clk(CLK100MHZ),
                .iA1(arrB[0][2]),
                .iB1(B[0][2]),
                .reset(reset),
                .readinA(indexing[2]),
                .readinB(readinTTY[0][2]),
                .out_num(out_num[0][2]),
                .A(A[1][2]),
                .B(B[0][3]),   
                .readoutA(readinTTX[1][2]),
                .readoutB(readinTTY[0][3])
            );
AddCore core01(
                .clk(CLK100MHZ),
                .iA1(arrB[0][1]),
                .iB1(B[0][1]),
                .reset(reset),
                .readinA(indexing[1]),
                .readinB(readinTTY[0][1]),
                .out_num(out_num[0][1]),
                .A(A[1][1]),
                .B(B[0][2]),   
                .readoutA(readinTTX[1][1]),
                .readoutB(readinTTY[0][2])
            );
            
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
            reg [2:0] calcSM = 0;
            reg [3:0] indexing = 0;
            assign trans_x = inVal[4:3];
            assign trans_y = inVal[2:1];
    always@(posedge CLK100MHZ) begin
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
                calcSM<=3'b001;
            end
            else begin
                RAstate<=RAstate+1;
                arrB[y][x]<=rx_byte;
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
        indexing[1] <= indexing[0];
        indexing[2] <= indexing[1];
        indexing[3] <= indexing[2];
        if(indexing[0]) begin
            arrA[0][0]<=arrA[1][0];
            arrA[1][0]<=arrA[2][0];
            arrA[2][0]<=arrA[3][0];
            arrB[0][0]<=arrB[1][0];
            arrB[1][0]<=arrB[2][0];
            arrB[2][0]<=arrB[3][0];
        end
        if(indexing[1]) begin
            arrA[0][1]<=arrA[1][1];
            arrA[1][1]<=arrA[2][1];
            arrA[2][1]<=arrA[3][1];
            arrB[0][1]<=arrB[1][1];
            arrB[1][1]<=arrB[2][1];
            arrB[2][1]<=arrB[3][1];
        end
        if(indexing[2]) begin
            arrA[0][2]<=arrA[1][2];
            arrA[1][2]<=arrA[2][2];
            arrA[2][2]<=arrA[3][2];
            arrB[0][2]<=arrB[1][2];
            arrB[1][2]<=arrB[2][2];
            arrB[2][2]<=arrB[3][2];
        end
        if(indexing[3]) begin
            arrA[0][3]<=arrA[1][3];
            arrA[1][3]<=arrA[2][3];
            arrA[2][3]<=arrA[3][3];
            arrB[0][3]<=arrB[1][3];
            arrB[1][3]<=arrB[2][3];
            arrB[2][3]<=arrB[3][3];
        end
        if(calcSM != 3'b000) begin
            if(calcSM==1) begin
                indexing[0]<=1;
            end
            if(calcSM==5)begin
                indexing[0]<=0;
                calcSM<=3'b000;
            end
            calcSM<=calcSM+1;
        end
        LED[2:0]<=mainSM;
    
    end
endmodule
