# Inicialización de registros con valores específicos
ADDI R1, R0, 10       # R1 = 10 (valor inicial para desplazamientos y cálculos)
ADDI R2, R0, 4        # R2 = 4 (número de bits para desplazamientos variables)
ADDI R3, R0, 15       # R3 = 15 (valor para operaciones de desplazamiento)
ADDI R4, R0, -20      # R4 = -20 (valor negativo para desplazamientos aritméticos)
ADDI R5, R0, 8        # R5 = 8 (dirección base de la memoria para almacenamiento)

# Operaciones de desplazamiento (desplazamientos lógicos y aritméticos)
SLL R6, R1, 2         # R6 = R1 << 2 (desplazamiento lógico a la izquierda; 10 << 2 = 40)
SRL R7, R3, 1         # R7 = R3 >> 1 (desplazamiento lógico a la derecha; 15 >> 1 = 7)
SRA R8, R4, 1         # R8 = R4 >> 1 (desplazamiento aritmético a la derecha; -20 >> 1 = -10)

# Desplazamientos variables (controlados por el valor en R2)
SLLV R9, R1, R2       # R9 = R1 << R2 (desplazamiento lógico a la izquierda con R2; 10 << 4 = 160)
SRLV R10, R3, R2      # R10 = R3 >> R2 (desplazamiento lógico a la derecha con R2; 15 >> 4 = 0)
SRAV R11, R4, R2      # R11 = R4 >> R2 (desplazamiento aritmético a la derecha con R2; -20 >> 4 = -2)

# Operación NOP (no operación, solo avanza al siguiente ciclo de ejecución)
NOP                   # Sin impacto en el estado del procesador, simplemente avanza

# Suma de registros y almacenamiento
ADDU R12, R6, R7      # R12 = R6 + R7 (suma de 40 + 7 = 47)
SB R12, 0(R5)         # Guarda el byte menos significativo de R12 (47) en la dirección 8

# Carga desde memoria y comparación
LB R13, 0(R5)         # Carga el byte desde la dirección 8 en R13 (47)
BEQ R12, R13, 1       # Si R12 == R13 (47 == 47), salta a la instrucción HALT
NOP                   # Sin impacto, solo avanza si no hay salto

# Finalización del programa
HALT                  # Detiene la ejecución del programa


# Estado final de los registros:
# Registro | Valor final (decimal) | Valor final (hexadecimal)
# ---------|-----------------------|--------------------------
# R1       | 10                    | 0x0A
# R2       | 4                     | 0x04
# R3       | 15                    | 0x0F
# R4       | -20                   | 0xFFFFFFEC
# R5       | 8                     | 0x08
# R6       | 40                    | 0x28
# R7       | 7                     | 0x07
# R8       | -10                   | 0xFFFFFFF6
# R9       | 160                   | 0xA0
# R10      | 0                     | 0x00
# R11      | -2                    | 0xFFFFFFFE
# R12      | 47                    | 0x2F
# R13      | 47                    | 0x2F


# Estado final de la memoria:
# .------------------------------------------------------------.
# | Dirección de Memoria | Valor almacenado (hexadecimal)      |
# |----------------------|-------------------------------------|
# | 8                    | 0x2F - Almacenado por SB R12, 0(R5) |