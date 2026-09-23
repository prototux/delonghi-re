/*
 * Software timers (0x0723 MAINLOOP_SUB1).
 *
 * The timer0 ISR sets tick.isr_5ms every ~5 ms. The first main loop pass
 * after that turns it into the one-pass events tick.t5ms / t50ms / t500ms
 * and runs every countdown of the firmware. Counters named tmr_* saturate
 * at 0; users reload them and test them for 0.
 */
#include "hw.h"
#include "fw.h"

void timebase_update(void)
{
    CLRWDT();
    tick.t5ms = 0;
    tick.t50ms = 0;
    tick.t500ms = 0;

    INTCONbits.T0IE = 0;
    if (!tick.isr_5ms)
        goto out;

    /* ---- every 5 ms ---------------------------------------------------- */
    led_out = disp.blink_250ms ? (uint8_t)(led_on & ~led_blink) : led_on;
    tick.isr_5ms = 0;
    INTCONbits.T0IE = 1;
    tick.t5ms = 1;

    if (startup_delay != 0 && --startup_delay == 0)
        tick.started = 1;

    if (--blink_presc == 0) {               /* 250 ms */
        disp.blink_250ms_b = !disp.blink_250ms_b;
        blink_presc = 50;
        disp.blink_250ms = !disp.blink_250ms;
    }

    if (spi_period != 0)
        spi_period--;
    if (uart_tx_to != 0 && --uart_tx_to == 0)
        link.uart_tx_busy = 0;
    if (uart_rx_to != 0 && --uart_rx_to == 0)
        uart_rx_idx = 0;                    /* incomplete frame: drop it */

    if (tick.started) {
        if (ui.scroll) {
            if (scroll_tmr != 0) {
                scroll_tmr--;
            } else {
                ui.scroll_step = 1;         /* marquee: one char every 350 ms */
                scroll_tmr = 70;
            }
        } else {
            ui.scroll_step = 0;
        }
    }

    if (--div_50ms != 0)
        goto out;

    /* ---- every 50 ms --------------------------------------------------- */
    div_50ms = 10;
    tick.t50ms = 1;

    if (div_800ms != 0) {
        div_800ms--;
    } else {
        div_800ms = 15;
        misc.blink_800ms = !misc.blink_800ms;
    }

    if (tick.started) {
        if (tmr_c9 != 0) tmr_c9--;
        if (tmr_cb != 0) tmr_cb--;
        if (link_timeout != 0) link_timeout--;
        if (tmr_c7 != 0) tmr_c7--;
        if (tmr_c8 != 0) tmr_c8--;
    }

    if (--div_500ms != 0)
        goto out;

    /* ---- every 500 ms -------------------------------------------------- */
    div_500ms = 10;
    tick.t500ms = 1;
    if (!tick.started)
        goto out;

    link.blink_1hz = !link.blink_1hz;

    if (disp.standby) {
        if (dim_timer != 0)
            dim_timer--;
        else
            dim_timer = 10;                 /* wraps: 0 lasts for 500 ms only */
    }

    if (tmr_cd != 0)
        tmr_cd--;

    if (idle_tmr != 0 && !fx.b4) {
        idle_tmr--;
    } else {
        fx.b4 = 0;
        fx.idle = 1;
    }

out:
    INTCONbits.T0IE = 1;
}
