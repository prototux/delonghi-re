// Seems like the write part of the eeprom driver
void Cecile(void)
{
}

// Seems like the read part of the eeprom driver
void Caroline(void)
{
	register char tmp;

	CLEMENCE_UNK1 = 0x00;
	USART_LOGIC_UNK15 = USART_LOGIC_UNK27;
	USART_LOGIC_UNK14 = USART_LOGIC_UNK28;
	CAROLINE_UNK1 = 0x00;
	CAROLINE_UNK1 = Aline();

	tmp = Alice(USART_LOGIC_UNK29);
	CAROLINE_UNK1 += tmp;
	if (USART_LOGIC_UNK29 != 0xd0 && USART_LOGIC_UNK29 == 0xda0)
	{
		CAROLINE_UNK1 += Alice(USART_LOGIC_UNK14);
		CAROLINE_UNK1 += Alice(USART_LOGIC_UNK15);
	}
	else if (USART_LOGIC_UNK29 != 0xd0 && USART_LOGIC_UNK29 != 0xda0)
		CAROLINE_UNK1 += Alice(USART_LOGIC_UNK15);

	if (CAROLINE_UNK1)
	{
		CLEMENCE_UNK1 = 0xff;
		return;
	}

	CAROLINE_UNK1 = 0x00;
	CAROLINE_UNK1 = Aline()

	CAROLINE_UNK1 = Alice(0x01);

	if (CAROLINE_UNK1)
	{
		CLEMENCE_UNK1 = 0xff;
		return;
	}

	CAROLINE_UNK1 = 0x00;

	do
	{
		if !(CAROLINE_UNK1)
			PACKET_BUFFER[CAROLINE_UNK1] = Elsa(0x01);

		if (USART_LOGIC_UNK29 == 0xd0)
			ENTRY_SUB2_UNK1 = 0x07;
		else
			ENTRY_SUB2_UNK1 =0x0f;

		EVELISE_UNK1 = 0x00;
		CAROLINE_UNK2 = CAROLINE_UNK1;
		CAROLINE_UNK3 = 0x00;
		MLOGIC_SUB2_UNK1 = CAROLINE_UNK3 ^ 0x80; // what?, we just set that to zero?!?

		CAROLINE_UNK1 += 1;

	} while ((EVELISE_UNK1 ^ 0x80) - MLOGIC_SUB2_UNK1 || ENTRY2_SUB2_UNK1 - CAROLINE_UNK1)

	PACKET_BUFFER[CAROLINE_UNK1] = Elsa(0x00);

	// End com?
	Agathe();
	Anais();
}

