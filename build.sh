#!/bin/bash
avra SerialADC.s --includepath /usr/share/avra/ -l listfile
avrdude -c usbtiny -p atmega328p -U hfuse:w:0xDF:m -U lfuse:w:0xFF:m -U flash:w:SerialADC.s.hex
