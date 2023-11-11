// PORTB 3: SDA 4: SCL
#define SCL_PIN  4
#define SDA_PIN  3
#define SCL_HIGH() (PORTB |= (1 << SCL_PIN))
#define SCL_LOW()  (PORTB &= ~(1 << SCL_PIN))
#define SDA_HIGH() (PORTB |= (1 << SDA_PIN))
#define SDA_LOW()  (PORTB &= ~(1 << SDA_PIN))
#define SDA_READ() ((PORTB >> SDA_PIN) & 1)
#define SCL_READ() ((PORTB >> SCL_PIN) & 1)
#define SDA_INPUT()  (TRISB |= (1 << SDA_PIN))
#define SDA_OUTPUT() (TRISB &= ~(1 << SDA_PIN))

// Start an I2C communication
char softi2c_start(void)
{
	// Start condition
	SDA_HIGH();
	NOP;NOP;NOP;
	SCL_HIGH();


	SDA_OUTPUT();
	SDA_INPUT();
	if (!(TRISB & 1<<3))
		return 0x1;
	softi2c_wait();

	// Start I2C com
	SDA_OUTPUT();
	SDA_LOW();
	softi2c_wait();

	// Start condition has been sent
	SCL_LOW();
	return 0x00;
}

// (Optionally) End an I2C communication
void softi2c_end(void)
{
	// Send a pulse
	SCL_LOW();
	SDA_OUTPUT();
	SDA_LOW();

	// Set SCL to idle state
	SCL_HIGH();
	softi2c_wait();

	// Set SDA to idle state
	SDA_HIGH();
	NOP;NOP;NOP;
	softi2c_wait();
}

// Send a single byte
void softi2c_send_byte(char byte)
{
	// Copy param and set SDA as output
	softi2c_param_cpy = byte;
	SDA_OUTPUT();

	// Send a byte, MSB first
	softi2c_tmp = 0x00;
	do
	{
		// Set SDA depending on the bit state
		if (softi2c_param_cpy & 0x80)
		{
			SDA_HIGH();
			NOP;NOP;
		}
		else
			SDA_LOW();

		NOP;

		// Send a clock pulse
		SCL_HIGH();
		softi2c_wait();
		SCL_LOW();

		// If we're at the last bit, set SDA as input
		if (softi2c_tmp == 0x07)
			SDA_INPUT();


		softi2c_wait();

		// Shift MSB to next bit
		softi2c_param_cpy <<= 1;

		softi2c_tmp += 1;
	} while (softi2c_tmp < 0x08);

	// Check if we got a ACK request
	SCL_HIGH();
	softi2c_wait();
	softi2c_tmp = 0x00;
	if (PORTB & 1<<3) // if SDA is set
		softi2c_tmp = 0x01;
	SCL_LOW();
	softi2c_wait();

	// Set SDA back to output and return the ACK bit
	SDA_OUTPUT();
	return softi2c_tmp;
}

// Read a byte, with optional ACK
void softi2c_read_byte(char send_ack)
{
	// Copy param
	softi2c_param_cpy = send_ack;


	softi2c_read_buffer = 0x00;
	SDA_INPUT();
	softi2c_tmp = 0x00;

	// Read a byte starting with MSB
	do
	{
		// Shift MSB to the right to make space for next bit
		softi2c_read_buffer <<= 1;

		// One clock pulse and read the bit, then wait
		SCL_HIGH();
		softi2c_wait();
		if (PORTB & 1<<3)
			SET(softi2c_read_buffer, 0);
		SCL_LOW();
		softi2c_wait();

		softi2c_tmp += 1;
	} while (softi2c_tmp < 0x7);

	// Send ACK?
	SDA_OUTPUT();
	if (softi2c_param_cpy == 0x01)
		SDA_LOW();
	else
	{
		SDA_HIGH();
		NOP; NOP; NOP;
	}

	// Do an additional clock pulse
	// No idea why yet
	SCL_HIGH();
	softi2c_wait();
	SCL_LOW();
	softi2c_wait();

	// Set SDA to low, still no idea why
	SDA_LOW();
	return softi2c_read_buffer;
}

// Wait ~10 cpu cycles -1.25us- (including the call) in the worst way possible
void softi2c_wait(void)
{
	// Clear watchdog
	CLRWDT();

	// Set bit 1 of USART_SSP_PACKET_STATUS. This isn't checked anywhere,
	// so either it's a debug/legacy flag, or it's a useless semaphore
	SET(USART_SSP_PACKET_STATUS, 1);
	if (!(USART_SSP_PACKET_STATUS & 0x01)) // This cannot be true
		return;
	NOP;
	CLR(USART_SSP_PACKET_STATUS, 1);
}