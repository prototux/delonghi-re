/*
 * Housekeeping run before the UI (0x1559 Coralie).
 */
#include "hw.h"
#include "fw.h"

void service_update(void)
{
    volatile uint8_t d;

    CLRWDT();

    /* First pass: holding only the encoder button at power up enters the
     * UART service mode (30 s, extended by every valid frame). */
    if (misc.first_run) {
        misc.first_run = 0;
        if ((keys & KEY_ENC_PUSH) && keys_count == 1) {
            misc.uart_mode = 1;
            link_select(0);
            uart_timeout = 60;
        } else {
            misc.uart_mode = 0;
            link_select(0xFF);
        }
    }

    /* Re-read the RTC every 500 ms */
    if (tick.t500ms) {
        i2c_read_block(I2C_RTC, 0x00, 0x00);
        if (rtc_buf_invalid() == 0) {
            rtc_sec = i2c_buf[0] & 0x7F;
            rtc_min = i2c_buf[1] & 0x7F;
            rtc_hour = i2c_buf[2] & 0x3F;
        }
    }

    /* Clock menu (state 0x11 with bit 7 = item open): HOT WATER alone stores
     * the BCD time the power board sends in param1:param2. */
    if ((pb_state & 0x3F) == 0x11 && (pb_state & 0x80) &&
        (keys & KEY_HOTWATER) && keys_count == 1) {
        for (d = 0; ++d < 8; )
            ;
        if (bcd_to_bin(pb_param1) < 24 && bcd_to_bin(pb_param2) < 60) {
            rtc_hour = pb_param1;
            rtc_min = pb_param2;
            rtc_sec = 0;
            ui.clock_valid = 1;
            i2c_buf[2] = rtc_hour;
            i2c_buf[1] = rtc_min;
            i2c_buf[0] = rtc_sec;
            i2c_buf[7] = 0;                     /* OUT = 0: "clock set" marker */
            i2c_write_block(I2C_RTC, 0x00, 0x00);
        }
    }

    /* tmr_cb only runs down while ui.b5 is set; see ui_alarm/ui_main */
    if (!ui.b5 || tmr_cb == 0)
        tmr_cb = 60;
}
