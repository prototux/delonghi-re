/*
 * Minimal stand-in for XC8's <xc.h> so the firmware can be syntax/type
 * checked with a host compiler (make check). Not a simulator.
 */
#ifndef HOST_XC_H
#define HOST_XC_H
#include <stdint.h>

#define __interrupt(...)
#define asm(x) ((void)0)
#define NOP() ((void)0)

#define SFR(name) extern volatile uint8_t name
SFR(PORTA); SFR(PORTB); SFR(PORTC); SFR(TRISA); SFR(TRISB); SFR(TRISC);
SFR(INTCON); SFR(PIR1); SFR(PIR2); SFR(PIE1); SFR(PIE2); SFR(OPTION_REG);
SFR(TMR0); SFR(TMR1L); SFR(TMR1H); SFR(T1CON); SFR(TMR2); SFR(T2CON); SFR(PR2);
SFR(CCP1CON); SFR(CCPR1L); SFR(SSPBUF); SFR(SSPCON); SFR(SSPSTAT);
SFR(RCSTA); SFR(TXSTA); SFR(SPBRG); SFR(TXREG); SFR(RCREG);
SFR(OSCCON); SFR(PCON); SFR(WPUB); SFR(IOCB); SFR(ANSEL); SFR(ADCON0); SFR(ADCON1);
SFR(LCDCON); SFR(LCDSE0); SFR(LCDSE1); SFR(LCDSE2); SFR(LVDCON); SFR(EECON1);
SFR(CMCON0); SFR(VRCON);

#define BITS8(n0,n1,n2,n3,n4,n5,n6,n7) struct { unsigned n0:1, n1:1, n2:1, n3:1, n4:1, n5:1, n6:1, n7:1; }
extern volatile BITS8(RA0,RA1,RA2,RA3,RA4,RA5,RA6,RA7) PORTAbits;
extern volatile BITS8(RB0,RB1,RB2,RB3,RB4,RB5,RB6,RB7) PORTBbits;
extern volatile BITS8(RC0,RC1,RC2,RC3,RC4,RC5,RC6,RC7) PORTCbits;
extern volatile BITS8(TRISB0,TRISB1,TRISB2,TRISB3,TRISB4,TRISB5,TRISB6,TRISB7) TRISBbits;
extern volatile BITS8(RBIF,INTF,T0IF,RBIE,INTE,T0IE,PEIE,GIE) INTCONbits;
extern volatile BITS8(TMR1IF,TMR2IF,CCP1IF,SSPIF,TXIF,RCIF,ADIF,EEIF) PIR1bits;
extern volatile BITS8(TMR1IE,TMR2IE,CCP1IE,SSPIE,TXIE,RCIE,ADIE,EEIE) PIE1bits;
extern volatile BITS8(RX9D,OERR,FERR,ADDEN,CREN,SREN,RX9,SPEN) RCSTAbits;
extern volatile BITS8(T2CKPS0,T2CKPS1,TMR2ON,TOUTPS0,TOUTPS1,TOUTPS2,TOUTPS3,b7) T2CONbits;
#endif
