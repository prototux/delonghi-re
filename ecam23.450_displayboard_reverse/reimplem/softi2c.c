// PORTB 3: SDA 4: SCL

void Elsa(char param)
{
	SOFT_I2C_UNK1 = param;
	SOFT_I2C_UNK2 = 0x00;
	SET(TRISB, 3);
	SOFT_I2C_UNK2 = 0x00;

	do
	{
		SOFT_I2C_UNK2 <<= 1;
		SET(PORTB, 4);
		Anais();
		SET(SOFT_I2C_UNK2, 0);
		CLR(PORTB, 4);
		Anais();
		SOFT_I2C_UNK2 += 1;
	} while (SOFT_I2C_UNK2 < 0x7);

	CLR(TRISB, 3);

	if (SOFT_I2C_UNK1 == 0x01)
	{
		CLR(PORTB, 3);
	}
	else
	{
		SET(PORTB, 3);
		NOP; NOP; NOP;
	}

	SET(PORTB, 4);
	Anais();
	CLR(PORTB, 4);
	Anais();
	CLR(PORTB, 3);
	return SOFT_I2C_UNK2;
}

char Aline(void)
{
	SET(PORTB, 3);
	NOP;
	NOP;
	NOP;
	SET(PORTB, 4);
	CLR(TRISB, 3);
	SET(TRISB, 3);
	if (!(TRISB & 1<<3))
		return 0x1;
	Anais();

	CLR(TRISB, 3);
	CLR(PORTB, 3);
	Anais();
	CLR(PORTB, 4);
	return 0x00;
}

void Alice(char param)
{
	SOFT_I2C_UNK1 = param;
	CLR(TRISB, 3);
	SOFT_I2C_UNK2 = 0x00;
	do
	{
		if (SOFT_I2C_UNK1 & 0x80)
		{
			SET(PORTB, 3);
			NOP; NOP;
		}
		else
			CLR(PORTB, 3);

		NOP;

		SET(PORTB, 4);
		Anais();
		CLR(PORTB, 4);

		if (SOFT_I2C_UNK2 == 0x07)
			SET(TRISB, 3);

		Anais();

		SOFT_I2C_UNK1 <<= 1;
		SOFT_I2C_UNK2 += 1;
	} while (SOFT_I2C_UNK2 < 0x08);

	SET(PORTB, 4);

	Anais();
	SOFT_I2C_UNK2 = 0x00;
	if (PORTB & 1<<3)
	{
		SOFT_I2C_UNK2 = 0x00;
		SORT_I2C_UNK2 += 1;
	}

	CLR(PORTB, 4);
	Anais();
	CLR(TRISB, 3);
	return SOFT_I2C_UNK2;
}

void Agathe(void)
{
	CLR(PORTB, 4);
	CLR(TRISB, 3);
	CLR(PORTB, 3);
	SET(PORTB, 4);
	Anais();
	SET(PORTB, 3);
	NOP;
	NOP;
	NOP;
	Anais();
}

// Seems to wait in the worst way possible
void Anais(void)
{
	CLRWDT();
	SET(USART_SSP_PACKET_STATUS, 1);
	if (!(USART_SSP_PACKET_STATUS & 0x01)) // this... can't be true
		return;
	NOP;
	NOP;
	CLR(USART_SSP_PACKET_STATUS, 1);
}
