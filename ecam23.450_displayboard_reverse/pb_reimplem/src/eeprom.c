/*
 * Data EEPROM (0x0980 ee_load, 0x0B3A ee_save_task, 0x0CE0 crc16,
 * 0x0D7A ee_write, 0x0D9A ee_read, 0x451A-0x4996 record pack/unpack/defaults).
 *
 * Three records, each stored twice, with a CRC-16 (high, low) after the data:
 *
 *   record  content                    data  copies at
 *   B       settings                   17    0x00, 0x13
 *   A       language and quantities    27    0x26, 0x43
 *   C       counters / statistics      21    0x60, 0x77
 *   -       factory bytes (read only)  10    0xF6..0xFF -> ee_factory
 *
 * Multi-byte values are big endian in the EEPROM. The records go through
 * ee_buf; at boot the first copy with a good CRC is unpacked, otherwise the
 * defaults are used. A save is requested by setting a bit in ee_flags
 * (5: record B, 1: record A, 3: record C); ee_save_task packs the record and
 * writes one byte every 30 ms (ee_write_timer, 10 ms ticks), first copy then
 * second copy, and never starts while the mains is missing.
 */
#include "pb.h"

/* ee_flags */
#define EE_A_BUSY   0x01
#define EE_A_REQ    0x02
#define EE_C_BUSY   0x04
#define EE_C_REQ    0x08
#define EE_B_BUSY   0x10
#define EE_B_REQ    0x20
#define EE_BUSY     (EE_A_BUSY | EE_B_BUSY | EE_C_BUSY)

/* sysflags */
#define SYS_MAINS_LOST  0x20

#define RECA_BASE   0x26
#define RECA_LEN    0x1B
#define RECB_BASE   0x00
#define RECB_LEN    0x11
#define RECC_BASE   0x60
#define RECC_LEN    0x15

/* 0x0D9A */
static uint8_t ee_read(uint8_t addr)
{
    EEADR = addr;
    EECON1bits.RD = 1;
    return EEDATA;
}

/* 0x0D7A. WREN stays set until ee_save_task has finished the record. */
static void ee_write(uint8_t addr, uint8_t data)
{
    EEADR = addr;
    EEDATA = data;
    PIR2bits.EEIF = 0;
    INTCONbits.GIE = 0;
    EECON1bits.WREN = 1;
    EECON2 = 0x55;
    EECON2 = 0xAA;
    EECON1bits.WR = 1;
    INTCONbits.GIE = 1;
}

/* 0x0CE0: CRC-16, polynomial 0x8005, MSB first, the register preloaded with
 * 0xAA:buf[0] and two zero bytes shifted in at the end (augmented form).
 * Result in crc_hi:crc_lo. The original keeps the carry-out bit in
 * tickflags.6 (used nowhere else). */
static void crc16(const volatile uint8_t *buf, uint8_t len)
{
    crc_hi = 0xAA;
    crc_lo = buf[0];
    for (uint8_t i = 1; (int16_t)i < (int16_t)len + 2; i++) {
        uint8_t b = (i < len) ? buf[i] : 0;
        for (uint8_t bit = 0; bit <= 7; bit++) {
            uint8_t msb = crc_hi & 0x80;
            crc_hi = (uint8_t)(crc_hi << 1) | (crc_lo >> 7);
            crc_lo <<= 1;
            if (b & 0x80)
                crc_lo |= 0x01;
            b <<= 1;
            if (msb) {
                crc_hi ^= 0x80;
                crc_lo ^= 0x05;
            }
        }
    }
}

/* ---- record A: language, options and quantities */

/* 0x451A. With 0xFF (boot) the language and options are reset too; the menu
 * (menu_item_apply) calls it with another value to keep them. */
void recA_defaults(uint8_t all)
{
    if (all == 0xFF) {
        language = 0x52;
        settings2 = 0x03;
    }
    qty_my = 60;
    qty_espresso = 85;
    qty_standard = 120;
    qty_long = 190;
    qty_extralong = 250;
    qty5_b = 150;
    qty_hotwater = 700;
    qty_cappu_coffee = 160;
    qty_milk_0 = 160;
    qty9 = 120;
    qty_milk_1 = 180;
    qty11 = 120;
    qty_milk_2 = 450;
}

static void put16(uint8_t i, uint16_t v)
{
    ee_buf[i] = (uint8_t)(v >> 8);
    ee_buf[i + 1] = (uint8_t)v;
}

static uint16_t get16(uint8_t i)
{
    return ((uint16_t)ee_buf[i] << 8) | ee_buf[i + 1];
}

/* 0x4598 */
static void recA_pack(void)
{
    ee_buf[0] = language;
    ee_buf[1] = settings2;
    put16(2, qty_my);
    put16(4, qty_espresso);
    put16(6, qty_standard);
    put16(8, qty_long);
    put16(10, qty_extralong);
    ee_buf[12] = qty5_b;
    put16(13, qty_hotwater);
    put16(15, qty_cappu_coffee);
    put16(17, qty_milk_0);
    put16(19, qty9);
    put16(21, qty_milk_1);
    put16(23, qty11);
    put16(25, qty_milk_2);
}

/* 0x4666 */
static void recA_unpack(void)
{
    language = ee_buf[0];
    settings2 = ee_buf[1];
    qty_my = get16(2);
    qty_espresso = get16(4);
    qty_standard = get16(6);
    qty_long = get16(8);
    qty_extralong = get16(10);
    qty5_b = ee_buf[12];
    qty_hotwater = get16(13);
    qty_cappu_coffee = get16(15);
    qty_milk_0 = get16(17);
    qty9 = get16(19);
    qty_milk_1 = get16(21);
    qty11 = get16(23);
    qty_milk_2 = get16(25);
}

/* ---- record B: settings */

/* 0x4734 */
static void recB_defaults(void)
{
    set_hardness = 3;
    grind_hist_a = 0x15;
    set_b2 = 0x15;
    set_b3 = 0x50;
    grind_hist_b = 0x43;
    set_b5 = 0x43;
    grind_hist_c = 0x36;
    set_b7 = 0x36;
    bu_stroke_ref = 0;
    grind_center = 0x50;
    set_fault = 0;
    set_temperature = 1;
    set_autooff = 3;
    settings = (language & 0x40) ? 0x1D : 0x0D;
    set_autostart_h = 0;
    set_autostart_m = 0;
}

/* 0x4794 */
static void recB_pack(void)
{
    ee_buf[0] = set_hardness;
    ee_buf[1] = grind_hist_a;
    ee_buf[2] = set_b2;
    ee_buf[3] = set_b3;
    ee_buf[4] = grind_hist_b;
    ee_buf[5] = set_b5;
    ee_buf[6] = grind_hist_c;
    ee_buf[7] = set_b7;
    put16(8, bu_stroke_ref);
    ee_buf[10] = grind_center;
    ee_buf[11] = set_fault;
    ee_buf[12] = set_temperature;
    ee_buf[13] = set_autooff;
    ee_buf[14] = settings;
    ee_buf[15] = set_autostart_h;
    ee_buf[16] = set_autostart_m;
}

/* 0x47E2 */
static void recB_unpack(void)
{
    set_hardness = ee_buf[0];
    grind_hist_a = ee_buf[1];
    set_b2 = ee_buf[2];
    set_b3 = ee_buf[3];
    grind_hist_b = ee_buf[4];
    set_b5 = ee_buf[5];
    grind_hist_c = ee_buf[6];
    set_b7 = ee_buf[7];
    bu_stroke_ref = get16(8);
    grind_center = ee_buf[10];
    set_fault = ee_buf[11];
    set_temperature = ee_buf[12];
    set_autooff = ee_buf[13];
    settings = ee_buf[14];
    set_autostart_h = ee_buf[15];
    set_autostart_m = ee_buf[16];
}

/* ---- record C: counters. The two water totals are 32 bit in RAM but only
 * their low 24 bits are stored; byte 5 is written but never read back. */

/* 0x4830 */
static void recC_defaults(void)
{
    water_since_descale = 0;
    grounds_count = 0;
    cnt_ca = 0;
    stat_coffee = 0;
    cnt_e = 0;
    stat_descale = 0;
    stat_water = 0;
    stat_milk = 0;
    stat_filter = 0;
    water_since_filter = 0;
}

/* 0x4870 */
static void recC_pack(void)
{
    ee_buf[0] = (uint8_t)(water_since_descale >> 16);
    ee_buf[1] = (uint8_t)(water_since_descale >> 8);
    ee_buf[2] = (uint8_t)water_since_descale;
    ee_buf[3] = grounds_count;
    ee_buf[4] = cnt_ca;
    put16(6, stat_coffee);
    ee_buf[8] = cnt_e;
    ee_buf[9] = stat_descale;
    ee_buf[10] = (uint8_t)(stat_water >> 24);
    ee_buf[11] = (uint8_t)(stat_water >> 16);
    ee_buf[12] = (uint8_t)(stat_water >> 8);
    ee_buf[13] = (uint8_t)stat_water;
    put16(14, stat_milk);
    ee_buf[16] = stat_filter;
    ee_buf[17] = (uint8_t)(water_since_filter >> 24);
    ee_buf[18] = (uint8_t)(water_since_filter >> 16);
    ee_buf[19] = (uint8_t)(water_since_filter >> 8);
    ee_buf[20] = (uint8_t)water_since_filter;
}

/* 0x4902 */
static void recC_unpack(void)
{
    water_since_descale = ((uint32_t)ee_buf[0] << 16) | ((uint16_t)ee_buf[1] << 8) | ee_buf[2];
    grounds_count = ee_buf[3];
    cnt_ca = ee_buf[4];
    stat_coffee = get16(6);
    cnt_e = ee_buf[8];
    stat_descale = ee_buf[9];
    stat_water = ((uint32_t)get16(10) << 16) | get16(12);
    stat_milk = get16(14);
    stat_filter = ee_buf[16];
    water_since_filter = ((uint32_t)get16(17) << 16) | get16(19);
}

/* read one record copy into ee_buf and check its CRC */
static uint8_t ee_read_copy(uint8_t addr, uint8_t len)
{
    for (uint8_t i = 0; i <= len + 1; i++)
        ee_buf[i] = ee_read(addr + i);
    crc16(ee_buf, len);
    return ee_buf[len] == crc_hi && ee_buf[len + 1] == crc_lo;
}

/* 0x0980: load the three records, copy 0 first, then copy 1 */
void ee_load(void)
{
    uint8_t ok;

    EECON1 = 0;

    ee_copy = 0;
    do {
        CLRWDT();
        ok = ee_read_copy(ee_copy * (RECA_LEN + 2) + RECA_BASE, RECA_LEN);
        ee_copy++;
    } while (!ok && ee_copy <= 1);
    if (ok)
        recA_unpack();
    else
        recA_defaults(0xFF);

    ee_copy = 0;
    do {
        CLRWDT();
        ok = ee_read_copy(ee_copy * (RECB_LEN + 2) + RECB_BASE, RECB_LEN);
        ee_copy++;
    } while (!ok && ee_copy <= 1);
    if (ok)
        recB_unpack();
    else
        recB_defaults();

    ee_copy = 0;
    do {
        CLRWDT();
        ok = ee_read_copy(ee_copy * (RECC_LEN + 2) + RECC_BASE, RECC_LEN);
        ee_copy++;
    } while (!ok && ee_copy <= 1);
    if (ok)
        recC_unpack();
    else
        recC_defaults();

    CLRWDT();
    for (uint8_t i = 0; i <= 9; i++)
        ee_factory[i] = ee_read(0xF6 + i);
}

/* one byte of the record being saved; returns 1 when both copies are done */
static uint8_t ee_save_byte(uint8_t base, uint8_t len)
{
    ee_write(ee_copy * (len + 2) + ee_idx + base, ee_buf[ee_idx]);
    ee_write_timer = 3;
    if (++ee_idx > len + 1) {
        if (++ee_copy < 2)
            ee_idx = 0;
        else
            return 1;
    }
    return 0;
}

/* 0x0B3A: background save, one byte per call at most every 30 ms */
void ee_save_task(void)
{
    loop_tasks++;

    /* record B */
    if ((ee_flags & EE_B_REQ) && !(sysflags & SYS_MAINS_LOST) && !(ee_flags & EE_BUSY)) {
        ee_flags |= EE_B_BUSY;
        ee_flags &= ~EE_B_REQ;
        ee_idx = 0;
        ee_copy = 0;
        recB_pack();
        crc16(ee_buf, RECB_LEN);
        ee_buf[RECB_LEN] = crc_hi;
        ee_buf[RECB_LEN + 1] = crc_lo;
    }
    if ((ee_flags & EE_B_BUSY) && ee_write_timer == 0) {
        if (ee_save_byte(RECB_BASE, RECB_LEN))
            ee_flags &= ~EE_B_BUSY;
    }

    /* record A */
    if ((ee_flags & EE_A_REQ) && !(sysflags & SYS_MAINS_LOST) && !(ee_flags & EE_BUSY)) {
        ee_flags |= EE_A_BUSY;
        ee_flags &= ~EE_A_REQ;
        ee_idx = 0;
        ee_copy = 0;
        recA_pack();
        crc16(ee_buf, RECA_LEN);
        ee_buf[RECA_LEN] = crc_hi;
        ee_buf[RECA_LEN + 1] = crc_lo;
    }
    if ((ee_flags & EE_A_BUSY) && ee_write_timer == 0) {
        if (ee_save_byte(RECA_BASE, RECA_LEN))
            ee_flags &= ~EE_A_BUSY;
    }

    /* record C */
    if ((ee_flags & EE_C_REQ) && !(sysflags & SYS_MAINS_LOST) && !(ee_flags & EE_BUSY)) {
        ee_flags |= EE_C_BUSY;
        ee_flags &= ~EE_C_REQ;
        ee_idx = 0;
        ee_copy = 0;
        recC_pack();
        crc16(ee_buf, RECC_LEN);
        ee_buf[RECC_LEN] = crc_hi;
        ee_buf[RECC_LEN + 1] = crc_lo;
    }
    if ((ee_flags & EE_C_BUSY) && ee_write_timer == 0) {
        if (ee_save_byte(RECC_BASE, RECC_LEN))
            ee_flags &= ~EE_C_BUSY;
    }

    /* all done and the last write finished: disable writes */
    if (!(ee_flags & EE_BUSY) && PIR2bits.EEIF) {
        PIR2bits.EEIF = 0;
        EECON1bits.WREN = 0;
    }
}
