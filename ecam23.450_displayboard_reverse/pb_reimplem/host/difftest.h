/* Host differential test: replay recorded calls of the original firmware. */
#ifndef DIFFTEST_H
#define DIFFTEST_H
#include <stdint.h>

struct pb_var { uint16_t addr; uint8_t size; volatile void *ptr; const char *name; };
struct pb_fn  { uint32_t addr; void (*fn)(void); const char *name; };

extern const struct pb_var pb_vars[];
extern const struct pb_fn pb_fns[];
#endif
