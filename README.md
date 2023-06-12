### Notes on Marpaung Lecture 6/12/2023

##### Initial Comments 

`ADD` is just add
`ADDS` generates a flag: adding two numbers generates 4 flags: `V` (overflow), `C` (cout), `N` (bit 63 (MSB: 1 negative, 0 positive)), `Z` (zero flag is set when result is zero) 
so forth for all -S ending instrs

`LDUR` loads register 

Branch (`B`) is jump unconditional 

`BEQ`, `BNE`, `BLT`, `BGE` jump on flags 
`BEQ`: Branch when `Z == 1` 
`BNE`: Branch when `Z == 0`
`BLT`: Branch when `N != V` 
`BGE`: Branch when `N == V` 

Registers are 64 bits

We don't have to consider data hazards or synchronization 

##### Slide Deck 

`ADDS` happens on execute, if `bEQ` is next, it has to be on the decode stage. The branch needs to get the information directly from the execute stage without any pipelining. We forward the data to the decode stage. 
E.G., we have to set the flags properly immediately and without delay

Can use-S-suffixed instructions on the Zero register (`XZR`) such that the flags get set at the right time for the antecedent / incoming branch instruction. 

ALU generates the four flags needed

`CondBranchAddress` at (4) on the right column should read `[23]` not `[25]` (the *CODE INSTRUCTION FORMATS*) section is more correct. 

Common ways to implement the new thing: 
- Go with the new testbench file, copy 

##### Ariel's Corrected Opcodes

opcode values:

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

##### TODO List

- Redesign the decoder stage completely for the new opcodes 
- Fix his testbench to start our own 
- Redesign the regfile declaration for the new bits 
- Refactor any use of `[0:31]` and so on to respect the new ordering of bits 
- Need `LAC6` so we can get to 64 bits for the ALU and all that relies on the LAC 
- Add the one flag needed for the ALU 


