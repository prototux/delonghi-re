/*
 * Differential test: replay calls recorded from the original firmware
 * (emulator/test/pb_trace.html) against the C reconstruction.
 *
 * For each record: load every global and the SFR page from the "before"
 * snapshot, call the C function, and compare every global with the RAM the
 * original left behind. Compiler scratch (r000-r00e, argument slots, overlaid
 * locals) is not a global here, so it is not compared.
 *
 *   build/difftest trace.log [function] [-v]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define main pb_main          /* the firmware's main(), built with -Dmain=pb_main */
#include "pb.h"
#undef main
#include "difftest.h"

#define MAXLINE (4096 * 2 + 64 * 1024)

struct stat { const char *name; int runs, fails; };

static int hexval(int c) { return c <= '9' ? c - '0' : (c | 0x20) - 'a' + 10; }

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "usage: %s trace.log [function] [-v]\n", argv[0]); return 2; }
    const char *only = NULL;
    int verbose = 0, maxshow = 3;
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "-v")) { verbose = 1; maxshow = 1000; }
        else only = argv[i];
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) { perror(argv[1]); return 2; }

    static char line[MAXLINE];
    static uint8_t before[4096], after[4096];
    static struct stat stats[128];
    int nstats = 0, unknown = 0;

    while (fgets(line, sizeof line, f)) {
        if (line[0] != 'T' || line[1] != ' ') continue;
        char *p = line + 2;
        uint32_t entry = (uint32_t)strtoul(p, &p, 16);
        const struct pb_fn *fn = pb_fns;
        while (fn->fn && fn->addr != entry) fn++;
        if (!fn->fn) { unknown++; continue; }
        if (only && strcmp(only, fn->name)) continue;

        p++;
        for (int a = 0; a < 4096; a++, p += 2) before[a] = (uint8_t)(hexval(p[0]) << 4 | hexval(p[1]));
        memcpy(after, before, sizeof after);
        p++;
        while (*p && *p != '\n' && *p != '-') {            /* aaa=vv,... (RAM, then output SFRs) */
            unsigned a = (unsigned)strtoul(p, &p, 16);
            p++;
            after[a & 0xfff] = (uint8_t)(hexval(p[0]) << 4 | hexval(p[1]));
            p += 2;
            if (*p == ',') p++;
        }

        for (const struct pb_var *v = pb_vars; v->name; v++) memcpy((void *)v->ptr, before + v->addr, v->size);
        memcpy((void *)pic_sfr, before + 0xf80, 0x80);
        fn->fn();

        struct stat *s = NULL;
        for (int i = 0; i < nstats; i++) if (stats[i].name == fn->name) s = &stats[i];
        if (!s) { s = &stats[nstats++]; s->name = fn->name; }
        s->runs++;

        int bad = 0;
        static const struct { uint16_t a; uint8_t mask; const char *name; } sfr_out[] = {
            { 0xf89, 0xff, "LATA" }, { 0xf8a, 0xff, "LATB" }, { 0xf8b, 0xff, "LATC" }, { 0xf8c, 0xff, "LATD" },
            { 0xf8d, 0x07, "LATE" }, { 0xf92, 0xff, "TRISA" }, { 0xf93, 0xff, "TRISB" }, { 0xf94, 0xff, "TRISC" },
            { 0xf95, 0xff, "TRISD" }, { 0xf96, 0xff, "TRISE" }, { 0xf9d, 0xff, "PIE1" }, { 0xfa0, 0xff, "PIE2" },
            { 0xff2, 0x78, "INTCON" },      /* enables only: GIE and the flags move on their own */
            { 0xfd5, 0xff, "T0CON" }, { 0xfcd, 0xff, "T1CON" }, { 0xfca, 0xff, "T2CON" }, { 0xfcb, 0xff, "PR2" },
            { 0xfbd, 0xff, "CCP1CON" }, { 0xfc2, 0xfd, "ADCON0" }, { 0xfc1, 0xff, "ADCON1" }, { 0xfc0, 0xff, "ADCON2" },
            { 0xfc6, 0x3f, "SSPCON1" }, { 0xfc7, 0xfe, "SSPSTAT" }, { 0xfc9, 0xff, "SSPBUF" }, { 0xfad, 0xff, "TXREG" },
            { 0xfac, 0xfd, "TXSTA" }, { 0xfab, 0xf9, "RCSTA" }, { 0xfaf, 0xff, "SPBRG" }, { 0xfb0, 0xff, "SPBRGH" },
            { 0xfb8, 0x3f, "BAUDCON" }, { 0xfd3, 0xf3, "OSCCON" }, { 0xf9b, 0xff, "OSCTUNE" },
        };
        for (unsigned i = 0; i < sizeof sfr_out / sizeof sfr_out[0]; i++) {
            uint16_t a = sfr_out[i].a;
            uint8_t got = pic_sfr[a - 0xf80];
            /* a write to PORTx is a write to LATx on the chip */
            if (a >= 0xf89 && a <= 0xf8d && pic_sfr[a - 9 - 0xf80] != before[a - 9])
                got = pic_sfr[a - 9 - 0xf80];
            /* the display board clocks bytes into SSPBUF whenever it likes: only
               check it when the function wrote it */
            if (a == 0xfc9 && got == before[a]) continue;
            if (!((got ^ after[a]) & sfr_out[i].mask)) continue;
            /* a PORTx bit write that did not change the value is invisible
               here, but on the chip it copies the pin levels into LATx */
            if (a >= 0xf89 && a <= 0xf8d && pic_sfr[a - 9 - 0xf80] == before[a - 9] &&
                !((before[a - 9] ^ after[a]) & sfr_out[i].mask)) continue;
            if (!bad && s->fails < maxshow)
                printf("%s #%d (mstate %02x step %02x):\n", fn->name, s->runs, before[0x03c], before[0x038]);
            if (s->fails < maxshow)
                printf("   SFR %-20s 0x%03x  before %02x  original %02x  C %02x\n",
                       sfr_out[i].name, a, before[a], after[a], got);
            bad++;
        }
        for (const struct pb_var *v = pb_vars; v->name; v++) {
            const uint8_t *got = (const uint8_t *)v->ptr;
            if (!memcmp(got, after + v->addr, v->size)) continue;
            if (!bad && s->fails < maxshow)
                printf("%s #%d (mstate %02x step %02x):\n", fn->name, s->runs, before[0x03c], before[0x038]);
            if (s->fails < maxshow) {
                printf("   %-24s 0x%03x  before", v->name, v->addr);
                for (int i = 0; i < v->size; i++) printf(" %02x", before[v->addr + i]);
                printf("  original");
                for (int i = 0; i < v->size; i++) printf(" %02x", after[v->addr + i]);
                printf("  C");
                for (int i = 0; i < v->size; i++) printf(" %02x", got[i]);
                printf("\n");
            }
            bad++;
        }
        if (bad) s->fails++;
    }
    fclose(f);

    int total = 0, fails = 0;
    printf("\n%-22s %6s %6s\n", "function", "calls", "differ");
    for (int i = 0; i < nstats; i++) {
        printf("%-22s %6d %6d%s\n", stats[i].name, stats[i].runs, stats[i].fails, stats[i].fails ? "  <--" : "");
        total += stats[i].runs; fails += stats[i].fails;
    }
    printf("%d calls replayed, %d differ", total, fails);
    if (unknown) printf(" (%d records for functions without a C entry point)", unknown);
    printf("\n");
    (void)verbose;
    return fails ? 1 : 0;
}
