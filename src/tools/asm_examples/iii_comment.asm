# Inicialización de valores
ADDI R1, R0, 5        # R1 = N (límite superior, en este caso 5)
ADDI R2, R0, 0        # R2 = 0 (acumulador para la suma)
ADDI R3, R0, 1        # R3 = 1 (contador para iterar desde 1 hasta N)
ADDI R4, R0, 64       # R4 = Dirección de salto dinámico (por ejemplo, línea 26) - Expresada en bytes
ADDI R31, R0, 0       # R31 = 0 (se usará para guardar direcciones de retorno)

# Inicio del bucle principal
SLT  R5, R3, R1       # Comprueba si R5 = R3 < R1 (contador < límite?)
BEQ  R5, R0, 2        # Si R3 >= R1, salta a las operaciones extra

# Incrementar el contador para la siguiente iteración
ADDI R3, R3, 1        # Incrementa R3 (contador)
J    5                # Salta de vuelta al inicio del bucle principal

# Operaciones extra
ADDU R2, R2, R3       # Acumula el valor de R3 en R2 (R2 += R3)
JAL 18                # Guarda dirección de retorno en R31 y salta a la subrutina B
ADDI R7, R0, 69       # Se setea el valor de R7
ADDI R2, R2, 10       # Incrementa a R2 en 10
HALT

# JALR rd, rs         # salta incondicionalmente a la instrucción cuya dirección se encuentra en el registro rs. Salva la dirección de la siguiente instrucción en el registro $rd
JALR R20, R4          # Salta a la direccion apuntada por R4 (=15) y guarda la dir de retorno en R20
J    20               # Goto HALT

# Subrutina C
ADDI R2, R2, 10       # Incrementa a R2 en 10
JR R20                # Salta a la direccion desde donde se invoco

# Subrutina B
ADDI R2, R2, 10       # Incrementa a R2 en 10
JR R31                # Salta a la direccion desde donde se invoco

# Finalización del programa
HALT                  # Detener ejecución






"00000000",
"00000005",
"00000019",
"00000005",
"00000040",
"00000000",
"00000000",
"00000045",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"00000000",
"0000002C"]