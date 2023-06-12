`timescale 1ns / 1ps


//// *** CPU5 ARM *** ////
// Structural representation of a 5-stage 32-bit pipelined CPU, memory enabled 
module cpu5arm(ibus, clk, daddrbus, databus, reset, iaddrbus);

    //// INPUTS AND OUTPUTS ////
    // Instruction bus and clock, reset for the PC DFF
    input [31:0] ibus;
    input clk, reset;
    output [31:0] daddrbus, iaddrbus;
    inout [31:0] databus;
   
    //// ***FLAGS*** ////
    // Cin, Imm, S wires and intermediate wires
    wire ImmOP, CinOP, Imm, Cin;
    wire [2:0] SOP, S;
    
    // SW flags and intermediate SW flags 
    wire SW, SWOP, SWIDEXout, SWEXMEMout;
    
    // Load Word Flags
    wire LW, LWOP, LWIDEXout, LWEXMEMout;
    
    // SLT, SLE, BNE, BEQ flags 
    wire SLTOP, SLEOP, SLT, SLE, BEQ, BNE;
   
   
   //// ***IFID OUTPUT*** ////
   // Output of DFF
   wire [31:0] IFIDout;
    
    //// ***DECODER + FIRST MUX OUTPUTS*** ////
    // Store the output of the decoders 
    wire [31:0] Aselect, Bselect, rdOut;
    
    // Store the sign extended IType instruction 
    wire [31:0] signextOUT;
    
    // Store the output of the RT RD mux
    wire [31:0] RTRDMuxResult;
    
    
    //// ***REGFILE OUTPUTS*** ////
    // Store the outputs of the regfile 
    wire [31:0] regAbusOUT, regBbusOUT;
    
    //// ****COMPARATOR OUTPUTS**** ////
    // Intermediary Dselect wire
    wire [31:0] DselectComparatorResult;
    
    // Store the comparator output 
    wire regComparatorResult;
    
    
    //// ***IDEX OUTPUTS*** ////
    // ALU inputs
    wire [31:0] abus, bbus;
    
    // Store the wire between IDEX and bbus mux
    wire [31:0] IDEXBbusOUT;
    
    // Intermediary Dselect wires
    wire [31:0] IDEXDselectOUT;
    
    // Store the output of the IDEX sign ext line 
    wire [31:0] IDEXSignExtOUT;
    
    
    //// ***ALU OUTPUT*** ////
    // Result of the ALU
    wire [31:0] ALUout;
    
    // Store the needed SLT SLE outputs from the ALU 
    wire isZeroOutput, carryOut;
    
    
    //// ***SLTSLE OUTPUTS*** ////
    // Intermediary Dselect wires
    wire [31:0] DselectSLTSLEResult;
    
    // Store the SLTSLE block's output 
    wire [31:0] SLTSLEoutput;
    
    
    //// ***EXMEM OUTPUTS*** ////
    // Store the EXMEM line going into the databus tristate 
    wire [31:0] EXMEMDatabus;
   
    // Intermediary Dselect wires
    wire [31:0] EXMEMDselectOUT;
    
    
   //// ***MEMWB + FINAL MUX OUTPUTS*** ////
    // Store the MEMWB top output 
    wire [31:0] memAddrOut;
    
    // Store the MEMWB bottom output 
    wire [31:0] memBusOut;
    
    // Final Dselect wire
    wire [31:0] DselectTemp, Dselect;
    
    // Final dbus wire
    wire [31:0] dbus;
    

    //// ***PC + ADDER WIRES*** ////
    // Store the mux output for the PC stage
    wire [31:0] PCadderMuxOUT;
    
    // Store the result of the adders 
    wire [31:0] signextAdderOUT, pcplus4AdderOUT;
    
    // Store the result of the new IFID output 
    wire [31:0] IFIDaddOUT;
 
    // Intermediates for 32'b4 and the SLL by 2 for the adders 
    wire [31:0] imm4, signExtSLL;
    
   
     
    //// Instantiate the PC adders 
    assign signExtSLL = signextOUT << 2;
    add32 signextAdder(
        .a(signExtSLL),
        .b(IFIDaddOUT),
        .sum(signextAdderOUT)
    );
    
    assign imm4 = 32'h00000004;
    add32 pcplus4Adder(
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
    
    
    //// Instantiate the register result comparator module
    comparator32 registerCheck(
        .a(regAbusOUT),
        .b(regBbusOUT),
        .result(regComparatorResult),
        .DselectIn(RTRDMuxResult),
        .DselectOut(DselectComparatorResult),
        .BEQFlag(BEQ),
        .BNEFlag(BNE)
    );
    
    //// Instantiate the decoders //// 
    //// Assign rs and Aselect ////
    decoder5bit rs (
        .r(IFIDout[25:21]),
        .sel(Aselect)
    );
    
    //// Assign rt ////
    decoder5bit rt (
        .r(IFIDout[20:16]),
        .sel(Bselect)
    );
    
    //// Assign rd ////
    decoder5bit rd (
        .r(IFIDout[15:11]), 
        .sel(rdOut)
    );
    
    //// Read opcode to determine ALU operation ////
    opcodedecoder op (
        .opcode(IFIDout[31:26]), 
        .ImmOP(ImmOP),
        .SOP(SOP),
        .CinOP(CinOP),
        .func(IFIDout[5:0]), 
        .SWFlag(SWOP),
        .LWFlag(LWOP), 
        .SLTFlag(SLTOP),
        .SLEFlag(SLEOP),
        .BEQFlag(BEQ),
        .BNEFlag(BNE)
    );
    
    //// Sign extend for I-type instructions //// 
    signextender sd (
        .in(IFIDout[15:0]),
        .se(signextOUT)
    );
    
    //// Instantiate the mux ////
    mux2 RTRDMux (
        .in0(rdOut),
        .in1(Bselect),
        .sel(ImmOP),
        .out(RTRDMuxResult)
    );
    
    //// Instantiate and use the 32x32 bit regfile     
    assign regAbusOUT = Aselect[0] ? 32'b0 : 32'bz;
    assign regBbusOUT = Bselect[0] ? 32'b0 : 32'bz;
    
    regfile aselbselregister[31:1] (
        .clk(clk),
        .Dselect(Dselect[31:1]),
        .dbus(dbus), 
        .Aselect(Aselect[31:1]), 
        .Bselect(Bselect[31:1]), 
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
        .SLTin(SLTOP),
        .SLEin(SLEOP),
        .SLTout(SLT),
        .SLEout(SLE)
    );
    
    //// Instantiate the mux between IDEX and EXMEM which switches for I Type instructions 
    mux2 SignExtMux(
        .in0(IDEXBbusOUT),
        .in1(IDEXSignExtOUT),
        .sel(Imm),
        .out(bbus)
    );
    
    //// Instantiate the 32-bit ALU which stands between IDEX and EXMEM 
    alu32 aluUnit(  
        .d(ALUout),
        .Cout(carryOut),
        .V(),
        .a(abus),
        .b(bbus),
        .Cin(Cin), 
        .S(S), 
        .zeroDetector(isZeroOutput)
    );
    
    //// Instantiate the SLTSLE logic "multiplexor" 
    SLTSLE sltsleLogic(
        .ALUin(ALUout),
        .DselectIN(IDEXDselectOUT),
        .DselectOUT(DselectSLTSLEResult),
        .zeroInput(isZeroOutput),
        .carryOutInput(carryOut),
        .SLTSLEout(SLTSLEoutput),
        .SLTsel(SLT),
        .SLEsel(SLE)
    );


    //// Instantiate the EX/MEM DFF //// 
    EXMEMDFF EXMEM (
        .AluInput(SLTSLEoutput),
        .IDEXInput(DselectSLTSLEResult),
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
    assign Dselect = SW ? 32'h00000000 : DselectTemp;
    
    //// Instantiate the final mux //// 
    mux2 MEMWBMux(
        .in0(memAddrOut),
        .in1(memBusOut),
        .sel(LW), 
        .out(dbus)
    );     
endmodule


//// *** SUB MODULES *** ////

// Given a 5-bit RS, RT, or RD, creates the correct decoded 32-bit value 
module decoder5bit(r, sel);
    input [4:0] r;
    output [31:0] sel;
    
    assign sel = 32'd1 << r;
endmodule 

// Behavioral representation of a tristate buffer, used so databus can play with inputs correctly and 
// avoid an "assign" statement 
module tristatebuffer(in0, ctrl, out0);
    input [31:0] in0;
    input ctrl;
    output [31:0] out0;
    
    assign out0 = ctrl ?  in0 :  32'bz;
endmodule

// Given a 6-bit opcode, decipher which one we have and do something 
module opcodedecoder(opcode, ImmOP, SOP, CinOP, func, SWFlag, LWFlag, BEQFlag, BNEFlag, SLTFlag, SLEFlag);
    input [5:0] opcode, func;
    output ImmOP, CinOP, SWFlag, LWFlag, BEQFlag, BNEFlag, SLTFlag, SLEFlag;
    output [2:0] SOP;
    
    // Internal wires to store R-Type results
    reg ImmOP, CinOP, SWFlag, LWFlag, BEQFlag, BNEFlag, SLTFlag, SLEFlag;
    reg [2:0] SOP;
    
    // Decide which instruction type we have and react accordingly 
    always @ (opcode, func) begin  
        case (opcode)
            6'b000000: begin 
                            // R-type
                            case (func)
                                    6'b000011: begin
                                                    // ADD
                                                    SOP = 3'b010;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b0;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                               end
                                    6'b000010: begin
                                                    // SUB 
                                                    SOP = 3'b011;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b1;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                               end
                                    6'b000001: begin
                                                    // XOR
                                                    SOP = 3'b000;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b0;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                               end
                                    6'b000111: begin
                                                    // AND 
                                                    SOP = 3'b110;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b0;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                               end
                                    6'b000100: begin
                                                    // OR 
                                                    SOP = 3'b100;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b0;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                               end
                                    6'b110110: begin
                                                    // SLT 
                                                    SOP = 3'b011;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b1;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b1;
                                                    SLEFlag = 1'b0;
                                               end 
                                    6'b110111: begin
                                                    // SLE 
                                                    SOP = 3'b011;
                                                    ImmOP = 1'b0;
                                                    CinOP = 1'b1;
                                                    SWFlag = 1'b0;
                                                    LWFlag = 1'b0;
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b1;
                                               end
                                    default: begin
                                                    // uh oh (rtype)
                                                    SOP = 3'bxxx; 
                                                    ImmOP = 1'bx; 
                                                    CinOP = 1'bx;
                                                    SWFlag = 1'b0; 
                                                    LWFlag = 1'b0; 
                                                    BEQFlag = 1'b0;
                                                    BNEFlag = 1'b0;
                                                    SLTFlag = 1'b0;
                                                    SLEFlag = 1'b0;
                                             end
                            endcase 
                       end              
            6'b000011: begin
                            // ADDI 
                            SOP = 3'b010;
                            ImmOP = 1'b1;
                            CinOP = 1'b0;
                            SWFlag = 1'b0;
                            LWFlag = 1'b0; 
                            BEQFlag = 1'b0;
                            BNEFlag = 1'b0;
                            SLTFlag = 1'b0;
                            SLEFlag = 1'b0;
                       end
            6'b000010: begin
                            // SUBI 
                            SOP = 3'b011;
                            ImmOP = 1'b1;
                            CinOP = 1'b1;
                            SWFlag = 1'b0;
                            LWFlag = 1'b0; 
                            BEQFlag = 1'b0;
                            BNEFlag = 1'b0;
                            SLTFlag = 1'b0;
                            SLEFlag = 1'b0;
                       end
           6'b000001: begin
                            // XORI 
                            SOP = 3'b000;
                            ImmOP = 1'b1;
                            CinOP = 1'b0;
                            SWFlag = 1'b0;
                            LWFlag = 1'b0;
                            BEQFlag = 1'b0;
                            BNEFlag = 1'b0;
                            SLTFlag = 1'b0;
                            SLEFlag = 1'b0; 
                       end
           6'b001111: begin
                            // ANDI 
                            SOP = 3'b110;
                            ImmOP  = 1'b1;
                            CinOP = 1'b0;
                            SWFlag = 1'b0;
                            LWFlag = 1'b0; 
                            BEQFlag = 1'b0;
                            BNEFlag = 1'b0;
                            SLTFlag = 1'b0;
                            SLEFlag = 1'b0;
                       end
           6'b001100: begin
                            // ORI 
                            SOP = 3'b100;
                            ImmOP = 1'b1;
                            CinOP = 1'b0;
                            SWFlag = 1'b0;
                            LWFlag = 1'b0; 
                            BEQFlag = 1'b0;
                            BNEFlag = 1'b0;
                            SLTFlag = 1'b0;
                            SLEFlag = 1'b0;
                       end
           6'b011110: begin 
                           // LW 
                           SOP = 3'b010; 
                           ImmOP = 1'b1; 
                           CinOP = 1'b0;
                           SWFlag = 1'b0;
                           LWFlag = 1'b1; 
                           BEQFlag = 1'b0;
                           BNEFlag = 1'b0;
                           SLTFlag = 1'b0;
                           SLEFlag = 1'b0;
                      end
           6'b011111: begin 
                           // SW 
                           SOP = 3'b010; 
                           ImmOP = 1'b1; 
                           CinOP = 1'b0;
                           SWFlag = 1'b1;
                           LWFlag = 1'b0;
                           BEQFlag = 1'b0;
                           BNEFlag = 1'b0;
                           SLTFlag = 1'b0;
                           SLEFlag = 1'b0;
                      end
           6'b110000: begin 
                           // BEQ 
                           SOP = 3'b111; 
                           ImmOP = 1'b1; 
                           CinOP = 1'b0;
                           SWFlag = 1'b0;
                           LWFlag = 1'b0;
                           BEQFlag = 1'b1;
                           BNEFlag = 1'b0;
                           SLTFlag = 1'b0;
                           SLEFlag = 1'b0;
                      end
           6'b110001: begin 
                           // BNE
                           SOP = 3'b111; 
                           ImmOP = 1'b1; 
                           CinOP = 1'b0;
                           SWFlag = 1'b0;
                           LWFlag = 1'b0;
                           BEQFlag = 1'b0;
                           BNEFlag = 1'b1;
                           SLTFlag = 1'b0;
                           SLEFlag = 1'b0;
                      end
           default: begin
                        // uh oh
                        SOP = 3'bxxx; 
                        ImmOP = 1'bx; 
                        CinOP = 1'bx;  
                        SWFlag = 1'b0;
                        LWFlag = 1'b0;
                        BEQFlag = 1'b0;
                        BNEFlag = 1'b0;
                        SLTFlag = 1'b0;
                        SLEFlag = 1'b0; 
                    end
        endcase 
    end               
endmodule 

// Sign extend the given value to 32 bits 
module signextender(in, se);
    input [15:0] in;
    output [31:0] se;
    
    assign se = {{16{in[15]}}, in};
endmodule 

// Behavioral representation of a 2-to-1 multiplexor.
module mux2 (in0, in1, sel, out);
    input [31:0] in0, in1;
    input sel;
    output [31:0] out; 
    
    assign out = ((sel === 1'bx) ? 0 : sel) ? in1 : in0;
endmodule

// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> For 32-bit inputs
module dff32bit (clk, D, Q);
    input [31:0] D;
    input clk;
    output [31:0] Q; 
    reg [31:0] Q; 
    
    always @ (posedge clk) begin 
        Q = D;
        end 
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
    input [31:0] PCinput;
    
    output [31:0] PCoutput;
    reg [31:0] PCoutput;
    
    initial begin
        PCoutput = 32'b0;
    end
    
    always @(posedge clk, posedge reset)
        if (reset) PCoutput <= 32'b0;
        else       PCoutput <= PCinput;
endmodule

//// *** IFID DFF *** ////
module IFIDDFF (clk, D, Q, IFIDaddlineIN, IFIDaddlineOUT);
    input clk; 
    input [31:0] IFIDaddlineIN, D;
    output [31:0] IFIDaddlineOUT, Q;
    reg [31:0] IFIDaddlineOUT, Q;
    
    always @ (posedge clk) begin 
        Q = D;
        IFIDaddlineOUT = IFIDaddlineIN;
        end 
endmodule

//// *** IDEX DFF *** ////
// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> Handles the ID/EX DFF
module IDEXDFF (Imm, S, Cin, ImmIN, SIN, CinIN, clk, abusIN, bbusIN, RTRDMuxIN, SignExtIN, abusOUT, bbusOUT, RTRDMuxOUT, SignExtOUT, SWInput, SWOutput, LWInput, LWOutput, SLEin, SLTin, SLEout, SLTout);
    input [2:0] SIN;
    input [31:0] abusIN, bbusIN, RTRDMuxIN, SignExtIN; 
    input CinIN, ImmIN, clk, SWInput, LWInput, SLEin, SLTin;
    
    output [2:0] S;
    output [31:0] abusOUT, bbusOUT, RTRDMuxOUT, SignExtOUT; 
    output Cin, Imm, SWOutput, LWOutput, SLEout, SLTout;
    
    reg [2:0] S;
    reg [31:0] abusOUT, bbusOUT, RTRDMuxOUT, SignExtOUT;
    reg Cin, Imm, SWOutput, LWOutput, SLEout, SLTout;
    
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
        SLTout = SLTin;
        SLEout = SLEin; 
        end
endmodule

//// *** EXMEM DFF *** ////
// Behavioral representation of a positive-edge triggered D-Flip-Flop. --> For 32-bit inputs
module EXMEMDFF (clk, AluInput, IDEXInput, Daddrbus, DselectOUT, BoperandIN, BoperandOUT, SWInput, SWOutput, LWInput, LWOutput);
    input [31:0] AluInput, IDEXInput, BoperandIN;
    input clk, SWInput, LWInput;
    output [31:0] DselectOUT, Daddrbus, BoperandOUT; 
    output SWOutput, LWOutput;
    reg [31:0] DselectOUT, Daddrbus, BoperandOUT; 
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
module MEMWBDFF (clk, MEMWBaddrbusIN, MEMWBaddrbusOUT, MEMWBdatabusIN, MEMWBdatabusOUT, MEMWBDselectOUT, MEMWBDselectIN, SWInput, SWOutput, LWInput, LWOutput, MEMWBsltsleFlagInput, MEMWBsltsleFlagOutput);
    input [31:0] MEMWBaddrbusIN, MEMWBdatabusIN, MEMWBDselectIN;
    input clk, SWInput, LWInput, MEMWBsltsleFlagInput;
    output [31:0] MEMWBaddrbusOUT, MEMWBdatabusOUT, MEMWBDselectOUT;
    output SWOutput, LWOutput, MEMWBsltsleFlagOutput;
    reg [31:0] MEMWBaddrbusOUT, MEMWBdatabusOUT, MEMWBDselectOUT;
    reg SWOutput, LWOutput, MEMWBsltsleFlagOutput;
    
    always @ (posedge clk) begin 
        MEMWBaddrbusOUT = MEMWBaddrbusIN;
        MEMWBdatabusOUT = MEMWBdatabusIN;
        MEMWBDselectOUT = MEMWBDselectIN;
        SWOutput = SWInput;
        LWOutput = LWInput; 
        MEMWBsltsleFlagOutput = MEMWBsltsleFlagInput;
        end 
endmodule

//// *** 32-BIT ADDER *** ////
module add32(a, b, sum);
    input [31:0] a, b;
    output [31:0] sum;
    
    assign sum = a + b;
endmodule

//// *** BRANCHING COMPARATOR MODULE *** ////
module comparator32(a, b, result, DselectIn, DselectOut, BNEFlag, BEQFlag);
    input [31:0] a, b, DselectIn;
    input BNEFlag, BEQFlag;
    output [31:0] DselectOut;
    output result;
    
    reg result;
    reg [31:0] DselectOut;

    always @ (BNEFlag, BEQFlag) begin
    if (BEQFlag == 1'b1 && a === b)
        assign result = 1'b1;
    else if (BNEFlag == 1'b1 && a !== b)
        assign result = 1'b1;
    else 
        assign result = 1'b0;
        
    assign DselectOut = ((BEQFlag == 1'b1 && a === b) || (BNEFlag == 1'b1 && a !== b)) ? 32'h00000000 : DselectIn;
   
    end
endmodule

//// *** SLT SLE FLAG ASSIGNMENT MODULE *** ////
module SLTSLE(ALUin, DselectIN, DselectOUT, SLTsel, SLEsel, SLTSLEout, zeroInput, carryOutInput);
    input [31:0] ALUin, DselectIN;
    input SLTsel, SLEsel, zeroInput, carryOutInput;
    
    output [31:0] SLTSLEout, DselectOUT;
    reg [31:0] SLTSLEout, DselectOUT; 
    reg SLTSLEbitFlag;
    
    always @ (ALUin, SLTsel, SLEsel, zeroInput, carryOutInput) begin
        if (SLTsel == 1'b1 && (~zeroInput & ~carryOutInput)) begin 
            assign SLTSLEout = 32'h00000001;
            assign DselectOUT = DselectIN;
        end
        else if (SLEsel == 1'b1 && (zeroInput | ~carryOutInput)) begin 
           assign SLTSLEout = 32'h00000001;
           assign DselectOUT = DselectIN;
        end  
        else if (SLEsel == 1'b1 || SLTsel == 1'b1) begin 
            assign SLTSLEout = 32'h00000000;
            assign DselectOUT = DselectIN;
        end
        else begin
            assign SLTSLEout = ALUin;
            assign DselectOUT = DselectIN;
        end
    end 
endmodule



//// *** REGFILE *** ////
// Behavioral representation of a falling-edge sensitive flip-flop.
module regfile(clk, Dselect, Aselect, Bselect, dbus, abus, bbus);
    input [31:0] dbus;
    input Dselect, Aselect, Bselect;
    input clk;
    output [31:0] abus, bbus;
   
    reg [31:0] Q;
    
    always @ (negedge clk) begin 
            if (Dselect == 1'b1) Q = dbus;
        end
   assign abus = Aselect ? Q : 32'bz; 
   assign bbus = Bselect ? Q : 32'bz;
endmodule



//// *** ALU32 *** //// 
// Module representing a 32-bit ALU. 
module alu32 (d, Cout, V, a, b, Cin, S, zeroDetector);
   output[31:0] d;
   output Cout, V, zeroDetector;
   input [31:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [31:0] c, g, p;
   wire gout, pout;
   
   // Instantiates 32 ALU cells.
   alu_cell alucell[31:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   assign zeroDetector = d == 32'h00000000;
   
   // Instantiates a 5-level LAC.
   lac5 laclevel5(
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
      .c(c)
   );
endmodule

// Module representing a single-bit cell of a 32-bit ALU
module alu_cell (d, g, p, a, b, c, S);
    output d, g, p;
    input a, b, c;
    input [2:0] S;
    
    // Use reg instead of wire since wires cannot be procedurally assigned in that control block (always)
    wire cint, bint;
    reg d;
    
    assign bint = S[0] ^ b;
    assign g = a & bint; 
    assign p = a ^ bint;
    assign cint = S[1] & c;

    always @ (a, b, c, d, S, bint, cint, p) begin
        case (S)
            3'b100 : d = a | b;
            3'b101 : d = ~(a | b); 
            3'b110 : d = a & b;
            3'b111 : d = 0; 
            default : d = (p ^ cint);
        endcase
    end
endmodule

// Handles the overflow from the ALU
// ACCREDITION: Parts of this module were given in lecture notes.
module overflow (Cout, V, Cin, gout, pout, c);
    output Cout, V;
    input [31:0] c;
    input Cin, gout, pout;
    
    assign Cout = gout | (pout & Cin);
    assign V = Cout ^ c[31];
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