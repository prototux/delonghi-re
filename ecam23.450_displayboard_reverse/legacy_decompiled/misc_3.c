// No idea what this does yet, it's only called by Eliana
char Elise(void)
{
	register char tmp;
	ELISE_UNK1 = 0x00;
	ESTELLE_UNK1 = 0x00;
	ESTELLE_UNK2 = 0x00;

	if (!(MLOGIC_SUB2_UNK1 | MLOGIC_SUB2_UNK2))
	{
		ENTRY_SUB2_UNK1 = 0x00;
		EVELISE_UNK1 == 0x00;
		return 0;
	}

	// The while condition isn't clear
	ELISE_UNK1 |= 0x1f;
	do
	{
		ELISE_UNK1 += 1;
		MLOGIC_SUB2_UNK1 <<= 1;
		MLOGIC_SUB2_UNK2 <<= 1;
	} while (MLOGIC_SUB2_UNK2);

	do
	{
		MLOGIC_SUB2_UNK2 >>= 1;
		MLOGIC_SUB2_UNK1 >>= 1;
		if (MLOGIC_SUB2_UNK2 <= EVELISE_UNK1 || MLOGIC_SUB2_UNK2 <= ENTRY_SUB2_UNK1)
		{
			if (ENTRY_SUB2_UNK1 < MLOGIC_SUB2_UNK1)
			{
				ENTRY_SUB2_UNK1 -= MLOGIC_SUB2_UNK1;
				EVELISE_UNK1 -= MLOGIC_SUB2_UNK2 + 0x01;
			}
			else
			{
				ENTRY_SUB2_UNK1 -= MLOGIC_SUB2_UNK1;
				EVELISE_UNK1 -= MLOGIC_SUB2_UNK2;
			}
		}

		ESTELLE_UNK1 <<= 1;
		ESTELLE_UNK2 <<= 1;
		ELISE_UNK1 -= 1;
		if ELISE_UNK1
	} while (ELISE_UNK1 || !(ELISE_UNK1 & 0x20));

	// what the heck is going on, is this some kind of very bad cryptography?
	if (ELISE_UNK1 & 0x80)
	{
		ESTELLE_UNK1 = ~(ESTELLE_UNK1);
		ESTELLE_UNK1 += 1;
		if (ESTELLE_UNK1)
			ESTELLE_UNK2 += 2;
		ESTELLE_UNK2 = ~(ESTELLE_UNK2);
	}

	MLOGIC_SUB2_UNK1 = ESTELLE_UNK1;
	MLOGIC_SUB2_UNK2 = ESTELLE_UNK2;
	if (!(ELISE_UNK1 & 0x40))
		return 0;

	ENTRY_SUB2_UNK1 = ~(ENTRY_SUB2_UNK1);
	ENTRY_SUB2_UNK1 += 1;
	if (!ENTRY_SUB2_UNK1)
		EVELISE_UNK1 -= 1;
	EVELISE_UNK1 = ~(EVELISE_UNK1);

	return 0;
}
