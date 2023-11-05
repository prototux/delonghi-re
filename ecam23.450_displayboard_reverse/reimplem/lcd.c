// Main i2c driver

// Seems to be an init function?
// Is called in main with 0x00 but also in MAINLOOP_MAIN_LOGIC/BGT4-ret, with 0xff
void Emy(char param)
{
	// Param == "do we need to reset the LCD" apparently
	USART_LOGIC_UNK4 = param;
	if (!USART_LOGIC_UNK4)
	{
		SET(PORTB, 2); // reset the LCD
		SSP_PACKET_DATA_12 = 0x64;

		// This waits for 0x64 cpu clocks apparently
		do { SSP_PACKET_DATA_12 -= 1; } while (SSP_PACKET_DATA_12);

		CLR(PORTB, 2);
		delay_2ms(1);
		SET(PORTB, 2);
		delay_2ms(28);
	}

	CHECKSUM_UNK1 = 0x38;
	Adele(0x01);

	// Send the first init string
	// should be 0x1f, 0x1f, 0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00
	USART_LOGIC_UNK5 = 0x00;
	do {
		CHECKSUM_UNK1 = USART_LOGIC_UNK5 | 0x40;
		Adele(0x01);

		SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK5;
		SSP_PACKET_DATA_18_TMP = 0x00;

		// This will fetch const data
		// Will actually fetch CONST_LCD_UNKNOWN1, the init data
		register tmp = USART_LOGIC_UNK5;
		FETCH_ADDR_H = 0x1a;
		if (USART_LOGIC_UNK5 > 0xc9)
			FETCH_ADDR_H += 1;
		CHECKSUM_UNK1 = fetch_data_withparam(USART_LOGIC_UNK5 + 0x36);

		// Send it (CHECKSUM_UNK1 is hidden param of adele)
		Adele(0x00);

		USART_LOGIC_UNK5 += 1;
	} while (USART_LOGIC_UNK5 < 0x08);

	// Send the second init string
	// should be 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
	USART_LOGIC_UNK5 = 0x00;
	do {
		CHECKSUM_UNK1 = USART_LOGIC_UNK5 + 0x08 | 0x40;
		Adele(0x01);

		SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK5;
		SSP_PACKET_DATA_18_TMP = 0x00;

		// This will fetch const data
		// Will actually fetch CONST_LCD_UNKNOWN1, the init data
		register tmp = USART_LOGIC_UNK5;
		FETCH_ADDR_H = 0x1a;
		if (USART_LOGIC_UNK5 > 0xc0)
			FETCH_ADDR_H += 1;
		CHECKSUM_UNK1 = fetch_data_withparam(USART_LOGIC_UNK5 + 0x3f);

		// Send it (CHECKSUM_UNK1 is hidden param of adele)
		Adele(0x00);

		USART_LOGIC_UNK5 += 1;
	} while (USART_LOGIC_UNK5 < 0x08);

	// Send the third init string
	// should be 0x08, 0x1c, 0x08, 0x09, 0x06, 0x08, 0x04, 0x00
	USART_LOGIC_UNK5 = 0x00;
	do {
		CHECKSUM_UNK1 = USART_LOGIC_UNK5 + 0x10 | 0x40;
		Adele(0x01);

		SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK5;
		SSP_PACKET_DATA_18_TMP = 0x00;

		// This will fetch const data
		// Will actually fetch CONST_LCD_UNKNOWN1, the init data
		register tmp = USART_LOGIC_UNK5;
		FETCH_ADDR_H = 0x1a;
		if (USART_LOGIC_UNK5 > 0xc0)
			FETCH_ADDR_H += 1;
		CHECKSUM_UNK1 = fetch_data_withparam(USART_LOGIC_UNK5 + 0x48);

		// Send it (CHECKSUM_UNK1 is hidden param of adele)
		Adele(0x00);

		USART_LOGIC_UNK5 += 1;
	} while (USART_LOGIC_UNK5 < 0x08);

	// Send the third init string, again
	// should be 0x08, 0x1c, 0x08, 0x09, 0x06, 0x08, 0x04, 0x00
	USART_LOGIC_UNK5 = 0x00;
	do {
		CHECKSUM_UNK1 = USART_LOGIC_UNK5 + 0x18 | 0x40;
		Adele(0x01);

		SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK5;
		SSP_PACKET_DATA_18_TMP = 0x00;

		// This will fetch const data
		// Will actually fetch CONST_LCD_UNKNOWN1, the init data
		register tmp = USART_LOGIC_UNK5;
		FETCH_ADDR_H = 0x1a;
		if (USART_LOGIC_UNK5 > 0xc0)
			FETCH_ADDR_H += 1;
		CHECKSUM_UNK1 = fetch_data_withparam(USART_LOGIC_UNK5 + 0x48);

		// Send it (CHECKSUM_UNK1 is hidden param of adele)
		Adele(0x00);

		USART_LOGIC_UNK5 += 1;
	} while (USART_LOGIC_UNK5 < 0x08);

	// Send other things
	CHECKSUM_UNK1 = 0x39; Adele(0x01);
	CHECKSUM_UNK1 = 0x1c; Adele(0x01);
	CHECKSUM_UNK1 = 0x5f; Adele(0x01);
	CHECKSUM_UNK1 = 0x0c; Adele(0x01);
	CHECKSUM_UNK1 = 0x06; Adele(0x01);
	if (USART_LOGIC_UNK4) // param
		return;
	CHECKSUM_UNK1 = 0x01; Adele(0x01);
	CHECKSUM_UNK1 = 0x01; Adele(0x01);
}


// This is what sends data to the LCD
// hidden param: CHECKSUM_UNK1
void Adele(char param)
{
	CHECKSUM_UNK2 = param;

	ADELE_UNK1 = Aline(); // maybe Aline(param)?
	ADELE_UNK1 = Alice(0x78);

	if (CHECKSUM_UNK2 == 0x01)
		ADELE_UNK1 = Alice(0x80);

	if (CHECKSUM_UNK2 == 0x00)
	{
		ADELE_UNK1 = 0x00;
		ADELE_UNK1 = Alice(0x40);
	}

	Alice(CHECKSUM_UNK1);

	Agathe();
}
