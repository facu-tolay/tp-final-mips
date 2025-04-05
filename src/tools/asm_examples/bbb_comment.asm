# Inicialización de registros con valores específicos
ADDI R1, R0, 10       # R1 = 10 (primer valor que se almacenará en memoria)
ADDI R2, R0, 20       # R2 = 20 (segundo valor que se almacenará en memoria)
ADDI R3, R0, 5        # R3 = 5 (tercer valor que se almacenará en memoria)
ADDI R4, R0, 15       # R4 = 15 (valor auxiliar no utilizado directamente)
ADDI R5, R0, 100      # R5 = 100 (dirección base en memoria para las operaciones)

# Almacenamiento en memoria
SB   R1, 0(R5)        # Almacena el byte menos significativo de R1 en la dirección 100
SH   R2, 2(R5)        # Almacena el halfword (2 bytes) de R2 en la dirección 102
SW   R3, 4(R5)        # Almacena el word (4 bytes) de R3 en la dirección 104

# Carga desde memoria
LB   R6, 0(R5)        # Carga el byte desde la dirección 100 en R6, extendiéndolo con signo
LH   R7, 2(R5)        # Carga el halfword desde la dirección 102 en R7, extendiéndolo con signo
LW   R8, 4(R5)        # Carga el word desde la dirección 104 en R8

# Operaciones entre registros
ADDU R9, R6, R7       # R9 = R6 + R7 (suma de los valores cargados de las direcciones 100 y 102)
SUBU R10, R9, R8      # R10 = R9 - R8 (resta del acumulador R9 menos el valor cargado de la dirección 104)

# Finalización del programa
HALT                  # Detiene la ejecución del programa

# Estado final de los registros
# Registro | Valor final (decimal) | Valor final (hexadecimal)
# ---------|-----------------------|--------------------------
# R1       | 10                    | 0x0A
# R2       | 20                    | 0x14
# R3       | 5                     | 0x05
# R4       | 15                    | 0x0F
# R5       | 100                   | 0x64
# R6       | 10                    | 0x0A
# R7       | 20                    | 0x14
# R8       | 5                     | 0x05
# R9       | 30                    | 0x1E
# R10      | 25                    | 0x19

# Estado final de la memoria:
# .------------------------------------------------------------.
# | Dirección de Memoria | Valor almacenado (hexadecimal)      |
# |----------------------|-------------------------------------|
# | 0x00000064           | 0x0A (byte)                         |
# | 0x00000066           | 0x0014 (halfword)                   |
# | 0x00000068           | 0x00000005 (word)                   |
