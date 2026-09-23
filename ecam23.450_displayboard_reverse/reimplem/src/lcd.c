/*
 * ST7036 character LCD over the bit-banged I2C bus, address 0x78
 * (0x00FD Adele, 0x0123 Emy, 0x01E9 Eva, 0x0832 Emma).
 *
 * The panel shows 2 lines of 20 characters: DDRAM 0x00..0x13 and 0x40..0x53.
 */
#include "hw.h"
#include "fw.h"

/* 0x00FD: one command (is_cmd == 1) or one data byte (is_cmd == 0) per
 * transfer. Control byte 0x80 = Co=1 RS=0, 0x40 = Co=0 RS=1. */
void lcd_write(uint8_t is_cmd, uint8_t b)
{
    softi2c_start();
    softi2c_write(I2C_LCD);
    if (is_cmd == 1)
        softi2c_write(0x80);
    if (is_cmd == 0)
        softi2c_write(0x40);
    softi2c_write(b);
    softi2c_stop();
}

/* 0x0123: soft == 0 at power up (hardware reset + clear), 0xFF when the
 * UI re-initialises the controller every 15 s without clearing it. */
void lcd_init(uint8_t soft)
{
    uint8_t n, i;
    volatile uint8_t d;

    if (soft == 0) {
        LCD_RST_N = 1;
        for (d = 100; --d != 0; )
            ;
        LCD_RST_N = 0;
        delay_ms(1);
        LCD_RST_N = 1;
        delay_ms(40);
    }

    lcd_write(1, 0x38);                 /* function set: 8 bit, 2 lines, IS=0 */

    for (n = 0; n < 4; n++) {           /* custom characters 0..3 */
        for (i = 0; i < 8; i++) {
            lcd_write(1, 0x40 | (uint8_t)(n * 8 + i));  /* CGRAM address */
            lcd_write(0, lcd_glyphs[n][i]);
        }
    }

    lcd_write(1, 0x39);                 /* function set, IS=1                     */
    lcd_write(1, 0x1C);                 /* bias 1/4, oscillator adjust            */
    lcd_write(1, 0x5F);                 /* icons on, booster on, contrast C5:C4=3 */
    lcd_write(1, 0x0C);                 /* display on, no cursor                  */
    lcd_write(1, 0x06);                 /* entry mode: increment                  */
    /* follower (0x6x) and contrast low bits (0x7x) are left at reset values */

    if (soft != 0)
        return;
    lcd_write(1, 0x01);                 /* clear */
    lcd_write(1, 0x02);                 /* home  */
}

/* 0x01E9 */
void lcd_putc_at(uint8_t pos, uint8_t c)
{
    lcd_write(1, pos | 0x80);
    lcd_write(0, c);
}

/* 0x0832: write the 10 char overlay at pos, clipped at the end of the line,
 * and remember what was written in field_shadow. */
void lcd_write_field(uint8_t pos)
{
    uint8_t i, last;

    last = (pos < 0x14) ? 0x13 : 0x53;
    lcd_write(1, pos | 0x80);
    for (i = 0; i < 10; i++) {
        if ((uint16_t)pos + i <= last)
            lcd_write(0, field[i]);
        field_shadow[i] = field[i];
    }
}
