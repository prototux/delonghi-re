/*
 * Factory test modes (0x6386..0x6830).
 *
 * state_control calls one of these instead of machine_control while a test
 * mode is active (test_timer != 0), chosen by test_mode (display state
 * 0x20 + test_mode). They only set unit requests, like machine_control;
 * test_step is advanced by step_sequencer and sent to the display.
 *
 *   1  test1_nop     display / key test, nothing to drive
 *   2  test2_load    LOAD TEST, one load per key
 *   3  test3_remote  remote load test, driven by UART command 0x80
 *   4  test4_auto    automatic self test
 *   5  test5_select  step select with the clean (ESC) / hot water (OK) keys
 */
#include "pb.h"
#include "units.h"

/* 0x1058: coffee temperature setpoints, indexed by set_temperature */
static const uint8_t coffee_setpoints[4] = { 0x76, 0x72, 0x6E, 0x6A };

/* 0x6386 */
void test1_nop(void)
{
}

/* 0x6388 */
void test5_select(void)
{
    switch (test_step) {
    case 0:
        if ((key_edges & KEY_HOTWATER) && keys_count == 1) {
            test_step = 1;
            break;
        }
        /* fall through */
    case 1:
        if ((key_edges & KEY_CLEAN) && keys_count == 1)
            test_step = 2;
        break;
    case 2:
        if ((key_edges & KEY_HOTWATER) && keys_count == 1)
            test_step = 1;
        break;
    case 3:
        break;
    }
}

/* 0x63CC: LOAD TEST.
 * Steps 0..2 home the brew unit, move it up, then to position 82.
 * Step 3: each key held alone drives one load. 2 cups moves the brew unit
 * down (step 4) then up (step 5), then back to step 3. */
void test2_load(void)
{
    if (test_step > 2) {
        if ((keys & (KEY_MENU | KEY_HOTWATER | KEY_CLEAN | KEY_1CUP | KEY_CAPPU | KEY_ONOFF) ||
             (keys_hi & KEYHI_PUSH)) && keys_count == 1) {
            test_step = 3;
        } else if ((key_edges & KEY_2CUPS) && keys_count == 1) {
            /* sic: 3 or 4 -> 4, 5 stays 5 */
            test_step = (test_step == 5) ? 5 : 4;
        } else if (test_step > 5) {
            test_step = 3;
        }
    }

    switch (test_step) {
    case 0:                                         /* 0x641E */
        req_bu_target = BU_TO_BOTTOM;
        wait_flags |= WAIT_BU;
        break;
    case 1:
        req_bu_target = BU_TO_TOP;
        wait_flags |= WAIT_BU;
        break;
    case 2:
        req_bu_target = 0x52;
        wait_flags |= WAIT_BU;
        break;
    case 3:                                         /* 0x6432 */
        test_key_sel = 0;
        if ((keys & KEY_MENU) && keys_count == 1)
            req_heatA_sp = coffee_setpoints[set_temperature];   /* HEATER */
        else if ((keys & KEY_1CUP) && keys_count == 1)
            req_valves = VALVE_EV1;
        else if ((keys & KEY_ONOFF) && keys_count == 1)
            req_valves = VALVE_EV1 | VALVE_EV2;
        else if ((keys & KEY_CLEAN) && keys_count == 1)
            req_grind = 10;                                     /* GRINDER */
        else if ((keys & KEY_HOTWATER) && keys_count == 1)
            req_pump_vol = PUMP_UNLIMITED;                      /* PUMP */
        else if ((keys_hi & KEYHI_PUSH) && keys_count == 1)
            req_valves = VALVE_EV2;
        else if ((keys & KEY_CAPPU) && keys_count == 1) {
            req_heatB_sp = 0x30;                                /* VAPORIZER */
            req_heat_mode = 3;
        }
        break;
    case 4:
        if ((keys & KEY_2CUPS) && keys_count == 1) {
            req_bu_target = BU_TO_BOTTOM;
            wait_flags |= WAIT_BU;
        }
        break;
    case 5:
        if ((keys & KEY_2CUPS) && keys_count == 1) {
            req_bu_target = BU_TO_TOP;
            wait_flags |= WAIT_BU;
        }
        break;
    }
}

/* 0x64F8: automatic self test. Each step runs for step_timer (100 ms units,
 * counted down by timebase) then asks for the next one with wait_flags.5. */
void test4_auto(void)
{
    uint8_t reload;

    switch (test_step) {
    case 0: case 2: case 4: case 6: case 8:         /* 0x64FA: pauses */
        reload = 20;
        break;
    case 1:
        req_heatA_sp = 0x27;
        reload = 10;
        break;
    case 3:
        req_grind = 20;
        req_pump_vol = PUMP_UNLIMITED;
        reload = 10;
        break;
    case 5:
        req_bu_target = BU_TO_TOP;
        reload = 10;
        break;
    case 7:
        req_bu_target = BU_TO_BOTTOM;
        reload = 10;
        break;
    case 9:
        req_heatB_sp = 0x30;
        req_heat_mode = 3;
        reload = 10;
        break;
    case 10: case 12:
        reload = 30;
        break;
    case 11:
        req_valves = VALVE_EV1;
        reload = 30;
        break;
    case 13:                                        /* last step: no reload */
        req_valves = VALVE_EV2;
        if (step_timer == 0)
            wait_flags |= STEP_FWD;
        return;
    default:                                        /* 14: done */
        return;
    }

    if (step_timer == 0) {
        wait_flags |= STEP_FWD;
        step_timer = reload;
    }
}

/* 0x65C0: remote load test, driven by the 4 bytes of UART command 0x80:
 * test_cmd, test_arg0, then a word test_arg1:test_arg2 (high:low).
 * Step 0 waits for a command; in step 1 the command is applied every tick
 * until it goes back to 0. */
void test3_remote(void)
{
    test_echo = 0;
    if (test_cmd == 0xC8)
        r01e |= F1E_REMOTE_C8;
    else if (test_cmd != 0)
        r01e &= ~F1E_REMOTE_C8;
    if (test_cmd == 0)
        test_step = 0;

    if (test_step == 0) {
        if (test_cmd != 0)
            test_step++;
        return;
    }
    if (test_step != 1)
        return;

    /* the word argument goes through r069:r06a, the compiler's shared
       scratch word: a local here */
    uint16_t word;

    switch (test_cmd) {
    case 0x01:                                      /* brew unit up */
        req_bu_target = BU_TO_TOP;
        wait_flags |= WAIT_BU;
        break;
    case 0x02:                                      /* brew unit down */
        req_bu_target = BU_TO_BOTTOM;
        wait_flags |= WAIT_BU;
        break;
    case 0x09:                                      /* brew unit to a position */
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_bu_target = word;
        wait_flags |= WAIT_BU;
        break;
    case 0x03:                                      /* pump, 0 -> 100 pulses */
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word != 0 ? word : 100;
        wait_flags |= WAIT_PUMP;
        break;
    case 0x04:                                      /* grinder, 0 -> 50 ticks */
        req_grind = test_arg2 != 0 ? test_arg2 : 0x32;
        wait_flags |= WAIT_GRIND;
        break;
    case 0x05:                                      /* heater A, 0 -> user setpoint */
        if (test_arg2 != 0)
            req_heatA_sp = test_arg2;
        else
            req_heatA_sp = coffee_setpoints[set_temperature];
        break;
    case 0x16:                                      /* heater A + pump */
        req_heatA_sp = test_arg0;
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word;
        wait_flags |= WAIT_PUMP;
        break;
    case 0x17:                                      /* heater A + grinder */
        req_heatA_sp = test_arg0;
        req_grind = test_arg2;
        wait_flags |= WAIT_GRIND;
        break;
    case 0x18:                                      /* heater A + brew unit */
        req_heatA_sp = test_arg0;
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_bu_target = word;
        wait_flags |= WAIT_BU;
        break;
    case 0x1C:                                      /* pump through EV1 */
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word;
        req_valves = VALVE_EV1;
        wait_flags |= WAIT_PUMP;
        break;
    case 0x1D:                                      /* pump through EV2 */
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word;
        req_valves = VALVE_EV2;
        wait_flags |= WAIT_PUMP;
        break;
    case 0x1E:                                      /* EV1 + EV2 */
        req_valves = VALVE_EV1 | VALVE_EV2;
        break;
    case 0x1F:                                      /* pump through EV1 + EV2 */
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word;
        wait_flags |= WAIT_PUMP;
        req_valves = VALVE_EV1 | VALVE_EV2;
        break;
    case 0x06:                                      /* heater B, 0 -> 0x30 */
        req_heatB_sp = test_arg2 != 0 ? test_arg2 : 0x30;
        req_heat_mode = 3;
        break;
    case 0x15:                                      /* both heaters, alternating */
        req_heatA_sp = test_arg1;
        req_heatB_sp = test_arg2;
        req_heat_mode = 1;
        break;
    case 0x19:                                      /* heater B + pump */
        req_heatB_sp = test_arg0;
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_pump_vol = word;
        wait_flags |= WAIT_PUMP;
        req_heat_mode = 3;
        break;
    case 0x1A:                                      /* heater B + grinder */
        req_heatB_sp = test_arg0;
        req_grind = test_arg2;
        wait_flags |= WAIT_GRIND;
        req_heat_mode = 3;
        break;
    case 0x1B:                                      /* heater B + brew unit */
        req_heatB_sp = test_arg0;
        word = ((uint16_t)test_arg1 << 8) | test_arg2;
        req_bu_target = word;
        wait_flags |= WAIT_BU;
        req_heat_mode = 3;
        break;
    case 0x08:
        req_valves = VALVE_EV2;
        break;
    case 0x07:
        req_valves = VALVE_EV1;
        break;
    case 0x0A:                                      /* echo a0 to the display */
        test_echo = test_arg0;
        break;
    }
}
