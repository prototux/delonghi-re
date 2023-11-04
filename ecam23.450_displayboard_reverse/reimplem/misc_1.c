
// These two are doing either checksum, crypto or obfuscation apparently

// Called in SSP_PACKET_SEND, Coralie and Eloise
// I have no idea what it does exactly yet
char Evelise(char param)
{
	INIT_ST1_UNK2 = param;
	EVELISE_UNK1 = 0x0a; // that's a shadowed and backupped var!

	// Why even
	INIT_ST1_UNK3 = INIT_ST1_UNK2 | 0xf0;
	INIT_ST1_UNK3 = INIT_ST1_UNK3<<4 | INIT_ST1_UNK3>>4; // swap nibbles for some reason
	INIT_ST1_UNK3 &= 0x0f;

	// To process
	CHECKSUM_UNK1 = Eloane(INIT_ST1_UNK3);
	INIT_ST1_UNK1 = (INIT_ST1_UNK2 & 0x0f) + CHECKSUM_UNK1;
	return INIT_ST1_UNK1;
}

char Eloane(char param)
{
	register tmp = 0x00;
	ENTRY2_SUB2_UNK1 = param;

	do
	{
		if (EVELISE_UNK1 & 0x01)
			tmp += ENTRY_SUB2_UNK1;

		ENTRY_SUB2_UNK1 <<= 1;
		EVELISE_UNK1 >>= 1;
	} while (EVELISE_UNK1);
	return tmp;
}
