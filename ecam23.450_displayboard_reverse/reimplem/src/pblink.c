/*
 * Link with the power board (0x0467..0x0722).
 *
 * The board-to-board connector carries either:
 *  - SPI (normal operation): the display board is the master, mode 3
 *    (CKP=1, CKE=0), Fosc/64 = 125 kHz, MSB first, no chip select.
 *    Every ~30 ms it clocks an 11 byte frame out while clocking the power
 *    board's 11 byte frame in, one byte every ~1.7 ms. See docs/protocol.md.
 *  - UART (service mode, entered by holding the encoder button at power
 *    up): 9600 baud, 8 data bits (TX adds a 9th "1" bit, i.e. 8N2), used by
 *    a PC tool to read/write the text EEPROM.
 * RC3 switches a 74HC4052 between the two.
 */
#include "hw.h"
#include "fw.h"

/* 0x0467: 0 = UART service mode, anything else = SPI */
void link_select(uint8_t spi)
{
    PIE1bits.RCIE = 0;
    RCSTA = 0x00;
    TXSTA = 0x00;
    (void)RCREG;

    if (spi == 0) {
        SSPSTAT = 0x00;
        SSPCON = 0x00;
        misc.uart_mode = 1;
        SPBRG = 12;             /* 8 MHz / (64 * 13) = 9615 baud          */
        TXSTA = 0x61;           /* TX9, TXEN, 9th bit = 1                  */
        RCSTA = 0x90;           /* SPEN, CREN                              */
        (void)RCREG;
        PIE1bits.RCIE = 1;
        PIE1bits.TXIE = 0;
        LINK_SEL_SPI = 0;
    } else {
        misc.uart_mode = 0;
        SSPCON = 0x32;          /* SSPEN, CKP=1, SPI master Fosc/64        */
        SSPSTAT = 0x00;         /* CKE=0, SMP=0                            */
        LINK_SEL_SPI = 1;
    }
}

/* 0x0490: checksum seeded with 0x55, sum (SPI) or XOR (UART) of len bytes */
uint8_t link_checksum(volatile uint8_t *buf, uint8_t len, uint8_t add)
{
    uint8_t i, sum = 0x55;

    for (i = 0; i < len; i++) {
        if (add)
            sum += buf[i];
        else
            sum ^= buf[i];
    }
    return sum;
}

/* 0x0540: build and start the SPI frame to the power board.
 *
 *  [0] 0xB0                 [6]  RTC seconds (binary)
 *  [1] key bitmap           [7]  keys held << 3 | enc push << 1 | clock valid << 7
 *  [2] encoder position     [8]  EEPROM config byte 2
 *  [3] 0x14                 [9]  EEPROM byte 0 (number of languages)
 *  [4] RTC hours (binary)   [10] 0x55 + sum of [0..9]
 *  [5] RTC minutes (binary)
 */
void spi_send_frame(void)
{
    /* Key click: once per press, and only the ON/OFF key while the machine
     * is off (state 0). The click re-arms when all keys are released. */
    if (keys_count != 0 && beep == BEEP_ARMED &&
        ((pb_state & 0x3F) != 0 || (keys & KEY_ONOFF)))
        beep = BEEP_SHORT;
    if (keys_count == 0 && beep == 0)
        beep = BEEP_ARMED;

    spi_tx[0] = 0xB0;
    spi_tx[1] = tx_keys;
    spi_tx[2] = enc_count;
    spi_tx[3] = 0x14;
    misc.spi_toggle = !misc.spi_toggle;
    spi_tx[4] = bcd_to_bin(rtc_hour);
    spi_tx[5] = bcd_to_bin(rtc_min);
    spi_tx[6] = bcd_to_bin(rtc_sec);
    spi_tx[7] = (uint8_t)(keys_count << 3) | tx_keys_hi;
    if (ui.clock_valid)
        spi_tx[7] |= 0x80;
    spi_tx[8] = eecfg_2;
    spi_tx[9] = eecfg_0;
    spi_tx[10] = link_checksum(spi_tx, 10, 1);

    spi_len = 11;
    link.spi_busy = 1;
    PIR1bits.SSPIF = 0;
    spi_idx = 0;
    SSPBUF = spi_tx[0];         /* the SSP ISR and timer0 do the rest */
    PIE1bits.SSPIE = 1;
}

/* Start sending uart_buf[0..len-1]; the TX ISR sends the rest */
static void uart_send(uint8_t len)
{
    uart_tx_len = len;
    link.uart_tx_busy = 1;
    uart_tx_idx = 1;
    TXREG = uart_buf[0];
    PIE1bits.TXIE = 1;
}

/* Replies are built over the request, so uart_buf[2] (command) and
 * uart_buf[3..4] (address) are echoed as received. */

/* 0x04AD: A0 05 26 sum_hi sum_lo chk */
void uart_reply_checksum(void)
{
    uart_buf[0] = 0xA0;
    uart_buf[1] = 0x05;
    uart_buf[3] = ee_sum >> 8;
    uart_buf[4] = ee_sum & 0xFF;
    uart_buf[5] = link_checksum(uart_buf, uart_buf[1], 0);
    uart_send(uart_buf[1] + 1);
}

/* 0x04D9: A0 06 85 addr_hi addr_lo ok chk */
void uart_reply_write(uint8_t ok)
{
    uart_buf[0] = 0xA0;
    uart_buf[1] = 0x06;
    uart_buf[2] = 0x85;
    uart_buf[5] = ok;
    uart_buf[6] = link_checksum(uart_buf, uart_buf[1], 0);
    uart_send(uart_buf[1] + 1);
}

/* 0x0500: A0 15 95 addr_hi addr_lo data[16] chk */
void uart_reply_read(void)
{
    uint8_t i;

    uart_buf[0] = 0xA0;
    uart_buf[1] = 0x15;
    uart_buf[2] = 0x95;
    for (i = 0; i < 16; i++)
        uart_buf[5 + i] = i2c_buf[i];
    uart_buf[5 + i] = link_checksum(uart_buf, uart_buf[1], 0);
    uart_send(uart_buf[1] + 1);
}

/* Handle a complete service mode frame (0x0690..0x0722) */
static void uart_handle_frame(void)
{
    uint8_t i, len = uart_buf[1];

    if (link_checksum(uart_buf, len, 0) != uart_buf[len])
        return;

    switch (uart_buf[2]) {
    case 0x85:                                  /* write 16 EEPROM bytes */
        if (len != 0x15)
            break;
        if (eeprom_busy != 0) {
            uart_reply_write(0);
            break;
        }
        for (i = 0; i < 16; i++)
            i2c_buf[i] = uart_buf[5 + i];
        ee_addr_hi = uart_buf[3];
        ee_addr_lo = uart_buf[4];
        uart_reply_write(1);
        i2c_write_block(I2C_EEPROM, ee_addr_hi, ee_addr_lo);
        break;

    case 0x10:                                  /* read 16 EEPROM bytes */
        if (len != 0x05)
            break;
        ee_addr_hi = uart_buf[3];
        ee_addr_lo = uart_buf[4];
        i2c_read_block(I2C_EEPROM, ee_addr_hi, ee_addr_lo);
        uart_reply_read();
        break;

    case 0x26:                                  /* EEPROM checksum */
        if (len != 0x03)
            break;
        eeprom_checksum();
        uart_reply_checksum();
        break;
    }

    uart_timeout = 20;                          /* stay in service mode 10 s */
}

/* 0x05B8: called on every main loop pass */
void link_update(void)
{
    CLRWDT();

    if (spi_period == 0 && !misc.uart_mode) {
        spi_period = 6;                         /* 30 ms */
        spi_send_frame();
    }

    /* ---- frame from the power board ----------------------------------- */
    if (link.spi_rx_done) {
        if (link_checksum(spi_rx, 10, 1) == spi_rx[10] && spi_rx[0] == 0x0B) {
            pb_state = spi_rx[1];
            pb_param1 = spi_rx[2];
            pb_param2 = spi_rx[3];
            pb_flags1 = spi_rx[4];
            pb_flags2 = spi_rx[5];
            pb_flags3 = spi_rx[6];
            pb_flags4 = spi_rx[7];
            pb_flags5 = spi_rx[8];
            pb_b8_lo = spi_rx[8] & 0x03;
            pb_b8_hi = (spi_rx[8] & 0x1C) >> 2;

            CUPLIGHT_N = (pb_flags2 & 0x10) ? 0 : 1;

            if ((pb_state & 0x3F) != 0x21)      /* the button test uses pb_b9 */
                pb_b9 = spi_rx[9];

            /* statistics pages: stored but never used (full byte compare) */
            if (pb_state == 0x24) {
                ee_addr_hi = pb_param1; ee_addr_lo = pb_param2;
                pb24_a = pb_param2;     pb24_b = pb_param1;
            } else if (pb_state == 0x25) {
                ee_addr_hi = pb_param1; ee_addr_lo = pb_param2;
                pb25_a = pb_param2;     pb25_b = pb_param1;
            } else if (pb_state == 0x26) {
                pb26_a = pb_param1;     pb26_b = pb_param2;
            } else if (pb_state == 0x27) {
                ee_addr_hi = pb_param1; ee_addr_lo = pb_param2;
                pb27_a = pb_param2;     pb27_b = pb_param1;
            }

            /* state 0x0D is the language choice: preview the one offered */
            if ((pb_state & 0x3F) == 0x0D && !(pb_flags4 & 0x40))
                language = pb_param2;
            else
                language = pb_flags2 & 0x0F;

            link_timeout = 50;                  /* 2.5 s */
            ui.link_lost = 0;
        }
        link.spi_rx_done = 0;
    }

    if (link_timeout == 0) {
        ui.link_lost = 1;
        pb_state = 0;
        pb_param1 = 0;
        pb_param2 = 0;
        pb_flags1 = 0;
        pb_flags3 = 0;
        pb_flags4 = 0;
        pb_flags5 = 0;
        pb_b8_lo = 0;
        pb_b8_hi = 0;
    }

    /* ---- service mode ------------------------------------------------- */
    if (uart_timeout != 0 && tick.t500ms && --uart_timeout == 0) {
        misc.uart_mode = 0;
        link_select(0xFF);
    }

    if (!link.uart_rx_ready)
        return;
    uart_handle_frame();
    uart_rx_idx = 0;
    link.uart_rx_ready = 0;
}
