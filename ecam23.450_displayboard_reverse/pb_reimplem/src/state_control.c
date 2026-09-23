/*
 * Per-tick state supervisor (state_control, 0x3186), called from main().
 *
 * machine_control() (0x10c0) is the key/process engine that moves
 * mstate/mstep between states. This function runs after it and, for the
 * current mstate/mstep:
 *   - recomputes all the actuator demands from scratch (heater setpoints,
 *     brew unit target, pump volume, grinder run, valves, heater mode);
 *   - advances the step by raising wait_flags.5 ("step done", consumed by
 *     step_sequencer), or does a few time-based transitions itself
 *     (end of warm-up -> ready, end of turn-off -> standby, auto-off ...);
 *   - then runs the unit drivers and the periodic housekeeping.
 *
 * Temperatures are NTC codes: 255 - ADC, so a HIGHER code means COLDER.
 * "SP" below is the coffee setpoint coffee_sp_tbl[set_temperature].
 *
 * The step switches were XOR chains on mstep in the binary; the ready /
 * brew steps of state 7 were a TBLRD jump table at 0x109E (17 entries).
 */
#include "pb.h"

/* wait_flags (r022): demands / waits for step_sequencer */
#define WF_GRIND     0x01   /* wait for the grinder (req_grind) */
#define WF_BU        0x02   /* wait for the brew unit (req_bu_target) */
#define WF_PUMP      0x04   /* wait for the pump volume (req_pump_vol) */
#define WF_HEATA     0x08   /* wait for heater A */
#define WF_STEP_FWD  0x20   /* step done: go to the next step */
#define WF_STEP_BACK 0x40   /* missing condition: step back */

/* sensors (r013), as sent to the display in tx[6] */
#define SN_SPOUT     0x01   /* bit0 (state 0x0E step 2 needs it set) */
#define SN_TOP       0x02   /* bit1 brew unit upper switch */
#define SN_BOTTOM    0x04   /* bit2 brew unit lower switch */
#define SN_NO_GROUNDS 0x08  /* bit3 grounds container missing */
#define SN_NO_TANK   0x10   /* bit4 water tank missing */
#define SN_RA5       0x20   /* bit5 unknown switch (modifies the energy saving logic) */

/* alarms (r018) */
#define AL_TANK_EMPTY 0x01
#define AL_FINE      0x10   /* bit4 ground too fine (no flow) */
#define AL_FAULT     0x40   /* bit6 general fault */

/* settings (r0c2) */
#define SET_ECO      0x10   /* bit4 energy saving */

/* tickflags (r01c): one-pass ticks from timebase() */
#define TICK_10MS    0x04
#define TICK_100MS   0x08
#define TICK_1S      0x10
#define TICK_10S     0x20

/* display key bitmap (keys, r011) */
#define K_1CUP       0x01
#define K_2CUPS      0x02
#define K_HOTWATER   0x04
#define K_MENU       0x08
#define K_ONOFF      0x10
#define K_CLEAN      0x80
#define KH_PUSH      0x02   /* keys_hi bit1: encoder push */

/* brew unit targets (req_bu_target) */
#define BU_UP        0xFFFF /* up to the upper limit (close the chamber) */
#define BU_HOME      0xFFFE /* down to the lower limit */
#define BU_MID       0x0052 /* position 0x52 */

#define ECO          (settings & SET_ECO)

/* 0x1058: coffee setpoint by set_temperature (0..3 used here) */
static const uint8_t coffee_sp_tbl[8] = { 0x76, 0x72, 0x6E, 0x6A, 0x49, 0x40, 0x3B, 0x36 };
/* 0x1030: auto-off delay by set_autooff, 10 s units (15 min .. 3 h) */
static const uint16_t autooff_tbl[5] = { 90, 180, 360, 720, 1080 };
/* 0x108A: ready idle time thresholds for eco_level, 10 s units */
static const uint8_t eco_idle_tbl[5] = { 0, 12, 30, 54, 84 };

static uint8_t coffee_sp(void)
{
    return coffee_sp_tbl[set_temperature];
}

/* ---- common tails */

static void step_done(void)                 /* L_415e */
{
    wait_flags |= WF_STEP_FWD;
}

static void wait_timer_done(void)           /* L_3336 */
{
    if (step_timer == 0)
        step_done();
}

static void bu_move(uint16_t target)        /* L_3354 / L_35a4 / L_40b4 -> L_335a */
{
    req_bu_target = target;
    wait_flags |= WF_BU;
}

static void pump(uint16_t vol)              /* ... -> L_3b08 / L_360a */
{
    req_pump_vol = vol;
    wait_flags |= WF_PUMP;
}

static void go_ready(void)                  /* L_36a2 */
{
    mstate = 7;
    mstep = 0;
}

/* done when there is no tank-empty alarm and the tank and the grounds
   container are in place (L_358c) */
static void done_if_ready_to_run(void)
{
    if (!(alarms & AL_TANK_EMPTY) && !(sensors & SN_NO_TANK) && !(sensors & SN_NO_GROUNDS))
        step_done();
}

/* ---- power-up key combinations (0x31B6), checked once after boot */
static void powerup_keys(void)
{
    if ((keys & K_2CUPS) && (keys & K_HOTWATER) && keys_count == 2) {
        /* display / button test, plus a "first start" reset */
        test_timer = 60;
        test_mode = 1;
        language &= 0xE0;
        settings2 |= 0x01;
        settings &= ~0x80;              /* filter off */
        ee_save_req_c3 = 5;
        ee_save_req_c0 = 5;
    } else if ((keys & K_1CUP) && (keys & K_HOTWATER) && keys_count == 2) {
        test_timer = 1;                 /* never counts down in mode 2 */
        test_mode = 2;                  /* load test */
        test_step = 0;
    } else if ((keys & K_HOTWATER) && (keys & K_CLEAN) && keys_count == 2) {
        test_timer = 60;
        test_mode = 4;                  /* electric test */
        test_step = 0;
        step_timer = 10;
    } else if ((keys_hi & KH_PUSH) && (keys & K_HOTWATER) && keys_count == 2) {
        mstate = 0x0F;                  /* circuit purge */
        mstep = 0;
    } else if ((keys & K_MENU) && (keys & K_ONOFF) && keys_count == 2) {
        bu_stroke_ref = 0;              /* re-learn the brew unit full stroke */
        ee_save_req_c3 = 5;
    } else if ((keys & K_1CUP) && (keys & K_ONOFF) && (keys & K_HOTWATER) && keys_count == 3) {
        test_timer = 60;
        test_mode = 5;                  /* energy saving test */
        test_step = 0;
    }
}

/* ---- factory test modes (0x328C) */
static void test_modes(void)
{
    /* the timer runs in seconds, except in mode 2 */
    if (test_mode == 1 || test_mode == 5 || test_mode == 4 || test_mode == 3 || test_mode == 0) {
        if (tickflags & TICK_1S)
            test_timer--;
    }
    switch (test_mode) {
    case 1: test1_nop(); break;
    case 2: test2_load(); break;
    case 3: test3_remote(); break;
    case 4: test4_auto(); break;
    case 5: test5_select(); break;
    }
}

/* ---- fault recovery (0x3326): alarms.6 set and mstate != 0 */
static void fault_recovery(void)
{
    if (fault_class == 1) {
        switch (fault_step) {
        case 0: wait_timer_done(); break;
        case 1: step_done(); break;
        case 2: if (flags25 & 0x40) bu_move(BU_HOME); break;
        case 3: if (flags25 & 0x40) bu_move(BU_MID); break;
        case 4: step_done(); break;
        case 5: break;
        }
    } else if (fault_class == 2) {
        switch (fault_step) {
        case 0: wait_timer_done(); break;
        case 1: bu_move(BU_HOME); break;
        case 2: wait_timer_done(); break;
        case 3: bu_move(BU_MID); break;
        case 4: break;
        }
    }
}

/* ---- 0x00 standby (0x3420) */
static void st_standby(void)
{
    switch (mstep) {
    case 0:
        step_timer = 20;
        step_done();
        break;
    case 1:
        wait_timer_done();
        break;
    case 2:                             /* idle, the display shows the clock */
        break;
    }
}

/* ---- 0x01 warm-up and 0x08 rinse (0x3444) */
static void st_warmup_heat(void)
{
    uint8_t sp;

    if (mstate == 1 && mstep != 0) {
        if (ECO && !(sensors & SN_RA5)) {           /* L_34da */
            req_heatA_sp = (mstep < 5 && temp_coffee > 0x55) ? 0x76 : 0xC8;
            return;
        }
        if ((flags21 & 0x08) && mstep == 5) {
            req_heat_mode = 5;
            if (temp_coffee > 0x55)
                req_heatA_sp = 0xFA;
            if (temp_steam > 0x55)
                req_heatB_sp = 0xFF;
            return;
        }
        if (mstep == 9) {
            req_heatA_sp = 0x76;
            req_heatB_sp = 0x40;
            req_heat_mode = (sensors & SN_RA5) ? 2 : 1;
            return;
        }
        if (!(heatflags & 0x01) && temp_coffee > 0x75) {
            req_heat_mode = 5;
            req_heatA_sp = 0x76;
            if (temp_steam > 0x3F)
                req_heatB_sp = 0xFF;
            return;
        }
        heatflags |= 0x01;                          /* L_34b8 */
        if (temp_coffee > 0x4E)
            req_heatA_sp = 0x76;
        req_heatB_sp = 0x40;
        req_heat_mode = 2;
        return;
    }

    /* state 8, or state 1 step 0 (L_34f0) */
    if ((flags21 & 0x08) && mstep == 5) {
        sp = coffee_sp();
        if ((int)temp_coffee >= (int)sp - 20)
            req_heatA_sp = (r01f & 0x80) ? 0xFA : 0xFD;
        return;
    }
    if (mstep == 6 || mstep == 0)
        return;
    req_heatA_sp = coffee_sp();
}

static void st_warmup(void)
{
    st_warmup_heat();

    switch (mstep) {                                /* L_36b8 */
    case 0:                                         /* L_3572 */
        if (ECO && mstate == 8 && temp_coffee > 0x8D) {
            r01f |= 0x80;                           /* extra rinse */
            bu_move(BU_MID);
        } else {
            done_if_ready_to_run();
        }
        break;
    case 1:                                         /* L_359e */
        if (mstate == 1)
            bu_move(BU_HOME);
        else if (ECO && (r01f & 0x80))
            bu_move(BU_HOME);
        else
            step_done();
        break;
    case 2:                                         /* L_35b8 */
        if (mstate != 1 || temp_coffee < 0xB6)
            bu_move(BU_UP);
        break;
    case 3:                                         /* L_35ce */
        /* the binary also tests the eco bit on both paths, with no effect */
        if (temp_coffee < 0x8E)
            step_done();
        break;
    case 4:
        step_done();
        break;
    case 5:                                         /* L_35f8: rinse dose */
        if (flags21 & 0x08) {
            pump(mstate == 1 ? 0xAF : qty5_b);
            step_timer = 10;
        } else {
            step_done();
            step_timer = 0;
        }
        break;
    case 6:
        wait_timer_done();
        break;
    case 7:
        bu_move(BU_HOME);
        break;
    case 8:                                         /* L_3626 */
        if (mstate == 8)
            step_done();
        else if ((int)temp_coffee <= (int)coffee_sp() + 10)
            step_done();
        else if (ECO)
            step_done();
        break;
    case 9:                                         /* L_3682 */
        if (mstate != 1) {
            go_ready();
        } else if (ECO) {
            if (temp_coffee < 0xC8)
                go_ready();
        } else if (temp_coffee < 0xA2 && temp_steam < 0x8E) {
            go_ready();
        }
        break;
    }
}

/* ---- 0x02 turning off (0x4000) */
static void st_turnoff(void)
{
    switch (mstep) {
    case 0:
        if (flags26 & 0x80)             /* turned off during warm-up */
            bu_move(BU_HOME);
        else
            step_done();
        break;
    case 1:
        bu_move(BU_UP);
        break;
    case 2:
        wait_timer_done();
        break;
    case 3:                             /* rinse on the way off */
        if (flags21 & 0x08)
            pump(0x4B);
        else
            step_done();
        step_timer = 10;
        break;
    case 4:
        wait_timer_done();
        break;
    case 5:
        step_done();
        break;
    case 6:
        bu_move(BU_MID);
        break;
    case 7:                             /* -> standby */
        mstate = 0;
        mstep = 2;
        saved_mstate = mstate;
        saved_mstep = mstep;
        break;
    }
}

/* ---- 0x04 descaling (0x40E2) */
static uint8_t descale_water_out(void)
{
    /* tank empty and at least 0xB5 flowmeter pulses pumped without water */
    return (alarms & AL_TANK_EMPTY) && nowater_cnt_l >= 0xB5;
}

static void st_descale(void)
{
    req_heat_mode = 1;
    req_heatA_sp = 0xB6;
    req_heatB_sp = 0xB6;

    switch (mstep) {
    case 0:
        step_done();
        break;
    case 1:                             /* L_40f0 */
        if (!(flags1d & 0x08))
            break;
        if (descale_water_out() || (alarms & AL_FINE)) {
            step_done();
            break;
        }
        if (descale_timer != 0 && (tickflags & TICK_1S))
            descale_timer--;
        req_pump_vol = 0xFFFF;
        if (descale_timer > 4)
            req_valves = 3;
        if (descale_timer == 0) {
            step_done();
            reeb = 30;
        }
        break;
    case 2:                             /* L_413a: pause, 10 s units */
        if (reeb != 0 && (tickflags & TICK_10S))
            reeb--;
        if (descale_water_out() || (alarms & AL_FINE)) {
            step_done();
        } else if (reeb == 0) {
            wait_flags |= WF_STEP_BACK;
            descale_timer = 30;
        }
        break;
    case 3:                             /* L_4174 */
        if (!(alarms & AL_TANK_EMPTY) && !(sensors & SN_NO_TANK))
            step_done();
        break;
    case 4:                             /* L_417c: rinse */
        if (!(flags1d & 0x08))
            break;
        if (descale_water_out() || (alarms & AL_FINE))
            step_done();
        else
            req_pump_vol = 0xFFFF;
        if (!(alarms & AL_TANK_EMPTY))
            req_valves = 3;
        break;
    case 5:
        if (flags1d & 0x08)
            step_done();
        break;
    case 6:                             /* back to where descaling was started */
        mstate = saved_mstate;
        mstep = saved_mstep;
        break;
    }
}

/* ---- 0x06 brew unit recovery (0x4058), entered by monitor_faults() */
static void st_bu_recovery(void)
{
    switch (mstep) {
    case 0:
        if (step_timer == 0)
            bu_move(BU_HOME);
        break;
    case 1:
        bu_move(BU_UP);
        break;
    case 2:
        bu_move(BU_HOME);
        break;
    case 3:                             /* L_406e */
        if (saved_mstate == 2) {        /* was turning off: resume it */
            if ((r01f & 0x04) && !(alarms & AL_TANK_EMPTY))
                flags21 |= 0x08;
            else
                flags21 &= ~0x08;
            /* 6/3 goes to saved_*: monitor_faults() then won't re-enter state 6 */
            saved_mstate = mstate;
            saved_mstep = mstep;
            mstep = 0;
            mstate = 2;
        } else {
            mstep = 0;
            mstate = 7;
        }
        break;
    }
}

/* ---- 0x07 ready / brewing (0x36EA) */

/* step 0 with the steam side warm: keep-warm logic (0x371C) */
static void ready_keepwarm(void)
{
    if (ready_timer == 0)
        ready_timer = 4500;             /* 45 s in 10 ms */
    else if (tickflags & TICK_10MS)
        ready_timer--;

    if (ECO && !(sensors & SN_RA5)) {
        /* L_38ec: coffee side held around 0xC3..0xC9, steam side off */
        uint8_t lim;
        if (temp_coffee > 0xC3 && temp_coffee <= 0xC9) {
            if (ready_timer >= 0x33)
                return;
            req_heat_mode = 0;
            lim = 0xC3;
        } else {
            lim = 0xC7;
        }
        if (temp_coffee > lim)
            req_heatA_sp = 0xFF;
        return;
    }

    /* the lower keep-warm target runs only with the eco bit CLEAR and RA5 set */
    heat2_keepwarm = (!ECO && (sensors & SN_RA5) && eco_timer != 0) ? 0x30 : 0x40;

    /* re87 cycles 0..2 at 10 s, 25 s, 40 s of the 45 s period; re95 ramps */
    if ((ready_timer == 1000 && re87 == 0) ||
        (ready_timer == 2500 && re87 == 1) ||
        (ready_timer == 4000 && re87 == 2)) {
        if (re95 == 0)
            re95++;
    }
    if (re95 != 0 && (tickflags & TICK_10MS)) {
        re95++;
        if (re95 > 0x4B) {
            re87++;
            re95 = 0;
        }
        if (re87 > 2)
            re87 = 0;
    }

    /* steam thermoblock around heat2_keepwarm +-4 */
    if ((int)temp_steam >= (int)heat2_keepwarm - 4 && (int)temp_steam <= (int)heat2_keepwarm + 4) {
        req_heat_mode = 3;
        if (re95 != 0 && (int)temp_steam >= (int)heat2_keepwarm - 4) {  /* second test always true */
            req_heatB_sp = 0xFF;
            r01f |= 0x01;
        }
    } else {                            /* L_386c */
        if (temp_steam >= heat2_keepwarm)
            req_heatB_sp = heat2_keepwarm;
        req_heat_mode = 1;
    }

    /* coffee thermoblock (L_387e) */
    if (temp_coffee > 0x71 && temp_coffee <= 0x78) {
        if (ready_timer < 0x33) {
            req_heat_mode = 0;
            if (temp_coffee > 0x71)     /* always true here */
                req_heatA_sp = 0xFF;
        }
    } else {
        if (temp_coffee > 0x75)
            req_heatA_sp = 0x76;
        req_heat_mode = 1;
    }

    if (heatflags & 0x10)               /* L_38ca */
        return;
    if (ECO)
        return;
    if (temp_steam <= 0x40)
        heatflags |= 0x10;
}

/* heater A setpoint while brewing (L_392a) */
static void brew_heat(void)
{
    uint8_t sp = coffee_sp();

    if (mstep < 4) {
        req_heatA_sp = ECO ? sp : 0x76;             /* L_3930 */
        return;
    }
    /* the mstate == 7 tests below are always true (only reached from state 7) */
    if (mstate == 7 && mstep == 4) {
        if (!(r01f & 0x08)) {
            req_heatA_sp = ECO ? sp : 0x76;
        } else if (pump_state == 1 && (out_loads & 0x08)) {
            req_heatA_sp = 0xFF;
        }
        return;
    }
    if (mstep == 5 && !ECO) {
        req_heatA_sp = 0x76;
        return;
    }
    if (mstate == 7 && mstep > 4 && mstep < 7 && ECO) {         /* L_3980 */
        if (flags21 & 0x10)                         /* pre-ground */
            req_heatA_sp = sp + 0x14;
        else if (r01f & 0x40)
            req_heatA_sp = sp;
        else if ((int)temp_coffee > (int)sp + 6)
            req_heatA_sp = 0xF8;
        return;
    }
    if (mstate == 7 && mstep == 7) {                /* L_3a06 */
        if ((int)temp_coffee > (int)sp - 20)
            req_heatA_sp = 0xFF;
        return;
    }
    if (mstate == 7 && mstep == 8) {
        req_heatA_sp = 0xFF;
        return;
    }
    if (mstate == 7 && mstep > 8 && mstep < 11) {
        if (set_temperature == 3)
            req_heatA_sp = 0xFF;
        return;
    }
    if ((mstate == 7 && mstep == 11) || (flags25 & 0x80)) {     /* L_3a9c */
        req_heatA_sp = ((int)temp_coffee > (int)sp + 8) ? 0xFF : sp;
        return;
    }
    if (mstep == 14 && !ECO)                        /* L_3ae2 */
        req_heatA_sp = 0x76;
    else
        req_heatA_sp = sp;
}

/* the espresso cycle: jump table at 0x109E (L_3be8) */
static void brew_steps(void)
{
    switch (mstep) {
    case 0:                             /* ready, waiting for a key (machine_control) */
    case 1:
        break;
    case 2:
        bu_move(BU_MID);
        break;
    case 3:
        bu_move(BU_HOME);
        break;
    case 4:                             /* J_3afa: grind */
        if (flags21 & 0x10) {           /* pre-ground: no grinding */
            if (!(r01f & 0x08))
                step_done();
            else
                pump(20);
            break;
        }
        req_grind = grind_dose;
        wait_flags |= WF_GRIND;
        if (r01f & 0x08)
            pump(20);
        step_timer = (ECO && (r01f & 0x40)) ? 30 : 10;
        break;
    case 5:
        wait_timer_done();
        break;
    case 6:                             /* J_3b2a: close the chamber */
        bu_move(BU_UP);
        step_timer = 20;
        break;
    case 7:                             /* J_3b36 */
        if (step_timer != 0)
            break;
        if (!ECO || (int)temp_coffee <= (int)coffee_sp() + 16)
            step_done();
        break;
    case 8:                             /* pre-infusion */
        pump(0x19);
        step_timer = 30;
        break;
    case 9:
        wait_timer_done();
        break;
    case 10:
        bu_move(BU_UP);
        break;
    case 11:                            /* J_3b9a: brew water dose */
        if (flags28 & 0x04)             /* programming the quantity */
            pump(0xFFFE);
        else if (flags21 & 0x02)        /* two cups */
            pump(target_qty);
        else
            pump(target_qty_total);
        break;
    case 12:                            /* J_3bb6 */
        if ((flags25 & 0x02) && (flags25 & 0x04))
            bu_move(BU_UP);
        else
            step_done();
        step_timer = 30;
        break;
    case 13:                            /* J_3bc8 */
        if (!(flags25 & 0x80)) {
            wait_timer_done();
        } else {
            pump(0x186);
            step_timer = 30;
        }
        break;
    case 14:
    case 15:
        bu_move(BU_HOME);
        break;
    case 16:
        go_ready();
        break;
    }
}

static void st_ready(void)
{
    if (temp_coffee > 0x4E) {           /* heating skipped while very hot */
        if (mstep == 0 && temp_steam > 0x24)
            ready_keepwarm();
        else
            brew_heat();
    }
    brew_steps();
}

/* ---- 0x0A milk / cappuccino (0x3C0E) */
static void st_milk_heat(void)
{
    if (mstep == 1) {
        req_heat_mode = ECO ? 2 : 3;
        if (temp_steam > 0x35)
            req_heatB_sp = 0x2B;
        if ((flags1d & 0x01) && temp_coffee > coffee_sp())
            req_heatA_sp = coffee_sp();
        return;
    }
    if (mstep == 2 || mstep == 3 || (flags1d & 0x02)) {         /* L_3c96 */
        if (temp_steam > 0x1D) {
            req_heat_mode = 3;
            req_heatB_sp = 0xFF;
        }
        return;
    }
    if (mstep == 4) {
        if (temp_steam > 0x24) {
            req_heat_mode = 3;
            req_heatB_sp = 0xFF;
        }
        return;
    }
    if (mstep != 0)
        req_heatA_sp = coffee_sp();
}

static void st_milk(void)
{
    uint8_t cappu_active;

    st_milk_heat();

    switch (mstep) {                    /* L_3dfc */
    case 0:
        if (step_timer == 0)
            go_ready();
        break;
    case 1:                             /* L_3ce4 */
        if (r01f & 0x08) {
            req_pump_vol = 20;          /* no wait flag here */
        } else if (temp_steam <= 0x35 && cappu_toggle_win == 0) {
            step_timer = 25;
            step_done();
        } else {
            req_pump_vol = 0xFFFF;      /* steam heating */
        }
        break;
    case 2:                             /* L_3d1a */
        req_pump_vol = 0xFFFF;
        if (step_timer == 0) {
            step_done();
            step_timer = 50;
        }
        break;
    case 3:                             /* L_3d34: milk */
        req_pump_vol = 0xFFFE;
        req_valves = 1;
        if (step_timer == 0)
            req_valves |= 2;
        if (flags1d & 0x10)             /* programming: the key ends it */
            break;
        if (milk_prog_slot == 0)
            r096 = qty_milk_0;
        else if (milk_prog_slot == 0x40)
            r096 = qty_milk_1;
        else if (milk_prog_slot == 0x80)
            r096 = qty_milk_2;
        /* the milk dose is a time: uptime_100ms is a 100 ms counter that
           machine_control clears when the milk starts (0x1d2c) */
        if (uptime_100ms >= r096)
            step_done();
        break;
    case 4:
        step_timer = 30;
        step_done();
        break;
    case 5:                             /* L_3daa */
        if (flags1d & 0x02) {
            req_valves = 1;
            if (milk_end_timer == 0) {
                req_valves |= 2;
                step_timer = 30;
            } else {
                step_timer = 0;
            }
            req_pump_vol = 0xFFFF;
        } else if (step_timer == 0) {
            step_done();
        }
        break;
    case 6:                             /* L_3dde */
        if (flags1d & 0x01) {
            if (cappu_phase == 5)
                brew_phase = 3;
        } else {
            go_ready();
        }
        break;
    }

    /* cappuccino: coffee phase run alongside the milk steps (L_3e1c) */
    if (!(flags1d & 0x01))
        return;
    cappu_active = ECO ? (mstep > 0) : (mstep > 1);
    if (!cappu_active)
        return;
    switch (cappu_phase) {
    case 1:
    case 2:
        req_bu_target = BU_HOME;
        flags1d |= 0x80;
        break;
    case 3:
        if (!ECO)
            cappu_phase++;
        break;
    case 4:
        if (flags21 & 0x10) {           /* pre-ground */
            cappu_phase++;
        } else {
            req_grind = grind_dose;
            flags1d |= 0x40;
        }
        break;
    }
}

/* ---- 0x0B hot water / steam and 0x0C cleaning (0x3E80) */
static void st_hotwater_heat(void)
{
    if (mstate == 0x0C) {
        req_heat_mode = 3;
        if (ECO && temp_steam > 0x67) {
            req_heatB_sp = 0x67;
            return;
        }
        if (temp_steam > 0x24)
            req_heatB_sp = 0xFF;
        return;
    }
    if (mstep == 2) {
        if (temp_coffee > 0x5D)
            req_heatA_sp = 0xFF;
        return;
    }
    if (mstep == 0)
        return;
    req_heat_mode = 5;
    req_heatA_sp = coffee_sp();
    if (temp_steam > 0x8D)
        req_heatB_sp = 0xFF;
}

static void st_hotwater(void)
{
    st_hotwater_heat();

    switch (mstep) {                    /* L_3fea */
    case 0:
        if (mstate == 0x0C)
            step_done();
        else if (step_timer == 0)
            go_ready();
        break;
    case 1:
        if (mstate == 0x0B) {
            if (temp_coffee <= 0x8E && temp_steam <= 0xA2) {
                step_done();
            } else {
                req_pump_vol = 0xFFFF;
                if (temp_steam > 0xA2)
                    rec5 = 30;
            }
        } else {
            if (temp_steam <= 0x67)
                step_done();
            else
                req_pump_vol = 0xFFFF;
        }
        break;
    case 2:                             /* dispense */
        if (mstate == 0x0B) {
            req_valves = 3;
            req_pump_vol = (flags1d & 0x10) ? 0xFFFE : qty_hotwater;
        } else if (mstate == 0x0C) {
            req_pump_vol = 0xFFFF;
            req_valves = 3;
        }
        wait_flags |= WF_PUMP;
        break;
    case 3:
        if (mstate == 0x0B)
            rebd = 30;
        step_done();
        break;
    case 4:
        if (mstate != 0x0B || rebd == 0)
            go_ready();
        break;
    }
}

/* ---- 0x0D first start / language (0x33BC) */
static void st_first_start(void)
{
    switch (mstep) {
    case 0:
    case 1:
        step_timer = 30;
        break;
    case 2:
        wait_timer_done();
        break;
    case 3:                             /* waiting for OK (machine_control) */
        break;
    }
}

/* ---- 0x0E circuit fill with the spout (0x33DC) */
static void st_fill(void)
{
    switch (mstep) {
    case 0:
        done_if_ready_to_run();
        break;
    case 2:
        if (sensors & SN_SPOUT) {
            pump(0xB4);
            req_valves = 3;
        } else {
            wait_flags |= WF_STEP_BACK;
        }
        break;
    case 4:
        bu_move(BU_HOME);
        break;
    }
}

/* ---- 0x0F circuit purge (0x40AE) */
static void st_purge(void)
{
    req_heatA_sp = 0x5A;
    switch (mstep) {
    case 0:
        bu_move(BU_UP);
        break;
    case 1:
        wait_flags |= WF_HEATA;
        step_timer = 100;
        break;
    case 2:
        if (step_timer == 0) {
            mstate = 0;
            mstep = 0;
        }
        break;
    }
}

/* ---- drivers and periodic housekeeping (L_4230) */

static void autooff(void)             /* 0x425C */
{
    if (mstate == 0 || mstate == 2 || mstate == 4 || mstate == 0x0F ||
        (key_edges | keys_hi_edges) || (r01e & 0x08) || (r01e & 0x10) ||
        (grind_state == 1 && (out_loads & 0x10)) ||
        (pump_state == 1 && (out_loads & 0x08))) {
        autooff_time = autooff_tbl[set_autooff];
        return;
    }
    if (autooff_time == 0 || !(tickflags & TICK_10S))
        return;
    if (--autooff_time != 0)
        return;

    flags21 |= 0x08;                    /* rinse on the way off */
    if (mstate == 7 && mstep < 14 && mstep != 0) {
        step_timer = 30;
        flags26 &= ~0x80;
        flags21 &= ~0x08;
    } else if (mstate == 1 && mstep == 0) {
        flags26 |= 0x80;
    } else {
        flags26 &= ~0x80;
    }
    mstep = 0;
    mstate = 2;                         /* turning off */
}

static void ready_idle_update(void)   /* 0x4344 */
{
    uint8_t i;

    if (mstate == 7 && mstep == 0) {
        if (!(tickflags & TICK_10S))
            return;
        if (ready_idle != 0xFF)
            ready_idle++;
        if (ready_idle <= eco_idle_tbl[0]) {
            eco_level = 0;
        } else if (ready_idle >= eco_idle_tbl[4]) {
            eco_level = 4;
        } else {
            for (i = 0; !(ready_idle < eco_idle_tbl[i + 1]); i++)
                ;
            eco_level = i;
        }
        if (!ECO && (sensors & SN_RA5) && eco_timer != 0)
            eco_timer--;
        return;
    }
    if (mstate == 8 || mstate == 0)
        ready_idle = 0;
    else if (mstate == 7 && mstep < 14 && mstep != 0 && pump_state == 1 && (out_loads & 0x08))
        ready_idle = 0;
}

static void drivers_and_housekeeping(void)
{
    out_loads = 0;
    out_loads2 = 0;
    wait_snapshot();
    heat_power_mgr();
    heatB_ctrl();
    heatA_ctrl();
    pump_ctrl();
    grinder_ctrl();
    bu_motor();
    step_sequencer();
    progress_update();
    brew_power_adapt();

    autooff();

    /* 0x4320 */
    if ((pump_state == 1 && (out_loads & 0x08)) || (mstate == 7 && mstep < 14 && mstep != 0))
        reed = 12;

    ready_idle_update();

    /* 0x440E */
    if (bu_pos >= 0x14 && bu_pos < 0x2D) {
        if (sensors & SN_NO_TANK)
            bu_idle_delay = 30;
    } else {
        bu_idle_delay = 0;
    }

    if (!(!ECO && mstate == 7 && mstep == 0 && (sensors & SN_RA5)))
        eco_timer = 120;                /* 20 min */

    ref0 = 0;
    counters_update();

    /* brew unit motor bookkeeping from the loads just computed (0x4460) */
    if ((out_loads & 0x02) && (out_loads & 0x40))
        ioflags |= 0x01;
    else if ((out_loads & 0x01) && (out_loads & 0x40))
        ioflags &= ~0x01;
    if (!(out_loads & 0x02) && !(out_loads & 0x01))
        bu_softstart = 50;
    if (out_loads & 0x40)
        bu_runon = 50;
    if (bu_state == 1 || bu_state == 4)
        bu_delay_down = 30;
    if (bu_state == 2 || bu_state == 5)
        bu_delay_up = 30;

    /* delayed EEPROM save requests, 100 ms units (0x44B2) */
    if (test_timer != 0 && test_mode != 1 && test_mode != 5) {
        ee_save_req_c3 = 0;
        red9 = 0;
        ee_flags &= ~0x20;
        ee_flags &= ~0x08;
    } else {
        if (ee_save_req_c3 != 0 && (tickflags & TICK_100MS)) {
            if (--ee_save_req_c3 == 0)
                ee_flags |= 0x20;       /* save record B (settings) */
        }
        if (red9 != 0 && (tickflags & TICK_100MS)) {
            if (--red9 == 0)
                ee_flags |= 0x08;       /* save record C (counters) */
        }
    }
    if (ee_save_req_c0 != 0 && (tickflags & TICK_100MS)) {
        if (--ee_save_req_c0 == 0)
            ee_flags |= 0x02;           /* save record A (recipes) */
    }
}

/* 0x3186 */
void state_control(void)
{
    loop_tasks++;

    /* every demand is recomputed on each tick */
    wait_flags &= ~(0x01 | 0x02 | 0x04 | 0x08 | 0x10 | 0x20 | 0x40);
    ioflags &= ~0x08;
    flags1d &= ~(0x80 | 0x40);
    gateflags2 &= ~(0x80 | 0x01);
    flags21 &= ~0x80;
    r01e &= ~0x80;
    req_heatA_sp = 0;
    req_heatB_sp = 0;
    req_grind = 0;
    req_pump_vol = 0;
    req_bu_target = 0;
    req_valves = 0;
    req_heat_mode = 0;

    if (flags25 & 0x01) {               /* first tick after boot */
        flags25 &= ~0x01;
        powerup_keys();
    }

    if (sysflags & 0x20)
        goto drivers;

    if (test_timer != 0) {
        test_modes();
        goto drivers;
    }

    if (active_timer == 0)              /* power not ready */
        goto drivers;

    machine_control();

    if (alarms & AL_FAULT) {
        if (mstate != 0)
            fault_recovery();
        goto drivers;
    }

    switch (mstate) {                   /* 0x41D6 */
    case 0x00: st_standby(); break;
    case 0x01: st_warmup(); break;
    case 0x02: st_turnoff(); break;
    case 0x04: st_descale(); break;
    case 0x06: st_bu_recovery(); break;
    case 0x07: st_ready(); break;
    case 0x08: st_warmup(); break;      /* rinse shares the warm-up code */
    case 0x0A: st_milk(); break;
    case 0x0B: st_hotwater(); break;
    case 0x0C: st_hotwater(); break;
    case 0x0D: st_first_start(); break;
    case 0x0E: st_fill(); break;
    case 0x0F: st_purge(); break;
    }

drivers:
    drivers_and_housekeeping();
}
