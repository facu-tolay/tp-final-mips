ADDI R1, R0, 10
ADDI R2, R0, 4
ADDI R3, R0, 20
ADDI R4, R0, -15
ADDI R5, R0, 100
LUI  R15, 43981
SB   R1, 0(R5)
SH   R2, 2(R5)
SW   R3, 4(R5)
SLL  R6, R3, 1
SRL  R7, R3, 1
SRA  R8, R4, 1
LBU  R9, 0(R5)
LHU  R10, 2(R5)
LWU  R11, 4(R5)
AND  R12, R9, R10
OR   R13, R10, R11
XOR  R14, R11, R9
HALT
