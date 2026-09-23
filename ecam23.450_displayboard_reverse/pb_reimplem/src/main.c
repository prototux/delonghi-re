/*
 * Startup and main loop (0x0018 startup, 0x6100 main, 0x6158 hw_init,
 * 0x3146 state_vars_init, 0x61B6 initial_state, 0x636A wdt_kick,
 * 0x0FF6 nop_hook, 0x0FF8 loop_count).
 *
 * 0x0018 startup is the compiler runtime: it clears RAM 0x00F-0x07B,
 * 0x08C-0x0FF and 0xE4A-0xF62 (the .bss) and jumps to main.
 *
 * The main loop is a superloop. The first four tasks always run; the rest
 * only once the 0.8 s startup delay has elapsed (sysflags.2). Every task
 * increments loop_tasks and the watchdog is only cleared when the count is
 * exactly the expected one, so a task that stops running resets the chip.
 */
#include "pb.h"

/* Configuration (0x300000: 00 08 16 0F 00 01 81 00 0F C0 0F E0 0F 40):
 * internal oscillator with RA6/RA7 as I/O, power-up timer, brown-out reset
 * (hardware only, 2.8 V), watchdog 1:128 (~0.5 s), MCLR off (RE3 input),
 * PORTB digital at reset, LVP off, no extended instructions, no protection. */
#pragma config OSC = INTIO67, FCMEN = OFF, IESO = OFF
#pragma config PWRT = ON, BOREN = SBORDIS, BORV = 2
#pragma config WDT = ON, WDTPS = 128
#pragma config CCP2MX = PORTC, PBADEN = OFF, LPT1OSC = OFF, MCLRE = OFF
#pragma config STVREN = ON, LVP = OFF, XINST = OFF
#pragma config CP0 = OFF, CP1 = OFF, CP2 = OFF, CPB = OFF, CPD = OFF
#pragma config WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRTC = OFF, WRTB = OFF, WRTD = OFF
#pragma config EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTRB = OFF

/* sysflags */
#define SYS_STARTED 0x04

/* 0x6158 */
static void hw_init(void)
{
    RCONbits.IPEN = 0;          /* single interrupt priority                   */
    OSCCON = 0x72;              /* 8 MHz internal oscillator                   */
    OSCTUNE = 0x80;             /* INTSRC, PLL off                             */
    RCON = 0x13;
    INTCON = 0x00;
    INTCON2 = 0x85;             /* no PORTB pull-ups, TMR0 high priority       */
    INTCON3 = 0xC0;
    PIE1 = 0x00;
    PIE2 = 0x00;
    PIR1 = 0x00;
    PIR2 = 0x00;
    IPR1 = 0xFF;
    IPR2 = 0x1F;
    HLVDCON = 0x05;
    PORTA = 0x00;
    TRISA = 0xEF;               /* RA4 output, the rest inputs                 */
    PORTB = 0x2C;               /* motor gates RB2/RB5 off (active low), RB3   */
    TRISB = 0xD3;               /* RB2, RB3, RB5 outputs                       */
    PORTC = 0x40;
    TRISC = 0x9F;               /* RC5 SDO, RC6 TX outputs                     */
    PORTD = 0x00;
    TRISD = 0x01;               /* RD1..RD7 loads, RD0 input                   */
    PORTE = 0x00;
    TRISE = 0x0F;
    CLRWDT();
}

/* 0x0FF6: empty */
static void nop_hook(void)
{
}

/* 0x0FF8: one more task for the watchdog count */
static void loop_count(void)
{
    loop_tasks++;
}

/* 0x3146 */
static void state_vars_init(void)
{
    heatA_state = 0;
    heatB_state = 0;
    pump_state = 0;
    bu_state = 0;
    grind_state = 0;
    test_step = 0;
    saved_mstate = 0;
    saved_mstep = 2;
    wake_reason = 0;
    taste = 0x30;
    drink = 4;
    re6f = 1;
    ree5 = re6f;
    flow_avg = 9;
    portd_req = 0;
    sensor_events |= 0x40;
    flags25 |= 0x01;            /* power-up key combos pending (state_control) */
}

/* 0x61B6: first state after reset */
static void initial_state(void)
{
    if (set_fault) {
        /* a fault was stored in the EEPROM: start in the fault state, off */
        alarms2 |= 0x40;
        step_timer = 10;
        fault_class = 1;
        fault_step = 0;
        mstate = 0;
        mstep = 2;
    } else {
        mstep = 0;
        fault_step = 0;
        fault_class = 0;
        if (!(language & 0x10)) {
            /* language never chosen: first start, language selection */
            mstate = 0x0D;
            lang_cycle_timer2 = 30;
            lang_cycle_timer = 30;
        } else if (settings2 & 0x01) {
            mstate = 0x0E;
        } else {
            mstate = 0;
        }
    }
}

/* 0x636A: clear the watchdog only after a complete main loop pass */
static void wdt_kick(uint8_t tasks)
{
    if ((!(sysflags & SYS_STARTED) && tasks == 4) ||
        ((sysflags & SYS_STARTED) && tasks == 10))
        CLRWDT();
}

/* 0x6100 */
void main(void)
{
    INTCONbits.GIE = 0;
    hw_init();
    nop_hook();
    state_vars_init();
    ee_load();
    initial_state();
    timers_init();
    zc_watch_init();
    inputs_clear();
    adc_init();
    comms_init();
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    for (;;) {
        loop_tasks = 0;
        timebase();
        inputs_task();
        adc_task();
        comms_update();
        if (sysflags & SYS_STARTED) {
            monitor_faults();
            state_control();
            loop_count();
            ee_save_task();
            power_task();
            outputs_task();
        }
        wdt_kick(loop_tasks);
    }
}
