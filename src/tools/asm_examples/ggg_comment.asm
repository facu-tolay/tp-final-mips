# Inicialización de valores
ADDI R1, R0, 0       # R1 = 0 (contador)
ADDI R2, R0, 10      # R2 = N (número de iteraciones, por ejemplo 10)
ADDI R3, R0, 1       # R3 = 1 (incremento en cada iteración)
ADDI R4, R0, 0       # R4 = 0 (acumulador)

# Bucle
SLT  R5, R1, R2      # Si R1 < R2, R5 = 1. Si no, R5 = 0.
BEQ  R5, R0, 4       # Si R5 == 0 (R1 >= R2), salta hacia el halt
ADDU R4, R4, R3      # Incrementar acumulador R4
SLTI R6, R4, 15      # Si R4 < 15, R6 = 1. Si no, R6 = 0.
ADDI R1, R1, 1       # Incrementar contador R1
J    4               # Salta nuevamente al inicio del bucle (Loop)

# Final del programa
HALT                 # Detener ejecución



# Estado final esperado:
# Registro  | Valor final (decimal) | Valor final (hexadecimal)
# ----------|-----------------------|--------------------------------
# R1        | 10                    | 0x0A (número de iteraciones, N)
# R2        | 10                    | 0x0A
# R3        | 1                     | 0x01
# R4        | 10                    | 0x0A
# R5        | 0                     | 0x00 (R1 ya no es menor que R2)
# R6        | 1                     | 0x01 (R4 < 15)