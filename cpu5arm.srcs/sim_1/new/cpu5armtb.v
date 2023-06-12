`timescale 1ns/10ps

// Written by Dr. Marpaung  
// Not to be published outside NEU.edu domain without a written permission/consent from Dr. Marpaung
// All Rights Reserved 

// THIS IS NOT THE TESTBENCH THAT SHALL BE USED TO GRADE YOUR INDIVIDUAL PROJECT
// THE PURPOSE OF THIS TESTBENCH IS TO GET YOU STARTED
// A MORE COMPLICATED TESTBENCH WILL BE USED TO FULLY TEST YOUR DESIGN
// THIS TESTBENCH MAY CONTAIN BUGS

// THIS IS NOT THE TESTBENCH THAT SHALL BE USED TO GRADE YOUR INDIVIDUAL PROJECT
// THE PURPOSE OF THIS TESTBENCH IS TO GET YOU STARTED
// A MORE COMPLICATED TESTBENCH WILL BE USED TO FULLY TEST YOUR DESIGN
// THIS TESTBENCH MAY CONTAIN BUGS


module cpu5armtb();

parameter num = 52;
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

	parameter BRANCH	= 6'b000101;
	parameter BEQ		= 8'b01010101;
	parameter BNE		= 8'b01010110;
	parameter BLT		= 8'b01010111;
	parameter BGE		= 8'b01011000;
	parameter CBZ		= 8'b10110100;
	parameter CBNZ		= 8'b10110101;
	parameter ADD		= 11'b10001011000;
	parameter ADDS		= 11'b10101011000;
	parameter SUB		= 11'b11001011000;
	parameter SUBS		= 11'b11101011000;
	parameter AND		= 11'b10001010000;
	parameter ANDS		= 11'b11101010000;
	parameter EOR		= 11'b11001010000;
	parameter ORR		= 11'b10101010000;
	parameter LSL		= 11'b11010011011;
	parameter LSR		= 11'b11010011010;
	parameter ADDI  	= 10'b1001000100;
	parameter ADDIS		= 10'b1011000100;
	parameter SUBI		= 10'b1101000100;
	parameter SUBIS		= 10'b1111000100;
	parameter ANDI		= 10'b1001001000;
	parameter ANDIS		= 10'b1111001000;
	parameter EORI		= 10'b1101001000;
	parameter ORRI		= 10'b1011001000;
	parameter MOVZ		= 9'b110100101;
	parameter STUR		= 11'b11111000000;
	parameter LDUR		= 11'b11111000010;
	
	
cpu5arm dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.

iname[0]  = "SUBI R20, R31, #1";
iname[1]  = "ADDI R21, R31, #1";
iname[2]  = "ADDI R22, R31, #2";
iname[3]  = "LDUR R24, [R20,0]";
iname[4]  = "LDUR R25, [R21,0]";
iname[5]  = "STUR R20, [R22,100]";
iname[6]  = "STUR R21, [R22,0]";
iname[7]  = "ADD  R26, R24, R25";
iname[8]  = "SUBIS R17, R24, 1111";
iname[9]  = "SUB  R27, R24, R25";
iname[10] = "ANDIS R18, R24, #0";     
iname[11] = "AND  R28, R24, R31";     
iname[12] = "ADDIS R19, R24, 1111";
iname[13] = "ADDI R29, R24, R25";
iname[14] = "ORRI R20, R24, 1111";
iname[15] = "ORR  R30, R24, R25";
iname[16] = "STUR R26, [R26,0]";
iname[17] = "STUR R27, [R17,0]";
iname[18] = "STUR R28, [R18,100]"; 
iname[19] = "STUR R29, [R19,0]";
iname[20] = "STUR R30, [R20,0]";
iname[21] = "ADDI R1,  R31, #1";    // Setting R1 to 32'h00000001 (since, R0 < R21).
iname[22] = "ADDI R5,  R31, #1";
iname[23] = "SUBIS R31, R31, #1";
iname[24] = "BNE  #16";             // Branching to  //(32'h00000060 + (decimal 16 *4) ) since, R0 != R1.
iname[25] = "ADDI R31, R31, #1";    // Delay Slot   //Branched Location
iname[26] = "ADDI R2,  R31, #15";   // Setting R2 to 32'h00000001 (since, R0 = R0).
iname[27] = "NOP  ANDI  R31, R20, #hFF";
iname[28] = "NOP  SUBS  R31, R22, R31";
iname[29] = "BEQ  #16";   
iname[30] = "SUBS R31, R20, R24";   // Delay Slot
iname[31] = "BGE  #16";             // Branching to (32h'0000000A0 + (decimal 16 *4))
iname[32] = "NOP  ANDS  R31,  R20, R31";    
iname[33] = "NOP  ADDS  R31,  R20, R31";
iname[34] = "SUBS R31,  R20, R24";
iname[35] = "BLT  #16";
iname[36] = "NOP  ADDI  R31,  R31, #0";
iname[37] = "NOP  ADDI  R31,  R31, #0";
iname[38] = "EOR  R29, R19, R31";
iname[39] = "EORI R30, R19, #hFFF";
iname[40] = "LSR  R31, R20, 6'd10";
iname[41] = "LSL  R31, R20, 6'd10";
iname[42] = "B    #d32";
iname[43] = "MOVZ R31, (<< 1*16), #hABCD ";
iname[44] = "MOVZ R31, (<< 3*16), #hABCD ";
iname[45] = "CBZ  R20, #d16";
iname[46] = "ADDI R31,  R31, #0";
iname[47] = "CBNZ R20, #d16";
iname[48] = "NOP  ADDI  R31,  R31, #0";
iname[49] = "NOP  ADDI  R31,  R31, #0";
iname[50] = "NOP  ADDI  R31,  R31, #0";
iname[51] = "NOP  ADDI  R31,  R31, #0";
iname[52] = "NOP  ADDI  R31,  R31, #0";

dontcare = 64'hx;

//* SUBI  R20, R31, #1
iaddrbusout[0] = 64'h0000000000000000;
//            opcode 
instrbusin[0]={SUBI, 12'b000000000001, 5'b11111, 5'b10100};

daddrbusout[0] = 64'b1111111111111111111111111111111111111111111111111111111111111111; //dontcare;
databusin[0] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

//* ADDI  R21, R31, #1
iaddrbusout[1] = 64'h0000000000000004;
//            opcode
instrbusin[1]={ADDI, 12'b000000000001, 5'b11111, 5'b10101};

daddrbusout[1] = 64'b0000000000000000000000000000000000000000000000000000000000000001; //dontcare;
databusin[1]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1]  = dontcare;

//* ADDI  R22, R31, #2
iaddrbusout[2] = 64'h0000000000000008;
//            opcode
instrbusin[2]={ADDI, 12'b000000000010, 5'b11111, 5'b10110};

daddrbusout[2] = 64'b0000000000000000000000000000000000000000000000000000000000000010; //dontcare; 
databusin[2]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2]  = dontcare;

//* LDUR  R24, [R20,0]
iaddrbusout[3] = 64'h000000000000000C;
//            opcode
instrbusin[3]={LDUR, 9'b000000000, 2'b00, 5'b10100, 5'b11000};

daddrbusout[3] = 64'hFFFFFFFFFFFFFFFF;
databusin[3]   = 64'hCCCCCCCCCCCCCCCC;
databusout[3]  = dontcare;

//* LDUR  R25, [R21,0]
iaddrbusout[4] = 64'h0000000000000010;
//            opcode
instrbusin[4]={LDUR, 9'b000000000, 2'b00, 5'b10101, 5'b11001};

daddrbusout[4] = 64'h0000000000000001;
databusin[4] = 64'hAAAAAAAAAAAAAAAA;
databusout[4] = dontcare;

//* STUR   R20, [R22,100] 
iaddrbusout[5] = 64'h0000000000000014;
//            opcode 
instrbusin[5]={STUR, 9'b001100100, 2'b01, 5'b10110, 5'b10100};

daddrbusout[5] = 64'h0000000000000066;
databusin[5] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 64'hFFFFFFFFFFFFFFFF;

//* STUR    R21, [R22,0]
iaddrbusout[6] = 64'h0000000000000018;
//            opcode 
instrbusin[6]={STUR, 9'b000000000, 2'b01, 5'd22, 5'd21};

daddrbusout[6] = 64'h0000000000000002;
databusin[6] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 64'h0000000000000001;

//* ADD   R26, R24, R25
iaddrbusout[7] = 64'h000000000000001C;
//             opcode   
instrbusin[7]={ADD, 5'd24, 6'd1, 5'd25, 5'd26};

daddrbusout[7] = 64'b0111011101110111011101110111011101110111011101110111011101110110; //dontcare;
databusin[7] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

//* SUBIS  R17, R24, 1111
iaddrbusout[8] = 64'h0000000000000020;
//            opcode
instrbusin[8]={SUBIS, 12'd1111, 5'd24, 5'd17};

daddrbusout[8] = 64'b1100110011001100110011001100110011001100110011001100100001110101;
databusin[8] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

//* SUB   R27, R24, R25
iaddrbusout[9] = 64'h0000000000000024;
//             opcode
instrbusin[9]={SUB, 5'd25, 6'd11, 5'd24, 5'd27};

daddrbusout[9] = 64'b0010001000100010001000100010001000100010001000100010001000100010;
databusin[9] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

//* ANDIS   R18, R24, #0             
iaddrbusout[10] = 64'h0000000000000028;
//            opcode
instrbusin[10]={ANDIS, 12'd0, 5'd24, 5'd18};

daddrbusout[10] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[10] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

//* AND    R28, R24, R31           
iaddrbusout[11] = 64'h000000000000002C;
//             opcode 
instrbusin[11]={AND, 5'd31, 6'd0, 5'd24, 5'd28};

daddrbusout[11] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[11] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

//* ADDI   R19, R24, 1111
iaddrbusout[12] = 64'h0000000000000030;
//            opcode 
instrbusin[12]={ADDIS, 12'd1111, 5'd24, 5'd19};

daddrbusout[12] = 64'b1100110011001100110011001100110011001100110011001101000100100011;
databusin[12] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

//* ADDI    R29, R24, R25
iaddrbusout[13] = 64'h0000000000000034;
//             opcode  
instrbusin[13]={AND, 5'd24, 6'd0, 5'd25, 5'd29};

daddrbusout[13] = 64'b1000100010001000100010001000100010001000100010001000100010001000;
databusin[13] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

//* ORRI    R20, R24, 1111
iaddrbusout[14] = 64'h0000000000000038;
//            opcode
instrbusin[14]={ORRI, 12'd1111, 5'd24, 5'd20};

daddrbusout[14] = 64'b1100110011001100110011001100110011001100110011001100110011011111;
databusin[14] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

//* ORR     R30, R24, R25
iaddrbusout[15] = 64'h000000000000003C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[15]={ORR, 5'd25, 6'd0, 5'd24, 5'd30};

daddrbusout[15] = 64'b1110111011101110111011101110111011101110111011101110111011101110;
databusin[15] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] =  dontcare;

//  STUR   R26, [R26,0]
iaddrbusout[16] = 64'h0000000000000040;
//            opcode 
instrbusin[16]={STUR, 9'd0, 2'b01, 5'd26, 5'd26};

daddrbusout[16] = 64'b0111011101110111011101110111011101110111011101110111011101110110;
databusin[16] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16]  = 64'b0111011101110111011101110111011101110111011101110111011101110110;

//  STUR   R27, [R17,0]
iaddrbusout[17] = 64'h0000000000000044;
//            opcode 
instrbusin[17]={STUR, 9'd0, 2'b10, 5'd17, 5'd27};

daddrbusout[17] = 64'b1100110011001100110011001100110011001100110011001100100001110101;
databusin[17] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = 64'b0010001000100010001000100010001000100010001000100010001000100010;

//  STUR   R28, [R18,100]       
iaddrbusout[18] = 64'h0000000000000048;
//            opcode 
instrbusin[18]={STUR, 9'd100, 2'b10, 5'd18, 5'd28};

daddrbusout[18] = 64'b0000000000000000000000000000000000000000000000000000000001100100;
databusin[18] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18]  = 64'b0000000000000000000000000000000000000000000000000000000000000000;

//  STUR   R29, [R19,0]
iaddrbusout[19] = 64'h000000000000004C;
//            opcode 
instrbusin[19]={STUR, 9'd000, 2'b10, 5'd19, 5'd29};

daddrbusout[19] = 64'b1100110011001100110011001100110011001100110011001101000100100011;
databusin[19] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = 64'b1000100010001000100010001000100010001000100010001000100010001000;

//  STUR   R30, [R20,0]
iaddrbusout[20] = 64'h0000000000000050;
//            opcode 
instrbusin[20]={STUR, 9'd000, 2'b10, 5'd20, 5'd30};

daddrbusout[20] = 64'b1100110011001100110011001100110011001100110011001100110011011111;
databusin[20] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20]  = 64'b1110111011101110111011101110111011101110111011101110111011101110;


//  ADDI  R1,  R31,  #1
iaddrbusout[21] = 64'h0000000000000054;
//             opcode  
instrbusin[21]={ADDI, 12'd1, 5'd31, 5'd1};
daddrbusout[21] = 64'h01;
databusin[21]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21]  = dontcare;

//* ADDI R5,  R31, #1
iaddrbusout[22] = 64'h0000000000000058;
//            opcode 
instrbusin[22]={ADDI, 12'd1, 5'd31, 5'd5};
daddrbusout[22] = 64'h01;
databusin[22] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] = dontcare;

//* SUBIS R31, R31, #1
iaddrbusout[23] = 64'h000000000000005C;
//            opcode 
instrbusin[23]={SUBIS, 12'd1, 5'd31, 5'd31};
daddrbusout[23] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[23] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] =  dontcare;

//* BNE #16
iaddrbusout[24] = 64'h0000000000000060;
//            opcode 
instrbusin[24]={BNE, 19'd16, 5'd0};
daddrbusout[24] = dontcare;
databusin[24] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[24] = dontcare;

//* ADDI R31,  R31, #1
iaddrbusout[25] = 64'h0000000000000064;
//            opcode
instrbusin[25]={ADDI, 12'd1, 5'd31, 5'd31};
daddrbusout[25] = 64'd1;
databusin[25] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[25] = dontcare;

//* ADDI  R2,  R31, #15
iaddrbusout[26] = 64'h00000000000000A0;
//             opcode
instrbusin[26]={ADDI, 12'd15, 5'd31, 5'd2};
daddrbusout[26] = 64'b0000000000000000000000000000000000000000000000000000000000001111;
databusin[26] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[26] = dontcare;

//* NOP  ANDI  R31,  R20, #hFF
iaddrbusout[27] = 64'h00000000000000A4;
//                   
instrbusin[27] = {ANDI, 12'hFF, 5'd20, 5'd31};
daddrbusout[27] = 64'b0000000000000000000000000000000000000000000000000000000011011111;
databusin[27] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[27] = dontcare;

//* NOP  SUBS  R31, R22, R31
iaddrbusout[28] = 64'h00000000000000A8;
//                 
instrbusin[28] = {SUBS, 5'd31, 6'd0, 5'd22, 5'd31};
daddrbusout[28] = 64'b0000000000000000000000000000000000000000000000000000000000000010;
databusin[28]  = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[28] = dontcare;

//* BEQ #16
iaddrbusout[29] = 64'h00000000000000AC;
//            opcode
instrbusin[29]={BEQ, 19'd16, 5'd0};
daddrbusout[29] = 64'b0000000000000000000000000000000000000000000000000000000011111000;
databusin[29] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[29] = dontcare;

//* SUBS  R31,  R20, R24
iaddrbusout[30] = 64'h00000000000000B0;
//                 
instrbusin[30] = {SUBS, 5'd24, 6'd0, 5'd20, 5'd31};
daddrbusout[30] = 64'b0000000000000000000000000000000000000000000000000000000000010011;
databusin[30] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[30] = dontcare;

//* BGE  #16
iaddrbusout[31] = 64'h00000000000000B4;
//            opcode
instrbusin[31]={BGE, 19'd16, 5'd0};
daddrbusout[31] = dontcare;
databusin[31] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[31] = dontcare;

//* NOP  ANDS  R31,  R20, R31
iaddrbusout[32] = 64'h00000000000000B8;
//            opcode 
instrbusin[32]={ANDS, 5'd31, 6'd0, 5'd20, 5'd31};
daddrbusout[32] = 64'd0;
databusin[32] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[32] = dontcare;

//* NOP  ADDS  R31,  R20, R31
iaddrbusout[33] = 64'h00000000000000F4;
//            opcode 
instrbusin[33]={ADDS, 5'd31, 6'd0, 5'd20, 5'd31};
daddrbusout[33] = 64'b1100110011001100110011001100110011001100110011001100110011011111;
databusin[33] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[33] = dontcare;

//* SUBS  R31,  R20, R24
iaddrbusout[34] = 64'h00000000000000F8;
//                 
instrbusin[34] = {SUBS, 5'd24, 6'd0, 5'd20, 5'd31};
daddrbusout[34] = 64'b0000000000000000000000000000000000000000000000000000000000010011;
databusin[34] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[34] = dontcare;

//* BLT  #16
iaddrbusout[35] = 64'h00000000000000FC;
//            opcode
instrbusin[35]={BLT, 19'd16, 5'd0};
daddrbusout[35] = dontcare;
databusin[35] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[35] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[36] = 64'h0000000000000100;
//            opcode 
instrbusin[36]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[36] = 64'd0;
databusin[36] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[36] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[37] = 64'h0000000000000104;
//            opcode 
instrbusin[37]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[37] = 64'd0;
databusin[37] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[37] = dontcare;

//* EOR   R29, R19, R31
iaddrbusout[38] = 64'h0000000000000108;
//             opcode
instrbusin[38]={EOR, 5'd31, 6'd10, 5'd19, 5'd29};

daddrbusout[38] = 64'b1100110011001100110011001100110011001100110011001101000100100011;
databusin[38] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[38] = dontcare;

//* EORI   R30, R19, #hFFF
iaddrbusout[39] = 64'h000000000000010C;
//             opcode
instrbusin[39]={EORI, 12'hFFF, 5'd19, 5'd30};

daddrbusout[39] = 64'b1100110011001100110011001100110011001100110011001101111011011100;
databusin[39] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[39] = dontcare;

//* LSR   R31, R20, 6'd10
iaddrbusout[40] = 64'h0000000000000110;
//             opcode
instrbusin[40]={LSR, 5'd01, 6'd10, 5'd20, 5'd31};

daddrbusout[40] = 64'b0000000000110011001100110011001100110011001100110011001100110011;
databusin[40] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[40] = dontcare;

//* LSL   R31, R20, 6'd10
iaddrbusout[41] = 64'h0000000000000114;
//             opcode
instrbusin[41]={LSL, 5'd01, 6'd10, 5'd20, 5'd31};

daddrbusout[41] = 64'b0011001100110011001100110011001100110011001100110111110000000000;
databusin[41] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[41] = dontcare;

//* B     #d32
iaddrbusout[42] = 64'h0000000000000118;
//             opcode
instrbusin[42]={BRANCH, 26'd32};

daddrbusout[42] = 64'b0011001100110011001100110011001100110011001100110111110000000000;
databusin[42] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[42] = dontcare;

//* MOVZ  R31, (<< 1*16), #hABCD 
iaddrbusout[43] = 64'h000000000000011C;
//             opcode
instrbusin[43]={MOVZ, 2'b01, 16'hABCD, 5'd31};

daddrbusout[43] = 64'b0000000000000000000000000000000010101011110011010000000000000000;
databusin[43] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[43] = dontcare;

//* MOVZ  R31, (<< 3*16), #hABCD
iaddrbusout[44] = 64'h0000000000000198;
//             opcode
instrbusin[44]={MOVZ, 2'b11, 16'hABCD, 5'd31};

daddrbusout[44] = 64'b1010101111001101000000000000000000000000000000000000000000000000;
databusin[44] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[44] = dontcare;

//* CBZ R20, #d16
iaddrbusout[45] = 64'h000000000000019C;
//            opcode
instrbusin[45]={CBZ, 19'd16, 5'd20};
daddrbusout[45] = dontcare;
databusin[45] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[45] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[46] = 64'h00000000000001A0;
//            opcode 
instrbusin[46]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[46] = 64'd0;
databusin[46] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[46] = dontcare;

//* CBNZ R20, #d16
iaddrbusout[47] = 64'h00000000000001A4;
//            opcode
instrbusin[47]={CBNZ, 19'd16, 5'd20};
daddrbusout[47] = dontcare;
databusin[47] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[47] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[48] = 64'h00000000000001A8;
//            opcode 
instrbusin[48]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[48] = 64'd0;
databusin[48] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[48] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[49] = 64'h00000000000001E4;
//            opcode 
instrbusin[49]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[49] = 64'd0;
databusin[49] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[49] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[50] = 64'h00000000000001E8;
//            opcode 
instrbusin[50]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[50] = 64'd0;
databusin[50] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[50] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[51] = 64'h00000000000001EC;
//            opcode 
instrbusin[51]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[51] = 64'd0;
databusin[51] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[51] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[52] = 64'h00000000000001F0;
//            opcode 
instrbusin[52]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[52] = 64'd0;
databusin[52] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[52] = dontcare;

// (no. instructions) + (no. loads) + 2*(no. stores) = 
ntests = 103;

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
	     ((k-3) != 24)  && ((k-3) != 29) && ((k-3) != 31) && ((k-3) != 35) && 
	     ((k-3) != 42) && ((k-3) != 45) && ((k-3) != 47)                        ) begin
	
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
	     ((k-3) != 24) && ((k-3) != 29) && ((k-3) != 31) && ((k-3) != 35) && 
		 ((k-3) != 42) && ((k-3) != 45 ) && ((k-3) != 47)                      ) begin
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
   
   $display("WARNING - WARNING - WARNING - WARNING - WARNING");
   $display("THIS IS NOT THE TESTBENCH THAT SHALL BE USED TO GRADE YOUR INDIVIDUAL PROJECT");
   $display("THE PURPOSE OF THIS TESTBENCH IS TO GET YOU STARTED");
   $display("A MORE COMPLICATED TESTBENCH WILL BE USED TO FULLY TEST YOUR DESIGN");
   $display("THIS TESTBENCH MAY CONTAIN BUGS");   
   $display("END OF WARNING");
   $display(" ");

end

endmodule
