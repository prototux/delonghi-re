/*
 * Definitions of the global state (see state.h).
 *
 * The original start-up code clears all RAM, then loads 0x66..0x68 with
 * 08 02 32 and 0xE7 with 0F from the table at 0x00BF. Only 0x68
 * (blink_presc) and 0xE7 (div_800ms) are ever used.
 */
#include "state.h"

/* bank 0 */
volatile uint8_t pb_flags3;
uint8_t last_pb_flags3;
uint8_t tx_keys;
uint8_t tx_keys_hi;
uint8_t kbd_row;
uint8_t pb_flags4;
uint8_t pb_flags5;
volatile tick_t tick;
volatile link_t link;
volatile ui_t ui;
volatile misc_t misc;
volatile fx_t fx;
uint8_t keys_raw;
uint8_t keys_prev;
volatile uint8_t pb_flags1;
uint8_t pb_flags2;
uint8_t pb_b8_hi;
uint8_t pb_b8_lo;
volatile uint8_t pb_state;
uint8_t pb_param1;
uint8_t pb_param2;
volatile enc_t enc;
uint8_t keys;
volatile uint8_t spi_idx;
volatile uint8_t spi_len;
uint8_t line1_loaded;
uint8_t line2_loaded;
volatile uint8_t spi_gap;
volatile uint8_t eeprom_busy;
uint8_t last_language;
uint8_t line1_msg;
uint8_t line2_msg;
uint8_t last_pb3_alarm;
uint8_t blink_presc = 50;

/* bank 1 */
uint8_t led_on;
uint8_t rtc_hour;
uint8_t edit_hour;
uint8_t i2c_err;
uint8_t line1_col;
uint8_t line2_col;
uint8_t scroll_pos;
uint8_t language;
uint8_t eecfg_2;
uint8_t rtc_min;
uint8_t edit_min;
uint8_t keys_count;
uint8_t rtc_sec;
uint8_t line1_chunk;
uint8_t line2_chunk;
uint8_t field_cmd;
uint8_t led_blink;
volatile uint8_t beep;
volatile uint8_t led_out;
uint8_t div_50ms;
volatile uint8_t div_5ms;
uint8_t div_500ms;
uint8_t dim_timer;
volatile uint8_t kbd_delay;
uint8_t line1_shown;
uint8_t line2_shown;
uint8_t spi_period;
uint8_t startup_delay;
volatile uint8_t uart_rx_to;
volatile uint8_t uart_tx_to;
uint8_t pb26_a, pb26_b;
volatile uint8_t uart_rx_idx;
volatile uint8_t uart_rx_len;
volatile uint8_t uart_tx_idx;
volatile uint8_t uart_tx_len;
uint8_t tmr_c7;
uint8_t tmr_c8;
uint8_t tmr_c9;
uint8_t link_timeout;
uint8_t tmr_cb;
uint8_t scroll_len;
uint8_t tmr_cd;
uint8_t uart_timeout;
uint16_t num;
uint16_t ee_sum;
uint16_t ee_size;
uint8_t ee_addr_lo, ee_addr_hi;
uint8_t pb25_a, pb25_b;
uint16_t scroll_tmr;
uint8_t pb27_a, pb27_b;
uint8_t pb24_a, pb24_b;
volatile uint8_t bl_pwm_cnt;
volatile uint8_t bl_pwm_top;
uint8_t div_800ms = 15;

/* banks 2 and 3 */
uint8_t enc_count;
uint8_t eecfg_0;
uint8_t pb_b9;
uint8_t enc_step;
uint8_t enc_pos;
volatile uint8_t idle_tmr;
uint8_t field[10];
volatile uint8_t spi_rx[11];
volatile uint8_t spi_tx[11];
uint8_t i2c_buf[16];
volatile uint8_t uart_buf[23];
volatile disp_t disp;
uint8_t field_shadow[10];
uint8_t line_buf[20];
uint8_t scroll_buf[64];
