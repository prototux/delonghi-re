/*
 * Constant data of the original firmware (generated from the v30 image).
 *
 * The PIC stores constants as RETLW tables; here they are plain arrays.
 */
#include "fw.h"

/* Messages 0xC8..0xDD: 20 characters each. The pointer table is at 0x0800,
 * each string is an "ADDWF PCL" + 21 RETLW (20 chars + NUL) table. */
static const char rom_msgs[22][21] = {
    /* 0xC8 MSG_BLANK          @0x1843 */ "                    ",
    /* 0xC9 MSG_DISPLAY_TEST   @0x192D */ "DISPLAY TEST MODE   ",
    /* 0xCA MSG_BUTTON         @0x1943 */ "BUTTON              ",
    /* 0xCB MSG_LOAD_TEST      @0x1917 */ "LOAD TEST MODE      ",
    /* 0xCC MSG_LIMIT_UP       @0x1985 */ "LIMIT SWITCH UP     ",
    /* 0xCD MSG_LIMIT_DOWN     @0x1959 */ "LIMIT SWITCH DOWN   ",
    /* 0xCE MSG_MOTOR_UP       @0x182D */ "MOTOR UP            ",
    /* 0xCF MSG_MOTOR_DOWN     @0x1901 */ "MOTOR DOWN          ",
    /* 0xD0 MSG_VAPORIZER_ON   @0x18DD */ "VAPORIZER ON        ",
    /* 0xD1 MSG_ELECTRIC_TEST  @0x18B1 */ "ELECTRIC TEST MODE  ",
    /* 0xD2 MSG_HEATER_ON      @0x189B */ "HEATER ON           ",
    /* 0xD3 MSG_GRINDER_ON     @0x1885 */ "GRINDER ON          ",
    /* 0xD4 MSG_PUMP_ON        @0x18C7 */ "PUMP ON             ",
    /* 0xD5 MSG_EV1_ON         @0x1859 */ "EV1 ON              ",
    /* 0xD6 MSG_EV2_ON         @0x186F */ "EV2 ON              ",
    /* 0xD7 MSG_UART_MODE      @0x1817 */ "UART MODE           ",
    /* 0xD8 MSG_BLANK2         @0x196F */ "                    ",
    /* 0xD9 MSG_PRESS_ESC_OK   @0x1801 */ "PRESS ESC + OK      ",
    /* 0xDA MSG_ENERGY_SAVING  @0x07E8 */ "ENERGY SAVING       ",
    /* 0xDB MSG_ALL_BLOCKS     @0x199B */ "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff",
    /* 0xDC MSG_ALL_0x17       @0x19DA */ "\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17\x17",
    /* 0xDD MSG_ALL_GLYPH0     @0x19B0 */ "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
};

uint8_t rom_msg_char(uint8_t msg, uint8_t i)
{
    return (uint8_t)rom_msgs[msg - MSG_ROM_FIRST][i];
}

/* CGRAM glyphs loaded by lcd_init() (tables at 0x1A35, 0x1A3E, 0x1A47).
 * Glyph 3 is loaded from the same table as glyph 2 in the original. */
const uint8_t lcd_glyphs[4][8] = {
    { 0x1F, 0x1F, 0x1F, 0x1F, 0x00, 0x00, 0x00, 0x00 },
    { 0x04, 0x04, 0x04, 0x06, 0x0C, 0x04, 0x04, 0x00 },
    { 0x08, 0x1C, 0x08, 0x09, 0x06, 0x08, 0x04, 0x00 },
    { 0x08, 0x1C, 0x08, 0x09, 0x06, 0x08, 0x04, 0x00 },
};

/* Unused tables, kept for reference:
 *  0x18F2: 0E 00 11 11 11 13 0D 00   (a "u" with umlaut glyph, never loaded)
 *  0x19D9: 20 x 0x17                  (same content as MSG_ALL_0x17)       */
