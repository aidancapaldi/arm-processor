//Christian Bender and Joe Perkins
//Final Project Test Bench
//EECE3324
//Prof. Julius Marpaung

`timescale 1ns/10ps


module cpu5armtbChristian();

parameter num = 61;
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

// INSTR that need to be tested: 
// B, BEQ, BNE, BLT, BGE, CBZ, CBNZ, ADD, ADDS, SUB, SUBS, AND, ANDS, EOR, ENOR
// 2,   4,   2,   2,   2,   1,    1,   1,    1,   2,    3,   1,    1,   1,    1

// ORR, LSL, LSR, ADDI, ADDIS, SUBI, SUBIS, ANDI, ANDIS, EORI, ENORI, ORRI, MOVZ
//   2,   2,   2,    2,     1,    2,     3,    1,     1,    1,     1,    1,    2

// STUR, LDUR
//    2,    4

// Register storing and setup, general testing
iname[0]  = "ADDI  R1,  R31, #1";      //R1  =  1
iname[1]  = "ADDI  R2,  R31, #2";      //R2  =  2
iname[2]  = "SUBI  R3,  R31, #1001";   //R3  = -1,001
iname[3]  = "SUB   R4,  R31, R1";      //R4  = -1
iname[4]  = "LDUR  R10, [R2, #50]";    //R10 =  8,404,465,998,076,206,250
iname[5]  = "LDUR  R11, [R1, #250]";   //R11 = -8,377,078,545,689,331,360
iname[6]  = "SUB   R5,  R1,  R2";      //R5  = 1
iname[7]  = "BLT   #20";               //Branch not enabled S flag false from [6] (change to BGE or something)
iname[8]  = "SUBIS R5,  R1,  #2";      //R5  = 1
iname[9]  = "BLT   #24";               //Branch to (64'h0000000000000024 + (d'24 * 4)) as R1 < #2
iname[10] = "NOP AND   R7,  R3,  R11"; //R7  = -8,377,078,545,689,331,712
iname[11] = "NOP LDUR  R12, [R2, #0]"; //R12 = -3,689,348,814,741,910,324
iname[12] = "LDUR  R13, [R2, #6]";     //R13 =  3,689,348,814,741,910,323
iname[13] = "EOR   R6,  R10, R11";     //R6  =    -64,165,052,033,636,918
iname[14] = "ADD   R14, R12, R1";      //R14 = -3,689,348,814,741,910,323
iname[15] = "ENORI R8,  R10, #3918";   //R8  = -8,404,465,998,076,204,005

// Flag testing on set operations outside of SUBS and SUBIS
iname[16] = "ANDS  R9,  R12, R13";     //R9  = 0, Z = True, Take Branch (shows ANDS set flags working)
iname[17] = "BEQ   #4";                //Branch to (64'h0000000000000098 + (d'4 * 4)) (Z True)
iname[18] = "NOP LSL   R15, R8,  #7";  //R15 = -3,068,286,578,108,289,024
iname[19] = "NOP ADDIS R16, R3, #1001";//R16 = 0, Z = True, Take Branch (shows ADDIS set flags working)
iname[20] = "BEQ   #8";                //Branch to (64'h00000000000000B4 + (d'8 * 8)) (Z==0)
iname[21] = "LSR   R17, R6,  #20";     //R17 =         17,530,993,482,280
iname[22] = "ADDS  R5,  R14, R13";     //R5  = 0, Z = True (shows ADDS set flags work)
iname[23] = "BEQ   #12";               //Branch to (64'h00000000000000D4 + (d'12 * 4)) (Z True)
iname[24] = "NOP MOVZ  R29, (<< 2*16), #hB17E"; //R29 =   195,154,723,995,648
iname[25] = "NOP ANDIS R31, R3, #1000";//R18 = 0
iname[26] = "BEQ   #20";               //Branch to (64'h000000000000010C + (d'20 *4)) = h'158
iname[27] = "NOP MOVZ  R28, (<< 3*16), #hBBBB"; //R28 = -4,919,338,167,972,134,912 

// Branch testing on expected operations and flags, general testing
iname[28] = "B     #1234";             //Branch to (64'h0000000000000158 + (64'h4D2 * 4)) = 64'h00000000000014A0 
iname[29] = "NOP ENOR R6, R1, R3";      //R5 = 1 ENOR -1001 = 1001 (h'3E9)
iname[30] = "B     #-1234";            //Branch to (64'h00000000000014A0 - (64'h4D2 * 4)) = 64'h00000000000000158
iname[31] = "NOP ORR R6, R14, R12";     //R6 = -3,689,348,814,741,910,323 ORR -3,689,348,814,741,910,323 = -3,689,348,814,741,910,323
iname[32] = "STUR  R2, [R4, #0]";      //M[2 + 0] = -1
iname[33] = "SUBS  R20, R11, R8";      //R20 =     27,387,452,386,872,645
iname[34] = "BGE   #-15";              //Branch to (64'h0000000000000160 - (d'-60 * 4)) = 64'hFFFF FFFF FFFF FFE0
iname[35] = "ADDI R10, R5, #1";        //R10 = 0 + 1 = 1
iname[36] = "EORI R4, R13, #2730";     //R4 =  3,689,348,814,741,911,961
iname[37] = "ORRI R8, R31, 1000";      //R8 =  0 ORR 64'h  = 64'h3E8
iname[38] = "CBZ  R5, #-75";           //Branch to (64'h000000000000012C + (d'-300 * 4))
iname[39] = "NOP ADD  R26, R31, R4";   //R26 = 3,689,348,814,741,911,961
iname[40] = "LSL  R27, R6, #63";       //R27 = -9,223,372,036,854,775,808
iname[41] = "CBNZ  R8, #75";           //Branch to (64'h)
iname[42] = "NOP LSR  R31, R27, #32";  //R27 >> 32, not stored
iname[43] = "STUR  R27, [R1, #29]";    //
iname[44] = "SUBIS R16, R29, #64";     //R16 = 195,154,723,995,648 - 64 = 195,154,723,995,584
iname[45] = "BNE R31, #8";             //branch taken + 8 * 4
iname[46] = "SUBS R13, R1, R14";       //R13 = 1 - (-3,689,348,814,741,910,323) = 3,689,348,814,741,910,324
iname[47] = "BGE R31, #129";           //branch taken + 129 * 4
iname[48] = "SUBS R31, R5, R31";       //Result is 0 - 0 = 0
iname[49] = "BNE R31, #1234";          //branch not taken
iname[50] = "SUBIS R31, R14, #100";    // 
iname[51] = "BGE R31, #129";           //branch not taken
iname[52] = "NOP ORR  R28, R31, R27";  //R28 = -9,223,372,036,854,775,808
iname[53] = "SUBS R31, R26, R4";       //Show that R26 and R4 are equal, result not stored
iname[54] = "BEQ  #200";               //Branch to (64'h0000000000000610 + (d'200 * 4)) = h'930
iname[55] = "NOP SUBI  R24, R11, #4095";//R24 = -8,377,078,545,689,335,455

// More in depth test on ANDS flag output
iname[56] = "ANDS  R16, R11, R7";      //R16 = -8,377,078,545,689,331,712, N == V (shows AND set flags working)
iname[57] = "BLT   #8";                //Branch to (64'h0000000000000934 + (d'8 * 8)) (N != V) = h'974
iname[58] = "NOP ANDI  R31, R27, #4080";
iname[59] = "NOP EORI  R31, R13, #1911";
iname[60] = "NOP ENORI R31, R31, #3731";
iname[61] = "NOP ADDIS R31, R3,  #3853";
 

dontcare = 64'hx;

//0 * ADDI  R1,  R31, #1
iaddrbusout[0] = 64'h0000000000000000;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[0]={ADDI, 12'h001         , 5'b11111, 5'b00001};

daddrbusout[0] = 64'h0000000000000001;
databusin[0]   = 64'hzzzzzzzzzzzzzzzz;
databusout[0]  = dontcare;

//1 * ADDI  R2,  R31, #2
iaddrbusout[1] = 64'h0000000000000004;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[1]={ADDI, 12'h002         , 5'b11111, 5'b00010};

daddrbusout[1] = 64'h0000000000000002;
databusin[1]   = 64'hzzzzzzzzzzzzzzzz;
databusout[1]  = dontcare;

//2 * ADDI  R3,  R31, #1001
iaddrbusout[2] = 64'h0000000000000008;
//           opcode, ALU_immediate   , Asel    , Result
instrbusin[2]={SUBI, 12'h3E9         , 5'b11111, 5'b00011};

daddrbusout[2] = 64'hFFFFFFFFFFFFFC17; 
databusin[2]   = 64'hzzzzzzzzzzzzzzzz;
databusout[2]  = dontcare;

//3 * SUB   R4,  R31, R1
iaddrbusout[3] = 64'h000000000000000C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[3]={SUB , 5'd1, 6'd1 , 5'd31, 5'd4};

daddrbusout[3] = 64'hFFFFFFFFFFFFFFFF;
databusin[3]   = 64'hzzzzzzzzzzzzzzzz;
databusout[3]  = dontcare;

//4 * LDUR  R10, [R2, 50]
iaddrbusout[4] = 64'h0000000000000010;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[4]={LDUR, 9'd50      , 2'b00, 5'd2    , 5'd10};

daddrbusout[4] = 64'h0000000000000034;
databusin[4]   = 64'h74A2A94BE62E5CAA;
databusout[4]  = dontcare;

//5 * LDUR   R11, [R1, #400]
iaddrbusout[5] = 64'h0000000000000014;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[5]={LDUR, 9'd250     , 2'b00, 5'd1    , 5'd11};

daddrbusout[5] = 64'h00000000000000FB;
databusin[5]   = 64'h8BBEA37244A43960;
databusout[5]  = dontcare;

//6 * SUB   R5,  R1, R2
iaddrbusout[6] = 64'h0000000000000018;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[6]={SUB , 5'd2, 6'd1 , 5'd1, 5'd5};

daddrbusout[6] = 64'hFFFFFFFFFFFFFFFF;
databusin[6]   = 64'hzzzzzzzzzzzzzzzz;
databusout[6]  = dontcare;

//7 * BLT  #20
iaddrbusout[7] = 64'h000000000000001C;
//          opcode, CB_addr, Rt
instrbusin[7]={BLT, 19'd20, 5'd0};
daddrbusout[7] = dontcare;
databusin[7]   = 64'hzzzzzzzzzzzzzzzz;
databusout[7]  = dontcare;

//8 * SUBIS  R5, R1, #2
iaddrbusout[8] = 64'h0000000000000020;
//           opcode, ALU_immediate, Asel , Result 
instrbusin[8]={SUBIS, 12'h002     , 5'd1, 5'd5};

daddrbusout[8] = 64'hFFFFFFFFFFFFFFFF;
databusin[8]   = 64'hzzzzzzzzzzzzzzzz;
databusout[8]  = dontcare;

//9 * BLT  #24
iaddrbusout[9] = 64'h0000000000000024;
//          opcode, CB_addr, Rt
instrbusin[9]={BLT, 19'd24, 5'd0};
daddrbusout[9] = dontcare;
databusin[9]   = 64'hzzzzzzzzzzzzzzzz;
databusout[9]  = dontcare;

//10* AND   R7,  R3,  R11
iaddrbusout[10] = 64'h0000000000000028;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[10]={AND , 5'd11, 6'd1 , 5'd3, 5'd7};

daddrbusout[10] = 64'h8BBEA37244A43800;
databusin[10]   = 64'hzzzzzzzzzzzzzzzz;
databusout[10]  = dontcare;

//11* LDUR  R12, [R2, 0]
iaddrbusout[11] = 64'h0000000000000084;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[11]={LDUR, 9'd0      , 2'b00, 5'd2    , 5'd12};

daddrbusout[11] = 64'h0000000000000002;
databusin[11]   = 64'hCCCCCCCCCCCCCCCC;
databusout[11]  = dontcare;

//12* LDUR  R13, [R2, 0]
iaddrbusout[12] = 64'h0000000000000088;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[12]={LDUR, 9'd6       , 2'b00, 5'd2    , 5'd13};

daddrbusout[12] = 64'h0000000000000008;
databusin[12]   = 64'h3333333333333333;
databusout[12]  = dontcare;

//13* EOR   R6,  R10, R11
iaddrbusout[13] = 64'h000000000000008C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[13]={EOR , 5'd11, 6'd1 , 5'd10, 5'd6};

daddrbusout[13] = 64'hFF1C0A39A28A65CA;
databusin[13]   = 64'hzzzzzzzzzzzzzzzz;
databusout[13]  = dontcare;

//14* ADD   R14, R12, R1
iaddrbusout[14] = 64'h0000000000000090;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[14]={ADD, 5'd1, 6'd0, 5'd12, 5'd14};

daddrbusout[14] = 64'hCCCCCCCCCCCCCCCD;
databusin[14]   = 64'hzzzzzzzzzzzzzzzz;
databusout[14]  = dontcare;

//15* ENORI R8,  R10, #3918
iaddrbusout[15] = 64'h0000000000000094;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[15]={ENORI, 12'd3918, 5'd10, 5'd8};

daddrbusout[15] = 64'h8B5D56B419D1AC1B;
databusin[15]   = 64'hzzzzzzzzzzzzzzzz;
databusout[15]  = dontcare;

//16* ANDS  R9,  R12, R13
iaddrbusout[16] = 64'h0000000000000098;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[16]={ANDS, 5'd13, 6'd2, 5'd12, 5'd9};

daddrbusout[16] = 64'h0000000000000000;
databusin[16]   = 64'hzzzzzzzzzzzzzzzz;
databusout[16]  = dontcare;

//17* BEQ  #4
iaddrbusout[17] = 64'h000000000000009C;
//          opcode, CB_addr, Rt
instrbusin[17]={BEQ, 19'd4, 5'd0};
daddrbusout[17] = dontcare;
databusin[17]   = 64'hzzzzzzzzzzzzzzzz;
databusout[17]  = dontcare;

//18* LSL   R15, R8,  12
iaddrbusout[18] = 64'h00000000000000A0;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[18]={LSL, 5'd30, 6'd12, 5'd8, 5'd15};

daddrbusout[18] = 64'hD56B419D1AC1B000;
databusin[18]   = 64'hzzzzzzzzzzzzzzzz;
databusout[18]  = dontcare;

//19* ADDIS R16, R3, #1001
iaddrbusout[19] = 64'h0000000000000AC;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[19]={ANDIS, 12'd1000, 5'd3, 5'd16};

daddrbusout[19] = 64'h0000000000000000;
databusin[19]   = 64'hzzzzzzzzzzzzzzzz;
databusout[19]  = dontcare;

//20* BEQ   #8
iaddrbusout[20] = 64'h00000000000000B0;
//          opcode, CB_addr, Rt
instrbusin[20]={BEQ, 19'd8, 5'd0};
daddrbusout[20] = dontcare;
databusin[20]   = 64'hzzzzzzzzzzzzzzzz;
databusout[20]  = dontcare;

//21* LSR   R17, R6,  #20
iaddrbusout[21] = 64'h00000000000000B4;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[21]={LSR, 5'd01, 6'd20, 5'd6, 5'd17};

daddrbusout[21] = 64'h00000FF1C0A39A28;
databusin[21]   = 64'hzzzzzzzzzzzzzzzz;
databusout[21]  = dontcare;

//22* ADDS  R5,  R14, R13
iaddrbusout[22] = 64'h00000000000000D0;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[22]={ADDS, 5'd13, 6'd1, 5'd14, 5'd5};

daddrbusout[22] = 64'h0000000000000000;
databusin[22]   = 64'hzzzzzzzzzzzzzzzz;
databusout[22]  = dontcare;

//23* BEQ  #12
iaddrbusout[23] = 64'h00000000000000D4;
//          opcode, CB_addr, Rt
instrbusin[23]={BEQ, 19'd12, 5'd0};
daddrbusout[23] = dontcare;
databusin[23]   = 64'hzzzzzzzzzzzzzzzz;
databusout[23]  = dontcare;

//24* MOVZ  R31, (<< 1*16), #hABCD 
iaddrbusout[24] = 64'h00000000000000D8;
//            opcode, instr, MOV_imm , result
instrbusin[24]={MOVZ, 2'b10, 16'hB17E, 5'd29};

daddrbusout[24] = 64'h0000B17E00000000;
databusin[24]   = 64'hzzzzzzzzzzzzzzzz;
databusout[24]  = dontcare;

//25* ANDIS R31, R3,  #1000
iaddrbusout[25] = 64'h0000000000000104;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[25]={ANDIS, 12'd1000, 5'd3, 5'd31};

daddrbusout[25] = 64'h0000000000000000;
databusin[25]   = 64'hzzzzzzzzzzzzzzzz;
databusout[25]  = dontcare;

//26* BEQ  #20
iaddrbusout[26] = 64'h00000000000000108;
//          opcode, CB_addr, Rt
instrbusin[26]={BEQ, 19'd20, 5'd0};
daddrbusout[26] = dontcare;
databusin[26]   = 64'hzzzzzzzzzzzzzzzz;
databusout[26]  = dontcare;

//27* MOVZ  R28, (<< 3*16), #hBBBB
iaddrbusout[27] = 64'h000000000000010C;
//            opcode, instr, MOV_imm , result
instrbusin[27]={MOVZ, 2'b11, 16'hBBBB, 5'd28};

daddrbusout[27] = 64'hBBBB000000000000;
databusin[27]   = 64'hzzzzzzzzzzzzzzzz;
databusout[27]  = dontcare;

//28* B     #d1234
iaddrbusout[28] = 64'h0000000000000158;
//             opcode,  BAddr
instrbusin[28]={BRANCH, 26'd1234};

daddrbusout[28] = dontcare;
databusin[28]   = 64'hzzzzzzzzzzzzzzzz;
databusout[28]  = dontcare;

//29* ENOR R6, R1, R3
iaddrbusout[29] = 64'h0000000000000015C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[29]={ENOR, 5'd3, 6'd7, 5'd1, 5'd6};

daddrbusout[29] = 64'h00000000000003E9;
databusin[29]   = 64'hzzzzzzzzzzzzzzzz;
databusout[29]  = dontcare;

//30* B     #d-1234
iaddrbusout[30] = 64'h00000000000014A0;
//             opcode,  BAddr
instrbusin[30]={BRANCH, 26'b11111111111111101100101110};

daddrbusout[30] = dontcare;
databusin[30]   = 64'hzzzzzzzzzzzzzzzz;
databusout[30]  = dontcare;

//31* ORR R6, R14, R12
iaddrbusout[31] = 64'h00000000000014A4;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[31]={ORR, 5'd12, 6'd6, 5'd14, 5'd6};

daddrbusout[31] = 64'hCCCCCCCCCCCCCCCD;
databusin[31]   = 64'hzzzzzzzzzzzzzzzz;
databusout[31]  = dontcare;

//32* STUR  R2,  #0, R4
iaddrbusout[32] = 64'h0000000000000158;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[32]={STUR, 9'b000000000, 2'b10, 5'd4, 5'd2};

daddrbusout[32] = 64'hFFFFFFFFFFFFFFFF;
databusin[32]   = 64'hzzzzzzzzzzzzzzzz;
databusout[32]  = 64'h0000000000000002;

//33* SUBS  R20, R11, R8
iaddrbusout[33] = 64'h000000000000015C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[33]={SUBS, 5'd8, 6'd5, 5'd11, 5'd20};

daddrbusout[33] = 64'h00614CBE2AD28D45;
databusin[33]   = 64'hzzzzzzzzzzzzzzzz;
databusout[33]  = dontcare;

//34* BGE  #-60
iaddrbusout[34] = 64'h0000000000000160;
//          opcode, CB_addr, Rt
instrbusin[34]={BGE, 19'b1111111111111110001, 5'd0};
daddrbusout[34] = dontcare;
databusin[34]   = 64'hzzzzzzzzzzzzzzzz;
databusout[34]  = dontcare;

//35* ADDI R10, R5, #1
iaddrbusout[35] = 64'h0000000000000164;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[35]={ADDI, 12'd1, 5'd5, 5'd10};

daddrbusout[35] = 64'h0000000000000001;
databusin[35]   = 64'hzzzzzzzzzzzzzzzz;
databusout[35]  = dontcare;

//36* EORI R4, R13, #43690
iaddrbusout[36] = 64'h0000000000000124;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[36]={EORI, 12'd2730, 5'd13, 5'd4};

daddrbusout[36] = 64'h3333333333333999;
databusin[36]   = 64'hzzzzzzzzzzzzzzzz;
databusout[36]  = dontcare;

//37* ORRI R8, R31, 1000
iaddrbusout[37] = 64'h0000000000000128;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[37]={ORRI, 12'd1000, 5'd31, 5'd8};

daddrbusout[37] = 64'h00000000000003E8;
databusin[37]   = 64'hzzzzzzzzzzzzzzzz;
databusout[37]  = dontcare;

//38* CBZ  R5, #-75
iaddrbusout[38] = 64'h000000000000012C;
//            opcode
instrbusin[38]={CBZ, 19'b1111111111110110101, 5'd5};
daddrbusout[38] = dontcare;
databusin[38]   = 64'hzzzzzzzzzzzzzzzz;
databusout[38]  = dontcare;

//39* ADD  R26, R31, R4
iaddrbusout[39] = 64'h0000000000000130;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[39]={ADD, 5'd4, 6'd2, 5'd31, 5'd26};

daddrbusout[39] = 64'h3333333333333999;
databusin[39]   = 64'hzzzzzzzzzzzzzzzz;
databusout[39]  = dontcare;

//40* LSL  R27, R6, #63
iaddrbusout[40] = 64'h0000000000000000;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[40]={LSL, 5'd31, 6'd63, 5'd6, 5'd27};

daddrbusout[40] = 64'h8000000000000000;
databusin[40]   = 64'hzzzzzzzzzzzzzzzz;
databusout[40]  = dontcare;

//41* CBNZ  R8, #75
iaddrbusout[41] = 64'h0000000000000004;
//            opcode
instrbusin[41]={CBNZ, 19'd75, 5'd8};
daddrbusout[41] = dontcare;
databusin[41]   = 64'hzzzzzzzzzzzzzzzz;
databusout[41]  = dontcare;

//42* LSR  R31, R26, #32
iaddrbusout[42] = 64'h0000000000000008;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[42]={LSR, 5'd15, 6'd32, 5'd26, 5'd31};

daddrbusout[42] = 64'h0000000033333333;
databusin[42]   = 64'hzzzzzzzzzzzzzzzz;
databusout[42]  = dontcare;

//43* STUR  R27, [R1, #29]
iaddrbusout[43] = 64'h0000000000000130;
//           opcode, DT_addr    , OP   , Asel    , Result
instrbusin[43]={STUR, 9'd29, 2'b01, 5'd1, 5'd27};

daddrbusout[43] = 64'h000000000000001E;
databusin[43]   = 64'hzzzzzzzzzzzzzzzz;
databusout[43]  = 64'h8000000000000000;

//44* SUBIS R16, R29, #64
iaddrbusout[44] = 64'h0000000000000134;
//           opcode, Imm , Rn, Rd
instrbusin[44]={SUBIS, 12'd64, 5'd29, 5'd16};

daddrbusout[44] = 64'h0000B17DFFFFFFC0;
databusin[44]   = 64'hzzzzzzzzzzzzzzzz;
databusout[44]  = dontcare;

//45* BNE R31, #8
iaddrbusout[45] = 64'h0000000000000138;
//           opcode, Baddr, Rt
instrbusin[45]={BNE, 19'd8, 5'd31};

daddrbusout[45] = dontcare;
databusin[45]   = 64'hzzzzzzzzzzzzzzzz;
databusout[45]  = dontcare;

//46* SUBS R13 R1 R14
iaddrbusout[46] = 64'h000000000000013C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[46]={SUBS, 5'd14, 6'd0, 5'd1, 5'd13};

daddrbusout[46] = 64'h3333333333333334;
databusin[46]   = 64'hzzzzzzzzzzzzzzzz;
databusout[46]  = dontcare;

//47* BGE R31, #129
iaddrbusout[47] = 64'h0000000000000158;
//           opcode, Baddr, Rt
instrbusin[47]={BNE, 19'd129, 5'd31};

daddrbusout[47] = dontcare;
databusin[47]   = 64'hzzzzzzzzzzzzzzzz;
databusout[47]  = dontcare;

//48* SUBS R31, R5, R31
iaddrbusout[48] = 64'h000000000000015C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[48]={SUBS, 5'd31, 6'd0, 5'd5, 5'd31};

daddrbusout[48] = 64'h0000000000000000;
databusin[48]   = 64'hzzzzzzzzzzzzzzzz;
databusout[48]  = dontcare;

//49* BNE R31, #1234
iaddrbusout[49] = 64'h000000000000035C;
//           opcode, Baddr, Rt
instrbusin[49]={BNE, 19'd1234, 5'd31};

daddrbusout[49] = dontcare;
databusin[49]   = 64'hzzzzzzzzzzzzzzzz;
databusout[49]  = dontcare;

//50* SUBIS R31, R14, #100
iaddrbusout[50] = 64'h0000000000000360;
//           opcode, Imm , Rn, Rd
instrbusin[50]={SUBIS, 12'd100, 5'd14, 5'd31};

daddrbusout[50] = 64'hCCCCCCCCCCCCCC69;
databusin[50]   = 64'hzzzzzzzzzzzzzzzz;
databusout[50]  = dontcare;

//51* BGE R31, #129
iaddrbusout[51] = 64'h0000000000000364;
//           opcode, Baddr, Rt
instrbusin[51]={BGE, 19'd129, 5'd31};

daddrbusout[51] = dontcare;
databusin[51]   = 64'hzzzzzzzzzzzzzzzz;
databusout[51]  = dontcare;

//52* ORR  R28, R31, R27
iaddrbusout[52] = 64'h00000000000000368;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[52]={ORR, 5'd27, 6'd0, 5'd31, 5'd28};
daddrbusout[52] = 64'h8000000000000000;
databusin[52]   = 64'hzzzzzzzzzzzzzzzz;
databusout[52]  = dontcare;

//53* SUBS   R31, R26, R4
iaddrbusout[53] = 64'h0000000000000036C;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[53]={SUBS, 5'd4, 6'd0, 5'd26, 5'd31};
daddrbusout[53] = 64'h0000000000000000;
databusin[53]   = 64'hzzzzzzzzzzzzzzzz;
databusout[53]  = dontcare; 

//54* BEQ  #200
iaddrbusout[54] = 64'h0000000000000370;
//           opcode, Baddr, Rt
instrbusin[54]={BEQ, 19'd200, 5'd31};

daddrbusout[54] = dontcare;
databusin[54]   = 64'hzzzzzzzzzzzzzzzz;
databusout[54]  = dontcare;

//55* SUBI  R24, R11, #4095
iaddrbusout[55] = 64'h0000000000000374;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[55]={SUBI, 12'd4095, 5'd11, 5'd24};

daddrbusout[55] = 64'h8BBEA37244A42961;
databusin[55]   = 64'hzzzzzzzzzzzzzzzz;
databusout[55]  = dontcare;

//56* ANDS  R16, R11, R7
iaddrbusout[56] = 64'h00000000000000690;
//           opcode, Bsel , Shamt, Asel , Result
instrbusin[56]={ANDS, 5'd7, 6'd0, 5'd11, 5'd16};
daddrbusout[56] = 64'h8BBEA37244A43800;
databusin[56]   = 64'hzzzzzzzzzzzzzzzz;
databusout[56]  = dontcare;

//57* BLT   #8
iaddrbusout[57] = 64'h0000000000000694;
//          opcode, CB_addr, Rt
instrbusin[57]={BLT, 19'd8, 5'd0};
daddrbusout[57] = dontcare;
databusin[57]   = 64'hzzzzzzzzzzzzzzzz;
databusout[57]  = dontcare;

//58* ANDI  R31, R27, #4080
iaddrbusout[58] = 64'h0000000000000698;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[58]={ANDI, 12'd4080, 5'd27, 5'd31};

daddrbusout[58] = 64'h0000000000000000;
databusin[58]   = 64'hzzzzzzzzzzzzzzzz;
databusout[58]  = dontcare;

//59* EORI  R31, R13, #1911
iaddrbusout[59] = 64'h00000000000006B4;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[59]={EORI, 12'd1911, 5'd13, 5'd31};

daddrbusout[59] = 64'h3333333333333443;
databusin[59]   = 64'hzzzzzzzzzzzzzzzz;
databusout[59]  = dontcare;

//60* ENORI R31, R31, #3731
iaddrbusout[60] = 64'h00000000000006B8;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[60]={ENORI, 12'd3731, 5'd31, 5'd31};

daddrbusout[60] = 64'hFFFFFFFFFFFFF16C;
databusin[60]   = 64'hzzzzzzzzzzzzzzzz;
databusout[60]  = dontcare;

//61* ADDIS R31, R31, #3731
iaddrbusout[61] = 64'h00000000000006BC;
//           opcode, ALU_immediate   , Asel    , Result 
instrbusin[61]={ADDIS, 12'd3853, 5'd3, 5'd31};

daddrbusout[61] = 64'h00000000000006D0;
databusin[61]   = 64'hzzzzzzzzzzzzzzzz;
databusout[61]  = dontcare;




// (no. instructions) + (no. loads) + 2*(no. stores) = 
// 61                 +  4          + 2*(2) 
ntests = 69;

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
	  ((k-3) != 7)  && ((k-3) != 9) && ((k-3) != 17) && ((k-3) != 20) && 
	  ((k-3) != 23) && ((k-3) != 26) && ((k-3) != 28) && ((k-3) != 30) &&                       
    ((k-3) != 34) && ((k-3) != 38) && ((k-3) != 41) && ((k-3) != 45) &&
    ((k-3) != 47) && ((k-3) != 49) && ((k-3) != 51) && ((k-3) != 51) &&
    ((k-3) != 54) && ((k-3) != 57) && ((k-3) != 58) && ((k-3) != 59) &&
    ((k-3) != 60) && ((k-3) != 61)) begin
	
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
	  ((k-3) != 7)  && ((k-3) != 9) && ((k-3) != 17) && ((k-3) != 20) && 
	  ((k-3) != 23) && ((k-3) != 26) && ((k-3) != 28) && ((k-3) != 30) &&                       
    ((k-3) != 34) && ((k-3) != 38) && ((k-3) != 41) && ((k-3) != 45) &&
    ((k-3) != 47) && ((k-3) != 49) && ((k-3) != 51) && ((k-3) != 51) &&
    ((k-3) != 54) && ((k-3) != 57) && ((k-3) != 58) && ((k-3) != 59) &&
    ((k-3) != 60) && ((k-3) != 61)) begin

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
