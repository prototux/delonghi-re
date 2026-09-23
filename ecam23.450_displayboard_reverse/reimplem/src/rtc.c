/*
 * Real time clock (M41T00-compatible, 8 registers, BCD)
 * (0x14E4 Eloise, 0x1507 init_something_2).
 *
 *   reg 0: ST | seconds      reg 1: minutes      reg 2: CEB CB | hours (24 h)
 *   reg 3..6: day, date, month, year (unused)    reg 7: OUT FT S | calibration
 *
 * The firmware keeps the time in BCD (rtc_hour/min/sec) and sends it in
 * binary to the power board. The OUT bit of register 7 is (ab)used as a
 * "clock was set" marker: it is 1 after a power loss of the RTC, and the
 * firmware writes 0 there whenever the user sets the time.
 */
#include "hw.h"
#include "fw.h"

/* 0x14E4: check the time just read into i2c_buf. 0 = plausible. */
uint8_t rtc_buf_invalid(void)
{
    if (bcd_to_bin(i2c_buf[2] & 0x3F) >= 24)
        return 0xFF;
    if (bcd_to_bin(i2c_buf[1] & 0x7F) >= 60)
        return 0xFF;
    if (bcd_to_bin(i2c_buf[0] & 0x7F) >= 60)
        return 0xFF;
    return 0;
}

/* 0x1507: reset the power board mirror and start the RTC */
void rtc_init(void)
{
    volatile uint8_t d;

    pb_state = 0;
    pb_param1 = 0;
    line1_shown = MSG_NONE;
    line2_shown = MSG_NONE;
    line1_loaded = MSG_NONE;
    line2_loaded = MSG_NONE;
    last_language = 0xFF;
    misc.first_run = 1;
    ui.link_lost = 1;

    i2c_read_block(I2C_RTC, 0x00, 0x00);
    if (rtc_buf_invalid() == 0) {
        rtc_sec = i2c_buf[0] & 0x7F;
        rtc_min = i2c_buf[1] & 0x7F;
        rtc_hour = i2c_buf[2] & 0x3F;
        if (!(i2c_buf[7] & 0x80))
            ui.clock_valid = 1;
    } else {
        i2c_buf[0] = 0;
        i2c_buf[1] = 0;
        i2c_buf[2] = 0;
    }

    /* Kick the oscillator: write back with ST (stop) set, then cleared.
     * Registers 3..7 are written back as they were read. */
    i2c_buf[0] |= 0x80;
    i2c_write_block(I2C_RTC, 0x00, 0x00);
    for (d = 0x42; --d != 0; )
        ;
    i2c_buf[0] &= 0x7F;
    i2c_write_block(I2C_RTC, 0x00, 0x00);
}
