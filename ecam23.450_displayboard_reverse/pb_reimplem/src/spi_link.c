/*
 * Link with the display board (SPI slave) and comms init (0x4ACC..0x51E8,
 * 0x5F7A..0x604A).
 *
 * The display board is the SPI master: mode 3 (CKP=1, CKE=0), 125 kHz, no
 * chip select. Every ~30 ms it clocks an 11 byte frame in (header 0xB0)
 * while clocking our 11 byte frame out (header 0x0B), one byte every
 * ~1.7 ms. See docs/protocol.md and docs/pb_notes/comms.md.
 *
 * Latency: the reply is built right after frame N is validated and is
 * clocked out during frame N+1.
 */
#include "pb.h"

/* flags26 */
#define F26_SPI_FRAME   0x08    /* complete frame received, not processed yet */
#define F26_MENU        0x20    /* in the settings menu                        */
#define F26_MENU_OPEN   0x40    /* a menu item is open                         */
/* flags28 */
#define F28_CLOCK_VALID 0x01    /* display RTC valid (rx[7].7)                 */
#define F28_PROG_QTY    0x04    /* programming the coffee quantity             */
/* flags1d */
#define F1D_CAPPU       0x01    /* cappuccino (coffee after milk)              */
#define F1D_DESCALE_RUN 0x08    /* descaling underway (state 4)                */
#define F1D_PROG        0x10    /* programming milk / hot water quantity       */
/* tickflags */
#define TF_UART_FRAME   0x02    /* UART request received                       */
/* sysflags */
#define SF_UART_TOGGLE  0x02    /* alternates the 0x80 / 0x81 replies          */

/* 0x4ACC: EUSART (19200 baud) and MSSP (SPI slave) set-up */
void comms_init(void)
{
    BAUDCON = 0x08;             /* BRG16                                    */
    SPBRG = 0x67;               /* 8 MHz / (4 * 104) = 19231 baud           */
    TXSTA = 0x65;               /* TX9, TXEN, BRGH, TX9D = 1 ("8N2")        */
    RCSTA = 0x90;               /* SPEN, CREN                               */
    SSPCON1 = 0x15;             /* SPI slave, SS disabled, CKP = 1          */
    SSPSTAT = 0x00;             /* CKE = 0, SMP = 0                         */
    (void)SSPBUF;
    SSPCON1bits.SSPEN = 1;
    PIR1bits.SSPIF = 0;
    PIE1bits.SSPIE = 1;
    (void)RCREG;
    PIE1bits.RCIE = 1;
    INTCONbits.PEIE = 1;
    PIE1bits.TXIE = 0;
}

/* 0x5F7A: 0x55 + sum (add != 0, SPI) or 0x55 ^ xor (add == 0, UART) */
uint8_t checksum(const volatile uint8_t *buf, uint8_t len, uint8_t add)
{
    uint8_t i, sum = 0x55;

    for (i = 0; i < len; i++) {
        if (add == 0)
            sum ^= buf[i];
        else
            sum += buf[i];
    }
    return sum;
}

/* 0x5FBE: MSSP interrupt, one byte exchanged with the display board.
 * The byte clocked out while rx[n] comes in is tx[n]: tx[0] is preloaded. */
void isr_spi(void)
{
    uint8_t b;

    PIR1bits.SSPIF = 0;
    b = SSPBUF;
    if (SSPCON1bits.WCOL)
        SSPCON1bits.WCOL = 0;

    if (SSPCON1bits.SSPOV) {
        SSPCON1bits.SSPOV = 0;
        spi_idx = 0;
        spi_resync_timer = 15;
        return;
    }
    if (flags26 & F26_SPI_FRAME)        /* previous frame not processed yet */
        return;

    if (spi_idx == 0) {
        /* Resynchronise on the header: until 0xB0 arrives we keep
         * offering tx[0] (0x0B). */
        if (b == 0xB0) {
            spi_rx[0] = b;
            spi_idx++;
            spi_last = 10;
        }
        SSPBUF = spi_tx[spi_idx];
    } else {
        spi_rx[spi_idx] = b;
        spi_idx++;
        /* After the last byte (idx 11) the original loads the byte after
         * spi_tx, i.e. uart_buf[0]: it is only clocked out if the frame is
         * then rejected (see comms_update). */
        SSPBUF = (spi_idx <= 10) ? spi_tx[spi_idx] : uart_buf[0];
        if (spi_idx > spi_last)
            flags26 |= F26_SPI_FRAME;
    }

    /* 15 ms resync timeout (isr_tmr2) runs only while a frame is incomplete */
    if (flags26 & F26_SPI_FRAME)
        spi_resync_timer = 0;
    else
        spi_resync_timer = 15;
}

/* 0x4AF4: main loop task, processes the SPI frame and the UART request */
void comms_update(void)
{
    uint8_t n, i, bits;         /* n lives in r0f5 in the original (overlaid local) */

    n = 0;
    loop_tasks++;

    if (flags26 & F26_SPI_FRAME) {
        /* Validation: checksum, key count consistent with the key bitmap,
         * time within range. Invalid frames are silently dropped. */
        if (checksum(spi_rx, 10, 0xFF) == spi_rx[10]) {
            bits = spi_rx[1];
            for (i = 0; i < 8; i++) {
                if (bits & 1)
                    n++;
                bits >>= 1;
            }
            bits = spi_rx[7];
            for (i = 0; i < 3; i++) {
                if (bits & 1)
                    n++;
                bits >>= 1;
            }
            if (((spi_rx[7] & 0x78) >> 3) == n &&
                spi_rx[4] < 24 && spi_rx[5] < 60 && spi_rx[6] < 60) {
                if (spi_rx[2] != disp_enc)
                    enc_activity = 30;
                disp_keys = spi_rx[1];
                disp_enc = spi_rx[2];
                disp_id = spi_rx[3];
                disp_hour = spi_rx[4];
                disp_min = spi_rx[5];
                disp_sec = spi_rx[6];
                disp_keys_hi = spi_rx[7] & 0x03;
                disp_eecfg = spi_rx[8];
                if (spi_rx[7] & 0x80)
                    flags28 |= F28_CLOCK_VALID;
                else
                    flags28 &= ~F28_CLOCK_VALID;
                disp_languages = spi_rx[9];
                spi_build_reply();
                link_timeout = 50;      /* x r01c.3 ticks (timebase) */
            }
        }
        /* Quirk: after a rejected frame SSPBUF still holds uart_buf[0], so the
         * next reply starts with a wrong byte and is dropped by the display. */
        spi_idx = 0;
        flags26 &= ~F26_SPI_FRAME;
    }

    /* Display link lost: release the keys, clock invalid */
    if (link_timeout == 0) {
        disp_keys = 0;
        disp_keys_hi = 0;
        flags28 &= ~F28_CLOCK_VALID;
    }

    if (tickflags & TF_UART_FRAME)
        service_dispatch();
}

/* Cup light request (flags2 bit 4), 0x50FC */
static uint8_t cup_light_on(void)
{
    if (energy_timer == 0 || !(settings & 0x08))
        return 0;
    return refa != 0 ||
           (mstate == 0x07 && mstep < 0x11 && mstep != 0) ||
           (mstate == 0x0A && mstep > 1) ||
           (mstate == 0x01 && mstep > 4 && mstep != 9) ||
           (mstate == 0x08 && mstep > 4) ||
           (mstate == 0x02 && mstep != 0) ||
           mstate == 0x0C;
}

/* 0x4D16: build the frame for the display board, spi_tx[0..10]:
 *
 *  [0] 0x0B        [4] flags1   [7] alarms
 *  [1] state       [5] flags2   [8] faults
 *  [2] param1      [6] sensors  [9] progress
 *  [3] param2                   [10] 0x55 + sum of [0..9]
 *
 * (state/param1/param2 are built in r0f7/r0f6/r0f8 in the original.)
 */
void spi_build_reply(void)
{
    uint8_t state = 0, p1 = 0, p2 = 0;
    uint16_t w;
    uint32_t q;

    if (test_timer != 0) {
        /* test modes: 0x21 display, 0x22 loads, 0x23 electric/remote, 0x24, 0x25 */
        state = test_mode + 0x20;
        p1 = test_step;
        p2 = (test_mode == 3) ? test_echo : reda;
    } else if (flags26 & F26_MENU) {
        switch (menu_item) {
        case 0:  state = 0x10; break;   /* shown blank by the display */
        case 2:  state = 0x11; break;   /* clock                       */
        case 8:  state = 0x12; break;   /* language                    */
        case 15: state = 0x29; break;   /* auto-start time             */
        case 4:  state = 0x13; break;   /* auto-start                  */
        case 1:  state = 0x14; break;   /* descale                     */
        case 5:  state = 0x15; break;   /* temperature                 */
        case 3:  state = 0x16; break;   /* auto-off                    */
        case 7:  state = 0x17; break;   /* water hardness              */
        case 13: state = 0x18; break;   /* defaults                    */
        case 10: state = 0x19; break;   /* replace filter              */
        case 9:  state = 0x1F; break;   /* filter                      */
        case 11: state = 0x26; break;   /* beep                        */
        case 12: state = 0x28; break;   /* cup light                   */
        case 6:  state = 0x27; break;   /* energy saving               */
        case 14:                        /* statistics, page menu_value */
            state = (flags26 & F26_MENU_OPEN) ? (uint8_t)(menu_value + 0x1A) : 0x1A;
            break;
        default: break;                 /* state stays 0 */
        }

        if (menu_item == 2 || menu_item == 15) {
            p1 = bin_to_bcd(menu_value);
            p2 = bin_to_bcd(menu_minutes);
            if (r01e & 0x20)            /* editing the minutes */
                p1 |= 0x80;
        } else if (menu_item == 14) {
            if (state == 0x1A) {                /* coffees */
                p1 = (uint8_t)(stat_coffee >> 8);
                p2 = (uint8_t)stat_coffee;
            } else if (state == 0x1B) {         /* descalings */
                p2 = stat_descale;
            } else if (state == 0x1C) {         /* water / 2000, saturated */
                /* signed 32 bit division in the original (sdiv32) */
                q = (uint32_t)((int32_t)stat_water / 2000);
                w = (q >= 0x10000UL) ? 0xFFFF : (uint16_t)q;
                p1 = (uint8_t)(w >> 8);
                p2 = (uint8_t)w;
            } else if (state == 0x1D) {         /* filters */
                p2 = stat_filter;
            } else if (state == 0x1E) {         /* milk */
                p1 = (uint8_t)(stat_milk >> 8);
                p2 = (uint8_t)stat_milk;
            }
        } else {
            p1 = menu_value;
        }
        if (flags26 & F26_MENU_OPEN)
            state |= 0x80;
        if (reb5 == 0)                  /* masked off by the display */
            state |= 0x40;
    } else if (mstate == 0x0D) {        /* first start: language offered */
        state = mstate;
        p1 = mstep;
        p2 = lang_preview;
    } else if (mstate == 0x07) {        /* coffee */
        state = mstate;
        p1 = mstep;
        if (cups == 1)
            p1 |= 0x20;
        if (flags1d & F1D_CAPPU)
            p1 |= 0x40;
        p2 = (flags21 & 0x10) ? 0 : taste;
        p2 |= drink;
        if (flags25 & 0x02)
            p2 |= 0x01;
        if ((flags28 & F28_PROG_QTY) && mstep > 1)
            p2 |= 0x80;
    } else if (mstate == 0x0A || mstate == 0x0B) {
        state = mstate;
        p1 = mstep;
        if (mstate == 0x0A) {           /* milk */
            if (flags1d & F1D_CAPPU)
                p1 |= 0x40;
            p2 = (flags21 & 0x10) ? 0 : taste;
            p2 |= drink;
        } else {                        /* hot water */
            if (cups == 1)
                p1 |= 0x20;
            if (mstep == 2)
                p1 |= 0x80;
        }
        if ((flags1d & F1D_PROG) && prog_press_timer == 0)
            p2 |= 0x80;
    } else {
        state = mstate;
        p1 = mstep;
        if (pump_state == 1 && (out_loads & 0x08))      /* pump running */
            p2 |= 0x80;
        if (bu_stroke_ref == 0 && mstate == 0 &&
            (keys & 0x08) && (keys & 0x10) && keys_count == 2)
            p2 |= 0x20;
        if ((flags1d & F1D_PROG) && prog_press_timer == 0)
            p2 |= 0x04;
        if (flags1d & F1D_DESCALE_RUN)
            p2 |= 0x08;
    }

    spi_tx[0] = 0x0B;
    spi_tx[1] = state;
    spi_tx[2] = p1;
    spi_tx[3] = p2;

    /* flags1 */
    spi_tx[4] = 0;
    if (settings & 0x01)                        /* auto-start off   */
        spi_tx[4] |= 0x01;
    if (settings2 & 0x02)                       /* 24 h clock       */
        spi_tx[4] |= 0x02;
    if (milk_timer != 0 && mstep == 0)          /* "press CLEAN"    */
        spi_tx[4] |= 0x20;
    if (settings & 0x08)                        /* cup light        */
        spi_tx[4] |= 0x08;
    if (settings & 0x04)                        /* beep             */
        spi_tx[4] |= 0x04;
    if (settings & 0x10)                        /* energy saving    */
        spi_tx[4] |= 0x10;
    if ((settings & 0x10) && energy_timer == 0) /* ... and active   */
        spi_tx[4] |= 0x40;
    if (settings & 0x80)                        /* water filter     */
        spi_tx[4] |= 0x80;

    /* flags2 */
    spi_tx[5] = language & 0x0F;
    if (cup_light_on())
        spi_tx[5] |= 0x10;
    if (heatflags & 0x10)                       /* milk container missing */
        spi_tx[5] |= 0x20;

    spi_tx[6] = sensors;

    spi_tx[7] = alarms;
    if (alarms2 & 0x10)
        spi_tx[7] |= 0x80;
    spi_tx[8] = alarms2 & 0xE0;
    if ((alarms & 0x20) && beans_alarm_timer != 0)      /* alarm held back */
        spi_tx[7] &= ~0x20;
    if ((alarms2 & 0x20) && less_coffee_timer != 0)     /* alarm held back */
        spi_tx[8] &= ~0x20;
    spi_tx[8] |= fault_class;
    spi_tx[8] |= (uint8_t)(fault_step << 2);

    spi_tx[9] = progress;
    spi_tx[10] = checksum(spi_tx, 10, 0xFF);
    SSPBUF = spi_tx[0];
}
