/*
 * Service port (EUSART, 0x4BF4..0x4D14, 0x51EA..0x5F76, 0x604C..0x60FE).
 *
 * 19200 baud; TX sends a 9th bit = 1 (looks like 8N2), RX is 8N1. This is a
 * different port from the display board's 9600 baud service mode: it is
 * probably reached through its own connector or a test jig.
 *
 * Request: 0A len cmd dest data... chk     chk = 0x55 ^ bytes[0..len-1],
 * Reply:   A0 len cmd 0F   data... chk     placed at index len.
 * The reply is built over the request in uart_buf. Values are big-endian.
 *
 *   0A 04 60 0F           -> A0 13 60 0F io[7] bu_pos pump_cnt 00 00 00 00
 *   0A 04 70 0F           -> A0 10 70 0F al al2 loads 00 state sub 23 tA tB prod grounds 0A
 *   0A 08 80 0F b0..b3    -> remote load test; alternately the 0x80 reply
 *                            (0x60 without the zeros) or A0 0C 81 0F ...
 *   0A 0A 90 0F id val32  -> A0 07 90 0F id st      (st 00 ok, FF bad id)
 *   0A 07 95 dd id n      -> A0 6+4n 95 0F id val32 x n   (dd 0F or F0)
 *   0A 04 F0 0F           -> A0 0E F0 0F ee_factory[10]
 * See docs/pb_notes/comms.md.
 */
#include "pb.h"

#define TF_UART_FRAME   0x02    /* tickflags: request received          */
#define SF_UART_TOGGLE  0x02    /* sysflags: 0x80 / 0x81 reply toggle   */
#define SF_UART_BUSY    0x80    /* sysflags: reply being sent (+20 ms)  */
#define F1D_CAPPU       0x01    /* flags1d: cappuccino                  */

/* Common reply tail, repeated inline in every reply function of the
 * original: checksum at [len], send len + 1 bytes under TX interrupt. */
static void svc_send(void)
{
    uint8_t len = uart_buf[1];

    uart_buf[len] = checksum(uart_buf, len, 0);
    uart_tx_len = len + 1;
    sysflags |= SF_UART_BUSY;   /* cleared by timebase 20 ms after the end */
    uart_tx_idx = 1;
    TXREG = uart_buf[0];
    PIE1bits.TXIE = 1;
}

static void svc_header(uint8_t len, uint8_t cmd)
{
    uart_buf[0] = 0xA0;
    uart_buf[1] = len;
    uart_buf[2] = cmd;
    uart_buf[3] = 0x0F;
}

/* 0x6076: EUSART receive interrupt */
void isr_uart_rx(void)
{
    uint8_t b;

    if (RCSTAbits.FERR || RCSTAbits.OERR) {
        RCSTAbits.CREN = 0;
        (void)RCREG;
        uart_rx_idx = 0;
        RCSTAbits.CREN = 1;
        return;
    }
    b = RCREG;
    /* ignored while a request is pending or a reply is being sent */
    if ((tickflags & TF_UART_FRAME) || (sysflags & SF_UART_BUSY))
        return;

    uart_rx_to = 2;             /* 20 ms inter-byte timeout (timebase) */
    if (uart_rx_idx == 0) {
        if (b == 0x0A) {
            uart_buf[0] = b;
            uart_rx_idx++;
        }
    } else if (uart_rx_idx == 1) {
        if (b < 0x19) {
            uart_buf[1] = b;
            uart_rx_idx++;
            uart_rx_len = b;
        } else {
            uart_rx_idx = 0;
        }
    } else {
        uart_buf[uart_rx_idx] = b;
        uart_rx_idx++;
        if (uart_rx_idx > uart_rx_len)  /* checksum byte received */
            tickflags |= TF_UART_FRAME;
    }
}

/* 0x604C: EUSART transmit interrupt */
void isr_uart_tx(void)
{
    if (uart_tx_idx < uart_tx_len) {
        TXREG = uart_buf[uart_tx_idx];
        uart_tx_idx++;
    } else {
        PIE1bits.TXIE = 0;
        uart_tx_to = 2;         /* timebase clears SF_UART_BUSY 20 ms later */
    }
}

/* 0x566E: key and sensor bits for the 0x60 / 0x80 replies */
void pack_io_snapshot(void)
{
    uint8_t i;

    for (i = 0; i < 7; i++)
        io_snapshot[i] = 0;
    if (keys & 0x10)    io_snapshot[0] |= 0x01;
    if (keys & 0x01)    io_snapshot[0] |= 0x02;
    if (keys & 0x02)    io_snapshot[0] |= 0x04;
    if (keys_hi & 0x02) io_snapshot[0] |= 0x08;
    if (keys & 0x04)    io_snapshot[0] |= 0x20;
    if (keys & 0x40)    io_snapshot[1] |= 0x40;
    if (keys & 0x08)    io_snapshot[2] |= 0x01;
    if (keys & 0x80)    io_snapshot[2] |= 0x80;
    if (sensors & 0x01) io_snapshot[5] |= 0x01;
    if (sensors & 0x02) io_snapshot[5] |= 0x02;
    if (sensors & 0x04) io_snapshot[5] |= 0x04;
    if (sensors & 0x08) io_snapshot[5] |= 0x08;
    if (sensors & 0x10) io_snapshot[5] |= 0x10;
    if (sensors & 0x40) io_snapshot[5] |= 0x40;
    if (sensors & 0x20) io_snapshot[6] |= 0x01;
}

/* cappuccino with drink 0..8 -> 0x0B..0x0F (0x5726..0x5760) */
static uint8_t cappu_code(void)
{
    switch (drink) {
    case 0: return 0x0B;
    case 2: return 0x0C;
    case 4: return 0x0D;
    case 6: return 0x0E;
    case 8: return 0x0F;
    default: return 0;
    }
}

/* 0x5704: product being made, for the 0x70 reply.
 * 1..5 one cup (my/espresso/standard/long/extra long), 6..10 two cups,
 * 0x0B..0x0F cappuccino, 0x10 hot water, 0x11 frothed milk, 0 nothing. */
uint8_t recipe_code(void)
{
    /* Leftover in the original: masks uart_buf[13], which the caller
     * overwrites with the result right after. */
    uart_buf[13] &= 0x03;

    if (mstate == 0x07 && mstep != 0) {
        if (flags1d & F1D_CAPPU)
            return cappu_code();
        if (drink > 8 || (drink & 1))
            return 0;
        if (cups == 0)
            return (uint8_t)(1 + drink / 2);
        if (cups == 1)
            return (uint8_t)(6 + drink / 2);
        return 0;
    }
    if (mstate == 0x0B)
        return 0x10;
    if (mstate == 0x0A)
        return (flags1d & F1D_CAPPU) ? cappu_code() : 0x11;
    return 0;
}

/* 0x51EA: status: keys/sensors, brew unit position, flow pulses */
void svc_reply_60(void)
{
    uint8_t i;

    svc_header(0x13, 0x60);
    pack_io_snapshot();
    for (i = 0; i < 7; i++)
        uart_buf[4 + i] = io_snapshot[i];
    uart_buf[11] = (uint8_t)(bu_pos >> 8);
    uart_buf[12] = (uint8_t)bu_pos;
    uart_buf[13] = (uint8_t)(pump_cnt_l >> 8);
    uart_buf[14] = (uint8_t)pump_cnt_l;
    uart_buf[15] = 0;
    uart_buf[16] = 0;
    uart_buf[17] = 0;
    uart_buf[18] = 0;
    svc_send();
}

/* 0x5288: machine status */
void svc_reply_70(void)
{
    uint8_t al2 = 0, io = 0;

    svc_header(0x10, 0x70);

    if (alarms2 & 0x20) al2 |= 0x01;
    if (alarms2 & 0x40) al2 |= 0x02;
    if (alarms2 & 0x10) al2 |= 0x04;
    if (alarms2 & 0x80) al2 |= 0x08;
    uart_buf[4] = alarms;
    uart_buf[5] = al2;

    /* load requests; the brew unit motor counts only with full power (bit 6) */
    if ((out_loads & 0x02) && (out_loads & 0x40)) io |= 0x02;
    if ((out_loads & 0x01) && (out_loads & 0x40)) io |= 0x01;
    if (out_loads & 0x04) io |= 0x04;
    if (pump_state == 1 && (out_loads & 0x08)) io |= 0x08;
    if (out_loads & 0x10) io |= 0x10;
    if (out_loads & 0x20) io |= 0x20;
    if (out_loads2 & 0x01) io |= 0x40;
    if (out_loads & 0x80) io |= 0x80;
    uart_buf[6] = io;

    uart_buf[7] = 0;
    uart_buf[8] = mstate;
    uart_buf[9] = mstep;
    uart_buf[10] = 0x23;        /* constant, probably a version */
    uart_buf[11] = temp_coffee;
    uart_buf[12] = temp_steam;
    uart_buf[13] = recipe_code();
    uart_buf[14] = grounds_count;
    uart_buf[15] = 0x0A;
    svc_send();
}

/* 0x536C: remote load test reply, even requests */
void svc_reply_80(void)
{
    uint8_t i;

    svc_header(0x0F, 0x80);
    pack_io_snapshot();
    for (i = 0; i < 7; i++)
        uart_buf[4 + i] = io_snapshot[i];
    uart_buf[11] = (uint8_t)(bu_pos >> 8);
    uart_buf[12] = (uint8_t)bu_pos;
    uart_buf[13] = (uint8_t)(pump_cnt_l >> 8);
    uart_buf[14] = (uint8_t)pump_cnt_l;
    svc_send();
}

/* 0x53F2: remote load test reply, odd requests */
void svc_reply_81(void)
{
    svc_header(0x0C, 0x81);
    uart_buf[4] = recb;
    uart_buf[5] = temp_coffee;
    uart_buf[6] = temp_steam;
    uart_buf[7] = re78;
    uart_buf[8] = re77;
    uart_buf[9] = grind_hist_b;         /* parameter 0x36 */
    uart_buf[10] = grind_hist_a;        /* parameter 0x33 */
    uart_buf[11] = 0x0A;
    svc_send();
}

/* 0x545C: read n parameters from id (request [4..5] id, [6] n).
 * n is not bounded: n > 4 runs past uart_buf (25 bytes) into ee_buf. */
void svc_read_params(void)
{
    uint8_t n = uart_buf[6], i;
    uint16_t id = (uint16_t)((uart_buf[4] << 8) | uart_buf[5]);
    uint32_t v;

    svc_header(0x06, 0x95);
    for (i = 0; i < n; i++) {
        uart_buf[1] += 4;
        v = param_get((uint16_t)(id + i));
        uart_buf[6 + 4 * i] = (uint8_t)(v >> 24);
        uart_buf[7 + 4 * i] = (uint8_t)(v >> 16);
        uart_buf[8 + 4 * i] = (uint8_t)(v >> 8);
        uart_buf[9 + 4 * i] = (uint8_t)v;
    }
    svc_send();
}

/* 0x554A: factory block (data EEPROM 0xF6..0xFF, copied at boot) */
void svc_reply_f0(void)
{
    uint8_t i;

    svc_header(0x0E, 0xF0);
    for (i = 0; i < 10; i++)
        uart_buf[4 + i] = ee_factory[i];
    svc_send();
}

/* 0x55C8: write one parameter (request [4..5] id, [6..9] value) */
void svc_write_param(void)
{
    uint16_t id = (uint16_t)((uart_buf[4] << 8) | uart_buf[5]);
    uint32_t v = ((uint32_t)uart_buf[6] << 24) | ((uint32_t)uart_buf[7] << 16) |
                 ((uint16_t)uart_buf[8] << 8) | uart_buf[9];

    svc_header(0x07, 0x90);
    uart_buf[6] = (param_set(id, v) == 0) ? 0x00 : 0xFF;
    svc_send();
}

/* 0x4BF4 (second half of comms_update): UART request dispatch */
void service_dispatch(void)
{
    uint8_t len = uart_buf[1];

    if (checksum(uart_buf, len, 0) == uart_buf[len]) {
        uart_dest = uart_buf[3];
        switch (uart_buf[2]) {
        case 0x60:
            if (len == 4 && uart_dest == 0x0F)
                svc_reply_60();
            break;
        case 0x70:
            if (len == 4 && uart_dest == 0x0F)
                svc_reply_70();
            break;
        case 0x80:              /* remote load test (test3_remote) */
            if (len == 8 && uart_dest == 0x0F) {
                test_timer = 5;
                test_mode = 3;
                test_cmd = uart_buf[4];
                test_arg0 = uart_buf[5];
                test_arg1 = uart_buf[6];
                test_arg2 = uart_buf[7];
                sysflags ^= SF_UART_TOGGLE;
                if (sysflags & SF_UART_TOGGLE)
                    svc_reply_80();
                else
                    svc_reply_81();
            }
            break;
        case 0x90:
            if (len == 0x0A && uart_dest == 0x0F)
                svc_write_param();
            break;
        case 0x95:
            if (len == 7 && (uart_dest == 0x0F || uart_dest == 0xF0))
                svc_read_params();
            break;
        case 0xF0:
            if (len == 4 && uart_dest == 0x0F)
                svc_reply_f0();
            break;
        default:
            break;
        }
    }
    uart_rx_idx = 0;
    tickflags &= ~TF_UART_FRAME;
}

/* 0x583C: read a parameter. dest 0x0F: settings (0x00-0x0E record A,
 * 0x32-0x41 record B), counters 0x64-0x6D, constants 0xC8-0xCB;
 * dest 0xF0: what we know about the display (0x3E8-0x3EE). Others read 0. */
uint32_t param_get(uint16_t id)
{
    if (uart_dest == 0x0F) {
        if (id < 0x0F) {
            switch (id) {
            case 0x00: return language;
            case 0x01: return settings2;
            case 0x02: return qty_my;
            case 0x03: return qty_espresso;
            case 0x04: return qty_standard;
            case 0x05: return qty_long;
            case 0x06: return qty_extralong;
            case 0x07: return qty5_b;
            case 0x08: return qty_hotwater;
            case 0x09: return qty_cappu_coffee;
            case 0x0A: return qty_milk_0;
            case 0x0B: return qty9;
            case 0x0C: return qty_milk_1;
            case 0x0D: return qty11;
            case 0x0E: return qty_milk_2;
            }
        } else if (id >= 0x32 && id < 0x42) {
            switch (id) {
            case 0x32: return set_hardness;
            case 0x33: return grind_hist_a;
            case 0x34: return set_b2;
            case 0x35: return set_b3;
            case 0x36: return grind_hist_b;
            case 0x37: return set_b5;
            case 0x38: return grind_hist_c;
            case 0x39: return set_b7;
            case 0x3A: return bu_stroke_ref;
            case 0x3B: return grind_center;
            case 0x3C: return set_fault;
            case 0x3D: return set_temperature;
            case 0x3E: return set_autooff;
            case 0x3F: return settings;
            case 0x40: return set_autostart_h;
            case 0x41: return set_autostart_m;
            }
        } else if (id >= 0x64 && id < 0x6E) {
            switch (id) {
            case 0x64: return water_since_descale;
            case 0x65: return grounds_count;
            case 0x66: return cnt_ca;
            case 0x67: return stat_coffee;
            case 0x68: return cnt_e;
            case 0x69: return stat_descale;
            case 0x6A: return stat_water;
            case 0x6B: return stat_milk;
            case 0x6C: return stat_filter;
            case 0x6D: return water_since_filter;
            }
        } else if (id >= 0xC8 && id < 0xCC) {
            /* probably version / format identifiers */
            switch (id) {
            case 0xC8: return 0x0A;
            case 0xC9: return 0x0C;
            case 0xCA: return 0x0A;
            case 0xCB: return 0;
            }
        }
    } else if (uart_dest == 0xF0) {
        if (id >= 0x3E8 && id < 0x3EF) {
            switch (id) {
            case 0x3E8: return disp_id;
            case 0x3E9: return disp_eecfg;
            case 0x3EA: return disp_hour;
            case 0x3EB: return disp_min;
            case 0x3EC: return disp_sec;
            case 0x3ED: return disp_enc;
            case 0x3EE: return disp_languages;
            }
        }
    }
    return 0;
}

/* 0x5CDC: write a parameter of record A (0x00-0x0E) or B (0x32-0x41) and
 * request the EEPROM save of that record. Only the low 8/16 bits of the
 * value are used, without range checks. Returns 0 on success, 0xFF for an
 * id outside both records (the counters are read-only). */
uint8_t param_set(uint16_t id, uint32_t v)
{
    uint8_t v8 = (uint8_t)v;
    uint16_t v16 = (uint16_t)v;

    if (id < 0x0F) {
        ee_save_req_c0 = 5;
        switch (id) {
        case 0x00: language = v8; break;
        case 0x01: settings2 = v8; break;
        case 0x02: qty_my = v16; break;
        case 0x03: qty_espresso = v16; break;
        case 0x04: qty_standard = v16; break;
        case 0x05: qty_long = v16; break;
        case 0x06: qty_extralong = v16; break;
        case 0x07: qty5_b = v8; break;
        case 0x08: qty_hotwater = v16; break;
        case 0x09: qty_cappu_coffee = v16; break;
        case 0x0A: qty_milk_0 = v16; break;
        case 0x0B: qty9 = v16; break;
        case 0x0C: qty_milk_1 = v16; break;
        case 0x0D: qty11 = v16; break;
        case 0x0E: qty_milk_2 = v16; break;
        }
        return 0;
    }
    if (id >= 0x32 && id < 0x42) {
        ee_save_req_c3 = 5;
        switch (id) {
        case 0x32: set_hardness = v8; break;
        case 0x33: grind_hist_a = v8; break;
        case 0x34: set_b2 = v8; break;
        case 0x35: set_b3 = v8; break;
        case 0x36: grind_hist_b = v8; break;
        case 0x37: set_b5 = v8; break;
        case 0x38: grind_hist_c = v8; break;
        case 0x39: set_b7 = v8; break;
        case 0x3A: bu_stroke_ref = v16; break;
        case 0x3B: grind_center = v8; break;
        case 0x3C: set_fault = v8; break;
        case 0x3D: set_temperature = v8; break;
        case 0x3E: set_autooff = v8; break;
        case 0x3F: settings = v8; break;
        case 0x40: set_autostart_h = v8; break;
        case 0x41: set_autostart_m = v8; break;
        }
        return 0;
    }
    return 0xFF;
}
