/*
 * Startup and main loop (0x0070 main + 0x1004, 0x1F47 init_hardware_1,
 * 0x1E8B init_hardware_2).
 *
 * The main loop is a plain superloop. Timing comes from the 5 ms tick the
 * timer0 interrupt raises (see timebase.c). Every pass polls the inputs and
 * the power board link; once the 150 ms startup delay has elapsed it also
 * runs the service tasks (RTC, service mode entry) and the UI.
 */
#include "hw.h"
#include "fw.h"

/* Configuration word at 0x2007 = 0x33CC:
 * INTOSCIO (RA6/RA7 are I/O), WDT on, power-up timer on, MCLR is RE3 input,
 * no code protection, BOR on, IESO/FCMEN off, debugger off. */
#pragma config FOSC = INTOSCIO, WDTE = ON, PWRTE = ON, MCLRE = OFF
#pragma config CP = OFF, CPD = OFF, BOREN = ON, IESO = OFF, FCMEN = OFF, DEBUG = OFF

/* 0x1F47: put every peripheral in a known state, interrupts off */
static void hw_init(void)
{
    INTCONbits.GIE = 0;
    INTCONbits.PEIE = 0;

    OSCCON = 0x70;          /* 8 MHz internal oscillator                         */
    OPTION_REG = 0xC6;      /* no PORTB pull-ups, TMR0 on Fosc/4, prescaler 1:128 */
    INTCON = 0x00;
    PIE1 = 0x00;
    PIE2 = 0x00;
    PCON = 0x00;
    PIR1 = 0x00;
    PIR2 = 0x00;
    WPUB = 0x00;
    TRISA = 0x00;           /* all outputs                                       */
    TRISB = 0xE0;           /* RB5..RB7 keypad columns in, I2C and control out   */
    IOCB = 0x00;
    TMR0 = 0xFD;
    INTCONbits.T0IE = 0;
    T1CON = 0x01;           /* timer1 on, Fosc/4, 1:1                            */
    PIE1bits.TMR1IE = 0;
    TMR2 = 0x00;
    TRISC = 0x87;           /* RC0..RC2 encoder in, RC7 RX/SDI in, rest out      */
    T2CON = 0x01;           /* timer2 prescaler 1:4, stopped                     */
    CCP1CON = 0xAC;         /* PWM                                               */
    ADCON1 = 0x50;
    ADCON0 = 0x00;
    ANSEL = 0x00;           /* all digital                                       */
    LCDCON = 0x00;          /* internal LCD driver unused                        */
    LCDSE0 = 0x00;
    LCDSE1 = 0x00;
    /* LCDSE2 (0x11E) only exists on the 40-pin PIC16F917; the original clears
       it anyway (CLRF 0x11E), which is harmless on the PIC16F916. */
    *(volatile uint8_t *)0x11E = 0x00;
    LVDCON = 0x00;
    SSPSTAT = 0x00;
    SSPCON = 0x00;
    EECON1 = 0x00;
    CMCON0 = 0xFF;          /* comparators off                                   */
    VRCON = 0x00;

    keys = 0;
    keys_raw = 0;
    keys_prev = 0;
    led_on = 0;
    led_out = 0;
    led_blink = 0;
    disp.all = 0;
}

/* 0x1E8B: start the timers and the buzzer PWM, reset the software timers */
static void timers_init(void)
{
    OPTION_REG = 0xC6;
    TMR0 = 0xFD;            /* 3 x 64 us = ~192 us per timer0 interrupt          */
    INTCONbits.T0IF = 0;
    INTCONbits.T0IE = 1;

    T1CON = 0x01;
    TMR1L = 0xA3;           /* 0x10000 - 0xFCA3 = 861 x 0.5 us = ~430 us          */
    TMR1H = 0xFC;
    PIR1bits.TMR1IF = 0;
    PIE1bits.TMR1IE = 1;

    CCP1CON = 0xAC;         /* buzzer: PWM period (PR2+1)*16 = 252 us (~3.97 kHz), */
    PR2 = 0x7D;             /* duty 50 %. timer2 is started by the timer0 ISR    */
    CCPR1L = 0x3E;
    T2CON = 0x01;

    div_5ms = 26;
    div_50ms = 10;
    div_500ms = 10;
    startup_delay = 30;     /* x 5 ms                                            */
    tmr_c9 = 30;
    tmr_cb = 60;
    tmr_c7 = 50;
    tmr_c8 = 50;
    tmr_cd = 30;
    kbd_delay = 10;
}

void main(void)
{
    /* 0x0070: the C runtime clears RAM and loads blink_presc and div_800ms
     * (see state.c), then jumps to 0x1004. */
    link.alarm_active = 0;
    misc.alarm_armed = 1;
    disp.backlight_pwm = 0;
    beep = 0;
    tick.started = 0;

    CLRWDT();
    delay_ms(30);

    hw_init();
    BACKLIGHT_N = 1;        /* backlight off until the UI takes over */
    CLRWDT();
    timers_init();
    rtc_init();
    lcd_init(0);
    eeprom_load_config();

    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    for (;;) {
        CLRWDT();
        timebase_update();
        CLRWDT();
        keypad_scan();
        CLRWDT();
        encoder_poll();
        CLRWDT();
        link_update();
        CLRWDT();

        if (tick.started) {
            service_update();
            CLRWDT();
            ui_update();
            CLRWDT();
        }
    }
}
