`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2026 08:29:20 PM
// Design Name: 
// Module Name: TPU
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


//module TPU(
//input
//    );
//endmodule


module AddCore(
    input clk,
    input [7:0] iA1,
    input [7:0] iB1,
    input reset,
    input readinA,
    input readinB,
    output reg [31:0] out_num,
    output reg [7:0] A,
    output reg [7:0] B,
    output reg readoutA,
    output reg readoutB
);
wire [17:0]G0;
wire [17:0]P0;
reg [7:0]endind = 0;
reg aval[7:0][7:0], bval[7:0][7:0];
//reg sum[7:0][16:0];
wire [16:0]partial1[4:0];
reg [16:0]partial[4:0];
reg [7:0] iA; 
reg signed [14:0] iB;
wire signed [14:0] dM = iB <<< 1;
wire signed [16:0] nM = -iB;
wire signed [16:0] dnM = -dM;
assign partial1[4] = {18{iA[7]}} & {iB[9:0], 8'd0};
initial begin
    out_num <= 32'd0;
    iA<=0;
    iB<=0;
    partial[0]<=0;
    partial[1]<=0;
    partial[2]<=0;
    partial[3]<=0;
    partial[4]<=0;
end
booth_encoder b1(.val({iA[1:0], 1'b0}), 
.M({2'b00,iB}), .M2({2'b00,dM}), .nM({nM}), .nM2({dnM}), .res(partial1[0]));

booth_encoder b2(.val(iA[3:1]),
.M({iB, 2'b00}), .M2({dM, 2'b00}), .nM({nM[14:0], 2'b00}), .nM2({dnM[14:0], 2'b00}), .res(partial1[1]));

booth_encoder b3(.val(iA[5:3]),
.M({iB[13:0],4'sd0}), .M2({dM[13:0],4'sd0}), .nM({nM[12:0],4'sd0}), .nM2({dnM[12:0],4'sd0}), .res(partial1[2]));

booth_encoder b4(.val(iA[7:5]),
.M({iB[11:0], 6'sd0}), .M2({dM[11:0], 6'sd0}), .nM({nM[10:0], 6'sd0}), .nM2({dnM[10:0], 6'sd0}), .res(partial1[3]));

always@(posedge clk) begin
    partial[0]<=partial1[0];
    partial[1]<=partial1[1];
    partial[2]<=partial1[2];  
    partial[3]<=partial1[3];  
    partial[4]<=partial1[4];  
    if(readinA && readinB) begin
        iA<=iA1; 
        iB<=iB1; 
        readoutA<=1;
        readoutB<=1;
    end
    else begin
        iA<=0;
        iB<=0;
        readoutA<=0;
        readoutB<=0;
    end
end
wire [16:0]res1[1:0]; 

adder2 add1(.s1(partial[0]),.s2(partial[1]), .s3(partial[2]), .o1(res1[0]), .c1(res1[1]));

wire [16:0]res2[1:0];
adder2 add2(.s1(res1[0]),.s2({res1[1][15:0], 1'b0}), .s3(partial[3]), .o1(res2[0]), .c1(res2[1]));

wire [16:0]res3[1:0];
adder2 add3(.s1(res2[0]),.s2({res2[1][15:0], 1'b0}), .s3(partial[4]), .o1(res3[0]), .c1(res3[1]));

wire [16:0]res4[1:0];
adder2 add4(.s1(res3[0]),.s2({res3[1][15:0], 1'b0}), .s3({1'b0, out_num[15:0]}), .o1(res4[0]), .c1(res4[1]));

wire [16:0]G1;
wire [16:0]P1;
wire [16:0]G2;
wire [16:0]P2;
wire [16:0]G3;
wire [16:0]P3;
wire [16:0]G4;
wire [16:0]P4;
wire [16:0]G5;
wire [16:0]P5;

assign G0 = res4[0] & {res4[1][16:0], 1'b0};
assign P0 = res4[0] ^ {res4[1][16:0], 1'b0};

KSA_stage_1 st1(.clk(clk), .G(G0),.P(P0),.Gn(G1),.Pn(P1));
KSA_stage_2 st2(.clk(clk), .G(G1),.P(P1),.Gn(G2),.Pn(P2));
KSA_stage_3 st3(.clk(clk), .G(G2),.P(P2),.Gn(G3),.Pn(P3));
KSA_stage_4 st4(.clk(clk), .G(G3),.P(P3),.Gn(G4),.Pn(P4));
KSA_stage_5 st5(.clk(clk), .G(G4),.P(P4),.Gn(G5),.Pn(P5));

wire [15:0]temp = G5[15:0]^P0[16:1];
always @(posedge clk) begin
    if(reset) begin
        out_num <= 32'd0;
    end
    else begin
        out_num[0] <= P5[0];
        out_num[15:1]<= temp[14:0];
        if(temp[15]) begin
            out_num[31:16]<=out_num[31:16]+1;
        end
    end
end
always@(posedge clk) begin
        A  <= iA1;
        B <= iB1;
        //01
        
    end
    
 
endmodule

module adder2(
    input [16:0] s1,
    input [16:0] s2,
    input [16:0] s3,
    output [16:0] o1,
    output [16:0] c1
);
assign o1 = s1^s2^s3;
assign c1 = s1&s2|s1&s3|s2&s3;
endmodule

module booth_encoder(
    input wire [2:0] val,
    input  wire signed [16:0] M,
    input  wire signed [16:0] M2,   // 2M
    input  wire signed [16:0] nM,   // -M
    input  wire signed [16:0] nM2,  // -2M
    output reg  signed [16:0] res   // partial product
);
    always @(*) begin
        case (val)
            3'b000: res = 18'sd0;
            3'b001: res = M;
            3'b010: res = M;
            3'b011: res = M2;
            3'b100: res = nM2;
            3'b101: res = nM;
            3'b110: res = nM;
            3'b111: res = 18'sd0;
        endcase
    end
 endmodule

module KSA_stage_1(
    input clk,
    input [16:0]G,
    input [16:0]P,
    output [16:0]Gn,
    output [16:0]Pn
);
genvar i;
assign Gn[0] = G[0];
assign Pn[0] = P[0];
generate
    for(i = 1; i<18; i = i+1) begin: stage1
        assign Gn[i] = G[i]|G[i-1]&P[i];
        assign Pn[i] = P[i]&P[i-1];
    end
endgenerate
endmodule

module KSA_stage_2(
    input clk,
    input [16:0]G,
    input [16:0]P,
    output [16:0]Gn,
    output [16:0]Pn
);
genvar i;
assign Gn[0] = G[0];
assign Pn[0] = P[0];
assign Gn[1] = G[1];
assign Pn[1] = P[1];
generate
    for(i = 2; i<18; i = i+1) begin: stage1
        assign Gn[i] = G[i]|G[i-2]&P[i];
        assign Pn[i] = P[i]&P[i-2];
    end
endgenerate
endmodule

module KSA_stage_3(
    input clk,
    input [16:0]G,
    input [16:0]P,
    output [16:0]Gn,
    output [16:0]Pn
);
genvar i;
assign Gn[0] = G[0];
assign Pn[0] = P[0];
assign Gn[1] = G[1];
assign Pn[1] = P[1];
assign Gn[2] = G[2];
assign Pn[2] = P[2];
assign Gn[3] = G[3];
assign Pn[3] = P[3];
generate
    for(i = 4; i<18; i = i+1) begin: stage1
        assign Gn[i] = G[i]|G[i-4]&P[i];
        assign Pn[i] = P[i]&P[i-4];
    end
endgenerate
endmodule

module KSA_stage_4(
    input clk,
    input [16:0]G,
    input [16:0]P,
    output [16:0]Gn,
    output [16:0]Pn
);
genvar j;
generate
    for(j = 0; j<8; j = j+1) begin: stage1
        assign Gn[j] = G[j];
        assign Pn[j] = P[j];
    end
endgenerate
genvar i;
generate
    for(i = 8; i<18; i = i+1) begin: stage2
        assign Gn[i] = G[i]|G[i-8]&P[i];
        assign Pn[i] = P[i]&P[i-8];
    end
endgenerate
endmodule

module KSA_stage_5(
    input clk,
    input [17:0]G,
    input [17:0]P,
    output [17:0]Gn,
    output [17:0]Pn
);
genvar j;
generate
    for(j = 0; j<16; j = j+1) begin: stage1
        assign Gn[j] = G[j];
        assign Pn[j] = P[j];
    end
endgenerate
genvar i;
generate
    for(i = 16; i<18; i = i+1) begin: stage2
        assign Gn[i] = G[i]|G[i-16]&P[i];
        assign Pn[i] = P[i]&P[i-16];
    end
endgenerate
endmodule
//module CLAAdder(
//    input [15:0] num1,
//    input [15:0] num2,
//    output [16:0] out
//);
//    wire [15:0] P1, G1;
//    wire [7:0]  P2, G2;
//    wire [3:0]  P3, G3;
//    wire [1:0]  P4, G4;
//    wire [0:0] P5, G5; 
//    wire [15:0] FG;
//        assign P1[15:0] = num1[15:0]^num2[15:0];
//        assign G1[15:0] = num1[15:0]&num2[15:0];
//    genvar i;
//    generate
//        for(i = 0; i < 8; i = i + 1) begin : stage
//            assign G2[i] = G1[2*i+1] | (P1[2*i+1] & G1[2*i]);
//            assign P2[i] = P1[2*i+1] & P1[2*i];
//        end
//    endgenerate
    
//    genvar i1;
//    generate
//        for(i1 = 0; i1 < 4; i1 = i1 + 1) begin : stage1
//            assign G3[i1] = G2[2*i1+1] | (P2[2*i1+1] & G2[2*i1]);
//            assign P3[i1] = P2[2*i1+1] & P2[2*i1];
//        end
//    endgenerate
    
//    genvar i2;
//    generate
//        for(i2 = 0; i2 < 2; i2 = i2 + 1) begin : stage2
//            assign G4[i2] = G3[2*i2+1] | (P3[2*i2+1] & G3[2*i2]);
//            assign P4[i2] = P3[2*i2+1] & P3[2*i2];
//        end
//    endgenerate
    
//    genvar i3;
//    generate
//        for(i3 = 0; i3 < 1; i3 = i3 + 1) begin : stage3
//            assign G5[i3] = G4[2*i3+1] | (P4[2*i3+1] & G4[2*i3]);
//            assign P5[i3] = P4[2*i3+1] & P4[2*i3];
//        end
//    endgenerate
    
//    assign FG[0] = G1[0];
//    assign FG[1] = G2[0];
//    assign FG[2] = G1[2]|P1[2]&G2[1];
//    assign FG[3] = G3[0];
//    assign FG[4] = G1[4]|P1[4]&G3[1];
//    assign FG[5] = G2[2]|P2[2]&G3[1];
//    assign FG[6] = G1[6]|P1[6]&G2[3]|P1[6]&P2[3]&G3[1];
//    assign FG[7] = G4[0];
//    assign FG[8] = G1[8]|P1[8]&G4[1];
//    assign FG[9] = G2[4]|P2[4]&G4[1];
//    assign FG[10] = G1[10]|P1[10]&G2[5]|P1[10]&P2[5]&G4[1];
//    assign FG[11] = G3[2]|P3[2]&G4[1];
//    assign FG[12] = G1[12]|P1[12]&G3[3]|P1[12]&P3[3]&G4[1];
//    assign FG[13] = G2[6]|P2[6]&G3[3]|P2[6]&P3[3]&G4[1];
//    assign FG[14] = G1[14]|P1[14]&G2[7]|P1[14]&P2[7]&G3[3]|P1[14]&P2[7]&P3[3]&G4[1];
//    assign FG[15] = G5[0];
    
//    genvar i4;
//    generate
//        for(i4 = 1; i4 < 16; i4 = i4 + 1) begin : stage4
//            assign out[i4] = FG[i4-1]^P1[i4];
//        end
//    endgenerate
//    assign out[0] = P1[0];
//    assign out[16] = FG[15];

//endmodule
//module LHCAdder(
//    input [16:0]sum,
//    input [7:0]add,
//    output [16:0] fin
//);
//    wire [7:0] p;
//    wire [7:0] p;

//    wire [8:0] c;

//    assign c[0] = 1'b0;

//    // Propagate and Generate
//    assign p = sum ^ add;
//    assign q = sum & add;

//    // Carry Lookahead Equations

//    assign C[1] =
//        G[0] |
//        (P[0] & C[0]);

//    assign C[2] =
//        G[1] |
//        (P[1] & G[0]) |
//        (P[1] & P[0] & C[0]);

//    assign C[3] =
//        G[2] |
//        (P[2] & G[1]) |
//        (P[2] & P[1] & G[0]) |
//        (P[2] & P[1] & P[0] & C[0]);

//    assign C[4] =
//        G[3] |
//        (P[3] & G[2]) |
//        (P[3] & P[2] & G[1]) |
//        (P[3] & P[2] & P[1] & G[0]) |
//        (P[3] & P[2] & P[1] & P[0] & C[0]);

//    assign C[5] =
//        G[4] |
//        (P[4] & G[3]) |
//        (P[4] & P[3] & G[2]) |
//        (P[4] & P[3] & P[2] & G[1]) |
//        (P[4] & P[3] & P[2] & P[1] & G[0]) |
//        (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

//    assign C[6] =
//        G[5] |
//        (P[5] & G[4]) |
//        (P[5] & P[4] & G[3]) |
//        (P[5] & P[4] & P[3] & G[2]) |
//        (P[5] & P[4] & P[3] & P[2] & G[1]) |
//        (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
//        (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

//    assign C[7] =
//        G[6] |
//        (P[6] & G[5]) |
//        (P[6] & P[5] & G[4]) |
//        (P[6] & P[5] & P[4] & G[3]) |
//        (P[6] & P[5] & P[4] & P[3] & G[2]) |
//        (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) |
//        (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
//        (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

//    assign C[8] =
//        G[7] |
//        (P[7] & G[6]) |
//        (P[7] & P[6] & G[5]) |
//        (P[7] & P[6] & P[5] & G[4]) |
//        (P[7] & P[6] & P[5] & P[4] & G[3]) |
//        (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) |
//        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) |
//        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
//        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

//    // Sum Bits
//    assign SUM[0] = P[0] ^ C[0];
//    assign SUM[1] = P[1] ^ C[1];
//    assign SUM[2] = P[2] ^ C[2];
//    assign SUM[3] = P[3] ^ C[3];
//    assign SUM[4] = P[4] ^ C[4];
//    assign SUM[5] = P[5] ^ C[5];
//    assign SUM[6] = P[6] ^ C[6];
//    assign SUM[7] = P[7] ^ C[7];

//    assign SUM[8] = C[8];

//endmodule

