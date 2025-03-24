# Inicialización de valores en los registros
ADDI R1, R0, 10      # R1 = 10
ADDI R2, R0, 20      # R2 = 20
ADDI R3, R0, 5       # R3 = 5
ADDI R4, R0, 15      # R4 = 15

# Operaciones aritméticas básicas
ADDU R5, R1, R2      # R5 = R1 + R2 (10 + 20 = 30)
SUBU R6, R5, R3      # R6 = R5 - R3 (30 - 5 = 25)

# Operaciones lógicas
OR   R7, R1, R4      # R7 = R1 | R4 (OR bit a bit entre 10 y 15)
NOR  R8, R2, R3      # R8 = ~(R2 | R3) (NOR bit a bit entre 20 y 5)
AND  R9, R4, R5      # R9 = R4 & R5 (AND bit a bit entre 15 y 30)
XOR  R10, R3, R1     # R10 = R3 ^ R1 (XOR bit a bit entre 5 y 10)
ANDI R11, R5, 12     # R11 = R5 & 12 (AND lógico con valor inmediato 12)

# Salto a una dirección específica
J 14                 # Salto a la instruccion 14

ADDI R14, R0, 100    # R14 = 100 (para demostrar que el salto funciona)
ORI  R12, R6, 8      # R12 = R6 | 8 (OR lógico con valor inmediato 8)
XORI R13, R7, 3      # R13 = R7 ^ 3 (XOR lógico con valor inmediato 3)

# Finalización del programa
HALT                 # Detener ejecución


# Resultados finales de los registros:
# Registro    Valor final (decimal)       Valor final (hexadecimal)
# R1          10                          0x0A
# R2          20                          0x14
# R3          5                           0x05
# R4          15                          0x0F
# R5          30                          0x1E
# R6          25                          0x19
# R7          15                          0x0F
# R8          -22 (en complemento)        0xFFFFFFEA
# R9          14                          0x0E
# R10         15                          0x0F
# R11         12                          0x0C
# R12         25                          0x19
# R13         12                          0x0C
# R14         No definido (no ejecutado)  N/A