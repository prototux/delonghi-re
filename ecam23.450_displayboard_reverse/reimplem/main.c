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
	SET(PORTA, 6); // Enable LCD backlight
	CLRWDT();
	init_hardware_2();

	init_something_2(); // This is probably power board communication

	// This is more init functions
	Emy(0x00); // Emy(0xff) is also called in MAINLOOP_MAIN_LOGIC
	Eleonore(); // Eleonore is never called again, seems to init the softI2C

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

// First part of the hardware init
void init_hardware_1(void)
{
	// Disable interrupts (should already be disabled by default, but oh well)
	CLR(INTCON, GIE);
	CLR(INTCON, PEIE);

	OSCON = 0x70;
	OPTION_REG = 0xc6;
	INTCON = 0x00;

	// Interrupts config
	PIE1 = 0x00;
	PIE2 = 0x00;
	PCON = 0x00;
	PIR1 = 0x00;
	PIR2 = 0x00;

	// Watchdog cofnig
	WPUB = 0x00;

	// GPIO config
	TRISA = 0x00;
	TRISB = 0xe0;
	IOCB = 0x00;

	// Timer 0 config
	TMR0 = 0xfd;
	CLR(INTCON, TMR0IE);

	// Timer 1 config
	T1CON = 0x01;
	CLR(PIE1, 0)

	// Timer 2 config
	TMR2 = 0x00;

	// PORTC tristate config
	TRISC = 0x87;

	// Timer 2 config again
	T2CON = 0x01;

	CCP1CON = 0xac;

	ADCON1 = 0x50;
	ADCON0 = 0x00;

	ANSEL = 0x00;

	// LCD Config
	LCDCON = 0x00;
	LCDSE0 = 0x00;
	LCDSE1 = 0x00;
	LCDSE2 = 0x00;
	LVDCON = 0x00;

	// SSP (I2C/SPI) config
	SSPSTAT = 0x00;
	SSPCON = 0x00;

	// EEPROM config
	EECON1 = 0x00;

	CMCON0 = 0xff;
	VRCON = 0x00;

	// Vars init
	SSP_PACKET_UNK1 = 0x00;
	INIT_HW1_UNK1 = 0x00;
	INIT_HW1_UNK2 = 0x00;
	INIT_HW1_UNK3 = 0x00;
	INIT_HW1_UNK4 = 0x00;
	INIT_HW1_UNK5 = 0x00;
	INIT_HW1_UNK6 = 0x00;
	INIT_HW1_UNK7 = 0x00;
	INIT_HW1_UNK8 = 0x00;
	ENTRY_DATA_UNK4 = 0x00;
}


// Second part of the hardware init
void init_hardware_2(void)
{
	OPTION_REG = 0xc6;

	// Timer 0 config
	TMR0 = 0xfd;
	CLR(INTCON, TMR0IF);
	SET(INTCON, TMR0IE);

	// Timer 1 config
	T1CON = 0x01;
	TMR1L = 0xa3;
	TMR1H = 0xfc;
	CLR(PIR1, 0);
	SET(PIE1, 0);

	// Comparator 1 config
	CCP1CON = 0xac;

	PR2 = 0x7d;

	CCPR1L = 0x3e;

	T2CON - 0x01;

	// Vars init
	HW_INIT2_UNK1 = 0x1a;
	HW_INIT2_UNK2 = 0x0a;
	HW_INIT2_UNK3 = 0x0a;
	HW_INIT2_UNK4 = 0x1e;
	HW_INIT2_UNK5 = 0x46;
	HW_INIT2_UNK6 = 0x1e;
	HW_INIT2_UNK7 = 0x3c;
	HW_INIT2_UNK8 = 0x32;
	HW_INIT2_UNK9 = 0x32;
	HW_INIT2_UNK10 = 0x1e;
	HW_INIT2_UNK11 = 0x0a;
}
