/*
 * Private bit masks for the unit drivers (heaters.c, water.c, brew_unit.c,
 * sequencer.c, test_modes.c). The variables themselves are declared in pb.h.
 */
#ifndef UNITS_H
#define UNITS_H

/* sensors (r013, raw inputs XOR 0x63, sent to the display as SPI tx[6]) */
#define SNS_SPOUT_OUT       0x01    /* RE0: hot water spout missing              */
#define SNS_BU_TOP          0x02    /* RA7: brew unit at the upper limit         */
#define SNS_BU_BOTTOM       0x04    /* RE1: brew unit at the lower limit         */
#define SNS_GROUNDS_OUT     0x08    /* RB0: grounds container missing            */
#define SNS_TANK_OUT        0x10    /* RB1: water tank missing                   */

/* alarms (r018) */
#define ALM_NO_WATER        0x01    /* FILL TANK (sensors.6)                     */
#define ALM_BIT3            0x08    /* blocks the "filter" decalc rate (?)       */
#define ALM_BIT4            0x10    /* stops the pump outside test mode (?)      */
#define ALM_HEATA_FAULT     0x80    /* heater A (coffee) fault                   */

/* alarms2 (r019) */
#define ALM2_HEATB_FAULT    0x10    /* heater B (steam) fault                    */
#define ALM2_BU_LIMIT       0x40    /* brew unit hit an unexpected limit switch  */

/* sysflags (r01b), set by the input sampling */
#define SYS_FLOW_PULSE      0x01    /* flowmeter edge (RA6)                      */
#define SYS_BU_PULSE        0x10    /* brew unit motor encoder edge (RC1)        */

/* tickflags (r01c) */
#define TICK_100MS          0x08

/* flags1d (r01d) */
#define F1D_CAPPU           0x01    /* coffee after milk (cappuccino)            */
#define F1D_BIT2            0x04    /* heater B: second threshold table          */
#define F1D_PROG_QTY        0x10    /* programming a quantity                    */
#define F1D_MILK_DONE       0x20    /* count one milk drink                      */
#define F1D_WAIT_GRIND      0x40    /* cappu_phase++ when the grinder is done    */
#define F1D_WAIT_BU         0x80    /* cappu_phase++ when the brew unit is done  */

/* r01e */
#define F1E_REMOTE_C8       0x02    /* remote load test command 0xC8 seen        */

/* r01f */
#define F1F_HEATA_EN        0x02    /* heater A allowed (meaning unconfirmed)    */

/* heatflags (r020) */
#define HF_RELOAD_B         0x20    /* heater B setpoint left 0xFF               */
#define HF_RELOAD_A         0x40    /* heater A setpoint left 0xFF               */

/* flags21 (r021) */
#define F21_ONE_CUP         0x02    /* set by the 1 cup key (machine_control) */
#define F21_BIT4            0x10    /* full brewing power (meaning unconfirmed)  */
#define F21_PUMP_INHIBIT    0x40

/* wait_flags (r022): units the state logic waits for, and step requests */
#define WAIT_GRIND          0x01
#define WAIT_BU             0x02
#define WAIT_PUMP           0x04
#define WAIT_HEATA          0x08
#define STEP_FWD            0x20
#define STEP_BACK           0x40
#define WAIT_END_OF_BREW    0x80    /* update the drink counters                 */

/* ioflags (r023) */
#define IO_BU_DIR_UP        0x01    /* brew unit encoder counts up               */
#define IO_WAIT_HEATB       0x08    /* heater B wait flag                        */
#define IO_BU_ABORTED       0x10    /* move cut short (target cleared / tank...) */
#define IO_HEAT_BOTH_A      0x80    /* req_heat_mode 4                           */

/* flags25 (r025) */
#define F25_BREWING         0x80    /* brewing outside state 7 step 0x0B (?)     */

/* flags26 (r026) */
#define F26_HEAT_BOTH_B     0x01    /* req_heat_mode 5                           */

/* gateflags2 (r027) */
#define STEP_BACK2          0x80

/* flags28 (r028) */
#define F28_PROG_MODE       0x04    /* quantity programming (long press)         */
#define F28_HEATA_SLOT      0x08    /* heater A may fire in this window          */
#define F28_HEATB_SLOT      0x10    /* heater B may fire in this window          */
#define F28_TURN_A          0x20    /* alternate modes: heater A's turn          */

/* out_loads (r02a) / out_loads2 (r02b), applied by outputs_task */
#define OUT_BU_DOWN         0x01
#define OUT_BU_UP           0x02
#define OUT_HEATA           0x04
#define OUT_PUMP            0x08
#define OUT_GRINDER         0x10
#define OUT_HEATB           0x20
#define OUT_BU_FULL         0x40
#define OUT_EV1             0x80
#define OUT2_EV2            0x01

/* req_valves (r030) */
#define VALVE_EV1           0x01
#define VALVE_EV2           0x02

/* settings (r0c2) / settings2 (r0db) */
#define SET_FILTER          0x80
#define SET2_BIT0           0x01

/* display keys (keys r011, key_edges r043; keys_hi r012) */
#define KEY_1CUP            0x01
#define KEY_2CUPS           0x02
#define KEY_HOTWATER        0x04    /* also OK  */
#define KEY_MENU            0x08
#define KEY_ONOFF           0x10
#define KEY_CAPPU           0x40
#define KEY_CLEAN           0x80    /* also ESC */
#define KEYHI_PUSH          0x02    /* encoder push button */

/* heater setpoint specials (req_heatA_sp / req_heatB_sp) */
#define SP_OFF              0x00
#define SP_FIXED_40         0xF8    /* heater A: fixed power 0x40 */
#define SP_FIXED_A0         0xFA    /* heater A: fixed power 0xA0 */
#define SP_FIXED_100        0xFD    /* fixed power 0x100          */
#define SP_MAX              0xFF    /* full power 0x140           */

/* brew unit targets (req_bu_target) */
#define BU_TO_TOP           0xFFFF
#define BU_TO_BOTTOM        0xFFFE

#define PUMP_UNLIMITED      0xFFFF

#endif
