/*
 * Block transfers with the RTC and the EEPROM, through i2c_buf
 * (0x165B Caroline, 0x172E Cecile, 0x16E8 Eleonore, 0x1795 Clemence).
 *
 *  - RTC    (0xD0): 1 address byte,  8 byte blocks (registers 0..7)
 *  - EEPROM (0xA0): 2 address bytes, 16 byte blocks (half a 64 byte page)
 *
 * Errors only set i2c_err, which nothing reads: a failed read leaves the
 * previous content of i2c_buf in place.
 */
#include "hw.h"
#include "fw.h"

static uint8_t block_len(uint8_t dev)
{
    return (dev == I2C_RTC) ? 8 : 16;
}

/* START, device, then the register/memory address */
static uint8_t send_address(uint8_t dev, uint8_t addr_hi, uint8_t addr_lo)
{
    uint8_t err;

    err = softi2c_start();
    err += softi2c_write(dev);
    if (dev == I2C_EEPROM)
        err += softi2c_write(addr_hi);
    if (dev == I2C_EEPROM || dev == I2C_RTC)
        err += softi2c_write(addr_lo);
    return err;
}

/* 0x165B */
void i2c_read_block(uint8_t dev, uint8_t addr_hi, uint8_t addr_lo)
{
    uint8_t i, n, err;

    i2c_err = 0;
    ee_addr_lo = addr_lo;
    ee_addr_hi = addr_hi;

    if (send_address(dev, addr_hi, addr_lo) != 0) {
        i2c_err = 0xFF;                 /* note: no STOP on this path */
        return;
    }
    err = softi2c_start();              /* repeated START, read mode */
    err += softi2c_write(dev | 1);
    if (err != 0) {
        i2c_err = 0xFF;
        return;
    }

    n = block_len(dev);
    for (i = 0; i < n - 1; i++)
        i2c_buf[i] = softi2c_read(1);
    i2c_buf[i] = softi2c_read(0);
    softi2c_stop();
    softi2c_delay();
}

/* 0x172E. The EEPROM write protect (/WC) is only released for the transfer;
 * eeprom_busy then covers the internal write cycle. */
void i2c_write_block(uint8_t dev, uint8_t addr_hi, uint8_t addr_lo)
{
    uint8_t i, n;

    i2c_err = 0;
    ee_addr_lo = addr_lo;
    ee_addr_hi = addr_hi;
    EE_WC_N = 0;

    if (send_address(dev, addr_hi, addr_lo) != 0) {
        i2c_err = 0xFF;
        softi2c_stop();
        EE_WC_N = 1;
        return;
    }

    n = block_len(dev);
    for (i = 0; i < n; i++)
        softi2c_write(i2c_buf[i]);
    softi2c_stop();

    if (dev == I2C_EEPROM)
        eeprom_busy = 25;               /* 25 timer0 ticks = ~5 ms */
    EE_WC_N = 1;
    softi2c_delay();
}

/* 0x16E8 (second half of Eleonore): read the EEPROM header.
 *   byte 0     : number of languages (0x0F in the dump). The string area
 *                is 0x14 + n * 2000 bytes, hence 16 KiB for n < 9.
 *   byte 2..3  : a config byte and its complement (0x65, 0x9A in the dump)
 * Both end up in every SPI frame to the power board. */
void eeprom_load_config(void)
{
    softi2c_bus_init();

    i2c_read_block(I2C_EEPROM, 0x00, 0x02);
    if ((uint16_t)i2c_buf[0] + i2c_buf[1] == 0x00FF)
        eecfg_2 = i2c_buf[0];

    i2c_read_block(I2C_EEPROM, 0x00, 0x00);
    eecfg_0 = i2c_buf[0];
    ee_size = (eecfg_0 < 9) ? 0x4000 : 0x8000;
}

/* 0x1795: 16 bit sum of the first ee_size EEPROM bytes (service command 0x26) */
void eeprom_checksum(void)
{
    uint16_t a, err;

    i2c_err = 0;
    ee_sum = 0;

    err = softi2c_start();
    err += softi2c_write(I2C_EEPROM);
    err += softi2c_write(0x00);
    err += softi2c_write(0x00);
    if (err == 0) {
        err = softi2c_start();
        err += softi2c_write(I2C_EEPROM | 1);
    }
    if (err != 0) {
        i2c_err = 0xFF;
        return;
    }

    for (a = 0; a < (uint16_t)(ee_size - 1); a++)
        ee_sum += softi2c_read(1);
    ee_sum += softi2c_read(0);
    softi2c_stop();
    softi2c_delay();
}
