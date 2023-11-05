
// RTC Driver, only called in the USART logic apprently
void Clemence(void)
{
	register char tmp;

	// Those probably store the time...
	CLEMENCE_UNK1 = 0x00;
	CLEMENCE_UNK2 = 0x00;
	CLEMENCE_UNK3 = 0x00;

	// Read status?
	SSP_PACKET_DATA_12 = 0x00;
	SSP_PACKET_DATA_18_MASK = 0x00;
	SSP_PACKET_DATA_12 = Aline();
	SSP_PACKET_DATA_18_MASK = 0x00;

	// read byte?
	tmp = Alice(0xa0);
	SSP_PACKET_DATA_12 += tmp;
	if (SSP_PACKET_DATA_12 < tmp)
		SSP_PACKET_DATA_18_MASK += 1;

	tmp = Alice(0x00);
	SSP_PACKET_DATA_12 += tmp;
	if (SSP_PACKET_DATA_12 < tmp)
		SSP_PACKET_DATA_18_MASK += 1;

	tmp = Alice(0xa00);
	SSP_PACKET_DATA_12 += tmp;
	if (SSP_PACKET_DATA_12 < tmp)
		SSP_PACKET_DATA_18_MASK += 1;


	if (!(SSP_PACKET_DATA_12 | SSP_PACKET_DATA_18_MASK))
	{
		SSP_PACKET_DATA_12 = 0x00;
		SSP_PACKET_DATA_18_MASK = 0x00;
		SSP_PACKET_DATA_12 = Aline();
		SSP_PACKET_DATA_18_MASK = 0x00;
		tmp += Alice(0xa1);
		SSP_PACKET_DATA_12 += tmp;
		if (SSP_PACKET_DATA_12 < tmp)
			SSP_PACKET_DATA_18_MASK += 1;

		if (!(SSP_PACKET_DATA_12 | SSP_PACKET_DATA_18_MASK))
		{
			CLEMENCE_UNK1 = 0xff;
			return;
		}
	}
	else
	{
		Clemence_UNK1 = 0xff;
		return;
	}

	SSP_PACKET_DATA_12 = 0x00;
	SSP_PACKET_DATA_18_MASK = 0x00;

	do
	{
		EVELISE_UNK1 = ELEONORE_UNK2;
		ENTRY_SUB1_UNK1 = ELEONORE_UNK1;

		// WHAT?!?
		// I promise i'm not on drugs, that's what the original asm code does
		tmp = 0xff;
		ENTRY_SUB2_UNK1 += tmp;
		if (ENTRY_SUB2_UNK1 < tmp)
			EVELISE_UNK1 += tmp;

		if (EVELISE_UNK1 >= SSP_PACKET_DATA_18_MASK)
			SSP_PACKET_DATA_12 = ENTRY_SUB_UNK1;

		if (EVELISE_UNK1 < SSP_PACKET_DATA_18_MASK)
			break;

		tmp = Elsa(0x01);
		CLEMENCE_UNK2 += tmp;
		if (CLEMENCE_UNK2 < tmp) // we overflowed it, increment unk3
			CLEMENCE_UNK3 += 1;

		// Also an overflow check?
		tmp = SSP_PACKET_DATA_12;
		SSP_PACKET_DATA_12 += 1;
		if (SSP_PACKET_DATA_12 < tmp)
			SSP_PACKET_DATA_18_MASK += 1;
	} while(true);

	// Same thing than in the loop
	tmp = Elsa(0x00);
	CLEMENCE_UNK2 += tmp;
	if (CLEMENCE_UNK2 < tmp)
		CLEMENCE_UNK3 += 1;

	// End of transmission?
	Agathe();
	Anais();
}
