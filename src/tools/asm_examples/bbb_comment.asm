# Inicialización de valores en los registros
ADDI R1, R0, 10      # R1 = 10
ADDI R2, R0, 20      # R2 = 20
ADDI R3, R0, 5       # R3 = 5
ADDI R4, R0, 15      # R4 = 15
ADDI R5, R0, 100     # R5 = Dirección base en memoria (ejemplo)

# Almacenamiento en memoria
SB   R1, 0(R5)       # Almacena el byte de R1 en la posición 0 de memoria (R5)
SH   R2, 2(R5)       # Almacena el halfword de R2 en la posición 2 de memoria (R5)
SW   R3, 4(R5)       # Almacena el word de R3 en la posición 4 de memoria (R5)

# Carga desde memoria
LB   R6, 0(R5)       # Carga el byte desde la posición 0 de memoria (R5) en R6
LH   R7, 2(R5)       # Carga el halfword desde la posición 2 de memoria (R5) en R7
LW   R8, 4(R5)       # Carga el word desde la posición 4 de memoria (R5) en R8

# Operaciones adicionales para verificar valores cargados
ADDU R9, R6, R7      # R9 = R6 + R7 (suma de valores cargados)
SUBU R10, R9, R8     # R10 = R9 - R8 (diferencia de los valores)

# Finalización del programa
HALT                 # Detener ejecución


# Resultado final:
# Ademas de los registros cargados inicialmente, se modifican:
#    R6 (valor cargado con LB): 10 (0x0A en hexadecimal).
#    R7 (valor cargado con LH): 20 (0x14 en hexadecimal).
#    R8 (valor cargado con LW): 5 (0x05 en hexadecimal).
#    R9 (resultado de la suma): 10 + 20 = 30 (0x1E en hexadecimal).
#    R10 (resultado de la resta): 30 - 5 = 25 (0x19 en hexadecimal).