// This seems to send the string in BIGARRAY to LCD
// So this is pretty much the printstr()
void Emma(char param)
{
	USART_LOGIC_UNK5 = param;
	USART_LOGIC_UNK4 = 0x00;

	if (param < 0x14)
		SSP_PACKET_DATA_12 = 0x13;
	else
		SSP_PACKET_DATA_12 = 0x53;

	CHECKSUM_UNK1 = USART_LOGIC_UNK5 | 0x80; // = param
	Adele(0x01);

	SSP_PACKET_DATA_18_MASK = 0; // iterator
	do
	{
		// This needs a big double-check
		SSP_PACKET_DATA_18_TMP = USART_LOGIC_UNK5;
		INIT_ST1_UNK1 = 0x00;

		SSP_PACKET_DATA_18_TMP += SSP_PACKET_DATA_18_MASK;
		if (SSP_PACKET_DATA_18_TMP < SSP_PACKET_DATA_18_MASK) // we overflowed it
			INIT_ST1_UNK1 += 1;

		INIT_ST1_UNK2 = SSP_PACKET_DATA_12;
		INIT_ST1_UNK3 = 0x00;
		ENTRY_SUB2_UNK1 = INIT_ST1_UNK3 ^ 0x80; // what
		if (ENTRY_SUB2_UNK1 < INIT_ST1_UNK1 ^ 0x80)
			register char tmp = SSP_PACKET_DATA_18_TMP <= SSP_PACKET_DATA_12;

		// Send char to LCD?
		if (SSP_PACKET_DATA_18_TMP <= SSP_PACKET_DATA) // tmp
		{
			CHECKSUM_UNK1 = BIGARRAY[SSP_PACKET_DATA_18_MASK];
			Adele(0x00);
		}

		// Copy byte from BIGARRAY to LCDARRAY2
		SSP_PACKET_DATA_18_TMP = BIGARRAY[SSP_PACKET_DATA_18_MASK];
		LCDARRAY2[SSP_PACKET_DATA_18_MASK] = SSP_PACKET_DATA_18_TMP;

		SSP_PACKET_DATA_18_MASK += 1;
	} while SSP_PACKET_DATA_18_MASK < 0xa;
}

// This would probably send a string based on eeprom data
// so pretty much lcd_showstr_frome2p...
void Elodie(void)
{
}

// This also seems to send strings to the LCD?
void Emilie(void)
{
}
