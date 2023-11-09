// Const data for memory bank init (at 0x0bf)
const char bank0_init_data[3] = {0x08, 0x02, 0x32};

// NB: for the LCD strings, those are 21 chars long
// the LCD is 20 chars wide + ending zero byte
// For the LCD data, they all have a "ADDWF PC,f" before
// aka 0x0782, this jumps to PC+WREG directly

// LCD data (string and init data (?) @ 0x07e7 and 0x07fd
// "ENERGY SAVING" string, probably for power management/going to sleep
const char LCD_DATA_0[21] = "ENERGY SAVING      \0";

// Probably some init data @ 0x0800-0x082c
const char LCD_DATA_1[44] = {0x43, 0x18, 0x2d, 0x19, 0x43, 0x19, 0x17, 0x19, 0x85, 0x19, 0x59,
							 0x19, 0x2d, 0x18, 0x01, 0x19, 0xdd, 0x18, 0xb1, 0x18, 0x9b, 0x18,
							 0x85, 0x18, 0xc7, 0x18, 0x59, 0x18, 0x6f, 0x18, 0x17, 0x18, 0x6f,
							 0x19, 0x01, 0x18, 0xe8, 0x07, 0x9b, 0x19, 0xda, 0x19, 0xb0, 0x19};

// LCD Strings @ 0x1800 to 0x19c3, those are 20+zero chars long
// Some seems to be error/"bootloader" messages,
// others are some known test menu items
const char LCD_STR_1[21] = "PRESS ESC + OK       \0";
const char LCD_STR_1[21] = "UART MODE            \0";
const char LCD_STR_1[21] = "MOTOR UP             \0";
const char LCD_STR_1[21] = "                     \0"; // yes, that's just all spaces
const char LCD_STR_1[21] = "EV1 ON               \0";
const char LCD_STR_1[21] = "EV2 ON               \0";
const char LCD_STR_1[21] = "GRINDER ON           \0";
const char LCD_STR_1[21] = "HEATER ON            \0";
const char LCD_STR_1[21] = "ELECTRIC TEST MODE   \0";
const char LCD_STR_1[21] = "PUMP ON              \0";
const char LCD_STR_1[21] = "VAPORIZER ON         \0";
const char LCD_DATA_2[8] = {0x0e, 0x00, 0x11, 0x11, 0x11, 0x13, 0x0d, 0x00}; // I don't know what it is
const char LCD_STR_1[21] = "MOTOR DOWN           \0";
const char LCD_STR_1[21] = "LOAD TEST MODE       \0";
const char LCD_STR_1[21] = "DISPLAY TEST MODE    \0";
const char LCD_STR_1[21] = "BUTTON               \0";
const char LCD_STR_1[21] = "LIMIT SWITCH DOWN    \0";
const char LCD_STR_1[21] = "                     \0"; // yes, that's just all spaces
const char LCD_STR_1[21] = "LIMIT SWITCH UP      \0";
const char LCD_DATA_3[20] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,  // Full line of
							 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}; // blocks
const char LCD_DATA_4[20] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // Empty line
							 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}; // i guess

// Some more LCD data (i guess) @ 0x19d9 to 0x19ed
const char LCD_DATA_5[20] = {0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17,  // Full line of
							 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17}; // something...

// More LCD data i guess again @ 0x1a35 to 0x1a4f
const char LCD_DATA_6[8] = {0x1f, 0x1f, 0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00};
const char LCD_DATA_7[8] = {0x04, 0x04, 0x04, 0x06, 0x0c, 0x04, 0x04, 0x00};
const char LCD_DATA_8[8] = {0x08, 0x1c, 0x08, 0x09, 0x06, 0x08, 0x04, 0x00};





