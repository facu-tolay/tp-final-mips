import serial
import time
import logging
import threading
import struct
from assembler import Assembler
from api_debug_unit import *


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

serial_port = None
asm = None
serial_receive_thread = None

def manage_exception(e):
    logging.error(f'[{__name__}] Exception raised: {repr(e)} | {type(e).__name__}\n@ {__file__}, line {e.__traceback__.tb_lineno}\n')

def enviar_programa_process(asm_filename):

    binary_code = ""
    asm_tokens = []

    try:
        asm_file = open(asm_filename, encoding='utf-8')
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

    # serial_port.write(b'B')
    api_du_enable_load_program(serial_port)
    with open("output_code.hex", "rb") as f:
        while True:
            data = f.read(8)
            if not data:
                break
            serial_port.write(data)
            time.sleep(0.10)

    print(f'\n\nsent all instructions !')

def test_program(asm_filename, expected_reg_state):
    global serial_receive_thread

    # toma el archivo, lo compila y lo envia al mips
    enviar_programa_process(asm_filename)

    # le da run
    time.sleep(1)
    # serial_port.write(b'G')
    api_du_run_program(serial_port)

    # toma el valor de los registros y compara
    time.sleep(1)
    # serial_port.write(b'R')
    api_du_read_registers(serial_port)
    time.sleep(2)
    mips_registers_status = serial_receive_thread.get_last_received_words()
    print(f'registros del MIPS despues de ejecutar:\n{mips_registers_status}\n')

    compare_registers(mips_registers_status, expected_reg_state)

    # borrar programa y reset PC
    time.sleep(1)
    # serial_port.write(b'F')
    api_du_delete_program(serial_port)
    time.sleep(1)
    # serial_port.write(b'C')
    api_du_reset_pc(serial_port)

    print("\ntodo borrado, listo para un nuevo run\n")

def compare_registers(current, expected):
    if(len(current) != len(expected)):
        print(f'[ERROR] difieren en tamaño\n')
        return False

    compare_result = True
    for i in range(0, len(current)):
        compare_result = compare_result and (current[i] == expected[i])

    print(f"match ? {bcolors.OKGREEN if compare_result==True else bcolors.FAIL} {compare_result} {bcolors.ENDC}")
    return compare_result

def main_menu():
    global serial_port

    while True:
        print("\n\n------- Menú Principal -------")
        print("\t 1. Testear programa aaa.asm")
        print("\t 2. Testear programa bbb.asm")
        print("\t 3. Testear programa ccc.asm")
        print("\t 4. Testear programa ddd.asm")
        print("\t 5. Testear programa eee.asm")
        # print("\t 6. Testear programa fff.asm")
        print("\t 6. Testear programa ggg.asm")

        print("\n--- Simulation section ---")
        print("\t 7. Borrar programa")
        print("\t 8. Reset PC\n")
        print("\t 9. Read PC")
        print("\t 0. Read registers")
        print("\t A. Read memory\n")
        print("\t X. Salir")
        choice = input("Selecciona una opción: ")

        if (choice == "1"):
            program_file = "./asm_examples/aaa.asm"
            expected_registers = ["00000000", "0000000A", "00000014", "00000005", "0000000F", "0000001E", "00000019", "0000000F",
                                  "FFFFFFEA", "0000000E", "0000000F", "0000000C", "00000019", "0000000C", "00000064", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        elif (choice == "2"):
            program_file = "./asm_examples/bbb.asm"
            expected_registers = ["00000000", "0000000A", "00000014", "00000005", "0000000F", "00000064", "0000000A", "00000014",
                                  "00000005", "0000001E", "00000019", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        elif (choice == "3"):
            program_file = "./asm_examples/ccc.asm"
            expected_registers = ["00000000", "0000000A", "00000004", "0000000F", "FFFFFFEC", "00000008", "00000028", "00000007",
                                  "FFFFFFF6", "000000A0", "00000000", "FFFFFFFE", "0000002F", "0000002F", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        elif (choice == "4"):
            program_file = "./asm_examples/ddd.asm"
            expected_registers = ["00000000", "0000000A", "00000004", "00000014", "FFFFFFF1", "00000064", "00000028", "0000000A",
                                  "FFFFFFF8", "0000000A", "00000004", "00000014", "00000000", "00000014", "0000001E", "ABCD0000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        elif (choice == "5"):
            program_file = "./asm_examples/eee.asm"
            expected_registers = ["00000000", "0000000A", "0000000A", "0000000B", "0000000B", "00000005", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        # elif (choice == "6"):
        #     program_file = "./asm_examples/fff.asm"
        #     expected_registers = ["00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
        #                           "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
        #                           "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
        #                           "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
        #     test_program(program_file, expected_registers)

        elif (choice == "6"):
            program_file = "./asm_examples/ggg.asm"
            expected_registers = ["00000000", "0000000A", "0000000A", "00000001", "0000000A", "00000000", "00000001", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                                  "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
            test_program(program_file, expected_registers)

        elif (choice == "7"):
            api_du_delete_program(serial_port)
        elif (choice == "8"):
            api_du_reset_pc(serial_port)
        elif (choice == "9"):
            api_du_read_pc(serial_port)
        elif (choice == "0"):
            api_du_read_registers(serial_port)
        elif (choice == "A"):
            api_du_read_memory(serial_port)
        elif (choice == "X"):
            print("exiting...")
            break
        else:
            print("Opción no válida, inténtalo de nuevo.")

class rx_thread(threading.Thread):

    def __init__(self, thread_name):
        threading.Thread.__init__(self)
        self.thread_name = thread_name
        self.__last_received_words = None

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

                self.__last_received_words = words_32b
                print(f'\n\n[THREAD] received data: {len(received)} bytes \n{words_32b}\n')

    def get_last_received_words(self):
        return self.__last_received_words


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

            serial_receive_thread = rx_thread("serial_rx_thread")
            serial_receive_thread.start()
    except Exception as e:
        manage_exception(e)

    main_menu()

    serial_port.close()
    print(f'\n\n back to main!')


if __name__ == '__main__':
    main()
