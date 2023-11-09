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
	CLR(TIMER0_INT_UNK2, 2);

	if ((ML_UNK3 == ELONA_UNK1 && ML_UNK3 == INIT_ST2_UNK1) || ELODIE_UNK5)
	{
		if (USART_LOGIC_UNK6 == ELONA_UNK2 && USART_LOGIC_UNK3 == USART_ST2_UNK2 && !(SSP_PACKET_DATA_18_BITCOND))
		{
			if (ELODIE_UNK4)
				return;

			SET(TIMER0_INT_UNK2, 2);

			if (!ELODIE_UNK5)
			{
				if (!(SSP_PACKET_DATA_18_BITCOND & 0x08) && (INIT_ST2_UNK2 == ELONA_UNK2))
				{
					Clara(ELONA_UNK2);
					ELODIE_UNK3 = 0x00;
					MLOOP_SUB1_UNK1 = 0xc8;
					MLOOP_SUB1_UNK2 = 0x00;
				}
				ELONA_UNK2 = 0x32;
				HW_INIT2_UNK10 = 0x1e;
				INIT_ST1_UNK1 = 0x00;
				INIT_ST1_UNK1 += 1;
				Emilie(ELONA_UNK2);
				INIT_ST2_UNK2 = ELONA_UNK2;
			}

			CHECKSUM_UNK1 = (ELODIE_UNK2 + 0x40) | 0x80;

			Adele(0x01);

			USART_LOGIC_UNK4 = ELODIE_UNK2;


			do
			{
				USART_LOGIC_UNK5 = ELODIE_UNK2;
				SSP_PACKET_DATA_12 = 0x00;
				if (0x05 > USART_LOGIC_UNK5)
					SSP_PACKET_DATA_12 += 1;

				SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK4;
				SSP_PACKET_DATA_18_TMP = 0x00;
				ENTRY_SUB2_UNK1 = SSP_PACKET_DATA_18_TMP | 0x80;
				if ((SSP_PACKET_DATA_12 | 0x80) < 0x81 ||
						( (SSP_PACKET_DATA_12 | 0x80) && USART_LOGIC_UNK5 <= SSP_PACKET_DATA_18_MASK))
					break;

				CHECKSUM_UNK1 = EMILIE_ARRAY[USART_LOGIC_UNK4];

				Adele(0x00);
				USART_LOGIC_UNK1 += 1;
			} while (true);

			ELODIE_UNK5 += 1;
			ELODIE_UNK2 += 5;
			if (0x03 < ELODIE_UNK5)
			{
				ELODIE_UNK5 = 0x00;
				ELODIE_UNK2 = 0x00;
				USART_LOGIC_UNK3 = INIT_ST2_UNK2;
				CLR(SSP_PACKET_DATA_18_BITCOND, 4);
			}
		}
	}
	else
	{
		SET(TIMER0_INT_UNK2, 2);
		if (!ELODIE_UNK4)
		{
			INIT_ST1_UNK1 = 0x00;
			Emilie(ELONA_UNK1);
			INIT_ST2_UNK1 = ELONA_UNK1;
		}

		CHECKSUM_UNK1 = ELODIE_UNK1 | 0x80;

		Adele(0x01);

		USART_LOGIC_UNK4 = ELODIE_UNK1;

		do
		{
			USART_LOGIC_UNK5 = ELODIE_UNK1;
			SSP_PACKET_DATA_12 = 0x00;
			USART_LOGIC_UNK5 += 0x05;
			if (USART_LOGIC_UNK5 < 0x05) // we overflowed it?
				SSP_PACKET_DATA_12 += 1;

			SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK4;

			SSP_PACKT_DATA_18_TMP = 0x00;
			ENTRY_SUB2_UNK1 = SSP_PACKET_DATA_18_TMP | 0x80;

			if ((SSP_PACKET_DATA_12 | 0x80) < 0x81 ||
					( (SSP_PACKET_DATA_12 | 0x80) && USART_LOGIC_UNK5 <= SSP_PACKET_DATA_18_MASK))
				break;

			CHECKSUM_UNK1 = EMILIE_ARRAY[USART_LOGIC_UNK4];

			Adele(0x00);

			USART_LOGIC_UNK4 += 1;
		} while (true);

		ELODIE_UNK4 += 1;
		ELODIE_UNK1 += 5;
		if (0x03 < ELODIE_UNK4)
		{
			ELODIE_UNK4 = 0x00;
			ELODIE_UNK1 = 0x00;
			ML_UNK3 = INIT_ST2_UNK1;
		}
	}
}

// This also seems to send strings to the LCD?
void Emilie(char param)
{
	INIT_ST1_UNK2 = param;

	if (INIT_ST1_UNK2 < 0xc8)
	{
		if (!(SSP_PACKET_DATA_BITCOND & 0x08) || (INIT_ST1_UNK2 != 0x01))
		{
			MLOGIC_SUB2_UNK1 = 0x64;
			MLOGIC_SUB2_UNK2 = 0x00;

			ENTRY_SUB2_UNK1 = PUSH_UNK1;

			EVELISE_UNK1 = 0x00;
			Estelle();

			ENTRY_SUB2_UNK1 = INIT_ST1_UNK2;
			EVELISE_UNK1 = 0x00;
			ENTRY_SUB2_UNK1 += ESTELLE_UNK1;

			if (ENTRY_SUB2_UNK1 < ESTELLE_UNK1) // we overflowed
				EVELISE_UNK1 += 1;

			EVELISE_UNK1 += ESTELLE_UNK2;
			MLOGIC_SUB2_UNK1 = 0x14;
			MLOGIC_SUB2_UNK2 = 0x00;
			Estelle();

			ESTELLE_UNK1 += 0x14;
			if (ESTELLE_UNK1 < 0x14) // we overflowed
				ESTELLE_UNK2 += 1;

			CLARA_UNK5 = ESTELLE_UNK1;
			CLARA_UNK6 = ESTELLE_UNK2;
			CLARA_UNK3 = CLARA_UNK5 & 0xf0;
			CLARA_UNK4 = CLARA_UNK6 & 0xff;
			CLARA_UNK1 = CLARA_UNK5 & 0x0f;
			USART_LOGIC_UNK27 = CLARA_UNK3;
			USART_LOGIC_UNK28 = CLARA_UNK4;
			USART_LOGIC_UNK29 = 0xa0;
			Caroline();

			CHECKSUM = 0x00;
			do
			{
				// TODO: finish
			} while (turue);
		}
	}
}
