import time
import serial
import logging
import threading
import struct
from assembler import Assembler
from api_debug_unit import *

serial_port = None
serial_receive_thread = None

def enviar_programa_process(asm_filename):
    global serial_port

    binary_code = ""
    asm_tokens = []

    asm_compiler = Assembler()

    try:
        asm_file = open(asm_filename, encoding='utf-8')
        asm_tokens = asm_compiler.tokenizer(asm_file)
    finally:
        asm_file.close()

    for inst in asm_tokens:
        binary_code += (asm_compiler.instruction_generator(inst))

    num_byte = []
    for i in range(int(len(binary_code)/8)):
        num = int(binary_code[i*8:(i+1)*8],2)
        num_byte.append(num)

    output_file_name = "output_code_" + asm_filename[-7:].replace(".", "_") + ".hex"

    try:
        out_file = open(output_file_name, "wb")
        out_file.write((''.join(chr(i) for i in num_byte)).encode('charmap'))
    finally:
        out_file.close()

    api_du_enable_load_program(serial_port)
    with open(output_file_name, "rb") as f:
        while True:
            data = f.read(8)
            if not data:
                break
            serial_port.write(data)
            time.sleep(0.10)

    print(f'\nsent all instructions !')

def test_program(asm_filename, expected_reg_state, expected_mem_state):
    global serial_port
    global serial_receive_thread

    test_result = True

    # toma el archivo, lo compila y lo envia al mips
    enviar_programa_process(asm_filename)

    # le da run
    time.sleep(0.5)
    api_du_run_program(serial_port)
    time.sleep(0.25)

    if(expected_reg_state != None and len(expected_reg_state) > 0):
        print(f'checking registers ...')
        api_du_read_registers(serial_port)
        time.sleep(1.5)
        mips_registers_status = serial_receive_thread.get_last_received_words()
        print(f'registros del MIPS despues de ejecutar:\n{mips_registers_status}\n')
        test_result = test_result and compare_registers(mips_registers_status, expected_reg_state)

    if(expected_mem_state != None and len(expected_mem_state) > 0):
        print(f'checking memory ...')
        api_du_read_memory(serial_port)
        time.sleep(1.5)
        mips_memory_status = serial_receive_thread.get_last_received_words()
        print(f'memoria del MIPS despues de ejecutar:\n{mips_memory_status}\n')
        test_result = test_result and compare_registers(mips_memory_status, expected_mem_state)

    print(f"\ntest pass ? {bcolors.OKGREEN if test_result==True else bcolors.FAIL} {test_result} {bcolors.ENDC}")

    # borrar programa y reset PC
    api_du_delete_program(serial_port)
    time.sleep(0.25)
    api_du_reset_pc(serial_port)
    print("\ntodo borrado, listo para un nuevo run\n")
    return test_result

def compare_registers(current, expected):
    if(len(current) != len(expected)):
        print(f'[ERROR] difieren en tamaño\n')
        return False

    compare_result = True
    for i in range(0, len(current)):
        compare_result = compare_result and (current[i] == expected[i])

    print(f'\n[COMPARE] expected data: {len(expected)} bytes \n{expected}\n')

    print(f"match ? {bcolors.OKGREEN if compare_result==True else bcolors.FAIL} {compare_result} {bcolors.ENDC}")
    return compare_result

def create_serial_port():
    global serial_port
    global serial_receive_thread

    try:
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

class rx_thread(threading.Thread):

    def __init__(self, thread_name):
        threading.Thread.__init__(self)
        self.thread_name = thread_name
        self.__last_received_words = None

    def run(self):
        global serial_port

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
                print(f'\n[THREAD] received data: {len(received)} bytes \n{words_32b}\n')

    def get_last_received_words(self):
        return self.__last_received_words

def manage_exception(e):
    logging.error(f'[{__name__}] Exception raised: {repr(e)} | {type(e).__name__}\n@ {__file__}, line {e.__traceback__.tb_lineno}\n')

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
