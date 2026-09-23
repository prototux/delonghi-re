/*
 * Hardware of the ECAM 23.450 display board: PIC16F916, 8 MHz internal RC.
 *
 * Pin map (see docs/hardware.md):
 *   RA0..RA2  keypad rows (driven low one at a time)
 *   RA3       ESC LED            (active low, 50% PWM when lit)
 *   RA4       OK LED             (active low, 50% PWM when lit)
 *   RA5       J2 pin 1           (unused)
 *   RA6       LCD backlight      (active low)
 *   RA7       cup light LEDs     (active low)
 *   RB1       M24256 /WC         (low = write enabled)
 *   RB2       ST7036 /RST
 *   RB3       I2C SDA (bit-banged: LCD 0x78, RTC 0xD0, EEPROM 0xA0)
 *   RB4       I2C SCL
 *   RB5..RB7  keypad columns (inputs)
 *   RC0, RC1  rotary encoder A, B
 *   RC2       rotary encoder push
 *   RC3       74HC4052 select: 0 = UART (service), 1 = SPI (power board)
 *   RC4       SPI SDO  -> power board connector pin 2
 *   RC5       buzzer (CCP1 PWM ~4 kHz, idle high)
 *   RC6       UART TX / SPI SCK  (through the 74HC4052)
 *   RC7       UART RX / SPI SDI  (through the 74HC4052)
 */
#ifndef HW_H
#define HW_H

#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 8000000UL

/* Keypad */
#define KBD_ROW_MASK   0x07        /* RA0..RA2 */
#define KBD_COL5       PORTBbits.RB5
#define KBD_COL6       PORTBbits.RB6
#define KBD_COL7       PORTBbits.RB7

/* LEDs, backlight, cup light (all active low) */
#define LED_ESC_N      PORTAbits.RA3
#define LED_OK_N       PORTAbits.RA4
#define BACKLIGHT_N    PORTAbits.RA6
#define CUPLIGHT_N     PORTAbits.RA7

/* External I2C bus (bit-banged) */
#define EE_WC_N        PORTBbits.RB1
#define LCD_RST_N      PORTBbits.RB2
#define I2C_SDA        PORTBbits.RB3
#define I2C_SCL        PORTBbits.RB4
#define I2C_SDA_TRIS   TRISBbits.TRISB3

/* Encoder */
#define ENC_A          PORTCbits.RC0
#define ENC_B          PORTCbits.RC1
#define ENC_PUSH       PORTCbits.RC2

/* Power board link */
#define LINK_SEL_SPI   PORTCbits.RC3
#define BUZZER         PORTCbits.RC5

#define CLRWDT()       asm("CLRWDT")

/* I2C device addresses (8 bit, write) */
#define I2C_LCD        0x78        /* ST7036 */
#define I2C_RTC        0xD0        /* M41T00-compatible RTC (8 registers) */
#define I2C_EEPROM     0xA0        /* M24256 (32 KiB) */

#endif
