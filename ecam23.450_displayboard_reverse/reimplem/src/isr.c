/*
 * Interrupts (0x0004 _interrupt and its handlers).
 *
 * The original saves W, STATUS, FSR, PCLATH, the fetch pointer and the
 * compiler scratch registers 0x79..0x7F, then polls the sources in this
 * order: SSP, timer0, timer1, UART RX, UART TX. XC8 does the context save.
 */
#include "hw.h"
#include "fw.h"

/* 0x1E5B: one SPI byte exchanged with the power board */
static void isr_ssp(void)
{
    PIR1bits.SSPIF = 0;
    spi_rx[spi_idx] = SSPBUF;
    spi_idx++;

    if (spi_idx < spi_len) {
        /* the next byte is sent by the timer0 ISR after ~1.7 ms */
        spi_gap = 9;
        return;
    }

    PIE1bits.SSPIE = 0;
    link.spi_rx_done = 1;
    link.spi_busy = 0;
}

/* 0x1F97: ~192 us system tick */
static void isr_timer0(void)
{
    TMR0 = 0xFD;
    INTCONbits.T0IF = 0;

    /* Buzzer. It only sounds when the power board allows it (pb_flags1.2).
     * Writing BEEP_SHORT or BEEP_LONG to `beep` starts it; it stops when
     * the 5 ms countdown below reaches 0. */
    if ((pb_flags1 & 0x04) && (beep == BEEP_SHORT || beep == BEEP_LONG)) {
        CCP1CON = 0xAC;
        T2CONbits.TMR2ON = 1;
    } else if (!(pb_flags1 & 0x04) || beep == 0 || beep == BEEP_ARMED) {
        T2CONbits.TMR2ON = 0;
        CCP1CON = 0x00;
        BUZZER = 1;
    }
    /* else: keep sounding */

    /* SPI byte pacing */
    if (spi_gap != 0 && --spi_gap == 0)
        SSPBUF = spi_tx[spi_idx];

    /* EEPROM write cycle (tWR = 5 ms) */
    if (eeprom_busy != 0)
        eeprom_busy--;

    /* OK/ESC LEDs: 50 % PWM when lit */
    fx.led_phase = !fx.led_phase;
    LED_OK_N  = !((led_out & 0x01) && fx.led_phase);
    LED_ESC_N = !((led_out & 0x02) && fx.led_phase);

    /* any key or encoder activity restarts the idle timer */
    if (enc.act_a || enc.act_b || keys_count != 0) {
        idle_tmr = 3;
        fx.idle = 0;
    }

    if (kbd_delay != 0)
        kbd_delay--;

    if (--div_5ms == 0) {
        div_5ms = 26;
        tick.isr_5ms = 1;
        if (beep != 0 && beep != BEEP_ARMED)
            beep--;
    }
}

/* 0x1EBF: ~430 us, LCD backlight dimming */
static void isr_timer1(void)
{
    PIR1bits.TMR1IF = 0;
    TMR1H = 0xFC;
    TMR1L = 0xA3;

    if (!disp.backlight_pwm) {
        BACKLIGHT_N = 1;                    /* off */
        return;
    }

    /* on for one slot out of bl_pwm_top + 1 */
    if (pb_flags1 & 0x40)
        bl_pwm_top = 1;                     /* 50 %  */
    else if ((pb_state & 0x3F) == 0 && (pb_flags3 & 0x18))
        bl_pwm_top = 2;                     /* 33 %  (standby with an alarm)     */
    else
        bl_pwm_top = 0;                     /* 100 % */

    if (bl_pwm_cnt == 0)
        BACKLIGHT_N = 0;
    else if (bl_pwm_cnt == 1 || bl_pwm_cnt == 2)
        BACKLIGHT_N = 1;

    if (bl_pwm_cnt < bl_pwm_top)
        bl_pwm_cnt++;
    else
        bl_pwm_cnt = 0;
}

/* 0x1EFE: service mode frame reception.
 * Frame: 0x0A, len (< 23), payload..., XOR checksum at index len. */
static void isr_uart_rx(void)
{
    uint8_t c;

    if (RCSTAbits.FERR || RCSTAbits.OERR) {
        RCSTAbits.CREN = 0;
        c = RCREG;
        uart_rx_idx = 0;                    /* drop the frame */
        RCSTAbits.CREN = 1;
        return;
    }

    c = RCREG;
    if (link.uart_rx_ready || link.uart_tx_busy)
        return;

    uart_rx_to = 2;                         /* 10 ms inter-byte timeout */

    if (uart_rx_idx == 0) {
        if (c == 0x0A) {
            uart_buf[0] = c;
            uart_rx_idx++;
        }
    } else if (uart_rx_idx == 1) {
        if (c < 0x17) {
            uart_buf[1] = c;
            uart_rx_idx++;
            uart_rx_len = c;
        } else {
            uart_rx_idx = 0;
        }
    } else {
        uart_buf[uart_rx_idx] = c;
        uart_rx_idx++;
        if (uart_rx_idx > uart_rx_len)
            link.uart_rx_ready = 1;
    }
}

/* 0x19C4: service mode reply transmission */
static void isr_uart_tx(void)
{
    if (uart_tx_idx < uart_tx_len) {
        TXREG = uart_buf[uart_tx_idx];
        uart_tx_idx++;
    } else {
        PIE1bits.TXIE = 0;
        uart_tx_to = 2;                     /* release RX 10 ms after the end */
    }
}

void __interrupt() isr(void)
{
    if (PIR1bits.SSPIF && PIE1bits.SSPIE)
        isr_ssp();
    if (INTCONbits.T0IF && INTCONbits.T0IE)
        isr_timer0();
    if (PIR1bits.TMR1IF && PIE1bits.TMR1IE)
        isr_timer1();
    if (PIR1bits.RCIF && PIE1bits.RCIE)
        isr_uart_rx();
    if (PIR1bits.TXIF && PIE1bits.TXIE)
        isr_uart_tx();
}
