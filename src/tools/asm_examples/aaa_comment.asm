# Inicialización de registros con valores específicos
ADDI R1, R0, 10       # R1 = 10 (primer valor)
ADDI R2, R0, 20       # R2 = 20 (segundo valor)
ADDI R3, R0, 5        # R3 = 5 (valor para restar)
ADDI R4, R0, 15       # R4 = 15 (valor para operaciones lógicas)

# Operaciones aritméticas básicas
ADDU R5, R1, R2       # R5 = R1 + R2 = 10 + 20 = 30 (suma de los dos valores)
SUBU R6, R5, R3       # R6 = R5 - R3 = 30 - 5 = 25 (resta del resultado previo)

# Operaciones lógicas entre registros
OR   R7, R1, R4       # R7 = R1 | R4 (OR bit a bit entre 10 y 15)
NOR  R8, R2, R3       # R8 = ~(R2 | R3) (NOR bit a bit entre 20 y 5)
AND  R9, R4, R5       # R9 = R4 & R5 (AND bit a bit entre 15 y 30)
XOR  R10, R3, R1      # R10 = R3 ^ R1 (XOR bit a bit entre 5 y 10)

# Operaciones con valores inmediatos
ANDI R11, R5, 12      # R11 = R5 & 12 (AND lógico con el valor inmediato 12)
ADDI R14, R0, 100     # R14 = 100 (carga de un valor inmediato en R14)
ORI  R12, R6, 8       # R12 = R6 | 8 (OR lógico con el valor inmediato 8)
XORI R13, R7, 3       # R13 = R7 ^ 3 (XOR lógico con el valor inmediato 3)

# Finalización del programa
HALT                  # Detiene la ejecución del programa


# Resultados finales de los registros:
# Registro | Valor final (decimal) | Valor final (hexadecimal)
# ---------|-----------------------|--------------------------
# R1       | 10                    | 0x0A
# R2       | 20                    | 0x14
# R3       | 5                     | 0x05
# R4       | 15                    | 0x0F
# R5       | 30                    | 0x1E
# R6       | 25                    | 0x19
# R7       | 15                    | 0x0F
# R8       | -22 (en complemento)  | 0xFFFFFFEA
# R9       | 14                    | 0x0E
# R10      | 15                    | 0x0F
# R11      | 12                    | 0x0C
# R12      | 25                    | 0x19
# R13      | 12                    | 0x0C
# R14      | 100                   | 0x64
