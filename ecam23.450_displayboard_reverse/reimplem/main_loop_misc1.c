// Need to understand what that does
void MAIN_LOOP_SUB1(void)
{
	CLR(ENTRY_DATA_UNK3, 2);
	CLR(ENTRY_DATA_UNK3, 3);
	CLR(ENTRY_DATA_UNK3, 4);
	CLR(INTCON, TMR0IE);

	if (ENTRY_DATA_UNK3 & 0x02)
	{
		if (ENTRY_DATA_UNK4 & 0x04)
			INIT_HW1_UNK7 = (~INIT_HW1_UNK8) & INIT_HW1_UNK6;
		else
			INIT_HW1_UNK7 = INIT_HW1_UNK6;

		CLR(ENTRY_DATA_UNK3, 1);
		SET(ENTRY_DATA_UNK3, 2);

		if (HW_INIT2_UNK4 && HW_INIT2_UNK4 == 0x01)
			SET(ENTRY_DATA_UNK3, 0);

		MLOOP_SUB1_UNK1 -= 1;
		if (MLOOP_SUB1_UNK1 == 0x00)
		{
			ENTRY_DATA_UNK4 ^= 0x40;
			MLOOP_SUB1_UNK1 = 0x32;

			if (ENTRY_DATA_UNK4 & 0x04)
				USART_LOGIC_UNK30 = 0x00;
			else
				USART_LOGIC_UNK30 = 0x01;
			USART_LOGIC_UNK30 <<= 2;

			ENTRY_DATA_UNK4 = ((ENTRY_DATA_UNK4 ^ USART_LOGIC_UNK30) & 0xfb) ^ USART_LOGIC_UNK30;
		}

		if (USART_LOGIC_UNK1)
			USART_LOGIC_UNK1 -= 1;

		if (SSP_TX_BUFFER_INDEX)
		{
			USART_TX_UNKNOWN -= 1;
			if (!USART_TX_UNKNOWN)
				CLR(USART_SSP_PACKET_STATUS, 2);
		}

		if (USART_RX_UNKNOWN)
		{
			USART_RX_UNKNOWN -= 1;
			if (!USART_RX_UNKNOWN)
				USART_RX_BUFFER_INDEX = 0x00;
		}

		if (ENTRY_DATA_UNK3 & 0x01)
		{
			if (SSP_PACKET_DATA_18_BITCOND & 0x04)
			{
				if (MLOOP_SUB1_UNK2 | MLOOP_SUB1_UNK1)
				{
					if (MLOOP_SUB1_UNK1)
						MLOO_SUB1_UNK2 -= 1;
					MLOOP_SUB1_UNK1 -=1;
				}
				else
				{
					SET(SSP_PACKET_DATA_18_BITCOND, 4);
					MLOOP_SUB1_UNK1 = 0x46;
					MLOOP_SUB1_UNK2 = 0x00;
				}
			}
			else
				CLR(SSP_PACKET_DATA_18_BITCOND, 4);
		}

		HW_INIT2_UNK2 -= 1;
		if (HW_INIT2_UNK2)
		{
			HW_INIT2_UNK2 = 0x0a;
			SET(ENTRY_DATA_UNK3, 3);

			if (MLOOP_SUB1_UNK3)
				MLOOP_SUB1_UNK3 -= 1;
			else
			{
				MLOOP_SUB1_UNK3 = 0x0f;
				if (ENTRY_DATA_UNK1 & 0x02)
					USART_LOGIC_UNK30 = 0x00;
				else
					USART_LOGIC_UNK30 = 0x01;

				USART_LOGIC_UNK30 >>= 1;

				ENTRY_DATA_UNK1 = ((USART_LOGIC_UNK1 ^ USART_LOGIC_UNK30) & 0xfd) ^ USART_LOGIC_UNK30;
			}

			if (ENTRY_DATA_UNK3 & 0x01)
			{
				if (HW_INIT2_UNK6)
					HW_INIT2_UNK6 -= 1;

				if (HW_INIT2_UNK7)
					HW_INIT2_UNK7 -= 1;

				if (USART_LOGIC_UNK25)
					USART_LOGIC_UNK25 -= 1;

				if (HW_INIT2_UNK8)
					HW_INIT2_UNK8 -= 1;

				if (HW_INIT2_UNK9)
					HW_INIT2_UNK9 -= 1;
			}

			HW_INIT2_UNK3 -= 3;
			if (!HW_INIT2_UNK3)
			{
				HW_INIT2_UNK3 = 0x0a;
				SET(ENTRY_DATA_UNK3, 4);

				if (ENTRY_DATA_UNK3 & 0x01)
				{
					USART_SSP_PACKET_STATUS ^= 0x40;

					if (ENTRY_DATA_UNK4 & 0x80)
					{
						if (ML_UNK4)
							ML_UNK4 -= 1;
						else
							ML_UNK4 = 0x0a;
					}

					if (USART_LOGIC_UNK4)
						USART_LOGIC_UNK4 -= 1;

					if (TIMER0_INT_UNK4 && TIMER0_INT_UNK2 & 0x10)
						TIMER0_INT_UNK4 -= 1;
					else
					{
						CLR(TIMER0_INT_UNK2, 4);
						SET(TIMER0_INT_UNK2, 5);
					}
				}
			}
		}
	}
	SET(INTCON, TMR0IE);
}
