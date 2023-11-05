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
		Anais();
		CLR(PORTB, 3);
		Anais();
		CLR(PORTB, 4);
		USART_LOGIC_30 += 1;
	} while (USART_LOGIC_30 < 0x9);

	// Init LCD, calls Agathe with whatever is in W, so 0x09?
	Agathe(0x09);

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
