# Inicialización de valores
ADDI R1, R0, 0       # R1 = 0 (contador)
ADDI R2, R0, 10      # R2 = N (valor final del contador, por ejemplo, 10)
ADDI R3, R0, 10      # R3 = 0x0A (registro donde se colocará +1 si se alcanza N)
ADDI R4, R0, 10      # R4 = 0x0A (contador secundario si R1 < N/2)
SRL  R5, R2, 1       # R5 = N / 2 (la mitad de N)

# Bucle
ADDI R1, R1, 1       # Incrementar el contador R1
BNE  R1, R5, -2      # Si R1 != N/2, salta a la línea 9 (PC + 1 - 2)
ADDI R4, R4, 1       # R4 = R4 + 1 (solo si R1 >= N/2)

# Verificar si se ha alcanzado N
BEQ R1, R2, 2        # Si R1 == N, salta a la línea 19 (PC + 1 + 2)
ADDI R1, R1, 1       # Incrementar el contador R1
J 8                  # Salta nuevamente al inicio del bucle (comienza a contar instrucciones desde 0 hasta n-1), linea 14

# Condición cumplida
ADDI R3, R3, 1       # R3 = 0x0B (se ha alcanzado N)
HALT                 # Detener ejecución





# Estado final esperado de los registros:
# Registro    | Valor final (decimal) |  Valor final (hexadecimal)
# ------------|-----------------------|---------------------------
# R1          | 10 (N)                | 0x0A
# R2          | 10 (N)                | 0x0A
# R3          | 11                    | 0x0B
# R4          | 11                    | 0x0B (incrementado al alcanzar N/2)
# R5          | 5 (N/2)               | 0x05
