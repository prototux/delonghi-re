byte CALLBACK_L(char pcl)
{
  JMPTO_PCL = pcl;
  return CALLBACK()
}

byte CALLBACK(void)
{
  // Check PCH's 8th bit and increment PCL if set
  // Also, return what's designed by PCL
  // PCH's 8th bit == memory access (and not function ptr call)
  if (JMPTO_PCH & 0x80)
  {
	// Set IRP if PCH's first bit is set
	if (JMPTO_PCH & 0x01)
	  STATUS.IRP = 1;

	char *dest = (JMPTO_PCH<<8) + PCL;
	return *dest

    JMPTO_PCL += 1; // why does it do that?
  }
  else // this is function ptr call
  {
    // Just return 8 if PCH's 7th bit is not set
	// So 7th bit == avoid function ptr call?
    if (JMPTO_PCH & 0x40)
	  return 0x8;

	char (*ptr)(void) = (JMPTO_PCH<<8) + JMPTO_PCL;

	JMPTO_PCL += 1;
	if (!JMPTO_PCL) // it overflowed
      JMPTO_PCH += 1;

    return ptr();
  }
}
