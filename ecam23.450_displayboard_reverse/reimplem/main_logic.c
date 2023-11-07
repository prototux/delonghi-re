// This is the big, scary one...
void MAINLOOP_MAIN_LOGIC(void)
{
	register char tmp;

	// Init some vars
	ELONA_UNK1 = 0xc8;
	ELONA_UNK2 = 0xc8;
	CLR(SSP_PACKET_DATA_18_BITCOND, 3);
	CLR(SSP_PACKET_DATA_18_BITCOND, 5);
	CLR(ENTRY_DATA_UNK4, 7);
	MLOGIC_SUB2_UNK3 = 0x45;

	if (USART_LOGIC_UNK26)
	{
		if (SSP_PACKET_DATA_18_BITCOND & 0x80)
			goto main_logic_ret;

		CLR(ENTRY_DATA_UNK3, 7);
		CLR(ENTRY_DATA_UNK1, 5);
		INIT_HW1_UNK6 = 0x00;
		INIT_HW1_UNK8 = 0x00;
		goto main_logic_jumper;
	}
	else
	{
		ELONA_UNK1 = 0xd7;
		goto main_logic_ret;
	}
	// Here we either have jumped to the goto table or got to the return/end code

	// Big goto subroutines here (ML4 isn't missing, it's the ret)

ML_10:
	if (Elona() && (USART_LOGIC_UNK6 & 0x40))
		goto main_logic_ret;

	CLR(TIMER0_INT_UNK2, 1);

	if (USART_LOGIC_UNK6 & 0x1f || (USART_LOGIC_UNK6 & 0x1f) != 0x01)
	{
		ELONA_UNK1 = 0x38;
		ELONA_UNK1 = 0x39;
		INIT_HW1_UNK6 = 0x01;
		goto main_logic_ret;
	}

	if (USART_LOGIC_UNK6 & 0x1f == 0x02)
		ELONA_UNK1 = 0x3a;
	goto main_logic_ret;

ML_11:
	if (Elona() != 0x00)
		goto main_logic_ret;

	CLR(TIMER0_INT_UNK2, 1);

	MLOGIC_SUB2_UNK1 = USART_LOGIC_UNK6 & 0x1f;
	MLOGIC_SUB2_UNK2 = 0x00;

	if (MLOGIC_SUB2_UNK2 == 0x00) // but this is always true?!?
		goto main_logic_ret;

	tmp = MLOGIC_SUB2_UNK1 ^ 0x00
	if (tmp)
	{
		ELONA_UNK1 = 0x19;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (tmp)
	{
		tmp ^= 0x03
		if (tmp)
			goto main_logic_ret;

		ELONA_UNK1 = 0x19;
		goto main_logic_ret;
	}

	if (!(TIMER1_UNK5 & 0x20))
	{
		ELONA_UNK1 = 0x2d
		ELONA_UNK2 = 0x2e;
		INIT_HW1_UNK6 = 0x01;
		goto main_logic_ret
	}

	ELONA_UNK1 = 0x14;
	ELONA_UNK2 = 0x44;
	INIT_HW1_UNK6 = 0x01;
	goto main_logic_ret;

ML_12:
	CLR(TIMER0_INT_UNK2, 1);
	MLOGIC_SUB2_UNK1 = USART_LOGIC_UNK6 & 0x1f;
	MLOGIC_SUB2_UNK2 = 0x00;

	tmp = MLOGIC_SUB2_UNK2 ^ 0x00;
	if (tmp)
		goto main_logic_ret;

	tmp = MLOGIC_SUB2_UNK1 ^ 0x00
	if (!tmp) // always true?!?
	{
		ELONA_UNK1 = 0x19;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		ELONA_UNK1 = 0x18;
		goto main_logic_ret;
	}

	tmp ^= 0x03;
	if (!tmp)
	{
		ELONA_UNK1 = 0x19;
		goto main_logic_ret;
	}

	goto main_logic_ret;

ML_1:
	CLR(TIMER0_INT_UNK2, 1);
	SET(ENTRY_DATA_UNK4, 7);

	if (!ML_UNK4)
		CLR(ENTRY_DATA_UNK4, 4);

	if (TIMER1_UNK5 & 0x08)
	{
		ML_UNK4 = 0x0a;
		SET(ENTRY_DATA_UNK4, 4);
		ELONA_UNK1 = 0x16;
		ELONA_UNK2 = 0x17;
		goto main_logic_ret;
	}

	if (TIMER1_UNK5 & 0x10)
	{
		ML_UNK4 = 0x0a;
		SET(ENTRY_DATA_UNK4, 4);
		ELONA_UNK1 = 0x15;
		goto main_logic_ret;
	}

	if (SSP_PACKET_DATA_18_BITCOND & 0x40 && SSP_PACKET_DATA_18)
	{
		ML_UNK4 = 0x0a;
		SET(ENTRY_DATA_UNK4, 4);
		goto main_logic_ret;
	}

	USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
	if (USART_LOGIC_UNK2 < 0x02)
	{
		if (Elona() != 0x00)
			goto main_logic_ret;
		ELONA_UNK1 = 0x13;
		INIT_HW1_UNK6 = 0xff;
		goto main_logic_ret;
	}

	if (SSP_PACKET_DATA_18_BITCOND & 0x40)
	{
		MLOGIC_SUB2_UNK7 = SSP_PACKET_DATA_15_PARAM;
		MLOGIC_SUB2_UNK6 = SSP_PACKET_DATA_16_PARAM;
		MAINLOOP_MAIN_LOGIC_SUB1(0x01);
		SET(MLOGIC_SUB2_UNK6, 7);
		if (HW_INIT2_UNK1 & 0x02)
		{
			MLOGIC_SUB2_UNK3 = 0x07;
			goto main_logic_ret;
		}
		else
		{
			MLOGIC_SUB2_UNK3 = 0x06;
			goto main_logic_ret;
		}
	}

ML_2:
	if (Elona() != 0x00)
		goto main_logic_ret;

	if (TIMER1_UNK6 & 0x3f == 0x08)
	{
		SET(TIMER0_INT_UNK2, 1);
		USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
		// 0x1a;
		if (0x05 < USART_LOGIC_UNK2)
		{
			ELONA_UNK1 = 0x1a;
			ELONA_UNK2 = 0x19;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0x1a;
			SET(ENTRY_DATA_UNK1, 5);
			goto main_logic_ret;
		}
	}

	USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
	if (0x08 < USART_LOGIC_UNK2)
		SET(TIMER0_INT_UNK2, 1);
	else
		CLR(TIMER0_INT_UNK2, 1);

	CLR(SSP_PACKET_DATA_18_BITCOND, 2);

	if ((USART_LOGIC_UNK6 & 0x1f) == 0x05)
		SET(SSP_PACKET_DATA_18_BITCOND, 2);

	if (!(SSP_PACKAT_DATA_18_BITCOND & 0x04))
	{
		SET(ENTRY_DATA_UNK1, 5)
		ELONA_UNK1 = 0x1a;
		goto main_logic_ret;
	}
	else
	{
		ELONA_UNK1 = 0x18;
		ELONA_UNK2 = 0x19;
		goto main_logic_ret;
	}

ML_3:
	if (Elona() != 0x00)
		goto main_logic_ret;
	SET(TIMER0_INT_UNK2, 1);
	ELONA_UNK1 = 0x2c;
	ELONA_UNK2 = 0x19;
	goto main_logic_ret;

ML_6:
	if (Elona() != 0x00)
		goto main_logic_ret;



ML_5:
	if (Elona() != 0x00)
		goto main_logic_ret;

	SET(TIMER0_INT_UNK2, 1);

	if (!(TIMER1_UNK5 & 0x01))
	{
		ELONA_UNK1 = 0x2d;
		ELONA_UNK2 = 0x1e;
		goto main_logic_ret;
	}
	// else...

	MLOGIC_SUB2_UNK1 = USART_LOGIC_UNK6 & 0x01;
	MLOGIC_SUB2_UNK2 = 0x00;
	if (MLOGIC_SUB_2_UNK2 != 0x00) // always false...
		goto main_logic_ret;

	tmp = MLOGIC_SUB2_UNK1;

	tmp ^= 0x00;
	if (!tmp)
	{
		ELONA_UNK1 = 0x19;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		if (USART_LOGIC_UNK7 & 0x08)
		{
			ELONA_UNK1 = 0x26;
			ELONA_UNK2 = 0x27;
			goto main_logic_ret;
		}

		SET(SSP_PACKET_DATA_18_BITCOND, 5);

		if (0x1e < HW_INIT2_UNK7)
		{
			ELONA_UNK1 = 0x25;
			ELONA_UNK2 = 0x44;
			INIT_HW1_UNK6 = 0x01;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0x00;
			ELONA_UNK1 += 1;
			ELONA_UNK2 = 0x50;
			INIT_HW1_UNK6 = 0x01;
			goto main_logic_ret;
		}
	}

	tmp ^= 0x03;
	if (!tmp)
	{
		ELONA_UNK1 = 0x26;
		ELINA_UNK2 = 0x27;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		if (USART_LOGIC_UNK7 & 0x08)
		{
			ELONA_UNK1 = 0x26;
			ELONA_UNK2 = 0x27;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0x1a;
			ELONA_UNK2 = 0x44; // WHY?!?
			ELONA_UNK2 = 0x1b;
		}
	}

	tmp ^= 0x07;
	if (!tmp)
	{
		if (USART_LOGIC_UNK7 & 0x08)
		{
			ELONA_UNK1 = 0x1a;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0x1a;
			ELONA_UNK2 = 0x44;
			INIT_HW1_UNK6 = 0x01;
			goto main_logic_ret;
		}
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		ELONA_UNK1 = 0x29;
		ELONA_UNK2 = 0x44;
		INIT_HW1_UNK6 = 0x01;
		goto main_logic_ret;
	}

	goto main_logic_ret;

ML_7:
	if (Elona() != 0x00)
		goto main_logic_ret;

	SET(TIMER0_INT_UNK2, 1);

	if (!(USART_LOGIC_UNK6 & 0x1f))
	{
		if (!(USART_LOGIC_UNK8 & 0x20))
		{
			ELONA_UNK1 = 0x18;
			ELONA_UNK2 = 0x19;
			goto main_logic_ret;
		}

		ELONA_UNK1 = 0x3d;
		ELONA_UNK2 = 0x3e;
		goto main_logic_ret;
	}

	if (USART_LOGIC_UNK6 & 0x1f == 0x01)
	{
		if (USART_LOGIC_UNK6 & 0x40)
		{
			ELONA_UNK1 = 0x3b;
			ELONA_UNK2 = 0x4a;
			SET(SSP_PACKET_DATA_18_BITCOND, 3);
			USART_LOGIC_UNK2 = 0x28;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK3 = 0x2b;
			ELONA_UNK2 = 0x4a;
			SET(SSP_PACKET_DATA_18_BITCOND, 3);
			USART_LOGIC_UNK2 = 0x28;
			goto main_logic_ret;
		}
	}

	// It is strange that it isn't checking against UNK6
	// but i've double checked it...
	if (USART_LOGIC_UNK7 & 0x80)
	{
		ELONA_UNK1 = 0x3f;
		ELONA_UNK2 = 0x12;
		CLR(ENTRY_DATA_UNK1, 5);
		goto main_logic_ret;
	}

	if (USART_LOGIC_UNK6 & 0x40)
	{
		ELONA_UNK1 = 0x3b;
		SET(ENTRY_DATA_UNK1, 5);
		USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
		// why it does it again?
		if (0x02 < USART_LOGIC_UNK2)
		{
			SET(ENTRY_DATA_UNK1, 5);
			goto main_logic_ret;
		}
		else
			goto main_logic_ret;
	}
	else
	{
		ELONA_UNK1 = 0x3b;
		SET(ENTRY_DATA_UNK1, 5);
		USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
		// why it does it again?
		if (0x02 < USART_LOGIC_UNK2)
		{
			SET(ENTRY_DATA_UNK1, 5);
			goto main_logic_ret;
		}
		else
			goto main_logic_ret;
	}

ML_8:
	if (Elona() != 0x00)
		goto main_logic_ret;

	CLR(TIMER0_INT_UNK2, 1);

	if (!(USART_LOGIC_UNK6 & 0x1f))
	{
		if (TIMER1_UNK5 & 0x01)
		{
			ELONA_UNK2 = 0x19;
			ELONA_UNK1 = 0x18;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0x2d;
			ELONA_UNK2 = 0x2e;
			goto main_logic_ret;
		}
	}

	if (USART_LOGIC_UNK6 & 0x1f == 0x01)
	{
		ELONA_UNK1 = 0x14;
		ELONA_UNK2 = 0x4a;
		SET(SSP_PACKET_DATA_18_BITCOND, 3);
		USART_LOGIC_UNK2 = 0x28;
		goto main_logic_ret;
	}
	else
	{
		SET(ENTRY_DATA_UNK1, 5);
		ELONA_UNK1 = 0x14;
		if (!(USART_LOGIC_UNK7 & 0x80))
			goto main_logic_ret;

		ELONA_UNK2 = 0x12;
		CLR(ENTRY_DATA_UNK1, 5);
		goto main_logic_ret;
	}

ML_9:
	if (Elona() | 0x00)
		goto main_logic_ret;

	SET(TIMER0_INT_UNK2, 1);

	if (USART_LOGIC_UNK6 & 0x1f != 0x01)
	{
		ELONA_UNK1 = 0x18;
		ELONA_UNK2 = 0x19;
		goto main_logic_ret;
	}
	else
	{
		ELONA_UNK1 = 0x2f;
		SET(ENTRY_DATA_UNK1, 5);
		goto main_logic_ret;
	}

ML_13: // This only calls SUB2
	MAINLOOP_MAIN_LOGIC_SUB2();
	goto main_logic_ret;

ML_14:
	if (USART_LOGIC_UNK7)
	{
		INIT_HW1_UNK6 = 0xff;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}

	if (SSP_PACKET_DATA_18)
	{
		ELONA_UNK1 = 0xc9;
		SET(ENTRY_DATA_UNK3, 7);
		if (ENTRY_DATA_UNK3 & 0x40)
		{
			CLR(ENTRY_DATA_UNK6 , 6);
			USART_LOGIC_UNK13 += 0xf6;
			if (USART_LOGIC_UNK13 < 0x0a)
				USART_LOGIC_UNK13 = 0x00;
		}
		else if (ENTRY_DATA_UNK3 & 0x20)
		{
			USART_LOGIC_UNK13 += 0x0a;
			if (USART_LOGIC_UNK13 < 0x65)
				USART_LOGIC_UNK13 = 0x64;
		}
		else
			goto main_logic_ret;

		SET(ENTRY_DATA_UNK1, 5);
		goto main_logic_ret;
	}

	// Reset LCD string
	USART_PACKET_CHECKSUM = 0x00;
	do
	{
		BIGARRAY[USART_PACKET_CHECKSUM] = 0x20;
		USART_PACKET_CHECKSUM += 1;
	} while (USART_PACKET_CHECKSUM < 0x0a);

	ELONA_UNK2 = 0xca;
	SET(ENTRY_DATA_UNK3, 7);
	MLOGIC_SUB2_UNK3 = 0x47;
	if (SSP_PACKET_UNK1 & 0x01)
	{
		BIGARRAY[1] = 0x31;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x02)
	{
		BIGARRAY[1] = 0x32;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x04)
	{
		BIGARRAY[1] = 0x33;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x20)
	{
		BIGARRAY[1] = 0x34;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x10)
	{
		BIGARRAY[1] = 0x35;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x08)
	{
		BIGARRAY[1] = 0x36;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x80)
	{
		BIGARRAY[1] = 0x37;
		goto main_logic_ret;
	}
	else if (SSP_PACKET_UNK1 & 0x40)
	{
		BIGARRAY[1] = 0x38;
		goto main_logic_ret;
	}
	goto main_logic_ret;

ML_15:
	if ((TIMER1_UNK5 & 0xde) == CECILE_UNK1)
	{
		ENTRY_DATA_UNK2 = 0x32;
		CECILE_UNK1 = TIMER1_UNK5 | 0xde;
	}

	if (USART_LOGIC_UNK7)
	{
		ELONA_UNK1 = USART_LOGIC_UNK7;
		ELONA_UNK2 = USART_LOGIC_UNK7;
		goto main_logic_ret;
	}

	if (USART_LOGIC_UNK6 < 0x03)
	{
		ELONA_UNK1 = 0xcb;
		goto main_logic_ret;
	}
	else if (USART_LOGIC_UNK6 == 0x03)
	{
		if (SSP_PACKET_UNK1 & 0x02 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd2;
			ELONA_UNK2 = 0xd2;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x04 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd3;
			ELONA_UNK2 = 0xd3;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x08 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd3;
			ELONA_UNK2 = 0xd3;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x10 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd5;
			ELONA_UNK2 = 0xd5;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x80 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd6;
			ELONA_UNK2 = 0xd6;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x20 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd0;
			ELONA_UNK2 = 0xd0;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x01 && SSP_PACKET_DATA_18 == 0x01)
		{
			ELONA_UNK1 = 0xd5;
			ELONA_UNK2 = 0xd6;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0xcb;
			goto main_logic_ret;
		}
	}

	else if (USART_LOGIC_UNK6 == 0x04)
	{
		if (TIMER1_UNK5 & 0x02)
		{
			ELONA_UNK1 = 0xcc;
			goto main_logic_ret;
		}
		else if (TIMER1_UNK5 & 0x04)
		{
			ELONA_UNK1 = 0xcd;
			goto main_logic_ret;
		}
		else if (!(SSP_PACKET_UNK1 & 0x10))
		{
			ELONA_UNK1 = 0xcb;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_DATA_18 = 0x01)
		{
			ELONA_UNK1 = 0xcf;
			goto main_logic_ret;
		}
		else
		{
			ELONA_UNK1 = 0xcb;
			goto main_logic_ret;
		}
	}

	else if (USART_LOGIC_UNK6 == 0x05)
	{
		if (TIMER1_UNK5 & 0x02)
		{
			ELONA_UNK1 = 0xcc;
			goto main_logic_ret;
		}
		else if (TIMER1_UNK5 & 0x04)
		{
			ELONA_UNK1 = 0xcd;
			goto main_logic_ret;
		}
		else if (SSP_PACKET_UNK1 & 0x10)
		{
			if (SSP_PACKET_DATA_18 = 0x01)
			{
				ELONA_UNK1 = 0xce;
				goto main_logc_ret;
			}
			else
			{
				ELONA_UNK1 = 0xcb;
				goto main_logic_ret;
			}
		}
		else
		{
			ELONA_UNK1 = 0xcb;
			goto main_logic_ret;
		}
	}

	else if (USART_LOGIC_UNK6 == 0x06)
	{
		ELONA_UNK1 = 0xd0;
		goto main_logic_ret;
	}

	goto main_logic_ret;

ML_17:
	ELONA_UNK1 = 0xd1;
	goto main_logic_ret;

ML_16:
	CLR(ENTRY_DATA_UNK4, 4);

	tmp = USART_LOGIC_UNK7;

	tmp ^= 0x0;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0x00;

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0x1;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0x01;

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0x3;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0x02;

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;

	}
	tmp ^= 0x1;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0x00;

		SET(ENTRY_DATA_UNK4, 4);

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0x7;
	if (!tmp)
	{
		CLR(PORTA, 7); // turn off the cup light

		CLR(ENTRY_DATA_UNK4, 4);

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0x1;
	if (!tmp)
	{
		SET(ENTRY_DATA_UNK4, 4);
		ELONA_UNK1 = 0xdd;
		ELONA_UNK2 = 0xdd;

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0x3;
	if (!tmp)
	{
		SET(ENTRY_DATA_UNK4, 4);
		ELONA_UNK1 = 0xdc;
		ELONA_UNK2 = 0xdc;

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}
	tmp ^= 0xf9;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0xff;
		SET(ENTRY_DATA_UNK4, 4);

		if (!(USART_LOGIC_UNK7 & 0x02))
			goto main_logic_ret;

		ELONA_UNK1 = 0xdb;
		ELONA_UNK2 = 0xdb;
		goto main_logic_ret;
	}

	if (!(USART_LOGIC_UNK7 & 0x02))
		goto main_logic_ret;

	ELONA_UNK1 = 0xdb;
	ELONA_UNK2 = 0xdb;
	goto main_logic_ret;

ML_18:
	ELONA_UNK1 = 0xda;
	INIT_HW1_UNK6 |= 0x03;

	USART_PACKET_CHECKSUM = 0x00;
	do
	{
		BIGARRAY[USART_PACKET_CHECKSUM] = 0x20;
	} while (USART_PACKET_CHECKSUM < 0x0a);

	tmp = USART_LOGIC_UNK6 ^ 0x00;
	if (!tmp)
	{
		if (!TIMER2_UNK2 & 0x10)
			goto main_logic_ret;

		BIGARRAY[1] = 0x2a;
		SET(ENTRY_DATA_UNK3, 7);
		MLOGIC_SUB2_UNK3 = 0x48;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		BIGARRAY[1] = 0x2a;
		SET(ENTRY_DATA_UNK3, 7);
		LOGIC_SUB2_UNK3 = 0x48;
		goto main_logic_ret;
	}

	tmp ^= 0x03;
	if (!tmp)
	{
		BIGARRAY[1] = 0x20;
		SET(ENTRY_DATA_UNK3, 7);
		LOGIC_SUB2_UNK3 = 0x48;
		goto main_logic_ret;
	}

	tmp ^= 0x01;
	if (!tmp)
	{
		INIT_HW1_UNK6 = 0x00;
		ELONA_UNK1 = 0xc8;
		ELONA_UNK2 = 0xc8;
		goto main_logic_ret;
	}

	goto main_logic_ret;


	// Goto table here
main_logic_jumper:

	MLOGIC_SUB2_UNK1 = TIMER1_UNK4 & 0x3f;
	MLOGIC_SUB2_UNK2 = 0x00;
	if (!(MLOGIC_SUB2_UNK2 ^ 0x00)) // should never be possible?!?
		goto main_logic_ret;

	tmp = MLOGIC_SUB2_UNK1;
	ENTRY_SUB2_UNK1 = tmp + 0xd6;
	if (ENTRY_SUB2_UNK1 < tmp)
		goto main_logic_ret;

	if (ENTRY_SUB2_UNK1 + 0x2a < ENTRY_SUB2_UNK1)
		goto main_logic_ret;

	// This should go over the following goto list
	ENTRY_SUB2_UNK -= 0x00; // this really happens in the assembly...
	PCLATH = 0x0e;
	if (ENTRY_SUB2_UNK1 + 0x98 < ENTRY_SUB2_UNK1)
		PCLATH += 1;
	PCL = ENTRY_SUB2_UNK1 + 0x98;

	// What does this list represents?
	goto ML_1;
	goto ML_2;
	goto ML_3;
	goto main_logic_ret;
	goto ML_5;
	goto main_logic_ret;
	goto main_logic_ret;
	goto ML_6;
	goto ML_2;
	goto ML_7;
	goto ML_8;
	goto ML_9;
	goto ML_10;
	goto ML_11;
	goto ML_12;
	goto main_logic_ret;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto main_logic_ret;
	goto ML_14;
	goto ML_15;
	goto ML_16;
	goto ML_17;
	goto ML_18;
	goto ML_13;
	goto ML_13;
	goto ML_13;
	goto ML_13;


	// Return/end code (also ML_4)
main_logic_ret:

	Elodie();

	// We need to display the progress bar
	if (ENTRY_DATA_UNK1 & 0x20 && !(TIMER0_INT_UNK2 & 0x40))
	{
		CLR(TIMER0_INT_UNK2, 3);

		// Init LCD string
		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			BIGARRAY[USART_PACKET_CHECKSUM] = 0x5f; // '_'
			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);

		// Loading bar?
		if (!USART_LOGIC_UNK13)
			BIGARRAY[0] = 0xff;

		if (USART_LOGIC_UNK13 < 0x0b)
			BIGARRAY[1] = 0xff;

		if (USART_LOGIC_UNK13 < 0x15)
			BIGARRAY[2] = 0xff;

		if (USART_LOGIC_UNK13 < 0x1f)
			BIGARRAY[3] = 0xff;

		if (USART_LOGIC_UNK13 < 0x29)
			BIGARRAY[4] = 0xff;

		if (USART_LOGIC_UNK13 < 0x33)
			BIGARRAY[5] = 0xff;

		if (USART_LOGIC_UNK13 < 0x3d)
			BIGARRAY[6] = 0xff;

		if (USART_LOGIC_UNK13 < 0x47)
			BIGARRAY[7] = 0xff;

		if (USART_LOGIC_UNK13 < 0x51)
			BIGARRAY[8] = 0xff;

		if (USART_LOGIC_UNK13 < 0x5b)
			BIGARRAY[9] = 0xff;

		MLOGIG_SUB2_UNK3 = 0x45;

		// strcmp BIGARRAY and LCDARRAY2
		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			USART_LOGIC_UNK2 = BIGARRAY[USART_PACKET_CHECKSUM];
			tmp = LCDARRAY2[USART_PACKET_CHECKSUM];
			if (tmp != USART_LOGIC_UNK2)
				USART_PACKET_CHECKSUM = 0x0c; // essentially, break

			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);

		// If strings are not identical (send it?)
		if (USART_PACKET_CHECKSUM >= 0xc)
			Emma(0x31);
	}
	else if (ENTRY_DATA_UNK3 & 0x80 && !(TIMER0_INT_UNK2 & 0x40))
	{
		// strcmp BIGARRAY and LCDARRAY2
		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			USART_LOGIC_UNK2 = BIGARRAY[USART_PACKET_CHECKSUM];
			tmp = LCDARRAY2[USART_PACKET_CHECKSUM];
			if (tmp != USART_LOGIC_UNK2)
				USART_PACKET_CHECKSUM = 0x0c; // essentially, break

			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);

		// If strings are not identical (send it?)
		if (USART_PACKET_CHECKSUM >= 0xc)
			Emma(ML_UNK1);
	}
	else
	{
		// Init both BIGARRAY and LCDARRAY2
		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			BIGARRAY[USART_PACKET_CHECKSUM] = 0x20;
			LCDARRAY2[USART_PACKET_CHECKSUM] = 0x20;
			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);
	}

	if (ML_UNK2 != USART_LOGIC_UNK24 && ML_UNK3 == ELONA_UNK1 && USART_LOGIC_UNK3 == ELONA_UNK2 && USART_LOGIC_UNK24)
	{
		ML_UNK2 = USART_LOGIC_UNK24;
		HW_INIT2_UNK8 = 0x32;
		HW_INIT2_UNK9 = 0x32;

		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			BIGARRAY[USART_PACKET_CHECKSUM] = 0x20;
			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);

		ML_UNK3 = 0xff;
		USART_LOGIC_UNK3 = 0xff;
	}

	if (ML_UNK3 == ELONA_UNK1 && USART_LOGIC_UNK3 == ELONA_UNK2 &&
			!(ENTRY_DATA_UNK3 & 0x80) && !(ENTRY_DATA_UNK1 & 0x20) && HW_INIT2_UNK10)

	{
		HW_INIT2_UNK10 = 0x1e;
		HW_INIT2_UNK8 = 0x32;
		HW_INIT2_UNK8 = 0x32;
		Emy(0xff);

		USART_PACKET_CHECKSUM = 0x00;
		do
		{
			BIGARRAY[USART_PACKET_CHECKSUM] = 0x20;
			USART_PACKET_CHECKSUM += 1;
		} while (USART_PACKET_CHECKSUM < 0x0a);

		ML_UNK3 = 0xff;
		USART_LOGIC_UNK3 = 0xff;
	}

	if (ML_UNK3 == ELONA_UNK1)
	{
		if (!(ENTRY_DATA_UNK3 & 0x80) && !(ENTRY_DATA_UNK1 & 0x20) && HW_INIT2_UNK8)
		{
			HW_INIT2_UNK8 = 0x32;
			ML_UNK3 = 0xff;
		}
	}
	else
		HW_INIT2_UNK8 = 0x32;


	if (USART_LOGIC_UNK8 == ELONA_UNK2 && !(ENTRY_DATA_UNK3 & 0x80) && !(ENTRY_DATA_UNK1 & 0x20))
	{
		if (!HW_INIT_UNK9)
		{
			HW_INIT2_UNK9 = 0x32;
			USART_LOGIC_UNK3 = 0xff;
		}
	}
	else
		HW_INIT2_UNK9 = 0x32;

	// Twisted logic here, but well...
	if(TIMER1_UNK4 & 0x4f)
	{
		USART_LOGIC_UNK2 = USART_LOGIC_UNK6 & 0x1f;
	}
	if ( (!(TIMER1_UNK4 & 0x4f) || USART_LOGIC_UNK2 <= 0x02) && (TIMER1_UNK4 & 0x3f != 0x23) )
		SET(ENTRY_DATA_UNK, 4);

	return;
}
