void MAINLOOP_MAIN_LOGIC_SUB1(byte param)
{
	USART_LOGIC_UNK5 = param;
	SSP_PACKET_DATA_12 = 0x00;

	// Init BIGARRAY with 0x20s
	USART_LOGIC_UNK4 = 0x00;
	do
	{
		BIGARRAY[USART_LOGIC_UNK4] = 0x20;
		USART_LOGIC_UNK4 += 1;
	}
	while (USART_LOGIC_UNK4 < 0xa);


}