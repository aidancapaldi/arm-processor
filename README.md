### 5-Stage Pipelined ARM CPU

##### What is this?

This repository contains an implementation of a 5-stage CPU. This processor can handle a selection of instructions from the `ARM` instruction set. The CPU is pipelined, which allows it to handle multiple instructions in tandem rather than waiting several cycles for completion of previous instructions, saving clock cycles over a multi-cyle or single-cycle processor. 
Instructions enter the "pipeline" wherein they proceed through the Instruction Fetch, Instruction Decode, Instruction Execute, Memory Access, and Memory Writeback stages. 

The processor supports 64-bit instructions provided via `ibus`. Data memory can be simulated via testbench from the bidirectional `databus` line. `daddrbus` line specifies which address to which the register should read or write, and the `iaddrbus` line specifies the program counter for the instructions. 
`iaddrbus` can increment as needed to support branching. 

##### Supported Opcodes

The following operation codes are supported by the CPU. Note the differences between these opcodes and those of the `LEGV8` green sheet. 

```verilog
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
```
##### Using the processor 

This processor was designed with an eye to use in the Xilinx Vivado toolsuite. Included are three testbenches which demonstrate the range of instructions supported.

Due credit goes to my colleague, Ariel Mahler, who wrote one of the testbenches (`cput5armtbAriel.v`) for the program. Credit for the `cpuarm5tb.v` testbench goes to Dr. Julius Marpaung.

Christian Bender also wrote one of the included testbenches.


##### Schematic Diagram 

[Diagram link](https://lucid.app/lucidchart/bb6ea441-bf98-424a-8f45-dcc6bf4a040e/edit?page=0_0&invitationId=inv_fa02469f-1cc0-4602-ad25-949e55a2c984#)

##### Acknowledgements

This program was authored and designed by Mikayla Sagle and Aidan Capaldi at Northeastern University in Summer term 2023. 

One of the two testbenches was authored by Ariel Mahler. Special thanks to Dr. Julius Marpaung for providing lectures and debugging support!
