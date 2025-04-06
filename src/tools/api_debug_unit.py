def api_du_run_program(du_serial_port):
    du_serial_port.write(b'E')

def api_du_next_step(du_serial_port):
    du_serial_port.write(b'N')

def api_du_enable_load_program(du_serial_port):
    du_serial_port.write(b'L')

def api_du_read_registers(du_serial_port):
    du_serial_port.write(b'R')

def api_du_read_memory(du_serial_port):
    du_serial_port.write(b'M')

def api_du_read_pc(du_serial_port):
    du_serial_port.write(b'P')

def api_du_delete_program(du_serial_port):
    du_serial_port.write(b'D')

def api_du_reset_pc(du_serial_port):
    du_serial_port.write(b'C')
