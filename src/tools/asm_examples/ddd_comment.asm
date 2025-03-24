# Inicialización de valores en registros
ADDI R1, R0, 10      # R1 = 10
ADDI R2, R0, 4       # R2 = 4 (para desplazamientos)
ADDI R3, R0, 20      # R3 = 20
ADDI R4, R0, -15     # R4 = -15 (valor negativo)
ADDI R5, R0, 100     # Carga el valor 0x00000064 en R5
LUI  R15, 43981      # Carga el valor 0xABCD0000 en R15

# Almacenamiento en memoria
SB   R1, 0(R5)       # Guarda el byte de R1 en la dirección 0(R5)
SH   R2, 2(R5)       # Guarda el halfword de R2 en la dirección 2(R5)
SW   R3, 4(R5)       # Guarda la palabra de R3 en la dirección 4(R5)

# Operaciones de desplazamiento
SLL  R6, R3, 1       # R6 = R3 << 1 (desplazamiento lógico a la izquierda)
SRL  R7, R3, 1       # R7 = R3 >> 1 (desplazamiento lógico a la derecha)
SRA  R8, R4, 1       # R8 = R4 >> 1 (desplazamiento aritmético a la derecha)

# Carga desde memoria
LBU  R9, 0(R5)       # Carga el byte sin signo desde la dirección 0(R5)
LHU  R10, 2(R5)      # Carga el halfword sin signo desde la dirección 2(R5)
LWU  R11, 4(R5)      # Carga la palabra sin signo desde la dirección 4(R5)

# Operaciones lógicas y adicionales
AND  R12, R9, R10    # R12 = R9 & R10
OR   R13, R10, R11   # R13 = R10 | R11
XOR  R14, R11, R9    # R14 = R11 ^ R9

# Finalización del programa
HALT                 # Detener ejecución


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
