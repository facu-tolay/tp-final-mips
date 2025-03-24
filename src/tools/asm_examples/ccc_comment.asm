# Inicialización de valores en registros
ADDI R1, R0, 10      # R1 = 10
ADDI R2, R0, 4       # R2 = 4 (valor usado como cantidad de desplazamiento)
ADDI R3, R0, 15      # R3 = 15
ADDI R4, R0, -20     # R4 = -20 (valor negativo, para demostrar desplazamiento aritmético)
ADDI R5, R0, 8       # R5 = 8

# Operaciones de desplazamiento
SLL R6, R1, 2        # R6 = R1 << 2 (desplazamiento lógico a la izquierda, equivalente a 10 * 4 = 40)
SRL R7, R3, 1        # R7 = R3 >> 1 (desplazamiento lógico a la derecha, sin signo, 15 / 2 = 7)
SRA R8, R4, 1        # R8 = R4 >> 1 (desplazamiento aritmético a la derecha, -20 >> 1 = -10)

# Desplazamientos variables
SLLV R9, R1, R2      # R9 = R1 << R2 (desplazamiento lógico a la izquierda según el valor en R2, 10 << 4 = 160)
SRLV R10, R3, R2     # R10 = R3 >> R2 (desplazamiento lógico a la derecha según el valor en R2, 15 >> 4 = 0)
SRAV R11, R4, R2     # R11 = R4 >> R2 (desplazamiento aritmético a la derecha según el valor en R2, -20 >> 4 = -2)

# Instrucción NOP
NOP                  # Sin operación, simplemente avanza a la siguiente instrucción

# Operaciones adicionales y almacenamiento
ADDU R12, R6, R7     # R12 = R6 + R7 (suma de los valores desplazados)
SB R12, 0(R5)        # Guarda R12 (valor resultante de la suma) como byte en la posición de memoria 8

# Carga de memoria y comparación
LB R13, 0(R5)        # Carga el byte desde la posición de memoria 8 en R13
BEQ R12, R13, 28     # Si R12 == R13, salta a la instrucción 28 (HALT)
NOP                  # Si no, sigue ejecutando (NOP para sincronización)

# Finalización del programa
HALT                 # Detener ejecución


# Resultado final:
# Ademas de los primeros registros, los demas se modifican:

#     R6 (SLL) = 40 → 0x28
# 
#     R7 (SRL) = 7 → 0x07
# 
#     R8 (SRA) = -10 (en complemento de 2) → 0xFFFFFFF6
# 
#     R9 (SLLV) = 160 → 0xA0
# 
#     R10 (SRLV) = 0 → 0x00
# 
#     R11 (SRAV) = -2 → 0xFFFFFFFE
# 
# Suma y almacenamiento:
# 
#     R12 (ADDU) = 40 + 7 = 47 → 0x2F
# 
#     R13 (LB) = 47 (cargado desde memoria) → 0x2F
