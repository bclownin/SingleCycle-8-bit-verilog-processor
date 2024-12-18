# SingleCycle-8-bit-verilog-processor
Single cycle version of the 8 bit processor.

Once files are added into a Vivado project, compile Assembler.cpp into an exe and place Assembler.exe and program.txt into the same directory as memory.mem (right click on memory.mem and select source file properties to see it's location). Write your program and run the Assembler and it will update memory.mem. Updating the memory.mem requires a complete rebuild (synth > impl > bit file) to take affect.

Pyssembler.py can be used instead of Assembler.cpp, it is the same program but written in python.

After instructions from memory run out, device transitions into "SWmode". From there, the processor is programmed via 16 input switches and are "clocked" into the processor via SWexe. BEQ and JUMP are not implemented in SWmode.

instruction format:
16 bit
0000 0000 0000 0000

funct = instruction[15:11]
op = instruction[15:14] = funct [4:3]
aluOp = instruction[13:11] = funct [2:0]
Target Register (RT) = instruction[10:8]
Register A (RA) = instruction[5:3]
Register B (RB) = instruction[2:0]
immediate = instruction[7:0]

ALU
funct == 00xxx where xxx is:
aluOp: 000 = AND
001 = OR
010 = ADD
011 = Subtract
100 = set less
101 = NOR
110 = set equal

LI
op = 01
loads immed value (instr[7:0] into target register [instr[10:8])

Display
op = 11
displays contents of target register (instr[10:8])

SW
funct = 10000
stores target register (instr[10:8]) contents into memory at address = immed [instr[7:0]

LW
funct = 10001
stores contents of memory at address = immed (instr[7:0]) into target register

Link
funct = 10010
stores current PC in dataMem[immed] to be jumped to from BEQ or JUMP

Jump
funct = 10011
sets PC = dataMem[rt], jump limit = immed

BEQ
funct = 10100
branches to dataMem[instr[10:6]] if ra == rb

*** Instruction syntax examples***
SB R1, 1
LB R1, 1
LI R2, 2
DISPLAY R3
LINK 4
JUMP 4, 5
BEQ 4, R1, R2
AND R3, R1, R2
OR R7, R6, R5
ADD R5, R4, R3
SUB R7, R1, R7
SLT R5, R3, R2
NOR R1, R2, R3
SETEQUAL R2, R3, R4
