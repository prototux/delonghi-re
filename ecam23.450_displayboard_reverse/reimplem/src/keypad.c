/*
 * Keypad matrix scan (0x12CB MAINLOOP_SUB2).
 *
 * Rows RA0..RA2 are driven low one at a time, columns RB5..RB7 are read; a
 * fourth phase reads the encoder push button on RC2. One phase runs every
 * 10 timer0 ticks (~2 ms), so a full scan takes ~8 ms. A key is reported
 * once it is seen in two consecutive full scans.
 *
 *          RB6        RB7         RB5
 *   RA0    ON/OFF     MENU/P
 *   RA1    CLEAN      HOT WATER
 *   RA2    2 CUPS     1 CUP       CAPPUCCINO
 *   (RC2   encoder push)
 */
#include "hw.h"
#include "fw.h"

#define BIT(v, n, cond)  ((v) = (uint8_t)(((v) & ~(1u << (n))) | ((cond) ? (1u << (n)) : 0u)))

void keypad_scan(void)
{
    uint8_t k, n;

    INTCONbits.T0IE = 0;
    if (kbd_delay != 0)
        goto out;
    kbd_delay = 10;

    if (kbd_row >= 4)
        kbd_row = 0;

    PORTA |= KBD_ROW_MASK;
    switch (kbd_row) {
    case 0:
        PORTAbits.RA0 = 0;
        BIT(keys_raw, 0, KBD_COL6);     /* ON/OFF    */
        BIT(keys_raw, 1, KBD_COL7);     /* MENU/P    */
        kbd_row++;
        break;
    case 1:
        PORTAbits.RA1 = 0;
        BIT(keys_raw, 2, KBD_COL6);     /* CLEAN     */
        BIT(keys_raw, 3, KBD_COL7);     /* HOT WATER */
        kbd_row++;
        break;
    case 2:
        PORTAbits.RA2 = 0;
        BIT(keys_raw, 4, KBD_COL6);     /* 2 CUPS    */
        BIT(keys_raw, 5, KBD_COL7);     /* 1 CUP     */
        BIT(keys_raw, 6, KBD_COL5);     /* CAPPUCCINO */
        kbd_row++;
        break;
    case 3:
        BIT(keys_raw, 7, ENC_PUSH);     /* encoder push */
        kbd_row++;
        break;
    }

    if (kbd_row < 4)
        goto out;

    /* full scan done: debounce */
    keys = keys_raw & keys_prev;
    keys_prev = keys_raw;
    INTCONbits.T0IE = 1;

    n = 0;
    for (k = keys; k != 0; k >>= 1)
        n += k & 1;
    keys_count = n;

    /* Key bitmap sent to the power board (SPI byte 1 and byte 7) */
    tx_keys = 0;
    if (keys & KEY_1CUP)     tx_keys |= 0x01;
    if (keys & KEY_2CUPS)    tx_keys |= 0x02;
    if (keys & KEY_HOTWATER) tx_keys |= 0x04;
    if (keys & KEY_MENU)     tx_keys |= 0x08;
    if (keys & KEY_ONOFF)    tx_keys |= 0x10;
    if (keys & KEY_CAPPU)    tx_keys |= 0x40;
    if (keys & KEY_CLEAN)    tx_keys |= 0x80;
    tx_keys_hi = (keys & KEY_ENC_PUSH) ? 0x02 : 0x00;

out:
    INTCONbits.T0IE = 1;
}
