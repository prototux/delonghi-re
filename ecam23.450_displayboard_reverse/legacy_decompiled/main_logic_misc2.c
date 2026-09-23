// Seems like a big part of the main logic
// It is called (and check against) in most of
// the main logic switch cases
char Elona(void)
{
	if ((TIMER1_UNK5 | 0xde) != INIT_ST2_UNK3)
	{
		ENTRY_DATA_UNK2 = 0x32;
		INIT_ST2_UNK3 = TIMER1_UNK5 | 0xde;
	}


	if (!(USART_LOGIC_UNK9 & 0x40))
	{
		if ( !(USART_LOGIC_UNK9 & 0x02) || !(TIMER_UNK5 & 0x08) )
		{
			if (ENTRY_DATA_UNK1 & 0x40)
			{
				CLR(ENTRY_DATA_UNK1, 6);
				INIT_DATA_UNK2 = 0x32;
			}

			SET(USART_SSP_PACKET_STATUS, 7);
			ELONA_UNK1 = 0x16;
			ELONA_UNK2 = 0x17;
			return 0x01;
		}

		if ( (!(USART_LOGIC_UNK9 & 0x02) || !(TIMER_UNK5)) & 0x08
				&& ((TIMER_UNK4 & 0x3f) == 0x07) && !(USART_LOGIC_UNK6 & 0x1f) )
		{
			if ((TIMER1_UNK4 & 0x3f) == 0x07 && (!(USART_LOGIC_UNK6 & 0x1f) || !(ENTRY_DATA_UNK1 & 0x40)))
			{
				CLR(ENTRY_DATA_UNK1, 6);
				ENTRY_DATA_UNK2 = 0x32;
			}

			ELONA_UNK1 = 0x1c;
			ELONA_UNK2 = 0x1d;
			return 0x01;
		}

		// This probably contains mistakes!
		if (!(TIMER1_UNK5 & 0x10))
		{
			if ( !(USART_LOGIC_UNK9 = 0x01) || !(TIMER0_INT_UNK2 & 0x02) )
			{
				if ((TIMER1_UNK4 & 0x3f) != 0x2 )
				{
					USART_LOGIC_UNK4 = USART_LOGIC_UNK6 & 0x1f;
					if (0x5 < USART_LOGIC_UNK4 && (TIMER1_UNK4 & 0x3f) != 0x7)
					{
						USART_LOGIC_UNK5 = USART_LOGIC_UNK6 & 0x1f;
						if (0xf < USART_LOGIC_UNK5 || !(USART_LOGIC_UNK6 & 0x1f) && (TIMER1_UNK4 & 0x3f) != 0xb)
						{
							SSP_PACKET_DATA_12 = USART_LOGIC_UNK6 & 0x1f;
							if (0x5 < SSP_PACKET_DATA_12 && (TIMER1_UNK4 & 0x3f) != 0x8)
							{
								SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK6 & 0x1f;
								if (0x9 < SSP_PACKET_DATA_18_MASK && ((TIMER1_UNK4 & 0x3f) != 0x1 ||
											(USART_LOGIC_UNK6 & 0x1f) != 0x5))
								{
									if (!(ENTRY_DATA_UNK1 & 0x40))
									{
										CLR(ENTRY_DATA_UNK1, 6);
										ENTRY_DATA_UNK2 = 0x32;
									}
									ELONA_UNK1 = 0x1b;
								}
							}
						}
					}
				}
			}
			else
			{
				if ( !(USART_LOGIC_UNK9 & 0x20) && ((TIMER1_UNK4 & 0x3f) == 0x7) && !(USART_LOGIC_UNK6 & 0x1f) )
				{
					if ( (TIMER1_UNK4 & 0x3f) == 0x7 && (!(USART_LOGIC_UNK6 & 0x1f) || (ENTRY_DATA_UNK1 & 0x40)) )
					{
						CLR(ENTRY_DATA_UNK1, 6);
						ENTRY_DATA_UNK2 = 0x32;
					}

					if (!(USART_LOGIC_UNK7 & 0x70))
					{
						if (!ENTRY_DATA_UNK1 & 0x40)
						{
							CLR(ENTRY_DATA_UNK1, 6);
							ENTRY_DATA_UNK2 = 0x32;
						}

						SET(USART_SSP_PACKET_STATUS, 7);
						ELONA_UNK1 = 0x33;
						ELONA_UNK2 = 0x34;
						return 0x01;
					}

					ELONA_UNK1 = 0x35;
					ELONA_UNK2 = 0x36;
					return 0x01;
				}

				if ( ( !(USART_LOGIC_UNK10 & 0x20) || ((TIMER1_UNK4 & 0x3f) != 0x7)) || !(USART_LOGIC_UNK6 & 0x1f) )
				{
					if ( (!(USART_LOGIC_UNK9 & 0x10) || ((TIMER1_UNK4 & 0x3f) == 0x4) ) ||
								((TIMER1_UNK4 & 0x3f) == 0x3 || ((TIMER1_UNK4 & 0x3f) == 0x1)) )
					{
						if ( (( (!(USART_LOGIC_UNK9 & 0x4) || ((TIMER1_UNK4 & 0x3f) != 0x7)) ||
										(USART_LOGIC_UNK6 & 0x1f)) || (USART_LOGIC_UNK6 & 0x80)) &&
										!(USART_LOGIC_UNK9 & 0x8) )
						{

							if (USART-SSP_PACKET_STATUS & 0x80)
							{
								CLR(USART_SSP_PACKET_STATUS, 7);
								ENTRY_DATA_UNK2 = 0x32;
							}
							SET(ENTRY_DATA_UNK1 , 6);
						}

						return 0x00;
					}

					if (!(ENTRY_DATA_UNK1 & 0x40))
					{
						CLR(ENTRY_DATA_UNK1, 6);
						ENTRY_DATA_UNK2 = 0x32;
					}

					if (HW_INIT2_UNK7 < 0x1e)
					{
						SET(USART_SSP_PACKET_STATUS, 7);
						INIT_HW1_UNK6 = 0x01;
						SET(SSP_PACKET_DATA_18_BITCOND, 5);
						ELONA_UNK1 = 0x41;
						ELONA_UNK2 = 0x42;
						return 0x01;
					}

					SET(USART_SSP_PACKET_STATUS, 7);
					INIT_HW1_UNK6 = 0x01;
					SET(SSP_PACKET_DATA_18_BITCOND, 5);
					ELONA_UNK1 = 0x22;
					ELONA_UNK2 = 0x23;
					return 0x01;

					if (!(ENTRY_DATA_UNK & 0x40))
					{
						CLR(ENTRY_DATA_UNK1, 6);
						ENTRY_DATA_UNK2 = 0x32;
					}
					ELONA_UNK1 = 0x21;
				}
			}
		}
		else
		{
			if (!(ENTRY_DATA_UNK1 & 0x40))
			{
				CLR(ENTRY_DATA_UNK1, 6);
				ENTRY_DATA_UNK2 = 0x32;
			}
			ELONA_UNK1 = 0x15;
		}
		return 0x01;
	}


	if (!(USART_LOGIC_UNK9))
	{
		if (!(USART_LOGIC_UNK10 & 0x40))
			return 0x01;

		if (USART_LOGIC_UNK11 == 0x02)
		{
			if (!(ENTRY_DATA_UNK1 & 0x40))
			{
				CLR(ENTRY_DATA_UNK1, 6);
				ENTRY_DATA_UNK2 = 0x32;
			}

			if (USART_LOGIC_UNK12 == 0x04)
			{
				SET(USART_SSP_PACKET_STATUS, 7);
				ELONA_UNK1 = 0x1f;
				ELONA_UNK2 = 0x20;
				return 0x01;
			}
			ELONA_UNK1 = 0x19;
			return 0x01;
		}

		if (USART_LOGIC_UNK11 == 0x01)
		{
			if (!(ENTRY_DATA_UNK1 & 0x40))
			{
				CLR(ENTRY_DATA_UNK1, 6);
				ENTRY_DATA_UNK2 = 0x32;
			}


			if (USART_LOGIC_UNK12 == 0x05)
			{
				SET(USART_SSP_PACKET_STATUS, 7);
				ELONA_UNK1 = 0x1f;
				ELONA_UNK2 = 0x20;
				return 0x01;
			}

			if (!(SSP_PACKET_UNK1 & 0x03) || (SSP_PACKET_UNK1 & 0x04) || (USART_PSSP_PACKET_STATUS | 0x80) != 0x02)
			{
				INIT_HW1_UNK6 |= 0x03;
				SET(USART_SSP_PACKET_STATUS, 7);
				ELONA_UNK1 = 0xd9;
				return 0x01;
			}
			ELONA_UNK1 = 0x19;
			return 0x01;
		}
	}

	if (!(ENTRY_DATA_UNK1 & 0x40))
	{
		CLR(ENTRY_DATA_UNK1, 6);
		ENTRY_DATA_UNK2 = 0x32;
	}

	SET(USART_SSP_PACKET_STATUS, 7);
	ELONA_UNK1 = 0x1e;
	return 0x01;
}
