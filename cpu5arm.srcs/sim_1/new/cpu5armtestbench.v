


//// Authored by Aidan Capaldi and Mikayla Sagle


`timescale 1ns/10ps


module cpu5armtestbench();

parameter num = 54;
reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:num];
wire [63:0] iaddrbus, daddrbus;
reg  [63:0] iaddrbusout[0:num], daddrbusout[0:num];
wire [63:0] databus;
reg  [63:0] databusk, databusin[0:num], databusout[0:num];
reg         clk, reset;
reg         clkd;

reg [63:0] dontcare;
reg [24*8:1] iname[0:num];
integer error, k, ntests;

	parameter BRANCH = 6'b000011;
    parameter BEQ = 8'b01110100;
    parameter BNE = 8'b01110101;
    parameter BLT = 8'b01110110;
    parameter BGE = 8'b01110111;
    parameter CBZ = 8'b11110100;
    parameter CBNZ = 8'b11110101;
    parameter ADD = 11'b00101000000;
    parameter ADDS = 11'b00101000001;
    parameter SUB = 11'b00101001001;
    parameter SUBS = 11'b00101001010;
    parameter AND = 11'b00101000010;
    parameter ANDS = 11'b00101000011;
    parameter EOR = 11'b00101000100;
    parameter ENOR = 11'b00101000101;
    parameter ORR = 11'b00101001000;
    parameter LSL = 11'b00101000110;
    parameter LSR = 11'b00101000111;
    parameter ADDI  = 10'b1000100000;
    parameter ADDIS = 10'b1000100001;
    parameter SUBI = 10'b1000100111;
    parameter SUBIS = 10'b1000101000;
    parameter ANDI = 10'b1000100010;
    parameter ANDIS = 10'b1000100011;
    parameter EORI = 10'b1000100100;
    parameter ENORI = 10'b1000100101;
    parameter ORRI = 10'b1000100110;
    parameter MOVZ = 9'b110010101;
    parameter STUR = 11'b11010000001;
    parameter LDUR = 11'b11010000000;
	
	
cpu5arm dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.

iname[0]  = "ADDI R1, R31, #3"; // Load in values to registers using ADDI SUBI 
iname[1]  = "ADDI R2, R31, #1";
iname[2]  = "SUBI R3, R31, #2";
iname[3]  = "SUBI R4, R31, #1";
iname[4]  = "LDUR R5, [R1,0]"; // Try LDUR STUR 
iname[5]  = "LDUR R6, [R2,0]";
iname[6]  = "STUR R1, [R9,0]";
iname[7]  = "STUR R2, [R4,0]";
iname[8]  = "ADD R11, R5, R1"; // Try all other instructions
iname[9]  = "ADD R11, R5, R31";
iname[10] = "ADDIS R12, R11, 1111";
iname[11] = "ADDIS R13, R5, 1111";
iname[12] = "AND R29, R1, R2";
iname[13] = "AND R28, R12, R13";
iname[14] = "ANDIS R30, R1, R2";
iname[15] = "ANDIS R27, R3, R1";
iname[16] = "EOR R26, R30, R3";
iname[17] = "EOR R25, R30, R26";
iname[18] = "ENOR R27, R30, R3";
iname[19] = "ENOR R23, R31, R1";
iname[20] = "LSL R31, R10, 6'd10";
iname[21] = "LSR R31, R10, 6'd10";
iname[22] = "ORR R22, R2, R1";
iname[23] = "ORR R19, R5, R14";
iname[24] = "SUB R23, R5, R1";
iname[25] = "SUB R25, R4, R4";
iname[26] = "SUBS R24, R3, R3";
iname[27] = "SUBS R16, R30, R1";
iname[28] = "ADDI R25, R5, #1";
iname[29] = "EORI R30, R29, #hFFF";
iname[30] = "ENORI R14, R29, #hFFF";
iname[31] = "SUBIS R16, R1, 1111";  
iname[32] = "BEQ #15";
iname[33] = "SUBIS R20, R1, 1111";
iname[34] = "BEQ #0";
iname[35] = "SUBIS R21, R1, 0000";
iname[36] = "BNE #9";
iname[37] = "NOP ANDI R31, R21, #hFF";
iname[38] = "NOP ANDI R31, R21, #hFF";
iname[39] = "MOVZ R31, (<< 3*16), #hCCCA";
iname[40] = "MOVZ R31, (<< 1*16), #h000A";
iname[41] = "CBZ R21, #d9";
iname[42] = "NOP ANDI R31, R21, #hFF";
iname[43] = "B #d16";
iname[44] = "CBNZ R21, #d9";
iname[45] = "SUBS R31, R1, R1";
iname[46] = "BLT #9";
iname[47] = "SUBS R31, R2, R1";
iname[48] = "BGE #5";
iname[49] = "NOP ADDI R31, R31, #0";
iname[50] = "NOP ADDI R31, R31, #0";
iname[51] = "NOP ADDI R31, R31, #0";
iname[52] = "NOP ADDI R31, R31, #0";
iname[53] = "NOP ADDI R31, R31, #0";

dontcare = 64'hx;

// ADDI  R1, R31, #3
iaddrbusout[0] = 64'h0000000000000000;
//            opcode 
instrbusin[0]={SUBI, 12'b000000000011, 5'b11111, 5'b00001};

daddrbusout[0] = 64'b1111111111111111111111111111111111111111111111111111111111111101; 
databusin[0] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

// ADDI  R2, R31, #1
iaddrbusout[1] = 64'h0000000000000004;
//            opcode 
instrbusin[1]={SUBI, 12'b000000000001, 5'b11111, 5'b00010};

daddrbusout[1] = 64'b1111111111111111111111111111111111111111111111111111111111111111; 
databusin[1] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1] = dontcare;

// SUBI  R3, R31, #2
iaddrbusout[2] = 64'h0000000000000008;
//            opcode 
instrbusin[2]={SUBI, 12'b000000000010, 5'b11111, 5'b00011};

daddrbusout[2] = 64'b1111111111111111111111111111111111111111111111111111111111111110; 
databusin[2] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2] = dontcare;

// SUBI  R4, R31, #1
iaddrbusout[3] = 64'h000000000000000C;
//            opcode 
instrbusin[3]={SUBI, 12'b000000000001, 5'b11111, 5'b00100};

daddrbusout[3] = 64'b1111111111111111111111111111111111111111111111111111111111111111; 
databusin[3] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[3] = dontcare;

// LDUR  R5, [R1,0]
iaddrbusout[4] = 64'h0000000000000010;
//            opcode
instrbusin[4]={LDUR, 9'b000000000, 2'b00, 5'b00001, 5'b00101};

daddrbusout[4] = 64'hFFFFFFFFFFFFFFFD;
databusin[4]   = 64'hAAAAAAAAAAAAAAAA;
databusout[4]  = dontcare;

// LDUR  R6, [R2,0]
iaddrbusout[5] = 64'h0000000000000014;
//            opcode
instrbusin[5]={LDUR, 9'b000000000, 2'b00, 5'b00010, 5'b00110};

daddrbusout[5] = 64'hFFFFFFFFFFFFFFFF;
databusin[5]   = 64'hCCCCCCCCCCCCCCCC;
databusout[5]  = dontcare;

// STUR   R1, [R9,0] 
iaddrbusout[6] = 64'h0000000000000018;
//            opcode 
instrbusin[6]={STUR, 9'b000000000, 2'b01, 5'b00011, 5'b00001};

daddrbusout[6] = 64'hFFFFFFFFFFFFFFFE;
databusin[6] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 64'hFFFFFFFFFFFFFFFD;

// STUR   R2, [R4,0] 
iaddrbusout[7] = 64'h000000000000001C;
//            opcode 
instrbusin[7]={STUR, 9'b000000000, 2'b01, 5'b00100, 5'b00010};

daddrbusout[7] = 64'hFFFFFFFFFFFFFFFF;
databusin[7] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = 64'hFFFFFFFFFFFFFFFF;


// ADD   R11, R5, R1
iaddrbusout[8] = 64'h0000000000000020;
//             opcode   
instrbusin[8]={ADD, 5'd5, 6'd1, 5'd1, 5'd11};

daddrbusout[8] = 64'b1010101010101010101010101010101010101010101010101010101010100111;
databusin[8] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

// ADD   R11, R5, R31
iaddrbusout[9] = 64'h0000000000000024;
//             opcode   
instrbusin[9]={ADD, 5'd31, 6'd1, 5'd1, 5'd11};

daddrbusout[9] = 64'b1111111111111111111111111111111111111111111111111111111111111101;
databusin[9] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

// ADDI   R12, R11, 1111
iaddrbusout[10] = 64'h0000000000000028;
//            opcode 
instrbusin[10]={ADDIS, 12'd1111, 5'd11, 5'd12};

daddrbusout[10] = dontcare;
databusin[10] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

// ADDI   R13, R5, 1111
iaddrbusout[11] = 64'h000000000000002C;
//            opcode 
instrbusin[11]={ADDIS, 12'd1111, 5'd5, 5'd13};

daddrbusout[11] = 64'b1010101010101010101010101010101010101010101010101010111100000001;
databusin[11] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

// AND    R1, R2, R29          
iaddrbusout[12] = 64'h0000000000000030;
//             opcode 
instrbusin[12]={AND, 5'd29, 6'd0, 5'd2, 5'd1};

daddrbusout[12] = dontcare;
databusin[12] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

// AND    R13, R12, R28          
iaddrbusout[13] = 64'h0000000000000034;
//             opcode 
instrbusin[13]={AND, 5'd28, 6'd0, 5'd12, 5'd13};

daddrbusout[13] = dontcare;
databusin[13] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

// ANDIS   R12, R11, #1             
iaddrbusout[14] = 64'h0000000000000038;
//            opcode
instrbusin[14]={ANDIS, 12'd1, 5'd11, 5'd12};

daddrbusout[14] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[14] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

// ANDIS   R13, R5, #1             
iaddrbusout[15] = 64'h000000000000003C;
//            opcode
instrbusin[15]={ANDIS, 12'd1, 5'd5, 5'd13};

daddrbusout[15] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[15] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] = dontcare;

// EOR   R26, R30, R3
iaddrbusout[16] = 64'h0000000000000040;
//             opcode
instrbusin[16]={EOR, 5'd3, 6'd10, 5'd30, 5'd26};

daddrbusout[16] = dontcare;
databusin[16] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16] = dontcare;

// EOR   R25, R30, R26
iaddrbusout[17] = 64'h0000000000000044;
//             opcode
instrbusin[17]={EOR, 5'd26, 6'd10, 5'd30, 5'd25};

daddrbusout[17] = dontcare;
databusin[17] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = dontcare;

// ENOR   R27, R30, R3
iaddrbusout[18] = 64'h0000000000000048;
//             opcode
instrbusin[18]={ENOR, 5'd3, 6'd10, 5'd30, 5'd27}; 

daddrbusout[18] = dontcare;
databusin[18] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18] = dontcare;

// ENOR   R23, R31, R1
iaddrbusout[19] = 64'h000000000000004C;
//             opcode
instrbusin[19]={ENOR, 5'd1, 6'd10, 5'd31, 5'd23};

daddrbusout[19] = dontcare;
databusin[19] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = dontcare;

// LSL   R31, R10, 6'd10
iaddrbusout[20] = 64'h0000000000000050;
//             opcode
instrbusin[20]={LSL, 5'd01, 6'd10, 5'd10, 5'd31};

daddrbusout[20] = 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0000000000;
databusin[20] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20] = dontcare;

// LSR   R31, R10, 6'd10
iaddrbusout[21] = 64'h0000000000000054;
//             opcode
instrbusin[21]={LSR, 5'd01, 6'd10, 5'd10, 5'd31};

daddrbusout[21] = 64'b0000000000xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
databusin[21] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21] = dontcare;

// ORR     R22, R2, R1
iaddrbusout[22] = 64'h0000000000000058;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[22]={ORR, 5'd1, 6'd0, 5'd2, 5'd22};

daddrbusout[22] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[22] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] =  dontcare;

// ORR     R19, R5, R14
iaddrbusout[23] = 64'h000000000000005C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[23]={ORR, 5'd14, 6'd0, 5'd5, 5'd19};

daddrbusout[23] = 64'b1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x;
databusin[23] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] =  dontcare;

// SUB   R23, R5, R1
iaddrbusout[24] = 64'h0000000000000060;
//             opcode
instrbusin[24]={SUB, 5'd1, 6'd11, 5'd5, 5'd23};

daddrbusout[24] = dontcare;
databusin[24] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[24] = dontcare;

// SUB   R25, R4, R4
iaddrbusout[25] = 64'h0000000000000064;
//             opcode
instrbusin[25]={SUB, 5'd4, 6'd11, 5'd4, 5'd25};

daddrbusout[25] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[25] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[25] = dontcare;

// SUBS  R24,  R3, R3
iaddrbusout[26] = 64'h0000000000000068;
//                 
instrbusin[26] = {SUBS, 5'd3, 6'd0, 5'd3, 5'd24};
daddrbusout[26] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[26] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[26] = dontcare;

// SUBS  R16,  R30, R1
iaddrbusout[27] = 64'h000000000000006C;
//                 
instrbusin[27] = {SUBS, 5'd1, 6'd0, 5'd30, 5'd16};
daddrbusout[27] = dontcare;
databusin[27] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[27] = dontcare;

// ADDI  R25, R31, #1
iaddrbusout[28] = 64'h0000000000000070;
//            opcode
instrbusin[28]={ADDI, 12'b000000000001, 5'b11111, 5'b11001};

daddrbusout[28] = 64'b0000000000000000000000000000000000000000000000000000000000000001; 
databusin[28]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[28]  = dontcare;

// EORI   R30, R29, #hFFF
iaddrbusout[29] = 64'h0000000000000074;
//             opcode
instrbusin[29]={EORI, 12'hFFF, 5'd29, 5'd30};

daddrbusout[29] = dontcare;
databusin[29] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[29] = dontcare;

// ENORI   R14, R29, #hFFF
iaddrbusout[30] = 64'h0000000000000078;
//             opcode
instrbusin[30]={ENORI, 12'hFFF, 5'd29, 5'd14};

daddrbusout[30] = dontcare;
databusin[30] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[30] = dontcare;

// SUBIS R16, R1, #1
iaddrbusout[31] = 64'h000000000000007C;
//            opcode 
instrbusin[31]={SUBIS, 12'd1, 5'd1, 5'd16};
daddrbusout[31] = dontcare;
databusin[31] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[31] =  dontcare;

// BEQ #15
iaddrbusout[32] = 64'h0000000000000080;
//            opcode
instrbusin[32]={BEQ, 19'd15, 5'd0};
daddrbusout[32] = 64'b0000000000000000000000000000000000000000000000000000000011111000;
databusin[32] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[32] = dontcare;

// SUBIS R20, R1, #1
iaddrbusout[33] = 64'h0000000000000084;
//            opcode 
instrbusin[33]={SUBIS, 12'd1, 5'd1, 5'd20};
daddrbusout[33] = dontcare;
databusin[33] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[33] =  dontcare;

// BEQ #0
iaddrbusout[34] = 64'h0000000000000088;
//            opcode
instrbusin[34]={BEQ, 19'd0, 5'd0};
daddrbusout[34] = 64'b0000000000000000000000000000000000000000000000000000000011111000;
databusin[34] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[34] = dontcare;

// SUBIS R21, R1, #0
iaddrbusout[35] = 64'h000000000000008C;
//            opcode 
instrbusin[35]={SUBIS, 12'd0, 5'd1, 5'd21};
daddrbusout[35] = dontcare;
databusin[35] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[35] =  dontcare;

// BNE #9
iaddrbusout[36] = 64'h0000000000000090;
//            opcode 
instrbusin[36]={BNE, 19'd9, 5'd0};
daddrbusout[36] = dontcare;
databusin[36] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[36] = dontcare;

// NOP  ANDI  R31,  R21, #hFF
iaddrbusout[37] = 64'h0000000000000094;
//                   
instrbusin[37] = {ANDI, 12'hFF, 5'd21, 5'd31};
daddrbusout[37] = 64'b00000000000000000000000000000000000000000000000000000000xxxxxxxx;
databusin[37] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[37] = dontcare;

// NOP  ANDI  R31,  R21, #hFF
iaddrbusout[38] = 64'h0000000000000098;
//                   
instrbusin[38] = {ANDI, 12'hFF, 5'd21, 5'd31};
daddrbusout[38] = 64'b00000000000000000000000000000000000000000000000000000000xxxxxxxx;
databusin[38] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[38] = dontcare;

// MOVZ  R31, (<< 3*16), #hCCCA 
iaddrbusout[39] = 64'h000000000000009C;
//             opcode
instrbusin[39]={MOVZ, 2'b11, 16'hCCCA, 5'd31};

daddrbusout[39] = 64'b1100110011001010000000000000000000000000000000000000000000000000;
databusin[39] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[39] = dontcare;

// MOVZ  R31, (<< 1*16), #h000A
iaddrbusout[40] = 64'h00000000000000A0;
//             opcode
instrbusin[40]={MOVZ, 2'b01, 16'h000A, 5'd31};

daddrbusout[40] = 64'b0000000000000000000000000000000000000000000010100000000000000000;
databusin[40] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[40] = dontcare;

// CBZ R21, #d9
iaddrbusout[41] = 64'h00000000000000A4;
//            opcode
instrbusin[41]={CBZ, 19'd9, 5'd21};
daddrbusout[41] = dontcare;
databusin[41] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[41] = dontcare;

// NOP  ANDI  R31,  R21, #hFF
iaddrbusout[42] = 64'h00000000000000A8;
//                   
instrbusin[42] = {ANDI, 12'hFF, 5'd21, 5'd31};
daddrbusout[42] = 64'b00000000000000000000000000000000000000000000000000000000xxxxxxxx;
databusin[42] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[42] = dontcare;

// B     #d16
iaddrbusout[43] = 64'h00000000000000AC;
//             opcode
instrbusin[43]={BRANCH, 26'd16};

daddrbusout[43] = dontcare;
databusin[43] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[43] = dontcare;

// CBNZ R21, #d9
iaddrbusout[44] = 64'h00000000000000B0;
//            opcode
instrbusin[44]={CBNZ, 19'd9, 5'd21};
daddrbusout[44] = dontcare;
databusin[44] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[44] = dontcare;

// SUBS  R31,  R1, R1
iaddrbusout[45] = 64'h00000000000000EC;
//                 
instrbusin[45] = {SUBS, 5'd1, 6'd0, 5'd31, 5'd1};
daddrbusout[45] = dontcare;
databusin[45] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[45] = dontcare;

// BLT  #9
iaddrbusout[46] = 64'h00000000000000D4;
//            opcode
instrbusin[46]={BLT, 19'd9, 5'd0};
daddrbusout[46] = dontcare;
databusin[46] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[46] = dontcare;

// SUBS  R31,  R2, R1
iaddrbusout[47] = 64'h00000000000000D8;
//                 
instrbusin[47] = {SUBS, 5'd1, 6'd0, 5'd31, 5'd2};
daddrbusout[47] = dontcare;
databusin[47] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[47] = dontcare;

// BGE  #5
iaddrbusout[48] = 64'h00000000000000DC;
//            opcode
instrbusin[48]={BGE, 19'd5, 5'd0};
daddrbusout[48] = dontcare;
databusin[48] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[48] = dontcare;

// NOP  ADDI  R31,  R31, #0
iaddrbusout[49] = 64'h00000000000000E0;
//            opcode 
instrbusin[49]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[49] = 64'd0;
databusin[49] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[49] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[50] = 64'h00000000000000F0;
//            opcode 
instrbusin[50]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[50] = 64'd0;
databusin[50] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[50] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[51] = 64'h00000000000000F4;
//            opcode 
instrbusin[51]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[51] = 64'd0;
databusin[51] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[51] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[52] = 64'h00000000000000F8;
//            opcode 
instrbusin[52]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[52] = 64'd0;
databusin[52] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[52] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[53] = 64'h00000000000000FC;
//            opcode 
instrbusin[53]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[53] = 64'd0;
databusin[53] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[53] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[54] = 64'h0000000000000100;
//            opcode 
instrbusin[54]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[54] = 64'd0;
databusin[54] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[54] = dontcare;

// 55 Instrs, 2 Loads, 2 * (2 Stores) --> 71
// (no. instructions) + (no. loads) + 2*(no. stores) = 
ntests = 71;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 64'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 32'bz;

  //extended reset to set up PC MUX
  reset = 1;
  $display ("reset=%b", reset);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5

  clk=1;
  clkd=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  $display ("Time=%t\n  clk=%b", $realtime, clk);

for (k=0; k<= num; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd=1;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    reset = 0;
    $display ("reset=%b", reset);


    //set load data for 3rd previous instruction
    if (k >=3)
      databusk = databusin[k-3];

    //check PC for this instruction
    if (k >= 0) begin
      $display ("  Testing PC for instruction %d", k);
      $display ("    Your iaddrbus =    %b", iaddrbus);
      $display ("    Correct iaddrbus = %b", iaddrbusout[k]);
      if (iaddrbusout[k] !== iaddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //put next instruction on ibus
    instrbus=instrbusin[k];
    $display ("  instrbus=%b %b %b %b %b for instruction %d: %s", instrbus[31:26], instrbus[25:21], instrbus[20:16], instrbus[15:11], instrbus[10:0], k, iname[k]);

    //check data address from 3rd previous instruction
    if ( (k >= 3) && 
	     ((k-3) != 32)  && ((k-3) != 34) && ((k-3) != 36) && ((k-3) != 41) && 
	     ((k-3) != 32) && ((k-3) != 44) && ((k-3) != 46) && ((k-3) != 48)) begin
	
	//if ( (k >= 3) && (daddrbusout[k-3] !== dontcare) ) begin
      $display ("  Testing data address for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your daddrbus =    %b", daddrbus);
      $display ("    Correct daddrbus = %b", daddrbusout[k-3]);
      if (daddrbusout[k-3] !== daddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end
    

    //check store data from 3rd previous instruction
    if ( (k >= 3) && (databusout[k-3] !== dontcare) && 
	     ((k-3) != 32)  && ((k-3) != 34) && ((k-3) != 36) && ((k-3) != 41) && 
	     ((k-3) != 32) && ((k-3) != 44) && ((k-3) != 46) && ((k-3) != 48)) begin
      $display ("  Testing store data for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your databus =    %b", databus);
      $display ("    Correct databus = %b", databusout[k-3]);
      if (databusout[k-3] !== databus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    clk = 0;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd = 0;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
  end

  if ( error !== 0) begin
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
  end

  if ( error == 0)
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

   $display(" Number Of Errors = %d", error);
   $display(" Total Test numbers = %d", ntests);
   $display(" Total number of correct operations = %d", (ntests-error));
   $display(" ");

end

endmodule
