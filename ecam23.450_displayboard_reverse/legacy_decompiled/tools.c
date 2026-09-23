// Basic macros for set/clear bits
#define CLR(reg, bit) reg &= ~(1<<bit)
#define SET(reg, bit) reg |= 1<<bit

// Clear watchdog timer
#define CLRWDT() asm('CLRWDT')


// Basic delay (in 2ms intervals) with watchdog clear
void delay_2ms(byte count)
{
	INIT_ST1_UNK1 = count;
	do
	{
		INIT_ST1_UNK2 = 0x04;
		do
		{
			INIT_ST1_UNK3 = 0xa6;
			do
			{
				INIT_ST1_UNK3 -= 1;
			} while (INIT_ST1_UNK3);

			CLRWDT();
			INIT_ST1_UNK2 -= 1;
		} while (INIT_ST1_UNK2)

		INIT_ST1_UNK1 -= 1;
	} while (INIT_ST1_UNK1);
}

// Clear memory between 2 addresses
void memclear(char end) // start is in FSR
{
	register tmp = end ^ FSR;
	while (tmp)
	{
		tmp ^= FSR;
		*INDF = 0;
		FSR += 1;
	}

	CLRWDT();
}

// This fetches the byte either from const (in flash, stored as a return...) or RAM
byte fetch_data(void)
{
	// If MSB of FETCH_ADDR_H is set
	// => fetch from RAM
	if (FETCH_ADDR_H & 0x80)
	{
		CLR(STATUS, IRP); // Clear IRP
		if (FETCH_ADDR_H & 0x01) // If first bit of FETCH_ADDR_H is set, set IRP for banks 2&3
			SET(STATUS, IRP);

		register char tmp = FETCH_ADDR_L;
		FETCH_ADDR_L += 1; // I don't know why iy does that
		FSR = tmp;

		tmp = *INDF;
		return tmp; // Return data indirectly (so what's at (FSR) addr)
	}
	else if (FETCH_ADDR_H & 0x40) // If 7th bit of FETCH_ADDR_H is set, just return 0x08
	{
		return 0x08; //I don't know what that is for...
	}
	else // Fetch data from const
	{
		// Copy FETCH_ADDR_H to PCLATH
		register char tmp = FETCH_ADDR_H;
		PCLATH = tmp;

		tmp = FETCH_ADDR_L;
		FETCH_ADDR_L += 1;
		if (FETCH_ADDR_L == 0)
			FETCH_ADDR_H += 1;

		PCL = tmp; // This would have indirectly called the ret to get a const equivalent
				   // WARN: THIS WILL NOT COMPILE/WORK!

		// return (what's returned by the function, eg. the const)
	}
}
