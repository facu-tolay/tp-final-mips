import serial
import time
import logging
import threading
import struct
from assembler import Assembler
from api_debug_unit import *

serial_port = None
asm = None
serial_receive_thread = None

def manage_exception(e):
    logging.error(f'[{__name__}] Exception raised: {repr(e)} | {type(e).__name__}\n@ {__file__}, line {e.__traceback__.tb_lineno}\n')

def enviar_programa_process(asm_filename):
    binary_code = ""
    asm_tokens = []

    try:
        asm_file_path = "./asm_examples/" + asm_filename
        asm_file = open(asm_file_path, encoding='utf-8')
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

    api_du_enable_load_program(serial_port)
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
            asm_filename = input("Archivo a grabar: ")
            enviar_programa_process(asm_filename)
        elif (choice == "2"):
            api_du_delete_program(serial_port)
        elif (choice == "3"):
            api_du_reset_pc(serial_port)
        elif (choice == "4"):
            api_du_run_program(serial_port)
        elif (choice == "5"):
            api_du_next_step(serial_port)
        elif (choice == "6"):
            api_du_read_pc(serial_port)
        elif (choice == "7"):
            api_du_read_registers(serial_port)
        elif (choice == "8"):
            api_du_read_memory(serial_port)
        elif (choice == "9"):
            print("Catalina: 'gudboye'")
            break
        else:
            print("Opción no válida, inténtalo de nuevo.")


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

    main_menu()

    serial_port.close()
    print(f'\n\n back to main!')

if __name__ == '__main__':
    main()

