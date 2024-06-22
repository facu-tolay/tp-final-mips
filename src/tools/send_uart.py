import serial
import time

send_amount = 1

# Open serial port
# serial_port = serial.Serial('/dev/ttyUSB1')  # Open port with baud rate

serial_port = serial.Serial(
    port        = '/dev/ttyUSB1',  # Port name
    baudrate    = 9600,     # Baud rate
    bytesize    = serial.EIGHTBITS,  # Number of data bits
    parity      = serial.PARITY_NONE,  # Enable parity checking
    stopbits    = serial.STOPBITS_ONE,  # Number of stop bits
    timeout     = 1,  # Read timeout value
    xonxoff     = False,  # Enable software flow control
    rtscts      = False,  # Enable hardware (RTS/CTS) flow control
    dsrdtr      = False  # Enable hardware (DSR/DTR) flow control
)

# Ensure the port is open
if serial_port.isOpen():
    print(serial_port.name + ' is open...')

for i in range(send_amount):
    hex_data = bytes.fromhex('55')
    serial_port.write(hex_data)
    time.sleep(0.10)

# Close the port
serial_port.close()