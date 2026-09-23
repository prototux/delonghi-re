// Those are never called functions
// I don't know why this deadcode is here

// WARN: as those are deadcode, i didn't even bother trying decode them in details

// This looks awfully like delay_2ms
// this is probably another delay()
void deadcode_1(char param)
{
	USART_LOGIC_UNK30 = param_1;

	do
	{
    	USART_PACKET_CHECKSUM = 0x4;
		do
		{
			delay_2ms(0xfa);
			CLRWDT();
			USART_PACKET_CHECKSUM -= 0x1;
		} while (USART_PACKET_CHECKSUM != 0x0);
		USART_LOGIC_UNK30 -= 0x1;
	} while (USART_LOGIC_UNK30 != 0x0);
}

// This is another wait loop/delay
void deadcode_2(char param)
{
	USART_LOGIC_UNK30 = USART_PACKET_CHECKSUM;
	while (USART_LOGIC_UNK30 != 0x0)
	{
		// Wait inside the wait...
		USART_PACKET_CHECKSUM = 0xf6;
		do { USART_PACKET_CHECKSUM -= 0x1; } while (USART_PACKET_CHECKSUM != 0x0);
		CLRWDT();
		USART_LOGIC_UNK30 -= 0x1;
	}

	USART_PACKET_CHECKSUM = USART_LOGIC_UNK30;
	do { USART_PACKET_CHECKSUM -= 0x1; } while (USART_PACKET_CHECKSUM != 0x0);
}

// Another deadcode wait/delay function...
void deadcode_3(char param)
{
	register char tmp;

	do
  	{
		USART_LOGIC_UNK30 = 0x4;
		tmp = USART_LOGIC_UNK30;
		do
		{
			USART_LOGIC_UNK30 = bVar1;
			USART_PACKET_CHECKSUM = 0xfa;
			tmp = USART_PACKET_CHECKSUM;
			do
			{
				USART_PACKET_CHECKSUM = tmp;
				tmp = USART_PACKET_CHECKSUM - 0x1;
			} while (USART_PACKET_CHECKSUM - 0x1 != 0x0);
			CLRWDT();

			tmp = USART_LOGIC_UNK30 - 0x1;
		} while (USART_LOGIC_UNK30 - 0x1 != 0x0);

		USART_LOGIC_UNK30 -= 0x2;
		tmp = 0x0;
		if (true)
			tmp = USART_PACKET_CHECKSUM - 0x2;

		USART_PACKET_CHECKSUM = tmp;
		tmp = USART_PACKET_CHECKSUM | USART_LOGIC_UNK30;
	} while (tmp != 0x0);
}

