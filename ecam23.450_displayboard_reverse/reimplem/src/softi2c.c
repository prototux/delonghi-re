/*
 * Bit-banged I2C master on RB3 (SDA) / RB4 (SCL)
 * (0x1647 Aline, 0x161B Alice, 0x15F5 Elsa, 0x16D2 Agathe, 0x16DF Anais,
 *  0x16E8 Eleonore).
 *
 * Devices on the bus: ST7036 LCD (0x78), RTC (0xD0), M24256 EEPROM (0xA0).
 *
 * Electrical notes for a compatible design:
 *  - SCL is a push-pull output, there is no clock stretching support;
 *  - SDA is driven push-pull high too (TRIS is only released to read);
 *  - one bit takes ~12 us, so the bus runs at ~50-80 kHz.
 */
#include "hw.h"
#include "fw.h"

/* 0x16DF: half bit delay. The original sets and clears link.1 around a NOP,
 * a no-op that only burns cycles (~6 us with the call). */
void softi2c_delay(void)
{
    CLRWDT();
    link.i2c_dummy = 1;
    NOP();
    link.i2c_dummy = 0;
}

/* 0x1647: START condition. Returns 1 if SDA is held low (bus busy). */
uint8_t softi2c_start(void)
{
    I2C_SDA = 1;
    NOP(); NOP(); NOP();
    I2C_SCL = 1;
    I2C_SDA_TRIS = 0;
    I2C_SDA_TRIS = 1;               /* release SDA and look at it */
    if (!I2C_SDA)
        return 1;
    softi2c_delay();
    I2C_SDA_TRIS = 0;
    I2C_SDA = 0;                    /* SDA falls while SCL is high */
    softi2c_delay();
    I2C_SCL = 0;
    return 0;
}

/* 0x161B: send one byte MSB first. Returns the ACK bit (0 = ACK, 1 = NACK). */
uint8_t softi2c_write(uint8_t b)
{
    uint8_t i, nack;

    I2C_SDA_TRIS = 0;
    for (i = 0; i < 8; i++) {
        if (b & 0x80) {
            I2C_SDA = 1;
            NOP(); NOP();
        } else {
            I2C_SDA = 0;
        }
        NOP();
        I2C_SCL = 1;
        softi2c_delay();
        I2C_SCL = 0;
        if (i == 7)
            I2C_SDA_TRIS = 1;       /* release SDA for the ACK slot */
        softi2c_delay();
        b <<= 1;
    }

    I2C_SCL = 1;
    softi2c_delay();
    nack = I2C_SDA ? 1 : 0;
    I2C_SCL = 0;
    softi2c_delay();
    I2C_SDA_TRIS = 0;
    return nack;
}

/* 0x15F5: read one byte MSB first, then ACK it (ack == 1) or NACK it. */
uint8_t softi2c_read(uint8_t ack)
{
    uint8_t i, b = 0;

    I2C_SDA_TRIS = 1;
    for (i = 0; i < 8; i++) {
        b <<= 1;
        I2C_SCL = 1;
        softi2c_delay();
        if (I2C_SDA)
            b |= 1;
        I2C_SCL = 0;
        softi2c_delay();
    }

    I2C_SDA_TRIS = 0;
    if (ack == 1) {
        I2C_SDA = 0;
    } else {
        I2C_SDA = 1;
        NOP(); NOP(); NOP();
    }
    I2C_SCL = 1;
    softi2c_delay();
    I2C_SCL = 0;
    softi2c_delay();
    I2C_SDA = 0;
    return b;
}

/* 0x16D2: STOP condition */
void softi2c_stop(void)
{
    I2C_SCL = 0;
    I2C_SDA_TRIS = 0;
    I2C_SDA = 0;
    I2C_SCL = 1;
    softi2c_delay();
    I2C_SDA = 1;                    /* SDA rises while SCL is high */
    NOP(); NOP(); NOP();
    softi2c_delay();
}

/* 0x16E8 (first half of Eleonore): bus recovery. Nine clocks with a START
 * on each, to get any slave out of a half finished transfer, then STOP. */
void softi2c_bus_init(void)
{
    uint8_t i;

    for (i = 0; i < 9; i++) {
        I2C_SDA = 1;
        I2C_SCL = 1;
        I2C_SDA_TRIS = 0;
        softi2c_delay();
        I2C_SDA = 0;
        softi2c_delay();
        I2C_SCL = 0;
    }
    softi2c_stop();
}
