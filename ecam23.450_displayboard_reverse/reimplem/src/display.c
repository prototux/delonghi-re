/*
 * Incremental LCD refresh (0x087E Elodie).
 *
 * The UI only sets line1_msg / line2_msg. Each call of display_refresh()
 * writes at most 5 characters, so a line is redrawn in 4 main loop passes
 * and the I2C bus is never busy for long. A line is redrawn when the wanted
 * message differs from the one shown (or loaded), or, for line 2, when the
 * marquee has to move. Line 1 has priority, but a line is never
 * interrupted once started.
 */
#include "hw.h"
#include "fw.h"

static void write_chunk(uint8_t col, uint8_t ddram)
{
    uint8_t i;

    lcd_write(1, 0x80 | (uint8_t)(ddram + col));
    for (i = col; i < col + 5; i++)
        lcd_write(0, line_buf[i]);
}

void display_refresh(void)
{
    fx.lcd_busy = 0;

    /* ---- line 1 -------------------------------------------------------- */
    if ((line1_shown != line1_msg || line1_shown != line1_loaded) && line2_chunk == 0) {
        fx.lcd_busy = 1;
        if (line1_chunk == 0) {
            text_load_line(line1_msg, 0);
            line1_loaded = line1_msg;
        }
        write_chunk(line1_col, LCD_LINE1);
        line1_chunk++;
        line1_col += 5;
        if (line1_chunk >= 4) {
            line1_chunk = 0;
            line1_col = 0;
            line1_shown = line1_loaded;
        }
        return;
    }

    /* ---- line 2 -------------------------------------------------------- */
    if (line2_shown == line2_msg && line2_shown == line2_loaded && !ui.scroll_step)
        return;
    if (line1_chunk != 0)
        return;

    fx.lcd_busy = 1;
    if (line2_chunk == 0) {
        if (ui.scroll && line2_loaded != line2_msg) {
            text_load_scroll(line2_msg);
            scroll_pos = 0;
            scroll_tmr = 200;           /* 1 s before the marquee starts */
        }
        tmr_c8 = 50;
        tmr_cd = 30;
        text_load_line(line2_msg, 1);
        line2_loaded = line2_msg;
    }
    write_chunk(line2_col, LCD_LINE2);
    line2_chunk++;
    line2_col += 5;
    if (line2_chunk >= 4) {
        line2_chunk = 0;
        line2_col = 0;
        line2_shown = line2_loaded;
        ui.scroll_step = 0;
    }
}
