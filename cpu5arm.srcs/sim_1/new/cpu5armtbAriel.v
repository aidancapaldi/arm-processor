`timescale 1ns/10ps

// Written by Dr. Marpaung  
// Not to be published outside NEU.edu domain without a written permission/consent from Dr. Marpaung
// All Rights Reserved 

// THIS IS NOT THE TESTBENCH THAT SHALL BE USED TO GRADE YOUR INDIVIDUAL PROJECT
// THE PURPOSE OF THIS TESTBENCH IS TO GET YOU STARTED
// A MORE COMPLICATED TESTBENCH WILL BE USED TO FULLY TEST YOUR DESIGN
// THIS TESTBENCH MAY CONTAIN BUGS

module cpu5armtbAriel();

    parameter num = 52;
    reg  [31:0] instrbus;
    reg  [31:0] instrbusin[0:num];
    wire [63:0] iaddrbus, daddrbus;
    reg  [63:0] iaddrbusout[0:num], daddrbusout[0:num];
    wire [63:0] databus;
    reg  [63:0] databusk, databusin[0:num], databusout[0:num];
    reg         clk, reset;
    reg         clkd;

    reg [63:0] dontcare, datazs;
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

        iname[0]  = "SUBI R20, R31, #1";
        iname[1]  = "ADDI R21, R31, #1010";
        iname[2]  = "ADDI R22, R31, #1";
        iname[3]  = "LDUR R24, [R20,0]";
        iname[4]  = "LDUR R25, [R21,0]";
        iname[5]  = "STUR R20, [R22,10]";
        iname[6]  = "EOR  R10, R22, R24";
        iname[7]  = "LSL  R23, R24, #4";
        iname[8]  = "AND  R20, R22, R24";
        iname[9]  = "STUR R21, [R22, 20]";
        iname[10] = "AND  R21, R22, R25";
        iname[11] = "ADD  R28, R24, R25";
        iname[12] = "SUBI R19, R24, 1111";
        iname[13] = "ADD  R29, R24, R25";
        iname[14] = "ORRI R18, R20, 0x1111";
        iname[15] = "ORR  R30, R20, R21";
        iname[16] = "B    #300";
        iname[17] = "ENOR R10, R20, R21";
        iname[18] = "EOR  R9,  R20, R21";
        iname[19] = "SUB  R15, R31, R21";
        iname[20] = "LSL  R11, R10, #2";
        iname[21] = "LSR  R12, R9, #110";
        iname[22] = "ANDI R20, R15, #7FF";
        iname[23] = "SUBIS R31, R22, #1";
        iname[24] = "BEQ  #16"; // No Branch
        iname[25] = "EORI R31, R31, #1"; // Delay Slot   //Branched Location
        iname[26] = "ADDIS R2,  R31, #15";
        iname[27] = "BGE  #24";
        iname[28] = "NOP  ENOR R31, R22, R31";
        iname[29] = "NOP  SUB  R31, R20, R21";
        iname[30] = "SUBS R31, R24, R28"; 
        iname[31] = "BLT  #16"; // Branching
        iname[32] = "NOP  ANDS  R31,  R20, R31";
        iname[33] = "NOP  ADDS  R31,  R20, R31";
        iname[34] = "ORR  R31,  R20, R24";
        iname[35] = "ANDS R31,  R22, R31";
        iname[36] = "BNE  #4"; // Branching!!
        iname[37] = "NOP  ENORI R31,  R31, #0";
        iname[38] = "SUBS  R29, R11, R10";
        iname[39] = "ORRI R20, R31, #h0F0";
        iname[40] = "LSR  R31, R20, 6'd10";
        iname[41] = "ANDIS R31, R20, 0x0FF";
        iname[42] = "CBZ  R31, #d32";
        iname[43] = "MOVZ R31, (<< 1*16), #h1111 ";
        iname[44] = "MOVZ R31, (<< 2*16), #h0001 ";
        iname[45] = "ADDS R31, R10, R9";
        iname[46] = "ENORI R31,  R31, #0";
        iname[47] = "CBNZ R20, #d16";
        iname[48] = "NOP  EORI  R31,  R31, #FF";
        iname[49] = "NOP  ANDI  R31,  R31, #FFF";
        iname[50] = "NOP  SUBIS R31,  R12, #43";
        iname[51] = "NOP  ADDIS  R31,  R31, #11";
        iname[52] = "NOP  ANDIS  R31,  R29, #7FF";

        dontcare = 64'hx;
        datazs = 64'bz;

        //* SUBI R20, R31, #1
        iaddrbusout[0] = 64'h0000000000000000;
        //            opcode 
        instrbusin[0]={SUBI, 12'b000000000001, 5'b11111, 5'b10100};

        daddrbusout[0] = 64'b1111111111111111111111111111111111111111111111111111111111111111; //dontcare;
        databusin[0] = datazs;
        databusout[0] = dontcare;

        //* ADDI R21, R31, #1010
        iaddrbusout[1] = 64'h0000000000000004;
        //            opcode
        instrbusin[1]={ADDI, 12'b000000001010, 5'b11111, 5'b10101};

        daddrbusout[1] = 64'b0000000000000000000000000000000000000000000000000000000000001010; //dontcare;
        databusin[1]   = datazs;
        databusout[1]  = dontcare;

        //* ADDI R22, R31, #1
        iaddrbusout[2] = 64'h0000000000000008;
        //            opcode
        instrbusin[2]={ADDI, 12'b000000000001, 5'b11111, 5'b10110};

        daddrbusout[2] = 64'b0000000000000000000000000000000000000000000000000000000000000001; //dontcare; 
        databusin[2]   = datazs;
        databusout[2]  = dontcare;

        //* LDUR R24, [R20,0]
        iaddrbusout[3] = 64'h000000000000000C;
        //            opcode
        instrbusin[3]={LDUR, 9'b000000000, 2'b00, 5'b10100, 5'b11000};

        daddrbusout[3] = 64'hFFFFFFFFFFFFFFFF;
        databusin[3]   = 64'hCCCCCCCCCCCCCCCC;
        databusout[3]  = dontcare;

        //* LDUR R25, [R21,0]
        iaddrbusout[4] = 64'h0000000000000010;
        //            opcode
        instrbusin[4]={LDUR, 9'b000000000, 2'b00, 5'b10101, 5'b11001};

        daddrbusout[4] = 64'h000000000000000A;
        databusin[4] = 64'hAAAAAAAAAAAAAAAA;
        databusout[4] = dontcare;

        //* STUR R20, [R22,10]
        iaddrbusout[5] = 64'h0000000000000014;
        //            opcode 
        instrbusin[5]={STUR, 9'b000001010, 2'b01, 5'b10110, 5'b10100};

        daddrbusout[5] = 64'h000000000000000B;
        databusin[5] = datazs;
        databusout[5] = 64'hFFFFFFFFFFFFFFFF;

        //* EOR  R10, R22, R24
        iaddrbusout[6] = 64'h0000000000000018;
        //            opcode 
        instrbusin[6]={EOR, 5'd24, 6'd000000, 5'd22, 5'd10};

        daddrbusout[6] = 64'hCCCCCCCCCCCCCCCD;
        databusin[6] = datazs;
        databusout[6] = dontcare;

        //* LSL  R23, R24, #4
        iaddrbusout[7] = 64'h000000000000001C;
        //             opcode   
        instrbusin[7]={LSL, 5'd01, 6'd4, 5'd24, 5'd23};

        daddrbusout[7] = 64'hCCCCCCCCCCCCCCC0; //dontcare;
        databusin[7] = datazs;
        databusout[7] = dontcare;

        //* AND  R20, R22, R24
        iaddrbusout[8] = 64'h0000000000000020;
        //            opcode
        instrbusin[8]={AND, 5'd24, 6'd0, 5'd22, 5'd20};

        daddrbusout[8] = 64'h0000000000000000;
        databusin[8] = datazs;
        databusout[8] = dontcare;

        //* STUR R21, [R22, 20]
        iaddrbusout[9] = 64'h0000000000000024;
        //             opcode
        instrbusin[9]={STUR, 9'd20, 2'b01, 5'd22, 5'd21};

        daddrbusout[9] = 64'd21;
        databusin[9] = datazs;
        databusout[9]   = 64'b0000000000000000000000000000000000000000000000000000000000001010;

        //* AND  R21, R22, R25
        iaddrbusout[10] = 64'h0000000000000028;
        //            opcode
        instrbusin[10]={AND, 5'd25, 6'd0, 5'd22, 5'd21};

        daddrbusout[10] = 64'h0000000000000000;
        databusin[10] = datazs;
        databusout[10] = dontcare;

        //* ADD  R28, R24, R25
        iaddrbusout[11] = 64'h000000000000002C;
        //             opcode 
        instrbusin[11]={ADD, 5'd25, 6'd0, 5'd24, 5'd28};

        daddrbusout[11] = 64'h7777777777777776;
        databusin[11] = datazs;
        databusout[11] = dontcare;

        //* SUBI R19, R24, 1111
        iaddrbusout[12] = 64'h0000000000000030;
        //            opcode 
        instrbusin[12]={SUBI, 12'b000000001111, 5'd24, 5'd19};

        daddrbusout[12] = 64'hCCCCCCCCCCCCCCBD;
        databusin[12] = datazs;
        databusout[12] = dontcare;

        //* ADD  R29, R24, R25
        iaddrbusout[13] = 64'h0000000000000034;
        //             opcode  
        instrbusin[13]={ADD, 5'd25, 6'd0, 5'd24, 5'd29};

        daddrbusout[13] = 64'h7777777777777776;
        databusin[13] = datazs;
        databusout[13] = dontcare;

        //* ORRI R18, R20, 0x111
        iaddrbusout[14] = 64'h0000000000000038;
        instrbusin[14]={ORRI, 12'h111, 5'd20, 5'd18};

        daddrbusout[14] = 64'h0000000000000111;
        databusin[14] = datazs;
        databusout[14] = dontcare;

        //* ORR  R30, R20, R21
        iaddrbusout[15] = 64'h000000000000003C;
        instrbusin[15]={ORR, 5'd21, 6'd0, 5'd20, 5'd30};

        daddrbusout[15] = 64'h0000000000000000;
        databusin[15] = datazs;
        databusout[15] =  dontcare;

        //  B    #300
        iaddrbusout[16] = 64'h0000000000000040;
        //            opcode 
        instrbusin[16]={BRANCH, 26'h0000300};

        daddrbusout[16] = 64'b1100110011001100110011001100110011001100110011001100110011001100;
        databusin[16] = datazs;
        databusout[16]  = dontcare;

        //  ENOR R10, R20, R21
        iaddrbusout[17] = 64'h0000000000000044;
        //            opcode 
        instrbusin[17]={ENOR, 5'd21, 6'd0, 5'd20, 5'd10};

        daddrbusout[17] = 64'hFFFFFFFFFFFFFFFF;
        databusin[17] = datazs;
        databusout[17] = dontcare;

        //  EOR  R9,  R20, R21
        iaddrbusout[18] = 64'h0000000000000C40;
        //            opcode 
        instrbusin[18]={EOR, 5'd21, 6'd0, 5'd20, 5'd9};

        daddrbusout[18] = 64'h0000000000000000;
        databusin[18] = datazs;
        databusout[18]  = dontcare;

        //  SUB  R15, R31, R21
        iaddrbusout[19] = 64'h0000000000000C44;
        //            opcode 
        instrbusin[19]={SUB, 5'd21, 6'd0, 5'd31, 5'd15};

        daddrbusout[19] = 64'h0000000000000000;
        databusin[19] = datazs;
        databusout[19] = dontcare;

        //  LSL  R11, R10, #2
        iaddrbusout[20] = 64'h0000000000000C48;
        //            opcode 
        instrbusin[20]={LSL, 5'd01, 6'd2, 5'd10, 5'd11};

        daddrbusout[20] = 64'hFFFFFFFFFFFFFFFC;
        databusin[20] = datazs;
        databusout[20]  = dontcare;


        //  LSR  R12, R9, #110
        iaddrbusout[21] = 64'h0000000000000C4C;
        //             opcode  
        instrbusin[21]={LSR, 5'd01, 6'b000110, 5'd9, 5'd12};
        daddrbusout[21] = 64'h0000000000000000;
        databusin[21]   = datazs;
        databusout[21]  = dontcare;

        //*  ANDI R20, R15, #7FF
        iaddrbusout[22] = 64'h0000000000000C50;
        //            opcode 
        instrbusin[22]={ANDI, 12'h7FF, 5'd15, 5'd20};
        daddrbusout[22] = 64'h0000000000000000;
        databusin[22] = datazs;
        databusout[22] = dontcare;

        //* SUBIS R31, R22, #1
        iaddrbusout[23] = 64'h0000000000000C54;
        //            opcode 
        instrbusin[23]={SUBIS, 12'd1, 5'd22, 5'd31};
        daddrbusout[23] = 64'h0000000000000000;
        databusin[23] =   datazs;
        databusout[23] =  dontcare;

        //* BNE  #16 edited
        iaddrbusout[24] = 64'h0000000000000C58;
        //            opcode 
        instrbusin[24]={BEQ, 19'd16, 5'd0};
        daddrbusout[24] = dontcare;
        databusin[24] = datazs;
        databusout[24] = dontcare;

        //* NOP EORI R31, R31, #1
        iaddrbusout[25] = 64'h0000000000000C5C;
        //            opcode
        instrbusin[25]={EORI, 12'd1, 5'd31, 5'd31};
        daddrbusout[25] = 64'd1;
        databusin[25] = datazs;
        databusout[25] = dontcare;

        //* ADDIS R2,  R31, #15
        iaddrbusout[26] = 64'h0000000000000C98;
        //             opcode
        instrbusin[26]={ADDIS, 12'd15, 5'd31, 5'd2};
        daddrbusout[26] = 64'b0000000000000000000000000000000000000000000000000000000000001111;
        databusin[26] = datazs;
        databusout[26] = dontcare;

        //* BGE  #24
        iaddrbusout[27] = 64'h0000000000000C9C;
        //                   
        instrbusin[27] = {BGE, 19'h24, 5'd20};
        daddrbusout[27] = 64'b1001100110011001100110011001100110011001100110011001100110011000;
        databusin[27] = datazs;
        databusout[27] = dontcare;

        //* NOP  ENOR R31, R22, R31
        iaddrbusout[28] = 64'h0000000000000CA0;
        //                 
        instrbusin[28] = {ENOR, 5'd31, 6'd0, 5'd22, 5'd31};
        daddrbusout[28] = 64'hFFFFFFFFFFFFFFFE;
        databusin[28]  = datazs;
        databusout[28] = dontcare;

        //* NOP  SUB  R31, R20, R21
        iaddrbusout[29] = 64'h0000000000000D2C;
        //            opcode
        instrbusin[29]={SUB, 5'd21, 6'd0, 5'd20, 5'd31};
        daddrbusout[29] = 64'b0000000000000000000000000000000000000000000000000000000011111000;
        databusin[29] = datazs;
        databusout[29] = dontcare;

        //* SUBS R31, R24, R28
        iaddrbusout[30] = 64'h0000000000000D30;
        //                 
        instrbusin[30] = {SUBS, 5'd28, 6'd0, 5'd24, 5'd31};
        daddrbusout[30] = 64'b0101010101010101010101010101010101010101010101010101010101010110;
        databusin[30] = datazs;
        databusout[30] = dontcare;

        //* BLT  #16
        iaddrbusout[31] = 64'h0000000000000D34;
        //            opcode
        instrbusin[31]={BLT, 19'd16, 5'd0};
        daddrbusout[31] = dontcare;
        databusin[31] = datazs;
        databusout[31] = dontcare;

        //* NOP  ANDS  R31,  R20, R31
        iaddrbusout[32] = 64'h0000000000000D38;
        //            opcode 
        instrbusin[32]={ANDS, 5'd31, 6'd0, 5'd20, 5'd31};
        daddrbusout[32] = 64'd0;
        databusin[32] = datazs;
        databusout[32] = dontcare;

        //* NOP  ADDS  R31,  R20, R31
        iaddrbusout[33] = 64'h0000000000000D74;
        //            opcode 
        instrbusin[33]={ADDS, 5'd31, 6'd0, 5'd20, 5'd31};
        daddrbusout[33] = 64'h0000000000000000;
        databusin[33] = datazs;
        databusout[33] = dontcare;

        //* ORR  R31,  R20, R24
        iaddrbusout[34] = 64'h0000000000000D78;
        //                 
        instrbusin[34] = {ORR, 5'd24, 6'd0, 5'd20, 5'd31};
        daddrbusout[34] = 64'hCCCCCCCCCCCCCCCC;
        databusin[34] = datazs;
        databusout[34] = dontcare;

        //* ANDS R31,  R22, R31
        iaddrbusout[35] = 64'h0000000000000D7C;
        //            opcode
        instrbusin[35]={ANDS, 5'd31, 6'd0, 5'd22, 5'd31};
        daddrbusout[35] = 64'b0000000000000000000000000000000000000000000000000000000000010011;
        databusin[35] = datazs;
        databusout[35] = dontcare;

        //* BNE  #4
        iaddrbusout[36] = 64'h0000000000000D80;
        //            opcode 
        instrbusin[36]={BNE, 19'd4, 5'd0};
        daddrbusout[36] = 64'b0110011001100110011001100110011001100110011001100110011001100000;
        databusin[36] = datazs;
        databusout[36] = dontcare;

        //* NOP  ENORI R31,  R31, #0
        iaddrbusout[37] = 64'h0000000000000D84;
        //            opcode 
        instrbusin[37]={ENORI, 12'd0, 5'd31, 5'd31};
        daddrbusout[37] = 64'hFFFFFFFFFFFFFFFF;
        databusin[37] = datazs;
        databusout[37] = dontcare;

        //* SUBS  R29, R11, R10
        iaddrbusout[38] = 64'h0000000000000D88;
        //             opcode
        instrbusin[38]={SUBS, 5'd10, 6'd0, 5'd11, 5'd29};

        daddrbusout[38] = 64'hFFFFFFFFFFFFFFFD;
        databusin[38] = datazs;
        databusout[38] = dontcare;

        //* ORRI R20, R31, #h0F0
        iaddrbusout[39] = 64'h0000000000000D8C;
        //             opcode
        instrbusin[39]={ORRI, 12'h0F0, 5'd31, 5'd20};

        daddrbusout[39] = 64'h00000000000000F0;
        databusin[39] = datazs;
        databusout[39] = dontcare;

        //* LSR  R31, R20, 6'd10
        iaddrbusout[40] = 64'h0000000000000D90;
        //             opcode
        instrbusin[40]={LSR, 5'd01, 6'b001010, 5'd20, 5'd31};

        daddrbusout[40] = 64'h0000000000000000;
        databusin[40] = datazs;
        databusout[40] = dontcare;

        //* ANDIS R31, R20, 0x0FF
        iaddrbusout[41] = 64'h0000000000000D94;
        //             opcode
        instrbusin[41]={ANDIS, 12'h0FF, 5'd20, 5'd31};

        daddrbusout[41] = 64'h0000000000000000;
        databusin[41] = datazs;
        databusout[41] = dontcare;

        //* CBZ  R31, #d32
        iaddrbusout[42] = 64'h0000000000000D98;
        //             opcode
        instrbusin[42]={CBZ, 19'd32, 5'd31};

        daddrbusout[42] = dontcare;
        databusin[42] = datazs;
        databusout[42] = dontcare;

        //* MOVZ R31, (<< 1*16), #h1111
        iaddrbusout[43] = 64'h0000000000000D9C;
        //             opcode
        instrbusin[43]={MOVZ, 2'b01, 16'h1111, 5'd31};

        daddrbusout[43] = 64'b0000000000000000000000000000000000010001000100010000000000000000;
        databusin[43] = datazs;
        databusout[43] = dontcare;

        //* MOVZ R31, (<< 2*16), #h0001
        iaddrbusout[44] = 64'h0000000000000E18;
        //             opcode
        instrbusin[44]={MOVZ, 2'b10, 16'h0001, 5'd31};

        daddrbusout[44] = 64'b0000000000000000000000000000000100000000000000000000000000000000;
        databusin[44] = datazs;
        databusout[44] = dontcare;

        //* ADDS R31, R10, R9
        iaddrbusout[45] = 64'h0000000000000E1C;
        //            opcode
        instrbusin[45]={ADDS, 5'd9, 6'h00, 5'd10, 5'd31};
        daddrbusout[45] = 64'b0000000000000000000000000000000100000000000000000000000000000000;
        databusin[45] = datazs;
        databusout[45] = dontcare;

        //* ENORI R31,  R31, #0
        iaddrbusout[46] = 64'h0000000000000E20;
        //            opcode 
        instrbusin[46]={ENORI, 12'd0, 5'd31, 5'd31};
        daddrbusout[46] = 64'hFFFFFFFFFFFFFFFF;
        databusin[46] = datazs;
        databusout[46] = dontcare;

        //* CBNZ R20, #d16
        iaddrbusout[47] = 64'h0000000000000E24;
        //            opcode
        instrbusin[47]={CBNZ, 19'd16, 5'd20};
        daddrbusout[47] = dontcare;
        databusin[47] = datazs;
        databusout[47] = dontcare;

        //* NOP  EORI  R31,  R31, #FF
        iaddrbusout[48] = 64'h0000000000000E28;
        //            opcode 
        instrbusin[48]={EORI, 12'h0FF, 5'd31, 5'd31};
        daddrbusout[48] = 64'h00000000000000FF;
        databusin[48] = datazs;
        databusout[48] = dontcare;

        //* NOP  ANDI  R31,  R31, #7FF
        iaddrbusout[49] = 64'h0000000000000E64;
        //            opcode 
        instrbusin[49]={ANDI, 12'h7FF, 5'd31, 5'd31};
        daddrbusout[49] = 64'd0;
        databusin[49] = datazs;
        databusout[49] = dontcare;

        //* NOP  SUBIS R31,  R12, #43
        iaddrbusout[50] = 64'h0000000000000E68;
        //            opcode 
        instrbusin[50]={SUBIS, 12'd43, 5'd12, 5'd31};
        daddrbusout[50] = 64'd0;
        databusin[50] = datazs;
        databusout[50] = dontcare;

        //* NOP  ADDIS  R31,  R31, #11
        iaddrbusout[51] = 64'h0000000000000E6C;
        //            opcode 
        instrbusin[51]={ADDIS, 12'd11, 5'd31, 5'd31};
        daddrbusout[51] = 64'd11;
        databusin[51] = datazs;
        databusout[51] = dontcare;

        //* NOP  ANDIS  R31,  R29, #7FF
        iaddrbusout[52] = 64'h0000000000000E70;
        //            opcode 
        instrbusin[52]={ANDIS, 12'h7FF, 5'd31, 5'd31};
        daddrbusout[52] = 64'd0;
        databusin[52] = datazs;
        databusout[52] = dontcare;

        // (no. instructions) + (no. loads) + 2*(no. stores) = 
        ntests = 59;

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
