// Seems to be a general init i2c function
// so probably something like "init_i2c_devices"
void Eleonore(void)
{
	// Send init cmd to i2c bus?
	USART_LOGIC_UNK30 = 0x00; // iterator
	do
	{
		SET(PORTB, 3);
		SET(PORTB, 4);
		CLR(TRISB, 3);
		softi2c_wait();
		CLR(PORTB, 3);
		softi2c_wait();
		CLR(PORTB, 4);
		USART_LOGIC_30 += 1;
	} while (USART_LOGIC_30 < 0x9);

	// Init LCD, calls softi2c_end with whatever is in W, so 0x09?
	softi2c_end(0x09);

	// Init E2P?
	USART_LOGIC_UNK27 = 0x02;
	USART_LOGIC_UNK28 = 0x00;
	USART_LOGIC_UNK29 = 0xa0;
	Caroline();

	// Shuffle around packet buffer, no idea why
	USART_LOGIC_UNK2 = 0x00
	USART_PACKET_CHECKSUM = PACKET_BUFFER[0] + PACKET_BUFFER[1];
	if (USART_PACKET_CHECKSUM < PACKET_BUFFER[1])
		USART_LOGIC_UNK2 += 1;

	if (!(USART_PACKET_CHECKSUM + 1 | USART_LOGIC_2))
		SSP_PACKET_DATA_19 = PACKET_BUFFER[0]

	// Do again something with the E2P
	USART_LOGIC_UNK27 = 0x00;
	USART_LOGIC_UNK28 = 0x00;
	USART_LOGIC_UNK29 = 0xa0;
	Caroline();

	if (PACKET_BUFFER < 0x09)
		ELEONOR_UNK2 = 0x40;
	else
		ELEONOR_UNK@ = 0x80;
}


// This init some data... maybe main logic data?
void init_something_2(void)
{
	TIMER1_UNK4 = 0x00;
	USART_LOGIC_UNK6 = 0x00;
	ML_UNK3 = 0xff;
	USART_LOGIC_UNK3 = 0xff;
	INIT_ST2_UNK1 = 0xff;
	INIT_ST2_UNK2 = 0xff;
	ML_UNK2 = 0xff;
	SET(ENTRY_DATA_UNK1, 2);
	SET(SSP_PACKET_DATA_18_BITCOND, 7);
	USART_LOGIC_UNK27 = 0x00;
	USART_LOGIC_UNK28 = 0x00;
	USART_LOGIC_UNK29 = 0xd0;
	Caroline();

	if (Eloise() == 0x00)
	{
		SSP_PACKET_DATA_17_PARAM = PACKET_BUFFER[0] & 0x7f;
		SSP_PACKET_DATA_16_PARAM = PACKET_BUFFER[1] & 0x7f;
		SSP_PACKET_DATA_15_PARAM = PACKET_BUFFER[2] & 0x3f;
		if (!(PACKET_BUFFER[7] & 0x80))
			SET(SSP_PACKET_DATA_18_BITCOND, 6);
	}
	else
	{
		ELONA_UNK1 = 0x00;
		ELONA_UNK2 = 0x00;
		INIT_ST2_UNK3 = 0x00;
	}

	// These are hidden params for Cecile?
	SET(PACKET_BUFFER, 7);
	SSP_PACKET_DATA_12 = 0x00;
	SSP_PACKET_DATA_18_MASK = 0x00;
	SSP_PACKET_DATA_18_TMP = 0xd0;
	Cecile();

	// Wait some cpu cycles
	USART_LOGIC_UNK30 = 0x42;
	while (USART_LOGIC_UNK30 != 0) USART_LOGIC_UNK30 -= 1;

	// These are hidden params for Cecile?
	CLR(PACKET_BUFFER, 7);
	SSP_PACKET_DATA_12 = 0x00;
	SSP_PACKET_DATA_18_MASK = 0x00;
	SSP_PACKET_DATA_18_TMP = 0xd0;
	Cecile();

	return
}
