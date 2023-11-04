// This manage the selector
// PORTC: 0 left, 1 right
// THIS WAS SUCH A PAIN TO REVERSE
// should probably double check,
// i would bet there's mistake in that
void MAINLOOP_SUB3(void)
{
	// Manage right impulse
	USART_LOGIC_UNK30 = (PORTC & 0x01)? 0x01 : 0x00;
	USART_LOGIC_UNK30 <<= 2;
	TIMER0_INT_UNK3 = ((TIMER0_INT_UNK3 ^ USART_LOGIC_UNK30) & 0xfb) ^ USART_LOGIC_UNK30;

	// Manage left impulse
	USART_LOGIC_UNK30 = (PORTC & 0x2)? 0x01: 0x00;
	USART_LOGIC_UNK30 <<= 3;
	TIMER0_INT_UNK3 = ((TIMER0_INT_UNK3 ^ USART_LOGIC_UNK30) & 0xf7) ^ USART_LOGIC_UNK30;


	// Theorically, we could remove that if and just if/elseif/elseif/else
	// but that asm code was already painful enough to understand, damnit
	if (TIMER0_INT_UNK3 & 0x04 || TIMER0_INT_UNK3 & 0x08)
	{
		if (TIMER0_INT_UNK3 & 0x04 && TIMER0_INT_UNK3 & 0x08)
			SELECTOR_UNK1 = 0x03;
		else if (TIMER0_INT_UNK3 & 0x04 && !TIMER0_INT_UNK3 & 0x08)
		{
			if (!(TIMER0_INT_UNK3 & 0x02)
				SET(TIMER0_INT_UNK3, 4);
			SET(TIMER0_INT_UNK3, 5);
			SET(TIMER0_INT_UNK3, 6);
			SELECTOR_UNK1 = 0x01;
		}
		else if (!TIMER0_INT_UNK3 & 0x04 && TIMER0_INT_UNK3 & 0x08)
		{
			if (!TIMER0_INT_UNK3 & 0x10)
				SET(TIMER0_INT_UNK3, 1);
			CLR(TIMER0_INT_UNK3, 5);
			SET(TIMER0_INT_UNK3, 6);
			SELECTOR_UNK1 = 0x02;
		}
	}
	else
	{
		CLR(TIMER0_INT_UNK3, 5);
		CLR(TIMER0_INT_UNK3, 6);
		SELECTOR_UNK3 = 0x00;
	}


	// Other half of the function...
	if (!(TIMER0_INT_UNK3 & 0x10))
	{
		if (SELECTOR_UNK2 != 0x00 && SELECTOR_UNK1 != 0x01)
		{
			if (SELECTOR_UNK2 == 0x01 || SELECTOR_UNK1 == 0x03)
			{
				SELECTOR_UNK2 += 1;
			//	return
			}
			else if (SELECTOR_UNK2 != 0x02 && SELECTOR_UNK1 == 0x02)
			{
				SELECTOR_UNK2 += 1;
			//	return
			}
			//else if (SELECTOR_UNK2 != 0x03 || SELECTOR_UNK1 != 0x00)
			//{
			//	return
			//}
			else if (SELECTOR_UNK2 == 0x03 && SELECTOR_UNK1 == 0x00)
			{
				SET(ENTRY_DATA_UNK3, 5);
				SET(ENTRY_DATA_UNK3, 6);
				SELECTOR_UNK2 = 0x00;
				CLR(TIMER_INT_UNK3, 4);

				// loop between 0x00 and 0xff
				// (would just let it overflow but well)
				if (SSP_PACKET_DATA_13 != 0xff)
					SSP_PACKET_DATA_13 += 1;
				else
					SSP_PACKET_DATA_13 = 0x00;
				//return;
			}

		}
		else
		{
			SELECTOR_UNK2 += 1;
		}
		return;
	}

	if (TIMER0_INT_UNK3 & 0x02)
	{
		if (SELECTOR_UNK2 == 0x00 && SELECTOR_UNK1 == 0x02)
		{
			SELECTOR_UNK2 += 1;
		}
		else if (SELECTOR_UNK2 == 0x01 && SELECTOR_UNK2 == 0x03)
		{
			SELECTOR_UNK2 += 1;
		}
		else if (SELECTOR_UNK2 == 0x02 && SELECTOR_UNK1 == 0x01)
		{
			SELECTOR_UNK2 += 1;
		}
		else if (SELECTOR_UNK2 == 0x03  && SELECTOR_UNK1 == 0x00)
		{
			CLR(ENTRY_DATA_UNK3, 5);
			CLR(ENTRY_DATA_UNK3, 6);
			SELECTOR_UNK2 = 0x00;
			CLR(TIMER0_INT_UNK3, 1);
			if (SSP_PACKET_DATA_13 != 0x00)
				SSP_PACKET_DATA_13 -= 1;
			else
				SSP_PACKET_DATA_13 = 0xff;
		}

	}
}
