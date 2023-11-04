
void POWERBOARD_COM_INIT(char uart_or_i2c)
{
	// Why?
	SSP_PACKET_DATA_12 = uart_or_i2c;

	// Disable USART RX interrupts
	CLR(PIE1, 5)

	// Reset USART
	RCSTA = 0x00;
	TXSTA = 0x00;

	if (uart_or_i2c) // USART, we chose you!
	{
		// Reset/clear SSP
		SSPSTAT = 0x00;
		SSPCON = 0x00;

		// Set the flag
		SET(ENTRY_DATA_UNK1, 4);

		// Config UART
		SPBRG = 0x0c;
		TXSTA = 0x61;
		RCSTA = 0x90;

		// Read receive buffer to clear it
		uart_or_i2c = RCREG;

		// Enable RX and TX interrupts
		SET(PIE1, 5);
		SET(PIE1, 4);
	}
	else // Red chose I2C
	{
		// Clear flag
		CLR(ENTRY_DATA_UNK1, 4);

		// Init SSP
		SSPCON = 0x32;
		SSPSTAT = 0x00;

		// Change the 74HC4052 to use X1/Y1, aka "select the 5V lines to powerboard"
		SET(PORTC, 3)
	}
}

void USART_PACKET_SEND_1()
{
	// Set header
	USART_PACKET_BUFFER[0] = 0xa0;

	// Set size
	USART_PACKET_BUFFER[1] = 0x05;

	// Set packet data
	// USART_PACKET_BUFFER[2] isn't set?!?
	// Why are we copying the size and header?
	USART_PACKET_BUFFER[3] = USART_PACKET_BUFFER[1];
	USART_PACKET_BUFFER[4] = USART_PACKET_BUFFER[0];

	// Checksum parameters
	INIT_ST1_UNK1 = USART_PACKET_BUFFER[1]; // Size to checksum
	INIT_ST1_UNK2 = 0x00; // XOR checksum

	// Compute and set checksum
	USART_PACKET_BUFFER[5] = PWRB_PACKET_CHECKSUM(&USART_PACKET_BUFFER);

	USART_TX_PACKET_SIZE = USART_PACKET_BUFFER[1] + 1; // so 0x06

	// Don't know why too
	SET(SSP_PACKET_STATUS, 2);

	// Reset TX buffer index
	USART_TX_BUFFER_INDEX = 0x00;
	USART_TX_BUFFER_INDEX += 1; // we're already going to send the header

	// Ship it!
	TXREG = USART_PACKET_BUFFER[0];

	// Enable TX interrupts
	SET(PIE1, 4);
}

void USART_PACKET_SEND_2(char something)
{
	// Define the param as SSP_PACKET_DATA_12, no idea why
	SSP_PACKET_DATA_12 = something;

	// Set header
	USART_PACKET_BUFFER[0] = 0xa0;

	// Set size
	USART_PACKET_BUFFER[1] = 0x06;

	// Set packet data
	// 3 and 4 aren't defined, no idea why
	USART_PACKET_BUFFER[2] = 0x85;
	USART_PACKET_BUFFER[5] = SSP_PACKET_DATA_12;

	// Checksum parameters
	INIT_ST1_UNK1 = USART_PACKET_BUFFER[1]; // Size to checksum
	INIT_ST1_UNK2 = 0x00; // XOR checksum

	// Compute and set checksum
	USART_PACKET_BUFFER[6] = PWRB_PACKET_CHECKSUM(&USART_PACKET_BUFFER);

	USART_TX_PACKET_SIZE = USART_PACKET_BUFFER[1] + 1; // so 0x07

	// Don't know why too
	SET(SSP_PACKET_STATUS, 2);

	// Reset TX buffer index
	USART_TX_BUFFER_INDEX = 0x00;
	USART_TX_BUFFER_INDEX += 1; // we're already going to send the header

	// Ship it!
	TXREG = USART_PACKET_BUFFER[0];

	// Enable TX interrupts
	SET(PIE1, 4);
}

void USART_PACKET_SEND_3()
{
	// Set header
	USART_PACKET_BUFFER[0] = 0xa0;

	// Set size
	USART_PACKET_BUFFER[1] = 0x15; // wow!

	// Set packet data
	USART_PACKET_BUFFER[2] = 0x95;
	// here it does 2 movf [3] and [4] to w, that's useless...
	// apparently, 3 and 4 aren't used at all

	// It's used as an iterator...
	SSP_PACKET_DATA_12 = 0x00;

	register tmp = 0;
	do
	{
		// Copy data from PACKET_DATA to USART_PACKET_BUFFER
		tmp = PACKET_BUFFER[SSP_PACKET_DATA_12];
		SSP_PACKET_DATA_18_MASK = tmp; // 18_MASK is used as a temp holder
		USART_PACKET_BUFFER[5+i] = SSP_PACKET_DATA_18_MASK; // start at USART_PACKET_BUFFER[4]

		SSP_PACKET_DATA_12 += 1;
	} while (SSP_PACKET_DATA_12 < 0x10);

	// Checksum parameters
	INIT_ST1_UNK1 = USART_PACKET_BUFFER[1]; // Size to checksum
	INIT_ST1_UNK2 = 0x00; // XOR checksum

	// Compute and set checksum
	SSP_PACKET_DATA_18_MASK = PWRB_PACKET_CHECKSUM(&USART_PACKET_BUFFER);
	USART_PACKET_BUFFER[5+i] = SSP_PACKET_DATA_18_MASK;

	USART_TX_PACKET_SIZE = USART_PACKET_BUFFER[1] + 1; // so 0x07

	// Don't know why too
	SET(SSP_PACKET_STATUS, 2);

	// Reset TX buffer index
	USART_TX_BUFFER_INDEX = 0x00;
	USART_TX_BUFFER_INDEX += 1; // we're already going to send the header

	// Ship it!
	TXREG = USART_PACKET_BUFFER[0];

	// Enable TX interrupts
	SET(PIE1, 4);
}

void SSP_PACKET_SEND()
{
}

// Simple checksum
void PWRB_PACKET_CHECKSUM(char *addr)
{
	INIT_ST1_UNK3 = addr;

	CHECKSUM_UNK1 = 0x55; // checksum value
	CHECKSUM_UNK2 = 0x00; // iterator
						  // INIT_ST1_UNK1 => size to checksum
						  // INIT_ST1_UNK2 => checksum type (xor or add)

	while (CHECKSUM_UNK2 < INIT_ST1_UNK1)
	{
		// XOR if INIT_ST1_UNK2 is zero, else just add, litteral checksum
		if (INIT_ST1_UNK2 == 0x00)
			CHECKSUM_UNK1 ^= INIT_ST_UNK3[CHECKSUM_UNK2];
		else
			CHECKSUM_UNK1 += INIT_ST_UNK3[CHECKSUM_UNK2];

		CHECKSUM_UNK2 += 1;
	}

	return CHECKSUM_UNK1;
}
