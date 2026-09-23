
void USART_MAYBE_LOGIC()
{
	register char tmp;

	// Send I2C packet to powerboard
	if (!TIMER0_INT_UNK3 && !(ENTRY_DATA_UNK1 & 0x10))
	{
		USART_LOGIC_UNK1 = 0x06;
		SSP_SEND_PACKET();
	}

	if (USART_SSP_PACKET_STATUS & 0x20)
	{
		// Do a I2C buffer checksum, why not?
		INIT_ST1_UNK1 = 0x0a;
		INIT_ST1_UNK2 = 0xff;
		USART_PACKET_CHECKSUM = PWRB_PACKET_CHECKSUM(&SSP_BUFFER);

		USART_LOGIC_UNK2 = 0x00;
		USART_LOGIC_UNK4 = USART_LOGIC_UNK3;
		USART_LOGIC_UNK5 = 0x00;
		if (!(USART_LOGIC_UNK2 ^ USART_LOGIC_UNK5)) // this is always false!
			tmp = USART_PACKET_CHECKSUM ^ USART_LOGIC_UNK4;

		// We received a valid packet on the I2C bus?
		if (!tmp && !(SSP_BUFFER ^ 0x0b))
		{
			// Unpack the I2C packet into our variables
			TIMER1_UNK4 = SSP_BUFFER[1];
			USART_LOGIC_UNK6 = SSP_BUFFER[2];
			USART_LOGIC_UNK7 = SSP_BUFFER[3];
			TIMER1_UNK2 = SSP_BUFFER[4];
			USART_LOGIC_UNK8 = SSP_BUFFER[5];
			TIMER_UNK5 = SSP_BUFFER[6];
			USART_LOGIC_UNK9 = SSP_BUFFER[7];
			USART_LOGIC_UNK10 = SSP_BUFFER[8];
			USART_LOGIC_UNK11 = SSP_BUFFER[8] & 0x03;
			USART_PACKET_CHECKSUM = SSP_BUFFER[8] & 0x1c;
			USART_PACKET_CHECKSUM <<= 1;
			USART_LOGIC_UNK12 = USART_PACKET_CHECKSUM << 1;

			// Turn on or off the cup light depending on 5th bit of SSP_BUFFER[5]
			if (!(USART_LOGIC_UNK8 & 0x10))
				SET(PORTA, 7); // turn on the cup light
			else
				CLR(PORTA, 7); // turn off the cup light

			if ((TIMER1_UNK4 & 0x3f) != 0x21) // Check agaist the packet size
				USART_LOGIC_UNK13 = SSP_BUFFER[9];

			if (TIMER1_UNK4 == 0x24)
			{
				USART_LOGIC_UNK14 = USART_LOGIC_UNK6; // copy SSP_BUFFER[2]
				USART_LOGIC_UNK15 = USART_LOGIC_UNK7; // copy SSP_BUFFER[3]
				USART_LOGIC_UNK16 = USART_LOGIC_UNK7;
				USART_LOGIC_UNK17 = USART_LOGIC_UNK14; // recopy SSP_BUFFER[2]
			}
			else if (TIMER1_UNK4 == 0x25)
			{
				USART_LOGIC_UNK14 = USART_LOGIC_UNK6;
				USART_LOGIC_UNK15 = USART_LOGIC_UNK7;
				USART_LOGIC_UNK19 = USART_LOGIC_UNK14;
			}
			else if (TIMER1_UNK4 == 0x26)
			{
				USART_LOGIC_UNK20 = USART_LOGIC_UNK6;
				USART_LOGIC_UNK21 = USART_LOGIC_UNK7;
			}
			else if (TIMER1_UNK4 == 0x27)
			{
				USART_LOGIC_UNK14 = USART_LOGIC_UNK6;
				USART_LOGIC_UNK15 = USART_LOGIC_UNK7;
				USART_LOGIC_UNK22 = USART_LOGIC_UNK15;
				USART_LOGIC_UNK23 = USART_LOGIC_UNK14;
			}

			// Maybe need to check this one
			if ((TIMER1_UNK4 & 0x3f) == 0x0d || !(USART_LOGIC_UNK9 & 0x40))
				USART_LOGIC_UNK24 = USART_LOGIC_UNK7
			else
				USART_LOGIC_UNK24 = USART_LOGIC_UNK8 & 0x0f;

			// Clear flag
			CLR(USART_SSP_PACKET_STATUS, 5);
		}
	}

	// Reset all values if UNK25 is not set
	if(!USART_LOGIC_UNK25)
	{
		SSP_PACKET_DATA_18_BITCOND = 0x00;
		TIMER1_UNK4 = 0x00;
		USART_LOGIC_UNK6 = 0x00;
		USART_LOGIC_UNK7 = 0x00;
		TIMER1_UNK2 = 0x00;
		TIMER1_UNK5 = 0x00;
		USART_LOGIC_UNK9 = 0x00;
		USART_LOGIC_UNK10 = 0x00;
		USART_LOGIC_UNK11 = 0x00;
		USART_LOGIC_UNK12 = 0x00;
	}


	// Depending on some flags, init the powerboard com
	if (!USART_LOGIC_UNK26 && (ENTRY_DATA_UNK3 & 0x10) && USART_LOGIC_UNK26 == 0x01)
	{
		SET(ENTRY_DATA_UNK1, 4);
		POWERBOARD_COM_INIT();
	}

	// This is an invalid status i assume, just return
	if (!(USART_SSP_PACKET_STATUS & 0x08))
		return;

	// Compute checksum for (i assume) received packet
	INIT_ST1_UNK1 = USART_PACKET_BUFFER[1];
	INIT_ST1_UNK2 = 0x00;
	USART_PACKET_CHECKSUM = PWRB_PACKET_CHECKSUM(&USART_PACKET_BUFFER);

	// Clear that
	USART_LOGIC_UNK2 = 0x00;

	// Get packet size
	USART_LOGIC_UNK4 = USART_PACKET_BUFFER[USART_PACKET_BUFFER[1]];
	USART_LOGIC_UNK5 = 0x00;

	// There's a probably defined out part here
	// if (USART_LOGIC_UNK2 != USART_LOGIC_UNK5)
	//  -> clear rx buffer index and packet status' bit 3
	//  -> then return
	// we just defined both as 0x00

	// We just received a valid USART packet
	if (USART_PACKET_CHECKSUM == USART_LOGIC_UNK4)
	{
		// Manage packets depending on the command byte
		switch (USART_PACKET_BUFFER[2])
		{
			case 0x85: // type 2
				if (USART_PACKET_BUFFER[1] != 0x15) // check size
					break; // This is abnormal, break and go to return

				if (TIMER0_INT_UNK1 & 0x04)
				{
					// Recopy the 15 bytes
					do
					{
						// Copy packet from USART_PACKET_BUFFER to PACKET_BUFFER
						USART_PACKET_CHECKSUM = USART_PACKET_BUFFER[USART_LOGIC_UNK30+5];
						PACKET_BUFFER[USART_LOGIC_UNK30] = USART_PACKET_CHECKSUM;

						USART_LOGIC_UNK30 += 1;
					} while (USART_LOGIC_UNK30 < 0x10);

					USART_LOGIC_UNK14 = USART_PACKET_BUFFER[3];
					USART_LOGIC_UNK15 = USART_PACKET_BUFFER[4];

					// Send the packet
					USART_PACKET_SEND_2(0x01);

					// No idea why it does that
					SSP_PACKET_DATA_12 = USART_LOGIC_UNK15;
					SSP_PACKET_DATA_18_MASK = USART_LOGIC_UNK14;
					SSP_PACKET_DATA_18_TMP = 0xa0;

					// Call what is i assume the write eeprom driver
					Cecile();
				}
				else
					// Send a type 2 packet with 0x00, that's it
					USART_PACKET_SEND_2(0x00);
				break;
			case 0x10: // type ???
				USART_LOGIC_UNK14 = USART_PACKET_BUFFER[3];
				USART_LOGIC_UNK15 = USART_PACKET_BUFFER[4];
				USART_LOGIC_UNK27 = USART_PACKET_BUFFER[4];
				USART_LOGIC_UNK28 = USART_LOGIC_UNK14;
				USART_LOGIC_UNK29 = 0xa0;
				Caroline();
				USART_PACKET_SEND_3();
				break;
			case 0x26: // type ???
				if (USART_PACKET_BUFFER[1] == 0x03) // check size
				{
					Clemence(); // Call RTC I2C device driver (?)
					USART_PACKET_SEND_1();
				}
				break;
		}

		// Why?
		USART_LOGIC_UNK26 = 0x14;
	}

	// Clear RX buffer index
	USART_RX_BUFFER_INDEX = 0x00;
	CLR(USART_SSP_PACKET_STATUS, 3);
}
