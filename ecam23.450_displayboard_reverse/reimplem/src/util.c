/*
 * Helpers (0x14CE Evelise + 0x1A29 Eloane, 0x1E71 delay_2ms).
 *
 * The original also has a 16x16 multiply (0x19EE Estelle) and a 16/16
 * divide (0x00C3 Elise); in C these are plain * / %.
 */
#include "hw.h"
#include "fw.h"

uint8_t bcd_to_bin(uint8_t bcd)
{
    return (uint8_t)((bcd >> 4) * 10 + (bcd & 0x0F));
}

/* ~1.0 ms per unit at 8 MHz (4 x 166 x 3 cycles), clears the watchdog */
void delay_ms(uint8_t n)
{
    uint8_t j;
    volatile uint8_t k;

    do {
        for (j = 4; j != 0; j--) {
            for (k = 0xA6; --k != 0; )
                ;
            CLRWDT();
        }
    } while (--n != 0);
}
