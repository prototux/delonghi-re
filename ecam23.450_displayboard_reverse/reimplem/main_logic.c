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

ML_11:

ML_12:

ML_1:

ML_2:

ML_3:
	if (Elona() | 0x0)
		goto main_logic_ret;
	SET(TIMER0_INT_UNK2, 1);
	ELONA_UNK1 = 0x2c;
	ELONA_UNK2 = 0x19;
	goto main_logic_ret;

ML_6:

ML_5:

ML_7:

ML_8:
	if (Elona() | 0x00)
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

ML_15:

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


	// Return/end code
main_logic_ret:
	return;

}
