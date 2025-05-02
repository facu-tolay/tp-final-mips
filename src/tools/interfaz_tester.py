from testcases import *
from common import *
import common
from api_debug_unit import *

def main_menu():

    while True:
        print("\n------- Main Menu -------")
        print("\t 0. Testear todos los programas")
        print("\t 1. Testear programa aaa.asm")
        print("\t 2. Testear programa bbb.asm")
        print("\t 3. Testear programa ccc.asm")
        print("\t 4. Testear programa ddd.asm")
        print("\t 5. Testear programa eee.asm")
        print("\t 6. Testear programa fff.asm")
        print("\t 7. Testear programa ggg.asm")
        print("\t 8. Testear programa hhh.asm")
        print("\t 9. Testear programa iii.asm")
        print("\t10. Testear programa jjj.asm")

        print("\n---- Control section ----")
        print("\t A. Borrar programa")
        print("\t B. Reset PC\n")
        print("\t C. Read PC")
        print("\t R. Read registers")
        print("\t M. Read memory\n")
        print("\t X. Salir")
        choice = input("Selecciona una opción: ")

        if (choice == "0"):
            testcase_all()
        elif (choice == "1"):
            testcase_aaa_asm()
        elif (choice == "2"):
            testcase_bbb_asm()
        elif (choice == "3"):
            testcase_ccc_asm()
        elif (choice == "4"):
            testcase_ddd_asm()
        elif (choice == "5"):
            testcase_eee_asm()
        elif (choice == "6"):
            testcase_fff_asm()
        elif (choice == "7"):
            testcase_ggg_asm()
        elif (choice == "8"):
            testcase_hhh_asm()
        elif (choice == "9"):
            testcase_iii_asm()
        elif (choice == "10"):
            testcase_jjj_asm()
        elif (choice == "A"):
            api_du_delete_program(common.serial_port)
        elif (choice == "B"):
            api_du_reset_pc(common.serial_port)
        elif (choice == "C"):
            api_du_read_pc(common.serial_port)
        elif (choice == "R"):
            api_du_read_registers(common.serial_port)
        elif (choice == "M"):
            api_du_read_memory(common.serial_port)
        elif (choice == "X" or choice == "x"):
            print("exiting...")
            break
        else:
            print("Opción no válida, inténtalo de nuevo.")

def main():
    create_serial_port()
    main_menu()

    common.serial_port.close()
    print(f'\n\n back to main!')


if __name__ == '__main__':
    main()
