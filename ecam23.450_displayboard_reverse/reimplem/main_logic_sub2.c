void MAINLOOP_MAIN_LOGIC_SUB2(void)
{
	// That is one big switch...
	goto switch;

BGT1:
	// todo

BGT2: // No idea what this does yet
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x46;
	if (!(TIMER1_UNK4 & 0x80))
		return;
	USART_LOGIC_UNK24 = USART_LOGIC_UNK6;
	ELONA_UNK1 = 0x38;
	ELONA_UNK2 = 0x39;
	return;

BGT3:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x47;
	if (TIMER1_UNK4 & 0x80)
	{
		if (USART_LOGIC_UNK6)
			ELONA_UNK2 = 0x54;
		else
			ELONA_UNK5 = 0x55;
		return;
	}

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);

	SET(ENTRY_DATA_UNK3, 7);
	MLOGIC_SUB2_UNK3 = 0x40;

	SET(TIMER0_INT_UNK2, 7);
	SET(TIMER0_INT_UNK2, 6);

	if (TIMER2_UNK2 & 0x01)
		return;

	USART_LOGIC_UNK5;
	Eva(0x04);
	return;

BGT17:
	// todo

BGT4:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x48;
	if (!(TIMER1_UNK4 & 0x80))
		return;
	ELONA_UNK2 = 0x44;
	return;

BGT5:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x49;
	if (!(TIMER1_UNK4 & 0x80))
		return;

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	} while (USART_LOGIC_UNK4 < 0x10);

	SET(ENTRY_DATA_UNK3, 7);
	MLOGIC_SUB2_UNK3 = 0x48;
	register tmp = USART_LOGIC_UNK6 ^ 0x00;
	if (!tmp);
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0x6f;
		BIGARRAY[2] = 0x6f;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x01;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0x6f;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x03;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0xfd;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x01;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0xfd;
		BIGARRAY[3] = 0xfd;
	}
	return;

BGT6:
	// todo

BGT7:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x51;
	if (!(TIMER1_UNK4 & 0x80))
		return;

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	} while (USART_LOGIC_UNK4 < 0x10);

	SET(ENTRY_DATA_UNK3, 7);
	MLOGIC_SUB2_UNK3 = 0x48;
	register tmp = USART_LOGIC_UNK6 ^ 0x00;
	if (!tmp);
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0x6f;
		BIGARRAY[2] = 0x6f;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x01;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0x6f;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x03;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0xfd;
		BIGARRAY[3] = 0x6f;
		return;
	}
	tmp ^= 0x01;
	if (!tmp)
	{
		BIGARRAY[0] = 0xfd;
		BIGARRAY[1] = 0xfd;
		BIGARRAY[2] = 0xfd;
		BIGARRAY[3] = 0xfd;
	}
	return;


BGT8:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x57;
	if (!(TIMER1_UNK4 & 0x80))
		return;
	ELONA_UNK2 = 0x44;
	return;

BGT9:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x58;
	if (!(TIMER1_UNK4 & 0x80))
		return;
	ELONA_UNK2 = 0x44;
	return;

BGT12:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x5a;
	if (!(TIMER1_UNK4 & 0x80))
		return;
	ELONA_UNK2 = 0x5c;
	USART_LOGIC_UNK14 = USART_LOGIC_UNK6;
	USART_LOGIC_UNK15 = USART_LOGIC_UNK7;
	MLOGIC_SUB2_UNK4 = USART_LOGIC_UNK15;
	MLOGIC_SUB2_UNK5 = USART_LOGIC_UNK14;
	Eliana();
	SET(MLOGIC_SUB2_UNK6, 7);
	MLOGIC_SUB2_UNK3 = 0x4f;
	return;

BGT10:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x5a;
	if (!(TIMER1_UNK4 & 0x80))
		return;

	if ((TIMER1_UNK4 & 0x3f) == 0x1b)
		ELONA_UNK2 = 0x5b;
	else if ((TIMER1_UNK4 & 0x3f) == 0x1d)
		return
	else
		ELONA_UNK2 = 0x5e;

	USART_LOGIC_UNK14 = USART_LOGIC_UNK6;
	USART_LOGIC_UNK15 = USART_LOGIC_UNK7;
	MLOGIC_SUB2_UNK4 = USART_LOGIC_UNK15;
	MLOGIC_SUB2_UNK5 = USART_LOGIC_UNK14;
	Eliana();
	SET(MLOGIC_SUB2_UNK6, 7);
	MLOGIC_SUB2_UNK3 = 0x4f;
	return;
	// more logic
	return;

BGT11:
	INIT_HW2_UNK6 = 0x03;
	ELONA_UNK1 = 0x5a;
	if (!(TIMER1_UNK4 & 0x80))
		return;

	if ((TIMER1_UNK4 & 0x3f) == 0x1b)
		ELONA_UNK2 = 0x5d;
	else if ((TIMER1_UNK4 & 0x3f) == 0x1d)
		return
	else
		ELONA_UNK2 = 0x5f;

	USART_LOGIC_UNK14 = USART_LOGIC_UNK6;
	USART_LOGIC_UNK15 = USART_LOGIC_UNK7;
	MLOGIC_SUB2_UNK4 = USART_LOGIC_UNK15;
	MLOGIC_SUB2_UNK5 = USART_LOGIC_UNK14;
	Eliana();
	SET(MLOGIC_SUB2_UNK6, 7);
	MLOGIC_SUB2_UNK3 = 0x4f;
	return;

BGT13:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x63;
	if (TIMER1_UNK4 & 0x80)
	{
		if (USART_LOGIC_UNK6)
			ELONA_UNK2 = 0x54;
		else
			ELONA_UNK5 = 0x55;
		return;
	}

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);

	if (TIMER1_UNK2 & 0x80)
	{
		BIGARRAY[1] = 0x2a;
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	else
	{
		BIGARRAY[1] = 0x20;
		SET(ENTRY_DATA_UNK3, 7);
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	return;


BGT14:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x59;
	if (TIMER1_UNK4 & 0x80)
	{
		if (USART_LOGIC_UNK6)
			ELONA_UNK2 = 0x54;
		else
			ELONA_UNK5 = 0x55;
		return;
	}

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);

	if (TIMER1_UNK2 & 0x04)
	{
		BIGARRAY[1] = 0x2a;
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	else
	{
		BIGARRAY[1] = 0x20;
		SET(ENTRY_DATA_UNK3, 7);
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	return;

BGT16:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x37;
	if (TIMER1_UNK4 & 0x80)
	{
		if (USART_LOGIC_UNK6)
			ELONA_UNK2 = 0x54;
		else
			ELONA_UNK5 = 0x55;
		return;
	}

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);

	if (TIMER1_UNK2 & 0x08)
	{
		BIGARRAY[1] = 0x2a;
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	else
	{
		BIGARRAY[1] = 0x20;
		SET(ENTRY_DATA_UNK3, 7);
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	return;

BGT_15:
	INIT_HW1_UNK6 = 0x03;
	ELONA_UNK1 = 0x53;
	if (TIMER1_UNK4 & 0x80)
	{
		if (USART_LOGIC_UNK6)
			ELONA_UNK2 = 0x54;
		else
			ELONA_UNK5 = 0x55;
		return;
	}

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);

	if (TIMER1_UNK2 & 0x10)
	{
		BIGARRAY[1] = 0x2a;
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	else
	{
		BIGARRAY[1] = 0x20;
		SET(ENTRY_DATA_UNK3, 7);
		MLOGIC_SUB2_UNK3 = 0x48;
	}
	return;


/*******************************/
/* Return to "normal" function */
/******************************/

switch:
	// BGT1_pre
	MLOGIC_SUB2_UNK1 = TIMER1_UNK4 & 0x3f;
	MLOGIC_SUB2_UNK2 = 0x00;

	// BGT1_mid
	if (MLOGIC_SUB2_UNK2 == 0x00) // this... cannot be true?
		return;


	// The scary goto list aka switch...
	ENTRY_SUB2_UNK1 = MLOGIC_SUB2_UNK1;

	// No idea why there's these checks
	if (ENTRY_SUB2_UNK1 > 0xd6)
		return;
	if (ENTRU_SUB2_UNK1 + 0xd6 > 0x19)
		return;

	ENTRY2_SUB2_UNK1 -= 0x11;
	PCLATH = 0x04;
	if (ENTRY2_SUB2_UNK1 < 0x48)
		PCLATH += 1;
	PCL = ENTRY2_SUB2_UNK1 + 0x48;

	// PCLATH+PCL will go to one of these
	goto BGT1;
	goto BGT2;
	goto BGT3;
	goto BGT4;
	goto BGT5;
	goto BGT6;
	goto BGT7;
	goto BGT8;
	goto BGT9;
	goto BGT10;
	goto BGT11;
	goto BGT10;
	goto BGT11;
	goto BGT12;
	goto BGT13;
	return; // BGT18-ret
	return; // BGT18-ret
	return; // BGT18-ret
	return; // BGT18-ret
	return; // BGT18-ret
	return; // BGT18-ret
	goto BGT14;
	goto BGT15;
	goto BGT16;
	goto BGT17;
}
