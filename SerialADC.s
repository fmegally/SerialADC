;
; AssemblerApplication1.asm
;
; Created: 4/17/2016 11:42:22 PM
; Author : Fady
;

.include "m328pdef.inc"

.def temp_lo  = r16
.def temp_hi  = r17
.def temp     = r18

.cseg
.org 0x0000
		jmp RESET			;Reset Handler
		jmp EXT_INT0		;IRQ0 Handler
		jmp EXT_INT1		;IRQ1 Handler
		jmp PC_INT0			;PCINT0
		jmp PC_INT1			;PCINT1
		jmp PC_INT2			;PCINT2
		jmp WDT				;Watchdog timer
		jmp TIM2_COMPA		;Timer 2 Compare A
		jmp TIM2_COMPB		;Timer 2 Compare B
		jmp TIM2_OVF		;Timer 2 Overflow
		jmp TIM1_CAPT		;Timer 1 Capture
		jmp TIM1_COMPA		;Timer 1 Compare A
		jmp TIM1_COMPB		;Timer 1 Compare B
		jmp TIM1_OVF		;Timer 1 Overflow
		jmp TIM0_COMPA		;Timer 0 Compare A
		jmp TIM0_COMPB		;Timer 0 Compare B
		jmp TIM0_OVF		;Timer 0 Overflow
		jmp SPI_STC			;SPI Transfer Complete
		jmp USART_RXC		;USART RX Complete
		jmp USART_UDRE		;USART UDR Empty
		jmp USART_TXC		;USART TX
		jmp ADC_INT			;ADC Conversion Complete
		jmp EE_RDY			;EEPROM Ready Handler
		jmp ANA_COMP		;Analog Comparator
		jmp TWI				;2-Wire Sertial Interface
		jmp SPM_RDY			;Store Program Memory Ready

RESET:	cli					;Disable global interrupts

		;Initialize Serial Communication
		ldi temp_lo, 0X67		;Set baud rate to 9600
		ldi temp_hi, 0X00		;Baudrate regiter is two bytes.(see previous line)
		sts UBRR0L, temp_lo
		sts UBRR0H, temp_hi
		clr temp
		ldi temp, (1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0) ; Enable TX, RX, RX Interrupt
		sts UCSR0B, temp
		clr temp
		ldi temp, (1<<UCSZ00)|(1<<UCSZ01) ; Set size to 8 bits
		sts UCSR0C, temp

		;Initialize the ADC peripheral
		clr temp
		sts ADCSRB, temp
		ldi temp, (1<<ADEN)
		sts ADCSRA, temp
		;Enable port B as output for debugging
		ldi temp,0xFF
		out DDRB,temp	
		sei				;Enable global interrupts

INFLOOP:
		rjmp INFLOOP

EXT_INT0:
		nop
		reti
EXT_INT1:
		nop
		reti
PC_INT0:
		nop
		reti
PC_INT1:
		nop
		reti
PC_INT2:
		nop
		reti
WDT:
		nop
		reti
TIM2_COMPA:
		nop
		reti
TIM2_COMPB:
		nop
		reti
TIM2_OVF:
		nop
		reti
TIM1_CAPT:
		nop
		reti
TIM1_COMPA:
		nop
		reti
TIM1_COMPB:
		nop
		reti
TIM1_OVF:
		nop
		reti
TIM0_COMPA:
		nop
		reti
TIM0_COMPB:
		nop
		reti
TIM0_OVF:
		nop
		reti
SPI_STC:
		nop
		reti
USART_RXC:
		lds temp, UDR0 			;Read requested channel from received byte
		andi temp,0x07 			;Mask to allow only ADC0 to ADC7 as valid options
		sts ADMUX, temp 		;Update MUX setting with the new channel
		out PORTB, temp			;Show RX value on Port B for debugging
		lds temp, ADCSRA 		;Read ADC status register
		sbr temp, (1<<ADSC)		;Set start conversion bit
		sts ADCSRA, temp 		;Store new setting
WAITA: 	lds temp, ADCSRA		;Read Status register
		sbrs temp,ADIF 			;Isolate conversion complete bit
		rjmp WAITA 				;If bit is clear(masked byte not zero) then converion is not complete
		lds temp_hi,ADCH		;When conversion is comlete copy ADC high byte and low byte
		lds temp_lo,ADCL

		lds temp, ADCSRA
		sbr temp, ADIF			;Clear ADC Interrupt flag
		sts ADCSRA, temp

		sts UDR0,temp_hi		;Send the conversion result high byte (only righmost 2 bits are relevant)
WAITH:	lds temp,UCSR0A 		;Check if UART transmission is complete
		sbrs temp,TXC0			;When TXC flag is raised (transm. complete) then move on
		rjmp WAITH

		lds temp,UCSR0A 		;Read UART Status register A
		sbr temp,(1<<TXC0) 		;Modify (write logical 1) to TX Complete bit. Write to to TXC to clear flag 
		sts UCSR0A,temp 		;Store(clear TX)

		sts UDR0,temp_lo 		;Send the conversion result low byte
WAITL:	lds temp,UCSR0A 		;Check if UART transmission is complete
		sbrs temp,TXC0			;When TXC flag is raised then move one
		rjmp WAITL

		lds temp,UCSR0A 		;Read UART Status register A
		sbr temp,(1<<TXC0) 		;Modify (write logical 1) to TX Complete bit. Write to to TXC to clear flag
		sts UCSR0A,temp 		;Store(clear TX)
		reti

USART_UDRE:
		nop
		reti
USART_TXC:
		nop
		reti
ADC_INT:
		nop
		reti
EE_RDY:
		nop
		reti
ANA_COMP:
		nop
		reti
TWI:
		nop
		reti
SPM_RDY:
		nop
		reti
