import serial

ADC_0,ADC_1,ADC_2,ADC_3,ADC_4 = range(5)

cnxn = serial.Serial(port='/dev/ttyACM1')

def getADCValue(connection,ADC_Channel=ADC_0,scale=5.0):
	connection.write(chr(ADC_0))
	r = connection.read(2)
	return float((ord(r[0])<<8)+(ord(r[1]))) / 1023 * scale
