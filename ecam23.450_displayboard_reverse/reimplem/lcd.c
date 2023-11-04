// Main i2c driver
// hidden param: CHECKSUM_UNK1
void Adele(char param)
{
	CHECKSUM_UNK2 = param;

	ADELE_UNK1 = Aline(); // maybe Aline(param)?
	ADELE_UNK1 = Alice(0x78);

	if (CHECKSUM_UNK2 == 0x01)
		ADELE_UNK1 = Alice(0x80);

	if (CHECKSUM_UNK2 == 0x00)
	{
		ADELE_UNK1 = 0x00;
		ADELE_UNK1 = Alice(0x40);
	}

	Alice(CHECKSUM_UNK1);

	Agathe();
}
