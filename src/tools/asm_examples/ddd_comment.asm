# Inicialización de registros con valores constantes
ADDI R1, R0, 10      # R1 = 10
ADDI R2, R0, 4       # R2 = 4
ADDI R3, R0, 20      # R3 = 20
ADDI R4, R0, -15     # R4 = -15
ADDI R5, R0, 100     # R5 = 100

# Carga de valores en registros
LUI  R15, 43981      # R15 = 43981 << 16

# Operaciones de almacenamiento en memoria
SB   R1, 0(R5)       # Guarda el byte bajo de R1 en Mem[100]
SH   R2, 2(R5)       # Guarda el halfword de R2 en Mem[102]
SW   R3, 4(R5)       # Guarda la palabra completa de R3 en Mem[104]

# Operaciones de desplazamiento (shift)
SLL  R6, R3, 1       # R6 = R3 << 1 (multiplicación por 2)
SRL  R7, R3, 1       # R7 = R3 >> 1 (división lógica por 2)
SRA  R8, R4, 1       # R8 = R4 >>> 1 (división aritmética por 2)

# Carga de valores desde la memoria
LBU  R9, 0(R5)       # R9 = Mem[100] (carga un byte sin signo)
LHU  R10, 2(R5)      # R10 = Mem[102] (carga un halfword sin signo)
LWU  R11, 4(R5)      # R11 = Mem[104] (carga una palabra sin signo)

# Operaciones lógicas
AND  R12, R9, R10    # R12 = R9 & R10
OR   R13, R10, R11   # R13 = R10 | R11
XOR  R14, R11, R9    # R14 = R11 ^ R9

# Fin del programa
HALT                 # Detiene la ejecución




# Resultados finales de los registros:
# Registro  | Valor final (decimal) | Valor final (hexadecimal)
# ----------|-----------------------|--------------------------
# R1        | 10                    | 0x0A
# R2        | 4                     | 0x04
# R3        | 20                    | 0x14
# R4        | -15                   | 0xFFFFFFF1
# R5        | 0x00000064            | 0x00000064
# R6        | 40                    | 0x28
# R7        | 10                    | 0x0A
# R8        | -8                    | 0xFFFFFFF8
# R9        | 10                    | 0x0A
# R10       | 4                     | 0x0004
# R11       | 20                    | 0x00000014
# R12       | 0                     | 0x0000
# R13       | 20                    | 0x00000014
# R14       | 30                    | 0x0000001E
# R15       | too long              | 0xABCD0000

# Resultados en memoria:
# Dirección  | Valor almacenado
# -----------|-------------------
# 0x00000064 | 0x0A (byte)
# 0x00000066 | 0x0004 (halfword)
# 0x00000068 | 0x00000014 (word)
