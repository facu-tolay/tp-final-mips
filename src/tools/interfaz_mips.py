import serial
import time
import logging
import threading
import struct
from assembler import Assembler



######## CODE DEFINITION ########

mips_code = """
ADDI R1, R1, 19
ADDI R2, R2, 5
SUBU R3, R1, R2
ADDU R4, R3, R0
SW R1, 0(R0)
J 0
"""

# # funca
# mips_code = """
# ADDI R1, R1, 21
# ADDI R2, R2, 3
# AND R3, R1, R2
# XOR R1, R2, R3
# LW R4, 0(R0)
# J 0
# """

#################################


# Diccionario de instrucciones -- ver pagina 243 patternson en espanol
instruction_set = {
    "AND"  : {"type": "R", "opcode": "000000", "shamt": "00000", "funct": "100100"},
    "XOR"  : {"type": "R", "opcode": "000000", "shamt": "00000", "funct": "100110"},

    "SUBU" : {"type": "R", "opcode": "000000", "shamt": "00000", "funct": "100011"},
    "ADDU" : {"type": "R", "opcode": "000000", "shamt": "00000", "funct": "100001"},
    "ADDI" : {"type": "I", "opcode": "001000"                                     },

    "LW"   : {"type": "I", "opcode": "100011"                                     }, # por ejemplo si la inst es "LW $S1, 100($S2)" --> $S1 = memory[$S2+100]
    "SW"   : {"type": "I", "opcode": "101011"                                     }, # por ejemplo si la inst es "SW $S1, 100($S2)" --> memory[$S2+100] = $S1
    "J"    : {"type": "J", "opcode": "000010"                                     }, # en las instrucciones "j [destino]", el destino es el numero de instruccion relativo al comienzo del PC. Si el PC comienza en 0 y quiero ir
                                                                                     # a la 1era instruccion hago "j 0", que equivale a la posicion inicial del PC. Si "j 1" salto a la 2da instruccion y seria la posicion 4 de memoria

    "HALT" : {"type": "X", "opcode": "01000000000000000000000000000000"           }
}

serial_port = None
asm = None
serial_receive_thread = None

def manage_exception(e):
    logging.error(f'[{__name__}] Exception raised: {repr(e)} | {type(e).__name__}\n@ {__file__}, line {e.__traceback__.tb_lineno}\n')

# Función para convertir un número decimal a binario de n bits
def to_binary(number, bits):
    binary = bin(number & int("1" * bits, 2))[2:]  # Asegura complemento a 2
    return binary.zfill(bits)

# Función para obtener automáticamente el binario de un registro
# la entrada es un string "Rn" y la salida es n en binario de 5 bits
def register_to_binary(register):
    if (register.startswith("R") and register[1:].isdigit()):
        reg_number = int(register[1:])  # Extrae el número del registro
        return to_binary(reg_number, 5)  # Convierte a binario de 5 bits
    else:
        raise ValueError(f"Registro no válido: {register}")

# Función para compilar una instrucción MIPS
# esta funcion esta rotasa
def compile_mips_instruction(instruction):
    parts = instruction.split()
    mnemonic = parts[0]
    if (mnemonic not in instruction_set):
        raise ValueError(f"Instrucción no soportada: {mnemonic}")

    info = instruction_set[mnemonic]
    opcode = info["opcode"]

    if (info["type"] == "X"):  # Tipo especiales
        if (mnemonic == "HALT"):
            return f"{opcode}"

    if (info["type"] == "I"):  # Tipo I
        if (mnemonic == "ADDI"):
            _, rt, rs, immediate = parts
            rs_bin = register_to_binary(rs.strip(","))
            rt_bin = register_to_binary(rt.strip(","))
            immediate_bin = to_binary(int(immediate), 16)
            return f"{opcode}{rs_bin}{rt_bin}{immediate_bin}"
        elif (mnemonic == "LW" or mnemonic == "SW"):
            _, rt, offset_base = parts
            offset, base = offset_base.split("(")
            base = base.strip(")")
            base_bin = register_to_binary(base)
            rt_bin = register_to_binary(rt.strip(","))
            offset_bin = to_binary(int(offset), 16)
            return f"{opcode}{base_bin}{rt_bin}{offset_bin}"

    elif (info["type"] == "R"):  # Tipo R
        _, rd, rs, rt = parts
        rs_bin = register_to_binary(rs.strip(","))
        rt_bin = register_to_binary(rt.strip(","))
        rd_bin = register_to_binary(rd.strip(","))
        shamt = info["shamt"]
        funct = info["funct"]
        return f"{opcode}{rs_bin}{rt_bin}{rd_bin}{shamt}{funct}"

    elif (info["type"] == "J"):  # Tipo J
        _, address = parts
        address_bin = to_binary(int(address), 26)
        return f"{opcode}{address_bin}"

    else:
        raise ValueError(f"Tipo no soportado para la instrucción: {mnemonic}")

# Función para convertir una instrucción binaria a hexadecimal
def binary_to_hex(binary):
    hex_value = hex(int(binary, 2))[2:].upper()  # Convierte a hexadecimal y quita '0x'
    return hex_value.zfill(8)  # Asegura 8 caracteres (32 bits en hexadecimal)

# Función principal para compilar código MIPS
def compile_mips_code(code):
    lines = code.strip().split("\n")
    compiled_binary = []
    compiled_hex = []
    for line in lines:
        binary_instruction = compile_mips_instruction(line)
        compiled_binary.append(binary_instruction)
        compiled_hex.append(binary_to_hex(binary_instruction))
    return compiled_binary, compiled_hex

# recibe un string con un byte en hexa y lo envia por serial. Recibe algo como "E4"
def send_byte_serial(byte_to_send):
    global serial_port
    try:
        hex_data = bytes.fromhex(byte_to_send) # esto es si se manda un string en byte_to_send que representa el hexadecimal
        # hex_data = byte_to_send.encode("ascii") # esto es si se manda un string en formato ASCII
        serial_port.write(hex_data)
    except Exception as e:
        manage_exception(e)

def send_instructions_serial(hex_output):
    n_nibbles_in_a_byte = 2

    print(f'instructions to send: \n {hex_output} \n')

    send_byte_serial(hex(ord('B'))[2:].upper()) # starts receiving code - la operacion [2:] elimina el prefijo '0x', y .upper() lo pone en mayúsculas

    time.sleep(0.10)

    for instruction_32b in hex_output:
        for i in range(0, len(instruction_32b), n_nibbles_in_a_byte): # recorremos el for de a 2 (n_nibbles_in_a_byte porque cada caracter del string representa 4 bits en hexa)
            byte_to_send = instruction_32b[i:i+2]
            send_byte_serial(byte_to_send)
            time.sleep(0.10)
    print(f'\n\nsent all instructions!')

def enviar_programa_process():

    binary_code = ""
    asm_tokens = []

    # binary_output, hex_output = compile_mips_code(mips_code)
    # send_instructions_serial(hex_output)

    try:
        # asm_file = open("./aaa.asm", encoding='utf-8')
        # asm_file = open("./bbb.asm", encoding='utf-8')
        # asm_file = open("./ccc.asm", encoding='utf-8')
        # asm_file = open("./ddd.asm", encoding='utf-8')
        asm_file = open("./asm_examples/eee.asm", encoding='utf-8')
        # asm_file = open("./fff.asm", encoding='utf-8')
        # asm_file = open("./ggg.asm", encoding='utf-8')
        asm_tokens = asm.tokenizer(asm_file)
    finally:
        asm_file.close()

    for inst in asm_tokens:
        binary_code += (asm.instruction_generator(inst))

    num_byte = []
    for i in range(int(len(binary_code)/8)):
        num = int(binary_code[i*8:(i+1)*8],2)
        num_byte.append(num)
    try:
        out_file = open("./output_code.hex", "wb")
        out_file.write((''.join(chr(i) for i in num_byte)).encode('charmap'))
    finally:
        out_file.close()

    # send_byte_serial(hex(ord('B'))[2:].upper())
    serial_port.write(b'B')
    with open("output_code.hex", "rb") as f:
        while True:
            data = f.read(8)
            if not data:
                break
            serial_port.write(data)
            time.sleep(0.10)

    print(f'\n\nsent all instructions !')

def main_menu():
    global serial_port

    while True:
        print("\n\n------- Menú Principal -------")
        print("\t 1. Enviar programa")
        print("\t 2. Borrar programa")
        print("\t 3. Reset PC\n")
        print("--- Simulation section ---")
        print("\t 4. Run\n")
        print("\t 5. Next step")
        print("\t 6. Read PC")
        print("\t 7. Read register")
        print("\t 8. Read memory\n")
        print("9. Salir")
        choice = input("Selecciona una opción: ")

        if (choice == "1"):
            enviar_programa_process()
        elif (choice == "2"):
            serial_port.write(b'F')
        elif (choice == "3"):
            serial_port.write(b'C')
        elif (choice == "4"):
            serial_port.write(b'G')
        elif (choice == "5"):
            serial_port.write(b'S')
        elif (choice == "6"):
            serial_port.write(b'P')
        elif (choice == "7"):
            serial_port.write(b'R')
        elif (choice == "8"):
            serial_port.write(b'M')
        elif (choice == "9"):
            print("Catalina: 'gudboye'")
            break
        else:
            print("Opción no válida, inténtalo de nuevo.")


# FIXME hacer un bloque generico en RTL que detecte caracteres y saque una salida cuando la vea

class thread(threading.Thread):

    def __init__(self, thread_name):
        threading.Thread.__init__(self)
        self.thread_name = thread_name

    def run(self):
        while True:
            if (serial_port.inWaiting()):
                received = serial_port.readlines()
                received = b''.join(received) # en caso de que llegue el valor d'10 significa salto de linea y lo toma como una linea aparte.
                                              # para solventar esto se hace un join de todas las lineas para tener un solo chunk de datos.

                words_32b = []
                for i in range(0, len(received) // 4 * 4, 4):  # Solo procesar múltiplos de 4
                    bytes_quartet = received[i:i+4]
                    word_32b = struct.unpack('>I', bytes_quartet)[0]  # '>I' para big-endian, cambia a '<I' para little-endian
                    word_32b_hex = f"{word_32b:08X}" # Convertir la palabra en un string hexadecimal de 8 caracteres
                    words_32b.append(word_32b_hex)
                print(f'\n\nreceived data: {len(received)} bytes \n{words_32b}\n')


def main():
    global serial_port
    global serial_receive_thread
    global asm

    asm = Assembler()

    try:
        # Open serial port
        serial_port = serial.Serial(
            port        = '/dev/ttyUSB1', # Port name
            baudrate    = 9600, # Baud rate
            bytesize    = serial.EIGHTBITS, # Number of data bits
            parity      = serial.PARITY_NONE, # Enable parity checking
            stopbits    = serial.STOPBITS_ONE, # Number of stop bits
            timeout     = 0.35, # Read timeout value in seconds
            xonxoff     = False, # Enable software flow control
            rtscts      = False, # Enable hardware (RTS/CTS) flow control
            dsrdtr      = False # Enable hardware (DSR/DTR) flow control
        )

        if serial_port.isOpen():
            print(serial_port.name + ' is open...')

            serial_receive_thread = thread("serial_rx_thread")
            serial_receive_thread.start()
    except Exception as e:
        manage_exception(e)

    # binary_output, hex_output = compile_mips_code(mips_code)
    # print("Instrucciones en binario:")
    # for binary in binary_output:
    #     print(binary)
    # print("\nInstrucciones en hexadecimal:")
    # for hexa in hex_output:
    #     print(hexa)

    # hex_data = bytes.fromhex('55')
    # serial_port.write(hex_data)
    # time.sleep(0.10)

    # send_instructions_serial(hex_output)

    main_menu()

    # Close the port
    serial_port.close()

    print(f'\n\n back to main!')


if __name__ == '__main__':
    main()

