### Notes on his lecture 6/12/2023

##### Initial comments 

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

##### Slide deck 

`ADDS` happens on execute, if `bEQ` is next, it has to be on the decode stage. The branch needs to get the information directly from the execute stage without any pipelining. We forward the data to the decode stage. 
E.G., we have to set the flags properly immediately and without delay

Can use-S-suffixed instructions on the Zero register (`RZR`) such that the flags get set at the right time for the antecedent / incoming branch instruction. 

ALU generates the four flags needed

##### Things we should remember to do 

- Redesign the decoder stage completely for the new opcodes 
- Fix his testbench to start our own 
- Redesign the regfile declaration for the new bits 
- Refactor any use of `[0:31]` and so on to respect the new ordering of bits 
- Need `LAC6` so we can get to 64 bits for the ALU and all that relies on the LAC 



