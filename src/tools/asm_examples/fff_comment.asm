# Inicialización de valores
ADDI R1, R0, 5        # R1 = N (límite superior, en este caso 5)
ADDI R2, R0, 0        # R2 = 0 (acumulador para la suma)
ADDI R3, R0, 1        # R3 = 1 (contador para iterar desde 1 hasta N)
ADDI R4, R0, 11       # R4 = Dirección de salto dinámico (por ejemplo, línea 20)
ADDI R31, R0, 0       # R31 = 0 (se usará para guardar direcciones de retorno)

# Inicio del bucle principal
SLT  R5, R3, R1       # Comprueba si R3 < R1 (contador < límite?)
BEQ  R5, R0, 2        # Si R3 >= R1, salta a las operaciones extra

# Incrementar el contador para la siguiente iteración
ADDI R3, R3, 1        # Incrementa R3 (contador)
J    5                # Salta de vuelta al inicio del bucle (Loop)

# Operaciones extra
ADDU R2, R2, R3       # Acumula el valor de R3 en R2 (R2 += R3)
JAL 13                # Guarda dirección de retorno en R31 y salta a la subrutina de JALR

# Subrutina B
ADDI R7, R0, 69       # Se incrementa R7
JR R31                # Retorna a la dirección guardada en R31

# Salto dinámico con JALR
JALR R31, R4          # Salta a la dirección en R4 y guarda la dirección de retorno en R31 - subrutina secundaria
ADDI R2, R2, 10       # Suma 10 a R2

# Finalización del programa
HALT                  # Detener ejecución
