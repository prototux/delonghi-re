void Eva(char param)
{
	SSP_PACKET_DATA_12 = param;
	CHECKSUM_UNK1 = param | 0x80;
	dev_lcd_send(0x01);
	CHECKSUM_UNK1 = USART_LOGIC_UNK5;
	dev_lcd_send(0x00);
}
