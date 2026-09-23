void _interrupt(void)
{
	// Backup important registers
	register char wreg; // This will contain the current W register
	ISR_BKP_WREG = wreg;
	ISR_BKP_STATUS = STATUS;
	ISR_BKP_FSR = FSR;
	ISR_BKP_PCLATH = PCLATH;

	// Backup apparently important variables
	ISR_BKP_ENTRY_SUB2_UNK1 = ENTRY_SUB2_UNK1;

	// NB: These are the shadowed vars
	ISR_BKP_SHWD1 = *(char*)0x7a;
	ISR_BKP_SHWD2 = *(char*)0x7b;
	ISR_BKP_SHWD3 = *(char*)0x7c;
	ISR_BKP_SHWD4 = *(char*)0x7d;
	ISR_BKP_SHWD5 = *(char*)0x7e;
	ISR_BKP_SHWD6 = *(char*)0x7f;

	ISR_BKP_FETCH_ADDR_L = FETCH_ADDR_L;
	ISR_BKP_FETCH_ADDR_H = FETCH_ADDR_H;

	// Clear status
	STATUS = 0x00;

	// Handle SSP interrupts
	if ( (PIR1 & 0x08) && (PIE1 & 0x08) )
		interrupt_handler_ssp();

	// Handle timer 0 interrupts
	// (check for timer0 and that timer0 is enabled)
	if ( (INTCON & 0x04) && (INTCON & 0x20) )
		interrupt_handler_timer0();

	// Handle timer 1 interrupts
	if ( (PIR1 & 0x01) && (PIE1 & 0x01) )
		interrupt_handler_timer1();

	// Handle USART interrupts
	if ( (PIR1 & 0x04) && (PIE1 & 0x04) )
		interrupt_handler_usart_rx();
	if ( (PIR1 & 0x10) && (PIE1 & 0x10) )
		interrupt_handler_usart_tx();

	// Restore variables and registers
	ENTRY_SUB2_UNK = ISR_BKP_ENTRY_SUB2_UNK1;
	*(char*)0x7a = ISR_BKP_SHWD1;
	*(char*)0x7b = ISR_BKP_SHWD2;
	*(char*)0x7c = ISR_BKP_SHWD3;
	*(char*)0x7d = ISR_BKP_SHWD4;
	*(char*)0x7e = ISR_BKP_SHWD5;
	*(char*)0x7f = ISR_BKP_SHWD6;
	FETCH_ADDR_L = ISR_BKP_FETCH_ADDR_L;
	FETCH_ADDR_H = ISR_BKP_FETCH_ADDR_H;
	FSR = ISR_BKP_FSR;
	PCLATH = ISR_BKP_PCLATH;
	STATUS = ISR_BKP_STATUS;
	wreg = ISR_BKP_WREG;

	// Return from interrupt
	asm('RETFIE');
}

// SSP (I2C) interrupt handler
void interrupt_handler_ssp(void)
{
	register char rcvd_byte;

	// Clear SSPIF flag in PIR1
	CLR(PIR1, 3);

	rcvd_byte = SSPBUF;

	// Copy received byte to buffer
	SSP_BUFFER[SSP_TX_BUFFER_INDEX++] = rcvd_byte;

	// I don't know why it does that yet
	// When you didn't finished to send packets, set a value and return
	if (SSP_TX_BUFFER_INDEX < SSP_PACKET_SIZE)
	{
		SSP_UNK2 = 0x09;
		return;
	}

	// When you've received all the packets apparently

	// Disable SSP interrupts
	CLR(PIE1, 3);

	// Update flags
	SET(USART_SSP_PACKET_STATUS, 5);
	CLR(USART_SSP_PACKET_STATUS, 4);
}

// Timer 0 interrupt handler
// that is definitively a weird one...
// still need to see each what time it triggers
void interrupt_handler_timer0(void)
{
	// Reset timer0
	TMR0 = 0xfd;
	CLR(INTCON, TMR0IF);

	// This enable or dizable the buzzer @ around 4khz (8mhz OSC, prescaler 4) using the PWM
	if (TIMER1_UNK2 & 0x04 && (ENTRY_DATA_UNK2 == 0x0a || ENTRY_DATA_UNK2 == 0x32))
	{
		// Set the PWM (CCP1) and enable timer 2
		CCP1CON = 0xac;
		SET(T2CON, 2);
	}
	else if ( !(TIMER1_UNK2 & 0x04) || (TIMER_UNK2 & 0x04 && (ENTRY_DATA_UNK2 == 0x00 || ENTRY_DATA_UNK2 == 0xff)) )
	{
		// Disable timer2, reset CCP1 and disable the buzzer (active low)
		CLR(T2CON, 2);
		CCP1CON = 0x00;
		SET(PORTC, 5);
	}

	// No idea what that part does
	// It sends part of a I2C packet
	if (SSP_UNK2 != 0x00 && --SSP_UNK2 == 0x00)
		// Why it starts at 0x3c and not 0x31?
		SSPBUF = SSP_BUFFER[11+SSP_TX_BUFFER_INDEX];

	// Decrement something if it isn't zero...
	if (TIMER0_INT_UNK1 != 0x00)
		TIMER0_INT_UNK1 -= 0x01;

	// WTF is that even?
	USART_RX_RCVD_BYTE = !(TIMER0_INT_UNK2 & 0x01);
	TIMER0_INT_UNK2 = ((USART_RX_RCVD_BYTE ^ TIMER0_INT_UNK2) & 0xfe) ^ USART_RX_RCVD_BYTE

	// This turn on or off the OK LED
	if ( !(INIT_HW1_UNK7 & 0x01) || !(TIMER0_INT_UNK2 & 0x01) )
		SET(PORTA, 4);
	else
		CLR(PORTA, 4);

	// This turn on or off the ESC LED
	if ( !(INIT_HW1_UNK7 & 0x02) || !(TIMER0_INT_UNK2 & 0x01) )
		SET(PORTA, 3);
	else
		CLR(PORTA, 3);

	// Whatever that is
	if ( (TIMER0_INT_UNK3 & 0x20) || (TIMER0_INT_UNK3 & 0x40) || SSP_PACKET_DATA_18 )
	{
		TIMER0_INT_UNK4 = 0x03;
		CLR(TIMER0_INT_UNK2, 5);
	}

	// Well, okay
	if (HW_INIT2_UNK11 != 0)
		HW_INIT2_UNK11 -= 1;

	// This apparently is a counter for some action
	HW_INIT2_UNK1 -= 1;
	if (HW_INIT2_UNK1 == 0)
	{
		// Reset counter
		HW_INIT2_UNK1 = 0x1a;

		SET(ENTRY_DATA_UNK3, 1);

		// That is also weird
		if (ENTRY_DATA_UNK2 != 0)
			ENTRY_DATA_UNK2 += 1;
		if (ENTRY_DATA_UNK2 != 0) // we overflowed it
			ENTRY_DATA_UNK2 -= 1; // return to 0xff
	}
}

// Timer 1 interrupt handler
// NB: timer 1 should trigger once every ~100us, so 0.1ms (theorically 107.5us)
void interrupt_handler_timer1(void)
{
	// Clear TMR1IF (the overflow interrupt flag) and reset TMR1
	CLR(PIR1, 0);
	TMR1H = 0xfc;
	TMR1L = 0xa3;

	// Check for an error condition?
	if ( !(ENTRY_DATA_UNK4 & 0x10) )
	{
		SET(PORTA, 6); // enable LCD backlight
		return;
	}

	// Define UNK3 (the limit for UNK6, the counter, it seems)
	if (TIMER1_UNK2 & 0x40)
		TIMER1_UNK3 = 0x01;
	else if ( !(TIMER1_UNK4 & 0x3f) && ((TIMER1_UNK5 & 0x10) || (TIMER1_UNK5 & 0x08)) )
		TIMER1_UNK3 = 0x02;
	else
		TIMER3_UNK3 = 0x00;

	// Turn on or off the LCD backlight depending on TIMER1_UNK6
	if (TIMER1_UNK6 == 0x00)
		CLR(PORTA, 6)
	else if (TIMER1_UNK6 == 0x01 || TIMER1_UNK6 == 0x02)
		SET(PORTA, 6)

	// Mange UNK6 (apparently, a counter)
	if (TIMER1_UNK6 < TIMER1_UNK3)
		TIMER_UNK6 += 1;
	else
		TIMER_UNK6 = 0;
}

// USART RX interrupt handler
void interrupt_handler_usart_rx(void)
{
	// Check for framing or overrun errors
	if ( (RCSTA & 0x04) || (RCSTA & 0x02) )
	{
		CLR(RCSTA, CREN); // Clear overrun error by setting continous receive bit
		USART_RX_RCVD_BYTE = RCREG; // Clear the framing error by reading RCREG
									// NB: this byte is discarded
		SET(RCSTA, CRAN); // Re-enable receiving bytes as errors were cleared

		USART_RX_BUFFER_INDEX = 0x00; // Reset the buffer (eg. discard the whole packet)

		// As there was an error, just return
		return;
	}

	// Receive byte
	USART_RX_RCVD_BYTE = RCREG;

	// Something with that that enables handling the packet, else we discard it...
	if (USART_SSP_PACKET_STATUS & 0x08 || !(USART_SSP_PACKET_STATUS & 0x04) )
	{
		USART_RX_UNKNOWN = 0x02; // I don't know what it does

		// Manange first byte (header, always 0x0a)
		if (USART_RX_BUFFER_INDEX == 0x00 && USART_RX_RCVD_BYTE == 0x0a)
		{
			// Put the packet into the buffer
			USART_PACKET_BUFFER[0] = USART_RX_RCVD_BYTE;
			USART_RX_BUFFER_INDEX += 1;
		}

		// Manage second byte (packet size, max 23/0x17)
		else if (USART_RX_BUFFER_INDEX == 0x01)
		{
			// Check if size is size is correct, else, discard packet
			if (USART_RX_RCVD_BYTE < 0x17)
			{
				// Receive packet and set packet size
				USART_PACKET_BUFFER[1] = USART_RX_RCVD_BYTE;
				USART_RX_PACKET_SIZE = USART_RX_RCVD_BYTE;
				USART_RX_BUFFER_INDEX += 1;
			}
			else
				USART_RX_BUFFER_INDEX = 0x00;
		}

		// Manage all other packets (just receive them)
		else
		{
			USART_PACKET_BUFFER[USART_RX_BUFFER_INDEX++] = USART_RX_RCVD_BYTE;

			// Check if we've reached the en of packet and flag that a packet is available
			if (USART_RX_BUFFER_INDEX > USART_RX_PACKET_SIZE)
				SET(USART_SSP_PACKET_STATUS, 3);
		}
	}

}

// USART TX interrupt handler
void interrupt_handler_usart_tx(void)
{
	// If there's still bytes to send... well, send them, we're not chronopost
	if (USART_TX_BUFFER_INDEX < USART_TX_PACKET_SIZE)
		TXREG = *USART_PACKET_BUFFER[USART_TX_BUFFER_INDEX++];
	else
	{
		// clear the interrupt flag and flag it, i guess
		CLR(PIR, 4);
		USART_TX_UNKNOWN = 0x02;
	}
}
