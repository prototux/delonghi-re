/*
 * Global firmware state of the ECAM 23.450 display board (PIC16F916).
 *
 * Every variable of the original firmware lives here, with the RAM address it
 * had in the original image (bank:address) so the C can be checked against
 * tools/pic14dis.py listings. Names follow tools/symbols.py.
 *
 * Bits whose purpose is still unknown are called bN and documented with
 * where they are set and tested.
 */
#ifndef STATE_H
#define STATE_H

#include <stdint.h>

/* ------------------------------------------------------------------------- */
/* Flag registers                                                            */
/* ------------------------------------------------------------------------- */

/* 0x02C: scheduler ticks and input events */
typedef union {
    uint8_t all;
    struct {
        unsigned started      : 1; /* startup delay (150 ms) elapsed: main loop runs the UI  */
        unsigned isr_5ms      : 1; /* set by the timer0 ISR every 5 ms, consumed by timebase */
        unsigned t5ms         : 1; /* 5 ms tick (valid for one main loop pass)               */
        unsigned t50ms        : 1; /* 50 ms tick                                             */
        unsigned t500ms       : 1; /* 500 ms tick                                            */
        unsigned enc_cw       : 1; /* encoder turned one detent clockwise                    */
        unsigned enc_ccw      : 1; /* encoder turned one detent counter-clockwise            */
        unsigned field_active : 1; /* the 10 char "field" overlay is shown (clock, numbers)  */
    };
} tick_t;

/* 0x02D: power board links (SPI + UART) */
typedef union {
    uint8_t all;
    struct {
        unsigned b0           : 1; /* never written, always 0; tested by ui_main            */
        unsigned i2c_dummy    : 1; /* toggled by softi2c_delay() only                        */
        unsigned uart_tx_busy : 1; /* UART reply being sent, RX is ignored                  */
        unsigned uart_rx_ready: 1; /* a complete UART frame waits in uart_buf               */
        unsigned spi_busy     : 1; /* SPI frame exchange in progress                         */
        unsigned spi_rx_done  : 1; /* SPI frame exchange finished, spi_rx is valid          */
        unsigned blink_1hz    : 1; /* toggles every 500 ms                                   */
        unsigned alarm_active : 1; /* an alarm screen is up (beep again when it clears)     */
    };
} link_t;

/* 0x02E: user interface */
typedef union {
    uint8_t all;
    struct {
        unsigned b0           : 1;
        unsigned b1           : 1;
        unsigned b2           : 1; /* ui_main: state 0x02/0x09 with param1==5 && param2.7  */
        unsigned scroll       : 1; /* line 2 shows a scrolling (marquee) text               */
        unsigned scroll_step  : 1; /* time to shift the marquee by one char                 */
        unsigned b5           : 1; /* "attention" screen up: holds tmr_cb (see Coralie)     */
        unsigned clock_valid  : 1; /* the RTC holds a time that was set by the user          */
        unsigned link_lost    : 1; /* no valid SPI frame from the power board for 2.5 s      */
    };
} ui_t;

/* 0x02F: miscellaneous */
typedef union {
    uint8_t all;
    struct {
        unsigned b0           : 1;
        unsigned blink_800ms  : 1; /* toggles every 800 ms                                   */
        unsigned first_run    : 1; /* first pass of service(): decide UART service mode     */
        unsigned spi_toggle   : 1; /* toggled on every SPI frame, never read                */
        unsigned uart_mode    : 1; /* service (UART) mode active, SPI frames suspended      */
        unsigned progress     : 1; /* show the progress bar (pb_b9) on line 2               */
        unsigned alarm_armed  : 1; /* no alarm was shown last pass (beep on next alarm)     */
        unsigned b7           : 1;
    };
} misc_t;

/* 0x030: display effects */
typedef union {
    uint8_t all;
    struct {
        unsigned led_phase    : 1; /* toggled by every timer0 interrupt: LED 50% PWM         */
        unsigned b1           : 1; /* set/cleared by ui_main, read by ui_alarm              */
        unsigned lcd_busy     : 1; /* display_refresh() is in the middle of a line          */
        unsigned field_clear  : 1; /* the field overlay has been blanked on the LCD         */
        unsigned b4           : 1; /* set by the menu editor, cleared by timebase (500 ms)  */
        unsigned idle         : 1; /* no key/encoder activity for idle_tmr (1.5 s)          */
        unsigned b6           : 1; /* menu editor: first entry into "hour" edit             */
        unsigned b7           : 1; /* menu editor: first entry into "minute" edit           */
    };
} fx_t;

/* 0x190 (bank 3): display */
typedef union {
    uint8_t all;
    struct {
        unsigned b0           : 1;
        unsigned b1           : 1;
        unsigned blink_250ms  : 1; /* toggles every 250 ms: LED blinking                    */
        unsigned b3           : 1;
        unsigned backlight_pwm: 1; /* backlight controlled by timer1 (else forced off)      */
        unsigned b5           : 1;
        unsigned blink_250ms_b: 1; /* toggles every 250 ms: field digits blinking           */
        unsigned standby      : 1; /* standby screen: count down dim_timer                  */
    };
} disp_t;

/* 0x03D: rotary encoder */
typedef union {
    uint8_t all;
    struct {
        unsigned b0           : 1;
        unsigned dir_ccw      : 1; /* current detent started with B (counter-clockwise)     */
        unsigned a            : 1; /* sampled RC0                                            */
        unsigned b            : 1; /* sampled RC1                                            */
        unsigned dir_cw       : 1; /* current detent started with A (clockwise)             */
        unsigned act_a        : 1; /* activity: A seen first                                */
        unsigned act_b        : 1; /* activity: B seen first                                */
        unsigned b7           : 1;
    };
} enc_t;

/* Debounced keys (keys, keys_raw, keys_prev): one bit per matrix position */
#define KEY_ONOFF     0x01  /* RA0 x RB6 */
#define KEY_MENU      0x02  /* RA0 x RB7 */
#define KEY_CLEAN     0x04  /* RA1 x RB6 */
#define KEY_HOTWATER  0x08  /* RA1 x RB7  - also "OK" when setting the clock */
#define KEY_2CUPS     0x10  /* RA2 x RB6 */
#define KEY_1CUP      0x20  /* RA2 x RB7 */
#define KEY_CAPPU     0x40  /* RA2 x RB5 */
#define KEY_ENC_PUSH  0x80  /* RC2       */

/* ------------------------------------------------------------------------- */
/* Bank 0                                                                    */
/* ------------------------------------------------------------------------- */
extern volatile uint8_t pb_flags3;      /* 0x023 SPI rx[6]                                  */
extern uint8_t last_pb_flags3;          /* 0x024 pb_flags3 & 0xde when "descaling" screen   */
extern uint8_t tx_keys;                 /* 0x025 SPI tx[1]: remapped key bitmap              */
extern uint8_t tx_keys_hi;              /* 0x026 SPI tx[7] bits 0-2                          */
extern uint8_t kbd_row;                 /* 0x029 keypad scan phase 0..3                      */
extern uint8_t pb_flags4;               /* 0x02A SPI rx[7]: alarms                           */
extern uint8_t pb_flags5;               /* 0x02B SPI rx[8]                                   */
extern volatile tick_t tick;            /* 0x02C */
extern volatile link_t link;            /* 0x02D */
extern volatile ui_t ui;                /* 0x02E */
extern volatile misc_t misc;            /* 0x02F */
extern volatile fx_t fx;                /* 0x030 */
extern uint8_t keys_raw;                /* 0x032 keypad sample being built                   */
extern uint8_t keys_prev;               /* 0x033 previous full sample                        */
extern volatile uint8_t pb_flags1;      /* 0x036 SPI rx[4]                                   */
extern uint8_t pb_flags2;               /* 0x037 SPI rx[5]                                   */
extern uint8_t pb_b8_hi;                /* 0x038 (SPI rx[8] >> 2) & 7                        */
extern uint8_t pb_b8_lo;                /* 0x039 SPI rx[8] & 3                               */
extern volatile uint8_t pb_state;       /* 0x03A SPI rx[1]: machine state (bits 0-5) + flags */
extern uint8_t pb_param1;               /* 0x03B SPI rx[2]                                   */
extern uint8_t pb_param2;               /* 0x03C SPI rx[3]                                   */
extern volatile enc_t enc;              /* 0x03D */
extern uint8_t keys;                    /* 0x03E debounced keys (KEY_*)                      */
extern volatile uint8_t spi_idx;        /* 0x040 */
extern volatile uint8_t spi_len;        /* 0x041 */
extern uint8_t line1_loaded;            /* 0x042 message whose text is in line_buf (line 1)  */
extern uint8_t line2_loaded;            /* 0x043 idem, line 2                                */
extern volatile uint8_t spi_gap;        /* 0x044 timer0 ticks before the next SPI byte       */
extern volatile uint8_t eeprom_busy;    /* 0x045 timer0 ticks until the EEPROM write is done */
extern uint8_t last_language;           /* 0x046 */
extern uint8_t line1_msg;               /* 0x047 message wanted on line 1                    */
extern uint8_t line2_msg;               /* 0x048 message wanted on line 2                    */
extern uint8_t last_pb3_alarm;          /* 0x049 (pb_flags3 | 0xde) seen by ui_alarm         */
extern uint8_t blink_presc;             /* 0x068 250 ms prescaler (initialised to 50)        */

/* ------------------------------------------------------------------------- */
/* Bank 1                                                                    */
/* ------------------------------------------------------------------------- */
extern uint8_t led_on;                  /* 0x0A0 bit0: OK LED, bit1: ESC LED                 */
extern uint8_t rtc_hour;                /* 0x0A1 BCD                                          */
extern uint8_t edit_hour;               /* 0x0A2 BCD, hour shown in the clock field          */
extern uint8_t i2c_err;                 /* 0x0A4 0xff after a NACK (never read)              */
extern uint8_t line1_col;               /* 0x0A5 refresh position in line 1 (0,5,10,15)      */
extern uint8_t line2_col;               /* 0x0A6 */
extern uint8_t scroll_pos;              /* 0x0A7 marquee offset                              */
extern uint8_t language;                /* 0x0A9 language index (from the power board)       */
extern uint8_t eecfg_2;                 /* 0x0AA EEPROM[2] if EEPROM[3] == ~EEPROM[2]         */
extern uint8_t rtc_min;                 /* 0x0AB BCD */
extern uint8_t edit_min;                /* 0x0AC BCD */
extern uint8_t keys_count;              /* 0x0AD number of keys held                         */
extern uint8_t rtc_sec;                 /* 0x0AE BCD */
extern uint8_t line1_chunk;             /* 0x0AF 5-char chunks of line 1 already written     */
extern uint8_t line2_chunk;             /* 0x0B0 */
extern uint8_t field_cmd;               /* 0x0B1 LCD position of the field overlay           */
extern uint8_t led_blink;               /* 0x0B2 LEDs that blink (subset of led_on)          */
extern volatile uint8_t beep;           /* 0x0B3 buzzer: 0x0a/0x32 start, counts to 0, 0xff=armed */
extern volatile uint8_t led_out;        /* 0x0B4 LEDs actually lit this 5 ms                 */
extern uint8_t div_50ms;                /* 0x0B5 */
extern volatile uint8_t div_5ms;        /* 0x0B6 */
extern uint8_t div_500ms;               /* 0x0B7 */
extern uint8_t dim_timer;               /* 0x0B8 500 ms units before the backlight goes off  */
extern volatile uint8_t kbd_delay;      /* 0x0B9 timer0 ticks between keypad row scans       */
extern uint8_t line1_shown;             /* 0x0BA message currently on line 1 (0xff: redraw)  */
extern uint8_t line2_shown;             /* 0x0BB */
extern uint8_t spi_period;              /* 0x0BD 5 ms ticks until the next SPI frame         */
extern uint8_t startup_delay;           /* 0x0BE */
extern volatile uint8_t uart_rx_to;     /* 0x0BF */
extern volatile uint8_t uart_tx_to;     /* 0x0C0 */
extern uint8_t pb26_a, pb26_b;          /* 0x0C1, 0x0C6 state 0x26 params (never read)      */
extern volatile uint8_t uart_rx_idx;    /* 0x0C2 */
extern volatile uint8_t uart_rx_len;    /* 0x0C3 */
extern volatile uint8_t uart_tx_idx;    /* 0x0C4 */
extern volatile uint8_t uart_tx_len;    /* 0x0C5 */
extern uint8_t tmr_c7;                  /* 0x0C7 50 ms: line 1 periodic redraw               */
extern uint8_t tmr_c8;                  /* 0x0C8 50 ms: line 2 periodic redraw               */
extern uint8_t tmr_c9;                  /* 0x0C9 50 ms: standby backlight                    */
extern uint8_t link_timeout;            /* 0x0CA 50 ms: power board link watchdog            */
extern uint8_t tmr_cb;                  /* 0x0CB 50 ms: "attention" screen timer             */
extern uint8_t scroll_len;              /* 0x0CC marquee text length                         */
extern uint8_t tmr_cd;                  /* 0x0CD 500 ms: periodic LCD re-init                */
extern uint8_t uart_timeout;            /* 0x0CE 500 ms: leave service mode when 0           */
extern uint16_t num;                    /* 0x0D5/0x0D6 number shown by format_number()     */
extern uint16_t ee_sum;                 /* 0x0D7/0x0D8 EEPROM checksum (service cmd 0x26)    */
extern uint16_t ee_size;                /* 0x0D9/0x0DA 0x4000 or 0x8000                      */
extern uint8_t ee_addr_lo, ee_addr_hi;  /* 0x0DB/0x0DC                                        */
extern uint8_t pb25_a, pb25_b;          /* 0x0DD/0x0DE state 0x25 params (never read)       */
extern uint16_t scroll_tmr;             /* 0x0DF/0x0E0 5 ms: marquee step                    */
extern uint8_t pb27_a, pb27_b;          /* 0x0E1/0x0E2 state 0x27 params (never read)       */
extern uint8_t pb24_a, pb24_b;          /* 0x0E3/0x0E4 state 0x24 params (never read)       */
extern volatile uint8_t bl_pwm_cnt;     /* 0x0E5 */
extern volatile uint8_t bl_pwm_top;     /* 0x0E6 */
extern uint8_t div_800ms;               /* 0x0E7 */

/* ------------------------------------------------------------------------- */
/* Bank 2 / 3                                                                */
/* ------------------------------------------------------------------------- */
extern uint8_t enc_count;               /* 0x120 encoder position, sent to the power board   */
extern uint8_t eecfg_0;                 /* 0x121 EEPROM[0] (number of languages?)            */
extern uint8_t pb_b9;                   /* 0x123 SPI rx[9]: progress 0..100                  */
extern uint8_t enc_step;                /* 0x124 quadrature step inside a detent (0..3)      */
extern uint8_t enc_pos;                 /* 0x125 0: idle, 1: A, 2: B, 3: A+B                 */
extern volatile uint8_t idle_tmr;       /* 0x126 500 ms units                                */
extern uint8_t field[10];               /* 0x127 10 char overlay (clock, numbers, bars)      */
extern volatile uint8_t spi_rx[11];     /* 0x131 */
extern volatile uint8_t spi_tx[11];     /* 0x13C */
extern uint8_t i2c_buf[16];             /* 0x147 I2C block transfer buffer                   */
extern volatile uint8_t uart_buf[23];   /* 0x157 UART frame (RX and TX share it)             */
extern volatile disp_t disp;            /* 0x190 */
extern uint8_t field_shadow[10];        /* 0x191 what the LCD shows at field_cmd             */
extern uint8_t line_buf[20];            /* 0x19B text of the line being refreshed            */
extern uint8_t scroll_buf[64];          /* 0x1AF marquee text (scroll_len chars, up to 0x1EF) */

#endif
