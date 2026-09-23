/*
 * Thermoblock temperatures (0x0DA6 adc_init, 0x0DD8 adc_task, 0x0EAE isr_adc).
 *
 * Two NTC channels: AN0 = steam thermoblock (temp_steam), AN1 = coffee
 * thermoblock (temp_coffee). Only the 8 high bits are used (left justified).
 * The conversion is started by isr_tmr2 10 ms after the channel switch, the
 * ISR stores the result and adc_task accumulates it: after 32 samples per
 * channel (about 0.64 s) the averages are published as 255 - average.
 * There is no conversion to degrees; all thresholds in the firmware compare
 * these raw codes (a higher code is a colder block).
 */
#include "pb.h"

/* sysflags */
#define SYS_ADC_DONE    0x08

/* 0x1000: ADCON0 channel select per channel index */
static const uint8_t adc_chan_table[2] = { 0x00, 0x04 };    /* AN0, AN1 */

/* 0x0DA6 */
void adc_init(void)
{
    adc_chan = 0;
    ADCON1 = 0x0D;              /* AN0, AN1 analog, Vref = Vdd/Vss            */
    ADCON2 = 0x11;              /* left justified, 4 TAD, Fosc/8               */
    ADCON0 = adc_chan_table[adc_chan];
    NOP();
    ADCON0bits.ADON = 1;
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;
    adc_start_timer = 10;
}

/* 0x0DD8 */
void adc_task(void)
{
    loop_tasks++;

    if (sysflags & SYS_ADC_DONE) {
        sysflags &= ~SYS_ADC_DONE;
        adc_sum[adc_chan] += adc_last;
        if (++adc_chan > 1) {
            adc_chan = 0;
            if (++adc_nsamples > 31) {
                temp_steam = 0xFF - (uint8_t)(adc_sum[0] >> 5);
                temp_coffee = 0xFF - (uint8_t)(adc_sum[1] >> 5);
                adc_nsamples = 0;
                for (uint8_t i = 0; i < 2; i++)
                    adc_sum[i] = 0;
            }
        }
        ADCON0 = adc_chan_table[adc_chan] | 0x01;   /* select, ADON */
        PIR1bits.ADIF = 0;
        PIE1bits.ADIE = 1;
        adc_start_timer = 10;
    }

    /* heating rate of the coffee thermoblock over 2 s (reb4: 100 ms timer) */
    if (reb4 == 0) {
        reb4 = 20;
        temp_coffee_slope = temp_coffee - temp_an1_prev;
        temp_an1_prev = temp_coffee;
    }
}

/* 0x0EAE */
void isr_adc(void)
{
    PIE1bits.ADIE = 0;
    adc_last = ADRESH;
    PIR1bits.ADIF = 0;
    sysflags |= SYS_ADC_DONE;
}
