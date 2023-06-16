`timescale 1ns / 1ps


//// *** CPU5 ARM *** ////
// Structural representation of a 5-stage 32-bit pipelined CPU, memory enabled 
module cpu5arm(ibus, clk, daddrbus, databus, reset, iaddrbus);

    //// INPUTS AND OUTPUTS ////
    // Instruction bus and clock, reset for the PC DFF
    input [31:0] ibus;
    input clk, reset;
    output [63:0] daddrbus, iaddrbus;
    inout [63:0] databus;
   
    //// ***FLAGS*** ////
    // Cin, Imm, S wires and intermediate wires
    wire ImmOP, CinOP, Imm, Cin;
    wire [2:0] SOP, S;
    
    // SW flags and intermediate SW flags 
    wire SW, SWOP, SWIDEXout, SWEXMEMout;
    
    // Load Word Flags
    wire LW, LWOP, LWIDEXout, LWEXMEMout;
    
    // BNE, BEQ flags 
    wire BEQ, BNE;
   
   
   //// ***IFID OUTPUT*** ////
   // Output of DFF
   wire [31:0] IFIDout;
    
    //// ***DECODER + FIRST MUX OUTPUTS*** ////
    // Store the output of the decoders 
    wire [31:0] Aselect, Bselect, rmOut;
    
    // Store the sign extended IType instruction 
    wire [63:0] signextOUT;
    
    
    
    //// ***REGFILE OUTPUTS*** ////
    // Store the outputs of the regfile 
    wire [63:0] regAbusOUT, regBbusOUT;
    
    //// ****COMPARATOR OUTPUTS**** ////
    // Intermediary Dselect wire
    wire [31:0] DselectComparatorResult;
    
    // Store the comparator output 
    wire regComparatorResult;
    
    
    //// ***IDEX OUTPUTS*** ////
    // ALU inputs
    wire [63:0] abus, bbus;
    
    // Store the wire between IDEX and bbus mux
    wire [63:0] IDEXBbusOUT;
    
    // Intermediary Dselect wires
    wire [31:0] IDEXDselectOUT;
    
    // Store the output of the IDEX sign ext line 
    wire [63:0] IDEXSignExtOUT;
    
    
    //// ***ALU OUTPUT*** ////
    // Result of the ALU
    wire [63:0] ALUout;
    
    // Store the needed SLT SLE outputs from the ALU 
    // Flags for ARM instructions     
    wire C, V, Z, N;
    
    //// ***EXMEM OUTPUTS*** ////
    // Store the EXMEM line going into the databus tristate 
    wire [63:0] EXMEMDatabus;
   
    // Intermediary Dselect wires
    wire [31:0] EXMEMDselectOUT;
    
    
   //// ***MEMWB + FINAL MUX OUTPUTS*** ////
    // Store the MEMWB top output 
    wire [63:0] memAddrOut;
    
    // Store the MEMWB bottom output 
    wire [63:0] memBusOut;
    
    // Final Dselect wire
    wire [31:0] DselectTemp, Dselect;
    
    // Final dbus wire
    wire [63:0] dbus;
    

    //// ***PC + ADDER WIRES*** ////
    // Store the mux output for the PC stage
    wire [63:0] PCadderMuxOUT;
    
    // Store the result of the adders 
    wire [63:0] signextAdderOUT, pcplus4AdderOUT;
    
    // Store the result of the new IFID output 
    wire [63:0] IFIDaddOUT;
 
    // Intermediates for 64'b4 and the SLL by 2 for the adders 
    wire [63:0] imm4, signExtSLL;
    
    // Flag for the opcode decoder 
    // 3 bit flag, to choose from any of 6 types of instructions 
    // 000 -> R-format, 001 -> I-format, 010 -> D-format, 011 -> IM-format, 100 -> B-format, 
    // 101 -> CB-format
    // 111 -> NOP or default 
    // xxx -> :3 
    wire [2:0] instrFlag;
    
    // Intermediate wire needed after setting the instruction bus flag 
    wire [31:0] IFSout;
    
    // Flags for S-suffixed instructions and CBNZ or CBZ
    wire SInstruction, CBNZCB, SFlag;
    
    // Flags for BLT and BGE 
    wire BLT, BGE;
    
    // Intermediate wire to hold the shift value for LSL and LSR operations
    wire [5:0] shamtIntoALU;
    
    // Flag for MOVZ 
    wire MOVZOP, MOVZ; 
    
    // Intermediate wire 
    wire [5:0] movmuxOutput;
    
    wire [31:0] rdrtOUT;
     
    //// Instantiate the PC adders 
    assign signExtSLL = signextOUT << 2;
    add64 signextAdder(
        .a(signExtSLL),
        .b(IFIDaddOUT),
        .sum(signextAdderOUT)
    );
    
    assign imm4 = 64'h0000000000000004;
    add64 pcplus4Adder(
        .a(imm4),
        .b(iaddrbus),
        .sum(pcplus4AdderOUT)
    );
    
    //// Instantiate the PC resettable DFF 
    PCDFF PC(
        .PCinput(PCadderMuxOUT),
        .PCoutput(iaddrbus),
        .reset(reset),
        .clk(clk)
    );
    
    //// Instantiate the mux for the adder outputs 
    mux2 PCadderMux(
        .in0(pcplus4AdderOUT),
        .in1(signextAdderOUT),
        .sel(regComparatorResult),
        .out(PCadderMuxOUT)
    );
    
    
    //// Instantiate the IF/ID DFF ////
    IFIDDFF IFID (
        .D(ibus),
        .Q(IFIDout),
        .clk(clk), 
        .IFIDaddlineIN(pcplus4AdderOUT),
        .IFIDaddlineOUT(IFIDaddOUT)
    );
    
    //// Set the InstrFlag based on the instruction bus input 
    //// (determine which type of instruction we have so the opcode decoder can work) 
    InstrFlagSetter SetFlag(
        .instructionBusIn(IFIDout),
        .instructionBusOut(IFSout),
        .instructionFlagOut(instrFlag)
    );
    
    
    //// Instantiate the register result comparator module
    comparator64 registerCheck(
        .a(abus),
        .b(64'h0000000000000000), // TODO: is this ok to do? branching is different in ARM so it should be 
        .result(regComparatorResult),
        .DselectIn(rdrtOUT),
        .DselectOut(DselectComparatorResult),
        .BEQFlag(BEQ),
        .BNEFlag(BNE), 
        .CBNZCBFlag(CBNZCB), 
        .VFlag(V),
        .CFlag(C),
        .NFlag(N),
        .ZFlag(Z),
        .BGEFlag(BGE),
        .BLTFlag(BLT)
    );
    
    //// Instantiate the decoders //// 
    //// Assign rs and Aselect ////
    decoder5bitsize32 rn (
        .r(IFSout[9:5]),
        .sel(Aselect)
    );
    
    //// Assign rt ////
    decoder5bitsize32 rm (
        .r(IFSout[20:16]),
        .sel(rmOut)
    );
    
    //// Assign rd ////
    decoder5bitsize32 rdrt (
        .r(IFSout[4:0]), 
        .sel(rdrtOUT)
    );
    
    mux2 BselectMux(
        .in0(rmOut),
        .in1(rdrtOUT),
        .sel(SWOP),
        .out(Bselect)
    );
    
    //// Read opcode to determine ALU operation ////
    opcodedecoder op (
        .opcode(IFSout[31:21]), 
        .ImmOP(ImmOP),
        .SOP(SOP),
        .CinOP(CinOP),
        .SWFlag(SWOP),
        .LWFlag(LWOP), 
        .BEQFlag(BEQ),
        .BNEFlag(BNE), 
        .CBNZCBFlag(CBNZCB), 
        .isSInstr(SInstruction),
        .BGEFlag(BGE),
        .BLTFlag(BLT),
        .MOVZFlag(MOVZOP),
        .InstrFlag(instrFlag)
    );
    
    //// Sign extend for non R-type instructions //// 
    signextender sd (
        .in(IFSout),
        .instrType(instrFlag),
        .se(signextOUT)
    );
    
    // Mux to handle MOVZ 
    mux6bit MOVZmux (
        .in0(IFSout[15:10]),
        .in1({4'b0, IFSout[22:21]}),
        .sel(MOVZOP),
        .out(movmuxOutput)
    );
        
    //// Instantiate and use the 32x64 bit regfile     
    assign regAbusOUT = Aselect[31] ? 64'b0 : 64'bz;
    assign regBbusOUT = Bselect[31] ? 64'b0 : 64'bz;
    
    regfile aselbselregister[30:0] (
        .clk(clk),
        .Dselect(Dselect[30:0]),
        .dbus(dbus), 
        .Aselect(Aselect[30:0]), 
        .Bselect(Bselect[30:0]), 
        .abus(regAbusOUT),
        .bbus(regBbusOUT)
    );
    
    
    //// Instantiate the ID/EX DFF //// 
    //// Support the ID/EX handling Imm, S, Cin 
    IDEXDFF IDEX(
        .SIN(SOP),
        .ImmIN(ImmOP),
        .CinIN(CinOP),
        .S(S),
        .Imm(Imm),
        .Cin(Cin),
        .clk(clk),
        .abusIN(regAbusOUT),
        .bbusIN(regBbusOUT),
        .SignExtIN(signextOUT),
        .RTRDMuxIN(DselectComparatorResult),
        .abusOUT(abus),
        .bbusOUT(IDEXBbusOUT),
        .SignExtOUT(IDEXSignExtOUT),
        .RTRDMuxOUT(IDEXDselectOUT), 
        .SWInput(SWOP),
        .SWOutput(SWIDEXout),
        .LWInput(LWOP),
        .LWOutput(LWIDEXout),
        .SInstrIN(SInstruction),
        .SInstrOUT(SFlag),
        .ShiftIN(movmuxOutput),
        .ShiftOUT(shamtIntoALU),
        .MOVZInput(MOVZOP),
        .MOVZOutput(MOVZ)
    );
    
    //// Instantiate the mux between IDEX and EXMEM which switches for I Type instructions 
    mux2 SignExtMux(
        .in0(IDEXBbusOUT),
        .in1(IDEXSignExtOUT),
        .sel(Imm),
        .out(bbus)
    );
    
    //// Instantiate the 32-bit ALU which stands between IDEX and EXMEM 
    alu64 aluUnit(  
        .d(ALUout),
        .Cout(C),
        .V(V),
        .a(abus),
        .b(bbus),
        .Cin(Cin), 
        .S(S), 
        .Z(Z),
        .N(N),
        .SInstructionIn(SFlag),
        .shamt(shamtIntoALU),
        .MOVZFlag(MOVZ)
    );

    //// Instantiate the EX/MEM DFF //// 
    EXMEMDFF EXMEM (
        .AluInput(ALUout),
        .IDEXInput(IDEXDselectOUT),
        .BoperandIN(IDEXBbusOUT),
        .DselectOUT(EXMEMDselectOUT), 
        .Daddrbus(daddrbus),
        .BoperandOUT(EXMEMDatabus),
        .SWInput(SWIDEXout),
        .SWOutput(SWEXMEMout),
        .clk(clk),
        .LWInput(LWIDEXout),
        .LWOutput(LWEXMEMout)
    );
    
    
    //// Instantiate databus' tristate ////
    tristatebuffer databusTristate (
        .in0(EXMEMDatabus),
        .ctrl(SWEXMEMout),
        .out0(databus)
    );
    
    //// Instantiate the MEM/WB DFF ////
    MEMWBDFF MEMWB (
        .clk(clk),
        .MEMWBaddrbusIN(daddrbus),
        .MEMWBaddrbusOUT(memAddrOut),
        .MEMWBdatabusIN(databus),
        .MEMWBdatabusOUT(memBusOut),
        .MEMWBDselectOUT(DselectTemp),
        .MEMWBDselectIN(EXMEMDselectOUT),
        .SWInput(SWEXMEMout),
        .SWOutput(SW),
        .LWInput(LWEXMEMout),
        .LWOutput(LW)
    );

    // Disable WB for SW instructions  
    assign Dselect = SW ? 32'b10000000000000000000000000000000 : DselectTemp;
    
    //// Instantiate the final mux //// 
    mux2 MEMWBMux(
        .in0(memAddrOut),
        .in1(memBusOut),
        .sel(LW), 
        .out(dbus)
    );     
endmodule


//// *** SUB MODULES *** ////

// Given a 5-bit RS, RT, or RD, creates the correct decoded 64-bit value 
module decoder5bit(r, sel);
    input [4:0] r;
    output [63:0] sel;
    
    assign sel = 64'd1 << r;
endmodule 

module decoder5bitsize32(r,sel);
    input [4:0] r;
    output [31:0] sel;
    
    assign sel = 32'd1 << r;
endmodule 

// Behavioral representation of a tristate buffer, used so databus can play with inputs correctly and 
// avoid an "assign" statement 
module tristatebuffer(in0, ctrl, out0);
    input [63:0] in0;
    input ctrl;
    output [63:0] out0;
    
    assign out0 = ctrl ?  in0 :  64'bz;
endmodule

// Given a variable-length ARM opcode of at most 11 bits, set the correct flags for the pipelined CPU. 
module opcodedecoder(opcode, ImmOP, SOP, CinOP, SWFlag, LWFlag, InstrFlag, isSInstr, CBNZCBFlag, BEQFlag, BNEFlag, BGEFlag, BLTFlag, MOVZFlag);
    input [10:0] opcode;
    input [2:0] InstrFlag;
    output ImmOP, CinOP, SWFlag, LWFlag, isSInstr, CBNZCBFlag, BEQFlag, BNEFlag, BGEFlag, BLTFlag, MOVZFlag;
    output [2:0] SOP;
    
    // Internal wires to store R-Type results
    reg ImmOP, CinOP, SWFlag, LWFlag, isSInstr, CBNZCBFlag, BEQFlag, BNEFlag, BGEFlag, BLTFlag, MOVZFlag;
    reg [2:0] SOP;
    
    // Decide which instruction type we have and react accordingly 
    always @ (opcode, InstrFlag) begin  
        case (InstrFlag)
            3'b000: begin
                        case (opcode)
                            11'b00101000000: begin // ADD 
                                                SOP = 3'b010; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end 
                            11'b00101000001: begin // ADDS
                                                SOP = 3'b010; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b1;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101000010: begin // AND
                                                SOP = 3'b110; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101000011: begin // ANDS
                                                SOP = 3'b110; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b1;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101000100: begin // EOR
                                                SOP = 3'b000; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101000101: begin // ENOR
                                                SOP = 3'b001; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                             end
                            11'b00101000110: begin // LSL
                                                SOP = 3'b101; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end 
                            11'b00101000111: begin // LSR
                                                SOP = 3'b111; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101001000: begin // ORR
                                                SOP = 3'b100; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b0;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end 
                            11'b00101001001: begin // SUB
                                                SOP = 3'b011; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b1;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b0;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                            11'b00101001010: begin // SUBS
                                                SOP = 3'b011; 
                                                ImmOP = 1'b0; 
                                                CinOP = 1'b1;  
                                                SWFlag = 1'b0;
                                                LWFlag = 1'b0;
                                                isSInstr = 1'b1;
                                                CBNZCBFlag = 1'b0; 
                                                BEQFlag = 1'b0;
                                                BNEFlag = 1'b0;
                                                BLTFlag = 1'b0; 
                                                BGEFlag = 1'b0;
                                                MOVZFlag = 1'b0;
                                             end
                             default: begin // Erm 
                                         SOP = 3'bxxx; 
                                         ImmOP = 1'bx; 
                                         CinOP = 1'bx;  
                                         SWFlag = 1'b0;
                                         LWFlag = 1'b0;
                                         isSInstr = 1'b0;
                                         CBNZCBFlag = 1'b0; 
                                         BEQFlag = 1'b0;
                                         BNEFlag = 1'b0;
                                         BLTFlag = 1'b0; 
                                         BGEFlag = 1'b0;
                                         MOVZFlag = 1'b0;
                                      end 
                        endcase 
                    end
            3'b001: begin 
                        case (opcode[10:1])
                                10'b1000100000: begin // ADDI
                                                    SOP = 3'b010; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end 
                                10'b1000100001: begin // ADDIS
                                                    SOP = 3'b010; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b1;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100010: begin // ANDI
                                                    SOP = 3'b110; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100011: begin // ANDIS
                                                    SOP = 3'b110; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b1;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100100: begin // EORI
                                                    SOP = 3'b000; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100101: begin // ENORI
                                                    SOP = 3'b001; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100110: begin // ORRI
                                                    SOP = 3'b100; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000100111: begin // SUBI
                                                    SOP = 3'b011; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b1;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                10'b1000101000: begin // SUBIS
                                                    SOP = 3'b011; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b1;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b1;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                default: begin // Erm 
                                            SOP = 3'bxxx; 
                                            ImmOP = 1'bx; 
                                            CinOP = 1'bx;  
                                            SWFlag = 1'b0;
                                            LWFlag = 1'b0;
                                            isSInstr = 1'b0;
                                            CBNZCBFlag = 1'b0; 
                                            BEQFlag = 1'b0;
                                            BNEFlag = 1'b0;
                                            BLTFlag = 1'b0; 
                                            BGEFlag = 1'b0;
                                            MOVZFlag = 1'b0;
                                        end 
                        endcase
                    end
            3'b010: begin 
                        case (opcode)
                                11'b11010000000: begin // LDUR
                                                    SOP = 3'b010; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b1;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end 
                                11'b11010000001: begin // STUR
                                                    SOP = 3'b010; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b1;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                default: begin // Erm 
                                            SOP = 3'bxxx; 
                                            ImmOP = 1'bx; 
                                            CinOP = 1'bx;  
                                            SWFlag = 1'b0;
                                            LWFlag = 1'b0;
                                            isSInstr = 1'b0;
                                            CBNZCBFlag = 1'b0; 
                                            BEQFlag = 1'b0;
                                            BNEFlag = 1'b0;
                                            BLTFlag = 1'b0; 
                                            BGEFlag = 1'b0;
                                            MOVZFlag = 1'b0;
                                        end 
                        endcase
                    end 
            3'b011: begin 
                        case (opcode[10:2])
                                9'b110010101: begin // MOVZ
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b1; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b1;
                                                end
                                default: begin // Erm 
                                            SOP = 3'bxxx; 
                                            ImmOP = 1'bx; 
                                            CinOP = 1'bx;  
                                            SWFlag = 1'b0;
                                            LWFlag = 1'b0;
                                            isSInstr = 1'b0;
                                            CBNZCBFlag = 1'b0; 
                                            BEQFlag = 1'b0;
                                            BNEFlag = 1'b0;
                                            BLTFlag = 1'b0; 
                                            BGEFlag = 1'b0;
                                            MOVZFlag = 1'b0;
                                        end 
                         endcase
                    end
            3'b100: begin 
                    case (opcode[10:5])
                                6'b000011: begin // B
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b1;
                                                    BNEFlag = 1'b1;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                default: begin // Erm 
                                            SOP = 3'bxxx; 
                                            ImmOP = 1'bx; 
                                            CinOP = 1'bx;  
                                            SWFlag = 1'b0;
                                            LWFlag = 1'b0;
                                            isSInstr = 1'b0;
                                            CBNZCBFlag = 1'b0; 
                                            BEQFlag = 1'b0;
                                            BNEFlag = 1'b0;
                                            BLTFlag = 1'b0; 
                                            BGEFlag = 1'b0;
                                            MOVZFlag = 1'b0;
                                        end 
                         endcase
                    end
            3'b101: begin 
                    case (opcode[10:3])
                                8'b11110100: begin // CBZ
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b1; 
                                                    BEQFlag = 1'b1;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                8'b11110101: begin // CBNZ
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b1; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b1;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                8'b01110100: begin // BEQ
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b1;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                8'b01110101: begin // BNE
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b1;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end 
                                8'b01110110: begin // BLT
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b1; 
                                                    BGEFlag = 1'b0;
                                                    MOVZFlag = 1'b0;
                                                end
                                8'b01110111: begin // BGE
                                                    SOP = 3'b101; 
                                                    ImmOP = 1'b0; 
                                                    CinOP = 1'b0;  
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    isSInstr = 1'b0;
                                                    CBNZCBFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    BLTFlag = 1'b0; 
                                                    BGEFlag = 1'b1;
                                                    MOVZFlag = 1'b0;
                                                end
                                default: begin // Erm 
                                            SOP = 3'bxxx; 
                                            ImmOP = 1'bx; 
                                            CinOP = 1'bx;  
                                            SWFlag = 1'b0;
                                            LWFlag = 1'b0;
                                            isSInstr = 1'b0;
                                            CBNZCBFlag = 1'b0; 
                                            BEQFlag = 1'b0;
                                            BNEFlag = 1'b0;
                                            BLTFlag = 1'b0; 
                                            BGEFlag = 1'b0;
                                            MOVZFlag = 1'b0;
                                        end 
                         endcase
                    end 
            3'b111: begin
                        SOP = 3'bxxx; 
                        ImmOP = 1'bx; 
                        CinOP = 1'bx;  
                        SWFlag = 1'b0;
                        LWFlag = 1'b0;
                        isSInstr = 1'b0;
                        BLTFlag = 1'b0; 
                        BGEFlag = 1'b0;
                        MOVZFlag = 1'b0;
                    end
        endcase
    end
endmodule 


// Sign extend the given value to 64 bits 
module signextender(in, instrType, se);
    input [31:0] in;
    input [2:0] instrType;
    output [63:0] se;
    
    reg [63:0] se;
    // is the always @ condition correct?
    always @ (in) begin  
        case (instrType)
            // these extension parameters were taken directly from the LEGv8 reference sheet
            3'b001: assign se = {52'b0,in[21:10]};          // I-type instruction
            3'b010: assign se = {{55{in[20]}}, in[20:12]};  // D-type instruction
            3'b011: assign se = {48'b0, in[20:5]};          // IM-type instruction
            3'b100: assign se = {{38{in[25]}}, in[25:0]};   // B-type instruction
            3'b101: assign se = {{45{in[23]}}, in[23:5]};   // CB-type add64
            default: assign se = 64'bz;                     // R-type and NOP don't rely on on any signextender
        endcase
    end
    
    //assign se = {{16{in[15]}}, in};
endmodule 

// Behavioral representation of a 2-to-1 multiplexor (64-bit).
module mux2 (in0, in1, sel, out);
    input [63:0] in0, in1;
    input sel;
    output [63:0] out; 
    
    assign out = ((sel === 1'bx) ? 0 : sel) ? in1 : in0;
endmodule

// Behavioral representation of a 2-to-1 multiplexor (6-bit).
module mux6bit (in0, in1, sel, out);
    input [5:0] in0, in1;
    input sel;
    output [5:0] out; 
    
    assign out = ((sel === 1'bx) ? 0 : sel) ? in1 : in0;
endmodule

// Behavioral representation of a D Flip Flop. 
// ACCREDITION: This code was provided by the lecture notes.
module dff (clk, D, Q);
    input D, clk;
    output Q; 
    reg Q; 
    
    always @ (posedge clk) begin 
        Q = D;
        end 
endmodule 

//// *** PC DFF *** ////
// Behavioral representaiton of a positve-edge triggered, resettable D-Flip-Flop --> Handles the PC DFF
module PCDFF(clk, reset, PCinput, PCoutput);
    input clk, reset;
    input [63:0] PCinput;
    
    output [63:0] PCoutput;
    reg [63:0] PCoutput;
    
    initial begin
        PCoutput = 64'b0;
    end
    
    always @(posedge clk, posedge reset)
        if (reset) PCoutput <= 64'b0;
        else       PCoutput <= PCinput;
endmodule

//// *** IFID DFF *** ////
module IFIDDFF (clk, D, Q, IFIDaddlineIN, IFIDaddlineOUT);
    input clk; 
    input [63:0] IFIDaddlineIN;
    input [31:0] D;
    output [63:0] IFIDaddlineOUT;
    output [31:0] Q;
    reg [63:0] IFIDaddlineOUT;
    reg [31:0] Q;
    
    always @ (posedge clk) begin 
        Q = D;
        IFIDaddlineOUT = IFIDaddlineIN;
        end 
endmodule

// Module which behaviorally sets the instruction bus flag 
// This module decides which type of ARM instruction we have 
module InstrFlagSetter(instructionBusIn, instructionBusOut, instructionFlagOut);
    input [31:0] instructionBusIn;
    output [31:0] instructionBusOut;
    output [2:0] instructionFlagOut;
    
    reg [2:0] instructionFlagOut;
    reg [31:0] instructionBusOut;
    
    // Based on the instruction bus, set the flag. 
    always @ (instructionBusIn) begin
        case (instructionBusIn[31:28]) 
            4'b0010: instructionFlagOut = 3'b000; // R-format 
            4'b1000: instructionFlagOut = 3'b001; // I-format
            4'b1101: instructionFlagOut = 3'b010; // D-format
            4'b1100: instructionFlagOut = 3'b011; // IM-format
            4'b0000: instructionFlagOut = 3'b100; // B-format
            4'b1111: instructionFlagOut = 3'b101; // CB-format (CBZ, CBNZ) 
            4'b0111: instructionFlagOut = 3'b101; // CB-format (BEQ, BNE, BLT, BGE)
            default: instructionFlagOut = 3'b111; // NOP or error 
        endcase 
        instructionBusOut = instructionBusIn;
    end 
endmodule 

//// *** IDEX DFF *** ////
// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> Handles the ID/EX DFF
module IDEXDFF (Imm, S, Cin, ImmIN, SIN, CinIN, clk, abusIN, bbusIN, SignExtIN, abusOUT, bbusOUT, RTRDMuxIN, RTRDMuxOUT, SignExtOUT, SWInput, SWOutput, LWInput, LWOutput, SInstrIN, SInstrOUT, ShiftIN, ShiftOUT, MOVZInput, MOVZOutput);
    input [2:0] SIN;
    input [63:0] abusIN, bbusIN, SignExtIN; 
    input [31:0] RTRDMuxIN;
    input [5:0] ShiftIN;
    input CinIN, ImmIN, clk, SWInput, LWInput, SInstrIN, MOVZInput;
    
    output [2:0] S;
    output [63:0] abusOUT, bbusOUT, SignExtOUT; 
    output [31:0] RTRDMuxOUT;
    output Cin, Imm, SWOutput, LWOutput, SInstrOUT, MOVZOutput;
    output [5:0] ShiftOUT;
    
    reg [2:0] S;
    reg [63:0] abusOUT, bbusOUT, SignExtOUT;
    reg [31:0] RTRDMuxOUT;
    reg Cin, Imm, SWOutput, LWOutput, SInstrOUT, MOVZOutput;
    reg [5:0] ShiftOUT;
    
    always @ (posedge clk) begin 
        S = SIN;
        Cin = CinIN; 
        Imm = ImmIN;
        abusOUT = abusIN; 
        bbusOUT = bbusIN; 
        RTRDMuxOUT = RTRDMuxIN; 
        SignExtOUT = SignExtIN;
        SWOutput = SWInput;
        LWOutput = LWInput;
        SInstrOUT = SInstrIN;
        ShiftOUT = ShiftIN;
        MOVZOutput = MOVZInput;
        end
endmodule

//// *** EXMEM DFF *** ////
// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> For 32-bit inputs
module EXMEMDFF (clk, AluInput, IDEXInput, Daddrbus, DselectOUT, BoperandIN, BoperandOUT, SWInput, SWOutput, LWInput, LWOutput);
    input [63:0] AluInput, BoperandIN;
    input [31:0] IDEXInput;
    input clk, SWInput, LWInput;
    output [63:0] Daddrbus, BoperandOUT; 
    output [31:0] DselectOUT;
    output SWOutput, LWOutput;
    reg [63:0] Daddrbus, BoperandOUT; 
    reg [31:0] DselectOUT;
    reg SWOutput, LWOutput;
    
    always @ (posedge clk) begin 
        DselectOUT = IDEXInput;
        Daddrbus = AluInput;
        BoperandOUT = BoperandIN; 
        SWOutput = SWInput;
        LWOutput = LWInput;
        end 
endmodule

//// *** MEMWBDFF *** ////
// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> Handles the MEM/WB DFF
module MEMWBDFF (clk, MEMWBaddrbusIN, MEMWBaddrbusOUT, MEMWBdatabusIN, MEMWBdatabusOUT, MEMWBDselectOUT, MEMWBDselectIN, SWInput, SWOutput, LWInput, LWOutput);
    input [63:0] MEMWBaddrbusIN, MEMWBdatabusIN;
    input [31:0] MEMWBDselectIN;
    input clk, SWInput, LWInput;
    output [63:0] MEMWBaddrbusOUT, MEMWBdatabusOUT;
    output [31:0] MEMWBDselectOUT;
    output SWOutput, LWOutput;
    reg [63:0] MEMWBaddrbusOUT, MEMWBdatabusOUT;
    reg [31:0] MEMWBDselectOUT;
    reg SWOutput, LWOutput;
    
    always @ (posedge clk) begin 
        MEMWBaddrbusOUT = MEMWBaddrbusIN;
        MEMWBdatabusOUT = MEMWBdatabusIN;
        MEMWBDselectOUT = MEMWBDselectIN;
        SWOutput = SWInput;
        LWOutput = LWInput; 
        end 
endmodule

//// *** 64-BIT ADDER *** ////
module add64(a, b, sum);
    input [63:0] a, b;
    output [63:0] sum;
    
    assign sum = a + b;
endmodule

// To do CBZ and CBNZ we can change the B input to be all 0 
// This effectively reuses the BEQ BNE code since CBZ and CBNZ are those operands on 0 
//// *** BRANCHING COMPARATOR MODULE *** ////
module comparator64(a, b, result, DselectIn, DselectOut, BNEFlag, BEQFlag, VFlag, CFlag, NFlag, ZFlag, CBNZCBFlag, BLTFlag, BGEFlag);
    input [63:0] a, b;
    input [31:0] DselectIn;
    input BNEFlag, BEQFlag, VFlag, CFlag, NFlag, ZFlag, CBNZCBFlag, BLTFlag, BGEFlag;
    output [31:0] DselectOut;
    output result;
    
    reg result;
    reg [31:0] DselectOut;
    
    //assign b = CBNZCBFlag ? 64'h0000000000000000 : b;
    
    always @ (BNEFlag, BEQFlag, CBNZCBFlag, BLTFlag, BGEFlag) begin
    if (BEQFlag == 1'b1 && ZFlag === 1) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (BNEFlag == 1'b1 && ZFlag === 0) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (BGEFlag == 1'b1 && NFlag === VFlag) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (BLTFlag == 1'b1 && NFlag !== VFlag) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (CBNZCBFlag == 1'b1 && BEQFlag == 1'b1 && a === b) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (CBNZCBFlag == 1'b1 && BNEFlag == 1'b1 && a !== b) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else if (BNEFlag == 1'b1 && BEQFlag == 1'b1) begin 
            assign result = 1'b1;
            assign DselectOut = 32'b10000000000000000000000000000000;
        end
    else 
        begin 
            assign result = 1'b0;
            assign DselectOut = DselectIn;      // do we need to assign deselect to 31 if a flag is high but condition is false?
                                                // assign DselectOut = (BEQFlag == 1'b1) || (BNEFlag == 1'b1) || (BLTFlag == 1'b1) || (BGE == 1'b1) || (CBNZCBFlag == 1'b'1) s? 32'b10000000000000000000000000000000 : DselectIn;
        end
        
    //assign DselectOut = ((BEQFlag == 1'b1 && a === b) || (BNEFlag == 1'b1 && a !== b)) ? 32'b10000000000000000000000000000000 : DselectIn;
    end
endmodule



//// *** REGFILE *** ////
// Behavioral representation of a falling-edge sensitive flip-flop.
module regfile(clk, Dselect, Aselect, Bselect, dbus, abus, bbus);
    input [63:0] dbus;
    input Dselect, Aselect, Bselect;
    input clk;
    output [63:0] abus, bbus;
   
    reg [63:0] Q;
    
    wire newclk;
    
    assign newclk = clk & Dselect;
    always @(negedge newclk) begin
            if (Dselect == 1'b1) Q = dbus;
        end
   assign abus = Aselect ? Q : 64'bz; 
   assign bbus = Bselect ? Q : 64'bz;
endmodule



//// *** ALU64 *** //// 
// Module representing a 64-bit ALU. 
module alu64 (d, Cout, V, a, b, Cin, S, Z, N, SInstructionIn, shamt, MOVZFlag);
   output[63:0] d;
   output Cout, V, Z, N;
   input [63:0] a, b;
   input Cin, SInstructionIn, MOVZFlag;
   input [2:0] S;
   input [5:0] shamt;
   
   wire [63:0] c, g, p;
   wire gout, pout;
   
   // Instantiates 32 ALU cells.
   alu_cell alucell[63:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S),
      .shamt(shamt),
      .MOVZ(MOVZFlag)
   );
   
   assign Z = SInstructionIn ? (d == 64'h0000000000000000) : 1'b0;
   assign N = SInstructionIn ? (d[63] == 1'b1) : 1'b0;
   
   // Instantiates a 6-level LAC.
   lac6 laclevel6(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );

   // Handles any overflow which occured at the end of the carry chain.
   overflow over(
      .Cout(Cout),
      .V(V),
      .Cin(Cin),
      .gout(gout),
      .pout(pout),
      .c(c), 
      .SFlag(SInstructionIn)
   );
endmodule

// Module representing a single-bit cell of a 32-bit ALU
module alu_cell (d, g, p, a, b, c, S, shamt, MOVZ);
    output d, g, p;
    input a, b, c, MOVZ;
    input [2:0] S;
    input [5:0] shamt;
    
    // Use reg instead of wire since wires cannot be procedurally assigned in that control block (always)
    wire cint, bint;
    reg d;
    
    assign bint = S[0] ^ b;
    assign g = a & bint; 
    assign p = a ^ bint;
    assign cint = S[1] & c;

    always @ (a, b, c, d, S, bint, cint, p, MOVZ, shamt) begin
        case (S)
            3'b100 : d = a | b;
            3'b101 : d = MOVZ ? (b << (shamt * 4'b1000)) : (a << shamt); // terenary operator for MOVZ... have MOVZ flag??
            3'b110 : d = a & b;
            3'b111 : d = a >> shamt; 
            default : d = (p ^ cint);
        endcase
    end
endmodule

// Handles the overflow from the ALU
// ACCREDITION: Parts of this module were given in lecture notes.
module overflow (Cout, V, Cin, gout, pout, c, SFlag);
    output Cout, V;
    input [63:0] c;
    input Cin, gout, pout, SFlag;
    
    assign Cout = SFlag ? (gout | (pout & Cin)) : 1'b0;
    assign V = SFlag ? (Cout ^ c[63]) : 1'b0;
endmodule

// ACCREDITION: This module's code comes from the lecture notes.
module lac(c, gout, pout, Cin, g, p);
    output [1:0] c;
    output gout, pout; 
    input Cin; 
    input [1:0] g, p;
    
    assign c[0] = Cin;
    assign c[1] = g[0] | (p[0] & Cin);
    assign gout = g[1] | (p[1] & g[0]);
    assign pout = p[1] & p[0];
endmodule

// ACCREDITION: This module's code comes from the lecture notes.
module lac2(c, gout, pout, Cin, g, p);
    output [3:0] c;
    output gout, pout;
    input Cin; 
    input [3:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac leaf0(
        .c(c[1:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[1:0]),
        .p(p[1:0])
    );
    
    lac leaf1(
        .c(c[3:2]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[3:2]),
        .p(p[3:2])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule   

// ACCREDITION: This module's code comes from the lecture notes.
module lac3(c, gout, pout, Cin, g, p);
    output [7:0] c;
    output gout, pout;
    input Cin; 
    input [7:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac2 leaf0(
        .c(c[3:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[3:0]),
        .p(p[3:0])
    );
    
    lac2 leaf1(
        .c(c[7:4]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[7:4]),
        .p(p[7:4])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac4(c, gout, pout, Cin, g, p);
    output [15:0] c;
    output gout, pout;
    input Cin; 
    input [15:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac3 leaf0(
        .c(c[7:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[7:0]),
        .p(p[7:0])
    );
    
    lac3 leaf1(
        .c(c[15:8]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[15:8]),
        .p(p[15:8])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac5(c, gout, pout, Cin, g, p);
    output [31:0] c;
    output gout, pout;
    input Cin; 
    input [31:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac4 leaf0(
        .c(c[15:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[15:0]),
        .p(p[15:0])
    );
    
    lac4 leaf1(
        .c(c[31:16]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[31:16]),
        .p(p[31:16])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac6(c, gout, pout, Cin, g, p);
    output [63:0] c;
    output gout, pout;
    input Cin; 
    input [63:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac5 leaf0(
        .c(c[31:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[31:0]),
        .p(p[31:0])
    );
    
    lac5 leaf1(
        .c(c[63:32]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[63:32]),
        .p(p[63:32])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule
