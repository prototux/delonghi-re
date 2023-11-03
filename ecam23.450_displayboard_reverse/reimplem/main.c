#include "pic16f916.h"

// Entrypoint (at addr 0x0000)
void _entry(void) { goto main; }

// Const data for memory bank init
const char bank0_init_data[3] = {0x08, 0x02, 0x32}; // this is at 0x00bf

// Real main
void main(void)

	/* Init RAM Bank 0 */
	// Clear memory from 0x20 to 0x65 using FSR
	FSR = 0x20; // start
	memclear(0x66); // end

	// Init bank 0 memory with const data from 0x00bf
	FETCH_ADDR_H = 0x00;
	FETCH_ADDR_L = 0xbf;
	FSR = 0x66; // start of memory to init
	init_ram_with_data(0x69); // end of memory to init


	/* Init RAM Bank 1 */
	// clear mem
	FSR = 0xa0; // start
	memclear(0xe7); // end

	// Init with const data from 0x00c2
	FETCH_ADDR_H = 0x00;
	FETCH_ADDR_L = 0xc2;
	FSR = 0xe7; // start
	init_ram_with_data(0xe8);


	/* Init RAM Bank 2 and 3 */
	// Set IRP (to select bank 2&3 indirect access)
	SET(STATUS, IRP);
	// Clear bank 2
	FSR = 0x20; // start
	memclear(0x6e); // end

	// Clear bank 3
	FSR = 0x90; // start
	memclear(0xef); // end

	// Here it goto to second part of the function, for some reason it's at the second page (0x1004)

	// I don't know why this yet, this data must be important given how early it is defined
	CLR(USART_SSP_PACKET_STATUS, 7);
	SET(ENTRY_DATA_UNK1, 6);
	CLR(ENTRY_DATA_UNK4, 4);
	ENTRY_DATA_UNK2 = 0;

	CLR(ENTRY_DATA_UNK3, 0); // This is used for the sub main loop

	// Reset watchdog and wait 60ms
	CLRWDT();
	delay_2ms(0x1e);

	// Init hardware
	init_hardware_1();
	SET(FSR, 6); // why?
	CLRWDT();
	init_hardware_2();

	init_something_2(); // This is probably power board communication

	// This is more init functions
	Emy(0x00);
	Eleonore();

	// Enable interrupts
	SET(INTCON, PEIE);
	SET(INTCON, GIE);


	// Main loop
	do
	{
		// Sub main loop, i don't know why yet
		do
		{
			CLRWDT();

			// First main loop function, unknown yet
			MAINLOOP_SUB1();
			CLRWDT();

			// Second main loop function, unknown yet
			MAINLOOP_SUB2();
			CLRWDT();

			// Third main loop function, unknown yet
			MAINLOOP_SUB3();
			CLRWDT();

			// Power board communication logic?
			USART_MAYBE_LOGIC();
			CLRWDT();
		} while ( !(ENTRY_DATA_UNK3 & 0x01) );

		// Other functions in the main loop

		Coralie(); // This seems like power board communication manager
		CLRWDT();

		MAINLOOP_MAIN_LOGIC(); // That big function...
		CLRWDT();

	} while (true);

}

// This inits part of RAM with const data
// (this an elaborate way to memcpy...)
char init_ram_with_data(char end)
{
	register char tmp = end; // we don't really care what value it has...
	ENTRY_SUB2_UNK1 = end;
	do
	{
		tmp = fetch_data(); // Fetch const data
		*INDF = tmp; // Write it to ram
		FSR += 1;
		tmp = FSR;
		ENTRY_SUB2_UNK1 ^= tmp;
	} while (ENTRY_SUB2_UNK1 != 0);

	return 0x00; // Only to reset wreg
}
