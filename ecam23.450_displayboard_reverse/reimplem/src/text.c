/*
 * Message texts (0x13BD Emilie, 0x121A Clara).
 *
 * Messages >= 0xC8 are in ROM (romdata.c). The others are 20 byte records
 * in the external EEPROM, 100 messages per language:
 *
 *     address = 0x14 + (language * 100 + msg) * 20
 *
 * The EEPROM is read in 16 byte aligned blocks, so a record takes two reads.
 * Long texts that scroll on line 2 are consecutive records read as one
 * scroll_len byte string.
 */
#include "hw.h"
#include "fw.h"

static uint16_t msg_address(uint8_t msg)
{
    return (uint16_t)(0x14 + ((uint16_t)language * 100 + msg) * 20);
}

/* 0x13BD: fill line_buf with the 20 characters of `msg` for LCD line `line` */
void text_load_line(uint8_t msg, uint8_t line)
{
    uint8_t i, p, off;
    uint16_t addr, blk;

    if (msg >= MSG_ROM_FIRST) {
        for (i = 0; i < 20; i++)
            line_buf[i] = rom_msg_char(msg, i);
        return;
    }

    if (ui.scroll && line == 1) {
        /* marquee: 20 chars of scroll_buf from scroll_pos, wrapping */
        p = scroll_pos;
        for (i = 0; i < 20; i++) {
            line_buf[i] = scroll_buf[p];
            if (++p >= scroll_len)
                p = 0;
        }
        if (++scroll_pos >= scroll_len)
            scroll_pos = 0;
        return;
    }

    addr = msg_address(msg);
    blk = addr & 0xFFF0;
    off = addr & 0x0F;

    i2c_read_block(I2C_EEPROM, blk >> 8, blk & 0xFF);
    for (i = 0; i < 16 - off; i++)
        line_buf[i] = i2c_buf[off + i];

    blk += 16;
    i2c_read_block(I2C_EEPROM, blk >> 8, blk & 0xFF);
    for (i = 0; i < off + 4; i++)
        line_buf[16 - off + i] = i2c_buf[i];
}

/* 0x121A: load scroll_len bytes starting at message `msg` into scroll_buf.
 * Like the original, it also writes scroll_buf[scroll_len]. */
void text_load_scroll(uint8_t msg)
{
    uint8_t i, j, k, off;
    uint16_t addr, blk;

    addr = msg_address(msg);
    blk = addr & 0xFFF0;
    off = addr & 0x0F;

    j = 0;
    i2c_read_block(I2C_EEPROM, blk >> 8, blk & 0xFF);
    for (i = 0; i < 16 - off; i++)
        scroll_buf[j++] = i2c_buf[off + i];

    for (k = 1; ; k++) {
        uint16_t b = blk + ((uint16_t)k << 4);
        i2c_read_block(I2C_EEPROM, b >> 8, b & 0xFF);
        for (i = 0; i < 16; i++) {
            scroll_buf[j] = i2c_buf[i];
            if (j == scroll_len)
                break;
            j++;
        }
        if (j >= scroll_len)
            return;
    }
}
