ADDI R1, R0, 0
ADDI R2, R0, 10
ADDI R3, R0, 1
ADDI R4, R0, 0
SLT  R5, R1, R2
BEQ  R5, R0, 4
ADDU R4, R4, R3
SLTI R6, R4, 15
ADDI R1, R1, 1
J 4
HALT
