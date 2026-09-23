/*
 * Function prototypes of the display board firmware.
 *
 * The comment after each prototype gives the address and the name the
 * function had in the original image / in legacy_decompiled/.
 */
#ifndef FW_H
#define FW_H

#include <stdint.h>
#include "state.h"

/* Buzzer requests (written to `beep`) */
#define BEEP_SHORT   0x0A   /* 10 x 5 ms = 50 ms  (key click)          */
#define BEEP_LONG    0x32   /* 50 x 5 ms = 250 ms (alarm, confirmation) */
#define BEEP_ARMED   0xFF   /* idle, a key press may beep               */

/* Message IDs: < 0xC8 come from the external EEPROM in the current
 * language, >= 0xC8 from the ROM table (romdata.c). */
#define MSG_ROM_FIRST        0xC8
#define MSG_BLANK            0xC8
#define MSG_DISPLAY_TEST     0xC9
#define MSG_BUTTON           0xCA
#define MSG_LOAD_TEST        0xCB
#define MSG_LIMIT_UP         0xCC
#define MSG_LIMIT_DOWN       0xCD
#define MSG_MOTOR_UP         0xCE
#define MSG_MOTOR_DOWN       0xCF
#define MSG_VAPORIZER_ON     0xD0
#define MSG_ELECTRIC_TEST    0xD1
#define MSG_HEATER_ON        0xD2
#define MSG_GRINDER_ON       0xD3
#define MSG_PUMP_ON          0xD4
#define MSG_EV1_ON           0xD5
#define MSG_EV2_ON           0xD6
#define MSG_UART_MODE        0xD7
#define MSG_BLANK2           0xD8
#define MSG_PRESS_ESC_OK     0xD9
#define MSG_ENERGY_SAVING    0xDA
#define MSG_ALL_BLOCKS       0xDB
#define MSG_ALL_0x17         0xDC
#define MSG_ALL_GLYPH0       0xDD
#define MSG_NONE             0xFF   /* forces a redraw */

/* LCD positions (ST7036 DDRAM) */
#define LCD_LINE1            0x00
#define LCD_LINE2            0x40

/* main.c */
void main(void);                                    /* 0x0070 + 0x1004 */

/* isr.c: the interrupt handler (0x0004 _interrupt) needs no prototype */

/* timebase.c */
void timebase_update(void);                         /* 0x0723 MAINLOOP_SUB1 */

/* keypad.c / encoder.c */
void keypad_scan(void);                             /* 0x12CB MAINLOOP_SUB2 */
void encoder_poll(void);                            /* 0x10D8 MAINLOOP_SUB3 */

/* softi2c.c */
uint8_t softi2c_start(void);                        /* 0x1647 Aline  : 1 = bus busy */
uint8_t softi2c_write(uint8_t b);                   /* 0x161B Alice  : 1 = NACK     */
uint8_t softi2c_read(uint8_t ack);                  /* 0x15F5 Elsa   : ack==1 -> ACK */
void    softi2c_stop(void);                         /* 0x16D2 Agathe */
void    softi2c_delay(void);                        /* 0x16DF Anais  */
void    softi2c_bus_init(void);                     /* 0x16E8 Eleonore (first part) */

/* i2cmem.c: 8 byte (RTC) or 16 byte (EEPROM) transfers through i2c_buf */
void i2c_read_block(uint8_t dev, uint8_t addr_hi, uint8_t addr_lo);   /* 0x165B Caroline */
void i2c_write_block(uint8_t dev, uint8_t addr_hi, uint8_t addr_lo);  /* 0x172E Cecile   */
void eeprom_load_config(void);                      /* 0x16E8 Eleonore (second part) */
void eeprom_checksum(void);                         /* 0x1795 Clemence */

/* rtc.c */
uint8_t rtc_buf_invalid(void);                      /* 0x14E4 Eloise : 0 = valid time */
void    rtc_init(void);                             /* 0x1507 init_something_2 */

/* lcd.c (ST7036 over I2C) */
void lcd_write(uint8_t is_cmd, uint8_t b);          /* 0x00FD Adele : is_cmd 1 = command, 0 = data */
void lcd_init(uint8_t soft);                        /* 0x0123 Emy   : soft 0 = reset + clear */
void lcd_putc_at(uint8_t pos, uint8_t c);           /* 0x01E9 Eva   */
void lcd_write_field(uint8_t pos);                  /* 0x0832 Emma  */

/* text.c */
void text_load_line(uint8_t msg, uint8_t line);     /* 0x13BD Emilie */
void text_load_scroll(uint8_t msg);                 /* 0x121A Clara  */

/* display.c */
void display_refresh(void);                         /* 0x087E Elodie */

/* pblink.c: power board link (SPI) + UART service mode */
void    link_select(uint8_t spi);                   /* 0x0467 USART_MAYBE_CONFIG: 0 = UART, else SPI */
uint8_t link_checksum(volatile uint8_t *buf, uint8_t len, uint8_t add); /* 0x0490 */
void    link_update(void);                          /* 0x05B8 USART_MAYBE_LOGIC */
void    spi_send_frame(void);                       /* 0x0540 SSP_SEND_1 */
void    uart_reply_checksum(void);                  /* 0x04AD USART_PACKET_SEND_1 */
void    uart_reply_write(uint8_t ok);               /* 0x04D9 USART_PACKET_SEND_2 */
void    uart_reply_read(void);                      /* 0x0500 USART_PACKET_SEND_3 */

/* service.c */
void service_update(void);                          /* 0x1559 Coralie */

/* ui_main.c / ui_menu.c / ui_alarm.c / ui_format.c */
void    ui_update(void);                            /* 0x0AC6 MAINLOOP_MAIN_LOGIC */
void    ui_menu(void);                              /* 0x01F5 MAINLOOP_MAIN_LOGIC_SUB2 */
uint8_t ui_alarm(void);                             /* 0x0961 Elona : 1 = alarm screen shown */
void    format_time(uint8_t mode);                  /* 0x1048 MAINLOOP_MAIN_LOGIC_SUB1 */
void    format_number(void);                        /* 0x116F Eliana (uses `num`) */

/* util.c */
uint8_t bcd_to_bin(uint8_t bcd);                    /* 0x14CE Evelise (+ 0x1A29 Eloane) */
void    delay_ms(uint8_t n);                        /* 0x1E71 delay_2ms: really ~1.0 ms per unit */

/* romdata.c */
uint8_t rom_msg_char(uint8_t msg, uint8_t i);       /* ROM strings 0x0800 table */
extern const uint8_t lcd_glyphs[4][8];              /* 0x1A36 CGRAM glyphs */

#endif
