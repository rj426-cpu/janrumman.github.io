# -*- coding: utf-8 -*-
"""
May 2021
Nils Napp

Python Example to read from FRDM-KL25Z Debug Cable Serial Port

You will need to change the COM Port. If you change the baudrate
be sure to change it in the setup code for the UART0 too.

In windows you can find it under "Device Manager" -> "Ports (COM & LTP)"

In linux it will look like /dev/ttyUSB0 or something similar. You can find it
by plugging in the board and then running 'sudo dmesg' and looking at most
recent output for something like /dev/tty????

The board will send one string "Hello There Again!"
And then keep sending single bytes 0-255

To send larger values than 255 you need to send muliple bytes from the MCU
and then decode them appropriatly using struct.unpack()
"""


import serial

#ser = serial.Serial('/dev/cu.usbmodemSDA6C7C1E5E1', 115200, timeout=2)
#print("Reading accelerometer data... (Ctrl+C to stop)")
#counter = 0
#while True:
 #   line = ser.readline().decode('utf-8').strip()
 #   if line:
#        if line == 'J':
 #           print(f"[{counter}] *** JUMP DETECTED ***")
 #       else:
 #           print(f"[{counter}] {line}")
 #       counter += 1
