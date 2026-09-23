/*
 * Rotary encoder (0x10D8 MAINLOOP_SUB3).
 *
 * The direction is latched on the first edge (A first: clockwise, B first:
 * counter-clockwise). The detent is only counted once the full sequence
 * has been seen and both contacts are open again:
 *     CW : A -> A+B -> B -> idle
 *     CCW: B -> A+B -> A -> idle
 * A counted detent bumps enc_count (sent to the power board) and raises
 * tick.enc_cw / tick.enc_ccw for the UI.
 */
#include "hw.h"
#include "fw.h"

enum { POS_IDLE = 0, POS_A = 1, POS_B = 2, POS_AB = 3 };

void encoder_poll(void)
{
    enc.a = ENC_A;
    enc.b = ENC_B;

    if (!enc.a && !enc.b) {
        enc.act_a = 0;
        enc.act_b = 0;
        enc_pos = POS_IDLE;
    } else if (enc.a && !enc.b) {
        if (!enc.dir_ccw)
            enc.dir_cw = 1;
        enc.act_a = 1;
        enc.act_b = 0;
        enc_pos = POS_A;
    } else if (!enc.a && enc.b) {
        if (!enc.dir_cw)
            enc.dir_ccw = 1;
        enc.act_a = 0;
        enc.act_b = 1;
        enc_pos = POS_B;
    } else {
        enc_pos = POS_AB;
    }

    if (enc.dir_cw) {
        if ((enc_step == 0 && enc_pos == POS_A) ||
            (enc_step == 1 && enc_pos == POS_AB) ||
            (enc_step == 2 && enc_pos == POS_B)) {
            enc_step++;
        } else if (enc_step == 3 && enc_pos == POS_IDLE) {
            tick.enc_cw = 1;
            tick.enc_ccw = 0;
            enc_step = 0;
            enc.dir_cw = 0;
            enc_count++;
        }
    } else if (enc.dir_ccw) {
        if ((enc_step == 0 && enc_pos == POS_B) ||
            (enc_step == 1 && enc_pos == POS_AB) ||
            (enc_step == 2 && enc_pos == POS_A)) {
            enc_step++;
        } else if (enc_step == 3 && enc_pos == POS_IDLE) {
            tick.enc_cw = 0;
            tick.enc_ccw = 1;
            enc_step = 0;
            enc.dir_ccw = 0;
            enc_count--;
        }
    }
}
