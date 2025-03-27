def api_du_run_program(serial_port):
    serial_port.write(b'E')

def api_du_next_step(serial_port):
    serial_port.write(b'N')

def api_du_enable_load_program(serial_port):
    serial_port.write(b'L')

def api_du_read_registers(serial_port):
    serial_port.write(b'R')

def api_du_read_memory(serial_port):
    serial_port.write(b'M')

def api_du_read_pc(serial_port):
    serial_port.write(b'P')

def api_du_delete_program(serial_port):
    serial_port.write(b'D')

def api_du_reset_pc(serial_port):
    serial_port.write(b'C')


# // RUN_COMMAND          = "E";
# // NEXT_COMMAND         = "N";
# // BOOTLOADER_COMMAND   = "L";
# // READ_REG_COMMAND     = "R";
# // READ_MEM_COMMAND     = "M";
# // READ_PC_COMMAND      = "P";
# // FLUSH_PROG_COMMAND   = "D";
# // RESET_PC_COMMAND     = "C";