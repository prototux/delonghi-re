/*
 * grinder_adapt.c - adaptive grinder dose (0x2BE6 grind_history_update,
 * 0x2718 grind_dose_compute).
 *
 * The brew unit stops going up on the coffee cake, so the stroke measured
 * in bu_pos pulses tells how much ground coffee was in the chamber:
 *   bu_stroke_ref  (r0BC, record B) learned full stroke, no coffee
 *                  (the name is historical: it is a stroke, not a time)
 *   stroke         bu_pos when the brew unit stopped on the cake
 *   ref - stroke   cake height
 * The firmware keeps two samples of (cake height, grinder dose, target) in
 * record B and scales the grinder dose so the cake reaches the target of
 * the chosen taste (grind_1cup / grind_2cup).
 *
 *   grind_hist_a / set_b2  cake height, last / previous
 *   grind_hist_b / set_b5  grinder dose used, last / previous
 *   grind_hist_c / set_b7  target (recb), last / previous
 *   grind_center           cake per dose average used last time
 *   set_b3                 scale factor (record B byte 3, default 0x50)
 *
 *   grind_dose_hi/lo       bounds of grind_dose (r0ECD upper, r0ECE lower)
 *
 * The 32 bit helpers (mul32 0x0F70 / 0x85A8, divmod32 0x85BC, shl32 0x857E)
 * are plain unsigned C maths; the divide gives 0 when dividing by 0.
 * r073..r07A, r08C..r08F, re4A, re4B are scratch and became locals.
 */
#include "pb.h"

static uint32_t div32(uint32_t a, uint32_t b)
{
    return b ? a / b : 0;
}

/* 0x2BE6: called at the end of a brew with the stroke measured
 * (machine_control passes bu_pos through r0F5:r0F6) */
void grind_history_update(uint16_t stroke)
{
    uint16_t cake;

    if (bu_stroke_ref >= stroke)
        cake = bu_stroke_ref - stroke;
    else
        cake = 0;

    if (alarms2 & 0x20) {
        /* "less coffee": the chamber was too full, restart from defaults */
        grind_hist_a = 0x15;
        set_b2 = 0x15;
        grind_hist_b = 0x43;
        set_b5 = 0x43;
        grind_hist_c = 0x36;                        /* set_b7 is left alone */
        grind_center = 0x50;
    } else if ((gateflags2 & 0x08) || (cake < 0x2e && cake >= 8)) {
        /* plausible cake (or the dose was clamped last time): shift in */
        set_b5 = grind_hist_b;
        grind_hist_b = grind_dose;
        set_b7 = grind_hist_c;
        grind_hist_c = recb;
        set_b2 = grind_hist_a;
        grind_hist_a = (uint8_t)cake;
        grind_center = grind_avg;
    }
}

/* 0x2718: grinder dose for this brew, into grind_dose (copied to req_grind
 * by state_control). gateflags2.3 = the dose had to be clamped. */
void grind_dose_compute(void)
{
    uint32_t n;
    uint16_t w;
    uint8_t lo, hi;

    gateflags2 &= ~0x08;

    /* cake per dose of the two samples, summed, x128:
     * (a*b5 + b2*b) * 128 / b / b5 = 128 * (a/b + b2/b5) */
    n = (uint32_t)((uint16_t)(grind_hist_a * set_b5)) + (uint16_t)(set_b2 * grind_hist_b);
    n <<= 7;
    n = div32(n, grind_hist_b);
    n = div32(n, set_b5);

    /* limited to grind_center +- 3 */
    lo = (grind_center > 3) ? grind_center - 3 : 0;
    hi = (grind_center < 0xfc) ? grind_center + 3 : 0xff;
    if (n < lo)
        grind_avg = lo;
    else if (n > hi)
        grind_avg = hi;
    else
        grind_avg = (uint8_t)n;

    if (flags21 & 0x02) {                           /* one cup */
        recb = grind_1cup;
        n = div32(0x0800, grind_avg);
        grind_dose_lo = (n >= 0x100) ? 0xff : (uint8_t)n;      /* lower bound */
        n = div32((uint32_t)set_b3 * 0x44, grind_avg);
        grind_dose_hi = (n >= 0x100) ? 0xff : (uint8_t)n;      /* upper bound */
    } else {                                        /* two cups */
        recb = grind_2cup;
        n = div32(0x2d00, grind_avg);
        grind_dose_hi = (n >= 0x100) ? 0xff : (uint8_t)n;      /* upper bound */
        n = div32((uint32_t)set_b3 * 0x3f, grind_avg);
        grind_dose_lo = (n >= 0x100) ? 0xff : (uint8_t)n;      /* lower bound */
    }
    if (grind_dose_hi < grind_dose_lo)
        grind_dose_hi = grind_dose_lo;

    if ((int16_t)recb <= (int16_t)grind_hist_c + 1 &&
        (int16_t)recb >= (int16_t)grind_hist_c - 1) {
        /* target unchanged: correct the last dose by the cake error.
         * w = cake/(target*scale) of both samples, x32768 */
        n = div32((uint32_t)grind_hist_a << 16, ((uint32_t)grind_hist_c * set_b3) << 1);
        w = (n >= 0x8000) ? 0x7fff : (uint16_t)n;
        n = div32((uint32_t)set_b2 << 16, ((uint32_t)set_b7 * set_b3) << 1);
        w += (n >= 0x8000) ? 0x7fff : (uint16_t)n;
        if (w >= 0x200)
            n = 0;
        else
            n = (uint32_t)(uint16_t)(0x200 - w) * grind_hist_b;
        n >>= 8;
    } else {
        /* new target: scale the last dose */
        n = div32((uint16_t)(recb * grind_hist_b), grind_hist_c);
    }

    if (n < grind_dose_lo) {
        grind_dose = grind_dose_lo;
        gateflags2 |= 0x08;
    } else if (n > grind_dose_hi) {
        grind_dose = grind_dose_hi;
        gateflags2 |= 0x08;
    } else {
        grind_dose = (uint8_t)n;
    }
}
