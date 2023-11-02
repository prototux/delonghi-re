void ISR_USART_RX(void)
{
  // USART Error clearing here
  USART_RX_RECIVED_BYTE = RCREG;
  char *buffer[0x17] = (char*)0x257;

  //  bit 3: full packet available to read
  //  bit 2: unknown
  if ((USART_RX_PACKET_STATUS & 0x8) || !(USART_RX_PACKET_STATUS & 0x4))
  {
    USART_RX_UNKNOWN = 0x2; // set something to 2

	if (USART_RX_BUFFER_INDEX == 0x0) // first byte (header) handling
      if ((USART_RX_RECIVED_BYTE ^ 0xa) == 0x0) // if header == xxxx0x0x, that's an invalid header
		buffer[USART_RX_BUFFER_INDEX++] = USART_RX_RECIVED_BYTE;
	else if (USART_RX_UNK1_MAYBE_STATUS == 0x1) // second byte (size) handling
	{
      if (USART_RX_RECIVED_BYTE < 0x17) // max packet size: 0x17
	  {
        USART_RX_PACKET_SIZE = USART_RX_RECIVED_BYTE; // this seems ot be packet size
	    buffer[USART_RX_BUFFER_INDEX++] = USART_RX_RECIVED_BYTE;
      }
	  else
      	USART_RX_BUFFER_INDEX = 0x0; // size should never be > 0x17, reset buffer
    }
	else // all other bytes
	{
	  buffer[USART_RX_BUFFER_INDEX++] = USART_RX_RECIVED_BYTE; // just copy it in buffer

	  // Set status as "full packet available" if we've reached the last byte (per packet size)
	  if (USART_RX_BUFFER_INDEX > USART_RX_PACKET_SIZE)
        USART_RX_PACKET_STATUS |= 0x8;
	}
  }
}
