import serial

# Replace with your actual port name from Step 1

ser = serial.Serial('/dev/cu.usbmodemSDA6C7C1E5E1', 115200, timeout=2)
print("Reading accelerometer data... (Ctrl+C to stop)")
counter = 0
while True:
    line = ser.readline().decode('utf-8').strip()
    if line:
        if line == 'J':
            print(f"[{counter}] *** JUMP DETECTED ***")
        else:
            print(f"[{counter}] {line}")
        counter += 1
