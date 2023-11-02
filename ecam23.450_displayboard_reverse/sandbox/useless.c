void init_something_1(char param_1)
{
  INIT_ST1_UNK1 = param_1;
  do {

	// Delay for 0x3*0xa5 -> 0x1EF
    INIT_ST1_UNK2 = 0x4;
    do {

      // Wait until it's time to clear the watchdog
      INIT_ST1_UNK3 = 0xa6;
      do { INIT_ST1_UNK3 -= 0x1; } while (INIT_ST1_UNK3 != 0x0);

	  // Clear the watchdog
      clearWatchDogTimer();

      INIT_ST1_UNK2 -= 0x1;
    } while (INIT_ST1_UNK2 != 0x0);

    INIT_ST1_UNK1 -= 0x1;
  } while (INIT_ST1_UNK1 != 0x0);
}
