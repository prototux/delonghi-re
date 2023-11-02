                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void _reset(void)
          ;tmp_T1CON     undefined1     HASH...
                                                          ;XREF[1,0]:   Entry Point
CODE:CODE:0000  0030            MOVLW       #0x0
CODE:CODE:0001  8a00            MOVWF       PCLATH
CODE:CODE:0002  7028            GOTO        main
CODE:CODE:0003  ff3f            db[2]
   |_CODE:CODE:0003  [0]             db          FFh
   |_CODE:CODE:0003.1[1]             db          3Fh
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined _interrupt(undefined1 wreg)
          ;wreg          undefined1           W
          ;cond          undefined1     Skip...                      ;XREF[1,0]:   CODE:002a
          ;tmp_PIR1      undefined1     HASH...
          ;tmp_INTCON    byte           HASH...
          ;tmp_PIR       undefined1     HASH...
          ;ret_INTCON    byte           HASH...
                                                          ;XREF[1,0]:   Entry Point
CODE:CODE:0004  f800            MOVWF       BANK-0:ISR_BKP_WREG                     ;= ??
CODE:CODE:0005  0308            MOVF        STATUS,w
CODE:CODE:0006  8301            CLRF        STATUS
CODE:CODE:0007  e900            MOVWF       BANK-0:ISR_BKP_STATUS                   ;= ??
CODE:CODE:0008  0408            MOVF        FSR0L,w
CODE:CODE:0009  ea00            MOVWF       BANK-0:ISR_BKP_FSR                      ;= ??
CODE:CODE:000a  0a08            MOVF        PCLATH,w
CODE:CODE:000b  eb00            MOVWF       BANK-0:ISR_BKP_PCLATH                   ;= ??
CODE:CODE:000c  8a01            CLRF        PCLATH
CODE:CODE:000d  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:000e  f400            MOVWF       BANK-0:ISR_BKP_ENTRY_SUB2_UNK1          ;= ??
CODE:CODE:000f  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:0010  f100            MOVWF       BANK-0:ISR_BKP_7a                       ;= ??
CODE:CODE:0011  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0012  f200            MOVWF       BANK-0:ISR_BKP_7b                       ;= ??
CODE:CODE:0013  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0014  f000            MOVWF       BANK-0:ISR_BKP_70                       ;= ??
CODE:CODE:0015  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:0016  f500            MOVWF       BANK-0:ISR_BKP_7d                       ;= ??
CODE:CODE:0017  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:0018  f600            MOVWF       BANK-0:ISR_BKP_7e                       ;= ??
CODE:CODE:0019  7f08            MOVF        BANK-0:DAT_DATA_007f,w                  ;= ??
CODE:CODE:001a  f300            MOVWF       BANK-0:ISR_BKP_7f                       ;= ??
CODE:CODE:001b  6e08            MOVF        BANK-0:FETCH_ADDR_L,w                   ;= ??
CODE:CODE:001c  ec00            MOVWF       BANK-0:ISR_BKP_JUMPTO_PCL               ;= ??
CODE:CODE:001d  6f08            MOVF        BANK-0:FETCH_ADDR_H,w                   ;= ??
CODE:CODE:001e  ed00            MOVWF       BANK-0:ISR_BKP_JUMPTO_PCH               ;= ??
CODE:CODE:001f  8301            CLRF        STATUS
CODE:CODE:0020  8c1d            BTFSS       BANK-0:PIR1,#0x3                        ;= ??
CODE:CODE:0021  2a28            GOTO        LAB_CODE_002a
CODE:CODE:0022  8316            BSF         STATUS,RP0
CODE:CODE:0023  8c1d            BTFSS       BANK-0:PIR1,#0x3                        ;= ??
                            ;Checks synchronous serial interrupt and calls it's function
CODE:CODE:0024  2a28            GOTO        LAB_CODE_002a
CODE:CODE:0025  0a16            BSF         PCLATH,#0x4
CODE:CODE:0026  8a15            BSF         PCLATH,#0x3
CODE:CODE:0027  5b26            CALL        offset interrupt_handler_ssp-0x1800     ;void interrupt_handler_ssp(void)
CODE:CODE:0028  0a12            BCF         PCLATH,#0x4
CODE:CODE:0029  8a11            BCF         PCLATH,#0x3
                            ;Checks if it's NOT the timer0 overflow
                            LAB_CODE_002a:                ;XREF[2,0]:   CODE:0021,CODE:0024
CODE:CODE:002a  0b19            BTFSC       INTCON,#0x2
                            ;If it is timer0 that interrupted, check if the timer0 is enabled
CODE:CODE:002b  8b1e            BTFSS       INTCON,#0x5
CODE:CODE:002c  3228            GOTO        LAB_CODE_0032
CODE:CODE:002d  0a16            BSF         PCLATH,#0x4
CODE:CODE:002e  8a15            BSF         PCLATH,#0x3
                            ;Apparently, timer0 interrupt management code?
CODE:CODE:002f  9727            CALL        offset interrupt_handler_timer0-0x1800  ;char interrupt_handler_timer0(void)
CODE:CODE:0030  0a12            BCF         PCLATH,#0x4
CODE:CODE:0031  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_0032:                ;XREF[1,0]:   CODE:002c
CODE:CODE:0032  8312            BCF         STATUS,RP0
CODE:CODE:0033  0c1c            BTFSS       BANK-0:PIR1,#0x0                        ;= ??
CODE:CODE:0034  3d28            GOTO        LAB_CODE_003d
CODE:CODE:0035  8316            BSF         STATUS,RP0
CODE:CODE:0036  0c1c            BTFSS       BANK-0:PIR1,#0x0                        ;= ??
                            ;Checks for timer1 overflow and calls it's dedicated function
CODE:CODE:0037  3d28            GOTO        LAB_CODE_003d
CODE:CODE:0038  0a16            BSF         PCLATH,#0x4
CODE:CODE:0039  8a15            BSF         PCLATH,#0x3
CODE:CODE:003a  bf26            CALL        offset interrupt_handler_timer1-0x1800  ;void interrupt_handler_timer1(void)
CODE:CODE:003b  0a12            BCF         PCLATH,#0x4
CODE:CODE:003c  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_003d:                ;XREF[2,0]:   CODE:0034,CODE:0037
CODE:CODE:003d  8312            BCF         STATUS,RP0
CODE:CODE:003e  8c1e            BTFSS       BANK-0:PIR1,#0x5                        ;= ??
CODE:CODE:003f  4828            GOTO        LAB_CODE_0048
CODE:CODE:0040  8316            BSF         STATUS,RP0
CODE:CODE:0041  8c1e            BTFSS       BANK-0:PIR1,#0x5                        ;= ??
                            ;Checks for USART receive interrupt and calls it's function
CODE:CODE:0042  4828            GOTO        LAB_CODE_0048
CODE:CODE:0043  0a16            BSF         PCLATH,#0x4
CODE:CODE:0044  8a15            BSF         PCLATH,#0x3
CODE:CODE:0045  fe26            CALL        offset interrupt_handler_usart_rx-0x1800;void interrupt_handler_usart_rx(void)
CODE:CODE:0046  0a12            BCF         PCLATH,#0x4
CODE:CODE:0047  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_0048:                ;XREF[2,0]:   CODE:003f,CODE:0042
CODE:CODE:0048  8312            BCF         STATUS,RP0
CODE:CODE:0049  0c1e            BTFSS       BANK-0:PIR1,#0x4                        ;= ??
CODE:CODE:004a  5328            GOTO        LAB_CODE_0053
CODE:CODE:004b  8316            BSF         STATUS,RP0
CODE:CODE:004c  0c1e            BTFSS       BANK-0:PIR1,#0x4                        ;= ??
                            ;Checks for USART transmit interrupt and calls it's function
CODE:CODE:004d  5328            GOTO        LAB_CODE_0053
CODE:CODE:004e  0a16            BSF         PCLATH,#0x4
CODE:CODE:004f  8a15            BSF         PCLATH,#0x3
CODE:CODE:0050  c421            CALL        offset interrupt_handler_usart_tx-0x1800;undefined interrupt_handler_usart_tx()
CODE:CODE:0051  0a12            BCF         PCLATH,#0x4
CODE:CODE:0052  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_0053:                ;XREF[2,0]:   CODE:004a,CODE:004d
CODE:CODE:0053  0313            BCF         STATUS,RP1
CODE:CODE:0054  8312            BCF         STATUS,RP0
CODE:CODE:0055  7408            MOVF        BANK-0:ISR_BKP_ENTRY_SUB2_UNK1,w        ;= ??
CODE:CODE:0056  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:0057  7108            MOVF        BANK-0:ISR_BKP_7a,w                     ;= ??
CODE:CODE:0058  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:0059  7208            MOVF        BANK-0:ISR_BKP_7b,w                     ;= ??
CODE:CODE:005a  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:005b  7008            MOVF        BANK-0:ISR_BKP_70,w                     ;= ??
CODE:CODE:005c  fc00            MOVWF       BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:005d  7508            MOVF        BANK-0:ISR_BKP_7d,w                     ;= ??
CODE:CODE:005e  fd00            MOVWF       BANK-0:DAT_DATA_007d                    ;= ??
CODE:CODE:005f  7608            MOVF        BANK-0:ISR_BKP_7e,w                     ;= ??
CODE:CODE:0060  fe00            MOVWF       BANK-0:DAT_DATA_007e                    ;= ??
CODE:CODE:0061  7308            MOVF        BANK-0:ISR_BKP_7f,w                     ;= ??
CODE:CODE:0062  ff00            MOVWF       BANK-0:DAT_DATA_007f                    ;= ??
CODE:CODE:0063  6c08            MOVF        BANK-0:ISR_BKP_JUMPTO_PCL,w             ;= ??
CODE:CODE:0064  ee00            MOVWF       BANK-0:FETCH_ADDR_L                     ;= ??
CODE:CODE:0065  6d08            MOVF        BANK-0:ISR_BKP_JUMPTO_PCH,w             ;= ??
CODE:CODE:0066  ef00            MOVWF       BANK-0:FETCH_ADDR_H                     ;= ??
CODE:CODE:0067  6a08            MOVF        BANK-0:ISR_BKP_FSR,w                    ;= ??
CODE:CODE:0068  8400            MOVWF       FSR0L
CODE:CODE:0069  6b08            MOVF        BANK-0:ISR_BKP_PCLATH,w                 ;= ??
CODE:CODE:006a  8a00            MOVWF       PCLATH
CODE:CODE:006b  6908            MOVF        BANK-0:ISR_BKP_STATUS,w                 ;= ??
CODE:CODE:006c  8300            MOVWF       STATUS
CODE:CODE:006d  f80e            SWAPF       BANK-0:ISR_BKP_WREG,f                   ;= ??
CODE:CODE:006e  780e            SWAPF       BANK-0:ISR_BKP_WREG,w                   ;= ??
                            ;Enable interrupts
CODE:CODE:006f  0900            RETFIE
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void main(void)
          ;tmp_T1CON     undefined1     HASH...
                            ;This part clear almost all of the banks:
                            ;bank 0: 0x20 -> 0x65 (of 0x20 -> 0x7F)
                            ;bank 1: 0xA0 -> 0xE6 (of 0xA0 -> 0xEF)
                            ;bank 2: 0x20 -> 0x6d (of 0x20 -> 0x6F)
                            ;bank 3: 0x90 -> 0xEE (of 0x90 -> 0xEF, full)
                                                          ;XREF[1,0]:   CODE:0002
CODE:CODE:0070  2030            MOVLW       #0x20
CODE:CODE:0071  8400            MOVWF       FSR0L
CODE:CODE:0072  6630            MOVLW       #0x66
                            ;Clear 0x20-0x65 @ bank-0 and init 0x66-0x68 with the const in 0x00bf
CODE:CODE:0073  9720            CALL        memclear                                ;void memclear(ubyte start, ubyte end)
CODE:CODE:0074  0030            MOVLW       #0x0
CODE:CODE:0075  ef00            MOVWF       BANK-0:FETCH_ADDR_H                     ;= ??
CODE:CODE:0076  bf30            MOVLW       #0xbf
CODE:CODE:0077  ee00            MOVWF       BANK-0:FETCH_ADDR_L                     ;= ??
CODE:CODE:0078  6630            MOVLW       #0x66
CODE:CODE:0079  8400            MOVWF       FSR0L
CODE:CODE:007a  6930            MOVLW       #0x69
CODE:CODE:007b  9c20            CALL        init_ram_with_data                      ;undefined init_ram_with_data(byte me...
CODE:CODE:007c  a030            MOVLW       #0xa0
CODE:CODE:007d  8400            MOVWF       FSR0L
CODE:CODE:007e  e730            MOVLW       #0xe7
                            ;Clear 0xa0-0xe6 @ bank-1 and init 0xe7 with the const in 0x00c2
CODE:CODE:007f  9720            CALL        memclear                                ;void memclear(ubyte start, ubyte end)
CODE:CODE:0080  0030            MOVLW       #0x0
CODE:CODE:0081  ef00            MOVWF       0x6f
CODE:CODE:0082  c230            MOVLW       #0xc2
CODE:CODE:0083  ee00            MOVWF       0x6e
CODE:CODE:0084  e730            MOVLW       #0xe7
CODE:CODE:0085  8400            MOVWF       FSR0L
CODE:CODE:0086  e830            MOVLW       #0xe8
CODE:CODE:0087  9c20            CALL        init_ram_with_data                      ;undefined init_ram_with_data(byte me...
CODE:CODE:0088  8317            BSF         STATUS,IRP
CODE:CODE:0089  2030            MOVLW       #0x20
CODE:CODE:008a  8400            MOVWF       FSR0L
CODE:CODE:008b  6e30            MOVLW       #0x6e
                            ;Clear 0x20-0x6d @ bank-2 and 0x90-0xee @ bank-3
CODE:CODE:008c  9720            CALL        memclear                                ;void memclear(ubyte start, ubyte end)
CODE:CODE:008d  9030            MOVLW       #0x90
CODE:CODE:008e  8400            MOVWF       FSR0L
CODE:CODE:008f  ef30            MOVLW       #0xef
CODE:CODE:0090  9720            CALL        memclear                                ;void memclear(ubyte start, ubyte end)
                            ;---end of this part---
                            ;Now we jump to (0b10000, 0x04), eg 0x1004
CODE:CODE:0091  0a16            BSF         PCLATH,#0x4
CODE:CODE:0092  8a11            BCF         PCLATH,#0x3
CODE:CODE:0093  0428            GOTO        offset ENTRY_SUB_AND_MAINLOOP &0xff
                            ;************************************************************************************************
                            ;*  Part of ENTRY_SUB1                                                                          *
                            ;*                                                                                              *
                            ;************************************************************************************************
                            ENTRY_SUB1_SUB1:              ;XREF[1,0]:   CODE:0099
CODE:CODE:0094  0406            XORWF       FSR0L,w
CODE:CODE:0095  8001            CLRF        INDF0
CODE:CODE:0096  840a            INCF        FSR0L,f
                            ;************************************************************************************************
                            ;*  Apparently, this resets some part of RAM to 0                                               *
                            ;*                                                                                              *
                            ;************************************************************************************************
                            ;void memclear(ubyte start, ubyte end)
          ;start         ubyte            FSR0L
          ;end           ubyte                W
                                                          ;XREF[4,0]:   CODE:0073,CODE:007f,CODE:008c,CODE:0090
CODE:CODE:0097  0406            XORWF       start,w
CODE:CODE:0098  031d            BTFSS       STATUS,#0x2
CODE:CODE:0099  9428            GOTO        ENTRY_SUB1_SUB1
CODE:CODE:009a  6400            CLRWDT
CODE:CODE:009b  0034            RETLW       #0x0
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined init_ram_with_data(byte mem_start, byte mem_end)
          ;mem_start     byte             FSR0L
          ;mem_end       byte                 W                      ;XREF[1,0]:   CODE:009f
          ;SUB_SUB_RET   undefined1           W                      ;XREF[1,0]:   CODE:009f
                            ;mem_start est dans FSR deja, parametre cache
                            ;les 2 parametres de callback sont deja dans les 2 globales
                                                          ;XREF[2,0]:   CODE:007b,CODE:0087
CODE:CODE:009c  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
                            LAB_CODE_009d:                ;XREF[1,0]:   CODE:00a8
CODE:CODE:009d  0a12            BCF         PCLATH,#0x4
CODE:CODE:009e  8a11            BCF         PCLATH,#0x3
CODE:CODE:009f  ac20            CALL        fetch_data
CODE:CODE:00a0  0a12            BCF         PCLATH,#0x4
CODE:CODE:00a1  8a11            BCF         PCLATH,#0x3
CODE:CODE:00a2  8000            MOVWF       INDF0
CODE:CODE:00a3  840a            INCF        mem_start,f
CODE:CODE:00a4  0408            MOVF        mem_start,w
CODE:CODE:00a5  7906            XORWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:00a6  0319            BTFSC       STATUS,#0x2
CODE:CODE:00a7  0034            RETLW       #0x0
CODE:CODE:00a8  9d28            GOTO        LAB_CODE_009d
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void fetch_data_withparam(byte addr_low)
          ;addr_low      byte                 W
                                                          ;XREF[6,0]:   CODE:0151,CODE:0171,CODE:0191,CODE:01b1
                                                          ;             CODE:14a7,CODE:14bc
CODE:CODE:00a9  8312            BCF         STATUS,RP0
CODE:CODE:00aa  0313            BCF         STATUS,RP1
CODE:CODE:00ab  ee00            MOVWF       BANK-0:FETCH_ADDR_L                     ;= ??
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;byte fetch_data(void)
          ;ret           undefined1           W                      ;XREF[1,0]:   CODE:00b6
          ;pcl           byte           HASH...
          ;pch           byte           HASH...
          ;lbits_cpy     undefined2     HASH...
                            ;Check if PCH's last bit is set
                            ;if set, just increment PCL
                                                          ;XREF[2,0]:   CODE:009f,CODE:14ab
CODE:CODE:00ac  ef1b            BTFSC       BANK-0:FETCH_ADDR_H,#0x7                ;= ??
CODE:CODE:00ad  b728            GOTO        LAB_CODE_00b7
                            ;Check if PCH's 6th byte (from 1) is not set
                            ;if not set, call the callback
CODE:CODE:00ae  6f1b            BTFSC       BANK-0:FETCH_ADDR_H,#0x6                ;= ??
CODE:CODE:00af  bf28            GOTO        CONST_1
CODE:CODE:00b0  6f08            MOVF        BANK-0:FETCH_ADDR_H,w                   ;= ??
CODE:CODE:00b1  8a00            MOVWF       PCLATH
CODE:CODE:00b2  6e08            MOVF        BANK-0:FETCH_ADDR_L,w                   ;= ??
                            ;increment PCH if PCL = 0xff
                            ;(and will overflow when incremented)
                            ;
CODE:CODE:00b3  ee0a            INCF        BANK-0:FETCH_ADDR_L,f                   ;= ??
CODE:CODE:00b4  0319            BTFSC       STATUS,#0x2
CODE:CODE:00b5  ef0a            INCF        BANK-0:FETCH_ADDR_H,f                   ;= ??
CODE:CODE:00b6  8200            MOVWF       PC
                            LAB_CODE_00b7:                ;XREF[1,0]:   CODE:00ad
CODE:CODE:00b7  8313            BCF         STATUS,IRP
CODE:CODE:00b8  6f18            BTFSC       BANK-0:FETCH_ADDR_H,#0x0                ;= ??
CODE:CODE:00b9  8317            BSF         STATUS,IRP
CODE:CODE:00ba  6e08            MOVF        BANK-0:FETCH_ADDR_L,w                   ;= ??
CODE:CODE:00bb  ee0a            INCF        BANK-0:FETCH_ADDR_L,f                   ;= ??
CODE:CODE:00bc  8400            MOVWF       FSR0L
CODE:CODE:00bd  0008            MOVF        INDF0,w
CODE:CODE:00be  0800            RETURN
                            ;-- called by first call to callback
                            CONST_1:                      ;XREF[1,0]:   CODE:00af
CODE:CODE:00bf  0834            RETLW       #0x8
CODE:CODE:00c0  0234            RETLW       #0x2
CODE:CODE:00c1  3234            RETLW       #0x32
CODE:CODE:00c2  0f34            RETLW       #0xf
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Elise()
                                                          ;XREF[9,0]:   CODE:1187,CODE:1192,CODE:11a4,CODE:11af
                                                          ;             CODE:11c0,CODE:11cb,CODE:11dc,CODE:11e7
                                                          ;             CODE:11f8
CODE:CODE:00c3  ff01            CLRF        BANK-0:DAT_DATA_007f                    ;= ??
CODE:CODE:00c4  fd01            CLRF        BANK-0:DAT_DATA_007d                    ;= ??
CODE:CODE:00c5  fe01            CLRF        BANK-0:DAT_DATA_007e                    ;= ??
CODE:CODE:00c6  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:00c7  7c04            IORWF       BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:00c8  031d            BTFSS       STATUS,#0x2
CODE:CODE:00c9  cd28            GOTO        LAB_CODE_00cd
CODE:CODE:00ca  f901            CLRF        BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:00cb  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:00cc  0034            RETLW       #0x0
                            LAB_CODE_00cd:                ;XREF[1,0]:   CODE:00c9
CODE:CODE:00cd  1f30            MOVLW       #0x1f
CODE:CODE:00ce  ff04            IORWF       BANK-0:DAT_DATA_007f,f                  ;= ??
CODE:CODE:00cf  0310            BCF         STATUS,C
CODE:CODE:00d0  ff0a            INCF        BANK-0:DAT_DATA_007f,f                  ;= ??
CODE:CODE:00d1  fb0d            RLF         BANK-0:DAT_DATA_007b,f                  ;= ??
CODE:CODE:00d2  fc0d            RLF         BANK-0:DAT_DATA_007c,f                  ;= ??
CODE:CODE:00d3  031c            BTFSS       STATUS,#0x0
CODE:CODE:00d4  d028            GOTO        0xd0
CODE:CODE:00d5  fc0c            RRF         BANK-0:DAT_DATA_007c,f                  ;= ??
CODE:CODE:00d6  fb0c            RRF         BANK-0:DAT_DATA_007b,f                  ;= ??
CODE:CODE:00d7  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:00d8  7a02            SUBWF       BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:00d9  031d            BTFSS       STATUS,#0x2
CODE:CODE:00da  dd28            GOTO        0xdd
CODE:CODE:00db  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:00dc  7902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:00dd  031c            BTFSS       STATUS,#0x0
CODE:CODE:00de  e528            GOTO        0xe5
CODE:CODE:00df  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:00e0  f902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:00e1  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:00e2  031c            BTFSS       STATUS,#0x0
CODE:CODE:00e3  7c0a            INCF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:00e4  fa02            SUBWF       BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:00e5  fd0d            RLF         BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:00e6  fe0d            RLF         BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:00e7  ff0b            DECFSZ      BANK-0:DAT_DATA_007f,f                  ;= ??
CODE:CODE:00e8  ff1a            BTFSC       BANK-0:DAT_DATA_007f,#0x5               ;= ??
CODE:CODE:00e9  d528            GOTO        0xd5
CODE:CODE:00ea  ff1f            BTFSS       BANK-0:DAT_DATA_007f,#0x7               ;= ??
CODE:CODE:00eb  f128            GOTO        0xf1
CODE:CODE:00ec  fd09            COMF        BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:00ed  fd0a            INCF        BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:00ee  0319            BTFSC       STATUS,#0x2
CODE:CODE:00ef  fe03            DECF        BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:00f0  fe09            COMF        BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:00f1  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:00f2  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:00f3  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:00f4  fc00            MOVWF       BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:00f5  7f1f            BTFSS       BANK-0:DAT_DATA_007f,#0x6               ;= ??
CODE:CODE:00f6  0034            RETLW       #0x0
CODE:CODE:00f7  f909            COMF        BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:00f8  f90a            INCF        BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:00f9  0319            BTFSC       STATUS,#0x2
CODE:CODE:00fa  fa03            DECF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:00fb  fa09            COMF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:00fc  0034            RETLW       #0x0
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Adele()
                                                          ;XREF[24,0]:  CODE:013c,CODE:0144,CODE:0156,CODE:0164
                                                          ;             CODE:0176,CODE:0184,CODE:0196,CODE:01a4
                                                          ;             CODE:01b6,CODE:01c1,CODE:01c7,CODE:01cd
                                                          ;             CODE:01d3,CODE:01d9,CODE:01e2,CODE:01e8
                                                          ;             CODE:01ee,CODE:01f4,CODE:0843,CODE:0868
                                                          ;             CODE:08a6,CODE:08cf,CODE:0921,CODE:094a
CODE:CODE:00fd  8301            CLRF        STATUS
CODE:CODE:00fe  d600            MOVWF       BANK-0:DAT_DATA_0056                    ;= ??
CODE:CODE:00ff  0a16            BSF         PCLATH,#0x4
CODE:CODE:0100  8a11            BCF         PCLATH,#0x3
CODE:CODE:0101  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:0102  d700            MOVWF       BANK-0:DAT_DATA_0057                    ;= ??
CODE:CODE:0103  7830            MOVLW       #0x78
CODE:CODE:0104  0a16            BSF         PCLATH,#0x4
CODE:CODE:0105  8a11            BCF         PCLATH,#0x3
CODE:CODE:0106  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:0107  0a12            BCF         PCLATH,#0x4
CODE:CODE:0108  8a11            BCF         PCLATH,#0x3
CODE:CODE:0109  d700            MOVWF       BANK-0:DAT_DATA_0057                    ;= ??
CODE:CODE:010a  560b            DECFSZ      BANK-0:DAT_DATA_0056,w                  ;= ??
CODE:CODE:010b  1329            GOTO        LAB_CODE_0113
CODE:CODE:010c  8030            MOVLW       #0x80
CODE:CODE:010d  0a16            BSF         PCLATH,#0x4
CODE:CODE:010e  8a11            BCF         PCLATH,#0x3
CODE:CODE:010f  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:0110  0a12            BCF         PCLATH,#0x4
CODE:CODE:0111  8a11            BCF         PCLATH,#0x3
CODE:CODE:0112  d700            MOVWF       BANK-0:DAT_DATA_0057                    ;= ??
                            LAB_CODE_0113:                ;XREF[1,0]:   CODE:010b
CODE:CODE:0113  d608            MOVF        0x56,f
CODE:CODE:0114  031d            BTFSS       STATUS,#0x2
CODE:CODE:0115  1c29            GOTO        LAB_CODE_011c
CODE:CODE:0116  d701            CLRF        BANK-0:DAT_DATA_0057                    ;= ??
CODE:CODE:0117  4030            MOVLW       #0x40
CODE:CODE:0118  0a16            BSF         PCLATH,#0x4
CODE:CODE:0119  8a11            BCF         PCLATH,#0x3
CODE:CODE:011a  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:011b  d700            MOVWF       BANK-0:DAT_DATA_0057                    ;= ??
                            LAB_CODE_011c:                ;XREF[1,0]:   CODE:0115
CODE:CODE:011c  5508            MOVF        BANK-0:DAT_DATA_0055,w                  ;= ??
CODE:CODE:011d  0a16            BSF         PCLATH,#0x4
CODE:CODE:011e  8a11            BCF         PCLATH,#0x3
CODE:CODE:011f  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:0120  0a16            BSF         PCLATH,#0x4
CODE:CODE:0121  8a11            BCF         PCLATH,#0x3
                            ;This is a goto
CODE:CODE:0122  d22e            GOTO        offset Agathe-0x1000                    ;undefined Agathe()
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Emy()
                                                          ;XREF[2,0]:   CODE:0fa9,CODE:1022
CODE:CODE:0123  8301            CLRF        STATUS
CODE:CODE:0124  cd00            MOVWF       BANK-0:DAT_DATA_004d                    ;= ??
CODE:CODE:0125  cd08            MOVF        BANK-0:DAT_DATA_004d,f                  ;= ??
CODE:CODE:0126  031d            BTFSS       STATUS,#0x2
CODE:CODE:0127  3929            GOTO        LAB_CODE_0139
CODE:CODE:0128  0615            BSF         FSR1L,#0x2
CODE:CODE:0129  6430            MOVLW       #0x64
CODE:CODE:012a  cf00            MOVWF       0x4f
                            LAB_CODE_012b:                ;XREF[1,0]:   CODE:012c
CODE:CODE:012b  cf0b            DECFSZ      0x4f,f
CODE:CODE:012c  2b29            GOTO        LAB_CODE_012b
CODE:CODE:012d  0611            BCF         FSR1L,#0x2
CODE:CODE:012e  0130            MOVLW       #0x1
CODE:CODE:012f  0a16            BSF         PCLATH,#0x4
CODE:CODE:0130  8a15            BSF         PCLATH,#0x3
CODE:CODE:0131  7126            CALL        offset delay_2ms-0x1800                 ;undefined delay_2ms()
CODE:CODE:0132  0615            BSF         FSR1L,#0x2
CODE:CODE:0133  2830            MOVLW       #0x28
CODE:CODE:0134  0a16            BSF         PCLATH,#0x4
CODE:CODE:0135  8a15            BSF         PCLATH,#0x3
CODE:CODE:0136  7126            CALL        offset delay_2ms-0x1800                 ;undefined delay_2ms()
CODE:CODE:0137  0a12            BCF         PCLATH,#0x4
CODE:CODE:0138  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_0139:                ;XREF[1,0]:   CODE:0127
CODE:CODE:0139  3830            MOVLW       #0x38
CODE:CODE:013a  d500            MOVWF       0x55
CODE:CODE:013b  0130            MOVLW       #0x1
CODE:CODE:013c  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:013d  0a12            BCF         PCLATH,#0x4
CODE:CODE:013e  8a11            BCF         PCLATH,#0x3
CODE:CODE:013f  ce01            CLRF        0x4e
                            LAB_CODE_0140:                ;XREF[1,0]:   CODE:015d
CODE:CODE:0140  4e08            MOVF        0x4e,w
CODE:CODE:0141  4038            IORLW       #0x40
CODE:CODE:0142  d500            MOVWF       0x55
CODE:CODE:0143  0130            MOVLW       #0x1
CODE:CODE:0144  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0145  4e08            MOVF        0x4e,w
CODE:CODE:0146  d000            MOVWF       0x50
CODE:CODE:0147  d101            CLRF        0x51
CODE:CODE:0148  5108            MOVF        0x51,w
CODE:CODE:0149  1a3e            ADDLW       #0x1a
CODE:CODE:014a  ef00            MOVWF       0x6f
CODE:CODE:014b  5008            MOVF        0x50,w
CODE:CODE:014c  363e            ADDLW       #0x36
CODE:CODE:014d  0318            BTFSC       STATUS,#0x0
CODE:CODE:014e  ef0a            INCF        0x6f,f
CODE:CODE:014f  0a12            BCF         PCLATH,#0x4
CODE:CODE:0150  8a11            BCF         PCLATH,#0x3
CODE:CODE:0151  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:0152  0a12            BCF         PCLATH,#0x4
CODE:CODE:0153  8a11            BCF         PCLATH,#0x3
CODE:CODE:0154  d500            MOVWF       0x55
CODE:CODE:0155  0030            MOVLW       #0x0
CODE:CODE:0156  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0157  0a12            BCF         PCLATH,#0x4
CODE:CODE:0158  8a11            BCF         PCLATH,#0x3
CODE:CODE:0159  ce0a            INCF        0x4e,f
CODE:CODE:015a  0830            MOVLW       #0x8
CODE:CODE:015b  4e02            SUBWF       0x4e,w
CODE:CODE:015c  031c            BTFSS       STATUS,#0x0
CODE:CODE:015d  4029            GOTO        LAB_CODE_0140
CODE:CODE:015e  ce01            CLRF        0x4e
                            LAB_CODE_015f:                ;XREF[1,0]:   CODE:017d
CODE:CODE:015f  4e08            MOVF        0x4e,w
CODE:CODE:0160  083e            ADDLW       #0x8
CODE:CODE:0161  4038            IORLW       #0x40
CODE:CODE:0162  d500            MOVWF       0x55
CODE:CODE:0163  0130            MOVLW       #0x1
CODE:CODE:0164  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0165  4e08            MOVF        0x4e,w
CODE:CODE:0166  d000            MOVWF       0x50
CODE:CODE:0167  d101            CLRF        0x51
CODE:CODE:0168  5108            MOVF        0x51,w
CODE:CODE:0169  1a3e            ADDLW       #0x1a
CODE:CODE:016a  ef00            MOVWF       0x6f
CODE:CODE:016b  5008            MOVF        0x50,w
CODE:CODE:016c  3f3e            ADDLW       #0x3f
CODE:CODE:016d  0318            BTFSC       STATUS,#0x0
CODE:CODE:016e  ef0a            INCF        0x6f,f
CODE:CODE:016f  0a12            BCF         PCLATH,#0x4
CODE:CODE:0170  8a11            BCF         PCLATH,#0x3
CODE:CODE:0171  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:0172  0a12            BCF         PCLATH,#0x4
CODE:CODE:0173  8a11            BCF         PCLATH,#0x3
CODE:CODE:0174  d500            MOVWF       0x55
CODE:CODE:0175  0030            MOVLW       #0x0
CODE:CODE:0176  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0177  0a12            BCF         PCLATH,#0x4
CODE:CODE:0178  8a11            BCF         PCLATH,#0x3
CODE:CODE:0179  ce0a            INCF        0x4e,f
CODE:CODE:017a  0830            MOVLW       #0x8
CODE:CODE:017b  4e02            SUBWF       0x4e,w
CODE:CODE:017c  031c            BTFSS       STATUS,#0x0
CODE:CODE:017d  5f29            GOTO        LAB_CODE_015f
CODE:CODE:017e  ce01            CLRF        0x4e
                            LAB_CODE_017f:                ;XREF[1,0]:   CODE:019d
CODE:CODE:017f  4e08            MOVF        0x4e,w
CODE:CODE:0180  103e            ADDLW       #0x10
CODE:CODE:0181  4038            IORLW       #0x40
CODE:CODE:0182  d500            MOVWF       0x55
CODE:CODE:0183  0130            MOVLW       #0x1
CODE:CODE:0184  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0185  4e08            MOVF        0x4e,w
CODE:CODE:0186  d000            MOVWF       0x50
CODE:CODE:0187  d101            CLRF        0x51
CODE:CODE:0188  5108            MOVF        0x51,w
CODE:CODE:0189  1a3e            ADDLW       #0x1a
CODE:CODE:018a  ef00            MOVWF       0x6f
CODE:CODE:018b  5008            MOVF        0x50,w
CODE:CODE:018c  483e            ADDLW       #0x48
CODE:CODE:018d  0318            BTFSC       STATUS,#0x0
CODE:CODE:018e  ef0a            INCF        0x6f,f
CODE:CODE:018f  0a12            BCF         PCLATH,#0x4
CODE:CODE:0190  8a11            BCF         PCLATH,#0x3
CODE:CODE:0191  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:0192  0a12            BCF         PCLATH,#0x4
CODE:CODE:0193  8a11            BCF         PCLATH,#0x3
CODE:CODE:0194  d500            MOVWF       0x55
CODE:CODE:0195  0030            MOVLW       #0x0
CODE:CODE:0196  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0197  0a12            BCF         PCLATH,#0x4
CODE:CODE:0198  8a11            BCF         PCLATH,#0x3
CODE:CODE:0199  ce0a            INCF        0x4e,f
CODE:CODE:019a  0830            MOVLW       #0x8
CODE:CODE:019b  4e02            SUBWF       0x4e,w
CODE:CODE:019c  031c            BTFSS       STATUS,#0x0
CODE:CODE:019d  7f29            GOTO        LAB_CODE_017f
CODE:CODE:019e  ce01            CLRF        0x4e
                            LAB_CODE_019f:                ;XREF[1,0]:   CODE:01bd
CODE:CODE:019f  4e08            MOVF        0x4e,w
CODE:CODE:01a0  183e            ADDLW       #0x18
CODE:CODE:01a1  4038            IORLW       #0x40
CODE:CODE:01a2  d500            MOVWF       0x55
CODE:CODE:01a3  0130            MOVLW       #0x1
CODE:CODE:01a4  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01a5  4e08            MOVF        0x4e,w
CODE:CODE:01a6  d000            MOVWF       0x50
CODE:CODE:01a7  d101            CLRF        0x51
CODE:CODE:01a8  5108            MOVF        0x51,w
CODE:CODE:01a9  1a3e            ADDLW       #0x1a
CODE:CODE:01aa  ef00            MOVWF       0x6f
CODE:CODE:01ab  5008            MOVF        0x50,w
CODE:CODE:01ac  483e            ADDLW       #0x48
CODE:CODE:01ad  0318            BTFSC       STATUS,#0x0
CODE:CODE:01ae  ef0a            INCF        0x6f,f
CODE:CODE:01af  0a12            BCF         PCLATH,#0x4
CODE:CODE:01b0  8a11            BCF         PCLATH,#0x3
CODE:CODE:01b1  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:01b2  0a12            BCF         PCLATH,#0x4
CODE:CODE:01b3  8a11            BCF         PCLATH,#0x3
CODE:CODE:01b4  d500            MOVWF       0x55
CODE:CODE:01b5  0030            MOVLW       #0x0
CODE:CODE:01b6  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01b7  0a12            BCF         PCLATH,#0x4
CODE:CODE:01b8  8a11            BCF         PCLATH,#0x3
CODE:CODE:01b9  ce0a            INCF        0x4e,f
CODE:CODE:01ba  0830            MOVLW       #0x8
CODE:CODE:01bb  4e02            SUBWF       0x4e,w
CODE:CODE:01bc  031c            BTFSS       STATUS,#0x0
CODE:CODE:01bd  9f29            GOTO        LAB_CODE_019f
CODE:CODE:01be  3930            MOVLW       #0x39
CODE:CODE:01bf  d500            MOVWF       0x55
CODE:CODE:01c0  0130            MOVLW       #0x1
CODE:CODE:01c1  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01c2  0a12            BCF         PCLATH,#0x4
CODE:CODE:01c3  8a11            BCF         PCLATH,#0x3
CODE:CODE:01c4  1c30            MOVLW       #0x1c
CODE:CODE:01c5  d500            MOVWF       0x55
CODE:CODE:01c6  0130            MOVLW       #0x1
CODE:CODE:01c7  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01c8  0a12            BCF         PCLATH,#0x4
CODE:CODE:01c9  8a11            BCF         PCLATH,#0x3
CODE:CODE:01ca  5f30            MOVLW       #0x5f
CODE:CODE:01cb  d500            MOVWF       0x55
CODE:CODE:01cc  0130            MOVLW       #0x1
CODE:CODE:01cd  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01ce  0a12            BCF         PCLATH,#0x4
CODE:CODE:01cf  8a11            BCF         PCLATH,#0x3
CODE:CODE:01d0  0c30            MOVLW       #0xc
CODE:CODE:01d1  d500            MOVWF       0x55
CODE:CODE:01d2  0130            MOVLW       #0x1
CODE:CODE:01d3  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01d4  0a12            BCF         PCLATH,#0x4
CODE:CODE:01d5  8a11            BCF         PCLATH,#0x3
CODE:CODE:01d6  0630            MOVLW       #0x6
CODE:CODE:01d7  d500            MOVWF       0x55
CODE:CODE:01d8  0130            MOVLW       #0x1
CODE:CODE:01d9  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01da  0a12            BCF         PCLATH,#0x4
CODE:CODE:01db  8a11            BCF         PCLATH,#0x3
CODE:CODE:01dc  cd08            MOVF        0x4d,f
CODE:CODE:01dd  031d            BTFSS       STATUS,#0x2
CODE:CODE:01de  0800            RETURN
CODE:CODE:01df  d501            CLRF        0x55
CODE:CODE:01e0  d50a            INCF        0x55,f
CODE:CODE:01e1  0130            MOVLW       #0x1
CODE:CODE:01e2  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01e3  0a12            BCF         PCLATH,#0x4
CODE:CODE:01e4  8a11            BCF         PCLATH,#0x3
CODE:CODE:01e5  0230            MOVLW       #0x2
CODE:CODE:01e6  d500            MOVWF       0x55
CODE:CODE:01e7  0130            MOVLW       #0x1
                            ;this is a goto
CODE:CODE:01e8  fd28            GOTO        Adele
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Eva()
                                                          ;XREF[6,0]:   CODE:029b,CODE:02f4,CODE:02fc,CODE:0302
                                                          ;             CODE:030a,CODE:0314
CODE:CODE:01e9  8301            CLRF        STATUS
CODE:CODE:01ea  cf00            MOVWF       BANK-0:DAT_DATA_004f                    ;= ??
CODE:CODE:01eb  8038            IORLW       #0x80
CODE:CODE:01ec  d500            MOVWF       BANK-0:DAT_DATA_0055                    ;= ??
CODE:CODE:01ed  0130            MOVLW       #0x1
CODE:CODE:01ee  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:01ef  0a12            BCF         PCLATH,#0x4
CODE:CODE:01f0  8a11            BCF         PCLATH,#0x3
CODE:CODE:01f1  4e08            MOVF        BANK-0:DAT_DATA_004e,w                  ;= ??
CODE:CODE:01f2  d500            MOVWF       BANK-0:DAT_DATA_0055                    ;= ??
CODE:CODE:01f3  0030            MOVLW       #0x0
                            ;this is a goto
CODE:CODE:01f4  fd28            GOTO        Adele
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;byte MAINLOOP_MAIN_LOGIC_SUB2(void)
                                                          ;XREF[1,0]:   CODE:0d1c
CODE:CODE:01f5  302c            GOTO        BGT1_pre
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 1                                    *
                            ;************************************************************************************************
                            BGT_1:                        ;XREF[1,0]:   CODE:0448
CODE:CODE:01f6  0330            MOVLW       #0x3
CODE:CODE:01f7  8316            BSF         STATUS,RP0
CODE:CODE:01f8  a000            MOVWF       0x20
CODE:CODE:01f9  4530            MOVLW       #0x45
CODE:CODE:01fa  8312            BCF         STATUS,RP0
CODE:CODE:01fb  c700            MOVWF       0x47
CODE:CODE:01fc  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:01fd  122a            GOTO        LAB_CODE_0212
CODE:CODE:01fe  cd01            CLRF        0x4d
                            LAB_CODE_01ff:                ;XREF[1,0]:   CODE:0209
CODE:CODE:01ff  4d08            MOVF        0x4d,w
CODE:CODE:0200  273e            ADDLW       #0x27
CODE:CODE:0201  8400            MOVWF       FSR0L
CODE:CODE:0202  8317            BSF         STATUS,IRP
CODE:CODE:0203  2030            MOVLW       #0x20
CODE:CODE:0204  8000            MOVWF       INDF0
CODE:CODE:0205  cd0a            INCF        0x4d,f
CODE:CODE:0206  0a30            MOVLW       #0xa
CODE:CODE:0207  4d02            SUBWF       0x4d,w
CODE:CODE:0208  031c            BTFSS       STATUS,#0x0
CODE:CODE:0209  ff29            GOTO        LAB_CODE_01ff
CODE:CODE:020a  ac17            BSF         0x2c,#0x7
CODE:CODE:020b  4030            MOVLW       #0x40
CODE:CODE:020c  8316            BSF         STATUS,RP0
CODE:CODE:020d  b100            MOVWF       0x31
CODE:CODE:020e  8312            BCF         STATUS,RP0
CODE:CODE:020f  3017            BSF         0x30,#0x6
CODE:CODE:0210  b017            BSF         0x30,#0x7
CODE:CODE:0211  652c            GOTO        BGT_18_RET
                            LAB_CODE_0212:                ;XREF[1,0]:   CODE:01fd
CODE:CODE:0212  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0213  7f39            ANDLW       #0x7f
CODE:CODE:0214  8316            BSF         STATUS,RP0
CODE:CODE:0215  a100            MOVWF       0x21
CODE:CODE:0216  8312            BCF         STATUS,RP0
CODE:CODE:0217  3c08            MOVF        0x3c,w
CODE:CODE:0218  7f39            ANDLW       #0x7f
CODE:CODE:0219  8316            BSF         STATUS,RP0
CODE:CODE:021a  ab00            MOVWF       0x2b
CODE:CODE:021b  ae01            CLRF        0x2e
CODE:CODE:021c  8312            BCF         STATUS,RP0
CODE:CODE:021d  3b08            MOVF        0x3b,w
CODE:CODE:021e  7f39            ANDLW       #0x7f
CODE:CODE:021f  8316            BSF         STATUS,RP0
CODE:CODE:0220  a200            MOVWF       0x22
CODE:CODE:0221  8312            BCF         STATUS,RP0
CODE:CODE:0222  3c08            MOVF        0x3c,w
CODE:CODE:0223  7f39            ANDLW       #0x7f
CODE:CODE:0224  8316            BSF         STATUS,RP0
CODE:CODE:0225  ac00            MOVWF       0x2c
CODE:CODE:0226  8312            BCF         STATUS,RP0
CODE:CODE:0227  bb1f            BTFSS       0x3b,#0x7
CODE:CODE:0228  5b2a            GOTO        LAB_CODE_025b
CODE:CODE:0229  301f            BTFSS       0x30,#0x6
CODE:CODE:022a  2d2a            GOTO        LAB_CODE_022d
CODE:CODE:022b  3016            BSF         0x30,#0x4
CODE:CODE:022c  3013            BCF         0x30,#0x6
                            LAB_CODE_022d:                ;XREF[1,0]:   CODE:022a
CODE:CODE:022d  b01e            BTFSS       0x30,#0x5
CODE:CODE:022e  312a            GOTO        LAB_CODE_0231
CODE:CODE:022f  0330            MOVLW       #0x3
CODE:CODE:0230  322a            GOTO        LAB_CODE_0232
                            LAB_CODE_0231:                ;XREF[1,0]:   CODE:022e
CODE:CODE:0231  0430            MOVLW       #0x4
                            LAB_CODE_0232:                ;XREF[1,0]:   CODE:0230
CODE:CODE:0232  0a16            BSF         PCLATH,#0x4
CODE:CODE:0233  8a11            BCF         PCLATH,#0x3
CODE:CODE:0234  4820            CALL        offset MAINLOOP_MAIN_LOGIC_SUB1 &0xff   ;undefined MAINLOOP_MAIN_LOGIC_SUB1()
CODE:CODE:0235  0a12            BCF         PCLATH,#0x4
CODE:CODE:0236  8a11            BCF         PCLATH,#0x3
CODE:CODE:0237  be1d            BTFSS       0x3e,#0x3
CODE:CODE:0238  692a            GOTO        LAB_CODE_0269
CODE:CODE:0239  8316            BSF         STATUS,RP0
CODE:CODE:023a  2d0b            DECFSZ      0x2d,w
CODE:CODE:023b  692a            GOTO        LAB_CODE_0269
CODE:CODE:023c  8312            BCF         STATUS,RP0
CODE:CODE:023d  2e17            BSF         0x2e,#0x6
CODE:CODE:023e  8316            BSF         STATUS,RP0
CODE:CODE:023f  2108            MOVF        0x21,w
CODE:CODE:0240  8312            BCF         STATUS,RP0
CODE:CODE:0241  0317            BSF         STATUS,RP1
CODE:CODE:0242  c900            MOVWF       0x49
CODE:CODE:0243  8316            BSF         STATUS,RP0
CODE:CODE:0244  0313            BCF         STATUS,RP1
CODE:CODE:0245  2b08            MOVF        0x2b,w
CODE:CODE:0246  8312            BCF         STATUS,RP0
CODE:CODE:0247  0317            BSF         STATUS,RP1
CODE:CODE:0248  c800            MOVWF       0x48
CODE:CODE:0249  8316            BSF         STATUS,RP0
CODE:CODE:024a  0313            BCF         STATUS,RP1
CODE:CODE:024b  2e08            MOVF        0x2e,w
CODE:CODE:024c  8312            BCF         STATUS,RP0
CODE:CODE:024d  0317            BSF         STATUS,RP1
CODE:CODE:024e  c700            MOVWF       0x47
CODE:CODE:024f  ce01            CLRF        0x4e
CODE:CODE:0250  0313            BCF         STATUS,RP1
CODE:CODE:0251  cf01            CLRF        0x4f
CODE:CODE:0252  d001            CLRF        0x50
CODE:CODE:0253  d030            MOVLW       #0xd0
CODE:CODE:0254  d100            MOVWF       0x51
CODE:CODE:0255  0a16            BSF         PCLATH,#0x4
CODE:CODE:0256  8a11            BCF         PCLATH,#0x3
CODE:CODE:0257  2e27            CALL        offset Cecile-0x1000                    ;undefined Cecile()
CODE:CODE:0258  0a12            BCF         PCLATH,#0x4
CODE:CODE:0259  8a11            BCF         PCLATH,#0x3
CODE:CODE:025a  692a            GOTO        LAB_CODE_0269
                            LAB_CODE_025b:                ;XREF[1,0]:   CODE:0228
CODE:CODE:025b  b01f            BTFSS       BANK-0:DAT_DATA_0030,#0x7               ;= ??
CODE:CODE:025c  5f2a            GOTO        LAB_CODE_025f
CODE:CODE:025d  3016            BSF         0x30,#0x4
CODE:CODE:025e  b013            BCF         0x30,#0x7
                            LAB_CODE_025f:                ;XREF[1,0]:   CODE:025c
CODE:CODE:025f  b01e            BTFSS       0x30,#0x5
CODE:CODE:0260  632a            GOTO        LAB_CODE_0263
CODE:CODE:0261  0230            MOVLW       #0x2
CODE:CODE:0262  642a            GOTO        LAB_CODE_0264
                            LAB_CODE_0263:                ;XREF[1,0]:   CODE:0260
CODE:CODE:0263  0430            MOVLW       #0x4
                            LAB_CODE_0264:                ;XREF[1,0]:   CODE:0262
CODE:CODE:0264  0a16            BSF         PCLATH,#0x4
CODE:CODE:0265  8a11            BCF         PCLATH,#0x3
CODE:CODE:0266  4820            CALL        offset MAINLOOP_MAIN_LOGIC_SUB1 &0xff   ;undefined MAINLOOP_MAIN_LOGIC_SUB1()
CODE:CODE:0267  0a12            BCF         PCLATH,#0x4
CODE:CODE:0268  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_0269:                ;XREF[3,0]:   CODE:0238,CODE:023b,CODE:025a
CODE:CODE:0269  8312            BCF         STATUS,RP0
CODE:CODE:026a  cb2a            GOTO        LAB_CODE_02cb
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 2                                    *
                            ;************************************************************************************************
                            BGT_2:                        ;XREF[1,0]:   CODE:0449
CODE:CODE:026b  0330            MOVLW       #0x3
CODE:CODE:026c  8316            BSF         STATUS,RP0
CODE:CODE:026d  a000            MOVWF       0x20
CODE:CODE:026e  4630            MOVLW       #0x46
CODE:CODE:026f  8312            BCF         STATUS,RP0
CODE:CODE:0270  c700            MOVWF       0x47
CODE:CODE:0271  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:0272  652c            GOTO        BGT_18_RET
CODE:CODE:0273  3b08            MOVF        0x3b,w
CODE:CODE:0274  8316            BSF         STATUS,RP0
CODE:CODE:0275  a900            MOVWF       0x29
CODE:CODE:0276  3830            MOVLW       #0x38
CODE:CODE:0277  8312            BCF         STATUS,RP0
CODE:CODE:0278  c700            MOVWF       0x47
CODE:CODE:0279  3930            MOVLW       #0x39
CODE:CODE:027a  2e2c            GOTO        LAB_CODE_042e
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 3                                    *
                            ;************************************************************************************************
                            BGT_3:                        ;XREF[1,0]:   CODE:044a
CODE:CODE:027b  0330            MOVLW       #0x3
CODE:CODE:027c  8316            BSF         STATUS,RP0
CODE:CODE:027d  a000            MOVWF       0x20
CODE:CODE:027e  4730            MOVLW       #0x47
CODE:CODE:027f  8312            BCF         STATUS,RP0
CODE:CODE:0280  c700            MOVWF       0x47
CODE:CODE:0281  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:0282  9f2a            GOTO        LAB_CODE_029f
CODE:CODE:0283  cd01            CLRF        0x4d
                            LAB_CODE_0284:                ;XREF[1,0]:   CODE:028e
CODE:CODE:0284  4d08            MOVF        0x4d,w
CODE:CODE:0285  273e            ADDLW       #0x27
CODE:CODE:0286  8400            MOVWF       FSR0L
CODE:CODE:0287  8317            BSF         STATUS,IRP
CODE:CODE:0288  2030            MOVLW       #0x20
CODE:CODE:0289  8000            MOVWF       INDF0
CODE:CODE:028a  cd0a            INCF        0x4d,f
CODE:CODE:028b  0a30            MOVLW       #0xa
CODE:CODE:028c  4d02            SUBWF       0x4d,w
CODE:CODE:028d  031c            BTFSS       STATUS,#0x0
CODE:CODE:028e  842a            GOTO        LAB_CODE_0284
CODE:CODE:028f  ac17            BSF         0x2c,#0x7
CODE:CODE:0290  4030            MOVLW       #0x40
CODE:CODE:0291  8316            BSF         STATUS,RP0
CODE:CODE:0292  b100            MOVWF       0x31
CODE:CODE:0293  8312            BCF         STATUS,RP0
CODE:CODE:0294  b017            BSF         0x30,#0x7
CODE:CODE:0295  3017            BSF         0x30,#0x6
CODE:CODE:0296  3618            BTFSC       0x36,#0x0
CODE:CODE:0297  652c            GOTO        BGT_18_RET
CODE:CODE:0298  1030            MOVLW       #0x10
CODE:CODE:0299  ce00            MOVWF       0x4e
CODE:CODE:029a  4a30            MOVLW       #0x4a
CODE:CODE:029b  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:029c  0a12            BCF         PCLATH,#0x4
CODE:CODE:029d  8a11            BCF         PCLATH,#0x3
CODE:CODE:029e  652c            GOTO        BGT_18_RET
                            LAB_CODE_029f:                ;XREF[1,0]:   CODE:0282
CODE:CODE:029f  bb08            MOVF        BANK-0:DAT_DATA_003b,f                  ;= ??
CODE:CODE:02a0  0319            BTFSC       STATUS,#0x2
CODE:CODE:02a1  2d2c            GOTO        LAB_CODE_042d
CODE:CODE:02a2  2b2c            GOTO        LAB_CODE_042b
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 17                                    *
                            ;************************************************************************************************
                            BGT_17:                       ;XREF[1,0]:   CODE:0460
CODE:CODE:02a3  0330            MOVLW       #0x3
CODE:CODE:02a4  8316            BSF         STATUS,RP0
CODE:CODE:02a5  a000            MOVWF       0x20
CODE:CODE:02a6  4730            MOVLW       #0x47
CODE:CODE:02a7  8312            BCF         STATUS,RP0
CODE:CODE:02a8  c700            MOVWF       0x47
CODE:CODE:02a9  3b08            MOVF        0x3b,w
CODE:CODE:02aa  7f39            ANDLW       #0x7f
CODE:CODE:02ab  8316            BSF         STATUS,RP0
CODE:CODE:02ac  a200            MOVWF       0x22
CODE:CODE:02ad  8312            BCF         STATUS,RP0
CODE:CODE:02ae  3c08            MOVF        0x3c,w
CODE:CODE:02af  7f39            ANDLW       #0x7f
CODE:CODE:02b0  8316            BSF         STATUS,RP0
CODE:CODE:02b1  ac00            MOVWF       0x2c
CODE:CODE:02b2  8312            BCF         STATUS,RP0
CODE:CODE:02b3  bb1f            BTFSS       0x3b,#0x7
CODE:CODE:02b4  bd2a            GOTO        LAB_CODE_02bd
CODE:CODE:02b5  301f            BTFSS       0x30,#0x6
CODE:CODE:02b6  b92a            GOTO        LAB_CODE_02b9
CODE:CODE:02b7  3016            BSF         0x30,#0x4
CODE:CODE:02b8  3013            BCF         0x30,#0x6
                            LAB_CODE_02b9:                ;XREF[1,0]:   CODE:02b6
CODE:CODE:02b9  b01e            BTFSS       0x30,#0x5
CODE:CODE:02ba  c52a            GOTO        LAB_CODE_02c5
CODE:CODE:02bb  0330            MOVLW       #0x3
CODE:CODE:02bc  c62a            GOTO        LAB_CODE_02c6
                            LAB_CODE_02bd:                ;XREF[1,0]:   CODE:02b4
CODE:CODE:02bd  b01f            BTFSS       BANK-0:DAT_DATA_0030,#0x7               ;= ??
CODE:CODE:02be  c12a            GOTO        LAB_CODE_02c1
CODE:CODE:02bf  3016            BSF         0x30,#0x4
CODE:CODE:02c0  b013            BCF         0x30,#0x7
                            LAB_CODE_02c1:                ;XREF[1,0]:   CODE:02be
CODE:CODE:02c1  b01e            BTFSS       0x30,#0x5
CODE:CODE:02c2  c52a            GOTO        LAB_CODE_02c5
CODE:CODE:02c3  0230            MOVLW       #0x2
CODE:CODE:02c4  c62a            GOTO        LAB_CODE_02c6
                            LAB_CODE_02c5:                ;XREF[2,0]:   CODE:02ba,CODE:02c2
CODE:CODE:02c5  0430            MOVLW       #0x4
                            LAB_CODE_02c6:                ;XREF[2,0]:   CODE:02bc,CODE:02c4
CODE:CODE:02c6  0a16            BSF         PCLATH,#0x4
CODE:CODE:02c7  8a11            BCF         PCLATH,#0x3
CODE:CODE:02c8  4820            CALL        offset MAINLOOP_MAIN_LOGIC_SUB1 &0xff   ;undefined MAINLOOP_MAIN_LOGIC_SUB1()
CODE:CODE:02c9  0a12            BCF         PCLATH,#0x4
CODE:CODE:02ca  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_02cb:                ;XREF[1,0]:   CODE:026a
CODE:CODE:02cb  ac17            BSF         0x2c,#0x7
CODE:CODE:02cc  4030            MOVLW       #0x40
CODE:CODE:02cd  252c            GOTO        LAB_CODE_0425
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 4                                    *
                            ;************************************************************************************************
                            BGT_4:                        ;XREF[1,0]:   CODE:044b
CODE:CODE:02ce  0330            MOVLW       #0x3
CODE:CODE:02cf  8316            BSF         STATUS,RP0
CODE:CODE:02d0  a000            MOVWF       0x20
CODE:CODE:02d1  4830            MOVLW       #0x48
CODE:CODE:02d2  742b            GOTO        LAB_CODE_0374
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 5                                    *
                            ;************************************************************************************************
                            BGT_5:                        ;XREF[1,0]:   CODE:044c
CODE:CODE:02d3  0330            MOVLW       #0x3
CODE:CODE:02d4  8316            BSF         STATUS,RP0
CODE:CODE:02d5  a000            MOVWF       0x20
CODE:CODE:02d6  4930            MOVLW       #0x49
CODE:CODE:02d7  8312            BCF         STATUS,RP0
CODE:CODE:02d8  c700            MOVWF       0x47
CODE:CODE:02d9  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:02da  652c            GOTO        BGT_18_RET
CODE:CODE:02db  cd01            CLRF        0x4d
                            LAB_CODE_02dc:                ;XREF[1,0]:   CODE:02e6
CODE:CODE:02dc  4d08            MOVF        0x4d,w
CODE:CODE:02dd  273e            ADDLW       #0x27
CODE:CODE:02de  8400            MOVWF       FSR0L
CODE:CODE:02df  8317            BSF         STATUS,IRP
CODE:CODE:02e0  2030            MOVLW       #0x20
CODE:CODE:02e1  8000            MOVWF       INDF0
CODE:CODE:02e2  cd0a            INCF        0x4d,f
CODE:CODE:02e3  0a30            MOVLW       #0xa
CODE:CODE:02e4  4d02            SUBWF       0x4d,w
CODE:CODE:02e5  031c            BTFSS       STATUS,#0x0
CODE:CODE:02e6  dc2a            GOTO        LAB_CODE_02dc
CODE:CODE:02e7  3e2b            GOTO        LAB_CODE_033e
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 6                                    *
                            ;************************************************************************************************
                            BGT_6:                        ;XREF[1,0]:   CODE:044d
CODE:CODE:02e8  0330            MOVLW       #0x3
CODE:CODE:02e9  8316            BSF         STATUS,RP0
CODE:CODE:02ea  a000            MOVWF       0x20
CODE:CODE:02eb  4d30            MOVLW       #0x4d
CODE:CODE:02ec  8312            BCF         STATUS,RP0
CODE:CODE:02ed  c700            MOVWF       0x47
CODE:CODE:02ee  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:02ef  192b            GOTO        LAB_CODE_0319
CODE:CODE:02f0  652c            GOTO        BGT_18_RET
                            LAB_CODE_02f1:                ;XREF[1,0]:   CODE:031c
CODE:CODE:02f1  3130            MOVLW       #0x31
CODE:CODE:02f2  ce00            MOVWF       0x4e
CODE:CODE:02f3  4030            MOVLW       #0x40
CODE:CODE:02f4  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:02f5  0a12            BCF         PCLATH,#0x4
CODE:CODE:02f6  8a11            BCF         PCLATH,#0x3
CODE:CODE:02f7  3530            MOVLW       #0x35
CODE:CODE:02f8  002b            GOTO        LAB_CODE_0300
                            LAB_CODE_02f9:                ;XREF[1,0]:   CODE:031f
CODE:CODE:02f9  3330            MOVLW       #0x33
CODE:CODE:02fa  ce00            MOVWF       0x4e
CODE:CODE:02fb  4030            MOVLW       #0x40
CODE:CODE:02fc  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:02fd  0a12            BCF         PCLATH,#0x4
CODE:CODE:02fe  8a11            BCF         PCLATH,#0x3
CODE:CODE:02ff  3030            MOVLW       #0x30
                            LAB_CODE_0300:                ;XREF[1,0]:   CODE:02f8
CODE:CODE:0300  ce00            MOVWF       0x4e
CODE:CODE:0301  4130            MOVLW       #0x41
CODE:CODE:0302  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:0303  0a12            BCF         PCLATH,#0x4
CODE:CODE:0304  8a11            BCF         PCLATH,#0x3
CODE:CODE:0305  c801            CLRF        0x48
CODE:CODE:0306  652c            GOTO        BGT_18_RET
                            LAB_CODE_0307:                ;XREF[1,0]:   CODE:0322
CODE:CODE:0307  3130            MOVLW       #0x31
CODE:CODE:0308  ce00            MOVWF       0x4e
CODE:CODE:0309  4030            MOVLW       #0x40
CODE:CODE:030a  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:030b  0a12            BCF         PCLATH,#0x4
CODE:CODE:030c  8a11            BCF         PCLATH,#0x3
CODE:CODE:030d  4e30            MOVLW       #0x4e
CODE:CODE:030e  2e2c            GOTO        LAB_CODE_042e
                            LAB_CODE_030f:                ;XREF[1,0]:   CODE:0325
CODE:CODE:030f  3230            MOVLW       #0x32
CODE:CODE:0310  122b            GOTO        LAB_CODE_0312
                            LAB_CODE_0311:                ;XREF[1,0]:   CODE:0328
CODE:CODE:0311  3330            MOVLW       #0x33
                            LAB_CODE_0312:                ;XREF[1,0]:   CODE:0310
CODE:CODE:0312  ce00            MOVWF       0x4e
CODE:CODE:0313  4030            MOVLW       #0x40
CODE:CODE:0314  e921            CALL        Eva                                     ;undefined Eva()
CODE:CODE:0315  0a12            BCF         PCLATH,#0x4
CODE:CODE:0316  8a11            BCF         PCLATH,#0x3
CODE:CODE:0317  4f30            MOVLW       #0x4f
CODE:CODE:0318  2e2c            GOTO        LAB_CODE_042e
                            LAB_CODE_0319:                ;XREF[1,0]:   CODE:02ef
CODE:CODE:0319  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:031a  003a            XORLW       #0x0
CODE:CODE:031b  0319            BTFSC       STATUS,#0x2
CODE:CODE:031c  f12a            GOTO        LAB_CODE_02f1
CODE:CODE:031d  013a            XORLW       #0x1
CODE:CODE:031e  0319            BTFSC       STATUS,#0x2
CODE:CODE:031f  f92a            GOTO        LAB_CODE_02f9
CODE:CODE:0320  033a            XORLW       #0x3
CODE:CODE:0321  0319            BTFSC       STATUS,#0x2
CODE:CODE:0322  072b            GOTO        LAB_CODE_0307
CODE:CODE:0323  013a            XORLW       #0x1
CODE:CODE:0324  0319            BTFSC       STATUS,#0x2
CODE:CODE:0325  0f2b            GOTO        LAB_CODE_030f
CODE:CODE:0326  073a            XORLW       #0x7
CODE:CODE:0327  0319            BTFSC       STATUS,#0x2
CODE:CODE:0328  112b            GOTO        LAB_CODE_0311
CODE:CODE:0329  652c            GOTO        BGT_18_RET
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 7                                    *
                            ;************************************************************************************************
                            BGT_7:                        ;XREF[1,0]:   CODE:044e
CODE:CODE:032a  0330            MOVLW       #0x3
CODE:CODE:032b  8316            BSF         STATUS,RP0
CODE:CODE:032c  a000            MOVWF       0x20
CODE:CODE:032d  5130            MOVLW       #0x51
CODE:CODE:032e  8312            BCF         STATUS,RP0
CODE:CODE:032f  c700            MOVWF       0x47
CODE:CODE:0330  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:0331  652c            GOTO        BGT_18_RET
CODE:CODE:0332  cd01            CLRF        0x4d
                            LAB_CODE_0333:                ;XREF[1,0]:   CODE:033d
CODE:CODE:0333  4d08            MOVF        0x4d,w
CODE:CODE:0334  273e            ADDLW       #0x27
CODE:CODE:0335  8400            MOVWF       FSR0L
CODE:CODE:0336  8317            BSF         STATUS,IRP
CODE:CODE:0337  2030            MOVLW       #0x20
CODE:CODE:0338  8000            MOVWF       INDF0
CODE:CODE:0339  cd0a            INCF        0x4d,f
CODE:CODE:033a  0a30            MOVLW       #0xa
CODE:CODE:033b  4d02            SUBWF       0x4d,w
CODE:CODE:033c  031c            BTFSS       STATUS,#0x0
CODE:CODE:033d  332b            GOTO        LAB_CODE_0333
                            LAB_CODE_033e:                ;XREF[1,0]:   CODE:02e7
CODE:CODE:033e  ac17            BSF         0x2c,#0x7
CODE:CODE:033f  4830            MOVLW       #0x48
CODE:CODE:0340  8316            BSF         STATUS,RP0
CODE:CODE:0341  b100            MOVWF       0x31
CODE:CODE:0342  5c2b            GOTO        LAB_CODE_035c
                            LAB_CODE_0343:                ;XREF[1,0]:   CODE:0360
CODE:CODE:0343  fd30            MOVLW       #0xfd
CODE:CODE:0344  0317            BSF         STATUS,RP1
CODE:CODE:0345  a700            MOVWF       0x27
CODE:CODE:0346  6f30            MOVLW       #0x6f
CODE:CODE:0347  582b            GOTO        LAB_CODE_0358
                            LAB_CODE_0348:                ;XREF[1,0]:   CODE:0363
CODE:CODE:0348  fd30            MOVLW       #0xfd
CODE:CODE:0349  0317            BSF         STATUS,RP1
CODE:CODE:034a  a700            MOVWF       0x27
CODE:CODE:034b  a800            MOVWF       0x28
CODE:CODE:034c  6f30            MOVLW       #0x6f
CODE:CODE:034d  592b            GOTO        LAB_CODE_0359
                            LAB_CODE_034e:                ;XREF[1,0]:   CODE:0366
CODE:CODE:034e  fd30            MOVLW       #0xfd
CODE:CODE:034f  0317            BSF         STATUS,RP1
CODE:CODE:0350  a700            MOVWF       0x27
CODE:CODE:0351  a800            MOVWF       0x28
CODE:CODE:0352  a900            MOVWF       0x29
CODE:CODE:0353  6f30            MOVLW       #0x6f
CODE:CODE:0354  5a2b            GOTO        LAB_CODE_035a
                            LAB_CODE_0355:                ;XREF[1,0]:   CODE:0369
CODE:CODE:0355  fd30            MOVLW       #0xfd
CODE:CODE:0356  0317            BSF         STATUS,RP1
CODE:CODE:0357  a700            MOVWF       0x27
                            LAB_CODE_0358:                ;XREF[1,0]:   CODE:0347
CODE:CODE:0358  a800            MOVWF       0x28
                            LAB_CODE_0359:                ;XREF[1,0]:   CODE:034d
CODE:CODE:0359  a900            MOVWF       0x29
                            LAB_CODE_035a:                ;XREF[1,0]:   CODE:0354
CODE:CODE:035a  aa00            MOVWF       0x2a
CODE:CODE:035b  652c            GOTO        BGT_18_RET
                            LAB_CODE_035c:                ;XREF[1,0]:   CODE:0342
CODE:CODE:035c  8312            BCF         STATUS,RP0
CODE:CODE:035d  3b08            MOVF        0x3b,w
CODE:CODE:035e  003a            XORLW       #0x0
CODE:CODE:035f  0319            BTFSC       STATUS,#0x2
CODE:CODE:0360  432b            GOTO        LAB_CODE_0343
CODE:CODE:0361  013a            XORLW       #0x1
CODE:CODE:0362  0319            BTFSC       STATUS,#0x2
CODE:CODE:0363  482b            GOTO        LAB_CODE_0348
CODE:CODE:0364  033a            XORLW       #0x3
CODE:CODE:0365  0319            BTFSC       STATUS,#0x2
CODE:CODE:0366  4e2b            GOTO        LAB_CODE_034e
CODE:CODE:0367  013a            XORLW       #0x1
CODE:CODE:0368  0319            BTFSC       STATUS,#0x2
CODE:CODE:0369  552b            GOTO        LAB_CODE_0355
CODE:CODE:036a  652c            GOTO        BGT_18_RET
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 8                                    *
                            ;************************************************************************************************
                            BGT_8:                        ;XREF[1,0]:   CODE:044f
CODE:CODE:036b  0330            MOVLW       #0x3
CODE:CODE:036c  8316            BSF         STATUS,RP0
CODE:CODE:036d  a000            MOVWF       0x20
CODE:CODE:036e  5730            MOVLW       #0x57
CODE:CODE:036f  742b            GOTO        LAB_CODE_0374
                            ;************************************************************************************************
                            ;*                                    BigFuckingGoto entry 9                                    *
                            ;************************************************************************************************
                            BGT_9:                        ;XREF[1,0]:   CODE:0450
CODE:CODE:0370  0330            MOVLW       #0x3
CODE:CODE:0371  8316            BSF         STATUS,RP0
CODE:CODE:0372  a000            MOVWF       0x20
CODE:CODE:0373  5830            MOVLW       #0x58
                            LAB_CODE_0374:                ;XREF[2,0]:   CODE:02d2,CODE:036f
CODE:CODE:0374  8312            BCF         STATUS,RP0
CODE:CODE:0375  c700            MOVWF       0x47
CODE:CODE:0376  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:0377  652c            GOTO        BGT_18_RET
CODE:CODE:0378  4430            MOVLW       #0x44
CODE:CODE:0379  2e2c            GOTO        LAB_CODE_042e
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 12                                    *
                            ;************************************************************************************************
                            BGT_12:                       ;XREF[1,0]:   CODE:0455
CODE:CODE:037a  0330            MOVLW       #0x3
CODE:CODE:037b  8316            BSF         STATUS,RP0
CODE:CODE:037c  a000            MOVWF       0x20
CODE:CODE:037d  5a30            MOVLW       #0x5a
CODE:CODE:037e  8312            BCF         STATUS,RP0
CODE:CODE:037f  c700            MOVWF       0x47
CODE:CODE:0380  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:0381  652c            GOTO        BGT_18_RET
CODE:CODE:0382  5c30            MOVLW       #0x5c
CODE:CODE:0383  af2b            GOTO        LAB_CODE_03af
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 10                                    *
                            ;************************************************************************************************
                            BGT_10:                       ;XREF[2,0]:   CODE:0451,CODE:0453
CODE:CODE:0384  0330            MOVLW       #0x3
CODE:CODE:0385  8316            BSF         STATUS,RP0
CODE:CODE:0386  a000            MOVWF       0x20
CODE:CODE:0387  5a30            MOVLW       #0x5a
CODE:CODE:0388  8312            BCF         STATUS,RP0
CODE:CODE:0389  c700            MOVWF       0x47
CODE:CODE:038a  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:038b  652c            GOTO        BGT_18_RET
CODE:CODE:038c  3a08            MOVF        0x3a,w
CODE:CODE:038d  3f39            ANDLW       #0x3f
CODE:CODE:038e  1a3a            XORLW       #0x1a
CODE:CODE:038f  031d            BTFSS       STATUS,#0x2
CODE:CODE:0390  932b            GOTO        LAB_CODE_0393
CODE:CODE:0391  5b30            MOVLW       #0x5b
CODE:CODE:0392  af2b            GOTO        LAB_CODE_03af
                            LAB_CODE_0393:                ;XREF[1,0]:   CODE:0390
CODE:CODE:0393  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:0394  3f39            ANDLW       #0x3f
CODE:CODE:0395  1c3a            XORLW       #0x1c
CODE:CODE:0396  031d            BTFSS       STATUS,#0x2
CODE:CODE:0397  652c            GOTO        BGT_18_RET
CODE:CODE:0398  5e30            MOVLW       #0x5e
CODE:CODE:0399  af2b            GOTO        LAB_CODE_03af
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 11                                    *
                            ;************************************************************************************************
                            BGT_11:                       ;XREF[2,0]:   CODE:0452,CODE:0454
CODE:CODE:039a  0330            MOVLW       #0x3
CODE:CODE:039b  8316            BSF         STATUS,RP0
CODE:CODE:039c  a000            MOVWF       0x20
CODE:CODE:039d  5a30            MOVLW       #0x5a
CODE:CODE:039e  8312            BCF         STATUS,RP0
CODE:CODE:039f  c700            MOVWF       0x47
CODE:CODE:03a0  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:03a1  652c            GOTO        BGT_18_RET
CODE:CODE:03a2  3a08            MOVF        0x3a,w
CODE:CODE:03a3  3f39            ANDLW       #0x3f
CODE:CODE:03a4  1b3a            XORLW       #0x1b
CODE:CODE:03a5  031d            BTFSS       STATUS,#0x2
CODE:CODE:03a6  a92b            GOTO        LAB_CODE_03a9
CODE:CODE:03a7  5d30            MOVLW       #0x5d
CODE:CODE:03a8  af2b            GOTO        LAB_CODE_03af
                            LAB_CODE_03a9:                ;XREF[1,0]:   CODE:03a6
CODE:CODE:03a9  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:03aa  3f39            ANDLW       #0x3f
CODE:CODE:03ab  1d3a            XORLW       #0x1d
CODE:CODE:03ac  031d            BTFSS       STATUS,#0x2
CODE:CODE:03ad  652c            GOTO        BGT_18_RET
CODE:CODE:03ae  5f30            MOVLW       #0x5f
                            LAB_CODE_03af:                ;XREF[4,0]:   CODE:0383,CODE:0392,CODE:0399,CODE:03a8
CODE:CODE:03af  c800            MOVWF       0x48
CODE:CODE:03b0  3b08            MOVF        0x3b,w
CODE:CODE:03b1  8316            BSF         STATUS,RP0
CODE:CODE:03b2  dc00            MOVWF       0x5c
CODE:CODE:03b3  8312            BCF         STATUS,RP0
CODE:CODE:03b4  3c08            MOVF        0x3c,w
CODE:CODE:03b5  8316            BSF         STATUS,RP0
CODE:CODE:03b6  db00            MOVWF       0x5b
CODE:CODE:03b7  d500            MOVWF       0x55
CODE:CODE:03b8  5c08            MOVF        0x5c,w
CODE:CODE:03b9  d600            MOVWF       0x56
CODE:CODE:03ba  0a16            BSF         PCLATH,#0x4
CODE:CODE:03bb  8a11            BCF         PCLATH,#0x3
CODE:CODE:03bc  6f21            CALL        offset Eliana-0x1000                    ;undefined Eliana()
CODE:CODE:03bd  0a12            BCF         PCLATH,#0x4
CODE:CODE:03be  8a11            BCF         PCLATH,#0x3
CODE:CODE:03bf  ac17            BSF         0x2c,#0x7
CODE:CODE:03c0  4f30            MOVLW       #0x4f
CODE:CODE:03c1  252c            GOTO        LAB_CODE_0425
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 13                                    *
                            ;************************************************************************************************
                            BGT_13:                       ;XREF[1,0]:   CODE:0456
CODE:CODE:03c2  0330            MOVLW       #0x3
CODE:CODE:03c3  8316            BSF         STATUS,RP0
CODE:CODE:03c4  a000            MOVWF       0x20
CODE:CODE:03c5  6330            MOVLW       #0x63
CODE:CODE:03c6  8312            BCF         STATUS,RP0
CODE:CODE:03c7  c700            MOVWF       0x47
CODE:CODE:03c8  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:03c9  282c            GOTO        LAB_CODE_0428
CODE:CODE:03ca  cd01            CLRF        0x4d
                            LAB_CODE_03cb:                ;XREF[1,0]:   CODE:03d5
CODE:CODE:03cb  4d08            MOVF        0x4d,w
CODE:CODE:03cc  273e            ADDLW       #0x27
CODE:CODE:03cd  8400            MOVWF       FSR0L
CODE:CODE:03ce  8317            BSF         STATUS,IRP
CODE:CODE:03cf  2030            MOVLW       #0x20
CODE:CODE:03d0  8000            MOVWF       INDF0
CODE:CODE:03d1  cd0a            INCF        0x4d,f
CODE:CODE:03d2  0a30            MOVLW       #0xa
CODE:CODE:03d3  4d02            SUBWF       0x4d,w
CODE:CODE:03d4  031c            BTFSS       STATUS,#0x0
CODE:CODE:03d5  cb2b            GOTO        LAB_CODE_03cb
CODE:CODE:03d6  b61b            BTFSC       0x36,#0x7
CODE:CODE:03d7  1d2c            GOTO        LAB_CODE_041d
CODE:CODE:03d8  1f2c            GOTO        LAB_CODE_041f
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 14                                    *
                            ;************************************************************************************************
                            BGT_14:                       ;XREF[1,0]:   CODE:045d
CODE:CODE:03d9  0330            MOVLW       #0x3
CODE:CODE:03da  8316            BSF         STATUS,RP0
CODE:CODE:03db  a000            MOVWF       0x20
CODE:CODE:03dc  5930            MOVLW       #0x59
CODE:CODE:03dd  8312            BCF         STATUS,RP0
CODE:CODE:03de  c700            MOVWF       0x47
CODE:CODE:03df  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:03e0  282c            GOTO        LAB_CODE_0428
CODE:CODE:03e1  cd01            CLRF        0x4d
                            LAB_CODE_03e2:                ;XREF[1,0]:   CODE:03ec
CODE:CODE:03e2  4d08            MOVF        0x4d,w
CODE:CODE:03e3  273e            ADDLW       #0x27
CODE:CODE:03e4  8400            MOVWF       FSR0L
CODE:CODE:03e5  8317            BSF         STATUS,IRP
CODE:CODE:03e6  2030            MOVLW       #0x20
CODE:CODE:03e7  8000            MOVWF       INDF0
CODE:CODE:03e8  cd0a            INCF        0x4d,f
CODE:CODE:03e9  0a30            MOVLW       #0xa
CODE:CODE:03ea  4d02            SUBWF       0x4d,w
CODE:CODE:03eb  031c            BTFSS       STATUS,#0x0
CODE:CODE:03ec  e22b            GOTO        LAB_CODE_03e2
CODE:CODE:03ed  361d            BTFSS       0x36,#0x2
CODE:CODE:03ee  1f2c            GOTO        LAB_CODE_041f
CODE:CODE:03ef  1d2c            GOTO        LAB_CODE_041d
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 16                                    *
                            ;************************************************************************************************
                            BGT_16:                       ;XREF[1,0]:   CODE:045f
CODE:CODE:03f0  0330            MOVLW       #0x3
CODE:CODE:03f1  8316            BSF         STATUS,RP0
CODE:CODE:03f2  a000            MOVWF       0x20
CODE:CODE:03f3  3730            MOVLW       #0x37
CODE:CODE:03f4  8312            BCF         STATUS,RP0
CODE:CODE:03f5  c700            MOVWF       0x47
CODE:CODE:03f6  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:03f7  282c            GOTO        LAB_CODE_0428
CODE:CODE:03f8  cd01            CLRF        0x4d
                            LAB_CODE_03f9:                ;XREF[1,0]:   CODE:0403
CODE:CODE:03f9  4d08            MOVF        0x4d,w
CODE:CODE:03fa  273e            ADDLW       #0x27
CODE:CODE:03fb  8400            MOVWF       FSR0L
CODE:CODE:03fc  8317            BSF         STATUS,IRP
CODE:CODE:03fd  2030            MOVLW       #0x20
CODE:CODE:03fe  8000            MOVWF       INDF0
CODE:CODE:03ff  cd0a            INCF        0x4d,f
CODE:CODE:0400  0a30            MOVLW       #0xa
CODE:CODE:0401  4d02            SUBWF       0x4d,w
CODE:CODE:0402  031c            BTFSS       STATUS,#0x0
CODE:CODE:0403  f92b            GOTO        LAB_CODE_03f9
CODE:CODE:0404  b619            BTFSC       0x36,#0x3
CODE:CODE:0405  1d2c            GOTO        LAB_CODE_041d
CODE:CODE:0406  1f2c            GOTO        LAB_CODE_041f
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto entry 15                                    *
                            ;************************************************************************************************
                            BGT_15:                       ;XREF[1,0]:   CODE:045e
CODE:CODE:0407  0330            MOVLW       #0x3
CODE:CODE:0408  8316            BSF         STATUS,RP0
CODE:CODE:0409  a000            MOVWF       0x20
CODE:CODE:040a  5330            MOVLW       #0x53
CODE:CODE:040b  8312            BCF         STATUS,RP0
CODE:CODE:040c  c700            MOVWF       0x47
CODE:CODE:040d  ba1b            BTFSC       0x3a,#0x7
CODE:CODE:040e  282c            GOTO        LAB_CODE_0428
CODE:CODE:040f  cd01            CLRF        0x4d
                            LAB_CODE_0410:                ;XREF[1,0]:   CODE:041a
CODE:CODE:0410  4d08            MOVF        0x4d,w
CODE:CODE:0411  273e            ADDLW       #0x27
CODE:CODE:0412  8400            MOVWF       FSR0L
CODE:CODE:0413  8317            BSF         STATUS,IRP
CODE:CODE:0414  2030            MOVLW       #0x20
CODE:CODE:0415  8000            MOVWF       INDF0
CODE:CODE:0416  cd0a            INCF        0x4d,f
CODE:CODE:0417  0a30            MOVLW       #0xa
CODE:CODE:0418  4d02            SUBWF       0x4d,w
CODE:CODE:0419  031c            BTFSS       STATUS,#0x0
CODE:CODE:041a  102c            GOTO        LAB_CODE_0410
CODE:CODE:041b  361e            BTFSS       0x36,#0x4
CODE:CODE:041c  1f2c            GOTO        LAB_CODE_041f
                            LAB_CODE_041d:                ;XREF[3,0]:   CODE:03d7,CODE:03ef,CODE:0405
CODE:CODE:041d  2a30            MOVLW       #0x2a
CODE:CODE:041e  202c            GOTO        LAB_CODE_0420
                            LAB_CODE_041f:                ;XREF[4,0]:   CODE:03d8,CODE:03ee,CODE:0406,CODE:041c
CODE:CODE:041f  2030            MOVLW       #0x20
                            LAB_CODE_0420:                ;XREF[1,0]:   CODE:041e
CODE:CODE:0420  0317            BSF         STATUS,RP1
CODE:CODE:0421  a800            MOVWF       0x28
CODE:CODE:0422  0313            BCF         STATUS,RP1
CODE:CODE:0423  ac17            BSF         0x2c,#0x7
CODE:CODE:0424  4830            MOVLW       #0x48
                            LAB_CODE_0425:                ;XREF[2,0]:   CODE:02cd,CODE:03c1
CODE:CODE:0425  8316            BSF         STATUS,RP0
CODE:CODE:0426  b100            MOVWF       0x31
CODE:CODE:0427  652c            GOTO        BGT_18_RET
                            LAB_CODE_0428:                ;XREF[4,0]:   CODE:03c9,CODE:03e0,CODE:03f7,CODE:040e
CODE:CODE:0428  bb08            MOVF        BANK-0:DAT_DATA_003b,f                  ;= ??
CODE:CODE:0429  031d            BTFSS       STATUS,#0x2
CODE:CODE:042a  2d2c            GOTO        LAB_CODE_042d
                            LAB_CODE_042b:                ;XREF[1,0]:   CODE:02a2
CODE:CODE:042b  5430            MOVLW       #0x54
CODE:CODE:042c  2e2c            GOTO        LAB_CODE_042e
                            LAB_CODE_042d:                ;XREF[2,0]:   CODE:02a1,CODE:042a
CODE:CODE:042d  5530            MOVLW       #0x55
                            LAB_CODE_042e:                ;XREF[5,0]:   CODE:027a,CODE:030e,CODE:0318,CODE:0379
                                                          ;             CODE:042c
CODE:CODE:042e  c800            MOVWF       BANK-0:DAT_DATA_0048                    ;= ??
CODE:CODE:042f  652c            GOTO        BGT_18_RET
                            ;************************************************************************************************
                            ;*                                     START OF BGT1 SWITCH                                     *
                            ;************************************************************************************************
                            BGT1_pre:                     ;XREF[1,0]:   CODE:01f5
CODE:CODE:0430  8312            BCF         STATUS,RP0
CODE:CODE:0431  0313            BCF         STATUS,RP1
CODE:CODE:0432  3a08            MOVF        0x3a,w
CODE:CODE:0433  3f39            ANDLW       #0x3f
CODE:CODE:0434  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:0435  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:0436  612c            GOTO        BGT1_mid
                            BigGotoJumper:                ;XREF[1,0]:   CODE:0464
CODE:CODE:0437  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0438  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:0439  d63e            ADDLW       #0xd6
CODE:CODE:043a  0318            BTFSC       STATUS,#0x0
CODE:CODE:043b  652c            GOTO        BGT_18_RET
CODE:CODE:043c  193e            ADDLW       #0x19
CODE:CODE:043d  031c            BTFSS       STATUS,#0x0
CODE:CODE:043e  652c            GOTO        BGT_18_RET
CODE:CODE:043f  1130            MOVLW       #0x11
CODE:CODE:0440  f902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:0441  0430            MOVLW       #0x4
CODE:CODE:0442  8a00            MOVWF       PCLATH
CODE:CODE:0443  4830            MOVLW       #0x48
CODE:CODE:0444  7907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:0445  0318            BTFSC       STATUS,#0x0
CODE:CODE:0446  8a0a            INCF        PCLATH,f
                                                          ; FWD[25,0]:  CODE:0448,CODE:0449,CODE:044a,CODE:044b
                                                          ;             CODE:044c,CODE:044d,CODE:044e,CODE:044f
                                                          ;             CODE:0450,CODE:0451,CODE:0452,CODE:0453
                                                          ;             CODE:0454,CODE:0455,CODE:0456,CODE:0457
                                                          ;             CODE:0458,CODE:0459,CODE:045a,CODE:045b
                                                          ;             CODE:045c,CODE:045d,CODE:045e,CODE:045f
                                                          ;             CODE:0460
CODE:CODE:0447  8200            MOVWF       PC
                            LAB_CODE_0448:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0448  f629            GOTO        BGT_1
                            LAB_CODE_0449:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0449  6b2a            GOTO        BGT_2
                            LAB_CODE_044a:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044a  7b2a            GOTO        BGT_3
                            LAB_CODE_044b:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044b  ce2a            GOTO        BGT_4
                            LAB_CODE_044c:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044c  d32a            GOTO        BGT_5
                            LAB_CODE_044d:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044d  e82a            GOTO        BGT_6
                            LAB_CODE_044e:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044e  2a2b            GOTO        BGT_7
                            LAB_CODE_044f:                ;XREF[1,0]:   CODE:0447
CODE:CODE:044f  6b2b            GOTO        BGT_8
                            LAB_CODE_0450:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0450  702b            GOTO        BGT_9
                            LAB_CODE_0451:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0451  842b            GOTO        BGT_10
                            LAB_CODE_0452:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0452  9a2b            GOTO        BGT_11
                            LAB_CODE_0453:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0453  842b            GOTO        BGT_10
                            LAB_CODE_0454:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0454  9a2b            GOTO        BGT_11
                            LAB_CODE_0455:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0455  7a2b            GOTO        BGT_12
                            LAB_CODE_0456:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0456  c22b            GOTO        BGT_13
                            LAB_CODE_0457:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0457  652c            GOTO        BGT_18_RET
                            LAB_CODE_0458:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0458  652c            GOTO        BGT_18_RET
                            LAB_CODE_0459:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0459  652c            GOTO        BGT_18_RET
                            LAB_CODE_045a:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045a  652c            GOTO        BGT_18_RET
                            LAB_CODE_045b:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045b  652c            GOTO        BGT_18_RET
                            LAB_CODE_045c:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045c  652c            GOTO        BGT_18_RET
                            LAB_CODE_045d:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045d  d92b            GOTO        BGT_14
                            LAB_CODE_045e:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045e  072c            GOTO        BGT_15
                            LAB_CODE_045f:                ;XREF[1,0]:   CODE:0447
CODE:CODE:045f  f02b            GOTO        BGT_16
                            LAB_CODE_0460:                ;XREF[1,0]:   CODE:0447
CODE:CODE:0460  a32a            GOTO        BGT_17
                            BGT1_mid:                     ;XREF[1,0]:   CODE:0436
CODE:CODE:0461  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0462  003a            XORLW       #0x0
CODE:CODE:0463  0319            BTFSC       STATUS,#0x2
CODE:CODE:0464  372c            GOTO        BigGotoJumper
                            ;************************************************************************************************
                            ;*                                BigFuckingGoto entry 18/RETURN                                *
                            ;************************************************************************************************
                            BGT_18_RET:                   ;XREF[27,0]:  CODE:0211,CODE:0272,CODE:0297,CODE:029e
                                                          ;             CODE:02da,CODE:02f0,CODE:0306,CODE:0329
                                                          ;             CODE:0331,CODE:035b,CODE:036a,CODE:0377
                                                          ;             CODE:0381,CODE:038b,CODE:0397,CODE:03a1
                                                          ;             CODE:03ad,CODE:0427,CODE:042f,CODE:043b
                                                          ;             CODE:043e,CODE:0457,CODE:0458,CODE:0459
                                                          ;             CODE:045a,CODE:045b,CODE:045c
CODE:CODE:0465  8301            CLRF        STATUS
CODE:CODE:0466  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_MAYBE_CONFIG()
                                                          ;XREF[3,0]:   CODE:0687,CODE:1569,CODE:1575
CODE:CODE:0467  8301            CLRF        STATUS
CODE:CODE:0468  cf00            MOVWF       0x4f
CODE:CODE:0469  8316            BSF         STATUS,RP0
CODE:CODE:046a  8c12            BCF         0xc,#0x5
CODE:CODE:046b  8312            BCF         STATUS,RP0
CODE:CODE:046c  9801            CLRF        0x18
CODE:CODE:046d  8316            BSF         STATUS,RP0
CODE:CODE:046e  9801            CLRF        0x18
CODE:CODE:046f  8312            BCF         STATUS,RP0
CODE:CODE:0470  1a08            MOVF        0x1a,w
CODE:CODE:0471  cf08            MOVF        0x4f,f
CODE:CODE:0472  031d            BTFSS       STATUS,#0x2
CODE:CODE:0473  882c            GOTO        LAB_CODE_0488
CODE:CODE:0474  8316            BSF         STATUS,RP0
CODE:CODE:0475  9401            CLRF        0x14
CODE:CODE:0476  8312            BCF         STATUS,RP0
CODE:CODE:0477  9401            CLRF        0x14
CODE:CODE:0478  2f16            BSF         0x2f,#0x4
CODE:CODE:0479  0c30            MOVLW       #0xc
CODE:CODE:047a  8316            BSF         STATUS,RP0
CODE:CODE:047b  9900            MOVWF       0x19
CODE:CODE:047c  6130            MOVLW       #0x61
CODE:CODE:047d  9800            MOVWF       0x18
CODE:CODE:047e  9030            MOVLW       #0x90
CODE:CODE:047f  8312            BCF         STATUS,RP0
CODE:CODE:0480  9800            MOVWF       0x18
CODE:CODE:0481  1a08            MOVF        0x1a,w
CODE:CODE:0482  8316            BSF         STATUS,RP0
CODE:CODE:0483  8c16            BSF         0xc,#0x5
CODE:CODE:0484  0c12            BCF         0xc,#0x4
CODE:CODE:0485  8312            BCF         STATUS,RP0
CODE:CODE:0486  8711            BCF         FSR1H,#0x3
CODE:CODE:0487  0800            RETURN
                            LAB_CODE_0488:                ;XREF[1,0]:   CODE:0473
CODE:CODE:0488  2f12            BCF         BANK-0:ENTRY_DATA_UNK1,#0x4             ;= ??
CODE:CODE:0489  3230            MOVLW       #0x32
CODE:CODE:048a  9400            MOVWF       0x14
CODE:CODE:048b  8316            BSF         STATUS,RP0
CODE:CODE:048c  9401            CLRF        0x14
CODE:CODE:048d  8312            BCF         STATUS,RP0
CODE:CODE:048e  8715            BSF         FSR1H,#0x3
CODE:CODE:048f  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_MAYBE_CHECKSUM(undefined1 buffer_addr)
          ;buffer_addr   undefined1           W
                                                          ;XREF[6,0]:   CODE:04c4,CODE:04eb,CODE:0524,CODE:05a7
                                                          ;             CODE:05cf,CODE:0691
CODE:CODE:0490  8301            CLRF        STATUS
CODE:CODE:0491  d400            MOVWF       BANK-0:INIT_ST1_UNK3                    ;= ??
CODE:CODE:0492  5530            MOVLW       #0x55
CODE:CODE:0493  d500            MOVWF       BANK-0:DAT_DATA_0055                    ;= ??
CODE:CODE:0494  d601            CLRF        BANK-0:DAT_DATA_0056                    ;= ??
CODE:CODE:0495  a72c            GOTO        LAB_CODE_04a7
                            LAB_CODE_0496:                ;XREF[1,0]:   CODE:04aa
CODE:CODE:0496  d308            MOVF        BANK-0:INIT_ST1_UNK2,f                  ;= ??
CODE:CODE:0497  031d            BTFSS       STATUS,#0x2
CODE:CODE:0498  a02c            GOTO        LAB_CODE_04a0
CODE:CODE:0499  5608            MOVF        BANK-0:DAT_DATA_0056,w                  ;= ??
CODE:CODE:049a  5407            ADDWF       BANK-0:INIT_ST1_UNK3,w                  ;= ??
CODE:CODE:049b  8400            MOVWF       FSR0L
CODE:CODE:049c  8317            BSF         STATUS,IRP
CODE:CODE:049d  0008            MOVF        INDF0,w
CODE:CODE:049e  d506            XORWF       BANK-0:DAT_DATA_0055,f                  ;= ??
CODE:CODE:049f  a62c            GOTO        LAB_CODE_04a6
                            LAB_CODE_04a0:                ;XREF[1,0]:   CODE:0498
CODE:CODE:04a0  5608            MOVF        BANK-0:DAT_DATA_0056,w                  ;= ??
CODE:CODE:04a1  5407            ADDWF       BANK-0:INIT_ST1_UNK3,w                  ;= ??
CODE:CODE:04a2  8400            MOVWF       FSR0L
CODE:CODE:04a3  8317            BSF         STATUS,IRP
CODE:CODE:04a4  0008            MOVF        INDF0,w
CODE:CODE:04a5  d507            ADDWF       BANK-0:DAT_DATA_0055,f                  ;= ??
                            LAB_CODE_04a6:                ;XREF[1,0]:   CODE:049f
CODE:CODE:04a6  d60a            INCF        BANK-0:DAT_DATA_0056,f                  ;= ??
                            LAB_CODE_04a7:                ;XREF[1,0]:   CODE:0495
CODE:CODE:04a7  5208            MOVF        BANK-0:INIT_ST1_UNK1,w                  ;= ??
CODE:CODE:04a8  5602            SUBWF       BANK-0:DAT_DATA_0056,w                  ;= ??
CODE:CODE:04a9  031c            BTFSS       STATUS,#0x0
CODE:CODE:04aa  962c            GOTO        LAB_CODE_0496
CODE:CODE:04ab  5508            MOVF        BANK-0:DAT_DATA_0055,w                  ;= ??
CODE:CODE:04ac  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_PACKET_SEND_1()
                                                          ;XREF[1,0]:   CODE:070b
CODE:CODE:04ad  a030            MOVLW       #0xa0
CODE:CODE:04ae  8312            BCF         STATUS,RP0
CODE:CODE:04af  0317            BSF         STATUS,RP1
CODE:CODE:04b0  d700            MOVWF       0x57
CODE:CODE:04b1  0530            MOVLW       #0x5
CODE:CODE:04b2  d800            MOVWF       0x58
CODE:CODE:04b3  8316            BSF         STATUS,RP0
CODE:CODE:04b4  0313            BCF         STATUS,RP1
CODE:CODE:04b5  5808            MOVF        0x58,w
CODE:CODE:04b6  8312            BCF         STATUS,RP0
CODE:CODE:04b7  0317            BSF         STATUS,RP1
CODE:CODE:04b8  da00            MOVWF       0x5a
CODE:CODE:04b9  8316            BSF         STATUS,RP0
CODE:CODE:04ba  0313            BCF         STATUS,RP1
CODE:CODE:04bb  5708            MOVF        0x57,w
CODE:CODE:04bc  8312            BCF         STATUS,RP0
CODE:CODE:04bd  0317            BSF         STATUS,RP1
CODE:CODE:04be  db00            MOVWF       0x5b
CODE:CODE:04bf  5808            MOVF        0x58,w
CODE:CODE:04c0  0313            BCF         STATUS,RP1
CODE:CODE:04c1  d200            MOVWF       0x52
CODE:CODE:04c2  d301            CLRF        0x53
CODE:CODE:04c3  5730            MOVLW       #0x57
CODE:CODE:04c4  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:04c5  0317            BSF         STATUS,RP1
CODE:CODE:04c6  dc00            MOVWF       0x5c
CODE:CODE:04c7  580a            INCF        0x58,w
CODE:CODE:04c8  8316            BSF         STATUS,RP0
CODE:CODE:04c9  0313            BCF         STATUS,RP1
CODE:CODE:04ca  c500            MOVWF       0x45
CODE:CODE:04cb  8312            BCF         STATUS,RP0
CODE:CODE:04cc  2d15            BSF         0x2d,#0x2
CODE:CODE:04cd  8316            BSF         STATUS,RP0
CODE:CODE:04ce  c401            CLRF        0x44
CODE:CODE:04cf  c40a            INCF        0x44,f
CODE:CODE:04d0  8312            BCF         STATUS,RP0
CODE:CODE:04d1  0317            BSF         STATUS,RP1
CODE:CODE:04d2  5708            MOVF        0x57,w
CODE:CODE:04d3  0313            BCF         STATUS,RP1
CODE:CODE:04d4  9900            MOVWF       0x19
CODE:CODE:04d5  8316            BSF         STATUS,RP0
CODE:CODE:04d6  0c16            BSF         0xc,#0x4
CODE:CODE:04d7  8312            BCF         STATUS,RP0
CODE:CODE:04d8  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_PACKET_SEND_2()
                            ;THIS SENDS DATA ON THE USART
                                                          ;XREF[2,0]:   CODE:06cd,CODE:06df
CODE:CODE:04d9  8301            CLRF        STATUS
CODE:CODE:04da  cf00            MOVWF       BANK-0:DAT_DATA_004f                    ;= ??
CODE:CODE:04db  a030            MOVLW       #0xa0
CODE:CODE:04dc  0317            BSF         STATUS,RP1
CODE:CODE:04dd  d700            MOVWF       BANK-2:USART_PACKET_BUFFER              ;= ??
CODE:CODE:04de  0630            MOVLW       #0x6
CODE:CODE:04df  d800            MOVWF       BANK-2:USART_PACKET_BUFFER[1]
CODE:CODE:04e0  8530            MOVLW       #0x85
CODE:CODE:04e1  d900            MOVWF       BANK-2:USART_PACKET_BUFFER[2]
CODE:CODE:04e2  0313            BCF         STATUS,RP1
CODE:CODE:04e3  4f08            MOVF        BANK-0:DAT_DATA_004f,w                  ;= ??
CODE:CODE:04e4  0317            BSF         STATUS,RP1
                            ;apparently this contains the parameter
CODE:CODE:04e5  dc00            MOVWF       BANK-2:USART_PACKET_BUFFER[5]
CODE:CODE:04e6  5808            MOVF        BANK-2:USART_PACKET_BUFFER[1],w
CODE:CODE:04e7  0313            BCF         STATUS,RP1
CODE:CODE:04e8  d200            MOVWF       BANK-0:INIT_ST1_UNK1                    ;= ??
CODE:CODE:04e9  d301            CLRF        BANK-0:INIT_ST1_UNK2                    ;= ??
CODE:CODE:04ea  5730            MOVLW       #0x57
CODE:CODE:04eb  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:04ec  0317            BSF         STATUS,RP1
CODE:CODE:04ed  dd00            MOVWF       BANK-2:USART_PACKET_BUFFER[6]
CODE:CODE:04ee  580a            INCF        BANK-2:USART_PACKET_BUFFER[1],w
CODE:CODE:04ef  8316            BSF         STATUS,RP0
CODE:CODE:04f0  0313            BCF         STATUS,RP1
CODE:CODE:04f1  c500            MOVWF       BANK-1:USART_TX_PACKET_SIZE             ;= ??
CODE:CODE:04f2  8312            BCF         STATUS,RP0
CODE:CODE:04f3  2d15            BSF         BANK-0:USART_RX_PACKET_STATUS,#0x2      ;= ??
CODE:CODE:04f4  8316            BSF         STATUS,RP0
CODE:CODE:04f5  c401            CLRF        BANK-1:USART_TX_BUFFER_INDEX            ;= ??
CODE:CODE:04f6  c40a            INCF        BANK-1:USART_TX_BUFFER_INDEX,f          ;= ??
CODE:CODE:04f7  8312            BCF         STATUS,RP0
CODE:CODE:04f8  0317            BSF         STATUS,RP1
CODE:CODE:04f9  5708            MOVF        BANK-2:USART_PACKET_BUFFER,w            ;= ??
CODE:CODE:04fa  0313            BCF         STATUS,RP1
CODE:CODE:04fb  9900            MOVWF       BANK-0:TXREG                            ;= ??
CODE:CODE:04fc  8316            BSF         STATUS,RP0
CODE:CODE:04fd  0c16            BSF         BANK-1:PIE1,#0x4                        ;= ??
CODE:CODE:04fe  8312            BCF         STATUS,RP0
CODE:CODE:04ff  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_PACKET_SEND_3()
                            ;CE TRUC ENVOIT UN PAQUET USART
                                                          ;XREF[1,0]:   CODE:06fe
CODE:CODE:0500  a030            MOVLW       #0xa0
CODE:CODE:0501  8312            BCF         STATUS,RP0
CODE:CODE:0502  0317            BSF         STATUS,RP1
CODE:CODE:0503  d700            MOVWF       0x57
CODE:CODE:0504  1530            MOVLW       #0x15
CODE:CODE:0505  d800            MOVWF       0x58
CODE:CODE:0506  9530            MOVLW       #0x95
CODE:CODE:0507  d900            MOVWF       0x59
CODE:CODE:0508  5a08            MOVF        0x5a,w
CODE:CODE:0509  5b08            MOVF        0x5b,w
CODE:CODE:050a  0313            BCF         STATUS,RP1
CODE:CODE:050b  cf01            CLRF        0x4f
                            LAB_CODE_050c:                ;XREF[1,0]:   CODE:051d
CODE:CODE:050c  4f08            MOVF        0x4f,w
CODE:CODE:050d  473e            ADDLW       #0x47
CODE:CODE:050e  8400            MOVWF       FSR0L
CODE:CODE:050f  8317            BSF         STATUS,IRP
CODE:CODE:0510  0008            MOVF        INDF0,w
CODE:CODE:0511  d000            MOVWF       0x50
CODE:CODE:0512  4f08            MOVF        0x4f,w
CODE:CODE:0513  053e            ADDLW       #0x5
CODE:CODE:0514  573e            ADDLW       #0x57
CODE:CODE:0515  8400            MOVWF       FSR0L
CODE:CODE:0516  8317            BSF         STATUS,IRP
CODE:CODE:0517  5008            MOVF        0x50,w
CODE:CODE:0518  8000            MOVWF       INDF0
CODE:CODE:0519  cf0a            INCF        0x4f,f
CODE:CODE:051a  1030            MOVLW       #0x10
CODE:CODE:051b  4f02            SUBWF       0x4f,w
CODE:CODE:051c  031c            BTFSS       STATUS,#0x0
CODE:CODE:051d  0c2d            GOTO        LAB_CODE_050c
CODE:CODE:051e  0317            BSF         STATUS,RP1
CODE:CODE:051f  5808            MOVF        0x58,w
CODE:CODE:0520  0313            BCF         STATUS,RP1
CODE:CODE:0521  d200            MOVWF       0x52
CODE:CODE:0522  d301            CLRF        0x53
CODE:CODE:0523  5730            MOVLW       #0x57
CODE:CODE:0524  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:0525  d000            MOVWF       0x50
CODE:CODE:0526  4f08            MOVF        0x4f,w
CODE:CODE:0527  053e            ADDLW       #0x5
CODE:CODE:0528  573e            ADDLW       #0x57
CODE:CODE:0529  8400            MOVWF       FSR0L
CODE:CODE:052a  8317            BSF         STATUS,IRP
CODE:CODE:052b  5008            MOVF        0x50,w
CODE:CODE:052c  8000            MOVWF       INDF0
CODE:CODE:052d  0317            BSF         STATUS,RP1
CODE:CODE:052e  580a            INCF        0x58,w
CODE:CODE:052f  8316            BSF         STATUS,RP0
CODE:CODE:0530  0313            BCF         STATUS,RP1
CODE:CODE:0531  c500            MOVWF       0x45
CODE:CODE:0532  8312            BCF         STATUS,RP0
CODE:CODE:0533  2d15            BSF         0x2d,#0x2
CODE:CODE:0534  8316            BSF         STATUS,RP0
CODE:CODE:0535  c401            CLRF        0x44
CODE:CODE:0536  c40a            INCF        0x44,f
CODE:CODE:0537  8312            BCF         STATUS,RP0
CODE:CODE:0538  0317            BSF         STATUS,RP1
CODE:CODE:0539  5708            MOVF        0x57,w
CODE:CODE:053a  0313            BCF         STATUS,RP1
CODE:CODE:053b  9900            MOVWF       0x19
CODE:CODE:053c  8316            BSF         STATUS,RP0
CODE:CODE:053d  0c16            BSF         0xc,#0x4
CODE:CODE:053e  8312            BCF         STATUS,RP0
CODE:CODE:053f  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined SSP_SEND_1()
          ;tmp_PIR1      undefined1     HASH...
                                                          ;XREF[1,0]:   CODE:05c4
CODE:CODE:0540  8316            BSF         STATUS,RP0
CODE:CODE:0541  0313            BCF         STATUS,RP1
CODE:CODE:0542  ad08            MOVF        BANK-1:SSP_UNK4,f                       ;= ??
CODE:CODE:0543  0319            BTFSC       STATUS,#0x2
CODE:CODE:0544  512d            GOTO        LAB_CODE_0551
CODE:CODE:0545  330f            INCFSZ      BANK-1:ENTRY_DATA_UNK2,w                ;= ??
CODE:CODE:0546  512d            GOTO        LAB_CODE_0551
CODE:CODE:0547  8312            BCF         STATUS,RP0
CODE:CODE:0548  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:0549  3f39            ANDLW       #0x3f
CODE:CODE:054a  031d            BTFSS       STATUS,#0x2
CODE:CODE:054b  4e2d            GOTO        LAB_CODE_054e
CODE:CODE:054c  3e1c            BTFSS       BANK-0:DAT_DATA_003e,#0x0               ;= ??
CODE:CODE:054d  512d            GOTO        LAB_CODE_0551
                            LAB_CODE_054e:                ;XREF[1,0]:   CODE:054b
CODE:CODE:054e  0a30            MOVLW       #0xa
CODE:CODE:054f  8316            BSF         STATUS,RP0
CODE:CODE:0550  b300            MOVWF       BANK-1:ENTRY_DATA_UNK2                  ;= ??
                            LAB_CODE_0551:                ;XREF[3,0]:   CODE:0544,CODE:0546,CODE:054d
CODE:CODE:0551  8316            BSF         STATUS,RP0
CODE:CODE:0552  ad08            MOVF        BANK-1:SSP_UNK4,f                       ;= ??
CODE:CODE:0553  031d            BTFSS       STATUS,#0x2
CODE:CODE:0554  5a2d            GOTO        LAB_CODE_055a
CODE:CODE:0555  b308            MOVF        BANK-1:ENTRY_DATA_UNK2,f                ;= ??
CODE:CODE:0556  031d            BTFSS       STATUS,#0x2
CODE:CODE:0557  5a2d            GOTO        LAB_CODE_055a
CODE:CODE:0558  ff30            MOVLW       #0xff
CODE:CODE:0559  b300            MOVWF       BANK-1:ENTRY_DATA_UNK2                  ;= ??
                            LAB_CODE_055a:                ;XREF[2,0]:   CODE:0554,CODE:0557
CODE:CODE:055a  8312            BCF         STATUS,RP0
CODE:CODE:055b  2508            MOVF        BANK-0:DAT_DATA_0025,w                  ;= ??
CODE:CODE:055c  cf00            MOVWF       BANK-0:DAT_DATA_004f                    ;= ??
CODE:CODE:055d  2608            MOVF        BANK-0:DAT_DATA_0026,w                  ;= ??
CODE:CODE:055e  d000            MOVWF       BANK-0:DAT_DATA_0050                    ;= ??
CODE:CODE:055f  b030            MOVLW       #0xb0
CODE:CODE:0560  0317            BSF         STATUS,RP1
CODE:CODE:0561  bc00            MOVWF       BANK-2:SSP_BYTE_TOSEND                  ;= ??
CODE:CODE:0562  0313            BCF         STATUS,RP1
CODE:CODE:0563  4f08            MOVF        BANK-0:DAT_DATA_004f,w                  ;= ??
CODE:CODE:0564  0317            BSF         STATUS,RP1
CODE:CODE:0565  bd00            MOVWF       BANK-2:DAT_BANK-2__003d                 ;= ??
CODE:CODE:0566  2008            MOVF        BANK-2:DAT_BANK-2__0020,w               ;= ??
CODE:CODE:0567  be00            MOVWF       BANK-2:DAT_BANK-2__003e                 ;= ??
CODE:CODE:0568  1430            MOVLW       #0x14
CODE:CODE:0569  bf00            MOVWF       BANK-2:DAT_BANK-2__003f                 ;= ??
CODE:CODE:056a  0830            MOVLW       #0x8
CODE:CODE:056b  0313            BCF         STATUS,RP1
CODE:CODE:056c  af06            XORWF       BANK-0:ENTRY_DATA_UNK1,f                ;= ??
CODE:CODE:056d  8316            BSF         STATUS,RP0
CODE:CODE:056e  2108            MOVF        BANK-1:DAT_BANK-1__0021,w               ;= ??
CODE:CODE:056f  0a16            BSF         PCLATH,#0x4
CODE:CODE:0570  8a11            BCF         PCLATH,#0x3
CODE:CODE:0571  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:0572  0317            BSF         STATUS,RP1
CODE:CODE:0573  c000            MOVWF       BANK-2:DAT_BANK-2__0040                 ;= ??
CODE:CODE:0574  8316            BSF         STATUS,RP0
CODE:CODE:0575  0313            BCF         STATUS,RP1
CODE:CODE:0576  2b08            MOVF        BANK-1:DAT_BANK-1__002b,w               ;= ??
CODE:CODE:0577  0a16            BSF         PCLATH,#0x4
CODE:CODE:0578  8a11            BCF         PCLATH,#0x3
CODE:CODE:0579  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:057a  0317            BSF         STATUS,RP1
CODE:CODE:057b  c100            MOVWF       BANK-2:DAT_BANK-2__0041                 ;= ??
CODE:CODE:057c  8316            BSF         STATUS,RP0
CODE:CODE:057d  0313            BCF         STATUS,RP1
CODE:CODE:057e  2e08            MOVF        BANK-1:DAT_BANK-1__002e,w               ;= ??
CODE:CODE:057f  0a16            BSF         PCLATH,#0x4
CODE:CODE:0580  8a11            BCF         PCLATH,#0x3
CODE:CODE:0581  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:0582  0a12            BCF         PCLATH,#0x4
CODE:CODE:0583  8a11            BCF         PCLATH,#0x3
CODE:CODE:0584  0317            BSF         STATUS,RP1
CODE:CODE:0585  c200            MOVWF       BANK-2:DAT_BANK-2__0042                 ;= ??
CODE:CODE:0586  8316            BSF         STATUS,RP0
CODE:CODE:0587  0313            BCF         STATUS,RP1
CODE:CODE:0588  2d08            MOVF        BANK-1:SSP_UNK4,w                       ;= ??
CODE:CODE:0589  8312            BCF         STATUS,RP0
CODE:CODE:058a  d100            MOVWF       BANK-0:DAT_DATA_0051                    ;= ??
CODE:CODE:058b  0310            BCF         STATUS,C
CODE:CODE:058c  d10d            RLF         BANK-0:DAT_DATA_0051,f                  ;= ??
CODE:CODE:058d  0310            BCF         STATUS,C
CODE:CODE:058e  d10d            RLF         BANK-0:DAT_DATA_0051,f                  ;= ??
CODE:CODE:058f  0310            BCF         STATUS,C
CODE:CODE:0590  510d            RLF         BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:0591  5004            IORWF       BANK-0:DAT_DATA_0050,w                  ;= ??
CODE:CODE:0592  0317            BSF         STATUS,RP1
CODE:CODE:0593  c300            MOVWF       BANK-2:DAT_BANK-2__0043                 ;= ??
CODE:CODE:0594  0313            BCF         STATUS,RP1
CODE:CODE:0595  2e1f            BTFSS       BANK-0:DAT_DATA_002e,#0x6               ;= ??
CODE:CODE:0596  992d            GOTO        LAB_CODE_0599
CODE:CODE:0597  0317            BSF         STATUS,RP1
CODE:CODE:0598  c317            BSF         BANK-2:DAT_BANK-2__0043,#0x7            ;= ??
                            LAB_CODE_0599:                ;XREF[1,0]:   CODE:0596
CODE:CODE:0599  8316            BSF         STATUS,RP0
CODE:CODE:059a  0313            BCF         STATUS,RP1
CODE:CODE:059b  2a08            MOVF        BANK-1:DAT_BANK-1__002a,w               ;= ??
CODE:CODE:059c  8312            BCF         STATUS,RP0
CODE:CODE:059d  0317            BSF         STATUS,RP1
CODE:CODE:059e  c400            MOVWF       BANK-2:DAT_BANK-2__0044                 ;= ??
CODE:CODE:059f  2108            MOVF        BANK-2:DAT_BANK-2__0021,w               ;= ??
CODE:CODE:05a0  c500            MOVWF       BANK-2:DAT_BANK-2__0045                 ;= ??
CODE:CODE:05a1  0a30            MOVLW       #0xa
CODE:CODE:05a2  0313            BCF         STATUS,RP1
CODE:CODE:05a3  d200            MOVWF       BANK-0:INIT_ST1_UNK1                    ;= ??
CODE:CODE:05a4  ff30            MOVLW       #0xff
CODE:CODE:05a5  d300            MOVWF       BANK-0:INIT_ST1_UNK2                    ;= ??
CODE:CODE:05a6  3c30            MOVLW       #0x3c
CODE:CODE:05a7  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:05a8  0317            BSF         STATUS,RP1
CODE:CODE:05a9  c600            MOVWF       BANK-2:DAT_BANK-2__0046                 ;= ??
CODE:CODE:05aa  0b30            MOVLW       #0xb
CODE:CODE:05ab  0313            BCF         STATUS,RP1
CODE:CODE:05ac  c100            MOVWF       BANK-0:SSP_UNK1_PACKET_SIZE_MAX         ;= ??
CODE:CODE:05ad  2d16            BSF         BANK-0:USART_RX_PACKET_STATUS,#0x4      ;= ??
CODE:CODE:05ae  8c11            BCF         BANK-0:PIR1,#0x3                        ;= ??
CODE:CODE:05af  c001            CLRF        BANK-0:SSP_PACKET_SIZE                  ;= ??
CODE:CODE:05b0  0317            BSF         STATUS,RP1
CODE:CODE:05b1  3c08            MOVF        BANK-2:SSP_BYTE_TOSEND,w                ;= ??
CODE:CODE:05b2  0313            BCF         STATUS,RP1
CODE:CODE:05b3  9300            MOVWF       BANK-0:SSPBUF                           ;= ??
CODE:CODE:05b4  8316            BSF         STATUS,RP0
CODE:CODE:05b5  8c15            BSF         BANK-1:PIE1,#0x3                        ;= ??
CODE:CODE:05b6  8312            BCF         STATUS,RP0
CODE:CODE:05b7  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined USART_MAYBE_LOGIC()
                                                          ;XREF[1,0]:   CODE:1037
CODE:CODE:05b8  6400            CLRWDT
CODE:CODE:05b9  8316            BSF         STATUS,RP0
CODE:CODE:05ba  0313            BCF         STATUS,RP1
CODE:CODE:05bb  bd08            MOVF        0x3d,f
CODE:CODE:05bc  031d            BTFSS       STATUS,#0x2
CODE:CODE:05bd  c72d            GOTO        LAB_CODE_05c7
CODE:CODE:05be  8312            BCF         STATUS,RP0
CODE:CODE:05bf  2f1a            BTFSC       0x2f,#0x4
CODE:CODE:05c0  c72d            GOTO        LAB_CODE_05c7
CODE:CODE:05c1  0630            MOVLW       #0x6
CODE:CODE:05c2  8316            BSF         STATUS,RP0
CODE:CODE:05c3  bd00            MOVWF       0x3d
CODE:CODE:05c4  4025            CALL        SSP_SEND_1                              ;undefined SSP_SEND_1()
CODE:CODE:05c5  0a12            BCF         PCLATH,#0x4
CODE:CODE:05c6  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_05c7:                ;XREF[2,0]:   CODE:05bd,CODE:05c0
CODE:CODE:05c7  8312            BCF         STATUS,RP0
CODE:CODE:05c8  ad1e            BTFSS       BANK-0:USART_RX_PACKET_STATUS,#0x5      ;= ??
CODE:CODE:05c9  6b2e            GOTO        LAB_CODE_066b
CODE:CODE:05ca  0a30            MOVLW       #0xa
CODE:CODE:05cb  d200            MOVWF       BANK-0:INIT_ST1_UNK1                    ;= ??
CODE:CODE:05cc  ff30            MOVLW       #0xff
CODE:CODE:05cd  d300            MOVWF       BANK-0:INIT_ST1_UNK2                    ;= ??
CODE:CODE:05ce  3130            MOVLW       #0x31
CODE:CODE:05cf  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:05d0  cb00            MOVWF       0x4b
CODE:CODE:05d1  cc01            CLRF        0x4c
CODE:CODE:05d2  0317            BSF         STATUS,RP1
CODE:CODE:05d3  3b08            MOVF        0x3b,w
CODE:CODE:05d4  0313            BCF         STATUS,RP1
CODE:CODE:05d5  cd00            MOVWF       0x4d
CODE:CODE:05d6  ce01            CLRF        0x4e
CODE:CODE:05d7  4c08            MOVF        0x4c,w
CODE:CODE:05d8  4e06            XORWF       0x4e,w
CODE:CODE:05d9  031d            BTFSS       STATUS,#0x2
CODE:CODE:05da  dd2d            GOTO        LAB_CODE_05dd
CODE:CODE:05db  4b08            MOVF        0x4b,w
CODE:CODE:05dc  4d06            XORWF       0x4d,w
                            LAB_CODE_05dd:                ;XREF[1,0]:   CODE:05da
CODE:CODE:05dd  031d            BTFSS       STATUS,#0x2
CODE:CODE:05de  692e            GOTO        LAB_CODE_0669
CODE:CODE:05df  0317            BSF         STATUS,RP1
CODE:CODE:05e0  3108            MOVF        0x31,w
CODE:CODE:05e1  0b3a            XORLW       #0xb
CODE:CODE:05e2  031d            BTFSS       STATUS,#0x2
CODE:CODE:05e3  692e            GOTO        LAB_CODE_0669
CODE:CODE:05e4  3208            MOVF        0x32,w
CODE:CODE:05e5  0313            BCF         STATUS,RP1
CODE:CODE:05e6  ba00            MOVWF       0x3a
CODE:CODE:05e7  0317            BSF         STATUS,RP1
CODE:CODE:05e8  3308            MOVF        BANK-2:SSP_BUFFER[2],w
CODE:CODE:05e9  0313            BCF         STATUS,RP1
CODE:CODE:05ea  bb00            MOVWF       0x3b
CODE:CODE:05eb  0317            BSF         STATUS,RP1
CODE:CODE:05ec  3408            MOVF        0x34,w
CODE:CODE:05ed  0313            BCF         STATUS,RP1
CODE:CODE:05ee  bc00            MOVWF       0x3c
CODE:CODE:05ef  0317            BSF         STATUS,RP1
CODE:CODE:05f0  3508            MOVF        0x35,w
CODE:CODE:05f1  0313            BCF         STATUS,RP1
CODE:CODE:05f2  b600            MOVWF       0x36
CODE:CODE:05f3  0317            BSF         STATUS,RP1
CODE:CODE:05f4  3608            MOVF        0x36,w
CODE:CODE:05f5  0313            BCF         STATUS,RP1
CODE:CODE:05f6  b700            MOVWF       0x37
CODE:CODE:05f7  0317            BSF         STATUS,RP1
CODE:CODE:05f8  3708            MOVF        0x37,w
CODE:CODE:05f9  0313            BCF         STATUS,RP1
CODE:CODE:05fa  a300            MOVWF       0x23
CODE:CODE:05fb  0317            BSF         STATUS,RP1
CODE:CODE:05fc  3808            MOVF        0x38,w
CODE:CODE:05fd  0313            BCF         STATUS,RP1
CODE:CODE:05fe  aa00            MOVWF       0x2a
CODE:CODE:05ff  0317            BSF         STATUS,RP1
CODE:CODE:0600  3908            MOVF        0x39,w
CODE:CODE:0601  0313            BCF         STATUS,RP1
CODE:CODE:0602  ab00            MOVWF       0x2b
CODE:CODE:0603  0317            BSF         STATUS,RP1
CODE:CODE:0604  3908            MOVF        0x39,w
CODE:CODE:0605  0339            ANDLW       #0x3
CODE:CODE:0606  0313            BCF         STATUS,RP1
CODE:CODE:0607  b900            MOVWF       0x39
CODE:CODE:0608  0317            BSF         STATUS,RP1
CODE:CODE:0609  3908            MOVF        0x39,w
CODE:CODE:060a  1c39            ANDLW       #0x1c
CODE:CODE:060b  0313            BCF         STATUS,RP1
CODE:CODE:060c  cb00            MOVWF       0x4b
CODE:CODE:060d  0310            BCF         STATUS,C
CODE:CODE:060e  cb0c            RRF         0x4b,f
CODE:CODE:060f  0310            BCF         STATUS,C
CODE:CODE:0610  4b0c            RRF         0x4b,w
CODE:CODE:0611  b800            MOVWF       0x38
CODE:CODE:0612  371e            BTFSS       0x37,#0x4
CODE:CODE:0613  162e            GOTO        LAB_CODE_0616
CODE:CODE:0614  8513            BCF         FSR0H,#0x7
CODE:CODE:0615  172e            GOTO        LAB_CODE_0617
                            LAB_CODE_0616:                ;XREF[1,0]:   CODE:0613
CODE:CODE:0616  8517            BSF         FSR0H,#0x7
                            LAB_CODE_0617:                ;XREF[1,0]:   CODE:0615
CODE:CODE:0617  3a08            MOVF        0x3a,w
CODE:CODE:0618  3f39            ANDLW       #0x3f
CODE:CODE:0619  213a            XORLW       #0x21
CODE:CODE:061a  0319            BTFSC       STATUS,#0x2
CODE:CODE:061b  1f2e            GOTO        LAB_CODE_061f
CODE:CODE:061c  0317            BSF         STATUS,RP1
CODE:CODE:061d  3a08            MOVF        0x3a,w
CODE:CODE:061e  a300            MOVWF       0x23
                            LAB_CODE_061f:                ;XREF[1,0]:   CODE:061b
CODE:CODE:061f  0313            BCF         STATUS,RP1
CODE:CODE:0620  3a08            MOVF        0x3a,w
CODE:CODE:0621  243a            XORLW       #0x24
CODE:CODE:0622  031d            BTFSS       STATUS,#0x2
CODE:CODE:0623  2f2e            GOTO        LAB_CODE_062f
CODE:CODE:0624  3b08            MOVF        0x3b,w
CODE:CODE:0625  8316            BSF         STATUS,RP0
CODE:CODE:0626  dc00            MOVWF       0x5c
CODE:CODE:0627  8312            BCF         STATUS,RP0
CODE:CODE:0628  3c08            MOVF        0x3c,w
CODE:CODE:0629  8316            BSF         STATUS,RP0
CODE:CODE:062a  db00            MOVWF       0x5b
CODE:CODE:062b  e300            MOVWF       0x63
CODE:CODE:062c  5c08            MOVF        0x5c,w
CODE:CODE:062d  e400            MOVWF       0x64
CODE:CODE:062e  582e            GOTO        LAB_CODE_0658
                            LAB_CODE_062f:                ;XREF[1,0]:   CODE:0623
CODE:CODE:062f  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:0630  253a            XORLW       #0x25
CODE:CODE:0631  031d            BTFSS       STATUS,#0x2
CODE:CODE:0632  3e2e            GOTO        LAB_CODE_063e
CODE:CODE:0633  3b08            MOVF        0x3b,w
CODE:CODE:0634  8316            BSF         STATUS,RP0
CODE:CODE:0635  dc00            MOVWF       0x5c
CODE:CODE:0636  8312            BCF         STATUS,RP0
CODE:CODE:0637  3c08            MOVF        0x3c,w
CODE:CODE:0638  8316            BSF         STATUS,RP0
CODE:CODE:0639  db00            MOVWF       0x5b
CODE:CODE:063a  dd00            MOVWF       0x5d
CODE:CODE:063b  5c08            MOVF        0x5c,w
CODE:CODE:063c  de00            MOVWF       0x5e
CODE:CODE:063d  582e            GOTO        LAB_CODE_0658
                            LAB_CODE_063e:                ;XREF[1,0]:   CODE:0632
CODE:CODE:063e  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:063f  263a            XORLW       #0x26
CODE:CODE:0640  031d            BTFSS       STATUS,#0x2
CODE:CODE:0641  4a2e            GOTO        LAB_CODE_064a
CODE:CODE:0642  3b08            MOVF        0x3b,w
CODE:CODE:0643  8316            BSF         STATUS,RP0
CODE:CODE:0644  c100            MOVWF       0x41
CODE:CODE:0645  8312            BCF         STATUS,RP0
CODE:CODE:0646  3c08            MOVF        0x3c,w
CODE:CODE:0647  8316            BSF         STATUS,RP0
CODE:CODE:0648  c600            MOVWF       0x46
CODE:CODE:0649  582e            GOTO        LAB_CODE_0658
                            LAB_CODE_064a:                ;XREF[1,0]:   CODE:0641
CODE:CODE:064a  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:064b  273a            XORLW       #0x27
CODE:CODE:064c  031d            BTFSS       STATUS,#0x2
CODE:CODE:064d  582e            GOTO        LAB_CODE_0658
CODE:CODE:064e  3b08            MOVF        0x3b,w
CODE:CODE:064f  8316            BSF         STATUS,RP0
CODE:CODE:0650  dc00            MOVWF       0x5c
CODE:CODE:0651  8312            BCF         STATUS,RP0
CODE:CODE:0652  3c08            MOVF        0x3c,w
CODE:CODE:0653  8316            BSF         STATUS,RP0
CODE:CODE:0654  db00            MOVWF       0x5b
CODE:CODE:0655  e100            MOVWF       0x61
CODE:CODE:0656  5c08            MOVF        0x5c,w
CODE:CODE:0657  e200            MOVWF       0x62
                            LAB_CODE_0658:                ;XREF[4,0]:   CODE:062e,CODE:063d,CODE:0649,CODE:064d
CODE:CODE:0658  8312            BCF         STATUS,RP0
CODE:CODE:0659  3a08            MOVF        0x3a,w
CODE:CODE:065a  3f39            ANDLW       #0x3f
CODE:CODE:065b  0d3a            XORLW       #0xd
CODE:CODE:065c  0319            BTFSC       STATUS,#0x2
CODE:CODE:065d  2a1b            BTFSC       0x2a,#0x6
CODE:CODE:065e  612e            GOTO        LAB_CODE_0661
CODE:CODE:065f  3c08            MOVF        0x3c,w
CODE:CODE:0660  632e            GOTO        LAB_CODE_0663
                            LAB_CODE_0661:                ;XREF[1,0]:   CODE:065e
CODE:CODE:0661  3708            MOVF        BANK-0:DAT_DATA_0037,w                  ;= ??
CODE:CODE:0662  0f39            ANDLW       #0xf
                            LAB_CODE_0663:                ;XREF[1,0]:   CODE:0660
CODE:CODE:0663  8316            BSF         STATUS,RP0
CODE:CODE:0664  a900            MOVWF       0x29
CODE:CODE:0665  3230            MOVLW       #0x32
CODE:CODE:0666  ca00            MOVWF       0x4a
CODE:CODE:0667  8312            BCF         STATUS,RP0
CODE:CODE:0668  ae13            BCF         0x2e,#0x7
                            LAB_CODE_0669:                ;XREF[2,0]:   CODE:05de,CODE:05e3
CODE:CODE:0669  0313            BCF         STATUS,RP1
CODE:CODE:066a  ad12            BCF         0x2d,#0x5
                            LAB_CODE_066b:                ;XREF[1,0]:   CODE:05c9
CODE:CODE:066b  8316            BSF         STATUS,RP0
CODE:CODE:066c  ca08            MOVF        0x4a,f
CODE:CODE:066d  031d            BTFSS       STATUS,#0x2
CODE:CODE:066e  7a2e            GOTO        LAB_CODE_067a
CODE:CODE:066f  8312            BCF         STATUS,RP0
CODE:CODE:0670  ae17            BSF         0x2e,#0x7
CODE:CODE:0671  ba01            CLRF        0x3a
CODE:CODE:0672  bb01            CLRF        0x3b
CODE:CODE:0673  bc01            CLRF        0x3c
CODE:CODE:0674  b601            CLRF        0x36
CODE:CODE:0675  a301            CLRF        0x23
CODE:CODE:0676  aa01            CLRF        0x2a
CODE:CODE:0677  ab01            CLRF        0x2b
CODE:CODE:0678  b901            CLRF        0x39
CODE:CODE:0679  b801            CLRF        0x38
                            LAB_CODE_067a:                ;XREF[1,0]:   CODE:066e
CODE:CODE:067a  8316            BSF         STATUS,RP0
CODE:CODE:067b  ce08            MOVF        0x4e,f
CODE:CODE:067c  8312            BCF         STATUS,RP0
CODE:CODE:067d  0319            BTFSC       STATUS,#0x2
CODE:CODE:067e  892e            GOTO        LAB_CODE_0689
CODE:CODE:067f  2c1e            BTFSS       0x2c,#0x4
CODE:CODE:0680  882e            GOTO        LAB_CODE_0688
CODE:CODE:0681  8316            BSF         STATUS,RP0
CODE:CODE:0682  ce0b            DECFSZ      0x4e,f
CODE:CODE:0683  882e            GOTO        LAB_CODE_0688
CODE:CODE:0684  8312            BCF         STATUS,RP0
CODE:CODE:0685  2f12            BCF         0x2f,#0x4
CODE:CODE:0686  ff30            MOVLW       #0xff
CODE:CODE:0687  6724            CALL        USART_MAYBE_CONFIG                      ;undefined USART_MAYBE_CONFIG()
                            LAB_CODE_0688:                ;XREF[2,0]:   CODE:0680,CODE:0683
CODE:CODE:0688  8312            BCF         STATUS,RP0
                            LAB_CODE_0689:                ;XREF[1,0]:   CODE:067e
CODE:CODE:0689  ad1d            BTFSS       0x2d,#0x3
CODE:CODE:068a  0800            RETURN
CODE:CODE:068b  0317            BSF         STATUS,RP1
CODE:CODE:068c  5808            MOVF        0x58,w
CODE:CODE:068d  0313            BCF         STATUS,RP1
CODE:CODE:068e  d200            MOVWF       0x52
CODE:CODE:068f  d301            CLRF        0x53
CODE:CODE:0690  5730            MOVLW       #0x57
CODE:CODE:0691  9024            CALL        USART_MAYBE_CHECKSUM                    ;undefined USART_MAYBE_CHECKSUM(undef...
CODE:CODE:0692  cb00            MOVWF       0x4b
CODE:CODE:0693  cc01            CLRF        0x4c
CODE:CODE:0694  0317            BSF         STATUS,RP1
CODE:CODE:0695  5808            MOVF        0x58,w
CODE:CODE:0696  573e            ADDLW       #0x57
CODE:CODE:0697  8400            MOVWF       FSR0L
CODE:CODE:0698  8317            BSF         STATUS,IRP
CODE:CODE:0699  0008            MOVF        INDF0,w
CODE:CODE:069a  0313            BCF         STATUS,RP1
CODE:CODE:069b  cd00            MOVWF       0x4d
CODE:CODE:069c  ce01            CLRF        0x4e
CODE:CODE:069d  4c08            MOVF        0x4c,w
CODE:CODE:069e  4e06            XORWF       0x4e,w
CODE:CODE:069f  031d            BTFSS       STATUS,#0x2
CODE:CODE:06a0  a32e            GOTO        LAB_CODE_06a3
CODE:CODE:06a1  4b08            MOVF        0x4b,w
CODE:CODE:06a2  4d06            XORWF       0x4d,w
                            LAB_CODE_06a3:                ;XREF[1,0]:   CODE:06a0
CODE:CODE:06a3  0319            BTFSC       STATUS,#0x2
CODE:CODE:06a4  0f2f            GOTO        LAB_CODE_070f
CODE:CODE:06a5  1e2f            GOTO        LAB_CODE_071e
                            LAB_CODE_06a6:                ;XREF[1,0]:   CODE:0713
CODE:CODE:06a6  5808            MOVF        BANK-0:DAT_DATA_0058,w                  ;= ??
CODE:CODE:06a7  153a            XORLW       #0x15
CODE:CODE:06a8  031d            BTFSS       STATUS,#0x2
CODE:CODE:06a9  1a2f            GOTO        LAB_CODE_071a
CODE:CODE:06aa  0313            BCF         STATUS,RP1
                            ;ce if trigger l'envoit d'un paquet avec 0x01 ou 0x00 dans un des bytes selon le cas
CODE:CODE:06ab  c508            MOVF        0x45,f
CODE:CODE:06ac  031d            BTFSS       STATUS,#0x2
CODE:CODE:06ad  de2e            GOTO        LAB_CODE_06de
CODE:CODE:06ae  ca01            CLRF        0x4a
                            LAB_CODE_06af:                ;XREF[1,0]:   CODE:06c0
CODE:CODE:06af  4a08            MOVF        0x4a,w
CODE:CODE:06b0  053e            ADDLW       #0x5
CODE:CODE:06b1  573e            ADDLW       #0x57
CODE:CODE:06b2  8400            MOVWF       FSR0L
CODE:CODE:06b3  8317            BSF         STATUS,IRP
CODE:CODE:06b4  0008            MOVF        INDF0,w
CODE:CODE:06b5  cb00            MOVWF       0x4b
CODE:CODE:06b6  4a08            MOVF        0x4a,w
CODE:CODE:06b7  473e            ADDLW       #0x47
CODE:CODE:06b8  8400            MOVWF       FSR0L
CODE:CODE:06b9  8317            BSF         STATUS,IRP
CODE:CODE:06ba  4b08            MOVF        0x4b,w
CODE:CODE:06bb  8000            MOVWF       INDF0
CODE:CODE:06bc  ca0a            INCF        0x4a,f
CODE:CODE:06bd  1030            MOVLW       #0x10
CODE:CODE:06be  4a02            SUBWF       0x4a,w
CODE:CODE:06bf  031c            BTFSS       STATUS,#0x0
CODE:CODE:06c0  af2e            GOTO        LAB_CODE_06af
CODE:CODE:06c1  0317            BSF         STATUS,RP1
CODE:CODE:06c2  5a08            MOVF        0x5a,w
CODE:CODE:06c3  8316            BSF         STATUS,RP0
CODE:CODE:06c4  0313            BCF         STATUS,RP1
CODE:CODE:06c5  dc00            MOVWF       0x5c
CODE:CODE:06c6  8312            BCF         STATUS,RP0
CODE:CODE:06c7  0317            BSF         STATUS,RP1
CODE:CODE:06c8  5b08            MOVF        0x5b,w
CODE:CODE:06c9  8316            BSF         STATUS,RP0
CODE:CODE:06ca  0313            BCF         STATUS,RP1
CODE:CODE:06cb  db00            MOVWF       0x5b
CODE:CODE:06cc  0130            MOVLW       #0x1
CODE:CODE:06cd  d924            CALL        USART_PACKET_SEND_2                     ;undefined USART_PACKET_SEND_2()
CODE:CODE:06ce  8316            BSF         STATUS,RP0
CODE:CODE:06cf  5b08            MOVF        0x5b,w
CODE:CODE:06d0  8312            BCF         STATUS,RP0
CODE:CODE:06d1  cf00            MOVWF       0x4f
CODE:CODE:06d2  8316            BSF         STATUS,RP0
CODE:CODE:06d3  5c08            MOVF        0x5c,w
CODE:CODE:06d4  8312            BCF         STATUS,RP0
CODE:CODE:06d5  d000            MOVWF       0x50
CODE:CODE:06d6  a030            MOVLW       #0xa0
CODE:CODE:06d7  d100            MOVWF       0x51
CODE:CODE:06d8  0a16            BSF         PCLATH,#0x4
CODE:CODE:06d9  8a11            BCF         PCLATH,#0x3
CODE:CODE:06da  2e27            CALL        offset Cecile-0x1000                    ;undefined Cecile()
CODE:CODE:06db  0a12            BCF         PCLATH,#0x4
CODE:CODE:06dc  8a11            BCF         PCLATH,#0x3
CODE:CODE:06dd  1a2f            GOTO        LAB_CODE_071a
                            LAB_CODE_06de:                ;XREF[1,0]:   CODE:06ad
CODE:CODE:06de  0030            MOVLW       #0x0
CODE:CODE:06df  d924            CALL        USART_PACKET_SEND_2                     ;undefined USART_PACKET_SEND_2()
CODE:CODE:06e0  0a12            BCF         PCLATH,#0x4
CODE:CODE:06e1  8a11            BCF         PCLATH,#0x3
CODE:CODE:06e2  1a2f            GOTO        LAB_CODE_071a
                            LAB_CODE_06e3:                ;XREF[1,0]:   CODE:0716
CODE:CODE:06e3  5808            MOVF        BANK-0:DAT_DATA_0058,w                  ;= ??
CODE:CODE:06e4  053a            XORLW       #0x5
CODE:CODE:06e5  031d            BTFSS       STATUS,#0x2
CODE:CODE:06e6  1a2f            GOTO        LAB_CODE_071a
CODE:CODE:06e7  5a08            MOVF        0x5a,w
CODE:CODE:06e8  8316            BSF         STATUS,RP0
CODE:CODE:06e9  0313            BCF         STATUS,RP1
CODE:CODE:06ea  dc00            MOVWF       0x5c
CODE:CODE:06eb  8312            BCF         STATUS,RP0
CODE:CODE:06ec  0317            BSF         STATUS,RP1
CODE:CODE:06ed  5b08            MOVF        0x5b,w
CODE:CODE:06ee  8316            BSF         STATUS,RP0
CODE:CODE:06ef  0313            BCF         STATUS,RP1
CODE:CODE:06f0  db00            MOVWF       0x5b
CODE:CODE:06f1  8312            BCF         STATUS,RP0
CODE:CODE:06f2  dc00            MOVWF       0x5c
CODE:CODE:06f3  8316            BSF         STATUS,RP0
CODE:CODE:06f4  5c08            MOVF        0x5c,w
CODE:CODE:06f5  8312            BCF         STATUS,RP0
CODE:CODE:06f6  dd00            MOVWF       0x5d
CODE:CODE:06f7  a030            MOVLW       #0xa0
CODE:CODE:06f8  de00            MOVWF       0x5e
CODE:CODE:06f9  0a16            BSF         PCLATH,#0x4
CODE:CODE:06fa  8a11            BCF         PCLATH,#0x3
CODE:CODE:06fb  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:06fc  0a12            BCF         PCLATH,#0x4
CODE:CODE:06fd  8a11            BCF         PCLATH,#0x3
CODE:CODE:06fe  0025            CALL        USART_PACKET_SEND_3                     ;undefined USART_PACKET_SEND_3()
CODE:CODE:06ff  0a12            BCF         PCLATH,#0x4
CODE:CODE:0700  8a11            BCF         PCLATH,#0x3
CODE:CODE:0701  1a2f            GOTO        LAB_CODE_071a
                            LAB_CODE_0702:                ;XREF[1,0]:   CODE:0719
CODE:CODE:0702  5808            MOVF        0x58,w
CODE:CODE:0703  033a            XORLW       #0x3
CODE:CODE:0704  031d            BTFSS       STATUS,#0x2
CODE:CODE:0705  1a2f            GOTO        LAB_CODE_071a
CODE:CODE:0706  0a16            BSF         PCLATH,#0x4
CODE:CODE:0707  8a11            BCF         PCLATH,#0x3
CODE:CODE:0708  9527            CALL        offset Clemence-0x1000                  ;undefined Clemence()
CODE:CODE:0709  0a12            BCF         PCLATH,#0x4
CODE:CODE:070a  8a11            BCF         PCLATH,#0x3
CODE:CODE:070b  ad24            CALL        USART_PACKET_SEND_1                     ;undefined USART_PACKET_SEND_1()
CODE:CODE:070c  0a12            BCF         PCLATH,#0x4
CODE:CODE:070d  8a11            BCF         PCLATH,#0x3
CODE:CODE:070e  1a2f            GOTO        LAB_CODE_071a
                            LAB_CODE_070f:                ;XREF[1,0]:   CODE:06a4
CODE:CODE:070f  0317            BSF         STATUS,RP1
CODE:CODE:0710  5908            MOVF        0x59,w
CODE:CODE:0711  853a            XORLW       #0x85
CODE:CODE:0712  0319            BTFSC       STATUS,#0x2
CODE:CODE:0713  a62e            GOTO        LAB_CODE_06a6
CODE:CODE:0714  103a            XORLW       #0x10
CODE:CODE:0715  0319            BTFSC       STATUS,#0x2
CODE:CODE:0716  e32e            GOTO        LAB_CODE_06e3
CODE:CODE:0717  263a            XORLW       #0x26
CODE:CODE:0718  0319            BTFSC       STATUS,#0x2
CODE:CODE:0719  022f            GOTO        LAB_CODE_0702
                            LAB_CODE_071a:                ;XREF[7,0]:   CODE:06a9,CODE:06dd,CODE:06e2,CODE:06e6
                                                          ;             CODE:0701,CODE:0705,CODE:070e
CODE:CODE:071a  1430            MOVLW       #0x14
CODE:CODE:071b  8316            BSF         STATUS,RP0
CODE:CODE:071c  0313            BCF         STATUS,RP1
CODE:CODE:071d  ce00            MOVWF       BANK-1:DAT_BANK-1__004e                 ;= ??
                            LAB_CODE_071e:                ;XREF[1,0]:   CODE:06a5
CODE:CODE:071e  8316            BSF         STATUS,RP0
CODE:CODE:071f  c201            CLRF        BANK-1:USART_RX_BUFFER_INDEX            ;= ??
CODE:CODE:0720  8312            BCF         STATUS,RP0
CODE:CODE:0721  ad11            BCF         BANK-0:USART_RX_PACKET_STATUS,#0x3      ;= ??
CODE:CODE:0722  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined MAINLOOP_SUB1()
                                                          ;XREF[1,0]:   CODE:102b
CODE:CODE:0723  6400            CLRWDT
CODE:CODE:0724  8312            BCF         STATUS,RP0
CODE:CODE:0725  0313            BCF         STATUS,RP1
CODE:CODE:0726  2c11            BCF         0x2c,#0x2
CODE:CODE:0727  ac11            BCF         0x2c,#0x3
CODE:CODE:0728  2c12            BCF         0x2c,#0x4
CODE:CODE:0729  8b12            BCF         INTCON,TMR0IE
CODE:CODE:072a  ac1c            BTFSS       0x2c,#0x1
CODE:CODE:072b  e42f            GOTO        LAB_CODE_07e4
CODE:CODE:072c  8316            BSF         STATUS,RP0
CODE:CODE:072d  0317            BSF         STATUS,RP1
CODE:CODE:072e  101d            BTFSS       0x10,#0x2
CODE:CODE:072f  342f            GOTO        LAB_CODE_0734
CODE:CODE:0730  0313            BCF         STATUS,RP1
CODE:CODE:0731  3209            COMF        0x32,w
CODE:CODE:0732  2005            ANDWF       0x20,w
CODE:CODE:0733  362f            GOTO        LAB_CODE_0736
                            LAB_CODE_0734:                ;XREF[1,0]:   CODE:072f
CODE:CODE:0734  0313            BCF         STATUS,RP1
CODE:CODE:0735  2008            MOVF        0x20,w
                            LAB_CODE_0736:                ;XREF[1,0]:   CODE:0733
CODE:CODE:0736  b400            MOVWF       0x34
CODE:CODE:0737  8312            BCF         STATUS,RP0
CODE:CODE:0738  ac10            BCF         0x2c,#0x1
CODE:CODE:0739  8b16            BSF         INTCON,TMR0IE
CODE:CODE:073a  2c15            BSF         0x2c,#0x2
CODE:CODE:073b  8316            BSF         STATUS,RP0
CODE:CODE:073c  be08            MOVF        0x3e,f
CODE:CODE:073d  0319            BTFSC       STATUS,#0x2
CODE:CODE:073e  432f            GOTO        LAB_CODE_0743
CODE:CODE:073f  be0b            DECFSZ      0x3e,f
CODE:CODE:0740  432f            GOTO        LAB_CODE_0743
CODE:CODE:0741  8312            BCF         STATUS,RP0
CODE:CODE:0742  2c14            BSF         0x2c,#0x0
                            LAB_CODE_0743:                ;XREF[2,0]:   CODE:073e,CODE:0740
CODE:CODE:0743  8312            BCF         STATUS,RP0
CODE:CODE:0744  e80b            DECFSZ      0x68,f
CODE:CODE:0745  632f            GOTO        LAB_CODE_0763
CODE:CODE:0746  4030            MOVLW       #0x40
CODE:CODE:0747  8316            BSF         STATUS,RP0
CODE:CODE:0748  0317            BSF         STATUS,RP1
CODE:CODE:0749  9006            XORWF       0x10,f
CODE:CODE:074a  3230            MOVLW       #0x32
CODE:CODE:074b  8312            BCF         STATUS,RP0
CODE:CODE:074c  0313            BCF         STATUS,RP1
CODE:CODE:074d  e800            MOVWF       0x68
CODE:CODE:074e  0030            MOVLW       #0x0
CODE:CODE:074f  8316            BSF         STATUS,RP0
CODE:CODE:0750  0317            BSF         STATUS,RP1
CODE:CODE:0751  101d            BTFSS       0x10,#0x2
CODE:CODE:0752  0130            MOVLW       #0x1
CODE:CODE:0753  0313            BCF         STATUS,RP1
CODE:CODE:0754  8312            BCF         STATUS,RP0
CODE:CODE:0755  ca00            MOVWF       0x4a
CODE:CODE:0756  ca0d            RLF         0x4a,f
CODE:CODE:0757  ca0d            RLF         0x4a,f
CODE:CODE:0758  8316            BSF         STATUS,RP0
CODE:CODE:0759  0317            BSF         STATUS,RP1
CODE:CODE:075a  1008            MOVF        0x10,w
CODE:CODE:075b  0313            BCF         STATUS,RP1
CODE:CODE:075c  8312            BCF         STATUS,RP0
CODE:CODE:075d  4a06            XORWF       0x4a,w
CODE:CODE:075e  fb39            ANDLW       #0xfb
CODE:CODE:075f  4a06            XORWF       0x4a,w
CODE:CODE:0760  8316            BSF         STATUS,RP0
CODE:CODE:0761  0317            BSF         STATUS,RP1
CODE:CODE:0762  9000            MOVWF       0x10
                            LAB_CODE_0763:                ;XREF[1,0]:   CODE:0745
CODE:CODE:0763  8316            BSF         STATUS,RP0
CODE:CODE:0764  0313            BCF         STATUS,RP1
CODE:CODE:0765  bd08            MOVF        0x3d,f
CODE:CODE:0766  031d            BTFSS       STATUS,#0x2
CODE:CODE:0767  bd03            DECF        0x3d,f
CODE:CODE:0768  c008            MOVF        0x40,f
CODE:CODE:0769  0319            BTFSC       STATUS,#0x2
CODE:CODE:076a  6f2f            GOTO        LAB_CODE_076f
CODE:CODE:076b  c00b            DECFSZ      0x40,f
CODE:CODE:076c  6f2f            GOTO        LAB_CODE_076f
CODE:CODE:076d  8312            BCF         STATUS,RP0
CODE:CODE:076e  2d11            BCF         0x2d,#0x2
                            LAB_CODE_076f:                ;XREF[2,0]:   CODE:076a,CODE:076c
CODE:CODE:076f  8316            BSF         STATUS,RP0
CODE:CODE:0770  bf08            MOVF        0x3f,f
CODE:CODE:0771  0319            BTFSC       STATUS,#0x2
CODE:CODE:0772  762f            GOTO        LAB_CODE_0776
CODE:CODE:0773  bf0b            DECFSZ      0x3f,f
CODE:CODE:0774  762f            GOTO        LAB_CODE_0776
CODE:CODE:0775  c201            CLRF        0x42
                            LAB_CODE_0776:                ;XREF[2,0]:   CODE:0772,CODE:0774
CODE:CODE:0776  8312            BCF         STATUS,RP0
CODE:CODE:0777  2c1c            BTFSS       0x2c,#0x0
CODE:CODE:0778  8d2f            GOTO        LAB_CODE_078d
CODE:CODE:0779  ae1d            BTFSS       0x2e,#0x3
CODE:CODE:077a  8c2f            GOTO        LAB_CODE_078c
CODE:CODE:077b  8316            BSF         STATUS,RP0
CODE:CODE:077c  6008            MOVF        0x60,w
CODE:CODE:077d  5f04            IORWF       0x5f,w
CODE:CODE:077e  0319            BTFSC       STATUS,#0x2
CODE:CODE:077f  852f            GOTO        LAB_CODE_0785
CODE:CODE:0780  df08            MOVF        0x5f,f
CODE:CODE:0781  0319            BTFSC       STATUS,#0x2
CODE:CODE:0782  e003            DECF        0x60,f
CODE:CODE:0783  df03            DECF        0x5f,f
CODE:CODE:0784  8d2f            GOTO        LAB_CODE_078d
                            LAB_CODE_0785:                ;XREF[1,0]:   CODE:077f
CODE:CODE:0785  8312            BCF         STATUS,RP0
CODE:CODE:0786  2e16            BSF         0x2e,#0x4
CODE:CODE:0787  4630            MOVLW       #0x46
CODE:CODE:0788  8316            BSF         STATUS,RP0
CODE:CODE:0789  df00            MOVWF       0x5f
CODE:CODE:078a  e001            CLRF        0x60
CODE:CODE:078b  8d2f            GOTO        LAB_CODE_078d
                            LAB_CODE_078c:                ;XREF[1,0]:   CODE:077a
CODE:CODE:078c  2e12            BCF         BANK-0:DAT_DATA_002e,#0x4               ;= ??
                            LAB_CODE_078d:                ;XREF[3,0]:   CODE:0778,CODE:0784,CODE:078b
CODE:CODE:078d  8316            BSF         STATUS,RP0
CODE:CODE:078e  b50b            DECFSZ      0x35,f
CODE:CODE:078f  e42f            GOTO        LAB_CODE_07e4
CODE:CODE:0790  0a30            MOVLW       #0xa
CODE:CODE:0791  b500            MOVWF       0x35
CODE:CODE:0792  8312            BCF         STATUS,RP0
CODE:CODE:0793  ac15            BSF         0x2c,#0x3
CODE:CODE:0794  8316            BSF         STATUS,RP0
CODE:CODE:0795  6708            MOVF        0x67,w
CODE:CODE:0796  0319            BTFSC       STATUS,#0x2
CODE:CODE:0797  9a2f            GOTO        LAB_CODE_079a
CODE:CODE:0798  e703            DECF        0x67,f
CODE:CODE:0799  a72f            GOTO        LAB_CODE_07a7
                            LAB_CODE_079a:                ;XREF[1,0]:   CODE:0797
CODE:CODE:079a  0f30            MOVLW       #0xf
CODE:CODE:079b  e700            MOVWF       0x67
CODE:CODE:079c  0030            MOVLW       #0x0
CODE:CODE:079d  8312            BCF         STATUS,RP0
CODE:CODE:079e  af1c            BTFSS       0x2f,#0x1
CODE:CODE:079f  0130            MOVLW       #0x1
CODE:CODE:07a0  ca00            MOVWF       0x4a
CODE:CODE:07a1  ca0d            RLF         0x4a,f
CODE:CODE:07a2  2f08            MOVF        0x2f,w
CODE:CODE:07a3  4a06            XORWF       0x4a,w
CODE:CODE:07a4  fd39            ANDLW       #0xfd
CODE:CODE:07a5  4a06            XORWF       0x4a,w
CODE:CODE:07a6  af00            MOVWF       0x2f
                            LAB_CODE_07a7:                ;XREF[1,0]:   CODE:0799
CODE:CODE:07a7  8312            BCF         STATUS,RP0
CODE:CODE:07a8  2c1c            BTFSS       0x2c,#0x0
CODE:CODE:07a9  bb2f            GOTO        LAB_CODE_07bb
CODE:CODE:07aa  8316            BSF         STATUS,RP0
CODE:CODE:07ab  c908            MOVF        0x49,f
CODE:CODE:07ac  0319            BTFSC       STATUS,#0x2
CODE:CODE:07ad  af2f            GOTO        LAB_CODE_07af
CODE:CODE:07ae  c903            DECF        0x49,f
                            LAB_CODE_07af:                ;XREF[1,0]:   CODE:07ad
CODE:CODE:07af  cb08            MOVF        0x4b,f
CODE:CODE:07b0  031d            BTFSS       STATUS,#0x2
CODE:CODE:07b1  cb03            DECF        0x4b,f
CODE:CODE:07b2  ca08            MOVF        0x4a,f
CODE:CODE:07b3  031d            BTFSS       STATUS,#0x2
CODE:CODE:07b4  ca03            DECF        0x4a,f
CODE:CODE:07b5  c708            MOVF        0x47,f
CODE:CODE:07b6  031d            BTFSS       STATUS,#0x2
CODE:CODE:07b7  c703            DECF        0x47,f
CODE:CODE:07b8  c808            MOVF        0x48,f
CODE:CODE:07b9  031d            BTFSS       STATUS,#0x2
CODE:CODE:07ba  c803            DECF        0x48,f
                            LAB_CODE_07bb:                ;XREF[1,0]:   CODE:07a9
CODE:CODE:07bb  8316            BSF         STATUS,RP0
CODE:CODE:07bc  b70b            DECFSZ      0x37,f
CODE:CODE:07bd  e42f            GOTO        LAB_CODE_07e4
CODE:CODE:07be  0a30            MOVLW       #0xa
CODE:CODE:07bf  b700            MOVWF       0x37
CODE:CODE:07c0  8312            BCF         STATUS,RP0
CODE:CODE:07c1  2c16            BSF         0x2c,#0x4
CODE:CODE:07c2  2c1c            BTFSS       0x2c,#0x0
CODE:CODE:07c3  e42f            GOTO        LAB_CODE_07e4
CODE:CODE:07c4  4030            MOVLW       #0x40
CODE:CODE:07c5  ad06            XORWF       0x2d,f
CODE:CODE:07c6  8316            BSF         STATUS,RP0
CODE:CODE:07c7  0317            BSF         STATUS,RP1
CODE:CODE:07c8  901f            BTFSS       0x10,#0x7
CODE:CODE:07c9  d22f            GOTO        LAB_CODE_07d2
CODE:CODE:07ca  0313            BCF         STATUS,RP1
CODE:CODE:07cb  b808            MOVF        0x38,f
CODE:CODE:07cc  0319            BTFSC       STATUS,#0x2
CODE:CODE:07cd  d02f            GOTO        LAB_CODE_07d0
CODE:CODE:07ce  b803            DECF        0x38,f
CODE:CODE:07cf  d22f            GOTO        LAB_CODE_07d2
                            LAB_CODE_07d0:                ;XREF[1,0]:   CODE:07cd
CODE:CODE:07d0  0a30            MOVLW       #0xa
CODE:CODE:07d1  b800            MOVWF       0x38
                            LAB_CODE_07d2:                ;XREF[2,0]:   CODE:07c9,CODE:07cf
CODE:CODE:07d2  0313            BCF         STATUS,RP1
CODE:CODE:07d3  cd08            MOVF        0x4d,f
CODE:CODE:07d4  031d            BTFSS       STATUS,#0x2
CODE:CODE:07d5  cd03            DECF        0x4d,f
CODE:CODE:07d6  8312            BCF         STATUS,RP0
CODE:CODE:07d7  0317            BSF         STATUS,RP1
CODE:CODE:07d8  2608            MOVF        0x26,w
CODE:CODE:07d9  0313            BCF         STATUS,RP1
CODE:CODE:07da  0319            BTFSC       STATUS,#0x2
CODE:CODE:07db  e22f            GOTO        LAB_CODE_07e2
CODE:CODE:07dc  301a            BTFSC       0x30,#0x4
CODE:CODE:07dd  e12f            GOTO        LAB_CODE_07e1
CODE:CODE:07de  0317            BSF         STATUS,RP1
CODE:CODE:07df  a603            DECF        0x26,f
CODE:CODE:07e0  e42f            GOTO        LAB_CODE_07e4
                            LAB_CODE_07e1:                ;XREF[1,0]:   CODE:07dd
CODE:CODE:07e1  0313            BCF         STATUS,RP1
                            LAB_CODE_07e2:                ;XREF[1,0]:   CODE:07db
CODE:CODE:07e2  3012            BCF         0x30,#0x4
CODE:CODE:07e3  b016            BSF         0x30,#0x5
                            LAB_CODE_07e4:                ;XREF[5,0]:   CODE:072b,CODE:078f,CODE:07bd,CODE:07c3
                                                          ;             CODE:07e0
CODE:CODE:07e4  8b16            BSF         INTCON,TMR0IE
CODE:CODE:07e5  8301            CLRF        STATUS
CODE:CODE:07e6  0800            RETURN
                            ;tres probabelement string pour l'ecran
                            ; ENERGY SAVING
CODE:CODE:07e7  82              ??          82h
CODE:CODE:07e7.107              ??          07h
CODE:CODE:07e8  4534            RETLW       #0x45
CODE:CODE:07e9  4e34            RETLW       #0x4e
CODE:CODE:07ea  4534            RETLW       #0x45
CODE:CODE:07eb  5234            RETLW       #0x52
CODE:CODE:07ec  4734            RETLW       #0x47
CODE:CODE:07ed  5934            RETLW       #0x59
CODE:CODE:07ee  2034            RETLW       #0x20
CODE:CODE:07ef  5334            RETLW       #0x53
CODE:CODE:07f0  4134            RETLW       #0x41
CODE:CODE:07f1  5634            RETLW       #0x56
CODE:CODE:07f2  4934            RETLW       #0x49
CODE:CODE:07f3  4e34            RETLW       #0x4e
CODE:CODE:07f4  4734            RETLW       #0x47
CODE:CODE:07f5  2034            RETLW       #0x20
CODE:CODE:07f6  2034            RETLW       #0x20
CODE:CODE:07f7  2034            RETLW       #0x20
CODE:CODE:07f8  2034            RETLW       #0x20
CODE:CODE:07f9  2034            RETLW       #0x20
CODE:CODE:07fa  2034            RETLW       #0x20
CODE:CODE:07fb  2034            RETLW       #0x20
CODE:CODE:07fc  0034            RETLW       #0x0
CODE:CODE:07fd  ff3fff3fff3f    db[6]
   |_CODE:CODE:07fd  [0]             db          FFh
   |_CODE:CODE:07fd.1[1]             db          3Fh
   |_CODE:CODE:07fe  [2]             db          FFh
   |_CODE:CODE:07fe.1[3]             db          3Fh
   |_CODE:CODE:07ff  [4]             db          FFh
   |_CODE:CODE:07ff.1[5]             db          3Fh
CODE:CODE:0800  82              ??          82h
CODE:CODE:0800.107              ??          07h
CODE:CODE:0801  4334            RETLW       #0x43
CODE:CODE:0802  1834            RETLW       #0x18
CODE:CODE:0803  2d34            RETLW       #0x2d
CODE:CODE:0804  1934            RETLW       #0x19
CODE:CODE:0805  4334            RETLW       #0x43
CODE:CODE:0806  1934            RETLW       #0x19
CODE:CODE:0807  1734            RETLW       #0x17
CODE:CODE:0808  1934            RETLW       #0x19
CODE:CODE:0809  8534            RETLW       #0x85
CODE:CODE:080a  1934            RETLW       #0x19
CODE:CODE:080b  5934            RETLW       #0x59
CODE:CODE:080c  1934            RETLW       #0x19
CODE:CODE:080d  2d34            RETLW       #0x2d
CODE:CODE:080e  1834            RETLW       #0x18
CODE:CODE:080f  0134            RETLW       #0x1
CODE:CODE:0810  1934            RETLW       #0x19
CODE:CODE:0811  dd34            RETLW       #0xdd
CODE:CODE:0812  1834            RETLW       #0x18
CODE:CODE:0813  b134            RETLW       #0xb1
CODE:CODE:0814  1834            RETLW       #0x18
CODE:CODE:0815  9b34            RETLW       #0x9b
CODE:CODE:0816  1834            RETLW       #0x18
CODE:CODE:0817  8534            RETLW       #0x85
CODE:CODE:0818  1834            RETLW       #0x18
CODE:CODE:0819  c734            RETLW       #0xc7
CODE:CODE:081a  1834            RETLW       #0x18
CODE:CODE:081b  5934            RETLW       #0x59
CODE:CODE:081c  1834            RETLW       #0x18
CODE:CODE:081d  6f34            RETLW       #0x6f
CODE:CODE:081e  1834            RETLW       #0x18
CODE:CODE:081f  1734            RETLW       #0x17
CODE:CODE:0820  1834            RETLW       #0x18
CODE:CODE:0821  6f34            RETLW       #0x6f
CODE:CODE:0822  1934            RETLW       #0x19
CODE:CODE:0823  0134            RETLW       #0x1
CODE:CODE:0824  1834            RETLW       #0x18
CODE:CODE:0825  e834            RETLW       #0xe8
CODE:CODE:0826  0734            RETLW       #0x7
CODE:CODE:0827  9b34            RETLW       #0x9b
CODE:CODE:0828  1934            RETLW       #0x19
CODE:CODE:0829  da34            RETLW       #0xda
CODE:CODE:082a  1934            RETLW       #0x19
CODE:CODE:082b  b034            RETLW       #0xb0
CODE:CODE:082c  1934            RETLW       #0x19
CODE:CODE:082d  ff3fff3ff...    db[10]
   |_CODE:CODE:082d  [0]             db          FFh
   |_CODE:CODE:082d.1[1]             db          3Fh
   |_CODE:CODE:082e  [2]             db          FFh
   |_CODE:CODE:082e.1[3]             db          3Fh
   |_CODE:CODE:082f  [4]             db          FFh
   |_CODE:CODE:082f.1[5]             db          3Fh
   |_CODE:CODE:0830  [6]             db          FFh
   |_CODE:CODE:0830.1[7]             db          3Fh
   |_CODE:CODE:0831  [8]             db          FFh
   |_CODE:CODE:0831.1[9]             db          3Fh
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Emma()
                                                          ;XREF[1,0]:   CODE:0f65
CODE:CODE:0832  8301            CLRF        STATUS
CODE:CODE:0833  ce00            MOVWF       0x4e
CODE:CODE:0834  cd01            CLRF        0x4d
CODE:CODE:0835  1430            MOVLW       #0x14
CODE:CODE:0836  4e02            SUBWF       0x4e,w
CODE:CODE:0837  0318            BTFSC       STATUS,#0x0
CODE:CODE:0838  3b28            GOTO        offset LAB_CODE_083b &0xff
CODE:CODE:0839  1330            MOVLW       #0x13
CODE:CODE:083a  3c28            GOTO        offset LAB_CODE_083c &0xff
                            LAB_CODE_083b:                ;XREF[1,0]:   CODE:0838
CODE:CODE:083b  5330            MOVLW       #0x53
                            LAB_CODE_083c:                ;XREF[1,0]:   CODE:083a
CODE:CODE:083c  cf00            MOVWF       0x4f
CODE:CODE:083d  4e08            MOVF        0x4e,w
CODE:CODE:083e  8038            IORLW       #0x80
CODE:CODE:083f  d500            MOVWF       0x55
CODE:CODE:0840  0130            MOVLW       #0x1
CODE:CODE:0841  0a12            BCF         PCLATH,#0x4
CODE:CODE:0842  8a11            BCF         PCLATH,#0x3
CODE:CODE:0843  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0844  0a12            BCF         PCLATH,#0x4
CODE:CODE:0845  8a15            BSF         PCLATH,#0x3
CODE:CODE:0846  d001            CLRF        0x50
                            LAB_CODE_0847:                ;XREF[1,0]:   CODE:087d
CODE:CODE:0847  4e08            MOVF        0x4e,w
CODE:CODE:0848  d100            MOVWF       0x51
CODE:CODE:0849  d201            CLRF        0x52
CODE:CODE:084a  5008            MOVF        0x50,w
CODE:CODE:084b  d107            ADDWF       0x51,f
CODE:CODE:084c  0318            BTFSC       STATUS,#0x0
CODE:CODE:084d  d20a            INCF        0x52,f
CODE:CODE:084e  4f08            MOVF        0x4f,w
CODE:CODE:084f  d300            MOVWF       0x53
CODE:CODE:0850  d401            CLRF        0x54
CODE:CODE:0851  5408            MOVF        0x54,w
CODE:CODE:0852  803a            XORLW       #0x80
CODE:CODE:0853  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:0854  5208            MOVF        0x52,w
CODE:CODE:0855  803a            XORLW       #0x80
CODE:CODE:0856  7902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:0857  031d            BTFSS       STATUS,#0x2
CODE:CODE:0858  5b28            GOTO        offset LAB_CODE_085b &0xff
CODE:CODE:0859  5108            MOVF        0x51,w
CODE:CODE:085a  5302            SUBWF       0x53,w
                            LAB_CODE_085b:                ;XREF[1,0]:   CODE:0858
CODE:CODE:085b  8312            BCF         STATUS,RP0
CODE:CODE:085c  0313            BCF         STATUS,RP1
CODE:CODE:085d  5008            MOVF        0x50,w
CODE:CODE:085e  031c            BTFSS       STATUS,#0x0
CODE:CODE:085f  6d28            GOTO        offset LAB_CODE_086d &0xff
CODE:CODE:0860  273e            ADDLW       #0x27
CODE:CODE:0861  8400            MOVWF       FSR0L
CODE:CODE:0862  8317            BSF         STATUS,IRP
CODE:CODE:0863  0008            MOVF        INDF0,w
CODE:CODE:0864  d500            MOVWF       0x55
CODE:CODE:0865  0030            MOVLW       #0x0
CODE:CODE:0866  0a12            BCF         PCLATH,#0x4
CODE:CODE:0867  8a11            BCF         PCLATH,#0x3
CODE:CODE:0868  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0869  0a12            BCF         PCLATH,#0x4
CODE:CODE:086a  8a15            BSF         PCLATH,#0x3
CODE:CODE:086b  0313            BCF         STATUS,RP1
CODE:CODE:086c  5008            MOVF        0x50,w
                            LAB_CODE_086d:                ;XREF[1,0]:   CODE:085f
CODE:CODE:086d  273e            ADDLW       #0x27
CODE:CODE:086e  8400            MOVWF       FSR0L
CODE:CODE:086f  8317            BSF         STATUS,IRP
CODE:CODE:0870  0008            MOVF        INDF0,w
CODE:CODE:0871  d100            MOVWF       0x51
CODE:CODE:0872  5008            MOVF        0x50,w
CODE:CODE:0873  913e            ADDLW       #0x91
CODE:CODE:0874  8400            MOVWF       FSR0L
CODE:CODE:0875  8317            BSF         STATUS,IRP
CODE:CODE:0876  5108            MOVF        0x51,w
CODE:CODE:0877  8000            MOVWF       INDF0
CODE:CODE:0878  d00a            INCF        0x50,f
CODE:CODE:0879  0a30            MOVLW       #0xa
CODE:CODE:087a  5002            SUBWF       0x50,w
CODE:CODE:087b  0318            BTFSC       STATUS,#0x0
CODE:CODE:087c  0800            RETURN
CODE:CODE:087d  4728            GOTO        offset LAB_CODE_0847 &0xff
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Elodie()
                                                          ;XREF[1,0]:   CODE:0ec6
CODE:CODE:087e  8301            CLRF        STATUS
CODE:CODE:087f  3011            BCF         0x30,#0x2
CODE:CODE:0880  8316            BSF         STATUS,RP0
CODE:CODE:0881  3a08            MOVF        0x3a,w
CODE:CODE:0882  8312            BCF         STATUS,RP0
CODE:CODE:0883  4706            XORWF       0x47,w
CODE:CODE:0884  8316            BSF         STATUS,RP0
CODE:CODE:0885  031d            BTFSS       STATUS,#0x2
CODE:CODE:0886  8d28            GOTO        offset LAB_CODE_088d &0xff
CODE:CODE:0887  3a08            MOVF        0x3a,w
CODE:CODE:0888  8312            BCF         STATUS,RP0
CODE:CODE:0889  4206            XORWF       0x42,w
CODE:CODE:088a  8316            BSF         STATUS,RP0
CODE:CODE:088b  0319            BTFSC       STATUS,#0x2
CODE:CODE:088c  e328            GOTO        offset LAB_CODE_08e3 &0xff
                            LAB_CODE_088d:                ;XREF[1,0]:   CODE:0886
CODE:CODE:088d  b008            MOVF        0x30,f
CODE:CODE:088e  031d            BTFSS       STATUS,#0x2
CODE:CODE:088f  e328            GOTO        offset LAB_CODE_08e3 &0xff
CODE:CODE:0890  8312            BCF         STATUS,RP0
CODE:CODE:0891  3015            BSF         0x30,#0x2
CODE:CODE:0892  8316            BSF         STATUS,RP0
CODE:CODE:0893  af08            MOVF        0x2f,f
CODE:CODE:0894  031d            BTFSS       STATUS,#0x2
CODE:CODE:0895  9e28            GOTO        offset LAB_CODE_089e &0xff
CODE:CODE:0896  8312            BCF         STATUS,RP0
CODE:CODE:0897  d201            CLRF        0x52
CODE:CODE:0898  4708            MOVF        0x47,w
CODE:CODE:0899  0a16            BSF         PCLATH,#0x4
CODE:CODE:089a  8a11            BCF         PCLATH,#0x3
CODE:CODE:089b  bd23            CALL        offset Emilie-0x1000                    ;undefined Emilie()
CODE:CODE:089c  4708            MOVF        0x47,w
CODE:CODE:089d  c200            MOVWF       0x42
                            LAB_CODE_089e:                ;XREF[1,0]:   CODE:0895
CODE:CODE:089e  8316            BSF         STATUS,RP0
CODE:CODE:089f  2508            MOVF        0x25,w
CODE:CODE:08a0  8038            IORLW       #0x80
CODE:CODE:08a1  8312            BCF         STATUS,RP0
CODE:CODE:08a2  d500            MOVWF       0x55
CODE:CODE:08a3  0130            MOVLW       #0x1
CODE:CODE:08a4  0a12            BCF         PCLATH,#0x4
CODE:CODE:08a5  8a11            BCF         PCLATH,#0x3
CODE:CODE:08a6  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:08a7  0a12            BCF         PCLATH,#0x4
CODE:CODE:08a8  8a15            BSF         PCLATH,#0x3
CODE:CODE:08a9  8316            BSF         STATUS,RP0
CODE:CODE:08aa  2508            MOVF        0x25,w
CODE:CODE:08ab  8312            BCF         STATUS,RP0
CODE:CODE:08ac  cd00            MOVWF       0x4d
                            LAB_CODE_08ad:                ;XREF[1,0]:   CODE:08d3
CODE:CODE:08ad  8316            BSF         STATUS,RP0
CODE:CODE:08ae  2508            MOVF        0x25,w
CODE:CODE:08af  8312            BCF         STATUS,RP0
CODE:CODE:08b0  ce00            MOVWF       0x4e
CODE:CODE:08b1  cf01            CLRF        0x4f
CODE:CODE:08b2  0530            MOVLW       #0x5
CODE:CODE:08b3  ce07            ADDWF       0x4e,f
CODE:CODE:08b4  0318            BTFSC       STATUS,#0x0
CODE:CODE:08b5  cf0a            INCF        0x4f,f
CODE:CODE:08b6  4d08            MOVF        0x4d,w
CODE:CODE:08b7  d000            MOVWF       0x50
CODE:CODE:08b8  d101            CLRF        0x51
CODE:CODE:08b9  5108            MOVF        0x51,w
CODE:CODE:08ba  803a            XORLW       #0x80
CODE:CODE:08bb  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:08bc  4f08            MOVF        0x4f,w
CODE:CODE:08bd  803a            XORLW       #0x80
CODE:CODE:08be  7902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:08bf  031d            BTFSS       STATUS,#0x2
CODE:CODE:08c0  c328            GOTO        offset LAB_CODE_08c3 &0xff
CODE:CODE:08c1  4e08            MOVF        0x4e,w
CODE:CODE:08c2  5002            SUBWF       0x50,w
                            LAB_CODE_08c3:                ;XREF[1,0]:   CODE:08c0
CODE:CODE:08c3  0318            BTFSC       STATUS,#0x0
CODE:CODE:08c4  d428            GOTO        offset LAB_CODE_08d4 &0xff
CODE:CODE:08c5  0313            BCF         STATUS,RP1
CODE:CODE:08c6  4d08            MOVF        0x4d,w
CODE:CODE:08c7  9b3e            ADDLW       #0x9b
CODE:CODE:08c8  8400            MOVWF       FSR0L
CODE:CODE:08c9  8317            BSF         STATUS,IRP
CODE:CODE:08ca  0008            MOVF        INDF0=>BANK-3:DAT_BANK-3__0069,w        ;= ??
CODE:CODE:08cb  d500            MOVWF       0x55
CODE:CODE:08cc  0030            MOVLW       #0x0
CODE:CODE:08cd  0a12            BCF         PCLATH,#0x4
CODE:CODE:08ce  8a11            BCF         PCLATH,#0x3
CODE:CODE:08cf  fd20            CALL        Adele
CODE:CODE:08d0  0a12            BCF         PCLATH,#0x4
CODE:CODE:08d1  8a15            BSF         PCLATH,#0x3
CODE:CODE:08d2  cd0a            INCF        0x4d,f
CODE:CODE:08d3  ad28            GOTO        offset LAB_CODE_08ad &0xff
                            LAB_CODE_08d4:                ;XREF[1,0]:   CODE:08c4
CODE:CODE:08d4  8316            BSF         STATUS,RP0
CODE:CODE:08d5  af0a            INCF        0x2f,f
CODE:CODE:08d6  0530            MOVLW       #0x5
CODE:CODE:08d7  a507            ADDWF       0x25,f
CODE:CODE:08d8  0430            MOVLW       #0x4
CODE:CODE:08d9  2f02            SUBWF       0x2f,w
CODE:CODE:08da  031c            BTFSS       STATUS,#0x0
CODE:CODE:08db  5f29            GOTO        offset LAB_CODE_095f-0x800
CODE:CODE:08dc  af01            CLRF        0x2f
CODE:CODE:08dd  a501            CLRF        0x25
CODE:CODE:08de  8312            BCF         STATUS,RP0
CODE:CODE:08df  4208            MOVF        0x42,w
CODE:CODE:08e0  8316            BSF         STATUS,RP0
CODE:CODE:08e1  ba00            MOVWF       0x3a
CODE:CODE:08e2  5f29            GOTO        offset LAB_CODE_095f-0x800
                            LAB_CODE_08e3:                ;XREF[2,0]:   CODE:088c,CODE:088f
CODE:CODE:08e3  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:08e4  8312            BCF         STATUS,RP0
CODE:CODE:08e5  4806            XORWF       0x48,w
CODE:CODE:08e6  8316            BSF         STATUS,RP0
CODE:CODE:08e7  031d            BTFSS       STATUS,#0x2
CODE:CODE:08e8  f128            GOTO        offset LAB_CODE_08f1 &0xff
CODE:CODE:08e9  3b08            MOVF        0x3b,w
CODE:CODE:08ea  8312            BCF         STATUS,RP0
CODE:CODE:08eb  4306            XORWF       0x43,w
CODE:CODE:08ec  031d            BTFSS       STATUS,#0x2
CODE:CODE:08ed  f028            GOTO        offset LAB_CODE_08f0 &0xff
CODE:CODE:08ee  2e1e            BTFSS       0x2e,#0x4
CODE:CODE:08ef  5f29            GOTO        offset LAB_CODE_095f-0x800
                            LAB_CODE_08f0:                ;XREF[1,0]:   CODE:08ed
CODE:CODE:08f0  8316            BSF         STATUS,RP0
                            LAB_CODE_08f1:                ;XREF[1,0]:   CODE:08e8
CODE:CODE:08f1  af08            MOVF        0x2f,f
CODE:CODE:08f2  8312            BCF         STATUS,RP0
CODE:CODE:08f3  031d            BTFSS       STATUS,#0x2
CODE:CODE:08f4  0800            RETURN
CODE:CODE:08f5  3015            BSF         0x30,#0x2
CODE:CODE:08f6  8316            BSF         STATUS,RP0
CODE:CODE:08f7  b008            MOVF        0x30,f
CODE:CODE:08f8  031d            BTFSS       STATUS,#0x2
CODE:CODE:08f9  1829            GOTO        offset LAB_CODE_0918-0x800
CODE:CODE:08fa  8312            BCF         STATUS,RP0
CODE:CODE:08fb  ae1d            BTFSS       0x2e,#0x3
CODE:CODE:08fc  0a29            GOTO        offset LAB_CODE_090a-0x800
CODE:CODE:08fd  4308            MOVF        0x43,w
CODE:CODE:08fe  4806            XORWF       0x48,w
CODE:CODE:08ff  0319            BTFSC       STATUS,#0x2
CODE:CODE:0900  0a29            GOTO        offset LAB_CODE_090a-0x800
CODE:CODE:0901  4808            MOVF        0x48,w
CODE:CODE:0902  0a16            BSF         PCLATH,#0x4
CODE:CODE:0903  8a11            BCF         PCLATH,#0x3
CODE:CODE:0904  1a22            CALL        offset Clara-0x1000                     ;undefined Clara()
CODE:CODE:0905  8316            BSF         STATUS,RP0
CODE:CODE:0906  a701            CLRF        0x27
CODE:CODE:0907  c830            MOVLW       #0xc8
CODE:CODE:0908  df00            MOVWF       0x5f
CODE:CODE:0909  e001            CLRF        0x60
                            LAB_CODE_090a:                ;XREF[2,0]:   CODE:08fc,CODE:0900
CODE:CODE:090a  3230            MOVLW       #0x32
CODE:CODE:090b  8316            BSF         STATUS,RP0
CODE:CODE:090c  c800            MOVWF       0x48
CODE:CODE:090d  1e30            MOVLW       #0x1e
CODE:CODE:090e  cd00            MOVWF       0x4d
CODE:CODE:090f  8312            BCF         STATUS,RP0
CODE:CODE:0910  d201            CLRF        0x52
CODE:CODE:0911  d20a            INCF        0x52,f
CODE:CODE:0912  4808            MOVF        0x48,w
CODE:CODE:0913  0a16            BSF         PCLATH,#0x4
CODE:CODE:0914  8a11            BCF         PCLATH,#0x3
CODE:CODE:0915  bd23            CALL        offset Emilie-0x1000                    ;undefined Emilie()
CODE:CODE:0916  4808            MOVF        0x48,w
CODE:CODE:0917  c300            MOVWF       0x43
                            LAB_CODE_0918:                ;XREF[1,0]:   CODE:08f9
CODE:CODE:0918  8316            BSF         STATUS,RP0
CODE:CODE:0919  2608            MOVF        0x26,w
CODE:CODE:091a  403e            ADDLW       #0x40
CODE:CODE:091b  8038            IORLW       #0x80
CODE:CODE:091c  8312            BCF         STATUS,RP0
CODE:CODE:091d  d500            MOVWF       0x55
CODE:CODE:091e  0130            MOVLW       #0x1
CODE:CODE:091f  0a12            BCF         PCLATH,#0x4
CODE:CODE:0920  8a11            BCF         PCLATH,#0x3
CODE:CODE:0921  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:0922  0a12            BCF         PCLATH,#0x4
CODE:CODE:0923  8a15            BSF         PCLATH,#0x3
CODE:CODE:0924  8316            BSF         STATUS,RP0
CODE:CODE:0925  2608            MOVF        0x26,w
CODE:CODE:0926  8312            BCF         STATUS,RP0
CODE:CODE:0927  cd00            MOVWF       0x4d
                            LAB_CODE_0928:                ;XREF[1,0]:   CODE:094e
CODE:CODE:0928  8316            BSF         STATUS,RP0
CODE:CODE:0929  2608            MOVF        0x26,w
CODE:CODE:092a  8312            BCF         STATUS,RP0
CODE:CODE:092b  ce00            MOVWF       0x4e
CODE:CODE:092c  cf01            CLRF        0x4f
CODE:CODE:092d  0530            MOVLW       #0x5
CODE:CODE:092e  ce07            ADDWF       0x4e,f
CODE:CODE:092f  0318            BTFSC       STATUS,#0x0
CODE:CODE:0930  cf0a            INCF        0x4f,f
CODE:CODE:0931  4d08            MOVF        0x4d,w
CODE:CODE:0932  d000            MOVWF       0x50
CODE:CODE:0933  d101            CLRF        0x51
CODE:CODE:0934  5108            MOVF        0x51,w
CODE:CODE:0935  803a            XORLW       #0x80
CODE:CODE:0936  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:0937  4f08            MOVF        0x4f,w
CODE:CODE:0938  803a            XORLW       #0x80
CODE:CODE:0939  7902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:093a  031d            BTFSS       STATUS,#0x2
CODE:CODE:093b  3e29            GOTO        offset LAB_CODE_093e-0x800
CODE:CODE:093c  4e08            MOVF        0x4e,w
CODE:CODE:093d  5002            SUBWF       0x50,w
                            LAB_CODE_093e:                ;XREF[1,0]:   CODE:093b
CODE:CODE:093e  0318            BTFSC       STATUS,#0x0
CODE:CODE:093f  4f29            GOTO        offset LAB_CODE_094f-0x800
CODE:CODE:0940  0313            BCF         STATUS,RP1
CODE:CODE:0941  4d08            MOVF        0x4d,w
CODE:CODE:0942  9b3e            ADDLW       #0x9b
CODE:CODE:0943  8400            MOVWF       FSR0L
CODE:CODE:0944  8317            BSF         STATUS,IRP
CODE:CODE:0945  0008            MOVF        INDF0,w
CODE:CODE:0946  d500            MOVWF       0x55
CODE:CODE:0947  0030            MOVLW       #0x0
CODE:CODE:0948  0a12            BCF         PCLATH,#0x4
CODE:CODE:0949  8a11            BCF         PCLATH,#0x3
CODE:CODE:094a  fd20            CALL        Adele                                   ;undefined Adele()
CODE:CODE:094b  0a12            BCF         PCLATH,#0x4
CODE:CODE:094c  8a15            BSF         PCLATH,#0x3
CODE:CODE:094d  cd0a            INCF        0x4d,f
CODE:CODE:094e  2829            GOTO        offset LAB_CODE_0928-0x800
                            LAB_CODE_094f:                ;XREF[1,0]:   CODE:093f
CODE:CODE:094f  8316            BSF         STATUS,RP0
CODE:CODE:0950  b00a            INCF        0x30,f
CODE:CODE:0951  0530            MOVLW       #0x5
CODE:CODE:0952  a607            ADDWF       0x26,f
CODE:CODE:0953  0430            MOVLW       #0x4
CODE:CODE:0954  3002            SUBWF       0x30,w
CODE:CODE:0955  031c            BTFSS       STATUS,#0x0
CODE:CODE:0956  5f29            GOTO        offset LAB_CODE_095f-0x800
CODE:CODE:0957  b001            CLRF        0x30
CODE:CODE:0958  a601            CLRF        0x26
CODE:CODE:0959  8312            BCF         STATUS,RP0
CODE:CODE:095a  4308            MOVF        0x43,w
CODE:CODE:095b  8316            BSF         STATUS,RP0
CODE:CODE:095c  bb00            MOVWF       0x3b
CODE:CODE:095d  8312            BCF         STATUS,RP0
CODE:CODE:095e  2e12            BCF         0x2e,#0x4
                            LAB_CODE_095f:                ;XREF[4,0]:   CODE:08db,CODE:08e2,CODE:08ef,CODE:0956
CODE:CODE:095f  8312            BCF         STATUS,RP0
CODE:CODE:0960  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Elona()
                                                          ;XREF[10,0]:  CODE:0ae0,CODE:0afb,CODE:0b67,CODE:0b83
                                                          ;             CODE:0bac,CODE:0bb3,CODE:0c5b,CODE:0cb1
                                                          ;             CODE:0cdf,CODE:0d09
CODE:CODE:0961  8301            CLRF        STATUS
CODE:CODE:0962  2308            MOVF        0x23,w
CODE:CODE:0963  de38            IORLW       #0xde
CODE:CODE:0964  4906            XORWF       0x49,w
CODE:CODE:0965  0319            BTFSC       STATUS,#0x2
CODE:CODE:0966  6e29            GOTO        offset LAB_CODE_096e-0x800
CODE:CODE:0967  3230            MOVLW       #0x32
CODE:CODE:0968  8316            BSF         STATUS,RP0
CODE:CODE:0969  b300            MOVWF       0x33
CODE:CODE:096a  8312            BCF         STATUS,RP0
CODE:CODE:096b  2308            MOVF        0x23,w
CODE:CODE:096c  de38            IORLW       #0xde
CODE:CODE:096d  c900            MOVWF       0x49
                            LAB_CODE_096e:                ;XREF[1,0]:   CODE:0966
CODE:CODE:096e  2a1f            BTFSS       0x2a,#0x6
CODE:CODE:096f  b429            GOTO        offset LAB_CODE_09b4-0x800
CODE:CODE:0970  aa1b            BTFSC       0x2a,#0x7
CODE:CODE:0971  aa29            GOTO        offset LAB_CODE_09aa-0x800
CODE:CODE:0972  2b1f            BTFSS       0x2b,#0x6
CODE:CODE:0973  aa2a            GOTO        offset LAB_CODE_0aaa >>2
CODE:CODE:0974  3908            MOVF        0x39,w
CODE:CODE:0975  023a            XORLW       #0x2
CODE:CODE:0976  031d            BTFSS       STATUS,#0x2
CODE:CODE:0977  8629            GOTO        offset LAB_CODE_0986-0x800
CODE:CODE:0978  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0979  7e29            GOTO        offset LAB_CODE_097e-0x800
CODE:CODE:097a  2f13            BCF         0x2f,#0x6
CODE:CODE:097b  3230            MOVLW       #0x32
CODE:CODE:097c  8316            BSF         STATUS,RP0
CODE:CODE:097d  b300            MOVWF       0x33
                            LAB_CODE_097e:                ;XREF[1,0]:   CODE:0979
CODE:CODE:097e  8312            BCF         STATUS,RP0
CODE:CODE:097f  ad17            BSF         0x2d,#0x7
CODE:CODE:0980  3808            MOVF        0x38,w
CODE:CODE:0981  043a            XORLW       #0x4
CODE:CODE:0982  0319            BTFSC       STATUS,#0x2
CODE:CODE:0983  9429            GOTO        offset LAB_CODE_0994-0x800
CODE:CODE:0984  1930            MOVLW       #0x19
CODE:CODE:0985  7b2a            GOTO        offset LAB_CODE_0a7b-0x800
                            LAB_CODE_0986:                ;XREF[1,0]:   CODE:0977
CODE:CODE:0986  390b            DECFSZ      BANK-0:DAT_DATA_0039,w                  ;= ??
CODE:CODE:0987  aa29            GOTO        offset LAB_CODE_09aa-0x800
CODE:CODE:0988  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0989  8e29            GOTO        offset LAB_CODE_098e-0x800
CODE:CODE:098a  2f13            BCF         0x2f,#0x6
CODE:CODE:098b  3230            MOVLW       #0x32
CODE:CODE:098c  8316            BSF         STATUS,RP0
CODE:CODE:098d  b300            MOVWF       0x33
                            LAB_CODE_098e:                ;XREF[1,0]:   CODE:0989
CODE:CODE:098e  8312            BCF         STATUS,RP0
CODE:CODE:098f  ad17            BSF         0x2d,#0x7
CODE:CODE:0990  3808            MOVF        0x38,w
CODE:CODE:0991  053a            XORLW       #0x5
CODE:CODE:0992  031d            BTFSS       STATUS,#0x2
CODE:CODE:0993  9829            GOTO        offset LAB_CODE_0998-0x800
                            LAB_CODE_0994:                ;XREF[1,0]:   CODE:0983
CODE:CODE:0994  1f30            MOVLW       #0x1f
CODE:CODE:0995  c700            MOVWF       0x47
CODE:CODE:0996  2030            MOVLW       #0x20
CODE:CODE:0997  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_0998:                ;XREF[1,0]:   CODE:0993
CODE:CODE:0998  be19            BTFSC       BANK-0:DAT_DATA_003e,#0x3               ;= ??
CODE:CODE:0999  3e1d            BTFSS       0x3e,#0x2
CODE:CODE:099a  a329            GOTO        offset LAB_CODE_09a3-0x800
CODE:CODE:099b  8316            BSF         STATUS,RP0
CODE:CODE:099c  2d08            MOVF        0x2d,w
CODE:CODE:099d  023a            XORLW       #0x2
CODE:CODE:099e  031d            BTFSS       STATUS,#0x2
CODE:CODE:099f  a329            GOTO        offset LAB_CODE_09a3-0x800
CODE:CODE:09a0  1930            MOVLW       #0x19
CODE:CODE:09a1  8312            BCF         STATUS,RP0
CODE:CODE:09a2  7b2a            GOTO        offset LAB_CODE_0a7b-0x800
                            LAB_CODE_09a3:                ;XREF[2,0]:   CODE:099a,CODE:099f
CODE:CODE:09a3  d930            MOVLW       #0xd9
CODE:CODE:09a4  8312            BCF         STATUS,RP0
CODE:CODE:09a5  c700            MOVWF       0x47
CODE:CODE:09a6  0330            MOVLW       #0x3
CODE:CODE:09a7  8316            BSF         STATUS,RP0
CODE:CODE:09a8  a004            IORWF       0x20,f
CODE:CODE:09a9  aa2a            GOTO        offset LAB_CODE_0aaa >>2
                            LAB_CODE_09aa:                ;XREF[2,0]:   CODE:0971,CODE:0987
CODE:CODE:09aa  2f1f            BTFSS       BANK-0:ENTRY_DATA_UNK1,#0x6             ;= ??
CODE:CODE:09ab  b029            GOTO        offset LAB_CODE_09b0-0x800
CODE:CODE:09ac  2f13            BCF         0x2f,#0x6
CODE:CODE:09ad  3230            MOVLW       #0x32
CODE:CODE:09ae  8316            BSF         STATUS,RP0
CODE:CODE:09af  b300            MOVWF       0x33
                            LAB_CODE_09b0:                ;XREF[1,0]:   CODE:09ab
CODE:CODE:09b0  8312            BCF         STATUS,RP0
CODE:CODE:09b1  ad17            BSF         0x2d,#0x7
CODE:CODE:09b2  1e30            MOVLW       #0x1e
CODE:CODE:09b3  7b2a            GOTO        offset LAB_CODE_0a7b-0x800
                            LAB_CODE_09b4:                ;XREF[1,0]:   CODE:096f
CODE:CODE:09b4  aa18            BTFSC       BANK-0:DAT_DATA_002a,#0x1               ;= ??
CODE:CODE:09b5  a31d            BTFSS       0x23,#0x3
CODE:CODE:09b6  c329            GOTO        offset LAB_CODE_09c3-0x800
CODE:CODE:09b7  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:09b8  bd29            GOTO        offset LAB_CODE_09bd-0x800
CODE:CODE:09b9  2f13            BCF         0x2f,#0x6
CODE:CODE:09ba  3230            MOVLW       #0x32
CODE:CODE:09bb  8316            BSF         STATUS,RP0
CODE:CODE:09bc  b300            MOVWF       0x33
                            LAB_CODE_09bd:                ;XREF[1,0]:   CODE:09b8
CODE:CODE:09bd  8312            BCF         STATUS,RP0
CODE:CODE:09be  ad17            BSF         0x2d,#0x7
CODE:CODE:09bf  1630            MOVLW       #0x16
CODE:CODE:09c0  c700            MOVWF       0x47
CODE:CODE:09c1  1730            MOVLW       #0x17
CODE:CODE:09c2  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_09c3:                ;XREF[1,0]:   CODE:09b6
CODE:CODE:09c3  aa18            BTFSC       BANK-0:DAT_DATA_002a,#0x1               ;= ??
CODE:CODE:09c4  a319            BTFSC       0x23,#0x3
CODE:CODE:09c5  e229            GOTO        offset LAB_CODE_09e2-0x800
CODE:CODE:09c6  3a08            MOVF        0x3a,w
CODE:CODE:09c7  3f39            ANDLW       #0x3f
CODE:CODE:09c8  073a            XORLW       #0x7
CODE:CODE:09c9  031d            BTFSS       STATUS,#0x2
CODE:CODE:09ca  e229            GOTO        offset LAB_CODE_09e2-0x800
CODE:CODE:09cb  3b08            MOVF        0x3b,w
CODE:CODE:09cc  1f39            ANDLW       #0x1f
CODE:CODE:09cd  031d            BTFSS       STATUS,#0x2
CODE:CODE:09ce  e229            GOTO        offset LAB_CODE_09e2-0x800
CODE:CODE:09cf  3a08            MOVF        0x3a,w
CODE:CODE:09d0  3f39            ANDLW       #0x3f
CODE:CODE:09d1  073a            XORLW       #0x7
CODE:CODE:09d2  031d            BTFSS       STATUS,#0x2
CODE:CODE:09d3  dd29            GOTO        offset LAB_CODE_09dd-0x800
CODE:CODE:09d4  3b08            MOVF        0x3b,w
CODE:CODE:09d5  1f39            ANDLW       #0x1f
CODE:CODE:09d6  0319            BTFSC       STATUS,#0x2
CODE:CODE:09d7  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:09d8  dd29            GOTO        offset LAB_CODE_09dd-0x800
CODE:CODE:09d9  2f13            BCF         0x2f,#0x6
CODE:CODE:09da  3230            MOVLW       #0x32
CODE:CODE:09db  8316            BSF         STATUS,RP0
CODE:CODE:09dc  b300            MOVWF       0x33
                            LAB_CODE_09dd:                ;XREF[2,0]:   CODE:09d3,CODE:09d8
CODE:CODE:09dd  1c30            MOVLW       #0x1c
CODE:CODE:09de  8312            BCF         STATUS,RP0
CODE:CODE:09df  c700            MOVWF       0x47
CODE:CODE:09e0  1d30            MOVLW       #0x1d
CODE:CODE:09e1  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_09e2:                ;XREF[3,0]:   CODE:09c5,CODE:09ca,CODE:09ce
CODE:CODE:09e2  231e            BTFSS       BANK-0:TIMER1_UNK5,#0x4                 ;= ??
CODE:CODE:09e3  ee29            GOTO        offset LAB_CODE_09ee-0x800
CODE:CODE:09e4  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:09e5  ea29            GOTO        offset LAB_CODE_09ea-0x800
CODE:CODE:09e6  2f13            BCF         0x2f,#0x6
CODE:CODE:09e7  3230            MOVLW       #0x32
CODE:CODE:09e8  8316            BSF         STATUS,RP0
CODE:CODE:09e9  b300            MOVWF       0x33
                            LAB_CODE_09ea:                ;XREF[1,0]:   CODE:09e5
CODE:CODE:09ea  8312            BCF         STATUS,RP0
CODE:CODE:09eb  ad17            BSF         0x2d,#0x7
CODE:CODE:09ec  1530            MOVLW       #0x15
CODE:CODE:09ed  7b2a            GOTO        offset LAB_CODE_0a7b-0x800
                            LAB_CODE_09ee:                ;XREF[1,0]:   CODE:09e3
CODE:CODE:09ee  2a18            BTFSC       BANK-0:DAT_DATA_002a,#0x0               ;= ??
CODE:CODE:09ef  b018            BTFSC       0x30,#0x1
CODE:CODE:09f0  392a            GOTO        offset LAB_CODE_0a39-0x800
CODE:CODE:09f1  3a08            MOVF        0x3a,w
CODE:CODE:09f2  3f39            ANDLW       #0x3f
CODE:CODE:09f3  023a            XORLW       #0x2
CODE:CODE:09f4  031d            BTFSS       STATUS,#0x2
CODE:CODE:09f5  fd29            GOTO        offset LAB_CODE_09fd-0x800
CODE:CODE:09f6  3b08            MOVF        0x3b,w
CODE:CODE:09f7  1f39            ANDLW       #0x1f
CODE:CODE:09f8  cd00            MOVWF       0x4d
CODE:CODE:09f9  0630            MOVLW       #0x6
CODE:CODE:09fa  4d02            SUBWF       0x4d,w
CODE:CODE:09fb  031c            BTFSS       STATUS,#0x0
CODE:CODE:09fc  392a            GOTO        offset LAB_CODE_0a39-0x800
                            LAB_CODE_09fd:                ;XREF[1,0]:   CODE:09f5
CODE:CODE:09fd  3a08            MOVF        0x3a,w
CODE:CODE:09fe  3f39            ANDLW       #0x3f
CODE:CODE:09ff  073a            XORLW       #0x7
CODE:CODE:0a00  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a01  0d2a            GOTO        offset LAB_CODE_0a0d-0x800
CODE:CODE:0a02  3b08            MOVF        0x3b,w
CODE:CODE:0a03  1f39            ANDLW       #0x1f
CODE:CODE:0a04  ce00            MOVWF       0x4e
CODE:CODE:0a05  1030            MOVLW       #0x10
CODE:CODE:0a06  4e02            SUBWF       0x4e,w
CODE:CODE:0a07  0318            BTFSC       STATUS,#0x0
CODE:CODE:0a08  0d2a            GOTO        offset LAB_CODE_0a0d-0x800
CODE:CODE:0a09  3b08            MOVF        0x3b,w
CODE:CODE:0a0a  1f39            ANDLW       #0x1f
CODE:CODE:0a0b  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a0c  392a            GOTO        offset LAB_CODE_0a39-0x800
                            LAB_CODE_0a0d:                ;XREF[2,0]:   CODE:0a01,CODE:0a08
CODE:CODE:0a0d  3a08            MOVF        0x3a,w
CODE:CODE:0a0e  3f39            ANDLW       #0x3f
CODE:CODE:0a0f  0b3a            XORLW       #0xb
CODE:CODE:0a10  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a11  192a            GOTO        offset LAB_CODE_0a19-0x800
CODE:CODE:0a12  3b08            MOVF        0x3b,w
CODE:CODE:0a13  1f39            ANDLW       #0x1f
CODE:CODE:0a14  cf00            MOVWF       0x4f
CODE:CODE:0a15  0630            MOVLW       #0x6
CODE:CODE:0a16  4f02            SUBWF       0x4f,w
CODE:CODE:0a17  031c            BTFSS       STATUS,#0x0
CODE:CODE:0a18  392a            GOTO        offset LAB_CODE_0a39-0x800
                            LAB_CODE_0a19:                ;XREF[1,0]:   CODE:0a11
CODE:CODE:0a19  3a08            MOVF        0x3a,w
CODE:CODE:0a1a  3f39            ANDLW       #0x3f
CODE:CODE:0a1b  083a            XORLW       #0x8
CODE:CODE:0a1c  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a1d  252a            GOTO        offset LAB_CODE_0a25-0x800
CODE:CODE:0a1e  3b08            MOVF        0x3b,w
CODE:CODE:0a1f  1f39            ANDLW       #0x1f
CODE:CODE:0a20  d000            MOVWF       0x50
CODE:CODE:0a21  0a30            MOVLW       #0xa
CODE:CODE:0a22  5002            SUBWF       0x50,w
CODE:CODE:0a23  031c            BTFSS       STATUS,#0x0
CODE:CODE:0a24  392a            GOTO        offset LAB_CODE_0a39-0x800
                            LAB_CODE_0a25:                ;XREF[1,0]:   CODE:0a1d
CODE:CODE:0a25  3a08            MOVF        0x3a,w
CODE:CODE:0a26  3f39            ANDLW       #0x3f
CODE:CODE:0a27  013a            XORLW       #0x1
CODE:CODE:0a28  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a29  2f2a            GOTO        offset LAB_CODE_0a2f-0x800
CODE:CODE:0a2a  3b08            MOVF        0x3b,w
CODE:CODE:0a2b  1f39            ANDLW       #0x1f
CODE:CODE:0a2c  053a            XORLW       #0x5
CODE:CODE:0a2d  0319            BTFSC       STATUS,#0x2
CODE:CODE:0a2e  392a            GOTO        offset LAB_CODE_0a39-0x800
                            LAB_CODE_0a2f:                ;XREF[1,0]:   CODE:0a29
CODE:CODE:0a2f  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0a30  352a            GOTO        offset LAB_CODE_0a35-0x800
CODE:CODE:0a31  2f13            BCF         0x2f,#0x6
CODE:CODE:0a32  3230            MOVLW       #0x32
CODE:CODE:0a33  8316            BSF         STATUS,RP0
CODE:CODE:0a34  b300            MOVWF       0x33
                            LAB_CODE_0a35:                ;XREF[1,0]:   CODE:0a30
CODE:CODE:0a35  8312            BCF         STATUS,RP0
CODE:CODE:0a36  ad17            BSF         0x2d,#0x7
CODE:CODE:0a37  1b30            MOVLW       #0x1b
CODE:CODE:0a38  7b2a            GOTO        offset LAB_CODE_0a7b-0x800
                            LAB_CODE_0a39:                ;XREF[6,0]:   CODE:09f0,CODE:09fc,CODE:0a0c,CODE:0a18
                                                          ;             CODE:0a24,CODE:0a2e
CODE:CODE:0a39  aa1e            BTFSS       BANK-0:DAT_DATA_002a,#0x5               ;= ??
CODE:CODE:0a3a  672a            GOTO        offset LAB_CODE_0a67-0x800
CODE:CODE:0a3b  3a08            MOVF        0x3a,w
CODE:CODE:0a3c  3f39            ANDLW       #0x3f
CODE:CODE:0a3d  073a            XORLW       #0x7
CODE:CODE:0a3e  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a3f  672a            GOTO        offset LAB_CODE_0a67-0x800
CODE:CODE:0a40  3b08            MOVF        0x3b,w
CODE:CODE:0a41  1f39            ANDLW       #0x1f
CODE:CODE:0a42  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a43  672a            GOTO        offset LAB_CODE_0a67-0x800
CODE:CODE:0a44  3a08            MOVF        0x3a,w
CODE:CODE:0a45  3f39            ANDLW       #0x3f
CODE:CODE:0a46  073a            XORLW       #0x7
CODE:CODE:0a47  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a48  522a            GOTO        offset LAB_CODE_0a52-0x800
CODE:CODE:0a49  3b08            MOVF        0x3b,w
CODE:CODE:0a4a  1f39            ANDLW       #0x1f
CODE:CODE:0a4b  0319            BTFSC       STATUS,#0x2
CODE:CODE:0a4c  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0a4d  522a            GOTO        offset LAB_CODE_0a52-0x800
CODE:CODE:0a4e  2f13            BCF         0x2f,#0x6
CODE:CODE:0a4f  3230            MOVLW       #0x32
CODE:CODE:0a50  8316            BSF         STATUS,RP0
CODE:CODE:0a51  b300            MOVWF       0x33
                            LAB_CODE_0a52:                ;XREF[2,0]:   CODE:0a48,CODE:0a4d
CODE:CODE:0a52  8312            BCF         STATUS,RP0
CODE:CODE:0a53  3c08            MOVF        0x3c,w
CODE:CODE:0a54  7039            ANDLW       #0x70
CODE:CODE:0a55  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a56  5b2a            GOTO        offset LAB_CODE_0a5b-0x800
CODE:CODE:0a57  3530            MOVLW       #0x35
CODE:CODE:0a58  c700            MOVWF       0x47
CODE:CODE:0a59  3630            MOVLW       #0x36
CODE:CODE:0a5a  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_0a5b:                ;XREF[1,0]:   CODE:0a56
CODE:CODE:0a5b  2f1f            BTFSS       BANK-0:ENTRY_DATA_UNK1,#0x6             ;= ??
CODE:CODE:0a5c  612a            GOTO        offset LAB_CODE_0a61-0x800
CODE:CODE:0a5d  2f13            BCF         0x2f,#0x6
CODE:CODE:0a5e  3230            MOVLW       #0x32
CODE:CODE:0a5f  8316            BSF         STATUS,RP0
CODE:CODE:0a60  b300            MOVWF       0x33
                            LAB_CODE_0a61:                ;XREF[1,0]:   CODE:0a5c
CODE:CODE:0a61  8312            BCF         STATUS,RP0
CODE:CODE:0a62  ad17            BSF         0x2d,#0x7
CODE:CODE:0a63  3330            MOVLW       #0x33
CODE:CODE:0a64  c700            MOVWF       0x47
CODE:CODE:0a65  3430            MOVLW       #0x34
CODE:CODE:0a66  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_0a67:                ;XREF[3,0]:   CODE:0a3a,CODE:0a3f,CODE:0a43
CODE:CODE:0a67  ab1e            BTFSS       BANK-0:DAT_DATA_002b,#0x5               ;= ??
CODE:CODE:0a68  7d2a            GOTO        offset LAB_CODE_0a7d-0x800
CODE:CODE:0a69  3a08            MOVF        0x3a,w
CODE:CODE:0a6a  3f39            ANDLW       #0x3f
CODE:CODE:0a6b  073a            XORLW       #0x7
CODE:CODE:0a6c  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a6d  7d2a            GOTO        offset LAB_CODE_0a7d-0x800
CODE:CODE:0a6e  3b08            MOVF        0x3b,w
CODE:CODE:0a6f  1f39            ANDLW       #0x1f
CODE:CODE:0a70  031d            BTFSS       STATUS,#0x2
CODE:CODE:0a71  7d2a            GOTO        offset LAB_CODE_0a7d-0x800
CODE:CODE:0a72  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0a73  782a            GOTO        offset LAB_CODE_0a78-0x800
CODE:CODE:0a74  2f13            BCF         0x2f,#0x6
CODE:CODE:0a75  3230            MOVLW       #0x32
CODE:CODE:0a76  8316            BSF         STATUS,RP0
CODE:CODE:0a77  b300            MOVWF       0x33
                            LAB_CODE_0a78:                ;XREF[1,0]:   CODE:0a73
CODE:CODE:0a78  8312            BCF         STATUS,RP0
CODE:CODE:0a79  ad17            BSF         0x2d,#0x7
CODE:CODE:0a7a  2130            MOVLW       #0x21
                            LAB_CODE_0a7b:                ;XREF[5,0]:   CODE:0985,CODE:09a2,CODE:09b3,CODE:09ed
                                                          ;             CODE:0a38
CODE:CODE:0a7b  c700            MOVWF       BANK-0:DAT_DATA_0047                    ;= ??
CODE:CODE:0a7c  aa2a            GOTO        offset LAB_CODE_0aaa >>2
                            LAB_CODE_0a7d:                ;XREF[3,0]:   CODE:0a68,CODE:0a6d,CODE:0a71
CODE:CODE:0a7d  2a1e            BTFSS       BANK-0:DAT_DATA_002a,#0x4               ;= ??
CODE:CODE:0a7e  ac2a            GOTO        offset LAB_CODE_0aac-0x800
CODE:CODE:0a7f  3a08            MOVF        0x3a,w
CODE:CODE:0a80  3f39            ANDLW       #0x3f
CODE:CODE:0a81  043a            XORLW       #0x4
CODE:CODE:0a82  0319            BTFSC       STATUS,#0x2
CODE:CODE:0a83  ac2a            GOTO        offset LAB_CODE_0aac-0x800
CODE:CODE:0a84  3a08            MOVF        0x3a,w
CODE:CODE:0a85  3f39            ANDLW       #0x3f
CODE:CODE:0a86  033a            XORLW       #0x3
CODE:CODE:0a87  0319            BTFSC       STATUS,#0x2
CODE:CODE:0a88  ac2a            GOTO        offset LAB_CODE_0aac-0x800
CODE:CODE:0a89  3a08            MOVF        0x3a,w
CODE:CODE:0a8a  3f39            ANDLW       #0x3f
CODE:CODE:0a8b  013a            XORLW       #0x1
CODE:CODE:0a8c  0319            BTFSC       STATUS,#0x2
CODE:CODE:0a8d  ac2a            GOTO        offset LAB_CODE_0aac-0x800
CODE:CODE:0a8e  2f1f            BTFSS       0x2f,#0x6
CODE:CODE:0a8f  942a            GOTO        offset LAB_CODE_0a94-0x800
CODE:CODE:0a90  2f13            BCF         0x2f,#0x6
CODE:CODE:0a91  3230            MOVLW       #0x32
CODE:CODE:0a92  8316            BSF         STATUS,RP0
CODE:CODE:0a93  b300            MOVWF       0x33
                            LAB_CODE_0a94:                ;XREF[1,0]:   CODE:0a8f
CODE:CODE:0a94  8312            BCF         STATUS,RP0
CODE:CODE:0a95  ad17            BSF         0x2d,#0x7
CODE:CODE:0a96  0130            MOVLW       #0x1
CODE:CODE:0a97  8316            BSF         STATUS,RP0
CODE:CODE:0a98  a000            MOVWF       0x20
CODE:CODE:0a99  8312            BCF         STATUS,RP0
CODE:CODE:0a9a  ae16            BSF         0x2e,#0x5
CODE:CODE:0a9b  1e30            MOVLW       #0x1e
CODE:CODE:0a9c  8316            BSF         STATUS,RP0
CODE:CODE:0a9d  4b02            SUBWF       0x4b,w
CODE:CODE:0a9e  031c            BTFSS       STATUS,#0x0
CODE:CODE:0a9f  a52a            GOTO        offset LAB_CODE_0aa5-0x800
CODE:CODE:0aa0  2230            MOVLW       #0x22
CODE:CODE:0aa1  8312            BCF         STATUS,RP0
CODE:CODE:0aa2  c700            MOVWF       0x47
CODE:CODE:0aa3  2330            MOVLW       #0x23
CODE:CODE:0aa4  a92a            GOTO        offset LAB_CODE_0aa9-0x800
                            LAB_CODE_0aa5:                ;XREF[1,0]:   CODE:0a9f
CODE:CODE:0aa5  4130            MOVLW       #0x41
CODE:CODE:0aa6  8312            BCF         STATUS,RP0
CODE:CODE:0aa7  c700            MOVWF       0x47
CODE:CODE:0aa8  4230            MOVLW       #0x42
                            LAB_CODE_0aa9:                ;XREF[6,0]:   CODE:0997,CODE:09c2,CODE:09e1,CODE:0a5a
                                                          ;             CODE:0a66,CODE:0aa4
CODE:CODE:0aa9  c800            MOVWF       BANK-0:DAT_DATA_0048                    ;= ??
                            LAB_CODE_0aaa:                ;XREF[3,0]:   CODE:0973,CODE:09a9,CODE:0a7c
CODE:CODE:0aaa  0130            MOVLW       #0x1
CODE:CODE:0aab  c42a            GOTO        offset LAB_CODE_0ac4-0x800
                            LAB_CODE_0aac:                ;XREF[4,0]:   CODE:0a7e,CODE:0a83,CODE:0a88,CODE:0a8d
CODE:CODE:0aac  2a1d            BTFSS       BANK-0:DAT_DATA_002a,#0x2               ;= ??
CODE:CODE:0aad  b92a            GOTO        offset LAB_CODE_0ab9-0x800
CODE:CODE:0aae  3a08            MOVF        0x3a,w
CODE:CODE:0aaf  3f39            ANDLW       #0x3f
CODE:CODE:0ab0  073a            XORLW       #0x7
CODE:CODE:0ab1  031d            BTFSS       STATUS,#0x2
CODE:CODE:0ab2  b92a            GOTO        offset LAB_CODE_0ab9-0x800
CODE:CODE:0ab3  3b08            MOVF        0x3b,w
CODE:CODE:0ab4  1f39            ANDLW       #0x1f
CODE:CODE:0ab5  031d            BTFSS       STATUS,#0x2
CODE:CODE:0ab6  b92a            GOTO        offset LAB_CODE_0ab9-0x800
CODE:CODE:0ab7  bb1f            BTFSS       0x3b,#0x7
CODE:CODE:0ab8  c32a            GOTO        offset LAB_CODE_0ac3-0x800
                            LAB_CODE_0ab9:                ;XREF[3,0]:   CODE:0aad,CODE:0ab2,CODE:0ab6
CODE:CODE:0ab9  aa19            BTFSC       0x2a,#0x3
CODE:CODE:0aba  c32a            GOTO        offset LAB_CODE_0ac3-0x800
CODE:CODE:0abb  ad1f            BTFSS       0x2d,#0x7
CODE:CODE:0abc  c12a            GOTO        offset LAB_CODE_0ac1-0x800
CODE:CODE:0abd  ad13            BCF         0x2d,#0x7
CODE:CODE:0abe  3230            MOVLW       #0x32
CODE:CODE:0abf  8316            BSF         STATUS,RP0
CODE:CODE:0ac0  b300            MOVWF       0x33
                            LAB_CODE_0ac1:                ;XREF[1,0]:   CODE:0abc
CODE:CODE:0ac1  8312            BCF         STATUS,RP0
CODE:CODE:0ac2  2f17            BSF         0x2f,#0x6
                            LAB_CODE_0ac3:                ;XREF[2,0]:   CODE:0ab8,CODE:0aba
CODE:CODE:0ac3  0030            MOVLW       #0x0
                            LAB_CODE_0ac4:                ;XREF[1,0]:   CODE:0aab
CODE:CODE:0ac4  8312            BCF         STATUS,RP0
CODE:CODE:0ac5  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined MAINLOOP_MAIN_LOGIC()
                                                          ;XREF[1,0]:   CODE:1043
CODE:CODE:0ac6  c830            MOVLW       #0xc8
CODE:CODE:0ac7  8301            CLRF        STATUS
CODE:CODE:0ac8  c700            MOVWF       0x47
CODE:CODE:0ac9  c800            MOVWF       0x48
CODE:CODE:0aca  ae11            BCF         0x2e,#0x3
CODE:CODE:0acb  ae12            BCF         0x2e,#0x5
CODE:CODE:0acc  8316            BSF         STATUS,RP0
CODE:CODE:0acd  0317            BSF         STATUS,RP1
CODE:CODE:0ace  9013            BCF         0x10,#0x7
CODE:CODE:0acf  4530            MOVLW       #0x45
CODE:CODE:0ad0  0313            BCF         STATUS,RP1
CODE:CODE:0ad1  b100            MOVWF       0x31
CODE:CODE:0ad2  ce08            MOVF        0x4e,f
CODE:CODE:0ad3  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ad4  d72a            GOTO        offset LAB_CODE_0ad7-0x800
CODE:CODE:0ad5  d730            MOVLW       #0xd7
CODE:CODE:0ad6  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0ad7:                ;XREF[1,0]:   CODE:0ad4
CODE:CODE:0ad7  8312            BCF         STATUS,RP0
CODE:CODE:0ad8  ae1b            BTFSC       0x2e,#0x7
CODE:CODE:0ad9  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0ada  ac13            BCF         0x2c,#0x7
CODE:CODE:0adb  af12            BCF         0x2f,#0x5
CODE:CODE:0adc  8316            BSF         STATUS,RP0
CODE:CODE:0add  a001            CLRF        0x20
CODE:CODE:0ade  b201            CLRF        0x32
CODE:CODE:0adf  812e            GOTO        offset BGT2_Jumper_pre-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 10                                   *
                            ;************************************************************************************************
                            BGT2_10:                      ;XREF[1,0]:   CODE:0ea5
CODE:CODE:0ae0  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0ae1  0038            IORLW       #0x0
CODE:CODE:0ae2  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ae3  e62a            GOTO        offset LAB_CODE_0ae6-0x800
CODE:CODE:0ae4  2a1b            BTFSC       0x2a,#0x6
CODE:CODE:0ae5  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0ae6:                ;XREF[1,0]:   CODE:0ae3
CODE:CODE:0ae6  b010            BCF         0x30,#0x1
CODE:CODE:0ae7  3b08            MOVF        0x3b,w
CODE:CODE:0ae8  1f39            ANDLW       #0x1f
CODE:CODE:0ae9  0319            BTFSC       STATUS,#0x2
CODE:CODE:0aea  f02a            GOTO        offset LAB_CODE_0af0-0x800
CODE:CODE:0aeb  3b08            MOVF        0x3b,w
CODE:CODE:0aec  1f39            ANDLW       #0x1f
CODE:CODE:0aed  013a            XORLW       #0x1
CODE:CODE:0aee  031d            BTFSS       STATUS,#0x2
CODE:CODE:0aef  f42a            GOTO        offset LAB_CODE_0af4-0x800
                            LAB_CODE_0af0:                ;XREF[1,0]:   CODE:0aea
CODE:CODE:0af0  3830            MOVLW       #0x38
CODE:CODE:0af1  c700            MOVWF       0x47
CODE:CODE:0af2  3930            MOVLW       #0x39
CODE:CODE:0af3  8e2c            GOTO        offset LAB_CODE_0c8e-0x800
                            LAB_CODE_0af4:                ;XREF[1,0]:   CODE:0aef
CODE:CODE:0af4  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0af5  1f39            ANDLW       #0x1f
CODE:CODE:0af6  023a            XORLW       #0x2
CODE:CODE:0af7  031d            BTFSS       STATUS,#0x2
CODE:CODE:0af8  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0af9  3a30            MOVLW       #0x3a
CODE:CODE:0afa  002e            GOTO        offset LAB_CODE_0e00-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 11                                   *
                            ;************************************************************************************************
                            BGT2_11:                      ;XREF[1,0]:   CODE:0ea6
CODE:CODE:0afb  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0afc  0038            IORLW       #0x0
CODE:CODE:0afd  031d            BTFSS       STATUS,#0x2
CODE:CODE:0afe  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0aff  b010            BCF         0x30,#0x1
CODE:CODE:0b00  092b            GOTO        offset LAB_CODE_0b09-0x800
                            LAB_CODE_0b01:                ;XREF[1,0]:   CODE:0b14
CODE:CODE:0b01  2318            BTFSC       BANK-0:TIMER1_UNK5,#0x0                 ;= ??
CODE:CODE:0b02  072b            GOTO        offset LAB_CODE_0b07-0x800
CODE:CODE:0b03  2d30            MOVLW       #0x2d
CODE:CODE:0b04  c700            MOVWF       0x47
CODE:CODE:0b05  2e30            MOVLW       #0x2e
CODE:CODE:0b06  8e2c            GOTO        offset LAB_CODE_0c8e-0x800
                            LAB_CODE_0b07:                ;XREF[1,0]:   CODE:0b02
CODE:CODE:0b07  1430            MOVLW       #0x14
CODE:CODE:0b08  8c2c            GOTO        offset LAB_CODE_0c8c-0x800
                            LAB_CODE_0b09:                ;XREF[1,0]:   CODE:0b00
CODE:CODE:0b09  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0b0a  1f39            ANDLW       #0x1f
CODE:CODE:0b0b  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:0b0c  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:0b0d  162b            GOTO        offset LAB_CODE_0b16-0x800
                            LAB_CODE_0b0e:                ;XREF[1,0]:   CODE:0b19
CODE:CODE:0b0e  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0b0f  003a            XORLW       #0x0
CODE:CODE:0b10  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b11  632c            GOTO        offset LAB_CODE_0c63-0x800
CODE:CODE:0b12  013a            XORLW       #0x1
CODE:CODE:0b13  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b14  012b            GOTO        offset LAB_CODE_0b01-0x800
CODE:CODE:0b15  282b            GOTO        offset LAB_CODE_0b28-0x800
                            LAB_CODE_0b16:                ;XREF[1,0]:   CODE:0b0d
CODE:CODE:0b16  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0b17  003a            XORLW       #0x0
CODE:CODE:0b18  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b19  0e2b            GOTO        offset LAB_CODE_0b0e-0x800
CODE:CODE:0b1a  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 12                                   *
                            ;************************************************************************************************
                            BGT2_12:                      ;XREF[1,0]:   CODE:0ea7
CODE:CODE:0b1b  b010            BCF         BANK-0:DAT_DATA_0030,#0x1               ;= ??
CODE:CODE:0b1c  3b08            MOVF        0x3b,w
CODE:CODE:0b1d  1f39            ANDLW       #0x1f
CODE:CODE:0b1e  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:0b1f  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:0b20  2c2b            GOTO        offset LAB_CODE_0b2c-0x800
                            LAB_CODE_0b21:                ;XREF[1,0]:   CODE:0b2f
CODE:CODE:0b21  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0b22  003a            XORLW       #0x0
CODE:CODE:0b23  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b24  632c            GOTO        offset LAB_CODE_0c63-0x800
CODE:CODE:0b25  013a            XORLW       #0x1
CODE:CODE:0b26  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b27  ec2c            GOTO        offset LAB_CODE_0cec-0x800
                            LAB_CODE_0b28:                ;XREF[1,0]:   CODE:0b15
CODE:CODE:0b28  033a            XORLW       #0x3
CODE:CODE:0b29  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b2a  632c            GOTO        offset LAB_CODE_0c63-0x800
CODE:CODE:0b2b  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0b2c:                ;XREF[1,0]:   CODE:0b20
CODE:CODE:0b2c  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0b2d  003a            XORLW       #0x0
CODE:CODE:0b2e  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b2f  212b            GOTO        offset LAB_CODE_0b21-0x800
CODE:CODE:0b30  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 1                                    *
                            ;************************************************************************************************
                            BGT2_1:                       ;XREF[1,0]:   CODE:0e98
CODE:CODE:0b31  b010            BCF         BANK-0:DAT_DATA_0030,#0x1               ;= ??
CODE:CODE:0b32  8316            BSF         STATUS,RP0
CODE:CODE:0b33  0317            BSF         STATUS,RP1
CODE:CODE:0b34  9017            BSF         0x10,#0x7
CODE:CODE:0b35  0313            BCF         STATUS,RP1
CODE:CODE:0b36  b808            MOVF        0x38,f
CODE:CODE:0b37  0317            BSF         STATUS,RP1
CODE:CODE:0b38  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b39  1012            BCF         0x10,#0x4
CODE:CODE:0b3a  8312            BCF         STATUS,RP0
CODE:CODE:0b3b  0313            BCF         STATUS,RP1
CODE:CODE:0b3c  a31d            BTFSS       0x23,#0x3
CODE:CODE:0b3d  492b            GOTO        offset LAB_CODE_0b49-0x800
CODE:CODE:0b3e  0a30            MOVLW       #0xa
CODE:CODE:0b3f  8316            BSF         STATUS,RP0
CODE:CODE:0b40  b800            MOVWF       0x38
CODE:CODE:0b41  0317            BSF         STATUS,RP1
CODE:CODE:0b42  1016            BSF         0x10,#0x4
CODE:CODE:0b43  1630            MOVLW       #0x16
CODE:CODE:0b44  8312            BCF         STATUS,RP0
CODE:CODE:0b45  0313            BCF         STATUS,RP1
CODE:CODE:0b46  c700            MOVWF       0x47
CODE:CODE:0b47  1730            MOVLW       #0x17
CODE:CODE:0b48  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0b49:                ;XREF[1,0]:   CODE:0b3d
CODE:CODE:0b49  231e            BTFSS       BANK-0:TIMER1_UNK5,#0x4                 ;= ??
CODE:CODE:0b4a  542b            GOTO        offset LAB_CODE_0b54-0x800
CODE:CODE:0b4b  0a30            MOVLW       #0xa
CODE:CODE:0b4c  8316            BSF         STATUS,RP0
CODE:CODE:0b4d  b800            MOVWF       0x38
CODE:CODE:0b4e  0317            BSF         STATUS,RP1
CODE:CODE:0b4f  1016            BSF         0x10,#0x4
CODE:CODE:0b50  1530            MOVLW       #0x15
CODE:CODE:0b51  8312            BCF         STATUS,RP0
CODE:CODE:0b52  0313            BCF         STATUS,RP1
CODE:CODE:0b53  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0b54:                ;XREF[1,0]:   CODE:0b4a
CODE:CODE:0b54  2e1f            BTFSS       BANK-0:DAT_DATA_002e,#0x6               ;= ??
CODE:CODE:0b55  5f2b            GOTO        offset LAB_CODE_0b5f-0x800
CODE:CODE:0b56  8316            BSF         STATUS,RP0
CODE:CODE:0b57  ad08            MOVF        0x2d,f
CODE:CODE:0b58  0319            BTFSC       STATUS,#0x2
CODE:CODE:0b59  5f2b            GOTO        offset LAB_CODE_0b5f-0x800
CODE:CODE:0b5a  0a30            MOVLW       #0xa
CODE:CODE:0b5b  b800            MOVWF       0x38
CODE:CODE:0b5c  0317            BSF         STATUS,RP1
CODE:CODE:0b5d  1016            BSF         0x10,#0x4
CODE:CODE:0b5e  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0b5f:                ;XREF[2,0]:   CODE:0b55,CODE:0b59
CODE:CODE:0b5f  8312            BCF         STATUS,RP0
CODE:CODE:0b60  3b08            MOVF        0x3b,w
CODE:CODE:0b61  1f39            ANDLW       #0x1f
CODE:CODE:0b62  cc00            MOVWF       0x4c
CODE:CODE:0b63  0230            MOVLW       #0x2
CODE:CODE:0b64  4c02            SUBWF       0x4c,w
CODE:CODE:0b65  0318            BTFSC       STATUS,#0x0
CODE:CODE:0b66  6f2b            GOTO        offset LAB_CODE_0b6f-0x800
CODE:CODE:0b67  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0b68  0038            IORLW       #0x0
CODE:CODE:0b69  031d            BTFSS       STATUS,#0x2
CODE:CODE:0b6a  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0b6b  1330            MOVLW       #0x13
CODE:CODE:0b6c  c700            MOVWF       0x47
CODE:CODE:0b6d  ff30            MOVLW       #0xff
CODE:CODE:0b6e  902c            GOTO        offset LAB_CODE_0c90-0x800
                            LAB_CODE_0b6f:                ;XREF[1,0]:   CODE:0b66
CODE:CODE:0b6f  2e1f            BTFSS       BANK-0:DAT_DATA_002e,#0x6               ;= ??
CODE:CODE:0b70  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0b71  8316            BSF         STATUS,RP0
CODE:CODE:0b72  2108            MOVF        0x21,w
CODE:CODE:0b73  a200            MOVWF       0x22
CODE:CODE:0b74  2b08            MOVF        0x2b,w
CODE:CODE:0b75  ac00            MOVWF       0x2c
CODE:CODE:0b76  0130            MOVLW       #0x1
CODE:CODE:0b77  0a16            BSF         PCLATH,#0x4
CODE:CODE:0b78  8a11            BCF         PCLATH,#0x3
CODE:CODE:0b79  4820            CALL        offset MAINLOOP_MAIN_LOGIC_SUB1 &0xff   ;undefined MAINLOOP_MAIN_LOGIC_SUB1()
CODE:CODE:0b7a  0a12            BCF         PCLATH,#0x4
CODE:CODE:0b7b  8a15            BSF         PCLATH,#0x3
CODE:CODE:0b7c  ac17            BSF         0x2c,#0x7
CODE:CODE:0b7d  b61c            BTFSS       0x36,#0x1
CODE:CODE:0b7e  812b            GOTO        offset LAB_CODE_0b81-0x800
CODE:CODE:0b7f  0730            MOVLW       #0x7
CODE:CODE:0b80  692e            GOTO        offset LAB_CODE_0e69-0x800
                            LAB_CODE_0b81:                ;XREF[1,0]:   CODE:0b7e
CODE:CODE:0b81  0630            MOVLW       #0x6
CODE:CODE:0b82  692e            GOTO        offset LAB_CODE_0e69-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 2                                    *
                            ;************************************************************************************************
                            BGT2_2:                       ;XREF[2,0]:   CODE:0e99,CODE:0ea0
CODE:CODE:0b83  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0b84  0038            IORLW       #0x0
CODE:CODE:0b85  031d            BTFSS       STATUS,#0x2
CODE:CODE:0b86  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0b87  3a08            MOVF        0x3a,w
CODE:CODE:0b88  3f39            ANDLW       #0x3f
CODE:CODE:0b89  083a            XORLW       #0x8
CODE:CODE:0b8a  031d            BTFSS       STATUS,#0x2
CODE:CODE:0b8b  962b            GOTO        offset LAB_CODE_0b96-0x800
CODE:CODE:0b8c  b014            BSF         0x30,#0x1
CODE:CODE:0b8d  3b08            MOVF        0x3b,w
CODE:CODE:0b8e  1f39            ANDLW       #0x1f
CODE:CODE:0b8f  cc00            MOVWF       0x4c
CODE:CODE:0b90  0530            MOVLW       #0x5
CODE:CODE:0b91  4c02            SUBWF       0x4c,w
CODE:CODE:0b92  1a30            MOVLW       #0x1a
CODE:CODE:0b93  0318            BTFSC       STATUS,#0x0
CODE:CODE:0b94  182d            GOTO        offset LAB_CODE_0d18-0x800
CODE:CODE:0b95  142d            GOTO        offset LAB_CODE_0d14-0x800
                            LAB_CODE_0b96:                ;XREF[1,0]:   CODE:0b8b
CODE:CODE:0b96  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0b97  1f39            ANDLW       #0x1f
CODE:CODE:0b98  cc00            MOVWF       0x4c
CODE:CODE:0b99  0830            MOVLW       #0x8
CODE:CODE:0b9a  4c02            SUBWF       0x4c,w
CODE:CODE:0b9b  0318            BTFSC       STATUS,#0x0
CODE:CODE:0b9c  9f2b            GOTO        offset LAB_CODE_0b9f-0x800
CODE:CODE:0b9d  b014            BSF         0x30,#0x1
CODE:CODE:0b9e  a02b            GOTO        offset LAB_CODE_0ba0-0x800
                            LAB_CODE_0b9f:                ;XREF[1,0]:   CODE:0b9c
CODE:CODE:0b9f  b010            BCF         BANK-0:DAT_DATA_0030,#0x1               ;= ??
                            LAB_CODE_0ba0:                ;XREF[1,0]:   CODE:0b9e
CODE:CODE:0ba0  2e11            BCF         0x2e,#0x2
CODE:CODE:0ba1  3b08            MOVF        0x3b,w
CODE:CODE:0ba2  1f39            ANDLW       #0x1f
CODE:CODE:0ba3  053a            XORLW       #0x5
CODE:CODE:0ba4  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ba5  bc1f            BTFSS       0x3c,#0x7
CODE:CODE:0ba6  a82b            GOTO        offset LAB_CODE_0ba8-0x800
CODE:CODE:0ba7  2e15            BSF         0x2e,#0x2
                            LAB_CODE_0ba8:                ;XREF[1,0]:   CODE:0ba6
CODE:CODE:0ba8  2e1d            BTFSS       0x2e,#0x2
CODE:CODE:0ba9  132d            GOTO        offset LAB_CODE_0d13-0x800
CODE:CODE:0baa  af16            BSF         0x2f,#0x5
CODE:CODE:0bab  872c            GOTO        offset LAB_CODE_0c87-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 3                                    *
                            ;************************************************************************************************
                            BGT2_3:                       ;XREF[1,0]:   CODE:0e9a
CODE:CODE:0bac  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0bad  0038            IORLW       #0x0
CODE:CODE:0bae  031d            BTFSS       STATUS,#0x2
CODE:CODE:0baf  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0bb0  b014            BSF         0x30,#0x1
CODE:CODE:0bb1  2c30            MOVLW       #0x2c
CODE:CODE:0bb2  142d            GOTO        offset LAB_CODE_0d14-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 6                                    *
                            ;************************************************************************************************
                            BGT2_6:                       ;XREF[1,0]:   CODE:0e9f
CODE:CODE:0bb3  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0bb4  0038            IORLW       #0x0
CODE:CODE:0bb5  031d            BTFSS       STATUS,#0x2
CODE:CODE:0bb6  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0bb7  b010            BCF         0x30,#0x1
CODE:CODE:0bb8  3b08            MOVF        0x3b,w
CODE:CODE:0bb9  1f39            ANDLW       #0x1f
CODE:CODE:0bba  031d            BTFSS       STATUS,#0x2
CODE:CODE:0bbb  0b2c            GOTO        offset LAB_CODE_0c0b-0x800
CODE:CODE:0bbc  3c08            MOVF        0x3c,w
CODE:CODE:0bbd  0e39            ANDLW       #0xe
CODE:CODE:0bbe  ca00            MOVWF       0x4a
CODE:CODE:0bbf  cb2b            GOTO        offset LAB_CODE_0bcb-0x800
                            LAB_CODE_0bc0:                ;XREF[1,0]:   CODE:0bce
CODE:CODE:0bc0  2a30            MOVLW       #0x2a
CODE:CODE:0bc1  c92b            GOTO        offset LAB_CODE_0bc9-0x800
                            LAB_CODE_0bc2:                ;XREF[1,0]:   CODE:0bd1
CODE:CODE:0bc2  5630            MOVLW       #0x56
CODE:CODE:0bc3  c92b            GOTO        offset LAB_CODE_0bc9-0x800
                            LAB_CODE_0bc4:                ;XREF[1,0]:   CODE:0bd4
CODE:CODE:0bc4  6030            MOVLW       #0x60
CODE:CODE:0bc5  c92b            GOTO        offset LAB_CODE_0bc9-0x800
                            LAB_CODE_0bc6:                ;XREF[1,0]:   CODE:0bd7
CODE:CODE:0bc6  6130            MOVLW       #0x61
CODE:CODE:0bc7  c92b            GOTO        offset LAB_CODE_0bc9-0x800
                            LAB_CODE_0bc8:                ;XREF[1,0]:   CODE:0bda
CODE:CODE:0bc8  6230            MOVLW       #0x62
                            LAB_CODE_0bc9:                ;XREF[4,0]:   CODE:0bc1,CODE:0bc3,CODE:0bc5,CODE:0bc7
CODE:CODE:0bc9  c700            MOVWF       0x47
CODE:CODE:0bca  db2b            GOTO        offset LAB_CODE_0bdb-0x800
                            LAB_CODE_0bcb:                ;XREF[1,0]:   CODE:0bbf
CODE:CODE:0bcb  4a08            MOVF        BANK-0:DAT_DATA_004a,w                  ;= ??
CODE:CODE:0bcc  003a            XORLW       #0x0
CODE:CODE:0bcd  0319            BTFSC       STATUS,#0x2
CODE:CODE:0bce  c02b            GOTO        offset LAB_CODE_0bc0-0x800
CODE:CODE:0bcf  023a            XORLW       #0x2
CODE:CODE:0bd0  0319            BTFSC       STATUS,#0x2
CODE:CODE:0bd1  c22b            GOTO        offset LAB_CODE_0bc2-0x800
CODE:CODE:0bd2  063a            XORLW       #0x6
CODE:CODE:0bd3  0319            BTFSC       STATUS,#0x2
CODE:CODE:0bd4  c42b            GOTO        offset LAB_CODE_0bc4-0x800
CODE:CODE:0bd5  023a            XORLW       #0x2
CODE:CODE:0bd6  0319            BTFSC       STATUS,#0x2
CODE:CODE:0bd7  c62b            GOTO        offset LAB_CODE_0bc6-0x800
CODE:CODE:0bd8  0e3a            XORLW       #0xe
CODE:CODE:0bd9  0319            BTFSC       STATUS,#0x2
CODE:CODE:0bda  c82b            GOTO        offset LAB_CODE_0bc8-0x800
                            LAB_CODE_0bdb:                ;XREF[1,0]:   CODE:0bca
CODE:CODE:0bdb  3c1f            BTFSS       0x3c,#0x6
CODE:CODE:0bdc  df2b            GOTO        offset LAB_CODE_0bdf-0x800
CODE:CODE:0bdd  1430            MOVLW       #0x14
CODE:CODE:0bde  c800            MOVWF       0x48
                            LAB_CODE_0bdf:                ;XREF[1,0]:   CODE:0bdc
CODE:CODE:0bdf  3c08            MOVF        0x3c,w
CODE:CODE:0be0  7039            ANDLW       #0x70
CODE:CODE:0be1  031d            BTFSS       STATUS,#0x2
CODE:CODE:0be2  e52b            GOTO        offset LAB_CODE_0be5-0x800
CODE:CODE:0be3  2d1c            BTFSS       0x2d,#0x0
CODE:CODE:0be4  ee2b            GOTO        offset LAB_CODE_0bee-0x800
                            LAB_CODE_0be5:                ;XREF[1,0]:   CODE:0be2
CODE:CODE:0be5  3c08            MOVF        0x3c,w
CODE:CODE:0be6  7039            ANDLW       #0x70
CODE:CODE:0be7  cc00            MOVWF       0x4c
CODE:CODE:0be8  cc0e            SWAPF       0x4c,f
CODE:CODE:0be9  0f30            MOVLW       #0xf
CODE:CODE:0bea  cc05            ANDWF       0x4c,f
CODE:CODE:0beb  4c08            MOVF        0x4c,w
CODE:CODE:0bec  0b3e            ADDLW       #0xb
CODE:CODE:0bed  f32b            GOTO        offset LAB_CODE_0bf3-0x800
                            LAB_CODE_0bee:                ;XREF[1,0]:   CODE:0be4
CODE:CODE:0bee  3c08            MOVF        BANK-0:DAT_DATA_003c,w                  ;= ??
CODE:CODE:0bef  7039            ANDLW       #0x70
CODE:CODE:0bf0  031d            BTFSS       STATUS,#0x2
CODE:CODE:0bf1  f42b            GOTO        offset LAB_CODE_0bf4-0x800
CODE:CODE:0bf2  1130            MOVLW       #0x11
                            LAB_CODE_0bf3:                ;XREF[1,0]:   CODE:0bed
CODE:CODE:0bf3  c800            MOVWF       0x48
                            LAB_CODE_0bf4:                ;XREF[1,0]:   CODE:0bf1
CODE:CODE:0bf4  2d1b            BTFSC       0x2d,#0x6
CODE:CODE:0bf5  2a1d            BTFSS       0x2a,#0x2
CODE:CODE:0bf6  fb2b            GOTO        offset LAB_CODE_0bfb-0x800
CODE:CODE:0bf7  b61a            BTFSC       0x36,#0x5
CODE:CODE:0bf8  fb2b            GOTO        offset LAB_CODE_0bfb-0x800
CODE:CODE:0bf9  3030            MOVLW       #0x30
CODE:CODE:0bfa  c700            MOVWF       0x47
                            LAB_CODE_0bfb:                ;XREF[2,0]:   CODE:0bf6,CODE:0bf8
CODE:CODE:0bfb  2d1f            BTFSS       0x2d,#0x6
CODE:CODE:0bfc  aa1d            BTFSS       0x2a,#0x3
CODE:CODE:0bfd  022c            GOTO        offset LAB_CODE_0c02-0x800
CODE:CODE:0bfe  b61a            BTFSC       0x36,#0x5
CODE:CODE:0bff  022c            GOTO        offset LAB_CODE_0c02-0x800
CODE:CODE:0c00  4330            MOVLW       #0x43
CODE:CODE:0c01  c800            MOVWF       0x48
                            LAB_CODE_0c02:                ;XREF[2,0]:   CODE:0bfd,CODE:0bff
CODE:CODE:0c02  361f            BTFSS       0x36,#0x6
CODE:CODE:0c03  062c            GOTO        offset LAB_CODE_0c06-0x800
CODE:CODE:0c04  5330            MOVLW       #0x53
CODE:CODE:0c05  c800            MOVWF       0x48
                            LAB_CODE_0c06:                ;XREF[1,0]:   CODE:0c03
CODE:CODE:0c06  b61a            BTFSC       0x36,#0x5
CODE:CODE:0c07  af1c            BTFSS       0x2f,#0x1
CODE:CODE:0c08  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0c09  3c30            MOVLW       #0x3c
CODE:CODE:0c0a  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0c0b:                ;XREF[1,0]:   CODE:0bbb
CODE:CODE:0c0b  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0c0c  1f39            ANDLW       #0x1f
CODE:CODE:0c0d  cc00            MOVWF       0x4c
CODE:CODE:0c0e  0e30            MOVLW       #0xe
CODE:CODE:0c0f  4c02            SUBWF       0x4c,w
CODE:CODE:0c10  0318            BTFSC       STATUS,#0x0
CODE:CODE:0c11  142c            GOTO        offset LAB_CODE_0c14-0x800
CODE:CODE:0c12  3c1c            BTFSS       0x3c,#0x0
CODE:CODE:0c13  162c            GOTO        offset LAB_CODE_0c16-0x800
                            LAB_CODE_0c14:                ;XREF[1,0]:   CODE:0c11
CODE:CODE:0c14  af16            BSF         0x2f,#0x5
CODE:CODE:0c15  632c            GOTO        offset LAB_CODE_0c63-0x800
                            LAB_CODE_0c16:                ;XREF[1,0]:   CODE:0c13
CODE:CODE:0c16  3b1f            BTFSS       BANK-0:DAT_DATA_003b,#0x6               ;= ??
CODE:CODE:0c17  1e2c            GOTO        offset LAB_CODE_0c1e-0x800
CODE:CODE:0c18  bc1f            BTFSS       0x3c,#0x7
CODE:CODE:0c19  1c2c            GOTO        offset LAB_CODE_0c1c-0x800
CODE:CODE:0c1a  4030            MOVLW       #0x40
CODE:CODE:0c1b  ce2c            GOTO        offset LAB_CODE_0cce-0x800
                            LAB_CODE_0c1c:                ;XREF[1,0]:   CODE:0c19
CODE:CODE:0c1c  3b30            MOVLW       #0x3b
CODE:CODE:0c1d  182d            GOTO        offset LAB_CODE_0d18-0x800
                            LAB_CODE_0c1e:                ;XREF[1,0]:   CODE:0c17
CODE:CODE:0c1e  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0c1f  1f39            ANDLW       #0x1f
CODE:CODE:0c20  cc00            MOVWF       0x4c
CODE:CODE:0c21  0430            MOVLW       #0x4
CODE:CODE:0c22  4c02            SUBWF       0x4c,w
CODE:CODE:0c23  0318            BTFSC       STATUS,#0x0
CODE:CODE:0c24  3c18            BTFSC       0x3c,#0x0
CODE:CODE:0c25  272c            GOTO        offset LAB_CODE_0c27-0x800
CODE:CODE:0c26  af16            BSF         0x2f,#0x5
                            LAB_CODE_0c27:                ;XREF[1,0]:   CODE:0c25
CODE:CODE:0c27  3c08            MOVF        0x3c,w
CODE:CODE:0c28  0e39            ANDLW       #0xe
CODE:CODE:0c29  023e            ADDLW       #0x2
CODE:CODE:0c2a  c700            MOVWF       0x47
CODE:CODE:0c2b  3b08            MOVF        0x3b,w
CODE:CODE:0c2c  2039            ANDLW       #0x20
CODE:CODE:0c2d  cc00            MOVWF       0x4c
CODE:CODE:0c2e  0530            MOVLW       #0x5
CODE:CODE:0c2f  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
                            LAB_CODE_0c30:                ;XREF[1,0]:   CODE:0c33
CODE:CODE:0c30  0310            BCF         STATUS,C
CODE:CODE:0c31  cc0c            RRF         0x4c,f
CODE:CODE:0c32  f90b            DECFSZ      BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:0c33  302c            GOTO        offset LAB_CODE_0c30-0x800
CODE:CODE:0c34  4c08            MOVF        0x4c,w
CODE:CODE:0c35  0038            IORLW       #0x0
CODE:CODE:0c36  031d            BTFSS       STATUS,#0x2
CODE:CODE:0c37  c70a            INCF        0x47,f
CODE:CODE:0c38  bc1b            BTFSC       0x3c,#0x7
CODE:CODE:0c39  052d            GOTO        offset LAB_CODE_0d05-0x800
CODE:CODE:0c3a  3c08            MOVF        0x3c,w
CODE:CODE:0c3b  7039            ANDLW       #0x70
CODE:CODE:0c3c  0319            BTFSC       STATUS,#0x2
CODE:CODE:0c3d  4e2c            GOTO        offset LAB_CODE_0c4e-0x800
CODE:CODE:0c3e  3b08            MOVF        0x3b,w
CODE:CODE:0c3f  1f39            ANDLW       #0x1f
CODE:CODE:0c40  cc00            MOVWF       0x4c
CODE:CODE:0c41  0430            MOVLW       #0x4
CODE:CODE:0c42  4c02            SUBWF       0x4c,w
CODE:CODE:0c43  3c08            MOVF        0x3c,w
CODE:CODE:0c44  0318            BTFSC       STATUS,#0x0
CODE:CODE:0c45  4f2c            GOTO        offset LAB_CODE_0c4f-0x800
CODE:CODE:0c46  7039            ANDLW       #0x70
CODE:CODE:0c47  cc00            MOVWF       0x4c
CODE:CODE:0c48  cc0e            SWAPF       0x4c,f
CODE:CODE:0c49  0f30            MOVLW       #0xf
CODE:CODE:0c4a  cc05            ANDWF       0x4c,f
CODE:CODE:0c4b  4c08            MOVF        0x4c,w
CODE:CODE:0c4c  0b3e            ADDLW       #0xb
CODE:CODE:0c4d  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0c4e:                ;XREF[1,0]:   CODE:0c3d
CODE:CODE:0c4e  3c08            MOVF        BANK-0:DAT_DATA_003c,w                  ;= ??
                            LAB_CODE_0c4f:                ;XREF[1,0]:   CODE:0c45
CODE:CODE:0c4f  7039            ANDLW       #0x70
CODE:CODE:0c50  031d            BTFSS       STATUS,#0x2
CODE:CODE:0c51  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0c52  3b08            MOVF        0x3b,w
CODE:CODE:0c53  1f39            ANDLW       #0x1f
CODE:CODE:0c54  cc00            MOVWF       0x4c
CODE:CODE:0c55  0430            MOVLW       #0x4
CODE:CODE:0c56  4c02            SUBWF       0x4c,w
CODE:CODE:0c57  0318            BTFSC       STATUS,#0x0
CODE:CODE:0c58  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0c59  1130            MOVLW       #0x11
CODE:CODE:0c5a  712e            GOTO        offset LAB_CODE_0e71-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 5                                    *
                            ;************************************************************************************************
                            BGT2_5:                       ;XREF[1,0]:   CODE:0e9c
CODE:CODE:0c5b  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0c5c  0038            IORLW       #0x0
CODE:CODE:0c5d  031d            BTFSS       STATUS,#0x2
CODE:CODE:0c5e  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0c5f  b014            BSF         0x30,#0x1
CODE:CODE:0c60  2318            BTFSC       0x23,#0x0
CODE:CODE:0c61  932c            GOTO        offset LAB_CODE_0c93-0x800
CODE:CODE:0c62  ee2c            GOTO        offset LAB_CODE_0cee-0x800
                            LAB_CODE_0c63:                ;XREF[5,0]:   CODE:0b11,CODE:0b24,CODE:0b2a,CODE:0c15
                                                          ;             CODE:0c9b
CODE:CODE:0c63  1930            MOVLW       #0x19
CODE:CODE:0c64  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0c65:                ;XREF[1,0]:   CODE:0c9e
CODE:CODE:0c65  bc19            BTFSC       BANK-0:DAT_DATA_003c,#0x3               ;= ??
CODE:CODE:0c66  7b2c            GOTO        offset LAB_CODE_0c7b-0x800
CODE:CODE:0c67  ab1f            BTFSS       0x2b,#0x7
CODE:CODE:0c68  772c            GOTO        offset LAB_CODE_0c77-0x800
CODE:CODE:0c69  ae16            BSF         0x2e,#0x5
CODE:CODE:0c6a  1e30            MOVLW       #0x1e
CODE:CODE:0c6b  8316            BSF         STATUS,RP0
CODE:CODE:0c6c  4b02            SUBWF       0x4b,w
CODE:CODE:0c6d  031c            BTFSS       STATUS,#0x0
CODE:CODE:0c6e  722c            GOTO        offset LAB_CODE_0c72-0x800
CODE:CODE:0c6f  2530            MOVLW       #0x25
CODE:CODE:0c70  8312            BCF         STATUS,RP0
CODE:CODE:0c71  8c2c            GOTO        offset LAB_CODE_0c8c-0x800
                            LAB_CODE_0c72:                ;XREF[1,0]:   CODE:0c6e
CODE:CODE:0c72  8312            BCF         STATUS,RP0
CODE:CODE:0c73  c701            CLRF        0x47
CODE:CODE:0c74  c70a            INCF        0x47,f
CODE:CODE:0c75  5030            MOVLW       #0x50
CODE:CODE:0c76  8e2c            GOTO        offset LAB_CODE_0c8e-0x800
                            LAB_CODE_0c77:                ;XREF[1,0]:   CODE:0c68
CODE:CODE:0c77  2530            MOVLW       #0x25
CODE:CODE:0c78  8c2c            GOTO        offset LAB_CODE_0c8c-0x800
                            LAB_CODE_0c79:                ;XREF[1,0]:   CODE:0ca4
CODE:CODE:0c79  bc1d            BTFSS       BANK-0:DAT_DATA_003c,#0x3               ;= ??
CODE:CODE:0c7a  7f2c            GOTO        offset LAB_CODE_0c7f-0x800
                            LAB_CODE_0c7b:                ;XREF[2,0]:   CODE:0c66,CODE:0ca1
CODE:CODE:0c7b  2630            MOVLW       #0x26
CODE:CODE:0c7c  c700            MOVWF       0x47
CODE:CODE:0c7d  2730            MOVLW       #0x27
CODE:CODE:0c7e  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0c7f:                ;XREF[1,0]:   CODE:0c7a
CODE:CODE:0c7f  1a30            MOVLW       #0x1a
CODE:CODE:0c80  c700            MOVWF       0x47
CODE:CODE:0c81  4430            MOVLW       #0x44
CODE:CODE:0c82  c800            MOVWF       0x48
CODE:CODE:0c83  1b30            MOVLW       #0x1b
CODE:CODE:0c84  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0c85:                ;XREF[1,0]:   CODE:0ca7
CODE:CODE:0c85  bc1d            BTFSS       BANK-0:DAT_DATA_003c,#0x3               ;= ??
CODE:CODE:0c86  892c            GOTO        offset LAB_CODE_0c89-0x800
                            LAB_CODE_0c87:                ;XREF[1,0]:   CODE:0bab
CODE:CODE:0c87  1a30            MOVLW       #0x1a
CODE:CODE:0c88  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0c89:                ;XREF[1,0]:   CODE:0c86
CODE:CODE:0c89  1a30            MOVLW       #0x1a
CODE:CODE:0c8a  8c2c            GOTO        offset LAB_CODE_0c8c-0x800
                            LAB_CODE_0c8b:                ;XREF[1,0]:   CODE:0caa
CODE:CODE:0c8b  2930            MOVLW       #0x29
                            LAB_CODE_0c8c:                ;XREF[4,0]:   CODE:0b08,CODE:0c71,CODE:0c78,CODE:0c8a
CODE:CODE:0c8c  c700            MOVWF       0x47
CODE:CODE:0c8d  4430            MOVLW       #0x44
                            LAB_CODE_0c8e:                ;XREF[3,0]:   CODE:0af3,CODE:0b06,CODE:0c76
CODE:CODE:0c8e  c800            MOVWF       BANK-0:DAT_DATA_0048                    ;= ??
CODE:CODE:0c8f  0130            MOVLW       #0x1
                            LAB_CODE_0c90:                ;XREF[1,0]:   CODE:0b6e
CODE:CODE:0c90  8316            BSF         STATUS,RP0
CODE:CODE:0c91  a000            MOVWF       0x20
CODE:CODE:0c92  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0c93:                ;XREF[1,0]:   CODE:0c61
CODE:CODE:0c93  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0c94  1f39            ANDLW       #0x1f
CODE:CODE:0c95  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:0c96  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:0c97  ac2c            GOTO        offset LAB_CODE_0cac-0x800
                            LAB_CODE_0c98:                ;XREF[1,0]:   CODE:0caf
CODE:CODE:0c98  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0c99  003a            XORLW       #0x0
CODE:CODE:0c9a  0319            BTFSC       STATUS,#0x2
CODE:CODE:0c9b  632c            GOTO        offset LAB_CODE_0c63-0x800
CODE:CODE:0c9c  013a            XORLW       #0x1
CODE:CODE:0c9d  0319            BTFSC       STATUS,#0x2
CODE:CODE:0c9e  652c            GOTO        offset LAB_CODE_0c65-0x800
CODE:CODE:0c9f  033a            XORLW       #0x3
CODE:CODE:0ca0  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ca1  7b2c            GOTO        offset LAB_CODE_0c7b-0x800
CODE:CODE:0ca2  013a            XORLW       #0x1
CODE:CODE:0ca3  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ca4  792c            GOTO        offset LAB_CODE_0c79-0x800
CODE:CODE:0ca5  073a            XORLW       #0x7
CODE:CODE:0ca6  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ca7  852c            GOTO        offset LAB_CODE_0c85-0x800
CODE:CODE:0ca8  013a            XORLW       #0x1
CODE:CODE:0ca9  0319            BTFSC       STATUS,#0x2
CODE:CODE:0caa  8b2c            GOTO        offset LAB_CODE_0c8b-0x800
CODE:CODE:0cab  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0cac:                ;XREF[1,0]:   CODE:0c97
CODE:CODE:0cac  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0cad  003a            XORLW       #0x0
CODE:CODE:0cae  0319            BTFSC       STATUS,#0x2
CODE:CODE:0caf  982c            GOTO        offset LAB_CODE_0c98-0x800
CODE:CODE:0cb0  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 7                                    *
                            ;************************************************************************************************
                            BGT2_7:                       ;XREF[1,0]:   CODE:0ea2
CODE:CODE:0cb1  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0cb2  0038            IORLW       #0x0
CODE:CODE:0cb3  031d            BTFSS       STATUS,#0x2
CODE:CODE:0cb4  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0cb5  b014            BSF         0x30,#0x1
CODE:CODE:0cb6  3b08            MOVF        0x3b,w
CODE:CODE:0cb7  1f39            ANDLW       #0x1f
CODE:CODE:0cb8  031d            BTFSS       STATUS,#0x2
CODE:CODE:0cb9  c02c            GOTO        offset LAB_CODE_0cc0-0x800
CODE:CODE:0cba  b71e            BTFSS       0x37,#0x5
CODE:CODE:0cbb  132d            GOTO        offset LAB_CODE_0d13-0x800
CODE:CODE:0cbc  3d30            MOVLW       #0x3d
CODE:CODE:0cbd  c700            MOVWF       0x47
CODE:CODE:0cbe  3e30            MOVLW       #0x3e
CODE:CODE:0cbf  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0cc0:                ;XREF[1,0]:   CODE:0cb9
CODE:CODE:0cc0  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0cc1  1f39            ANDLW       #0x1f
CODE:CODE:0cc2  013a            XORLW       #0x1
CODE:CODE:0cc3  031d            BTFSS       STATUS,#0x2
CODE:CODE:0cc4  cb2c            GOTO        offset LAB_CODE_0ccb-0x800
CODE:CODE:0cc5  3b1f            BTFSS       0x3b,#0x6
CODE:CODE:0cc6  c92c            GOTO        offset LAB_CODE_0cc9-0x800
CODE:CODE:0cc7  3b30            MOVLW       #0x3b
CODE:CODE:0cc8  f82c            GOTO        offset LAB_CODE_0cf8-0x800
                            LAB_CODE_0cc9:                ;XREF[1,0]:   CODE:0cc6
CODE:CODE:0cc9  2b30            MOVLW       #0x2b
CODE:CODE:0cca  f82c            GOTO        offset LAB_CODE_0cf8-0x800
                            LAB_CODE_0ccb:                ;XREF[1,0]:   CODE:0cc4
CODE:CODE:0ccb  bc1f            BTFSS       BANK-0:DAT_DATA_003c,#0x7               ;= ??
CODE:CODE:0ccc  d02c            GOTO        offset LAB_CODE_0cd0-0x800
CODE:CODE:0ccd  3f30            MOVLW       #0x3f
                            LAB_CODE_0cce:                ;XREF[1,0]:   CODE:0c1b
CODE:CODE:0cce  c700            MOVWF       0x47
CODE:CODE:0ccf  052d            GOTO        offset LAB_CODE_0d05-0x800
                            LAB_CODE_0cd0:                ;XREF[1,0]:   CODE:0ccc
CODE:CODE:0cd0  3b1f            BTFSS       BANK-0:DAT_DATA_003b,#0x6               ;= ??
CODE:CODE:0cd1  d42c            GOTO        offset LAB_CODE_0cd4-0x800
CODE:CODE:0cd2  3b30            MOVLW       #0x3b
CODE:CODE:0cd3  d52c            GOTO        offset LAB_CODE_0cd5-0x800
                            LAB_CODE_0cd4:                ;XREF[1,0]:   CODE:0cd1
CODE:CODE:0cd4  2b30            MOVLW       #0x2b
                            LAB_CODE_0cd5:                ;XREF[1,0]:   CODE:0cd3
CODE:CODE:0cd5  c700            MOVWF       0x47
CODE:CODE:0cd6  af16            BSF         0x2f,#0x5
CODE:CODE:0cd7  3b08            MOVF        0x3b,w
CODE:CODE:0cd8  1f39            ANDLW       #0x1f
CODE:CODE:0cd9  cc00            MOVWF       0x4c
CODE:CODE:0cda  0230            MOVLW       #0x2
CODE:CODE:0cdb  4c02            SUBWF       0x4c,w
CODE:CODE:0cdc  031c            BTFSS       STATUS,#0x0
CODE:CODE:0cdd  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0cde  492d            GOTO        offset LAB_CODE_0d49-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 8                                    *
                            ;************************************************************************************************
                            BGT2_8:                       ;XREF[1,0]:   CODE:0ea3
CODE:CODE:0cdf  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0ce0  0038            IORLW       #0x0
CODE:CODE:0ce1  031d            BTFSS       STATUS,#0x2
CODE:CODE:0ce2  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0ce3  b010            BCF         0x30,#0x1
CODE:CODE:0ce4  3b08            MOVF        0x3b,w
CODE:CODE:0ce5  1f39            ANDLW       #0x1f
CODE:CODE:0ce6  031d            BTFSS       STATUS,#0x2
CODE:CODE:0ce7  f22c            GOTO        offset LAB_CODE_0cf2-0x800
CODE:CODE:0ce8  231c            BTFSS       0x23,#0x0
CODE:CODE:0ce9  ee2c            GOTO        offset LAB_CODE_0cee-0x800
CODE:CODE:0cea  1930            MOVLW       #0x19
CODE:CODE:0ceb  c800            MOVWF       0x48
                            LAB_CODE_0cec:                ;XREF[1,0]:   CODE:0b27
CODE:CODE:0cec  1830            MOVLW       #0x18
CODE:CODE:0ced  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0cee:                ;XREF[2,0]:   CODE:0c62,CODE:0ce9
CODE:CODE:0cee  2d30            MOVLW       #0x2d
CODE:CODE:0cef  c700            MOVWF       0x47
CODE:CODE:0cf0  2e30            MOVLW       #0x2e
CODE:CODE:0cf1  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0cf2:                ;XREF[1,0]:   CODE:0ce7
CODE:CODE:0cf2  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0cf3  1f39            ANDLW       #0x1f
CODE:CODE:0cf4  013a            XORLW       #0x1
CODE:CODE:0cf5  031d            BTFSS       STATUS,#0x2
CODE:CODE:0cf6  002d            GOTO        offset LAB_CODE_0d00-0x800
CODE:CODE:0cf7  1430            MOVLW       #0x14
                            LAB_CODE_0cf8:                ;XREF[2,0]:   CODE:0cc8,CODE:0cca
CODE:CODE:0cf8  c700            MOVWF       0x47
CODE:CODE:0cf9  4a30            MOVLW       #0x4a
CODE:CODE:0cfa  c800            MOVWF       0x48
CODE:CODE:0cfb  ae15            BSF         0x2e,#0x3
CODE:CODE:0cfc  2830            MOVLW       #0x28
CODE:CODE:0cfd  8316            BSF         STATUS,RP0
CODE:CODE:0cfe  cc00            MOVWF       0x4c
CODE:CODE:0cff  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0d00:                ;XREF[1,0]:   CODE:0cf6
CODE:CODE:0d00  af16            BSF         BANK-0:ENTRY_DATA_UNK1,#0x5             ;= ??
CODE:CODE:0d01  1430            MOVLW       #0x14
CODE:CODE:0d02  c700            MOVWF       0x47
CODE:CODE:0d03  bc1f            BTFSS       0x3c,#0x7
CODE:CODE:0d04  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0d05:                ;XREF[2,0]:   CODE:0c39,CODE:0ccf
CODE:CODE:0d05  1230            MOVLW       #0x12
CODE:CODE:0d06  c800            MOVWF       0x48
CODE:CODE:0d07  af12            BCF         0x2f,#0x5
CODE:CODE:0d08  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 9                                    *
                            ;************************************************************************************************
                            BGT2_9:                       ;XREF[1,0]:   CODE:0ea4
CODE:CODE:0d09  6121            CALL        offset Elona-0x800                      ;undefined Elona()
CODE:CODE:0d0a  0038            IORLW       #0x0
CODE:CODE:0d0b  031d            BTFSS       STATUS,#0x2
CODE:CODE:0d0c  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0d0d  b014            BSF         0x30,#0x1
CODE:CODE:0d0e  3b08            MOVF        0x3b,w
CODE:CODE:0d0f  1f39            ANDLW       #0x1f
CODE:CODE:0d10  013a            XORLW       #0x1
CODE:CODE:0d11  031d            BTFSS       STATUS,#0x2
CODE:CODE:0d12  172d            GOTO        offset LAB_CODE_0d17-0x800
                            LAB_CODE_0d13:                ;XREF[2,0]:   CODE:0ba9,CODE:0cbb
CODE:CODE:0d13  1830            MOVLW       #0x18
                            LAB_CODE_0d14:                ;XREF[2,0]:   CODE:0b95,CODE:0bb2
CODE:CODE:0d14  c700            MOVWF       0x47
CODE:CODE:0d15  1930            MOVLW       #0x19
CODE:CODE:0d16  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0d17:                ;XREF[1,0]:   CODE:0d12
CODE:CODE:0d17  2f30            MOVLW       #0x2f
                            LAB_CODE_0d18:                ;XREF[2,0]:   CODE:0b94,CODE:0c1d
CODE:CODE:0d18  c700            MOVWF       0x47
CODE:CODE:0d19  492d            GOTO        offset LAB_CODE_0d49-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 13                                   *
                            ;************************************************************************************************
                            BGT2_13:                      ;XREF[19,0]:  CODE:0ea9,CODE:0eaa,CODE:0eab,CODE:0eac
                                                          ;             CODE:0ead,CODE:0eae,CODE:0eaf,CODE:0eb0
                                                          ;             CODE:0eb1,CODE:0eb2,CODE:0eb3,CODE:0eb4
                                                          ;             CODE:0eb5,CODE:0eb6,CODE:0eb7,CODE:0ebe
                                                          ;             CODE:0ebf,CODE:0ec0,CODE:0ec1
CODE:CODE:0d1a  0a12            BCF         PCLATH,#0x4
CODE:CODE:0d1b  8a11            BCF         PCLATH,#0x3
CODE:CODE:0d1c  f521            CALL        MAINLOOP_MAIN_LOGIC_SUB2                ;byte MAINLOOP_MAIN_LOGIC_SUB2(void)
CODE:CODE:0d1d  0a12            BCF         PCLATH,#0x4
CODE:CODE:0d1e  8a15            BSF         PCLATH,#0x3
CODE:CODE:0d1f  c62e            GOTO        offset MAINLOOP_MAIN_LOGIC::BGT2_4_RE...
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 14                                   *
                            ;************************************************************************************************
                            BGT2_14:                      ;XREF[1,0]:   CODE:0eb9
CODE:CODE:0d20  bc08            MOVF        BANK-0:DAT_DATA_003c,f                  ;= ??
CODE:CODE:0d21  0319            BTFSC       STATUS,#0x2
CODE:CODE:0d22  292d            GOTO        offset LAB_CODE_0d29-0x800
CODE:CODE:0d23  ff30            MOVLW       #0xff
CODE:CODE:0d24  8316            BSF         STATUS,RP0
CODE:CODE:0d25  a000            MOVWF       0x20
CODE:CODE:0d26  db30            MOVLW       #0xdb
CODE:CODE:0d27  8312            BCF         STATUS,RP0
CODE:CODE:0d28  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0d29:                ;XREF[1,0]:   CODE:0d22
CODE:CODE:0d29  8316            BSF         STATUS,RP0
CODE:CODE:0d2a  ad08            MOVF        0x2d,f
CODE:CODE:0d2b  031d            BTFSS       STATUS,#0x2
CODE:CODE:0d2c  4b2d            GOTO        offset LAB_CODE_0d4b-0x800
CODE:CODE:0d2d  c930            MOVLW       #0xc9
CODE:CODE:0d2e  8312            BCF         STATUS,RP0
CODE:CODE:0d2f  c700            MOVWF       0x47
CODE:CODE:0d30  ac17            BSF         0x2c,#0x7
CODE:CODE:0d31  2c1f            BTFSS       0x2c,#0x6
CODE:CODE:0d32  3c2d            GOTO        offset LAB_CODE_0d3c-0x800
CODE:CODE:0d33  2c13            BCF         0x2c,#0x6
CODE:CODE:0d34  f630            MOVLW       #0xf6
CODE:CODE:0d35  0317            BSF         STATUS,RP1
CODE:CODE:0d36  a307            ADDWF       0x23,f
CODE:CODE:0d37  0a30            MOVLW       #0xa
CODE:CODE:0d38  2302            SUBWF       0x23,w
CODE:CODE:0d39  031c            BTFSS       STATUS,#0x0
CODE:CODE:0d3a  a301            CLRF        0x23
CODE:CODE:0d3b  482d            GOTO        offset LAB_CODE_0d48-0x800
                            LAB_CODE_0d3c:                ;XREF[1,0]:   CODE:0d32
CODE:CODE:0d3c  ac1e            BTFSS       BANK-0:ENTRY_DATA_UNK3,#0x5             ;= ??
CODE:CODE:0d3d  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0d3e  ac12            BCF         0x2c,#0x5
CODE:CODE:0d3f  0a30            MOVLW       #0xa
CODE:CODE:0d40  0317            BSF         STATUS,RP1
CODE:CODE:0d41  a307            ADDWF       0x23,f
CODE:CODE:0d42  6530            MOVLW       #0x65
CODE:CODE:0d43  2302            SUBWF       0x23,w
CODE:CODE:0d44  031c            BTFSS       STATUS,#0x0
CODE:CODE:0d45  482d            GOTO        offset LAB_CODE_0d48-0x800
CODE:CODE:0d46  6430            MOVLW       #0x64
CODE:CODE:0d47  a300            MOVWF       0x23
                            LAB_CODE_0d48:                ;XREF[2,0]:   CODE:0d3b,CODE:0d45
CODE:CODE:0d48  0313            BCF         STATUS,RP1
                            LAB_CODE_0d49:                ;XREF[2,0]:   CODE:0cde,CODE:0d19
CODE:CODE:0d49  af16            BSF         0x2f,#0x5
CODE:CODE:0d4a  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0d4b:                ;XREF[1,0]:   CODE:0d2c
CODE:CODE:0d4b  8312            BCF         STATUS,RP0
CODE:CODE:0d4c  cb01            CLRF        0x4b
                            LAB_CODE_0d4d:                ;XREF[1,0]:   CODE:0d57
CODE:CODE:0d4d  4b08            MOVF        0x4b,w
CODE:CODE:0d4e  273e            ADDLW       #0x27
CODE:CODE:0d4f  8400            MOVWF       FSR0L
CODE:CODE:0d50  8317            BSF         STATUS,IRP
CODE:CODE:0d51  2030            MOVLW       #0x20
CODE:CODE:0d52  8000            MOVWF       INDF0
CODE:CODE:0d53  cb0a            INCF        0x4b,f
CODE:CODE:0d54  0a30            MOVLW       #0xa
CODE:CODE:0d55  4b02            SUBWF       0x4b,w
CODE:CODE:0d56  031c            BTFSS       STATUS,#0x0
CODE:CODE:0d57  4d2d            GOTO        offset LAB_CODE_0d4d-0x800
CODE:CODE:0d58  ca30            MOVLW       #0xca
CODE:CODE:0d59  c800            MOVWF       0x48
CODE:CODE:0d5a  ac17            BSF         0x2c,#0x7
CODE:CODE:0d5b  4730            MOVLW       #0x47
CODE:CODE:0d5c  8316            BSF         STATUS,RP0
CODE:CODE:0d5d  b100            MOVWF       0x31
CODE:CODE:0d5e  8312            BCF         STATUS,RP0
CODE:CODE:0d5f  3e1c            BTFSS       0x3e,#0x0
CODE:CODE:0d60  632d            GOTO        offset LAB_CODE_0d63-0x800
CODE:CODE:0d61  3130            MOVLW       #0x31
CODE:CODE:0d62  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d63:                ;XREF[1,0]:   CODE:0d60
CODE:CODE:0d63  be1c            BTFSS       BANK-0:DAT_DATA_003e,#0x1               ;= ??
CODE:CODE:0d64  672d            GOTO        offset LAB_CODE_0d67-0x800
CODE:CODE:0d65  3230            MOVLW       #0x32
CODE:CODE:0d66  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d67:                ;XREF[1,0]:   CODE:0d64
CODE:CODE:0d67  3e1d            BTFSS       BANK-0:DAT_DATA_003e,#0x2               ;= ??
CODE:CODE:0d68  6b2d            GOTO        offset LAB_CODE_0d6b-0x800
CODE:CODE:0d69  3330            MOVLW       #0x33
CODE:CODE:0d6a  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d6b:                ;XREF[1,0]:   CODE:0d68
CODE:CODE:0d6b  be1e            BTFSS       BANK-0:DAT_DATA_003e,#0x5               ;= ??
CODE:CODE:0d6c  6f2d            GOTO        offset LAB_CODE_0d6f-0x800
CODE:CODE:0d6d  3430            MOVLW       #0x34
CODE:CODE:0d6e  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d6f:                ;XREF[1,0]:   CODE:0d6c
CODE:CODE:0d6f  3e1e            BTFSS       BANK-0:DAT_DATA_003e,#0x4               ;= ??
CODE:CODE:0d70  732d            GOTO        offset LAB_CODE_0d73-0x800
CODE:CODE:0d71  3530            MOVLW       #0x35
CODE:CODE:0d72  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d73:                ;XREF[1,0]:   CODE:0d70
CODE:CODE:0d73  be1d            BTFSS       BANK-0:DAT_DATA_003e,#0x3               ;= ??
CODE:CODE:0d74  772d            GOTO        offset LAB_CODE_0d77-0x800
CODE:CODE:0d75  3630            MOVLW       #0x36
CODE:CODE:0d76  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d77:                ;XREF[1,0]:   CODE:0d74
CODE:CODE:0d77  be1f            BTFSS       BANK-0:DAT_DATA_003e,#0x7               ;= ??
CODE:CODE:0d78  7b2d            GOTO        offset LAB_CODE_0d7b-0x800
CODE:CODE:0d79  3730            MOVLW       #0x37
CODE:CODE:0d7a  7e2d            GOTO        offset LAB_CODE_0d7e-0x800
                            LAB_CODE_0d7b:                ;XREF[1,0]:   CODE:0d78
CODE:CODE:0d7b  3e1f            BTFSS       BANK-0:DAT_DATA_003e,#0x6               ;= ??
CODE:CODE:0d7c  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0d7d  3830            MOVLW       #0x38
                            LAB_CODE_0d7e:                ;XREF[7,0]:   CODE:0d62,CODE:0d66,CODE:0d6a,CODE:0d6e
                                                          ;             CODE:0d72,CODE:0d76,CODE:0d7a
CODE:CODE:0d7e  0317            BSF         STATUS,RP1
CODE:CODE:0d7f  a800            MOVWF       0x28
CODE:CODE:0d80  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 15                                   *
                            ;************************************************************************************************
                            BGT2_15:                      ;XREF[1,0]:   CODE:0eba
CODE:CODE:0d81  2308            MOVF        BANK-0:TIMER1_UNK5,w                    ;= ??
CODE:CODE:0d82  de38            IORLW       #0xde
CODE:CODE:0d83  2406            XORWF       0x24,w
CODE:CODE:0d84  0319            BTFSC       STATUS,#0x2
CODE:CODE:0d85  8d2d            GOTO        offset LAB_CODE_0d8d-0x800
CODE:CODE:0d86  3230            MOVLW       #0x32
CODE:CODE:0d87  8316            BSF         STATUS,RP0
CODE:CODE:0d88  b300            MOVWF       0x33
CODE:CODE:0d89  8312            BCF         STATUS,RP0
CODE:CODE:0d8a  2308            MOVF        0x23,w
CODE:CODE:0d8b  de38            IORLW       #0xde
CODE:CODE:0d8c  a400            MOVWF       0x24
                            LAB_CODE_0d8d:                ;XREF[1,0]:   CODE:0d85
CODE:CODE:0d8d  bc08            MOVF        0x3c,f
CODE:CODE:0d8e  031d            BTFSS       STATUS,#0x2
CODE:CODE:0d8f  4a2e            GOTO        offset LAB_CODE_0e4a-0x800
CODE:CODE:0d90  0330            MOVLW       #0x3
CODE:CODE:0d91  3b02            SUBWF       0x3b,w
CODE:CODE:0d92  0318            BTFSC       STATUS,#0x0
CODE:CODE:0d93  962d            GOTO        offset LAB_CODE_0d96-0x800
CODE:CODE:0d94  cb30            MOVLW       #0xcb
CODE:CODE:0d95  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0d96:                ;XREF[1,0]:   CODE:0d93
CODE:CODE:0d96  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0d97  033a            XORLW       #0x3
CODE:CODE:0d98  031d            BTFSS       STATUS,#0x2
CODE:CODE:0d99  d42d            GOTO        offset LAB_CODE_0dd4-0x800
CODE:CODE:0d9a  be1c            BTFSS       0x3e,#0x1
CODE:CODE:0d9b  a12d            GOTO        offset LAB_CODE_0da1-0x800
CODE:CODE:0d9c  8316            BSF         STATUS,RP0
CODE:CODE:0d9d  2d0b            DECFSZ      0x2d,w
CODE:CODE:0d9e  a12d            GOTO        offset LAB_CODE_0da1-0x800
CODE:CODE:0d9f  d230            MOVLW       #0xd2
CODE:CODE:0da0  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0da1:                ;XREF[2,0]:   CODE:0d9b,CODE:0d9e
CODE:CODE:0da1  8312            BCF         STATUS,RP0
CODE:CODE:0da2  3e1d            BTFSS       0x3e,#0x2
CODE:CODE:0da3  a92d            GOTO        offset LAB_CODE_0da9-0x800
CODE:CODE:0da4  8316            BSF         STATUS,RP0
CODE:CODE:0da5  2d0b            DECFSZ      0x2d,w
CODE:CODE:0da6  a92d            GOTO        offset LAB_CODE_0da9-0x800
CODE:CODE:0da7  d330            MOVLW       #0xd3
CODE:CODE:0da8  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0da9:                ;XREF[2,0]:   CODE:0da3,CODE:0da6
CODE:CODE:0da9  8312            BCF         STATUS,RP0
CODE:CODE:0daa  be1d            BTFSS       0x3e,#0x3
CODE:CODE:0dab  b12d            GOTO        offset LAB_CODE_0db1-0x800
CODE:CODE:0dac  8316            BSF         STATUS,RP0
CODE:CODE:0dad  2d0b            DECFSZ      0x2d,w
CODE:CODE:0dae  b12d            GOTO        offset LAB_CODE_0db1-0x800
CODE:CODE:0daf  d430            MOVLW       #0xd4
CODE:CODE:0db0  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0db1:                ;XREF[2,0]:   CODE:0dab,CODE:0dae
CODE:CODE:0db1  8312            BCF         STATUS,RP0
CODE:CODE:0db2  be1e            BTFSS       0x3e,#0x5
CODE:CODE:0db3  b92d            GOTO        offset LAB_CODE_0db9-0x800
CODE:CODE:0db4  8316            BSF         STATUS,RP0
CODE:CODE:0db5  2d0b            DECFSZ      0x2d,w
CODE:CODE:0db6  b92d            GOTO        offset LAB_CODE_0db9-0x800
CODE:CODE:0db7  d530            MOVLW       #0xd5
CODE:CODE:0db8  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0db9:                ;XREF[2,0]:   CODE:0db3,CODE:0db6
CODE:CODE:0db9  8312            BCF         STATUS,RP0
CODE:CODE:0dba  be1f            BTFSS       0x3e,#0x7
CODE:CODE:0dbb  c12d            GOTO        offset LAB_CODE_0dc1-0x800
CODE:CODE:0dbc  8316            BSF         STATUS,RP0
CODE:CODE:0dbd  2d0b            DECFSZ      0x2d,w
CODE:CODE:0dbe  c12d            GOTO        offset LAB_CODE_0dc1-0x800
CODE:CODE:0dbf  d630            MOVLW       #0xd6
CODE:CODE:0dc0  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0dc1:                ;XREF[2,0]:   CODE:0dbb,CODE:0dbe
CODE:CODE:0dc1  8312            BCF         STATUS,RP0
CODE:CODE:0dc2  3e1f            BTFSS       0x3e,#0x6
CODE:CODE:0dc3  c92d            GOTO        offset LAB_CODE_0dc9-0x800
CODE:CODE:0dc4  8316            BSF         STATUS,RP0
CODE:CODE:0dc5  2d0b            DECFSZ      0x2d,w
CODE:CODE:0dc6  c92d            GOTO        offset LAB_CODE_0dc9-0x800
CODE:CODE:0dc7  d030            MOVLW       #0xd0
CODE:CODE:0dc8  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0dc9:                ;XREF[2,0]:   CODE:0dc3,CODE:0dc6
CODE:CODE:0dc9  8312            BCF         STATUS,RP0
CODE:CODE:0dca  3e1c            BTFSS       0x3e,#0x0
CODE:CODE:0dcb  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0dcc  8316            BSF         STATUS,RP0
CODE:CODE:0dcd  2d0b            DECFSZ      0x2d,w
CODE:CODE:0dce  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0dcf  d530            MOVLW       #0xd5
CODE:CODE:0dd0  8312            BCF         STATUS,RP0
CODE:CODE:0dd1  c700            MOVWF       0x47
CODE:CODE:0dd2  d630            MOVLW       #0xd6
CODE:CODE:0dd3  712e            GOTO        offset LAB_CODE_0e71-0x800
                            LAB_CODE_0dd4:                ;XREF[1,0]:   CODE:0d99
CODE:CODE:0dd4  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0dd5  043a            XORLW       #0x4
CODE:CODE:0dd6  031d            BTFSS       STATUS,#0x2
CODE:CODE:0dd7  e32d            GOTO        offset LAB_CODE_0de3-0x800
CODE:CODE:0dd8  a318            BTFSC       0x23,#0x1
CODE:CODE:0dd9  e92d            GOTO        offset LAB_CODE_0de9-0x800
CODE:CODE:0dda  2319            BTFSC       0x23,#0x2
CODE:CODE:0ddb  ed2d            GOTO        offset LAB_CODE_0ded-0x800
CODE:CODE:0ddc  3e1e            BTFSS       0x3e,#0x4
CODE:CODE:0ddd  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0dde  8316            BSF         STATUS,RP0
CODE:CODE:0ddf  2d0b            DECFSZ      0x2d,w
CODE:CODE:0de0  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0de1  cf30            MOVLW       #0xcf
CODE:CODE:0de2  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0de3:                ;XREF[1,0]:   CODE:0dd7
CODE:CODE:0de3  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0de4  053a            XORLW       #0x5
CODE:CODE:0de5  031d            BTFSS       STATUS,#0x2
CODE:CODE:0de6  f92d            GOTO        offset LAB_CODE_0df9-0x800
CODE:CODE:0de7  a31c            BTFSS       0x23,#0x1
CODE:CODE:0de8  eb2d            GOTO        offset LAB_CODE_0deb-0x800
                            LAB_CODE_0de9:                ;XREF[1,0]:   CODE:0dd9
CODE:CODE:0de9  cc30            MOVLW       #0xcc
CODE:CODE:0dea  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0deb:                ;XREF[1,0]:   CODE:0de8
CODE:CODE:0deb  231d            BTFSS       BANK-0:TIMER1_UNK5,#0x2                 ;= ??
CODE:CODE:0dec  ef2d            GOTO        offset LAB_CODE_0def-0x800
                            LAB_CODE_0ded:                ;XREF[1,0]:   CODE:0ddb
CODE:CODE:0ded  cd30            MOVLW       #0xcd
CODE:CODE:0dee  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0def:                ;XREF[1,0]:   CODE:0dec
CODE:CODE:0def  3e1e            BTFSS       BANK-0:DAT_DATA_003e,#0x4               ;= ??
CODE:CODE:0df0  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0df1  8316            BSF         STATUS,RP0
CODE:CODE:0df2  2d0b            DECFSZ      0x2d,w
CODE:CODE:0df3  f62d            GOTO        offset LAB_CODE_0df6-0x800
CODE:CODE:0df4  ce30            MOVLW       #0xce
CODE:CODE:0df5  f72d            GOTO        offset sub_bfl_wtf-0x800
                            LAB_CODE_0df6:                ;XREF[6,0]:   CODE:0dcb,CODE:0dce,CODE:0ddd,CODE:0de0
                                                          ;             CODE:0df0,CODE:0df3
CODE:CODE:0df6  cb30            MOVLW       #0xcb
                            sub_bfl_wtf:                  ;XREF[9,0]:   CODE:0ad6,CODE:0da0,CODE:0da8,CODE:0db0
                                                          ;             CODE:0db8,CODE:0dc0,CODE:0dc8,CODE:0de2
                                                          ;             CODE:0df5
CODE:CODE:0df7  8312            BCF         STATUS,RP0
CODE:CODE:0df8  002e            GOTO        offset LAB_CODE_0e00-0x800
                            LAB_CODE_0df9:                ;XREF[1,0]:   CODE:0de6
CODE:CODE:0df9  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0dfa  063a            XORLW       #0x6
CODE:CODE:0dfb  031d            BTFSS       STATUS,#0x2
CODE:CODE:0dfc  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0dfd  d030            MOVLW       #0xd0
CODE:CODE:0dfe  002e            GOTO        offset LAB_CODE_0e00-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 17                                   *
                            ;************************************************************************************************
                            BGT2_17:                      ;XREF[1,0]:   CODE:0ebc
CODE:CODE:0dff  d130            MOVLW       #0xd1
                            LAB_CODE_0e00:                ;XREF[10,0]:  CODE:0afa,CODE:0b53,CODE:0c64,CODE:0c88
                                                          ;             CODE:0ced,CODE:0d95,CODE:0dea,CODE:0dee
                                                          ;             CODE:0df8,CODE:0dfe
CODE:CODE:0e00  c700            MOVWF       BANK-0:DAT_DATA_0047                    ;= ??
CODE:CODE:0e01  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 16                                   *
                            ;************************************************************************************************
                            BGT2_16:                      ;XREF[1,0]:   CODE:0ebb
CODE:CODE:0e02  8316            BSF         STATUS,RP0
CODE:CODE:0e03  0317            BSF         STATUS,RP1
CODE:CODE:0e04  1012            BCF         0x10,#0x4
CODE:CODE:0e05  2b2e            GOTO        offset LAB_CODE_0e2b-0x800
                            LAB_CODE_0e06:                ;XREF[1,0]:   CODE:0e30
CODE:CODE:0e06  8316            BSF         STATUS,RP0
CODE:CODE:0e07  a001            CLRF        0x20
CODE:CODE:0e08  462e            GOTO        offset LAB_CODE_0e46-0x800
                            LAB_CODE_0e09:                ;XREF[1,0]:   CODE:0e33
CODE:CODE:0e09  0130            MOVLW       #0x1
CODE:CODE:0e0a  0c2e            GOTO        offset LAB_CODE_0e0c-0x800
                            LAB_CODE_0e0b:                ;XREF[1,0]:   CODE:0e36
CODE:CODE:0e0b  0230            MOVLW       #0x2
                            LAB_CODE_0e0c:                ;XREF[1,0]:   CODE:0e0a
CODE:CODE:0e0c  8316            BSF         STATUS,RP0
CODE:CODE:0e0d  a000            MOVWF       0x20
CODE:CODE:0e0e  462e            GOTO        offset LAB_CODE_0e46-0x800
                            LAB_CODE_0e0f:                ;XREF[1,0]:   CODE:0e39
CODE:CODE:0e0f  8316            BSF         STATUS,RP0
CODE:CODE:0e10  a001            CLRF        0x20
CODE:CODE:0e11  282e            GOTO        offset LAB_CODE_0e28-0x800
                            LAB_CODE_0e12:                ;XREF[1,0]:   CODE:0e3c
CODE:CODE:0e12  8513            BCF         FSR0H,#0x7
CODE:CODE:0e13  8316            BSF         STATUS,RP0
CODE:CODE:0e14  0317            BSF         STATUS,RP1
CODE:CODE:0e15  1012            BCF         0x10,#0x4
CODE:CODE:0e16  462e            GOTO        offset LAB_CODE_0e46-0x800
                            LAB_CODE_0e17:                ;XREF[1,0]:   CODE:0e3f
CODE:CODE:0e17  8316            BSF         STATUS,RP0
CODE:CODE:0e18  0317            BSF         STATUS,RP1
CODE:CODE:0e19  1016            BSF         0x10,#0x4
CODE:CODE:0e1a  dd30            MOVLW       #0xdd
CODE:CODE:0e1b  202e            GOTO        offset LAB_CODE_0e20-0x800
                            LAB_CODE_0e1c:                ;XREF[1,0]:   CODE:0e42
CODE:CODE:0e1c  8316            BSF         STATUS,RP0
CODE:CODE:0e1d  0317            BSF         STATUS,RP1
CODE:CODE:0e1e  1016            BSF         0x10,#0x4
CODE:CODE:0e1f  dc30            MOVLW       #0xdc
                            LAB_CODE_0e20:                ;XREF[1,0]:   CODE:0e1b
CODE:CODE:0e20  8312            BCF         STATUS,RP0
CODE:CODE:0e21  0313            BCF         STATUS,RP1
CODE:CODE:0e22  c700            MOVWF       0x47
CODE:CODE:0e23  c800            MOVWF       0x48
CODE:CODE:0e24  462e            GOTO        offset LAB_CODE_0e46-0x800
                            LAB_CODE_0e25:                ;XREF[1,0]:   CODE:0e45
CODE:CODE:0e25  ff30            MOVLW       #0xff
CODE:CODE:0e26  8316            BSF         STATUS,RP0
CODE:CODE:0e27  a000            MOVWF       0x20
                            LAB_CODE_0e28:                ;XREF[1,0]:   CODE:0e11
CODE:CODE:0e28  0317            BSF         STATUS,RP1
CODE:CODE:0e29  1016            BSF         0x10,#0x4
CODE:CODE:0e2a  462e            GOTO        offset LAB_CODE_0e46-0x800
                            LAB_CODE_0e2b:                ;XREF[1,0]:   CODE:0e05
CODE:CODE:0e2b  8312            BCF         STATUS,RP0
CODE:CODE:0e2c  0313            BCF         STATUS,RP1
CODE:CODE:0e2d  3c08            MOVF        0x3c,w
CODE:CODE:0e2e  003a            XORLW       #0x0
CODE:CODE:0e2f  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e30  062e            GOTO        offset LAB_CODE_0e06-0x800
CODE:CODE:0e31  013a            XORLW       #0x1
CODE:CODE:0e32  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e33  092e            GOTO        offset LAB_CODE_0e09-0x800
CODE:CODE:0e34  033a            XORLW       #0x3
CODE:CODE:0e35  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e36  0b2e            GOTO        offset LAB_CODE_0e0b-0x800
CODE:CODE:0e37  013a            XORLW       #0x1
CODE:CODE:0e38  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e39  0f2e            GOTO        offset LAB_CODE_0e0f-0x800
CODE:CODE:0e3a  073a            XORLW       #0x7
CODE:CODE:0e3b  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e3c  122e            GOTO        offset LAB_CODE_0e12-0x800
CODE:CODE:0e3d  013a            XORLW       #0x1
CODE:CODE:0e3e  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e3f  172e            GOTO        offset LAB_CODE_0e17-0x800
CODE:CODE:0e40  033a            XORLW       #0x3
CODE:CODE:0e41  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e42  1c2e            GOTO        offset LAB_CODE_0e1c-0x800
CODE:CODE:0e43  f93a            XORLW       #0xf9
CODE:CODE:0e44  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e45  252e            GOTO        offset LAB_CODE_0e25-0x800
                            LAB_CODE_0e46:                ;XREF[5,0]:   CODE:0e08,CODE:0e0e,CODE:0e16,CODE:0e24
                                                          ;             CODE:0e2a
CODE:CODE:0e46  8312            BCF         STATUS,RP0
CODE:CODE:0e47  0313            BCF         STATUS,RP1
CODE:CODE:0e48  bc1c            BTFSS       0x3c,#0x1
CODE:CODE:0e49  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e4a:                ;XREF[1,0]:   CODE:0d8f
CODE:CODE:0e4a  db30            MOVLW       #0xdb
CODE:CODE:0e4b  702e            GOTO        offset LAB_CODE_0e70-0x800
                            ;************************************************************************************************
                            ;*                                   BigFuckingGoto2 entry 18                                   *
                            ;************************************************************************************************
                            BGT2_18:                      ;XREF[1,0]:   CODE:0ebd
CODE:CODE:0e4c  da30            MOVLW       #0xda
CODE:CODE:0e4d  c700            MOVWF       0x47
CODE:CODE:0e4e  0330            MOVLW       #0x3
CODE:CODE:0e4f  8316            BSF         STATUS,RP0
CODE:CODE:0e50  a004            IORWF       0x20,f
CODE:CODE:0e51  8312            BCF         STATUS,RP0
CODE:CODE:0e52  cb01            CLRF        0x4b
                            LAB_CODE_0e53:                ;XREF[1,0]:   CODE:0e5e
CODE:CODE:0e53  4b08            MOVF        0x4b,w
CODE:CODE:0e54  273e            ADDLW       #0x27
CODE:CODE:0e55  8400            MOVWF       FSR0L
CODE:CODE:0e56  8317            BSF         STATUS,IRP
CODE:CODE:0e57  2030            MOVLW       #0x20
CODE:CODE:0e58  8000            MOVWF       INDF0
CODE:CODE:0e59  cb0a            INCF        0x4b,f
CODE:CODE:0e5a  0a30            MOVLW       #0xa
CODE:CODE:0e5b  4b02            SUBWF       0x4b,w
CODE:CODE:0e5c  0318            BTFSC       STATUS,#0x0
CODE:CODE:0e5d  732e            GOTO        offset LAB_CODE_0e73-0x800
CODE:CODE:0e5e  532e            GOTO        offset LAB_CODE_0e53-0x800
                            LAB_CODE_0e5f:                ;XREF[1,0]:   CODE:0e76
CODE:CODE:0e5f  361e            BTFSS       BANK-0:TIMER1_UNK2,#0x4                 ;= ??
CODE:CODE:0e60  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e61:                ;XREF[1,0]:   CODE:0e79
CODE:CODE:0e61  2a30            MOVLW       #0x2a
CODE:CODE:0e62  642e            GOTO        offset LAB_CODE_0e64-0x800
                            LAB_CODE_0e63:                ;XREF[1,0]:   CODE:0e7c
CODE:CODE:0e63  2030            MOVLW       #0x20
                            LAB_CODE_0e64:                ;XREF[1,0]:   CODE:0e62
CODE:CODE:0e64  0317            BSF         STATUS,RP1
CODE:CODE:0e65  a800            MOVWF       0x28
CODE:CODE:0e66  0313            BCF         STATUS,RP1
CODE:CODE:0e67  ac17            BSF         0x2c,#0x7
CODE:CODE:0e68  4830            MOVLW       #0x48
                            LAB_CODE_0e69:                ;XREF[2,0]:   CODE:0b80,CODE:0b82
CODE:CODE:0e69  8316            BSF         STATUS,RP0
CODE:CODE:0e6a  b100            MOVWF       0x31
CODE:CODE:0e6b  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e6c:                ;XREF[1,0]:   CODE:0e7f
CODE:CODE:0e6c  8316            BSF         STATUS,RP0
CODE:CODE:0e6d  a001            CLRF        0x20
CODE:CODE:0e6e  c830            MOVLW       #0xc8
CODE:CODE:0e6f  8312            BCF         STATUS,RP0
                            LAB_CODE_0e70:                ;XREF[1,0]:   CODE:0e4b
CODE:CODE:0e70  c700            MOVWF       0x47
                            LAB_CODE_0e71:                ;XREF[11,0]:  CODE:0b48,CODE:0c0a,CODE:0c4d,CODE:0c5a
                                                          ;             CODE:0c7e,CODE:0c84,CODE:0cbf,CODE:0cf1
                                                          ;             CODE:0d16,CODE:0d28,CODE:0dd3
CODE:CODE:0e71  c800            MOVWF       BANK-0:DAT_DATA_0048                    ;= ??
CODE:CODE:0e72  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e73:                ;XREF[1,0]:   CODE:0e5d
CODE:CODE:0e73  3b08            MOVF        BANK-0:DAT_DATA_003b,w                  ;= ??
CODE:CODE:0e74  003a            XORLW       #0x0
CODE:CODE:0e75  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e76  5f2e            GOTO        offset LAB_CODE_0e5f-0x800
CODE:CODE:0e77  013a            XORLW       #0x1
CODE:CODE:0e78  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e79  612e            GOTO        offset LAB_CODE_0e61-0x800
CODE:CODE:0e7a  033a            XORLW       #0x3
CODE:CODE:0e7b  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e7c  632e            GOTO        offset LAB_CODE_0e63-0x800
CODE:CODE:0e7d  013a            XORLW       #0x1
CODE:CODE:0e7e  0319            BTFSC       STATUS,#0x2
CODE:CODE:0e7f  6c2e            GOTO        offset LAB_CODE_0e6c-0x800
CODE:CODE:0e80  c62e            GOTO        offset BGT2_4_RET-0x800
                            ;************************************************************************************************
                            ;*                                     START OF BGT SWITCH                                      *
                            ;************************************************************************************************
                            BGT2_Jumper_pre:              ;XREF[1,0]:   CODE:0adf
CODE:CODE:0e81  8312            BCF         STATUS,RP0
CODE:CODE:0e82  3a08            MOVF        0x3a,w
CODE:CODE:0e83  3f39            ANDLW       #0x3f
CODE:CODE:0e84  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:0e85  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:0e86  c22e            GOTO        offset BGT2_Jumper_mid-0x800
                            BGT2_Jumper:                  ;XREF[1,0]:   CODE:0ec5
CODE:CODE:0e87  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:0e88  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:0e89  d63e            ADDLW       #0xd6
CODE:CODE:0e8a  0318            BTFSC       STATUS,#0x0
CODE:CODE:0e8b  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0e8c  2a3e            ADDLW       #0x2a
CODE:CODE:0e8d  031c            BTFSS       STATUS,#0x0
CODE:CODE:0e8e  c62e            GOTO        offset BGT2_4_RET-0x800
CODE:CODE:0e8f  0030            MOVLW       #0x0
CODE:CODE:0e90  f902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:0e91  0e30            MOVLW       #0xe
CODE:CODE:0e92  8a00            MOVWF       PCLATH
CODE:CODE:0e93  9830            MOVLW       #0x98
CODE:CODE:0e94  7907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:0e95  0318            BTFSC       STATUS,#0x0
CODE:CODE:0e96  8a0a            INCF        PCLATH,f
                                                          ; FWD[42,0]:  CODE:0e98,CODE:0e99,CODE:0e9a,CODE:0e9b
                                                          ;             CODE:0e9c,CODE:0e9d,CODE:0e9e,CODE:0e9f
                                                          ;             CODE:0ea0,CODE:0ea1,CODE:0ea2,CODE:0ea3
                                                          ;             CODE:0ea4,CODE:0ea5,CODE:0ea6,CODE:0ea7
                                                          ;             CODE:0ea8,CODE:0ea9,CODE:0eaa,CODE:0eab
                                                          ;             CODE:0eac,CODE:0ead,CODE:0eae,CODE:0eaf
                                                          ;             CODE:0eb0,CODE:0eb1,CODE:0eb2,CODE:0eb3
                                                          ;             CODE:0eb4,CODE:0eb5,CODE:0eb6,CODE:0eb7
                                                          ;             CODE:0eb8,CODE:0eb9,CODE:0eba,CODE:0ebb
                                                          ;             CODE:0ebc,CODE:0ebd,CODE:0ebe,CODE:0ebf
                                                          ;             CODE:0ec0,CODE:0ec1
CODE:CODE:0e97  8200            MOVWF       PC
                            LAB_CODE_0e98:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e98  312b            GOTO        offset BGT2_1-0x800
                            LAB_CODE_0e99:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e99  832b            GOTO        offset BGT2_2-0x800
                            LAB_CODE_0e9a:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9a  ac2b            GOTO        offset BGT2_3-0x800
                            LAB_CODE_0e9b:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9b  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e9c:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9c  5b2c            GOTO        offset BGT2_5-0x800
                            LAB_CODE_0e9d:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9d  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e9e:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9e  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0e9f:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0e9f  b32b            GOTO        offset BGT2_6-0x800
                            LAB_CODE_0ea0:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea0  832b            GOTO        offset BGT2_2-0x800
                            LAB_CODE_0ea1:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea1  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0ea2:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea2  b12c            GOTO        offset BGT2_7-0x800
                            LAB_CODE_0ea3:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea3  df2c            GOTO        offset BGT2_8-0x800
                            LAB_CODE_0ea4:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea4  092d            GOTO        offset BGT2_9-0x800
                            LAB_CODE_0ea5:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea5  e02a            GOTO        offset BGT2_10-0x800
                            LAB_CODE_0ea6:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea6  fb2a            GOTO        offset BGT2_11-0x800
                            LAB_CODE_0ea7:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea7  1b2b            GOTO        offset BGT2_12-0x800
                            LAB_CODE_0ea8:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea8  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0ea9:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ea9  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eaa:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eaa  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eab:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eab  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eac:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eac  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0ead:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ead  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eae:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eae  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eaf:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eaf  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb0:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb0  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb1:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb1  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb2:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb2  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb3:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb3  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb4:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb4  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb5:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb5  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb6:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb6  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb7:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb7  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0eb8:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb8  c62e            GOTO        offset BGT2_4_RET-0x800
                            LAB_CODE_0eb9:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eb9  202d            GOTO        offset BGT2_14-0x800
                            LAB_CODE_0eba:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0eba  812d            GOTO        offset BGT2_15-0x800
                            LAB_CODE_0ebb:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ebb  022e            GOTO        offset BGT2_16-0x800
                            LAB_CODE_0ebc:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ebc  ff2d            GOTO        offset BGT2_17-0x800
                            LAB_CODE_0ebd:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ebd  4c2e            GOTO        offset BGT2_18-0x800
                            LAB_CODE_0ebe:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ebe  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0ebf:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ebf  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0ec0:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ec0  1a2d            GOTO        offset BGT2_13-0x800
                            LAB_CODE_0ec1:                ;XREF[1,0]:   CODE:0e97
CODE:CODE:0ec1  1a2d            GOTO        offset BGT2_13-0x800
                            BGT2_Jumper_mid:              ;XREF[1,0]:   CODE:0e86
CODE:CODE:0ec2  7c08            MOVF        BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:0ec3  003a            XORLW       #0x0
CODE:CODE:0ec4  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ec5  872e            GOTO        offset BGT2_Jumper-0x800
                            ;************************************************************************************************
                            ;*                                BigFuckingGoto2 entry 4/RETURN                                *
                            ;************************************************************************************************
                            BGT2_4_RET:                   ;XREF[47,0]:  CODE:0ad9,CODE:0ae5,CODE:0af8,CODE:0afe
                                                          ;             CODE:0b1a,CODE:0b2b,CODE:0b30,CODE:0b5e
                                                          ;             CODE:0b6a,CODE:0b70,CODE:0b86,CODE:0baf
                                                          ;             CODE:0bb6,CODE:0c08,CODE:0c51,CODE:0c58
                                                          ;             CODE:0c5e,CODE:0c92,CODE:0cab,CODE:0cb0
                                                          ;             CODE:0cb4,CODE:0cdd,CODE:0ce2,CODE:0cff
                                                          ;             CODE:0d04,CODE:0d08,CODE:0d0c,CODE:0d1f
                                                          ;             CODE:0d3d,CODE:0d4a,CODE:0d7c,CODE:0d80
                                                          ;             CODE:0dfc,CODE:0e01,CODE:0e49,CODE:0e60
                                                          ;             CODE:0e6b,CODE:0e72,CODE:0e80,CODE:0e8b
                                                          ;             CODE:0e8e,CODE:0e9b,CODE:0e9d,CODE:0e9e
                                                          ;             CODE:0ea1,CODE:0ea8,CODE:0eb8
CODE:CODE:0ec6  7e20            CALL        offset Elodie &0xff                     ;undefined Elodie()
CODE:CODE:0ec7  af1a            BTFSC       0x2f,#0x5
CODE:CODE:0ec8  3019            BTFSC       0x30,#0x2
CODE:CODE:0ec9  2f2f            GOTO        offset LAB_CODE_0f2f-0x800
CODE:CODE:0eca  b011            BCF         0x30,#0x3
CODE:CODE:0ecb  cb01            CLRF        0x4b
                            LAB_CODE_0ecc:                ;XREF[1,0]:   CODE:0ed6
CODE:CODE:0ecc  4b08            MOVF        0x4b,w
CODE:CODE:0ecd  273e            ADDLW       #0x27
CODE:CODE:0ece  8400            MOVWF       FSR0L
CODE:CODE:0ecf  8317            BSF         STATUS,IRP
CODE:CODE:0ed0  5f30            MOVLW       #0x5f
CODE:CODE:0ed1  8000            MOVWF       INDF0
CODE:CODE:0ed2  cb0a            INCF        0x4b,f
CODE:CODE:0ed3  0a30            MOVLW       #0xa
CODE:CODE:0ed4  4b02            SUBWF       0x4b,w
CODE:CODE:0ed5  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ed6  cc2e            GOTO        offset LAB_CODE_0ecc-0x800
CODE:CODE:0ed7  0317            BSF         STATUS,RP1
CODE:CODE:0ed8  2308            MOVF        0x23,w
CODE:CODE:0ed9  0319            BTFSC       STATUS,#0x2
CODE:CODE:0eda  dd2e            GOTO        offset LAB_CODE_0edd-0x800
CODE:CODE:0edb  ff30            MOVLW       #0xff
CODE:CODE:0edc  a700            MOVWF       0x27
                            LAB_CODE_0edd:                ;XREF[1,0]:   CODE:0eda
CODE:CODE:0edd  0b30            MOVLW       #0xb
CODE:CODE:0ede  2302            SUBWF       0x23,w
CODE:CODE:0edf  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ee0  e32e            GOTO        offset LAB_CODE_0ee3-0x800
CODE:CODE:0ee1  ff30            MOVLW       #0xff
CODE:CODE:0ee2  a800            MOVWF       0x28
                            LAB_CODE_0ee3:                ;XREF[1,0]:   CODE:0ee0
CODE:CODE:0ee3  1530            MOVLW       #0x15
CODE:CODE:0ee4  2302            SUBWF       0x23,w
CODE:CODE:0ee5  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ee6  e92e            GOTO        offset LAB_CODE_0ee9-0x800
CODE:CODE:0ee7  ff30            MOVLW       #0xff
CODE:CODE:0ee8  a900            MOVWF       0x29
                            LAB_CODE_0ee9:                ;XREF[1,0]:   CODE:0ee6
CODE:CODE:0ee9  1f30            MOVLW       #0x1f
CODE:CODE:0eea  2302            SUBWF       0x23,w
CODE:CODE:0eeb  031c            BTFSS       STATUS,#0x0
CODE:CODE:0eec  ef2e            GOTO        offset LAB_CODE_0eef-0x800
CODE:CODE:0eed  ff30            MOVLW       #0xff
CODE:CODE:0eee  aa00            MOVWF       0x2a
                            LAB_CODE_0eef:                ;XREF[1,0]:   CODE:0eec
CODE:CODE:0eef  2930            MOVLW       #0x29
CODE:CODE:0ef0  2302            SUBWF       0x23,w
CODE:CODE:0ef1  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ef2  f52e            GOTO        offset LAB_CODE_0ef5-0x800
CODE:CODE:0ef3  ff30            MOVLW       #0xff
CODE:CODE:0ef4  ab00            MOVWF       0x2b
                            LAB_CODE_0ef5:                ;XREF[1,0]:   CODE:0ef2
CODE:CODE:0ef5  3330            MOVLW       #0x33
CODE:CODE:0ef6  2302            SUBWF       0x23,w
CODE:CODE:0ef7  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ef8  fb2e            GOTO        offset LAB_CODE_0efb-0x800
CODE:CODE:0ef9  ff30            MOVLW       #0xff
CODE:CODE:0efa  ac00            MOVWF       0x2c
                            LAB_CODE_0efb:                ;XREF[1,0]:   CODE:0ef8
CODE:CODE:0efb  3d30            MOVLW       #0x3d
CODE:CODE:0efc  2302            SUBWF       0x23,w
CODE:CODE:0efd  031c            BTFSS       STATUS,#0x0
CODE:CODE:0efe  012f            GOTO        offset LAB_CODE_0f01-0x800
CODE:CODE:0eff  ff30            MOVLW       #0xff
CODE:CODE:0f00  ad00            MOVWF       0x2d
                            LAB_CODE_0f01:                ;XREF[1,0]:   CODE:0efe
CODE:CODE:0f01  4730            MOVLW       #0x47
CODE:CODE:0f02  2302            SUBWF       0x23,w
CODE:CODE:0f03  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f04  072f            GOTO        offset LAB_CODE_0f07-0x800
CODE:CODE:0f05  ff30            MOVLW       #0xff
CODE:CODE:0f06  ae00            MOVWF       0x2e
                            LAB_CODE_0f07:                ;XREF[1,0]:   CODE:0f04
CODE:CODE:0f07  5130            MOVLW       #0x51
CODE:CODE:0f08  2302            SUBWF       0x23,w
CODE:CODE:0f09  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f0a  0d2f            GOTO        offset LAB_CODE_0f0d-0x800
CODE:CODE:0f0b  ff30            MOVLW       #0xff
CODE:CODE:0f0c  af00            MOVWF       0x2f
                            LAB_CODE_0f0d:                ;XREF[1,0]:   CODE:0f0a
CODE:CODE:0f0d  5b30            MOVLW       #0x5b
CODE:CODE:0f0e  2302            SUBWF       0x23,w
CODE:CODE:0f0f  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f10  132f            GOTO        offset LAB_CODE_0f13-0x800
CODE:CODE:0f11  ff30            MOVLW       #0xff
CODE:CODE:0f12  b000            MOVWF       0x30
                            LAB_CODE_0f13:                ;XREF[1,0]:   CODE:0f10
CODE:CODE:0f13  4530            MOVLW       #0x45
CODE:CODE:0f14  8316            BSF         STATUS,RP0
CODE:CODE:0f15  0313            BCF         STATUS,RP1
CODE:CODE:0f16  b100            MOVWF       0x31
CODE:CODE:0f17  8312            BCF         STATUS,RP0
CODE:CODE:0f18  cb01            CLRF        0x4b
                            LAB_CODE_0f19:                ;XREF[1,0]:   CODE:0f2d
CODE:CODE:0f19  4b08            MOVF        0x4b,w
CODE:CODE:0f1a  273e            ADDLW       #0x27
CODE:CODE:0f1b  8400            MOVWF       FSR0L
CODE:CODE:0f1c  8317            BSF         STATUS,IRP
CODE:CODE:0f1d  0008            MOVF        INDF0,w
CODE:CODE:0f1e  cc00            MOVWF       0x4c
CODE:CODE:0f1f  4b08            MOVF        0x4b,w
CODE:CODE:0f20  913e            ADDLW       #0x91
CODE:CODE:0f21  8400            MOVWF       FSR0L
CODE:CODE:0f22  8317            BSF         STATUS,IRP
CODE:CODE:0f23  0008            MOVF        INDF0,w
CODE:CODE:0f24  4c06            XORWF       0x4c,w
CODE:CODE:0f25  0319            BTFSC       STATUS,#0x2
CODE:CODE:0f26  292f            GOTO        offset LAB_CODE_0f29-0x800
CODE:CODE:0f27  0c30            MOVLW       #0xc
CODE:CODE:0f28  cb00            MOVWF       0x4b
                            LAB_CODE_0f29:                ;XREF[1,0]:   CODE:0f26
CODE:CODE:0f29  cb0a            INCF        0x4b,f
CODE:CODE:0f2a  0a30            MOVLW       #0xa
CODE:CODE:0f2b  4b02            SUBWF       0x4b,w
CODE:CODE:0f2c  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f2d  192f            GOTO        offset LAB_CODE_0f19-0x800
CODE:CODE:0f2e  492f            GOTO        offset LAB_CODE_0f49-0x800
                            LAB_CODE_0f2f:                ;XREF[1,0]:   CODE:0ec9
CODE:CODE:0f2f  ac1b            BTFSC       BANK-0:ENTRY_DATA_UNK3,#0x7             ;= ??
CODE:CODE:0f30  3019            BTFSC       0x30,#0x2
CODE:CODE:0f31  4e2f            GOTO        offset LAB_CODE_0f4e-0x800
CODE:CODE:0f32  b011            BCF         0x30,#0x3
CODE:CODE:0f33  cb01            CLRF        0x4b
                            LAB_CODE_0f34:                ;XREF[1,0]:   CODE:0f48
CODE:CODE:0f34  4b08            MOVF        0x4b,w
CODE:CODE:0f35  273e            ADDLW       #0x27
CODE:CODE:0f36  8400            MOVWF       FSR0L
CODE:CODE:0f37  8317            BSF         STATUS,IRP
CODE:CODE:0f38  0008            MOVF        INDF0,w
CODE:CODE:0f39  cc00            MOVWF       0x4c
CODE:CODE:0f3a  4b08            MOVF        0x4b,w
CODE:CODE:0f3b  913e            ADDLW       #0x91
CODE:CODE:0f3c  8400            MOVWF       FSR0L
CODE:CODE:0f3d  8317            BSF         STATUS,IRP
CODE:CODE:0f3e  0008            MOVF        INDF0,w
CODE:CODE:0f3f  4c06            XORWF       0x4c,w
CODE:CODE:0f40  0319            BTFSC       STATUS,#0x2
CODE:CODE:0f41  442f            GOTO        offset LAB_CODE_0f44-0x800
CODE:CODE:0f42  0c30            MOVLW       #0xc
CODE:CODE:0f43  cb00            MOVWF       0x4b
                            LAB_CODE_0f44:                ;XREF[1,0]:   CODE:0f41
CODE:CODE:0f44  cb0a            INCF        0x4b,f
CODE:CODE:0f45  0a30            MOVLW       #0xa
CODE:CODE:0f46  4b02            SUBWF       0x4b,w
CODE:CODE:0f47  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f48  342f            GOTO        offset LAB_CODE_0f34-0x800
                            LAB_CODE_0f49:                ;XREF[1,0]:   CODE:0f2e
CODE:CODE:0f49  0c30            MOVLW       #0xc
CODE:CODE:0f4a  4b02            SUBWF       0x4b,w
CODE:CODE:0f4b  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f4c  662f            GOTO        offset LAB_CODE_0f66-0x800
CODE:CODE:0f4d  632f            GOTO        offset LAB_CODE_0f63-0x800
                            LAB_CODE_0f4e:                ;XREF[1,0]:   CODE:0f31
CODE:CODE:0f4e  cb01            CLRF        BANK-0:DAT_DATA_004b                    ;= ??
                            LAB_CODE_0f4f:                ;XREF[1,0]:   CODE:0f5f
CODE:CODE:0f4f  4b08            MOVF        0x4b,w
CODE:CODE:0f50  273e            ADDLW       #0x27
CODE:CODE:0f51  8400            MOVWF       FSR0L
CODE:CODE:0f52  8317            BSF         STATUS,IRP
CODE:CODE:0f53  2030            MOVLW       #0x20
CODE:CODE:0f54  8000            MOVWF       INDF0
CODE:CODE:0f55  4b08            MOVF        0x4b,w
CODE:CODE:0f56  913e            ADDLW       #0x91
CODE:CODE:0f57  8400            MOVWF       FSR0L
CODE:CODE:0f58  8317            BSF         STATUS,IRP
CODE:CODE:0f59  2030            MOVLW       #0x20
CODE:CODE:0f5a  8000            MOVWF       INDF0
CODE:CODE:0f5b  cb0a            INCF        0x4b,f
CODE:CODE:0f5c  0a30            MOVLW       #0xa
CODE:CODE:0f5d  4b02            SUBWF       0x4b,w
CODE:CODE:0f5e  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f5f  4f2f            GOTO        offset LAB_CODE_0f4f-0x800
CODE:CODE:0f60  b019            BTFSC       0x30,#0x3
CODE:CODE:0f61  662f            GOTO        offset LAB_CODE_0f66-0x800
CODE:CODE:0f62  b015            BSF         0x30,#0x3
                            LAB_CODE_0f63:                ;XREF[1,0]:   CODE:0f4d
CODE:CODE:0f63  8316            BSF         STATUS,RP0
CODE:CODE:0f64  3108            MOVF        0x31,w
CODE:CODE:0f65  3220            CALL        offset Emma &0xff                       ;undefined Emma()
                            LAB_CODE_0f66:                ;XREF[2,0]:   CODE:0f4c,CODE:0f61
CODE:CODE:0f66  4608            MOVF        0x46,w
CODE:CODE:0f67  8316            BSF         STATUS,RP0
CODE:CODE:0f68  2906            XORWF       0x29,w
CODE:CODE:0f69  0319            BTFSC       STATUS,#0x2
CODE:CODE:0f6a  8f2f            GOTO        offset LAB_CODE_0f8f-0x800
CODE:CODE:0f6b  3a08            MOVF        0x3a,w
CODE:CODE:0f6c  8312            BCF         STATUS,RP0
CODE:CODE:0f6d  4706            XORWF       0x47,w
CODE:CODE:0f6e  8316            BSF         STATUS,RP0
CODE:CODE:0f6f  031d            BTFSS       STATUS,#0x2
CODE:CODE:0f70  8f2f            GOTO        offset LAB_CODE_0f8f-0x800
CODE:CODE:0f71  3b08            MOVF        0x3b,w
CODE:CODE:0f72  8312            BCF         STATUS,RP0
CODE:CODE:0f73  4806            XORWF       0x48,w
CODE:CODE:0f74  8316            BSF         STATUS,RP0
CODE:CODE:0f75  031d            BTFSS       STATUS,#0x2
CODE:CODE:0f76  8f2f            GOTO        offset LAB_CODE_0f8f-0x800
CODE:CODE:0f77  2908            MOVF        0x29,w
CODE:CODE:0f78  8312            BCF         STATUS,RP0
CODE:CODE:0f79  c600            MOVWF       0x46
CODE:CODE:0f7a  3230            MOVLW       #0x32
CODE:CODE:0f7b  8316            BSF         STATUS,RP0
CODE:CODE:0f7c  c700            MOVWF       0x47
CODE:CODE:0f7d  c800            MOVWF       0x48
CODE:CODE:0f7e  8312            BCF         STATUS,RP0
CODE:CODE:0f7f  cb01            CLRF        0x4b
                            LAB_CODE_0f80:                ;XREF[1,0]:   CODE:0f8a
CODE:CODE:0f80  4b08            MOVF        0x4b,w
CODE:CODE:0f81  273e            ADDLW       #0x27
CODE:CODE:0f82  8400            MOVWF       FSR0L
CODE:CODE:0f83  8317            BSF         STATUS,IRP
CODE:CODE:0f84  2030            MOVLW       #0x20
CODE:CODE:0f85  8000            MOVWF       INDF0
CODE:CODE:0f86  cb0a            INCF        0x4b,f
CODE:CODE:0f87  0a30            MOVLW       #0xa
CODE:CODE:0f88  4b02            SUBWF       0x4b,w
CODE:CODE:0f89  031c            BTFSS       STATUS,#0x0
CODE:CODE:0f8a  802f            GOTO        offset LAB_CODE_0f80-0x800
CODE:CODE:0f8b  ff30            MOVLW       #0xff
CODE:CODE:0f8c  8316            BSF         STATUS,RP0
CODE:CODE:0f8d  ba00            MOVWF       0x3a
CODE:CODE:0f8e  bb00            MOVWF       0x3b
                            LAB_CODE_0f8f:                ;XREF[3,0]:   CODE:0f6a,CODE:0f70,CODE:0f76
CODE:CODE:0f8f  3a08            MOVF        0x3a,w
CODE:CODE:0f90  8312            BCF         STATUS,RP0
CODE:CODE:0f91  4706            XORWF       0x47,w
CODE:CODE:0f92  8316            BSF         STATUS,RP0
CODE:CODE:0f93  031d            BTFSS       STATUS,#0x2
CODE:CODE:0f94  bd2f            GOTO        offset LAB_CODE_0fbd-0x800
CODE:CODE:0f95  3b08            MOVF        0x3b,w
CODE:CODE:0f96  8312            BCF         STATUS,RP0
CODE:CODE:0f97  4806            XORWF       0x48,w
CODE:CODE:0f98  031d            BTFSS       STATUS,#0x2
CODE:CODE:0f99  bc2f            GOTO        offset LAB_CODE_0fbc-0x800
CODE:CODE:0f9a  ac1f            BTFSS       0x2c,#0x7
CODE:CODE:0f9b  af1a            BTFSC       0x2f,#0x5
CODE:CODE:0f9c  bc2f            GOTO        offset LAB_CODE_0fbc-0x800
CODE:CODE:0f9d  8316            BSF         STATUS,RP0
CODE:CODE:0f9e  cd08            MOVF        0x4d,f
CODE:CODE:0f9f  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fa0  bc2f            GOTO        offset LAB_CODE_0fbc-0x800
CODE:CODE:0fa1  1e30            MOVLW       #0x1e
CODE:CODE:0fa2  cd00            MOVWF       0x4d
CODE:CODE:0fa3  3230            MOVLW       #0x32
CODE:CODE:0fa4  c700            MOVWF       0x47
CODE:CODE:0fa5  c800            MOVWF       0x48
CODE:CODE:0fa6  ff30            MOVLW       #0xff
CODE:CODE:0fa7  0a12            BCF         PCLATH,#0x4
CODE:CODE:0fa8  8a11            BCF         PCLATH,#0x3
CODE:CODE:0fa9  2321            CALL        Emy                                     ;undefined Emy()
CODE:CODE:0faa  0a12            BCF         PCLATH,#0x4
CODE:CODE:0fab  8a15            BSF         PCLATH,#0x3
CODE:CODE:0fac  cb01            CLRF        0x4b
                            LAB_CODE_0fad:                ;XREF[1,0]:   CODE:0fb7
CODE:CODE:0fad  4b08            MOVF        0x4b,w
CODE:CODE:0fae  273e            ADDLW       #0x27
CODE:CODE:0faf  8400            MOVWF       FSR0L
CODE:CODE:0fb0  8317            BSF         STATUS,IRP
CODE:CODE:0fb1  2030            MOVLW       #0x20
CODE:CODE:0fb2  8000            MOVWF       INDF0
CODE:CODE:0fb3  cb0a            INCF        0x4b,f
CODE:CODE:0fb4  0a30            MOVLW       #0xa
CODE:CODE:0fb5  4b02            SUBWF       0x4b,w
CODE:CODE:0fb6  031c            BTFSS       STATUS,#0x0
CODE:CODE:0fb7  ad2f            GOTO        offset LAB_CODE_0fad-0x800
CODE:CODE:0fb8  ff30            MOVLW       #0xff
CODE:CODE:0fb9  8316            BSF         STATUS,RP0
CODE:CODE:0fba  ba00            MOVWF       0x3a
CODE:CODE:0fbb  bb00            MOVWF       0x3b
                            LAB_CODE_0fbc:                ;XREF[3,0]:   CODE:0f99,CODE:0f9c,CODE:0fa0
CODE:CODE:0fbc  8316            BSF         STATUS,RP0
                            LAB_CODE_0fbd:                ;XREF[1,0]:   CODE:0f94
CODE:CODE:0fbd  3a08            MOVF        0x3a,w
CODE:CODE:0fbe  8312            BCF         STATUS,RP0
CODE:CODE:0fbf  4706            XORWF       0x47,w
CODE:CODE:0fc0  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fc1  ce2f            GOTO        offset LAB_CODE_0fce-0x800
CODE:CODE:0fc2  ac1f            BTFSS       0x2c,#0x7
CODE:CODE:0fc3  af1a            BTFSC       0x2f,#0x5
CODE:CODE:0fc4  ce2f            GOTO        offset LAB_CODE_0fce-0x800
CODE:CODE:0fc5  8316            BSF         STATUS,RP0
CODE:CODE:0fc6  c708            MOVF        0x47,f
CODE:CODE:0fc7  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fc8  d12f            GOTO        offset LAB_CODE_0fd1-0x800
CODE:CODE:0fc9  3230            MOVLW       #0x32
CODE:CODE:0fca  c700            MOVWF       0x47
CODE:CODE:0fcb  ff30            MOVLW       #0xff
CODE:CODE:0fcc  ba00            MOVWF       0x3a
CODE:CODE:0fcd  d12f            GOTO        offset LAB_CODE_0fd1-0x800
                            LAB_CODE_0fce:                ;XREF[2,0]:   CODE:0fc1,CODE:0fc4
CODE:CODE:0fce  3230            MOVLW       #0x32
CODE:CODE:0fcf  8316            BSF         STATUS,RP0
CODE:CODE:0fd0  c700            MOVWF       0x47
                            LAB_CODE_0fd1:                ;XREF[2,0]:   CODE:0fc8,CODE:0fcd
CODE:CODE:0fd1  3b08            MOVF        0x3b,w
CODE:CODE:0fd2  8312            BCF         STATUS,RP0
CODE:CODE:0fd3  4806            XORWF       0x48,w
CODE:CODE:0fd4  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fd5  e22f            GOTO        offset LAB_CODE_0fe2-0x800
CODE:CODE:0fd6  ac1f            BTFSS       0x2c,#0x7
CODE:CODE:0fd7  af1a            BTFSC       0x2f,#0x5
CODE:CODE:0fd8  e22f            GOTO        offset LAB_CODE_0fe2-0x800
CODE:CODE:0fd9  8316            BSF         STATUS,RP0
CODE:CODE:0fda  c808            MOVF        0x48,f
CODE:CODE:0fdb  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fdc  e52f            GOTO        offset LAB_CODE_0fe5-0x800
CODE:CODE:0fdd  3230            MOVLW       #0x32
CODE:CODE:0fde  c800            MOVWF       0x48
CODE:CODE:0fdf  ff30            MOVLW       #0xff
CODE:CODE:0fe0  bb00            MOVWF       0x3b
CODE:CODE:0fe1  e52f            GOTO        offset LAB_CODE_0fe5-0x800
                            LAB_CODE_0fe2:                ;XREF[2,0]:   CODE:0fd5,CODE:0fd8
CODE:CODE:0fe2  3230            MOVLW       #0x32
CODE:CODE:0fe3  8316            BSF         STATUS,RP0
CODE:CODE:0fe4  c800            MOVWF       0x48
                            LAB_CODE_0fe5:                ;XREF[2,0]:   CODE:0fdc,CODE:0fe1
CODE:CODE:0fe5  8312            BCF         STATUS,RP0
CODE:CODE:0fe6  3a08            MOVF        0x3a,w
CODE:CODE:0fe7  3f39            ANDLW       #0x3f
CODE:CODE:0fe8  031d            BTFSS       STATUS,#0x2
CODE:CODE:0fe9  f52f            GOTO        offset LAB_CODE_0ff5-0x800
CODE:CODE:0fea  3b08            MOVF        0x3b,w
CODE:CODE:0feb  1f39            ANDLW       #0x1f
CODE:CODE:0fec  cc00            MOVWF       0x4c
CODE:CODE:0fed  0230            MOVLW       #0x2
CODE:CODE:0fee  4c02            SUBWF       0x4c,w
CODE:CODE:0fef  031c            BTFSS       STATUS,#0x0
CODE:CODE:0ff0  f52f            GOTO        offset LAB_CODE_0ff5-0x800
CODE:CODE:0ff1  8316            BSF         STATUS,RP0
CODE:CODE:0ff2  c908            MOVF        0x49,f
CODE:CODE:0ff3  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ff4  fe2f            GOTO        offset LAB_CODE_0ffe-0x800
                            LAB_CODE_0ff5:                ;XREF[2,0]:   CODE:0fe9,CODE:0ff0
CODE:CODE:0ff5  8312            BCF         STATUS,RP0
CODE:CODE:0ff6  3a08            MOVF        0x3a,w
CODE:CODE:0ff7  3f39            ANDLW       #0x3f
CODE:CODE:0ff8  233a            XORLW       #0x23
CODE:CODE:0ff9  0319            BTFSC       STATUS,#0x2
CODE:CODE:0ffa  fe2f            GOTO        offset LAB_CODE_0ffe-0x800
CODE:CODE:0ffb  8316            BSF         STATUS,RP0
CODE:CODE:0ffc  0317            BSF         STATUS,RP1
CODE:CODE:0ffd  1016            BSF         0x10,#0x4
                            LAB_CODE_0ffe:                ;XREF[2,0]:   CODE:0ff4,CODE:0ffa
CODE:CODE:0ffe  8301            CLRF        STATUS
CODE:CODE:0fff  0800            RETURN
CODE:CODE:1000  ff3fff3ff...    db[8]
   |_CODE:CODE:1000  [0]             db          FFh
   |_CODE:CODE:1000.1[1]             db          3Fh
   |_CODE:CODE:1001  [2]             db          FFh
   |_CODE:CODE:1001.1[3]             db          3Fh
   |_CODE:CODE:1002  [4]             db          FFh
   |_CODE:CODE:1002.1[5]             db          3Fh
   |_CODE:CODE:1003  [6]             db          FFh
   |_CODE:CODE:1003.1[7]             db          3Fh
                            ;************************************************************************************************
                            ;*                                  Part of the ENTRY/Mainloop                                  *
                            ;************************************************************************************************
                            ENTRY_SUB_AND_MAINLOOP:       ;XREF[1,0]:   CODE:0093
CODE:CODE:1004  8312            BCF         STATUS,RP0
CODE:CODE:1005  0313            BCF         STATUS,RP1
CODE:CODE:1006  ad13            BCF         BANK-0:USART_RX_PACKET_STATUS,#0x7      ;= ??
CODE:CODE:1007  2f17            BSF         BANK-0:ENTRY_DATA_UNK1,#0x6             ;= ??
CODE:CODE:1008  8316            BSF         STATUS,RP0
CODE:CODE:1009  0317            BSF         STATUS,RP1
CODE:CODE:100a  1012            BCF         BANK-3:TIMER1_UNK1,#0x4                 ;= ??
CODE:CODE:100b  0313            BCF         STATUS,RP1
CODE:CODE:100c  b301            CLRF        BANK-1:ENTRY_DATA_UNK2                  ;= ??
CODE:CODE:100d  8312            BCF         STATUS,RP0
CODE:CODE:100e  2c10            BCF         BANK-0:ENTRY_DATA_UNK3,#0x0             ;= ??
CODE:CODE:100f  6400            CLRWDT
CODE:CODE:1010  1e30            MOVLW       #0x1e
CODE:CODE:1011  0a16            BSF         PCLATH,#0x4
CODE:CODE:1012  8a15            BSF         PCLATH,#0x3
CODE:CODE:1013  7126            CALL        offset delay_2ms-0x1800                 ;undefined delay_2ms()
CODE:CODE:1014  0a16            BSF         PCLATH,#0x4
CODE:CODE:1015  8a15            BSF         PCLATH,#0x3
CODE:CODE:1016  4727            CALL        offset init_hardware_1-0x1800           ;undefined init_hardware_1()
CODE:CODE:1017  0517            BSF         FSR0H,#0x6
CODE:CODE:1018  6400            CLRWDT
CODE:CODE:1019  0a16            BSF         PCLATH,#0x4
CODE:CODE:101a  8a15            BSF         PCLATH,#0x3
CODE:CODE:101b  8b26            CALL        offset init_hardware_2-0x1800           ;undefined init_hardware_2()
CODE:CODE:101c  0a16            BSF         PCLATH,#0x4
CODE:CODE:101d  8a11            BCF         PCLATH,#0x3
CODE:CODE:101e  0725            CALL        offset init_something_2-0x1000          ;undefined init_something_2()
CODE:CODE:101f  0030            MOVLW       #0x0
CODE:CODE:1020  0a12            BCF         PCLATH,#0x4
CODE:CODE:1021  8a11            BCF         PCLATH,#0x3
CODE:CODE:1022  2321            CALL        Emy                                     ;undefined Emy()
CODE:CODE:1023  0a16            BSF         PCLATH,#0x4
CODE:CODE:1024  8a11            BCF         PCLATH,#0x3
CODE:CODE:1025  e826            CALL        offset Eleonore-0x1000                  ;undefined Eleonore()
CODE:CODE:1026  0b17            BSF         INTCON,PEIE
CODE:CODE:1027  8b17            BSF         INTCON,GIE
                            LAB_CODE_1028:                ;XREF[2,0]:   CODE:103c,CODE:1047
CODE:CODE:1028  6400            CLRWDT
CODE:CODE:1029  0a12            BCF         PCLATH,#0x4
CODE:CODE:102a  8a11            BCF         PCLATH,#0x3
CODE:CODE:102b  2327            CALL        MAINLOOP_SUB1                           ;undefined MAINLOOP_SUB1()
CODE:CODE:102c  6400            CLRWDT
CODE:CODE:102d  0a16            BSF         PCLATH,#0x4
CODE:CODE:102e  8a11            BCF         PCLATH,#0x3
CODE:CODE:102f  cb22            CALL        offset MAINLOOP_SUB2-0x1000             ;undefined MAINLOOP_SUB2()
CODE:CODE:1030  6400            CLRWDT
CODE:CODE:1031  0a16            BSF         PCLATH,#0x4
CODE:CODE:1032  8a11            BCF         PCLATH,#0x3
CODE:CODE:1033  d820            CALL        offset MAINLOOP_SUB3 &0xff              ;undefined MAINLOOP_SUB3()
CODE:CODE:1034  6400            CLRWDT
CODE:CODE:1035  0a12            BCF         PCLATH,#0x4
CODE:CODE:1036  8a11            BCF         PCLATH,#0x3
CODE:CODE:1037  b825            CALL        USART_MAYBE_LOGIC                       ;undefined USART_MAYBE_LOGIC()
CODE:CODE:1038  0a16            BSF         PCLATH,#0x4
CODE:CODE:1039  8a11            BCF         PCLATH,#0x3
CODE:CODE:103a  6400            CLRWDT
CODE:CODE:103b  2c1c            BTFSS       0x2c,#0x0
CODE:CODE:103c  2828            GOTO        offset LAB_CODE_1028 &0xff
CODE:CODE:103d  0a16            BSF         PCLATH,#0x4
CODE:CODE:103e  8a11            BCF         PCLATH,#0x3
CODE:CODE:103f  5925            CALL        offset Coralie-0x1000                   ;undefined Coralie()
CODE:CODE:1040  6400            CLRWDT
CODE:CODE:1041  0a12            BCF         PCLATH,#0x4
CODE:CODE:1042  8a15            BSF         PCLATH,#0x3
CODE:CODE:1043  c622            CALL        offset MAINLOOP_MAIN_LOGIC-0x800        ;undefined MAINLOOP_MAIN_LOGIC()
CODE:CODE:1044  0a16            BSF         PCLATH,#0x4
CODE:CODE:1045  8a11            BCF         PCLATH,#0x3
CODE:CODE:1046  6400            CLRWDT
CODE:CODE:1047  2828            GOTO        offset LAB_CODE_1028 &0xff
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined MAINLOOP_MAIN_LOGIC_SUB1()
                                                          ;XREF[4,0]:   CODE:0234,CODE:0266,CODE:02c8,CODE:0b79
CODE:CODE:1048  8301            CLRF        STATUS
CODE:CODE:1049  ce00            MOVWF       0x4e
CODE:CODE:104a  cf01            CLRF        0x4f
                            LAB_CODE_104b:                ;XREF[1,0]:   CODE:1055
CODE:CODE:104b  4f08            MOVF        0x4f,w
CODE:CODE:104c  273e            ADDLW       #0x27
CODE:CODE:104d  8400            MOVWF       FSR0L
CODE:CODE:104e  8317            BSF         STATUS,IRP
CODE:CODE:104f  2030            MOVLW       #0x20
CODE:CODE:1050  8000            MOVWF       INDF0
CODE:CODE:1051  cf0a            INCF        0x4f,f
CODE:CODE:1052  0a30            MOVLW       #0xa
CODE:CODE:1053  4f02            SUBWF       0x4f,w
CODE:CODE:1054  031c            BTFSS       STATUS,#0x0
CODE:CODE:1055  4b28            GOTO        offset LAB_CODE_104b &0xff
CODE:CODE:1056  b618            BTFSC       0x36,#0x1
CODE:CODE:1057  7d28            GOTO        offset LAB_CODE_107d &0xff
CODE:CODE:1058  1230            MOVLW       #0x12
CODE:CODE:1059  8316            BSF         STATUS,RP0
CODE:CODE:105a  2202            SUBWF       0x22,w
CODE:CODE:105b  031c            BTFSS       STATUS,#0x0
CODE:CODE:105c  7228            GOTO        offset LAB_CODE_1072 &0xff
CODE:CODE:105d  2208            MOVF        0x22,w
CODE:CODE:105e  213a            XORLW       #0x21
CODE:CODE:105f  031d            BTFSS       STATUS,#0x2
CODE:CODE:1060  6328            GOTO        offset LAB_CODE_1063 &0xff
CODE:CODE:1061  0930            MOVLW       #0x9
CODE:CODE:1062  6828            GOTO        offset LAB_CODE_1068 &0xff
                            LAB_CODE_1063:                ;XREF[1,0]:   CODE:1060
CODE:CODE:1063  2208            MOVF        BANK-0:DAT_DATA_0022,w                  ;= ??
CODE:CODE:1064  203a            XORLW       #0x20
CODE:CODE:1065  031d            BTFSS       STATUS,#0x2
CODE:CODE:1066  6a28            GOTO        offset LAB_CODE_106a &0xff
CODE:CODE:1067  0830            MOVLW       #0x8
                            LAB_CODE_1068:                ;XREF[1,0]:   CODE:1062
CODE:CODE:1068  a200            MOVWF       0x22
CODE:CODE:1069  7028            GOTO        offset LAB_CODE_1070 &0xff
                            LAB_CODE_106a:                ;XREF[1,0]:   CODE:1066
CODE:CODE:106a  1330            MOVLW       #0x13
CODE:CODE:106b  2202            SUBWF       0x22,w
CODE:CODE:106c  031c            BTFSS       STATUS,#0x0
CODE:CODE:106d  7028            GOTO        offset LAB_CODE_1070 &0xff
CODE:CODE:106e  ee30            MOVLW       #0xee
CODE:CODE:106f  a207            ADDWF       0x22,f
                            LAB_CODE_1070:                ;XREF[2,0]:   CODE:1069,CODE:106d
CODE:CODE:1070  5030            MOVLW       #0x50
CODE:CODE:1071  7828            GOTO        offset LAB_CODE_1078 &0xff
                            LAB_CODE_1072:                ;XREF[1,0]:   CODE:105c
CODE:CODE:1072  a208            MOVF        BANK-0:DAT_DATA_0022,f                  ;= ??
CODE:CODE:1073  031d            BTFSS       STATUS,#0x2
CODE:CODE:1074  7728            GOTO        offset LAB_CODE_1077 &0xff
CODE:CODE:1075  1230            MOVLW       #0x12
CODE:CODE:1076  a200            MOVWF       0x22
                            LAB_CODE_1077:                ;XREF[1,0]:   CODE:1074
CODE:CODE:1077  4130            MOVLW       #0x41
                            LAB_CODE_1078:                ;XREF[1,0]:   CODE:1071
CODE:CODE:1078  8312            BCF         STATUS,RP0
CODE:CODE:1079  0317            BSF         STATUS,RP1
CODE:CODE:107a  ad00            MOVWF       0x2d
CODE:CODE:107b  4d30            MOVLW       #0x4d
CODE:CODE:107c  ae00            MOVWF       0x2e
                            LAB_CODE_107d:                ;XREF[1,0]:   CODE:1057
CODE:CODE:107d  8316            BSF         STATUS,RP0
CODE:CODE:107e  0313            BCF         STATUS,RP1
CODE:CODE:107f  220e            SWAPF       0x22,w
CODE:CODE:1080  0f39            ANDLW       #0xf
CODE:CODE:1081  3038            IORLW       #0x30
CODE:CODE:1082  8312            BCF         STATUS,RP0
CODE:CODE:1083  0317            BSF         STATUS,RP1
CODE:CODE:1084  a700            MOVWF       0x27
CODE:CODE:1085  8316            BSF         STATUS,RP0
CODE:CODE:1086  0313            BCF         STATUS,RP1
CODE:CODE:1087  2208            MOVF        0x22,w
CODE:CODE:1088  0f39            ANDLW       #0xf
CODE:CODE:1089  3038            IORLW       #0x30
CODE:CODE:108a  8312            BCF         STATUS,RP0
CODE:CODE:108b  0317            BSF         STATUS,RP1
CODE:CODE:108c  a800            MOVWF       0x28
CODE:CODE:108d  3a30            MOVLW       #0x3a
CODE:CODE:108e  a900            MOVWF       0x29
CODE:CODE:108f  8316            BSF         STATUS,RP0
CODE:CODE:1090  0313            BCF         STATUS,RP1
CODE:CODE:1091  2c0e            SWAPF       0x2c,w
CODE:CODE:1092  0f39            ANDLW       #0xf
CODE:CODE:1093  3038            IORLW       #0x30
CODE:CODE:1094  8312            BCF         STATUS,RP0
CODE:CODE:1095  0317            BSF         STATUS,RP1
CODE:CODE:1096  aa00            MOVWF       0x2a
CODE:CODE:1097  8316            BSF         STATUS,RP0
CODE:CODE:1098  0313            BCF         STATUS,RP1
CODE:CODE:1099  2c08            MOVF        0x2c,w
CODE:CODE:109a  0f39            ANDLW       #0xf
CODE:CODE:109b  3038            IORLW       #0x30
CODE:CODE:109c  8312            BCF         STATUS,RP0
CODE:CODE:109d  0317            BSF         STATUS,RP1
CODE:CODE:109e  ab00            MOVWF       0x2b
CODE:CODE:109f  0313            BCF         STATUS,RP1
CODE:CODE:10a0  4e08            MOVF        0x4e,w
CODE:CODE:10a1  023a            XORLW       #0x2
CODE:CODE:10a2  031d            BTFSS       STATUS,#0x2
CODE:CODE:10a3  ac28            GOTO        offset LAB_CODE_10ac &0xff
CODE:CODE:10a4  8316            BSF         STATUS,RP0
CODE:CODE:10a5  0317            BSF         STATUS,RP1
CODE:CODE:10a6  101f            BTFSS       0x10,#0x6
CODE:CODE:10a7  ac28            GOTO        offset LAB_CODE_10ac &0xff
CODE:CODE:10a8  2030            MOVLW       #0x20
CODE:CODE:10a9  8312            BCF         STATUS,RP0
CODE:CODE:10aa  a700            MOVWF       0x27
CODE:CODE:10ab  a800            MOVWF       0x28
                            LAB_CODE_10ac:                ;XREF[2,0]:   CODE:10a3,CODE:10a7
CODE:CODE:10ac  8312            BCF         STATUS,RP0
CODE:CODE:10ad  0313            BCF         STATUS,RP1
CODE:CODE:10ae  4e08            MOVF        0x4e,w
CODE:CODE:10af  033a            XORLW       #0x3
CODE:CODE:10b0  031d            BTFSS       STATUS,#0x2
CODE:CODE:10b1  ba28            GOTO        offset LAB_CODE_10ba &0xff
CODE:CODE:10b2  8316            BSF         STATUS,RP0
CODE:CODE:10b3  0317            BSF         STATUS,RP1
CODE:CODE:10b4  101f            BTFSS       0x10,#0x6
CODE:CODE:10b5  ba28            GOTO        offset LAB_CODE_10ba &0xff
CODE:CODE:10b6  2030            MOVLW       #0x20
CODE:CODE:10b7  8312            BCF         STATUS,RP0
CODE:CODE:10b8  aa00            MOVWF       0x2a
CODE:CODE:10b9  ab00            MOVWF       0x2b
                            LAB_CODE_10ba:                ;XREF[2,0]:   CODE:10b1,CODE:10b5
CODE:CODE:10ba  8312            BCF         STATUS,RP0
CODE:CODE:10bb  0313            BCF         STATUS,RP1
CODE:CODE:10bc  4e0b            DECFSZ      0x4e,w
CODE:CODE:10bd  c328            GOTO        offset LAB_CODE_10c3 &0xff
CODE:CODE:10be  2d1f            BTFSS       0x2d,#0x6
CODE:CODE:10bf  c328            GOTO        offset LAB_CODE_10c3 &0xff
CODE:CODE:10c0  2030            MOVLW       #0x20
CODE:CODE:10c1  0317            BSF         STATUS,RP1
CODE:CODE:10c2  a900            MOVWF       0x29
                            LAB_CODE_10c3:                ;XREF[2,0]:   CODE:10bd,CODE:10bf
CODE:CODE:10c3  0317            BSF         STATUS,RP1
CODE:CODE:10c4  2708            MOVF        0x27,w
CODE:CODE:10c5  303a            XORLW       #0x30
CODE:CODE:10c6  031d            BTFSS       STATUS,#0x2
CODE:CODE:10c7  ca28            GOTO        offset LAB_CODE_10ca &0xff
CODE:CODE:10c8  2030            MOVLW       #0x20
CODE:CODE:10c9  a700            MOVWF       0x27
                            LAB_CODE_10ca:                ;XREF[1,0]:   CODE:10c7
CODE:CODE:10ca  0313            BCF         STATUS,RP1
CODE:CODE:10cb  3618            BTFSC       0x36,#0x0
CODE:CODE:10cc  d628            GOTO        offset LAB_CODE_10d6 &0xff
CODE:CODE:10cd  b61c            BTFSS       0x36,#0x1
CODE:CODE:10ce  d328            GOTO        offset LAB_CODE_10d3 &0xff
CODE:CODE:10cf  1030            MOVLW       #0x10
CODE:CODE:10d0  0317            BSF         STATUS,RP1
CODE:CODE:10d1  ad00            MOVWF       0x2d
CODE:CODE:10d2  d628            GOTO        offset LAB_CODE_10d6 &0xff
                            LAB_CODE_10d3:                ;XREF[1,0]:   CODE:10ce
CODE:CODE:10d3  1030            MOVLW       #0x10
CODE:CODE:10d4  0317            BSF         STATUS,RP1
CODE:CODE:10d5  b000            MOVWF       0x30
                            LAB_CODE_10d6:                ;XREF[2,0]:   CODE:10cc,CODE:10d2
CODE:CODE:10d6  0313            BCF         STATUS,RP1
CODE:CODE:10d7  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined MAINLOOP_SUB3()
                                                          ;XREF[1,0]:   CODE:1033
CODE:CODE:10d8  0030            MOVLW       #0x0
CODE:CODE:10d9  8301            CLRF        STATUS
CODE:CODE:10da  0718            BTFSC       FSR1H,#0x0
CODE:CODE:10db  0130            MOVLW       #0x1
CODE:CODE:10dc  ca00            MOVWF       0x4a
CODE:CODE:10dd  ca0d            RLF         0x4a,f
CODE:CODE:10de  ca0d            RLF         0x4a,f
CODE:CODE:10df  3d08            MOVF        0x3d,w
CODE:CODE:10e0  4a06            XORWF       0x4a,w
CODE:CODE:10e1  fb39            ANDLW       #0xfb
CODE:CODE:10e2  4a06            XORWF       0x4a,w
CODE:CODE:10e3  bd00            MOVWF       0x3d
CODE:CODE:10e4  0030            MOVLW       #0x0
CODE:CODE:10e5  8718            BTFSC       FSR1H,#0x1
CODE:CODE:10e6  0130            MOVLW       #0x1
CODE:CODE:10e7  ca00            MOVWF       0x4a
CODE:CODE:10e8  ca0d            RLF         0x4a,f
CODE:CODE:10e9  ca0d            RLF         0x4a,f
CODE:CODE:10ea  ca0d            RLF         0x4a,f
CODE:CODE:10eb  3d08            MOVF        0x3d,w
CODE:CODE:10ec  4a06            XORWF       0x4a,w
CODE:CODE:10ed  f739            ANDLW       #0xf7
CODE:CODE:10ee  4a06            XORWF       0x4a,w
CODE:CODE:10ef  bd00            MOVWF       0x3d
CODE:CODE:10f0  3d1d            BTFSS       0x3d,#0x2
CODE:CODE:10f1  bd19            BTFSC       0x3d,#0x3
CODE:CODE:10f2  f428            GOTO        offset LAB_CODE_10f4 &0xff
CODE:CODE:10f3  0d29            GOTO        offset LAB_CODE_110d-0x1000
                            LAB_CODE_10f4:                ;XREF[1,0]:   CODE:10f2
CODE:CODE:10f4  3d19            BTFSC       BANK-0:DAT_DATA_003d,#0x2               ;= ??
CODE:CODE:10f5  bd19            BTFSC       0x3d,#0x3
CODE:CODE:10f6  fd28            GOTO        offset LAB_CODE_10fd &0xff
CODE:CODE:10f7  bd1c            BTFSS       0x3d,#0x1
CODE:CODE:10f8  3d16            BSF         0x3d,#0x4
CODE:CODE:10f9  bd16            BSF         0x3d,#0x5
CODE:CODE:10fa  3d13            BCF         0x3d,#0x6
CODE:CODE:10fb  0130            MOVLW       #0x1
CODE:CODE:10fc  0a29            GOTO        offset LAB_CODE_110a-0x1000
                            LAB_CODE_10fd:                ;XREF[1,0]:   CODE:10f6
CODE:CODE:10fd  3d1d            BTFSS       BANK-0:DAT_DATA_003d,#0x2               ;= ??
CODE:CODE:10fe  bd1d            BTFSS       0x3d,#0x3
CODE:CODE:10ff  0629            GOTO        offset LAB_CODE_1106-0x1000
CODE:CODE:1100  3d1e            BTFSS       0x3d,#0x4
CODE:CODE:1101  bd14            BSF         0x3d,#0x1
CODE:CODE:1102  bd12            BCF         0x3d,#0x5
CODE:CODE:1103  3d17            BSF         0x3d,#0x6
CODE:CODE:1104  0230            MOVLW       #0x2
CODE:CODE:1105  0a29            GOTO        offset LAB_CODE_110a-0x1000
                            LAB_CODE_1106:                ;XREF[1,0]:   CODE:10ff
CODE:CODE:1106  3d19            BTFSC       BANK-0:DAT_DATA_003d,#0x2               ;= ??
CODE:CODE:1107  bd1d            BTFSS       0x3d,#0x3
CODE:CODE:1108  0d29            GOTO        offset LAB_CODE_110d-0x1000
CODE:CODE:1109  0330            MOVLW       #0x3
                            LAB_CODE_110a:                ;XREF[2,0]:   CODE:10fc,CODE:1105
CODE:CODE:110a  0317            BSF         STATUS,RP1
CODE:CODE:110b  a500            MOVWF       0x25
CODE:CODE:110c  1129            GOTO        offset LAB_CODE_1111-0x1000
                            LAB_CODE_110d:                ;XREF[2,0]:   CODE:10f3,CODE:1108
CODE:CODE:110d  bd12            BCF         BANK-0:DAT_DATA_003d,#0x5               ;= ??
CODE:CODE:110e  3d13            BCF         0x3d,#0x6
CODE:CODE:110f  0317            BSF         STATUS,RP1
CODE:CODE:1110  a501            CLRF        0x25
                            LAB_CODE_1111:                ;XREF[1,0]:   CODE:110c
CODE:CODE:1111  0313            BCF         STATUS,RP1
CODE:CODE:1112  3d1e            BTFSS       0x3d,#0x4
CODE:CODE:1113  3f29            GOTO        offset LAB_CODE_113f-0x1000
CODE:CODE:1114  0317            BSF         STATUS,RP1
CODE:CODE:1115  2408            MOVF        0x24,w
CODE:CODE:1116  031d            BTFSS       STATUS,#0x2
CODE:CODE:1117  1b29            GOTO        offset LAB_CODE_111b-0x1000
CODE:CODE:1118  250b            DECFSZ      0x25,w
CODE:CODE:1119  1b29            GOTO        offset LAB_CODE_111b-0x1000
CODE:CODE:111a  5529            GOTO        offset LAB_CODE_1155-0x1000
                            LAB_CODE_111b:                ;XREF[2,0]:   CODE:1117,CODE:1119
CODE:CODE:111b  240b            DECFSZ      BANK-0:DAT_DATA_0024,w                  ;= ??
CODE:CODE:111c  2129            GOTO        offset LAB_CODE_1121-0x1000
CODE:CODE:111d  2508            MOVF        0x25,w
CODE:CODE:111e  033a            XORLW       #0x3
CODE:CODE:111f  0319            BTFSC       STATUS,#0x2
CODE:CODE:1120  5529            GOTO        offset LAB_CODE_1155-0x1000
                            LAB_CODE_1121:                ;XREF[1,0]:   CODE:111c
CODE:CODE:1121  2408            MOVF        0x24,w
CODE:CODE:1122  023a            XORLW       #0x2
CODE:CODE:1123  031d            BTFSS       STATUS,#0x2
CODE:CODE:1124  2929            GOTO        offset LAB_CODE_1129-0x1000
CODE:CODE:1125  2508            MOVF        0x25,w
CODE:CODE:1126  023a            XORLW       #0x2
CODE:CODE:1127  0319            BTFSC       STATUS,#0x2
CODE:CODE:1128  5529            GOTO        offset LAB_CODE_1155-0x1000
                            LAB_CODE_1129:                ;XREF[1,0]:   CODE:1124
CODE:CODE:1129  2408            MOVF        0x24,w
CODE:CODE:112a  033a            XORLW       #0x3
CODE:CODE:112b  031d            BTFSS       STATUS,#0x2
CODE:CODE:112c  6d29            GOTO        offset LAB_CODE_116d-0x1000
CODE:CODE:112d  2508            MOVF        0x25,w
CODE:CODE:112e  0313            BCF         STATUS,RP1
CODE:CODE:112f  031d            BTFSS       STATUS,#0x2
CODE:CODE:1130  0800            RETURN
CODE:CODE:1131  ac16            BSF         0x2c,#0x5
CODE:CODE:1132  2c13            BCF         0x2c,#0x6
CODE:CODE:1133  0317            BSF         STATUS,RP1
CODE:CODE:1134  a401            CLRF        0x24
CODE:CODE:1135  0313            BCF         STATUS,RP1
CODE:CODE:1136  3d12            BCF         0x3d,#0x4
CODE:CODE:1137  0317            BSF         STATUS,RP1
CODE:CODE:1138  200a            INCF        0x20,w
CODE:CODE:1139  0319            BTFSC       STATUS,#0x2
CODE:CODE:113a  3d29            GOTO        offset LAB_CODE_113d-0x1000
CODE:CODE:113b  a00a            INCF        0x20,f
CODE:CODE:113c  6d29            GOTO        offset LAB_CODE_116d-0x1000
                            LAB_CODE_113d:                ;XREF[1,0]:   CODE:113a
CODE:CODE:113d  a001            CLRF        BANK-0:DAT_DATA_0020                    ;= ??
CODE:CODE:113e  6d29            GOTO        offset LAB_CODE_116d-0x1000
                            LAB_CODE_113f:                ;XREF[1,0]:   CODE:1113
CODE:CODE:113f  bd1c            BTFSS       BANK-0:DAT_DATA_003d,#0x1               ;= ??
CODE:CODE:1140  6d29            GOTO        offset LAB_CODE_116d-0x1000
CODE:CODE:1141  0317            BSF         STATUS,RP1
CODE:CODE:1142  2408            MOVF        0x24,w
CODE:CODE:1143  031d            BTFSS       STATUS,#0x2
CODE:CODE:1144  4929            GOTO        offset LAB_CODE_1149-0x1000
CODE:CODE:1145  2508            MOVF        0x25,w
CODE:CODE:1146  023a            XORLW       #0x2
CODE:CODE:1147  0319            BTFSC       STATUS,#0x2
CODE:CODE:1148  5529            GOTO        offset LAB_CODE_1155-0x1000
                            LAB_CODE_1149:                ;XREF[1,0]:   CODE:1144
CODE:CODE:1149  240b            DECFSZ      0x24,w
CODE:CODE:114a  4f29            GOTO        offset LAB_CODE_114f-0x1000
CODE:CODE:114b  2508            MOVF        0x25,w
CODE:CODE:114c  033a            XORLW       #0x3
CODE:CODE:114d  0319            BTFSC       STATUS,#0x2
CODE:CODE:114e  5529            GOTO        offset LAB_CODE_1155-0x1000
                            LAB_CODE_114f:                ;XREF[1,0]:   CODE:114a
CODE:CODE:114f  2408            MOVF        0x24,w
CODE:CODE:1150  023a            XORLW       #0x2
CODE:CODE:1151  031d            BTFSS       STATUS,#0x2
CODE:CODE:1152  5729            GOTO        offset LAB_CODE_1157-0x1000
CODE:CODE:1153  250b            DECFSZ      0x25,w
CODE:CODE:1154  5729            GOTO        offset LAB_CODE_1157-0x1000
                            LAB_CODE_1155:                ;XREF[5,0]:   CODE:111a,CODE:1120,CODE:1128,CODE:1148
                                                          ;             CODE:114e
CODE:CODE:1155  a40a            INCF        0x24,f
CODE:CODE:1156  6d29            GOTO        offset LAB_CODE_116d-0x1000
                            LAB_CODE_1157:                ;XREF[2,0]:   CODE:1152,CODE:1154
CODE:CODE:1157  2408            MOVF        BANK-0:DAT_DATA_0024,w                  ;= ??
CODE:CODE:1158  033a            XORLW       #0x3
CODE:CODE:1159  031d            BTFSS       STATUS,#0x2
CODE:CODE:115a  6d29            GOTO        offset LAB_CODE_116d-0x1000
CODE:CODE:115b  2508            MOVF        0x25,w
CODE:CODE:115c  0313            BCF         STATUS,RP1
CODE:CODE:115d  031d            BTFSS       STATUS,#0x2
CODE:CODE:115e  0800            RETURN
CODE:CODE:115f  ac12            BCF         0x2c,#0x5
CODE:CODE:1160  2c17            BSF         0x2c,#0x6
CODE:CODE:1161  0317            BSF         STATUS,RP1
CODE:CODE:1162  a401            CLRF        0x24
CODE:CODE:1163  0313            BCF         STATUS,RP1
CODE:CODE:1164  bd10            BCF         0x3d,#0x1
CODE:CODE:1165  0317            BSF         STATUS,RP1
CODE:CODE:1166  2008            MOVF        0x20,w
CODE:CODE:1167  0319            BTFSC       STATUS,#0x2
CODE:CODE:1168  6b29            GOTO        offset LAB_CODE_116b-0x1000
CODE:CODE:1169  a003            DECF        0x20,f
CODE:CODE:116a  6d29            GOTO        offset LAB_CODE_116d-0x1000
                            LAB_CODE_116b:                ;XREF[1,0]:   CODE:1168
CODE:CODE:116b  ff30            MOVLW       #0xff
CODE:CODE:116c  a000            MOVWF       0x20
                            LAB_CODE_116d:                ;XREF[7,0]:   CODE:112c,CODE:113c,CODE:113e,CODE:1140
                                                          ;             CODE:1156,CODE:115a,CODE:116a
CODE:CODE:116d  0313            BCF         STATUS,RP1
CODE:CODE:116e  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Eliana()
                                                          ;XREF[1,0]:   CODE:03bc
CODE:CODE:116f  8301            CLRF        STATUS
CODE:CODE:1170  ce01            CLRF        0x4e
                            LAB_CODE_1171:                ;XREF[1,0]:   CODE:117b
CODE:CODE:1171  4e08            MOVF        0x4e,w
CODE:CODE:1172  273e            ADDLW       #0x27
CODE:CODE:1173  8400            MOVWF       FSR0L
CODE:CODE:1174  8317            BSF         STATUS,IRP
CODE:CODE:1175  2030            MOVLW       #0x20
CODE:CODE:1176  8000            MOVWF       INDF0
CODE:CODE:1177  ce0a            INCF        0x4e,f
CODE:CODE:1178  0a30            MOVLW       #0xa
CODE:CODE:1179  4e02            SUBWF       0x4e,w
CODE:CODE:117a  031c            BTFSS       STATUS,#0x0
CODE:CODE:117b  7129            GOTO        offset LAB_CODE_1171-0x1000
CODE:CODE:117c  1030            MOVLW       #0x10
CODE:CODE:117d  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:117e  2730            MOVLW       #0x27
CODE:CODE:117f  fc00            MOVWF       BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:1180  8316            BSF         STATUS,RP0
CODE:CODE:1181  5608            MOVF        0x56,w
CODE:CODE:1182  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:1183  5508            MOVF        0x55,w
CODE:CODE:1184  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1185  0a12            BCF         PCLATH,#0x4
CODE:CODE:1186  8a11            BCF         PCLATH,#0x3
CODE:CODE:1187  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:1188  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:1189  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:118a  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:118b  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:118c  0a30            MOVLW       #0xa
CODE:CODE:118d  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:118e  0030            MOVLW       #0x0
CODE:CODE:118f  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:1190  0a12            BCF         PCLATH,#0x4
CODE:CODE:1191  8a11            BCF         PCLATH,#0x3
CODE:CODE:1192  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:1193  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:1194  3038            IORLW       #0x30
CODE:CODE:1195  8312            BCF         STATUS,RP0
CODE:CODE:1196  0317            BSF         STATUS,RP1
CODE:CODE:1197  a700            MOVWF       0x27
CODE:CODE:1198  e830            MOVLW       #0xe8
CODE:CODE:1199  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:119a  0330            MOVLW       #0x3
CODE:CODE:119b  fc00            MOVWF       BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:119c  8316            BSF         STATUS,RP0
CODE:CODE:119d  0313            BCF         STATUS,RP1
CODE:CODE:119e  5608            MOVF        0x56,w
CODE:CODE:119f  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11a0  5508            MOVF        0x55,w
CODE:CODE:11a1  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11a2  0a12            BCF         PCLATH,#0x4
CODE:CODE:11a3  8a11            BCF         PCLATH,#0x3
CODE:CODE:11a4  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11a5  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:11a6  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11a7  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:11a8  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11a9  0a30            MOVLW       #0xa
CODE:CODE:11aa  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11ab  0030            MOVLW       #0x0
CODE:CODE:11ac  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11ad  0a12            BCF         PCLATH,#0x4
CODE:CODE:11ae  8a11            BCF         PCLATH,#0x3
CODE:CODE:11af  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11b0  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:11b1  3038            IORLW       #0x30
CODE:CODE:11b2  8312            BCF         STATUS,RP0
CODE:CODE:11b3  0317            BSF         STATUS,RP1
CODE:CODE:11b4  a800            MOVWF       0x28
CODE:CODE:11b5  6430            MOVLW       #0x64
CODE:CODE:11b6  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11b7  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11b8  8316            BSF         STATUS,RP0
CODE:CODE:11b9  0313            BCF         STATUS,RP1
CODE:CODE:11ba  5608            MOVF        0x56,w
CODE:CODE:11bb  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11bc  5508            MOVF        0x55,w
CODE:CODE:11bd  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11be  0a12            BCF         PCLATH,#0x4
CODE:CODE:11bf  8a11            BCF         PCLATH,#0x3
CODE:CODE:11c0  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11c1  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:11c2  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11c3  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:11c4  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11c5  0a30            MOVLW       #0xa
CODE:CODE:11c6  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11c7  0030            MOVLW       #0x0
CODE:CODE:11c8  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11c9  0a12            BCF         PCLATH,#0x4
CODE:CODE:11ca  8a11            BCF         PCLATH,#0x3
CODE:CODE:11cb  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11cc  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:11cd  3038            IORLW       #0x30
CODE:CODE:11ce  8312            BCF         STATUS,RP0
CODE:CODE:11cf  0317            BSF         STATUS,RP1
CODE:CODE:11d0  a900            MOVWF       0x29
CODE:CODE:11d1  0a30            MOVLW       #0xa
CODE:CODE:11d2  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11d3  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11d4  8316            BSF         STATUS,RP0
CODE:CODE:11d5  0313            BCF         STATUS,RP1
CODE:CODE:11d6  5608            MOVF        0x56,w
CODE:CODE:11d7  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11d8  5508            MOVF        0x55,w
CODE:CODE:11d9  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11da  0a12            BCF         PCLATH,#0x4
CODE:CODE:11db  8a11            BCF         PCLATH,#0x3
CODE:CODE:11dc  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11dd  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:11de  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11df  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:11e0  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11e1  0a30            MOVLW       #0xa
CODE:CODE:11e2  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11e3  0030            MOVLW       #0x0
CODE:CODE:11e4  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11e5  0a12            BCF         PCLATH,#0x4
CODE:CODE:11e6  8a11            BCF         PCLATH,#0x3
CODE:CODE:11e7  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11e8  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:11e9  3038            IORLW       #0x30
CODE:CODE:11ea  8312            BCF         STATUS,RP0
CODE:CODE:11eb  0317            BSF         STATUS,RP1
CODE:CODE:11ec  aa00            MOVWF       0x2a
CODE:CODE:11ed  0a30            MOVLW       #0xa
CODE:CODE:11ee  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:11ef  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:11f0  8316            BSF         STATUS,RP0
CODE:CODE:11f1  0313            BCF         STATUS,RP1
CODE:CODE:11f2  5608            MOVF        0x56,w
CODE:CODE:11f3  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:11f4  5508            MOVF        0x55,w
CODE:CODE:11f5  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:11f6  0a12            BCF         PCLATH,#0x4
CODE:CODE:11f7  8a11            BCF         PCLATH,#0x3
CODE:CODE:11f8  c320            CALL        Elise                                   ;undefined Elise()
CODE:CODE:11f9  0a16            BSF         PCLATH,#0x4
CODE:CODE:11fa  8a11            BCF         PCLATH,#0x3
CODE:CODE:11fb  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:11fc  3038            IORLW       #0x30
CODE:CODE:11fd  8312            BCF         STATUS,RP0
CODE:CODE:11fe  0317            BSF         STATUS,RP1
CODE:CODE:11ff  ab00            MOVWF       0x2b
CODE:CODE:1200  2708            MOVF        0x27,w
CODE:CODE:1201  303a            XORLW       #0x30
CODE:CODE:1202  031d            BTFSS       STATUS,#0x2
CODE:CODE:1203  182a            GOTO        offset LAB_CODE_1218-0x1000
CODE:CODE:1204  2030            MOVLW       #0x20
CODE:CODE:1205  a700            MOVWF       0x27
CODE:CODE:1206  2808            MOVF        0x28,w
CODE:CODE:1207  303a            XORLW       #0x30
CODE:CODE:1208  031d            BTFSS       STATUS,#0x2
CODE:CODE:1209  182a            GOTO        offset LAB_CODE_1218-0x1000
CODE:CODE:120a  2030            MOVLW       #0x20
CODE:CODE:120b  a800            MOVWF       0x28
CODE:CODE:120c  2908            MOVF        0x29,w
CODE:CODE:120d  303a            XORLW       #0x30
CODE:CODE:120e  031d            BTFSS       STATUS,#0x2
CODE:CODE:120f  182a            GOTO        offset LAB_CODE_1218-0x1000
CODE:CODE:1210  2030            MOVLW       #0x20
CODE:CODE:1211  a900            MOVWF       0x29
CODE:CODE:1212  2a08            MOVF        0x2a,w
CODE:CODE:1213  303a            XORLW       #0x30
CODE:CODE:1214  031d            BTFSS       STATUS,#0x2
CODE:CODE:1215  182a            GOTO        offset LAB_CODE_1218-0x1000
CODE:CODE:1216  2030            MOVLW       #0x20
CODE:CODE:1217  aa00            MOVWF       0x2a
                            LAB_CODE_1218:                ;XREF[4,0]:   CODE:1203,CODE:1209,CODE:120f,CODE:1215
CODE:CODE:1218  0313            BCF         STATUS,RP1
CODE:CODE:1219  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Clara()
                                                          ;XREF[1,0]:   CODE:0904
CODE:CODE:121a  8301            CLRF        STATUS
CODE:CODE:121b  d200            MOVWF       0x52
CODE:CODE:121c  6430            MOVLW       #0x64
CODE:CODE:121d  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:121e  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:121f  8316            BSF         STATUS,RP0
CODE:CODE:1220  2908            MOVF        0x29,w
CODE:CODE:1221  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1222  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:1223  0a16            BSF         PCLATH,#0x4
CODE:CODE:1224  8a15            BSF         PCLATH,#0x3
CODE:CODE:1225  ee21            CALL        offset Estelle-0x1800                   ;undefined Estelle()
CODE:CODE:1226  8312            BCF         STATUS,RP0
CODE:CODE:1227  5208            MOVF        0x52,w
CODE:CODE:1228  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1229  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:122a  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:122b  f907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:122c  0318            BTFSC       STATUS,#0x0
CODE:CODE:122d  fa0a            INCF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:122e  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:122f  fa07            ADDWF       BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1230  1430            MOVLW       #0x14
CODE:CODE:1231  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:1232  0030            MOVLW       #0x0
CODE:CODE:1233  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:1234  0a16            BSF         PCLATH,#0x4
CODE:CODE:1235  8a15            BSF         PCLATH,#0x3
CODE:CODE:1236  ee21            CALL        offset Estelle-0x1800                   ;undefined Estelle()
CODE:CODE:1237  1430            MOVLW       #0x14
CODE:CODE:1238  fd07            ADDWF       BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:1239  0318            BTFSC       STATUS,#0x0
CODE:CODE:123a  fe0a            INCF        BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:123b  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:123c  8316            BSF         STATUS,RP0
CODE:CODE:123d  d100            MOVWF       0x51
CODE:CODE:123e  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:123f  d200            MOVWF       0x52
CODE:CODE:1240  f030            MOVLW       #0xf0
CODE:CODE:1241  5105            ANDWF       0x51,w
CODE:CODE:1242  cf00            MOVWF       0x4f
CODE:CODE:1243  ff30            MOVLW       #0xff
CODE:CODE:1244  5205            ANDWF       0x52,w
CODE:CODE:1245  d000            MOVWF       0x50
CODE:CODE:1246  5108            MOVF        0x51,w
CODE:CODE:1247  0f39            ANDLW       #0xf
CODE:CODE:1248  a800            MOVWF       0x28
CODE:CODE:1249  8312            BCF         STATUS,RP0
CODE:CODE:124a  d401            CLRF        0x54
CODE:CODE:124b  8316            BSF         STATUS,RP0
CODE:CODE:124c  4f08            MOVF        0x4f,w
CODE:CODE:124d  8312            BCF         STATUS,RP0
CODE:CODE:124e  dc00            MOVWF       0x5c
CODE:CODE:124f  8316            BSF         STATUS,RP0
CODE:CODE:1250  5008            MOVF        0x50,w
CODE:CODE:1251  8312            BCF         STATUS,RP0
CODE:CODE:1252  dd00            MOVWF       0x5d
CODE:CODE:1253  a030            MOVLW       #0xa0
CODE:CODE:1254  de00            MOVWF       0x5e
CODE:CODE:1255  0a16            BSF         PCLATH,#0x4
CODE:CODE:1256  8a11            BCF         PCLATH,#0x3
CODE:CODE:1257  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:1258  0a16            BSF         PCLATH,#0x4
CODE:CODE:1259  8a11            BCF         PCLATH,#0x3
CODE:CODE:125a  d501            CLRF        0x55
CODE:CODE:125b  6e2a            GOTO        offset LAB_CODE_126e-0x1000
                            LAB_CODE_125c:                ;XREF[1,0]:   CODE:1285
CODE:CODE:125c  8316            BSF         STATUS,RP0
CODE:CODE:125d  0313            BCF         STATUS,RP1
CODE:CODE:125e  2808            MOVF        0x28,w
CODE:CODE:125f  8312            BCF         STATUS,RP0
CODE:CODE:1260  5507            ADDWF       0x55,w
CODE:CODE:1261  473e            ADDLW       #0x47
CODE:CODE:1262  8400            MOVWF       FSR0L
CODE:CODE:1263  8317            BSF         STATUS,IRP
CODE:CODE:1264  0008            MOVF        INDF0,w
CODE:CODE:1265  d600            MOVWF       0x56
CODE:CODE:1266  5408            MOVF        0x54,w
CODE:CODE:1267  af3e            ADDLW       #0xaf
CODE:CODE:1268  8400            MOVWF       FSR0L
CODE:CODE:1269  8317            BSF         STATUS,IRP
CODE:CODE:126a  5608            MOVF        0x56,w
CODE:CODE:126b  8000            MOVWF       INDF0
CODE:CODE:126c  d50a            INCF        0x55,f
CODE:CODE:126d  d40a            INCF        0x54,f
                            LAB_CODE_126e:                ;XREF[1,0]:   CODE:125b
CODE:CODE:126e  1030            MOVLW       #0x10
CODE:CODE:126f  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1270  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:1271  8316            BSF         STATUS,RP0
CODE:CODE:1272  2808            MOVF        0x28,w
CODE:CODE:1273  f902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:1274  031c            BTFSS       STATUS,#0x0
CODE:CODE:1275  fa03            DECF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1276  8312            BCF         STATUS,RP0
CODE:CODE:1277  5508            MOVF        0x55,w
CODE:CODE:1278  d600            MOVWF       0x56
CODE:CODE:1279  d701            CLRF        0x57
CODE:CODE:127a  5708            MOVF        0x57,w
CODE:CODE:127b  803a            XORLW       #0x80
CODE:CODE:127c  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:127d  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:127e  803a            XORLW       #0x80
CODE:CODE:127f  7b02            SUBWF       BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:1280  031d            BTFSS       STATUS,#0x2
CODE:CODE:1281  842a            GOTO        offset LAB_CODE_1284-0x1000
CODE:CODE:1282  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:1283  5602            SUBWF       0x56,w
                            LAB_CODE_1284:                ;XREF[1,0]:   CODE:1281
CODE:CODE:1284  031c            BTFSS       STATUS,#0x0
CODE:CODE:1285  5c2a            GOTO        offset LAB_CODE_125c-0x1000
CODE:CODE:1286  d301            CLRF        0x53
CODE:CODE:1287  d30a            INCF        0x53,f
                            LAB_CODE_1288:                ;XREF[1,0]:   CODE:12ca
CODE:CODE:1288  5308            MOVF        0x53,w
CODE:CODE:1289  d600            MOVWF       0x56
CODE:CODE:128a  d701            CLRF        0x57
CODE:CODE:128b  d60e            SWAPF       0x56,f
CODE:CODE:128c  d70e            SWAPF       0x57,f
CODE:CODE:128d  f030            MOVLW       #0xf0
CODE:CODE:128e  d705            ANDWF       0x57,f
CODE:CODE:128f  5608            MOVF        0x56,w
CODE:CODE:1290  0f39            ANDLW       #0xf
CODE:CODE:1291  d704            IORWF       0x57,f
CODE:CODE:1292  f030            MOVLW       #0xf0
CODE:CODE:1293  d605            ANDWF       0x56,f
CODE:CODE:1294  8316            BSF         STATUS,RP0
CODE:CODE:1295  4f08            MOVF        0x4f,w
CODE:CODE:1296  0313            BCF         STATUS,RP1
CODE:CODE:1297  8312            BCF         STATUS,RP0
CODE:CODE:1298  d607            ADDWF       0x56,f
CODE:CODE:1299  0318            BTFSC       STATUS,#0x0
CODE:CODE:129a  d70a            INCF        0x57,f
CODE:CODE:129b  8316            BSF         STATUS,RP0
CODE:CODE:129c  5008            MOVF        0x50,w
CODE:CODE:129d  8312            BCF         STATUS,RP0
CODE:CODE:129e  d707            ADDWF       0x57,f
CODE:CODE:129f  5608            MOVF        0x56,w
CODE:CODE:12a0  dc00            MOVWF       0x5c
CODE:CODE:12a1  5708            MOVF        0x57,w
CODE:CODE:12a2  dd00            MOVWF       0x5d
CODE:CODE:12a3  a030            MOVLW       #0xa0
CODE:CODE:12a4  de00            MOVWF       0x5e
CODE:CODE:12a5  0a16            BSF         PCLATH,#0x4
CODE:CODE:12a6  8a11            BCF         PCLATH,#0x3
CODE:CODE:12a7  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:12a8  0a16            BSF         PCLATH,#0x4
CODE:CODE:12a9  8a11            BCF         PCLATH,#0x3
CODE:CODE:12aa  d501            CLRF        0x55
                            LAB_CODE_12ab:                ;XREF[1,0]:   CODE:12c2
CODE:CODE:12ab  5508            MOVF        0x55,w
CODE:CODE:12ac  473e            ADDLW       #0x47
CODE:CODE:12ad  8400            MOVWF       FSR0L
CODE:CODE:12ae  8317            BSF         STATUS,IRP
CODE:CODE:12af  0008            MOVF        INDF0,w
CODE:CODE:12b0  d600            MOVWF       0x56
CODE:CODE:12b1  5408            MOVF        0x54,w
CODE:CODE:12b2  af3e            ADDLW       #0xaf
CODE:CODE:12b3  8400            MOVWF       FSR0L
CODE:CODE:12b4  8317            BSF         STATUS,IRP
CODE:CODE:12b5  5608            MOVF        0x56,w
CODE:CODE:12b6  8000            MOVWF       INDF0
CODE:CODE:12b7  5408            MOVF        0x54,w
CODE:CODE:12b8  8316            BSF         STATUS,RP0
CODE:CODE:12b9  4c06            XORWF       0x4c,w
CODE:CODE:12ba  8312            BCF         STATUS,RP0
CODE:CODE:12bb  0319            BTFSC       STATUS,#0x2
CODE:CODE:12bc  c32a            GOTO        offset LAB_CODE_12c3-0x1000
CODE:CODE:12bd  d50a            INCF        0x55,f
CODE:CODE:12be  d40a            INCF        0x54,f
CODE:CODE:12bf  1030            MOVLW       #0x10
CODE:CODE:12c0  5502            SUBWF       0x55,w
CODE:CODE:12c1  031c            BTFSS       STATUS,#0x0
CODE:CODE:12c2  ab2a            GOTO        offset LAB_CODE_12ab-0x1000
                            LAB_CODE_12c3:                ;XREF[1,0]:   CODE:12bc
CODE:CODE:12c3  d30a            INCF        0x53,f
CODE:CODE:12c4  8316            BSF         STATUS,RP0
CODE:CODE:12c5  4c08            MOVF        0x4c,w
CODE:CODE:12c6  8312            BCF         STATUS,RP0
CODE:CODE:12c7  5402            SUBWF       0x54,w
CODE:CODE:12c8  0318            BTFSC       STATUS,#0x0
CODE:CODE:12c9  0800            RETURN
CODE:CODE:12ca  882a            GOTO        offset LAB_CODE_1288-0x1000
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined MAINLOOP_SUB2()
                                                          ;XREF[1,0]:   CODE:102f
CODE:CODE:12cb  8b12            BCF         INTCON,TMR0IE
CODE:CODE:12cc  8316            BSF         STATUS,RP0
CODE:CODE:12cd  0313            BCF         STATUS,RP1
CODE:CODE:12ce  b908            MOVF        0x39,f
CODE:CODE:12cf  031d            BTFSS       STATUS,#0x2
CODE:CODE:12d0  ba2b            GOTO        offset LAB_CODE_13ba-0x1000
CODE:CODE:12d1  0a30            MOVLW       #0xa
CODE:CODE:12d2  b900            MOVWF       0x39
CODE:CODE:12d3  0430            MOVLW       #0x4
CODE:CODE:12d4  8312            BCF         STATUS,RP0
CODE:CODE:12d5  2902            SUBWF       0x29,w
CODE:CODE:12d6  0318            BTFSC       STATUS,#0x0
CODE:CODE:12d7  a901            CLRF        0x29
CODE:CODE:12d8  0514            BSF         FSR0H,#0x0
CODE:CODE:12d9  8514            BSF         FSR0H,#0x1
CODE:CODE:12da  0515            BSF         FSR0H,#0x2
CODE:CODE:12db  342b            GOTO        offset LAB_CODE_1334-0x1000
                            LAB_CODE_12dc:                ;XREF[1,0]:   CODE:1337
CODE:CODE:12dc  0510            BCF         FSR0H,#0x0
CODE:CODE:12dd  0030            MOVLW       #0x0
CODE:CODE:12de  061b            BTFSC       FSR1L,#0x6
CODE:CODE:12df  0130            MOVLW       #0x1
CODE:CODE:12e0  ca00            MOVWF       0x4a
CODE:CODE:12e1  3208            MOVF        0x32,w
CODE:CODE:12e2  4a06            XORWF       0x4a,w
CODE:CODE:12e3  fe39            ANDLW       #0xfe
CODE:CODE:12e4  4a06            XORWF       0x4a,w
CODE:CODE:12e5  b200            MOVWF       0x32
CODE:CODE:12e6  0030            MOVLW       #0x0
CODE:CODE:12e7  861b            BTFSC       FSR1L,#0x7
CODE:CODE:12e8  0130            MOVLW       #0x1
CODE:CODE:12e9  ca00            MOVWF       0x4a
CODE:CODE:12ea  ca0d            RLF         0x4a,f
CODE:CODE:12eb  3208            MOVF        0x32,w
CODE:CODE:12ec  4a06            XORWF       0x4a,w
CODE:CODE:12ed  fd39            ANDLW       #0xfd
CODE:CODE:12ee  302b            GOTO        offset LAB_CODE_1330-0x1000
                            LAB_CODE_12ef:                ;XREF[1,0]:   CODE:133a
CODE:CODE:12ef  8510            BCF         FSR0H,#0x1
CODE:CODE:12f0  0030            MOVLW       #0x0
CODE:CODE:12f1  061b            BTFSC       FSR1L,#0x6
CODE:CODE:12f2  0130            MOVLW       #0x1
CODE:CODE:12f3  ca00            MOVWF       0x4a
CODE:CODE:12f4  ca0d            RLF         0x4a,f
CODE:CODE:12f5  ca0d            RLF         0x4a,f
CODE:CODE:12f6  3208            MOVF        0x32,w
CODE:CODE:12f7  4a06            XORWF       0x4a,w
CODE:CODE:12f8  fb39            ANDLW       #0xfb
CODE:CODE:12f9  4a06            XORWF       0x4a,w
CODE:CODE:12fa  b200            MOVWF       0x32
CODE:CODE:12fb  0030            MOVLW       #0x0
CODE:CODE:12fc  861b            BTFSC       FSR1L,#0x7
CODE:CODE:12fd  0130            MOVLW       #0x1
CODE:CODE:12fe  ca00            MOVWF       0x4a
CODE:CODE:12ff  ca0d            RLF         0x4a,f
CODE:CODE:1300  ca0d            RLF         0x4a,f
CODE:CODE:1301  ca0d            RLF         0x4a,f
CODE:CODE:1302  3208            MOVF        0x32,w
CODE:CODE:1303  4a06            XORWF       0x4a,w
CODE:CODE:1304  f739            ANDLW       #0xf7
CODE:CODE:1305  302b            GOTO        offset LAB_CODE_1330-0x1000
                            LAB_CODE_1306:                ;XREF[1,0]:   CODE:133d
CODE:CODE:1306  0511            BCF         FSR0H,#0x2
CODE:CODE:1307  0030            MOVLW       #0x0
CODE:CODE:1308  061b            BTFSC       FSR1L,#0x6
CODE:CODE:1309  0130            MOVLW       #0x1
CODE:CODE:130a  ca00            MOVWF       0x4a
CODE:CODE:130b  ca0e            SWAPF       0x4a,f
CODE:CODE:130c  3208            MOVF        0x32,w
CODE:CODE:130d  4a06            XORWF       0x4a,w
CODE:CODE:130e  ef39            ANDLW       #0xef
CODE:CODE:130f  4a06            XORWF       0x4a,w
CODE:CODE:1310  b200            MOVWF       0x32
CODE:CODE:1311  0030            MOVLW       #0x0
CODE:CODE:1312  861b            BTFSC       FSR1L,#0x7
CODE:CODE:1313  0130            MOVLW       #0x1
CODE:CODE:1314  ca00            MOVWF       0x4a
CODE:CODE:1315  ca0e            SWAPF       0x4a,f
CODE:CODE:1316  ca0d            RLF         0x4a,f
CODE:CODE:1317  3208            MOVF        0x32,w
CODE:CODE:1318  4a06            XORWF       0x4a,w
CODE:CODE:1319  df39            ANDLW       #0xdf
CODE:CODE:131a  4a06            XORWF       0x4a,w
CODE:CODE:131b  b200            MOVWF       0x32
CODE:CODE:131c  0030            MOVLW       #0x0
CODE:CODE:131d  861a            BTFSC       FSR1L,#0x5
CODE:CODE:131e  0130            MOVLW       #0x1
CODE:CODE:131f  ca00            MOVWF       0x4a
CODE:CODE:1320  ca0e            SWAPF       0x4a,f
CODE:CODE:1321  ca0d            RLF         0x4a,f
CODE:CODE:1322  ca0d            RLF         0x4a,f
CODE:CODE:1323  3208            MOVF        0x32,w
CODE:CODE:1324  4a06            XORWF       0x4a,w
CODE:CODE:1325  bf39            ANDLW       #0xbf
CODE:CODE:1326  302b            GOTO        offset LAB_CODE_1330-0x1000
                            LAB_CODE_1327:                ;XREF[1,0]:   CODE:1340
CODE:CODE:1327  0030            MOVLW       #0x0
CODE:CODE:1328  0719            BTFSC       FSR1H,#0x2
CODE:CODE:1329  0130            MOVLW       #0x1
CODE:CODE:132a  ca00            MOVWF       0x4a
CODE:CODE:132b  ca0c            RRF         0x4a,f
CODE:CODE:132c  ca0c            RRF         0x4a,f
CODE:CODE:132d  3208            MOVF        0x32,w
CODE:CODE:132e  4a06            XORWF       0x4a,w
CODE:CODE:132f  7f39            ANDLW       #0x7f
                            LAB_CODE_1330:                ;XREF[3,0]:   CODE:12ee,CODE:1305,CODE:1326
CODE:CODE:1330  4a06            XORWF       0x4a,w
CODE:CODE:1331  b200            MOVWF       0x32
CODE:CODE:1332  a90a            INCF        0x29,f
CODE:CODE:1333  412b            GOTO        offset LAB_CODE_1341-0x1000
                            LAB_CODE_1334:                ;XREF[1,0]:   CODE:12db
CODE:CODE:1334  2908            MOVF        BANK-0:DAT_DATA_0029,w                  ;= ??
CODE:CODE:1335  003a            XORLW       #0x0
CODE:CODE:1336  0319            BTFSC       STATUS,#0x2
CODE:CODE:1337  dc2a            GOTO        offset LAB_CODE_12dc-0x1000
CODE:CODE:1338  013a            XORLW       #0x1
CODE:CODE:1339  0319            BTFSC       STATUS,#0x2
CODE:CODE:133a  ef2a            GOTO        offset LAB_CODE_12ef-0x1000
CODE:CODE:133b  033a            XORLW       #0x3
CODE:CODE:133c  0319            BTFSC       STATUS,#0x2
CODE:CODE:133d  062b            GOTO        offset LAB_CODE_1306-0x1000
CODE:CODE:133e  013a            XORLW       #0x1
CODE:CODE:133f  0319            BTFSC       STATUS,#0x2
CODE:CODE:1340  272b            GOTO        offset LAB_CODE_1327-0x1000
                            LAB_CODE_1341:                ;XREF[1,0]:   CODE:1333
CODE:CODE:1341  0430            MOVLW       #0x4
CODE:CODE:1342  2902            SUBWF       0x29,w
CODE:CODE:1343  031c            BTFSS       STATUS,#0x0
CODE:CODE:1344  ba2b            GOTO        offset LAB_CODE_13ba-0x1000
CODE:CODE:1345  3208            MOVF        0x32,w
CODE:CODE:1346  3305            ANDWF       0x33,w
CODE:CODE:1347  be00            MOVWF       0x3e
CODE:CODE:1348  3208            MOVF        0x32,w
CODE:CODE:1349  b300            MOVWF       0x33
CODE:CODE:134a  8b16            BSF         INTCON,TMR0IE
CODE:CODE:134b  8316            BSF         STATUS,RP0
CODE:CODE:134c  ad01            CLRF        0x2d
CODE:CODE:134d  8312            BCF         STATUS,RP0
CODE:CODE:134e  3e1c            BTFSS       0x3e,#0x0
CODE:CODE:134f  522b            GOTO        offset LAB_CODE_1352-0x1000
CODE:CODE:1350  8316            BSF         STATUS,RP0
CODE:CODE:1351  ad0a            INCF        0x2d,f
                            LAB_CODE_1352:                ;XREF[1,0]:   CODE:134f
CODE:CODE:1352  8312            BCF         STATUS,RP0
CODE:CODE:1353  be1c            BTFSS       0x3e,#0x1
CODE:CODE:1354  572b            GOTO        offset LAB_CODE_1357-0x1000
CODE:CODE:1355  8316            BSF         STATUS,RP0
CODE:CODE:1356  ad0a            INCF        0x2d,f
                            LAB_CODE_1357:                ;XREF[1,0]:   CODE:1354
CODE:CODE:1357  8312            BCF         STATUS,RP0
CODE:CODE:1358  3e1d            BTFSS       0x3e,#0x2
CODE:CODE:1359  5c2b            GOTO        offset LAB_CODE_135c-0x1000
CODE:CODE:135a  8316            BSF         STATUS,RP0
CODE:CODE:135b  ad0a            INCF        0x2d,f
                            LAB_CODE_135c:                ;XREF[1,0]:   CODE:1359
CODE:CODE:135c  8312            BCF         STATUS,RP0
CODE:CODE:135d  3e1f            BTFSS       0x3e,#0x6
CODE:CODE:135e  612b            GOTO        offset LAB_CODE_1361-0x1000
CODE:CODE:135f  8316            BSF         STATUS,RP0
CODE:CODE:1360  ad0a            INCF        0x2d,f
                            LAB_CODE_1361:                ;XREF[1,0]:   CODE:135e
CODE:CODE:1361  8312            BCF         STATUS,RP0
CODE:CODE:1362  be1d            BTFSS       0x3e,#0x3
CODE:CODE:1363  662b            GOTO        offset LAB_CODE_1366-0x1000
CODE:CODE:1364  8316            BSF         STATUS,RP0
CODE:CODE:1365  ad0a            INCF        0x2d,f
                            LAB_CODE_1366:                ;XREF[1,0]:   CODE:1363
CODE:CODE:1366  8312            BCF         STATUS,RP0
CODE:CODE:1367  3e1e            BTFSS       0x3e,#0x4
CODE:CODE:1368  6b2b            GOTO        offset LAB_CODE_136b-0x1000
CODE:CODE:1369  8316            BSF         STATUS,RP0
CODE:CODE:136a  ad0a            INCF        0x2d,f
                            LAB_CODE_136b:                ;XREF[1,0]:   CODE:1368
CODE:CODE:136b  8312            BCF         STATUS,RP0
CODE:CODE:136c  be1e            BTFSS       0x3e,#0x5
CODE:CODE:136d  702b            GOTO        offset LAB_CODE_1370-0x1000
CODE:CODE:136e  8316            BSF         STATUS,RP0
CODE:CODE:136f  ad0a            INCF        0x2d,f
                            LAB_CODE_1370:                ;XREF[1,0]:   CODE:136d
CODE:CODE:1370  8312            BCF         STATUS,RP0
CODE:CODE:1371  be1f            BTFSS       0x3e,#0x7
CODE:CODE:1372  752b            GOTO        offset LAB_CODE_1375-0x1000
CODE:CODE:1373  8316            BSF         STATUS,RP0
CODE:CODE:1374  ad0a            INCF        0x2d,f
                            LAB_CODE_1375:                ;XREF[1,0]:   CODE:1372
CODE:CODE:1375  8312            BCF         STATUS,RP0
CODE:CODE:1376  be1a            BTFSC       0x3e,#0x5
CODE:CODE:1377  7a2b            GOTO        offset LAB_CODE_137a-0x1000
CODE:CODE:1378  4a10            BCF         0x4a,#0x0
CODE:CODE:1379  7b2b            GOTO        offset LAB_CODE_137b-0x1000
                            LAB_CODE_137a:                ;XREF[1,0]:   CODE:1377
CODE:CODE:137a  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_137b:                ;XREF[1,0]:   CODE:1379
CODE:CODE:137b  2510            BCF         0x25,#0x0
CODE:CODE:137c  4a18            BTFSC       0x4a,#0x0
CODE:CODE:137d  2514            BSF         0x25,#0x0
CODE:CODE:137e  0313            BCF         STATUS,RP1
CODE:CODE:137f  3e1a            BTFSC       0x3e,#0x4
CODE:CODE:1380  832b            GOTO        offset LAB_CODE_1383-0x1000
CODE:CODE:1381  4a10            BCF         0x4a,#0x0
CODE:CODE:1382  842b            GOTO        offset LAB_CODE_1384-0x1000
                            LAB_CODE_1383:                ;XREF[1,0]:   CODE:1380
CODE:CODE:1383  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_1384:                ;XREF[1,0]:   CODE:1382
CODE:CODE:1384  a510            BCF         0x25,#0x1
CODE:CODE:1385  4a18            BTFSC       0x4a,#0x0
CODE:CODE:1386  a514            BSF         0x25,#0x1
CODE:CODE:1387  be19            BTFSC       0x3e,#0x3
CODE:CODE:1388  8b2b            GOTO        offset LAB_CODE_138b-0x1000
CODE:CODE:1389  4a10            BCF         0x4a,#0x0
CODE:CODE:138a  8c2b            GOTO        offset LAB_CODE_138c-0x1000
                            LAB_CODE_138b:                ;XREF[1,0]:   CODE:1388
CODE:CODE:138b  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_138c:                ;XREF[1,0]:   CODE:138a
CODE:CODE:138c  2511            BCF         0x25,#0x2
CODE:CODE:138d  4a18            BTFSC       0x4a,#0x0
CODE:CODE:138e  2515            BSF         0x25,#0x2
CODE:CODE:138f  be18            BTFSC       0x3e,#0x1
CODE:CODE:1390  932b            GOTO        offset LAB_CODE_1393-0x1000
CODE:CODE:1391  4a10            BCF         0x4a,#0x0
CODE:CODE:1392  942b            GOTO        offset LAB_CODE_1394-0x1000
                            LAB_CODE_1393:                ;XREF[1,0]:   CODE:1390
CODE:CODE:1393  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_1394:                ;XREF[1,0]:   CODE:1392
CODE:CODE:1394  a511            BCF         0x25,#0x3
CODE:CODE:1395  4a18            BTFSC       0x4a,#0x0
CODE:CODE:1396  a515            BSF         0x25,#0x3
CODE:CODE:1397  3e18            BTFSC       0x3e,#0x0
CODE:CODE:1398  9b2b            GOTO        offset LAB_CODE_139b-0x1000
CODE:CODE:1399  4a10            BCF         0x4a,#0x0
CODE:CODE:139a  9c2b            GOTO        offset LAB_CODE_139c-0x1000
                            LAB_CODE_139b:                ;XREF[1,0]:   CODE:1398
CODE:CODE:139b  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_139c:                ;XREF[1,0]:   CODE:139a
CODE:CODE:139c  2512            BCF         0x25,#0x4
CODE:CODE:139d  4a18            BTFSC       0x4a,#0x0
CODE:CODE:139e  2516            BSF         0x25,#0x4
CODE:CODE:139f  a512            BCF         0x25,#0x5
CODE:CODE:13a0  3e1b            BTFSC       0x3e,#0x6
CODE:CODE:13a1  a42b            GOTO        offset LAB_CODE_13a4-0x1000
CODE:CODE:13a2  4a10            BCF         0x4a,#0x0
CODE:CODE:13a3  a52b            GOTO        offset LAB_CODE_13a5-0x1000
                            LAB_CODE_13a4:                ;XREF[1,0]:   CODE:13a1
CODE:CODE:13a4  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_13a5:                ;XREF[1,0]:   CODE:13a3
CODE:CODE:13a5  2513            BCF         0x25,#0x6
CODE:CODE:13a6  4a18            BTFSC       0x4a,#0x0
CODE:CODE:13a7  2517            BSF         0x25,#0x6
CODE:CODE:13a8  3e19            BTFSC       0x3e,#0x2
CODE:CODE:13a9  ac2b            GOTO        offset LAB_CODE_13ac-0x1000
CODE:CODE:13aa  4a10            BCF         0x4a,#0x0
CODE:CODE:13ab  ad2b            GOTO        offset LAB_CODE_13ad-0x1000
                            LAB_CODE_13ac:                ;XREF[1,0]:   CODE:13a9
CODE:CODE:13ac  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_13ad:                ;XREF[1,0]:   CODE:13ab
CODE:CODE:13ad  a513            BCF         0x25,#0x7
CODE:CODE:13ae  4a18            BTFSC       0x4a,#0x0
CODE:CODE:13af  a517            BSF         0x25,#0x7
CODE:CODE:13b0  2610            BCF         0x26,#0x0
CODE:CODE:13b1  be1b            BTFSC       0x3e,#0x7
CODE:CODE:13b2  b52b            GOTO        offset LAB_CODE_13b5-0x1000
CODE:CODE:13b3  4a10            BCF         0x4a,#0x0
CODE:CODE:13b4  b62b            GOTO        offset LAB_CODE_13b6-0x1000
                            LAB_CODE_13b5:                ;XREF[1,0]:   CODE:13b2
CODE:CODE:13b5  4a14            BSF         BANK-0:DAT_DATA_004a,#0x0               ;= ??
                            LAB_CODE_13b6:                ;XREF[1,0]:   CODE:13b4
CODE:CODE:13b6  a610            BCF         0x26,#0x1
CODE:CODE:13b7  4a18            BTFSC       0x4a,#0x0
CODE:CODE:13b8  a614            BSF         0x26,#0x1
CODE:CODE:13b9  2611            BCF         0x26,#0x2
                            LAB_CODE_13ba:                ;XREF[2,0]:   CODE:12d0,CODE:1344
CODE:CODE:13ba  8b16            BSF         INTCON,TMR0IE
CODE:CODE:13bb  8312            BCF         STATUS,RP0
CODE:CODE:13bc  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Emilie()
                                                          ;XREF[2,0]:   CODE:089b,CODE:0915
CODE:CODE:13bd  8301            CLRF        STATUS
CODE:CODE:13be  d300            MOVWF       0x53
CODE:CODE:13bf  c830            MOVLW       #0xc8
CODE:CODE:13c0  5302            SUBWF       0x53,w
CODE:CODE:13c1  0318            BTFSC       STATUS,#0x0
CODE:CODE:13c2  922c            GOTO        offset LAB_CODE_1492-0x1000
CODE:CODE:13c3  ae1d            BTFSS       0x2e,#0x3
CODE:CODE:13c4  ec2b            GOTO        offset LAB_CODE_13ec-0x1000
CODE:CODE:13c5  520b            DECFSZ      0x52,w
CODE:CODE:13c6  ec2b            GOTO        offset LAB_CODE_13ec-0x1000
CODE:CODE:13c7  8316            BSF         STATUS,RP0
CODE:CODE:13c8  2708            MOVF        0x27,w
CODE:CODE:13c9  8312            BCF         STATUS,RP0
CODE:CODE:13ca  d400            MOVWF       0x54
CODE:CODE:13cb  d501            CLRF        0x55
                            LAB_CODE_13cc:                ;XREF[1,0]:   CODE:13e3
CODE:CODE:13cc  5408            MOVF        0x54,w
CODE:CODE:13cd  af3e            ADDLW       #0xaf
CODE:CODE:13ce  8400            MOVWF       FSR0L
CODE:CODE:13cf  8317            BSF         STATUS,IRP
CODE:CODE:13d0  0008            MOVF        INDF0,w
CODE:CODE:13d1  d800            MOVWF       0x58
CODE:CODE:13d2  5508            MOVF        0x55,w
CODE:CODE:13d3  9b3e            ADDLW       #0x9b
CODE:CODE:13d4  8400            MOVWF       FSR0L
CODE:CODE:13d5  8317            BSF         STATUS,IRP
CODE:CODE:13d6  5808            MOVF        0x58,w
CODE:CODE:13d7  8000            MOVWF       INDF0
CODE:CODE:13d8  d40a            INCF        0x54,f
CODE:CODE:13d9  8316            BSF         STATUS,RP0
CODE:CODE:13da  4c08            MOVF        0x4c,w
CODE:CODE:13db  8312            BCF         STATUS,RP0
CODE:CODE:13dc  5402            SUBWF       0x54,w
CODE:CODE:13dd  0318            BTFSC       STATUS,#0x0
CODE:CODE:13de  d401            CLRF        0x54
CODE:CODE:13df  d50a            INCF        0x55,f
CODE:CODE:13e0  1430            MOVLW       #0x14
CODE:CODE:13e1  5502            SUBWF       0x55,w
CODE:CODE:13e2  031c            BTFSS       STATUS,#0x0
CODE:CODE:13e3  cc2b            GOTO        offset LAB_CODE_13cc-0x1000
CODE:CODE:13e4  8316            BSF         STATUS,RP0
CODE:CODE:13e5  a70a            INCF        0x27,f
CODE:CODE:13e6  4c08            MOVF        0x4c,w
CODE:CODE:13e7  2702            SUBWF       0x27,w
CODE:CODE:13e8  031c            BTFSS       STATUS,#0x0
CODE:CODE:13e9  cb2c            GOTO        offset LAB_CODE_14cb-0x1000
CODE:CODE:13ea  a701            CLRF        0x27
CODE:CODE:13eb  cb2c            GOTO        offset LAB_CODE_14cb-0x1000
                            LAB_CODE_13ec:                ;XREF[2,0]:   CODE:13c4,CODE:13c6
CODE:CODE:13ec  6430            MOVLW       #0x64
CODE:CODE:13ed  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:13ee  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:13ef  8316            BSF         STATUS,RP0
CODE:CODE:13f0  2908            MOVF        0x29,w
CODE:CODE:13f1  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:13f2  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:13f3  0a16            BSF         PCLATH,#0x4
CODE:CODE:13f4  8a15            BSF         PCLATH,#0x3
CODE:CODE:13f5  ee21            CALL        offset Estelle-0x1800                   ;undefined Estelle()
CODE:CODE:13f6  8312            BCF         STATUS,RP0
CODE:CODE:13f7  5308            MOVF        0x53,w
CODE:CODE:13f8  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:13f9  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:13fa  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:13fb  f907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:13fc  0318            BTFSC       STATUS,#0x0
CODE:CODE:13fd  fa0a            INCF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:13fe  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:13ff  fa07            ADDWF       BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1400  1430            MOVLW       #0x14
CODE:CODE:1401  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:1402  0030            MOVLW       #0x0
CODE:CODE:1403  fc01            CLRF        BANK-0:DAT_DATA_007c                    ;= ??
CODE:CODE:1404  0a16            BSF         PCLATH,#0x4
CODE:CODE:1405  8a15            BSF         PCLATH,#0x3
CODE:CODE:1406  ee21            CALL        offset Estelle-0x1800                   ;undefined Estelle()
CODE:CODE:1407  1430            MOVLW       #0x14
CODE:CODE:1408  fd07            ADDWF       BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:1409  0318            BTFSC       STATUS,#0x0
CODE:CODE:140a  fe0a            INCF        BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:140b  7d08            MOVF        BANK-0:DAT_DATA_007d,w                  ;= ??
CODE:CODE:140c  8316            BSF         STATUS,RP0
CODE:CODE:140d  d100            MOVWF       0x51
CODE:CODE:140e  7e08            MOVF        BANK-0:DAT_DATA_007e,w                  ;= ??
CODE:CODE:140f  d200            MOVWF       0x52
CODE:CODE:1410  f030            MOVLW       #0xf0
CODE:CODE:1411  5105            ANDWF       0x51,w
CODE:CODE:1412  cf00            MOVWF       0x4f
CODE:CODE:1413  ff30            MOVLW       #0xff
CODE:CODE:1414  5205            ANDWF       0x52,w
CODE:CODE:1415  d000            MOVWF       0x50
CODE:CODE:1416  5108            MOVF        0x51,w
CODE:CODE:1417  0f39            ANDLW       #0xf
CODE:CODE:1418  a800            MOVWF       0x28
CODE:CODE:1419  4f08            MOVF        0x4f,w
CODE:CODE:141a  8312            BCF         STATUS,RP0
CODE:CODE:141b  dc00            MOVWF       0x5c
CODE:CODE:141c  8316            BSF         STATUS,RP0
CODE:CODE:141d  5008            MOVF        0x50,w
CODE:CODE:141e  8312            BCF         STATUS,RP0
CODE:CODE:141f  dd00            MOVWF       0x5d
CODE:CODE:1420  a030            MOVLW       #0xa0
CODE:CODE:1421  de00            MOVWF       0x5e
CODE:CODE:1422  0a16            BSF         PCLATH,#0x4
CODE:CODE:1423  8a11            BCF         PCLATH,#0x3
CODE:CODE:1424  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:1425  0a16            BSF         PCLATH,#0x4
CODE:CODE:1426  8a11            BCF         PCLATH,#0x3
CODE:CODE:1427  d501            CLRF        0x55
                            LAB_CODE_1428:                ;XREF[1,0]:   CODE:1451
CODE:CODE:1428  1030            MOVLW       #0x10
CODE:CODE:1429  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:142a  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:142b  8316            BSF         STATUS,RP0
CODE:CODE:142c  2808            MOVF        0x28,w
CODE:CODE:142d  f902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:142e  031c            BTFSS       STATUS,#0x0
CODE:CODE:142f  fa03            DECF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1430  8312            BCF         STATUS,RP0
CODE:CODE:1431  5508            MOVF        0x55,w
CODE:CODE:1432  d800            MOVWF       0x58
CODE:CODE:1433  d901            CLRF        0x59
CODE:CODE:1434  5908            MOVF        0x59,w
CODE:CODE:1435  803a            XORLW       #0x80
CODE:CODE:1436  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:1437  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:1438  803a            XORLW       #0x80
CODE:CODE:1439  7b02            SUBWF       BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:143a  031d            BTFSS       STATUS,#0x2
CODE:CODE:143b  3e2c            GOTO        offset LAB_CODE_143e-0x1000
CODE:CODE:143c  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:143d  5802            SUBWF       0x58,w
                            LAB_CODE_143e:                ;XREF[1,0]:   CODE:143b
CODE:CODE:143e  8316            BSF         STATUS,RP0
CODE:CODE:143f  0318            BTFSC       STATUS,#0x0
CODE:CODE:1440  522c            GOTO        offset LAB_CODE_1452-0x1000
CODE:CODE:1441  0313            BCF         STATUS,RP1
CODE:CODE:1442  2808            MOVF        0x28,w
CODE:CODE:1443  8312            BCF         STATUS,RP0
CODE:CODE:1444  5507            ADDWF       0x55,w
CODE:CODE:1445  473e            ADDLW       #0x47
CODE:CODE:1446  8400            MOVWF       FSR0L
CODE:CODE:1447  8317            BSF         STATUS,IRP
CODE:CODE:1448  0008            MOVF        INDF0,w
CODE:CODE:1449  d800            MOVWF       0x58
CODE:CODE:144a  5508            MOVF        0x55,w
CODE:CODE:144b  9b3e            ADDLW       #0x9b
CODE:CODE:144c  8400            MOVWF       FSR0L
CODE:CODE:144d  8317            BSF         STATUS,IRP
CODE:CODE:144e  5808            MOVF        0x58,w
CODE:CODE:144f  8000            MOVWF       INDF0
CODE:CODE:1450  d50a            INCF        0x55,f
CODE:CODE:1451  282c            GOTO        offset LAB_CODE_1428-0x1000
                            LAB_CODE_1452:                ;XREF[1,0]:   CODE:1440
CODE:CODE:1452  5008            MOVF        BANK-0:DAT_DATA_0050,w                  ;= ??
CODE:CODE:1453  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:1454  4f08            MOVF        0x4f,w
CODE:CODE:1455  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1456  1030            MOVLW       #0x10
CODE:CODE:1457  f907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:1458  0318            BTFSC       STATUS,#0x0
CODE:CODE:1459  fa0a            INCF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:145a  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:145b  8312            BCF         STATUS,RP0
CODE:CODE:145c  dc00            MOVWF       0x5c
CODE:CODE:145d  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:145e  dd00            MOVWF       0x5d
CODE:CODE:145f  a030            MOVLW       #0xa0
CODE:CODE:1460  de00            MOVWF       0x5e
CODE:CODE:1461  0a16            BSF         PCLATH,#0x4
CODE:CODE:1462  8a11            BCF         PCLATH,#0x3
CODE:CODE:1463  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:1464  0a16            BSF         PCLATH,#0x4
CODE:CODE:1465  8a11            BCF         PCLATH,#0x3
CODE:CODE:1466  d501            CLRF        0x55
                            LAB_CODE_1467:                ;XREF[1,0]:   CODE:1491
CODE:CODE:1467  8316            BSF         STATUS,RP0
CODE:CODE:1468  2808            MOVF        0x28,w
CODE:CODE:1469  8312            BCF         STATUS,RP0
CODE:CODE:146a  d800            MOVWF       0x58
CODE:CODE:146b  d901            CLRF        0x59
CODE:CODE:146c  0430            MOVLW       #0x4
CODE:CODE:146d  d807            ADDWF       0x58,f
CODE:CODE:146e  0318            BTFSC       STATUS,#0x0
CODE:CODE:146f  d90a            INCF        0x59,f
CODE:CODE:1470  5508            MOVF        0x55,w
CODE:CODE:1471  da00            MOVWF       0x5a
CODE:CODE:1472  db01            CLRF        0x5b
CODE:CODE:1473  5b08            MOVF        0x5b,w
CODE:CODE:1474  803a            XORLW       #0x80
CODE:CODE:1475  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1476  5908            MOVF        0x59,w
CODE:CODE:1477  803a            XORLW       #0x80
CODE:CODE:1478  7902            SUBWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:1479  031d            BTFSS       STATUS,#0x2
CODE:CODE:147a  7d2c            GOTO        offset LAB_CODE_147d-0x1000
CODE:CODE:147b  5808            MOVF        0x58,w
CODE:CODE:147c  5a02            SUBWF       0x5a,w
                            LAB_CODE_147d:                ;XREF[1,0]:   CODE:147a
CODE:CODE:147d  0313            BCF         STATUS,RP1
CODE:CODE:147e  0318            BTFSC       STATUS,#0x0
CODE:CODE:147f  cc2c            GOTO        offset LAB_CODE_14cc-0x1000
CODE:CODE:1480  5508            MOVF        0x55,w
CODE:CODE:1481  473e            ADDLW       #0x47
CODE:CODE:1482  8400            MOVWF       FSR0L
CODE:CODE:1483  8317            BSF         STATUS,IRP
CODE:CODE:1484  0008            MOVF        INDF0,w
CODE:CODE:1485  d800            MOVWF       0x58
CODE:CODE:1486  8316            BSF         STATUS,RP0
CODE:CODE:1487  2808            MOVF        0x28,w
CODE:CODE:1488  103c            SUBLW       #0x10
CODE:CODE:1489  8312            BCF         STATUS,RP0
CODE:CODE:148a  5507            ADDWF       0x55,w
CODE:CODE:148b  9b3e            ADDLW       #0x9b
CODE:CODE:148c  8400            MOVWF       FSR0L
CODE:CODE:148d  8317            BSF         STATUS,IRP
CODE:CODE:148e  5808            MOVF        0x58,w
CODE:CODE:148f  8000            MOVWF       INDF0
CODE:CODE:1490  d50a            INCF        0x55,f
CODE:CODE:1491  672c            GOTO        offset LAB_CODE_1467-0x1000
                            LAB_CODE_1492:                ;XREF[1,0]:   CODE:13c2
CODE:CODE:1492  5308            MOVF        BANK-0:INIT_ST1_UNK2,w                  ;= ??
CODE:CODE:1493  d800            MOVWF       0x58
CODE:CODE:1494  d901            CLRF        0x59
CODE:CODE:1495  0310            BCF         STATUS,C
CODE:CODE:1496  d80d            RLF         0x58,f
CODE:CODE:1497  d90d            RLF         0x59,f
CODE:CODE:1498  7030            MOVLW       #0x70
CODE:CODE:1499  d807            ADDWF       0x58,f
CODE:CODE:149a  0318            BTFSC       STATUS,#0x0
CODE:CODE:149b  d90a            INCF        0x59,f
CODE:CODE:149c  fe30            MOVLW       #0xfe
CODE:CODE:149d  d907            ADDWF       0x59,f
CODE:CODE:149e  5908            MOVF        0x59,w
CODE:CODE:149f  083e            ADDLW       #0x8
CODE:CODE:14a0  ef00            MOVWF       0x6f
CODE:CODE:14a1  5808            MOVF        0x58,w
CODE:CODE:14a2  013e            ADDLW       #0x1
CODE:CODE:14a3  0318            BTFSC       STATUS,#0x0
CODE:CODE:14a4  ef0a            INCF        0x6f,f
CODE:CODE:14a5  0a12            BCF         PCLATH,#0x4
CODE:CODE:14a6  8a11            BCF         PCLATH,#0x3
CODE:CODE:14a7  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:14a8  da00            MOVWF       0x5a
CODE:CODE:14a9  0a12            BCF         PCLATH,#0x4
CODE:CODE:14aa  8a11            BCF         PCLATH,#0x3
CODE:CODE:14ab  ac20            CALL        fetch_data                              ;byte fetch_data(void)
CODE:CODE:14ac  db00            MOVWF       0x5b
CODE:CODE:14ad  5a08            MOVF        0x5a,w
CODE:CODE:14ae  d600            MOVWF       0x56
CODE:CODE:14af  5b08            MOVF        0x5b,w
CODE:CODE:14b0  d700            MOVWF       0x57
CODE:CODE:14b1  d501            CLRF        0x55
                            LAB_CODE_14b2:                ;XREF[1,0]:   CODE:14ca
CODE:CODE:14b2  5508            MOVF        0x55,w
CODE:CODE:14b3  5607            ADDWF       0x56,w
CODE:CODE:14b4  ee00            MOVWF       0x6e
CODE:CODE:14b5  5708            MOVF        0x57,w
CODE:CODE:14b6  ef00            MOVWF       0x6f
CODE:CODE:14b7  6e08            MOVF        0x6e,w
CODE:CODE:14b8  0318            BTFSC       STATUS,#0x0
CODE:CODE:14b9  ef0a            INCF        0x6f,f
CODE:CODE:14ba  0a12            BCF         PCLATH,#0x4
CODE:CODE:14bb  8a11            BCF         PCLATH,#0x3
CODE:CODE:14bc  a920            CALL        fetch_data_withparam                    ;void fetch_data_withparam(byte addr_...
CODE:CODE:14bd  0a16            BSF         PCLATH,#0x4
CODE:CODE:14be  8a11            BCF         PCLATH,#0x3
CODE:CODE:14bf  d800            MOVWF       0x58
CODE:CODE:14c0  5508            MOVF        0x55,w
CODE:CODE:14c1  9b3e            ADDLW       #0x9b
CODE:CODE:14c2  8400            MOVWF       FSR0L
CODE:CODE:14c3  8317            BSF         STATUS,IRP
CODE:CODE:14c4  5808            MOVF        0x58,w
CODE:CODE:14c5  8000            MOVWF       INDF0
CODE:CODE:14c6  d50a            INCF        0x55,f
CODE:CODE:14c7  1430            MOVLW       #0x14
CODE:CODE:14c8  5502            SUBWF       0x55,w
CODE:CODE:14c9  031c            BTFSS       STATUS,#0x0
CODE:CODE:14ca  b22c            GOTO        offset LAB_CODE_14b2-0x1000
                            LAB_CODE_14cb:                ;XREF[2,0]:   CODE:13e9,CODE:13eb
CODE:CODE:14cb  0313            BCF         STATUS,RP1
                            LAB_CODE_14cc:                ;XREF[1,0]:   CODE:147f
CODE:CODE:14cc  8312            BCF         STATUS,RP0
CODE:CODE:14cd  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Evelise()
                                                          ;XREF[8,0]:   CODE:0571,CODE:0579,CODE:0581,CODE:14e8
                                                          ;             CODE:14f3,CODE:14fe,CODE:15b0,CODE:15b9
CODE:CODE:14ce  8301            CLRF        STATUS
CODE:CODE:14cf  d300            MOVWF       0x53
CODE:CODE:14d0  0a30            MOVLW       #0xa
CODE:CODE:14d1  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:14d2  5308            MOVF        0x53,w
CODE:CODE:14d3  f039            ANDLW       #0xf0
CODE:CODE:14d4  d400            MOVWF       0x54
CODE:CODE:14d5  d40e            SWAPF       0x54,f
CODE:CODE:14d6  0f30            MOVLW       #0xf
CODE:CODE:14d7  d405            ANDWF       0x54,f
CODE:CODE:14d8  5408            MOVF        0x54,w
CODE:CODE:14d9  0a16            BSF         PCLATH,#0x4
CODE:CODE:14da  8a15            BSF         PCLATH,#0x3
CODE:CODE:14db  2922            CALL        offset Eloane-0x1800                    ;undefined Eloane()
CODE:CODE:14dc  0a16            BSF         PCLATH,#0x4
CODE:CODE:14dd  8a11            BCF         PCLATH,#0x3
CODE:CODE:14de  d500            MOVWF       0x55
CODE:CODE:14df  5308            MOVF        0x53,w
CODE:CODE:14e0  0f39            ANDLW       #0xf
CODE:CODE:14e1  5507            ADDWF       0x55,w
CODE:CODE:14e2  d200            MOVWF       0x52
CODE:CODE:14e3  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Eloise()
                                                          ;XREF[2,0]:   CODE:151d,CODE:1584
CODE:CODE:14e4  8312            BCF         STATUS,RP0
CODE:CODE:14e5  0317            BSF         STATUS,RP1
CODE:CODE:14e6  4908            MOVF        0x49,w
CODE:CODE:14e7  3f39            ANDLW       #0x3f
CODE:CODE:14e8  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:14e9  0a16            BSF         PCLATH,#0x4
CODE:CODE:14ea  8a11            BCF         PCLATH,#0x3
CODE:CODE:14eb  cd00            MOVWF       0x4d
CODE:CODE:14ec  1830            MOVLW       #0x18
CODE:CODE:14ed  4d02            SUBWF       0x4d,w
CODE:CODE:14ee  0318            BTFSC       STATUS,#0x0
CODE:CODE:14ef  ff34            RETLW       #0xff
CODE:CODE:14f0  0317            BSF         STATUS,RP1
CODE:CODE:14f1  4808            MOVF        0x48,w
CODE:CODE:14f2  7f39            ANDLW       #0x7f
CODE:CODE:14f3  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:14f4  0a16            BSF         PCLATH,#0x4
CODE:CODE:14f5  8a11            BCF         PCLATH,#0x3
CODE:CODE:14f6  ce00            MOVWF       0x4e
CODE:CODE:14f7  3c30            MOVLW       #0x3c
CODE:CODE:14f8  4e02            SUBWF       0x4e,w
CODE:CODE:14f9  0318            BTFSC       STATUS,#0x0
CODE:CODE:14fa  ff34            RETLW       #0xff
CODE:CODE:14fb  0317            BSF         STATUS,RP1
CODE:CODE:14fc  4708            MOVF        0x47,w
CODE:CODE:14fd  7f39            ANDLW       #0x7f
CODE:CODE:14fe  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:14ff  0a16            BSF         PCLATH,#0x4
CODE:CODE:1500  8a11            BCF         PCLATH,#0x3
CODE:CODE:1501  cf00            MOVWF       0x4f
CODE:CODE:1502  3c30            MOVLW       #0x3c
CODE:CODE:1503  4f02            SUBWF       0x4f,w
CODE:CODE:1504  031c            BTFSS       STATUS,#0x0
CODE:CODE:1505  0034            RETLW       #0x0
CODE:CODE:1506  ff34            RETLW       #0xff
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined init_something_2()
                                                          ;XREF[1,0]:   CODE:101e
CODE:CODE:1507  8301            CLRF        STATUS
CODE:CODE:1508  ba01            CLRF        0x3a
CODE:CODE:1509  bb01            CLRF        0x3b
CODE:CODE:150a  ff30            MOVLW       #0xff
CODE:CODE:150b  8316            BSF         STATUS,RP0
CODE:CODE:150c  ba00            MOVWF       0x3a
CODE:CODE:150d  bb00            MOVWF       0x3b
CODE:CODE:150e  8312            BCF         STATUS,RP0
CODE:CODE:150f  c200            MOVWF       0x42
CODE:CODE:1510  c300            MOVWF       0x43
CODE:CODE:1511  c600            MOVWF       0x46
CODE:CODE:1512  2f15            BSF         0x2f,#0x2
CODE:CODE:1513  ae17            BSF         0x2e,#0x7
CODE:CODE:1514  dc01            CLRF        0x5c
CODE:CODE:1515  dd01            CLRF        0x5d
CODE:CODE:1516  d030            MOVLW       #0xd0
CODE:CODE:1517  de00            MOVWF       0x5e
CODE:CODE:1518  0a16            BSF         PCLATH,#0x4
CODE:CODE:1519  8a11            BCF         PCLATH,#0x3
CODE:CODE:151a  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:151b  0a16            BSF         PCLATH,#0x4
CODE:CODE:151c  8a11            BCF         PCLATH,#0x3
CODE:CODE:151d  e424            CALL        offset Eloise-0x1000                    ;undefined Eloise()
CODE:CODE:151e  0038            IORLW       #0x0
CODE:CODE:151f  0317            BSF         STATUS,RP1
CODE:CODE:1520  031d            BTFSS       STATUS,#0x2
CODE:CODE:1521  3c2d            GOTO        offset LAB_CODE_153c-0x1000
CODE:CODE:1522  4708            MOVF        0x47,w
CODE:CODE:1523  7f39            ANDLW       #0x7f
CODE:CODE:1524  8316            BSF         STATUS,RP0
CODE:CODE:1525  0313            BCF         STATUS,RP1
CODE:CODE:1526  ae00            MOVWF       0x2e
CODE:CODE:1527  8312            BCF         STATUS,RP0
CODE:CODE:1528  0317            BSF         STATUS,RP1
CODE:CODE:1529  4808            MOVF        0x48,w
CODE:CODE:152a  7f39            ANDLW       #0x7f
CODE:CODE:152b  8316            BSF         STATUS,RP0
CODE:CODE:152c  0313            BCF         STATUS,RP1
CODE:CODE:152d  ab00            MOVWF       0x2b
CODE:CODE:152e  8312            BCF         STATUS,RP0
CODE:CODE:152f  0317            BSF         STATUS,RP1
CODE:CODE:1530  4908            MOVF        0x49,w
CODE:CODE:1531  3f39            ANDLW       #0x3f
CODE:CODE:1532  8316            BSF         STATUS,RP0
CODE:CODE:1533  0313            BCF         STATUS,RP1
CODE:CODE:1534  a100            MOVWF       0x21
CODE:CODE:1535  8312            BCF         STATUS,RP0
CODE:CODE:1536  0317            BSF         STATUS,RP1
CODE:CODE:1537  ce1b            BTFSC       0x4e,#0x7
CODE:CODE:1538  3f2d            GOTO        offset LAB_CODE_153f-0x1000
CODE:CODE:1539  0313            BCF         STATUS,RP1
CODE:CODE:153a  2e17            BSF         0x2e,#0x6
CODE:CODE:153b  3f2d            GOTO        offset LAB_CODE_153f-0x1000
                            LAB_CODE_153c:                ;XREF[1,0]:   CODE:1521
CODE:CODE:153c  c701            CLRF        BANK-0:DAT_DATA_0047                    ;= ??
CODE:CODE:153d  c801            CLRF        0x48
CODE:CODE:153e  c901            CLRF        0x49
                            LAB_CODE_153f:                ;XREF[2,0]:   CODE:1538,CODE:153b
CODE:CODE:153f  0317            BSF         STATUS,RP1
CODE:CODE:1540  c717            BSF         0x47,#0x7
CODE:CODE:1541  0313            BCF         STATUS,RP1
CODE:CODE:1542  cf01            CLRF        0x4f
CODE:CODE:1543  d001            CLRF        0x50
CODE:CODE:1544  d030            MOVLW       #0xd0
CODE:CODE:1545  d100            MOVWF       0x51
CODE:CODE:1546  0a16            BSF         PCLATH,#0x4
CODE:CODE:1547  8a11            BCF         PCLATH,#0x3
CODE:CODE:1548  2e27            CALL        offset Cecile-0x1000                    ;undefined Cecile()
CODE:CODE:1549  0a16            BSF         PCLATH,#0x4
CODE:CODE:154a  8a11            BCF         PCLATH,#0x3
CODE:CODE:154b  4230            MOVLW       #0x42
CODE:CODE:154c  ca00            MOVWF       0x4a
                            LAB_CODE_154d:                ;XREF[1,0]:   CODE:154e
CODE:CODE:154d  ca0b            DECFSZ      0x4a,f
CODE:CODE:154e  4d2d            GOTO        offset LAB_CODE_154d-0x1000
CODE:CODE:154f  0317            BSF         STATUS,RP1
CODE:CODE:1550  c713            BCF         0x47,#0x7
CODE:CODE:1551  0313            BCF         STATUS,RP1
CODE:CODE:1552  cf01            CLRF        0x4f
CODE:CODE:1553  d001            CLRF        0x50
CODE:CODE:1554  d030            MOVLW       #0xd0
CODE:CODE:1555  d100            MOVWF       0x51
CODE:CODE:1556  0a16            BSF         PCLATH,#0x4
CODE:CODE:1557  8a11            BCF         PCLATH,#0x3
CODE:CODE:1558  2e2f            GOTO        offset Cecile-0x1000                    ;undefined Cecile()
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Coralie()
                                                          ;XREF[1,0]:   CODE:103f
CODE:CODE:1559  6400            CLRWDT
CODE:CODE:155a  8312            BCF         STATUS,RP0
CODE:CODE:155b  0313            BCF         STATUS,RP1
CODE:CODE:155c  2f1d            BTFSS       0x2f,#0x2
CODE:CODE:155d  782d            GOTO        offset LAB_CODE_1578-0x1000
CODE:CODE:155e  2f11            BCF         0x2f,#0x2
CODE:CODE:155f  be1f            BTFSS       0x3e,#0x7
CODE:CODE:1560  702d            GOTO        offset LAB_CODE_1570-0x1000
CODE:CODE:1561  8316            BSF         STATUS,RP0
CODE:CODE:1562  2d0b            DECFSZ      0x2d,w
CODE:CODE:1563  702d            GOTO        offset LAB_CODE_1570-0x1000
CODE:CODE:1564  8312            BCF         STATUS,RP0
CODE:CODE:1565  2f16            BSF         0x2f,#0x4
CODE:CODE:1566  0030            MOVLW       #0x0
CODE:CODE:1567  0a12            BCF         PCLATH,#0x4
CODE:CODE:1568  8a11            BCF         PCLATH,#0x3
CODE:CODE:1569  6724            CALL        USART_MAYBE_CONFIG                      ;undefined USART_MAYBE_CONFIG()
CODE:CODE:156a  0a16            BSF         PCLATH,#0x4
CODE:CODE:156b  8a11            BCF         PCLATH,#0x3
CODE:CODE:156c  3c30            MOVLW       #0x3c
CODE:CODE:156d  8316            BSF         STATUS,RP0
CODE:CODE:156e  ce00            MOVWF       0x4e
CODE:CODE:156f  782d            GOTO        offset LAB_CODE_1578-0x1000
                            LAB_CODE_1570:                ;XREF[2,0]:   CODE:1560,CODE:1563
CODE:CODE:1570  8312            BCF         STATUS,RP0
CODE:CODE:1571  2f12            BCF         0x2f,#0x4
CODE:CODE:1572  ff30            MOVLW       #0xff
CODE:CODE:1573  0a12            BCF         PCLATH,#0x4
CODE:CODE:1574  8a11            BCF         PCLATH,#0x3
CODE:CODE:1575  6724            CALL        USART_MAYBE_CONFIG                      ;undefined USART_MAYBE_CONFIG()
CODE:CODE:1576  0a16            BSF         PCLATH,#0x4
CODE:CODE:1577  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_1578:                ;XREF[2,0]:   CODE:155d,CODE:156f
CODE:CODE:1578  8312            BCF         STATUS,RP0
CODE:CODE:1579  2c1e            BTFSS       0x2c,#0x4
CODE:CODE:157a  9c2d            GOTO        offset LAB_CODE_159c-0x1000
CODE:CODE:157b  dc01            CLRF        0x5c
CODE:CODE:157c  dd01            CLRF        0x5d
CODE:CODE:157d  d030            MOVLW       #0xd0
CODE:CODE:157e  de00            MOVWF       0x5e
CODE:CODE:157f  0a16            BSF         PCLATH,#0x4
CODE:CODE:1580  8a11            BCF         PCLATH,#0x3
CODE:CODE:1581  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:1582  0a16            BSF         PCLATH,#0x4
CODE:CODE:1583  8a11            BCF         PCLATH,#0x3
CODE:CODE:1584  e424            CALL        offset Eloise-0x1000                    ;undefined Eloise()
CODE:CODE:1585  0038            IORLW       #0x0
CODE:CODE:1586  031d            BTFSS       STATUS,#0x2
CODE:CODE:1587  9c2d            GOTO        offset LAB_CODE_159c-0x1000
CODE:CODE:1588  0317            BSF         STATUS,RP1
CODE:CODE:1589  4708            MOVF        0x47,w
CODE:CODE:158a  7f39            ANDLW       #0x7f
CODE:CODE:158b  8316            BSF         STATUS,RP0
CODE:CODE:158c  0313            BCF         STATUS,RP1
CODE:CODE:158d  ae00            MOVWF       0x2e
CODE:CODE:158e  8312            BCF         STATUS,RP0
CODE:CODE:158f  0317            BSF         STATUS,RP1
CODE:CODE:1590  4808            MOVF        0x48,w
CODE:CODE:1591  7f39            ANDLW       #0x7f
CODE:CODE:1592  8316            BSF         STATUS,RP0
CODE:CODE:1593  0313            BCF         STATUS,RP1
CODE:CODE:1594  ab00            MOVWF       0x2b
CODE:CODE:1595  8312            BCF         STATUS,RP0
CODE:CODE:1596  0317            BSF         STATUS,RP1
CODE:CODE:1597  4908            MOVF        0x49,w
CODE:CODE:1598  3f39            ANDLW       #0x3f
CODE:CODE:1599  8316            BSF         STATUS,RP0
CODE:CODE:159a  0313            BCF         STATUS,RP1
CODE:CODE:159b  a100            MOVWF       0x21
                            LAB_CODE_159c:                ;XREF[2,0]:   CODE:157a,CODE:1587
CODE:CODE:159c  8312            BCF         STATUS,RP0
CODE:CODE:159d  3a08            MOVF        0x3a,w
CODE:CODE:159e  3f39            ANDLW       #0x3f
CODE:CODE:159f  113a            XORLW       #0x11
CODE:CODE:15a0  0319            BTFSC       STATUS,#0x2
CODE:CODE:15a1  ba1f            BTFSS       0x3a,#0x7
CODE:CODE:15a2  e72d            GOTO        offset LAB_CODE_15e7-0x1000
CODE:CODE:15a3  be1d            BTFSS       0x3e,#0x3
CODE:CODE:15a4  e72d            GOTO        offset LAB_CODE_15e7-0x1000
CODE:CODE:15a5  8316            BSF         STATUS,RP0
CODE:CODE:15a6  2d0b            DECFSZ      0x2d,w
CODE:CODE:15a7  e72d            GOTO        offset LAB_CODE_15e7-0x1000
CODE:CODE:15a8  8312            BCF         STATUS,RP0
CODE:CODE:15a9  ca01            CLRF        0x4a
                            LAB_CODE_15aa:                ;XREF[1,0]:   CODE:15ae
CODE:CODE:15aa  ca0a            INCF        0x4a,f
CODE:CODE:15ab  0830            MOVLW       #0x8
CODE:CODE:15ac  4a02            SUBWF       0x4a,w
CODE:CODE:15ad  031c            BTFSS       STATUS,#0x0
CODE:CODE:15ae  aa2d            GOTO        offset LAB_CODE_15aa-0x1000
CODE:CODE:15af  3b08            MOVF        0x3b,w
CODE:CODE:15b0  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:15b1  0a16            BSF         PCLATH,#0x4
CODE:CODE:15b2  8a11            BCF         PCLATH,#0x3
CODE:CODE:15b3  cb00            MOVWF       0x4b
CODE:CODE:15b4  1830            MOVLW       #0x18
CODE:CODE:15b5  4b02            SUBWF       0x4b,w
CODE:CODE:15b6  0318            BTFSC       STATUS,#0x0
CODE:CODE:15b7  e72d            GOTO        offset LAB_CODE_15e7-0x1000
CODE:CODE:15b8  3c08            MOVF        0x3c,w
CODE:CODE:15b9  ce24            CALL        offset Evelise-0x1000                   ;undefined Evelise()
CODE:CODE:15ba  0a16            BSF         PCLATH,#0x4
CODE:CODE:15bb  8a11            BCF         PCLATH,#0x3
CODE:CODE:15bc  cc00            MOVWF       0x4c
CODE:CODE:15bd  3c30            MOVLW       #0x3c
CODE:CODE:15be  4c02            SUBWF       0x4c,w
CODE:CODE:15bf  0318            BTFSC       STATUS,#0x0
CODE:CODE:15c0  e72d            GOTO        offset LAB_CODE_15e7-0x1000
CODE:CODE:15c1  3b08            MOVF        0x3b,w
CODE:CODE:15c2  8316            BSF         STATUS,RP0
CODE:CODE:15c3  a100            MOVWF       0x21
CODE:CODE:15c4  8312            BCF         STATUS,RP0
CODE:CODE:15c5  3c08            MOVF        0x3c,w
CODE:CODE:15c6  8316            BSF         STATUS,RP0
CODE:CODE:15c7  ab00            MOVWF       0x2b
CODE:CODE:15c8  ae01            CLRF        0x2e
CODE:CODE:15c9  8312            BCF         STATUS,RP0
CODE:CODE:15ca  2e17            BSF         0x2e,#0x6
CODE:CODE:15cb  8316            BSF         STATUS,RP0
CODE:CODE:15cc  2108            MOVF        0x21,w
CODE:CODE:15cd  8312            BCF         STATUS,RP0
CODE:CODE:15ce  0317            BSF         STATUS,RP1
CODE:CODE:15cf  c900            MOVWF       0x49
CODE:CODE:15d0  8316            BSF         STATUS,RP0
CODE:CODE:15d1  0313            BCF         STATUS,RP1
CODE:CODE:15d2  2b08            MOVF        0x2b,w
CODE:CODE:15d3  8312            BCF         STATUS,RP0
CODE:CODE:15d4  0317            BSF         STATUS,RP1
CODE:CODE:15d5  c800            MOVWF       0x48
CODE:CODE:15d6  8316            BSF         STATUS,RP0
CODE:CODE:15d7  0313            BCF         STATUS,RP1
CODE:CODE:15d8  2e08            MOVF        0x2e,w
CODE:CODE:15d9  8312            BCF         STATUS,RP0
CODE:CODE:15da  0317            BSF         STATUS,RP1
CODE:CODE:15db  c700            MOVWF       0x47
CODE:CODE:15dc  ce01            CLRF        0x4e
CODE:CODE:15dd  0313            BCF         STATUS,RP1
CODE:CODE:15de  cf01            CLRF        0x4f
CODE:CODE:15df  d001            CLRF        0x50
CODE:CODE:15e0  d030            MOVLW       #0xd0
CODE:CODE:15e1  d100            MOVWF       0x51
CODE:CODE:15e2  0a16            BSF         PCLATH,#0x4
CODE:CODE:15e3  8a11            BCF         PCLATH,#0x3
CODE:CODE:15e4  2e27            CALL        offset Cecile-0x1000                    ;undefined Cecile()
CODE:CODE:15e5  0a16            BSF         PCLATH,#0x4
CODE:CODE:15e6  8a11            BCF         PCLATH,#0x3
                            LAB_CODE_15e7:                ;XREF[5,0]:   CODE:15a2,CODE:15a4,CODE:15a7,CODE:15b7
                                                          ;             CODE:15c0
CODE:CODE:15e7  8312            BCF         STATUS,RP0
CODE:CODE:15e8  ae1e            BTFSS       0x2e,#0x5
CODE:CODE:15e9  f02d            GOTO        offset LAB_CODE_15f0-0x1000
CODE:CODE:15ea  8316            BSF         STATUS,RP0
CODE:CODE:15eb  cb08            MOVF        0x4b,f
CODE:CODE:15ec  031d            BTFSS       STATUS,#0x2
CODE:CODE:15ed  f32d            GOTO        offset LAB_CODE_15f3-0x1000
CODE:CODE:15ee  3c30            MOVLW       #0x3c
CODE:CODE:15ef  f22d            GOTO        offset LAB_CODE_15f2-0x1000
                            LAB_CODE_15f0:                ;XREF[1,0]:   CODE:15e9
CODE:CODE:15f0  3c30            MOVLW       #0x3c
CODE:CODE:15f1  8316            BSF         STATUS,RP0
                            LAB_CODE_15f2:                ;XREF[1,0]:   CODE:15ef
CODE:CODE:15f2  cb00            MOVWF       0x4b
                            LAB_CODE_15f3:                ;XREF[1,0]:   CODE:15ed
CODE:CODE:15f3  8312            BCF         STATUS,RP0
CODE:CODE:15f4  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Elsa()
                                                          ;XREF[4,0]:   CODE:16a3,CODE:16c7,CODE:17e6,CODE:17f3
CODE:CODE:15f5  8301            CLRF        STATUS
CODE:CODE:15f6  e200            MOVWF       0x62
CODE:CODE:15f7  e401            CLRF        0x64
CODE:CODE:15f8  8316            BSF         STATUS,RP0
CODE:CODE:15f9  8615            BSF         FSR1L,#0x3
CODE:CODE:15fa  8312            BCF         STATUS,RP0
CODE:CODE:15fb  e301            CLRF        0x63
CODE:CODE:15fc  0310            BCF         STATUS,C
                            LAB_CODE_15fd:                ;XREF[1,0]:   CODE:1608
CODE:CODE:15fd  e40d            RLF         0x64,f
CODE:CODE:15fe  0616            BSF         FSR1L,#0x4
CODE:CODE:15ff  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1600  8619            BTFSC       FSR1L,#0x3
CODE:CODE:1601  6414            BSF         0x64,#0x0
CODE:CODE:1602  0612            BCF         FSR1L,#0x4
CODE:CODE:1603  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1604  e30a            INCF        0x63,f
CODE:CODE:1605  0830            MOVLW       #0x8
CODE:CODE:1606  6302            SUBWF       0x63,w
CODE:CODE:1607  031c            BTFSS       STATUS,#0x0
CODE:CODE:1608  fd2d            GOTO        offset LAB_CODE_15fd-0x1000
CODE:CODE:1609  8316            BSF         STATUS,RP0
CODE:CODE:160a  8611            BCF         FSR1L,#0x3
CODE:CODE:160b  8312            BCF         STATUS,RP0
CODE:CODE:160c  620b            DECFSZ      0x62,w
CODE:CODE:160d  102e            GOTO        offset LAB_CODE_1610-0x1000
CODE:CODE:160e  8611            BCF         FSR1L,#0x3
CODE:CODE:160f  142e            GOTO        offset LAB_CODE_1614-0x1000
                            LAB_CODE_1610:                ;XREF[1,0]:   CODE:160d
CODE:CODE:1610  8615            BSF         FSR1L,#0x3
CODE:CODE:1611  0000            NOP
CODE:CODE:1612  0000            NOP
CODE:CODE:1613  0000            NOP
                            LAB_CODE_1614:                ;XREF[1,0]:   CODE:160f
CODE:CODE:1614  0616            BSF         FSR1L,#0x4
CODE:CODE:1615  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1616  0612            BCF         FSR1L,#0x4
CODE:CODE:1617  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1618  8611            BCF         FSR1L,#0x3
CODE:CODE:1619  6408            MOVF        0x64,w
CODE:CODE:161a  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Alice()
                                                          ;XREF[16,0]:  CODE:0106,CODE:010f,CODE:011a,CODE:011f
                                                          ;             CODE:166d,CODE:167b,CODE:1681,CODE:168f
                                                          ;             CODE:1740,CODE:174e,CODE:1754,CODE:176c
                                                          ;             CODE:17a3,CODE:17aa,CODE:17b1,CODE:17c3
CODE:CODE:161b  8301            CLRF        STATUS
CODE:CODE:161c  e200            MOVWF       0x62
CODE:CODE:161d  8316            BSF         STATUS,RP0
CODE:CODE:161e  8611            BCF         FSR1L,#0x3
CODE:CODE:161f  8312            BCF         STATUS,RP0
CODE:CODE:1620  e301            CLRF        0x63
                            LAB_CODE_1621:                ;XREF[1,0]:   CODE:1638
CODE:CODE:1621  e21f            BTFSS       0x62,#0x7
CODE:CODE:1622  272e            GOTO        offset LAB_CODE_1627-0x1000
CODE:CODE:1623  8615            BSF         FSR1L,#0x3
CODE:CODE:1624  0000            NOP
CODE:CODE:1625  0000            NOP
CODE:CODE:1626  282e            GOTO        offset LAB_CODE_1628-0x1000
                            LAB_CODE_1627:                ;XREF[1,0]:   CODE:1622
CODE:CODE:1627  8611            BCF         FSR1L,#0x3
                            LAB_CODE_1628:                ;XREF[1,0]:   CODE:1626
CODE:CODE:1628  0000            NOP
CODE:CODE:1629  0616            BSF         FSR1L,#0x4
CODE:CODE:162a  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:162b  0612            BCF         FSR1L,#0x4
CODE:CODE:162c  6308            MOVF        0x63,w
CODE:CODE:162d  073a            XORLW       #0x7
CODE:CODE:162e  8316            BSF         STATUS,RP0
CODE:CODE:162f  0319            BTFSC       STATUS,#0x2
CODE:CODE:1630  8615            BSF         FSR1L,#0x3
CODE:CODE:1631  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1632  0310            BCF         STATUS,C
CODE:CODE:1633  e20d            RLF         0x62,f
CODE:CODE:1634  e30a            INCF        0x63,f
CODE:CODE:1635  0830            MOVLW       #0x8
CODE:CODE:1636  6302            SUBWF       0x63,w
CODE:CODE:1637  031c            BTFSS       STATUS,#0x0
CODE:CODE:1638  212e            GOTO        offset LAB_CODE_1621-0x1000
CODE:CODE:1639  0616            BSF         FSR1L,#0x4
CODE:CODE:163a  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:163b  e301            CLRF        0x63
CODE:CODE:163c  861d            BTFSS       FSR1L,#0x3
CODE:CODE:163d  402e            GOTO        offset LAB_CODE_1640-0x1000
CODE:CODE:163e  e301            CLRF        0x63
CODE:CODE:163f  e30a            INCF        0x63,f
                            LAB_CODE_1640:                ;XREF[1,0]:   CODE:163d
CODE:CODE:1640  0612            BCF         FSR1L,#0x4
CODE:CODE:1641  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1642  8316            BSF         STATUS,RP0
CODE:CODE:1643  8611            BCF         FSR1L,#0x3
CODE:CODE:1644  8312            BCF         STATUS,RP0
CODE:CODE:1645  6308            MOVF        0x63,w
CODE:CODE:1646  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Aline()
                                                          ;XREF[6,0]:   CODE:0101,CODE:1668,CODE:1689,CODE:173b
                                                          ;             CODE:179d,CODE:17bd
CODE:CODE:1647  8301            CLRF        STATUS
CODE:CODE:1648  8615            BSF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:1649  0000            NOP
CODE:CODE:164a  0000            NOP
CODE:CODE:164b  0000            NOP
CODE:CODE:164c  0616            BSF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:164d  8316            BSF         STATUS,RP0
CODE:CODE:164e  8611            BCF         FSR1L=>BANK-1:TRISB,#0x3                ;= ??
CODE:CODE:164f  8615            BSF         FSR1L=>BANK-1:TRISB,#0x3                ;= ??
CODE:CODE:1650  8312            BCF         STATUS,RP0
CODE:CODE:1651  861d            BTFSS       FSR1L,#0x3
CODE:CODE:1652  0134            RETLW       #0x1
CODE:CODE:1653  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1654  8316            BSF         STATUS,RP0
CODE:CODE:1655  8611            BCF         FSR1L=>BANK-1:TRISB,#0x3                ;= ??
CODE:CODE:1656  8312            BCF         STATUS,RP0
CODE:CODE:1657  8611            BCF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:1658  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:1659  0612            BCF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:165a  0034            RETLW       #0x0
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Caroline()
                                                          ;XREF[9,0]:   CODE:06fb,CODE:1257,CODE:12a7,CODE:1424
                                                          ;             CODE:1463,CODE:151a,CODE:1581,CODE:16ff
                                                          ;             CODE:171b
CODE:CODE:165b  8316            BSF         STATUS,RP0
CODE:CODE:165c  0313            BCF         STATUS,RP1
CODE:CODE:165d  a401            CLRF        BANK-1:DAT_BANK-1__0024                 ;= ??
CODE:CODE:165e  8312            BCF         STATUS,RP0
CODE:CODE:165f  5c08            MOVF        BANK-0:DAT_DATA_005c,w                  ;= ??
CODE:CODE:1660  8316            BSF         STATUS,RP0
CODE:CODE:1661  db00            MOVWF       BANK-1:DAT_BANK-1__005b                 ;= ??
CODE:CODE:1662  8312            BCF         STATUS,RP0
CODE:CODE:1663  5d08            MOVF        BANK-0:DAT_DATA_005d,w                  ;= ??
CODE:CODE:1664  8316            BSF         STATUS,RP0
CODE:CODE:1665  dc00            MOVWF       BANK-1:DAT_BANK-1__005c                 ;= ??
CODE:CODE:1666  8312            BCF         STATUS,RP0
CODE:CODE:1667  df01            CLRF        BANK-0:DAT_DATA_005f                    ;= ??
CODE:CODE:1668  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:1669  0a16            BSF         PCLATH,#0x4
CODE:CODE:166a  8a11            BCF         PCLATH,#0x3
CODE:CODE:166b  df00            MOVWF       BANK-0:DAT_DATA_005f                    ;= ??
CODE:CODE:166c  5e08            MOVF        BANK-0:DAT_DATA_005e,w                  ;= ??
CODE:CODE:166d  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:166e  0a16            BSF         PCLATH,#0x4
CODE:CODE:166f  8a11            BCF         PCLATH,#0x3
CODE:CODE:1670  df07            ADDWF       BANK-0:DAT_DATA_005f,f                  ;= ??
CODE:CODE:1671  5e08            MOVF        BANK-0:DAT_DATA_005e,w                  ;= ??
CODE:CODE:1672  d03a            XORLW       #0xd0
CODE:CODE:1673  0319            BTFSC       STATUS,#0x2
CODE:CODE:1674  7f2e            GOTO        offset LAB_CODE_167f-0x1000
CODE:CODE:1675  5e08            MOVF        BANK-0:DAT_DATA_005e,w                  ;= ??
CODE:CODE:1676  a03a            XORLW       #0xa0
CODE:CODE:1677  031d            BTFSS       STATUS,#0x2
CODE:CODE:1678  852e            GOTO        offset LAB_CODE_1685-0x1000
CODE:CODE:1679  8316            BSF         STATUS,RP0
CODE:CODE:167a  5c08            MOVF        BANK-1:DAT_BANK-1__005c,w               ;= ??
CODE:CODE:167b  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:167c  0a16            BSF         PCLATH,#0x4
CODE:CODE:167d  8a11            BCF         PCLATH,#0x3
CODE:CODE:167e  df07            ADDWF       BANK-0:DAT_DATA_005f,f                  ;= ??
                            LAB_CODE_167f:                ;XREF[1,0]:   CODE:1674
CODE:CODE:167f  8316            BSF         STATUS,RP0
CODE:CODE:1680  5b08            MOVF        BANK-1:DAT_BANK-1__005b,w               ;= ??
CODE:CODE:1681  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:1682  0a16            BSF         PCLATH,#0x4
CODE:CODE:1683  8a11            BCF         PCLATH,#0x3
CODE:CODE:1684  df07            ADDWF       BANK-0:DAT_DATA_005f,f                  ;= ??
                            LAB_CODE_1685:                ;XREF[1,0]:   CODE:1678
CODE:CODE:1685  df08            MOVF        BANK-0:DAT_DATA_005f,f                  ;= ??
CODE:CODE:1686  031d            BTFSS       STATUS,#0x2
CODE:CODE:1687  962e            GOTO        offset LAB_CODE_1696-0x1000
CODE:CODE:1688  df01            CLRF        BANK-0:DAT_DATA_005f                    ;= ??
CODE:CODE:1689  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:168a  0a16            BSF         PCLATH,#0x4
CODE:CODE:168b  8a11            BCF         PCLATH,#0x3
CODE:CODE:168c  df00            MOVWF       BANK-0:DAT_DATA_005f                    ;= ??
CODE:CODE:168d  5e08            MOVF        BANK-0:DAT_DATA_005e,w                  ;= ??
CODE:CODE:168e  0138            IORLW       #0x1
CODE:CODE:168f  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:1690  0a16            BSF         PCLATH,#0x4
CODE:CODE:1691  8a11            BCF         PCLATH,#0x3
CODE:CODE:1692  df07            ADDWF       BANK-0:DAT_DATA_005f,f                  ;= ??
CODE:CODE:1693  df08            MOVF        BANK-0:DAT_DATA_005f,f                  ;= ??
CODE:CODE:1694  0319            BTFSC       STATUS,#0x2
CODE:CODE:1695  9a2e            GOTO        offset LAB_CODE_169a-0x1000
                            LAB_CODE_1696:                ;XREF[1,0]:   CODE:1687
CODE:CODE:1696  ff30            MOVLW       #0xff
CODE:CODE:1697  8316            BSF         STATUS,RP0
CODE:CODE:1698  a400            MOVWF       BANK-1:DAT_BANK-1__0024                 ;= ??
CODE:CODE:1699  d02e            GOTO        offset LAB_CODE_16d0-0x1000
                            LAB_CODE_169a:                ;XREF[1,0]:   CODE:1695
CODE:CODE:169a  df01            CLRF        BANK-0:DAT_DATA_005f                    ;= ??
CODE:CODE:169b  a92e            GOTO        offset LAB_CODE_16a9-0x1000
                            LAB_CODE_169c:                ;XREF[1,0]:   CODE:16c1
CODE:CODE:169c  8312            BCF         STATUS,RP0
CODE:CODE:169d  0313            BCF         STATUS,RP1
CODE:CODE:169e  5f08            MOVF        0x5f,w
CODE:CODE:169f  473e            ADDLW       #0x47
CODE:CODE:16a0  8400            MOVWF       FSR0L
CODE:CODE:16a1  8317            BSF         STATUS,IRP
CODE:CODE:16a2  0130            MOVLW       #0x1
CODE:CODE:16a3  f525            CALL        offset Elsa-0x1000                      ;undefined Elsa()
CODE:CODE:16a4  0a16            BSF         PCLATH,#0x4
CODE:CODE:16a5  8a11            BCF         PCLATH,#0x3
CODE:CODE:16a6  8317            BSF         STATUS,IRP
CODE:CODE:16a7  8000            MOVWF       INDF0
CODE:CODE:16a8  df0a            INCF        0x5f,f
                            LAB_CODE_16a9:                ;XREF[1,0]:   CODE:169b
CODE:CODE:16a9  5e08            MOVF        BANK-0:DAT_DATA_005e,w                  ;= ??
CODE:CODE:16aa  d03a            XORLW       #0xd0
CODE:CODE:16ab  0319            BTFSC       STATUS,#0x2
CODE:CODE:16ac  af2e            GOTO        offset LAB_CODE_16af-0x1000
CODE:CODE:16ad  0f30            MOVLW       #0xf
CODE:CODE:16ae  b02e            GOTO        offset LAB_CODE_16b0-0x1000
                            LAB_CODE_16af:                ;XREF[1,0]:   CODE:16ac
CODE:CODE:16af  0730            MOVLW       #0x7
                            LAB_CODE_16b0:                ;XREF[1,0]:   CODE:16ae
CODE:CODE:16b0  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:16b1  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:16b2  8312            BCF         STATUS,RP0
CODE:CODE:16b3  5f08            MOVF        BANK-0:DAT_DATA_005f,w                  ;= ??
CODE:CODE:16b4  e000            MOVWF       BANK-0:DAT_DATA_0060                    ;= ??
CODE:CODE:16b5  e101            CLRF        BANK-0:DAT_DATA_0061                    ;= ??
CODE:CODE:16b6  6108            MOVF        BANK-0:DAT_DATA_0061,w                  ;= ??
CODE:CODE:16b7  803a            XORLW       #0x80
CODE:CODE:16b8  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:16b9  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:16ba  803a            XORLW       #0x80
CODE:CODE:16bb  7b02            SUBWF       BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:16bc  031d            BTFSS       STATUS,#0x2
CODE:CODE:16bd  c02e            GOTO        offset LAB_CODE_16c0-0x1000
CODE:CODE:16be  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:16bf  6002            SUBWF       BANK-0:DAT_DATA_0060,w                  ;= ??
                            LAB_CODE_16c0:                ;XREF[1,0]:   CODE:16bd
CODE:CODE:16c0  031c            BTFSS       STATUS,#0x0
CODE:CODE:16c1  9c2e            GOTO        offset LAB_CODE_169c-0x1000
CODE:CODE:16c2  5f08            MOVF        BANK-0:DAT_DATA_005f,w                  ;= ??
CODE:CODE:16c3  473e            ADDLW       #0x47
CODE:CODE:16c4  8400            MOVWF       FSR0L
CODE:CODE:16c5  8317            BSF         STATUS,IRP
CODE:CODE:16c6  0030            MOVLW       #0x0
CODE:CODE:16c7  f525            CALL        offset Elsa-0x1000                      ;undefined Elsa()
CODE:CODE:16c8  0a16            BSF         PCLATH,#0x4
CODE:CODE:16c9  8a11            BCF         PCLATH,#0x3
CODE:CODE:16ca  8317            BSF         STATUS,IRP
CODE:CODE:16cb  8000            MOVWF       INDF0=>BANK-1:DAT_BANK-1__0047          ;= ??
CODE:CODE:16cc  d226            CALL        offset Agathe-0x1000                    ;undefined Agathe()
CODE:CODE:16cd  0a16            BSF         PCLATH,#0x4
CODE:CODE:16ce  8a11            BCF         PCLATH,#0x3
CODE:CODE:16cf  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
                            LAB_CODE_16d0:                ;XREF[1,0]:   CODE:1699
CODE:CODE:16d0  8312            BCF         STATUS,RP0
CODE:CODE:16d1  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Agathe()
                                                          ;XREF[6,0]:   CODE:0122,CODE:16cc,CODE:16f7,CODE:175e
                                                          ;             CODE:178a,CODE:17fa
CODE:CODE:16d2  8301            CLRF        STATUS
CODE:CODE:16d3  0612            BCF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:16d4  8316            BSF         STATUS,RP0
CODE:CODE:16d5  8611            BCF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:16d6  8312            BCF         STATUS,RP0
CODE:CODE:16d7  8611            BCF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:16d8  0616            BSF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:16d9  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:16da  8615            BSF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:16db  0000            NOP
CODE:CODE:16dc  0000            NOP
CODE:CODE:16dd  0000            NOP
                            ;this is a goto
CODE:CODE:16de  df2e            GOTO        offset Anais-0x1000                     ;void Anais(void)
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void Anais(void)
                                                          ;XREF[17,0]:  CODE:15ff,CODE:1603,CODE:1615,CODE:1617
                                                          ;             CODE:162a,CODE:1631,CODE:163a,CODE:1641
                                                          ;             CODE:1653,CODE:1658,CODE:16cf,CODE:16d9
                                                          ;             CODE:16de,CODE:16ee,CODE:16f0,CODE:1794
                                                          ;             CODE:17fd
CODE:CODE:16df  6400            CLRWDT
CODE:CODE:16e0  8312            BCF         STATUS,RP0
CODE:CODE:16e1  0313            BCF         STATUS,RP1
CODE:CODE:16e2  ad14            BSF         BANK-0:USART_RX_PACKET_STATUS,#0x1      ;= ??
CODE:CODE:16e3  ad1c            BTFSS       BANK-0:USART_RX_PACKET_STATUS,#0x1      ;= ??
CODE:CODE:16e4  0800            RETURN
CODE:CODE:16e5  0000            NOP
CODE:CODE:16e6  ad10            BCF         BANK-0:USART_RX_PACKET_STATUS,#0x1      ;= ??
CODE:CODE:16e7  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Eleonore()
                                                          ;XREF[1,0]:   CODE:1025
CODE:CODE:16e8  8301            CLRF        STATUS
CODE:CODE:16e9  ca01            CLRF        BANK-0:DAT_DATA_004a                    ;= ??
                            LAB_CODE_16ea:                ;XREF[1,0]:   CODE:16f6
CODE:CODE:16ea  8615            BSF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:16eb  0616            BSF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:16ec  8316            BSF         STATUS,RP0
CODE:CODE:16ed  8611            BCF         FSR1L=>BANK-1:TRISB,#0x3                ;= ??
CODE:CODE:16ee  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:16ef  8611            BCF         FSR1L=>BANK-0:PORTB,#0x3                ;= ??
CODE:CODE:16f0  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
CODE:CODE:16f1  0612            BCF         FSR1L=>BANK-0:PORTB,#0x4                ;= ??
CODE:CODE:16f2  ca0a            INCF        BANK-0:DAT_DATA_004a,f                  ;= ??
CODE:CODE:16f3  0930            MOVLW       #0x9
CODE:CODE:16f4  4a02            SUBWF       BANK-0:DAT_DATA_004a,w                  ;= ??
CODE:CODE:16f5  031c            BTFSS       STATUS,#0x0
CODE:CODE:16f6  ea2e            GOTO        offset LAB_CODE_16ea-0x1000
CODE:CODE:16f7  d226            CALL        offset Agathe-0x1000                    ;undefined Agathe()
CODE:CODE:16f8  0a16            BSF         PCLATH,#0x4
CODE:CODE:16f9  8a11            BCF         PCLATH,#0x3
CODE:CODE:16fa  0230            MOVLW       #0x2
CODE:CODE:16fb  dc00            MOVWF       BANK-0:DAT_DATA_005c                    ;= ??
CODE:CODE:16fc  dd01            CLRF        BANK-0:DAT_DATA_005d                    ;= ??
CODE:CODE:16fd  a030            MOVLW       #0xa0
CODE:CODE:16fe  de00            MOVWF       BANK-0:DAT_DATA_005e                    ;= ??
CODE:CODE:16ff  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:1700  0a16            BSF         PCLATH,#0x4
CODE:CODE:1701  8a11            BCF         PCLATH,#0x3
CODE:CODE:1702  0317            BSF         STATUS,RP1
CODE:CODE:1703  4708            MOVF        BANK-2:DAT_BANK-2__0047,w               ;= ??
CODE:CODE:1704  0313            BCF         STATUS,RP1
CODE:CODE:1705  cb00            MOVWF       BANK-0:DAT_DATA_004b                    ;= ??
CODE:CODE:1706  cc01            CLRF        BANK-0:DAT_DATA_004c                    ;= ??
CODE:CODE:1707  0317            BSF         STATUS,RP1
CODE:CODE:1708  4808            MOVF        BANK-2:DAT_BANK-2__0048,w               ;= ??
CODE:CODE:1709  0313            BCF         STATUS,RP1
CODE:CODE:170a  cb07            ADDWF       BANK-0:DAT_DATA_004b,f                  ;= ??
CODE:CODE:170b  0318            BTFSC       STATUS,#0x0
CODE:CODE:170c  cc0a            INCF        BANK-0:DAT_DATA_004c,f                  ;= ??
CODE:CODE:170d  4b0a            INCF        BANK-0:DAT_DATA_004b,w                  ;= ??
CODE:CODE:170e  4c04            IORWF       BANK-0:DAT_DATA_004c,w                  ;= ??
CODE:CODE:170f  031d            BTFSS       STATUS,#0x2
CODE:CODE:1710  162f            GOTO        offset LAB_CODE_1716-0x1000
CODE:CODE:1711  0317            BSF         STATUS,RP1
CODE:CODE:1712  4708            MOVF        BANK-2:DAT_BANK-2__0047,w               ;= ??
CODE:CODE:1713  8316            BSF         STATUS,RP0
CODE:CODE:1714  0313            BCF         STATUS,RP1
CODE:CODE:1715  aa00            MOVWF       BANK-1:DAT_BANK-1__002a                 ;= ??
                            LAB_CODE_1716:                ;XREF[1,0]:   CODE:1710
CODE:CODE:1716  8312            BCF         STATUS,RP0
CODE:CODE:1717  dc01            CLRF        0x5c
CODE:CODE:1718  dd01            CLRF        0x5d
CODE:CODE:1719  a030            MOVLW       #0xa0
CODE:CODE:171a  de00            MOVWF       0x5e
CODE:CODE:171b  5b26            CALL        offset Caroline-0x1000                  ;undefined Caroline()
CODE:CODE:171c  0a16            BSF         PCLATH,#0x4
CODE:CODE:171d  8a11            BCF         PCLATH,#0x3
CODE:CODE:171e  0317            BSF         STATUS,RP1
CODE:CODE:171f  4708            MOVF        0x47,w
CODE:CODE:1720  a100            MOVWF       0x21
CODE:CODE:1721  0930            MOVLW       #0x9
CODE:CODE:1722  2102            SUBWF       0x21,w
CODE:CODE:1723  8316            BSF         STATUS,RP0
CODE:CODE:1724  0313            BCF         STATUS,RP1
CODE:CODE:1725  d901            CLRF        0x59
CODE:CODE:1726  0318            BTFSC       STATUS,#0x0
CODE:CODE:1727  2a2f            GOTO        offset LAB_CODE_172a-0x1000
CODE:CODE:1728  4030            MOVLW       #0x40
CODE:CODE:1729  2b2f            GOTO        offset LAB_CODE_172b-0x1000
                            LAB_CODE_172a:                ;XREF[1,0]:   CODE:1727
CODE:CODE:172a  8030            MOVLW       #0x80
                            LAB_CODE_172b:                ;XREF[1,0]:   CODE:1729
CODE:CODE:172b  da00            MOVWF       0x5a
CODE:CODE:172c  8312            BCF         STATUS,RP0
CODE:CODE:172d  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Cecile()
                                                          ;XREF[5,0]:   CODE:0257,CODE:06da,CODE:1548,CODE:1558
                                                          ;             CODE:15e4
CODE:CODE:172e  8316            BSF         STATUS,RP0
CODE:CODE:172f  0313            BCF         STATUS,RP1
CODE:CODE:1730  a401            CLRF        BANK-0:DAT_DATA_0024                    ;= ??
CODE:CODE:1731  8312            BCF         STATUS,RP0
CODE:CODE:1732  4f08            MOVF        BANK-0:DAT_DATA_004f,w                  ;= ??
CODE:CODE:1733  8316            BSF         STATUS,RP0
CODE:CODE:1734  db00            MOVWF       BANK-1:DAT_BANK-1__005b                 ;= ??
CODE:CODE:1735  8312            BCF         STATUS,RP0
CODE:CODE:1736  5008            MOVF        BANK-0:DAT_DATA_0050,w                  ;= ??
CODE:CODE:1737  8316            BSF         STATUS,RP0
CODE:CODE:1738  dc00            MOVWF       BANK-1:DAT_BANK-1__005c                 ;= ??
CODE:CODE:1739  8312            BCF         STATUS,RP0
CODE:CODE:173a  8610            BCF         FSR1L=>BANK-0:PORTB,#0x1                ;= ??
CODE:CODE:173b  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:173c  0a16            BSF         PCLATH,#0x4
CODE:CODE:173d  8a11            BCF         PCLATH,#0x3
CODE:CODE:173e  d200            MOVWF       BANK-0:INIT_ST1_UNK1                    ;= ??
CODE:CODE:173f  5108            MOVF        BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:1740  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:1741  0a16            BSF         PCLATH,#0x4
CODE:CODE:1742  8a11            BCF         PCLATH,#0x3
CODE:CODE:1743  d207            ADDWF       BANK-0:INIT_ST1_UNK1,f                  ;= ??
CODE:CODE:1744  5108            MOVF        BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:1745  d03a            XORLW       #0xd0
CODE:CODE:1746  0319            BTFSC       STATUS,#0x2
CODE:CODE:1747  522f            GOTO        offset LAB_CODE_1752-0x1000
CODE:CODE:1748  5108            MOVF        BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:1749  a03a            XORLW       #0xa0
CODE:CODE:174a  031d            BTFSS       STATUS,#0x2
CODE:CODE:174b  582f            GOTO        offset LAB_CODE_1758-0x1000
CODE:CODE:174c  8316            BSF         STATUS,RP0
CODE:CODE:174d  5c08            MOVF        BANK-0:DAT_DATA_005c,w                  ;= ??
CODE:CODE:174e  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:174f  0a16            BSF         PCLATH,#0x4
CODE:CODE:1750  8a11            BCF         PCLATH,#0x3
CODE:CODE:1751  d207            ADDWF       BANK-0:INIT_ST1_UNK1,f                  ;= ??
                            LAB_CODE_1752:                ;XREF[1,0]:   CODE:1747
CODE:CODE:1752  8316            BSF         STATUS,RP0
CODE:CODE:1753  5b08            MOVF        BANK-1:DAT_BANK-1__005b,w               ;= ??
CODE:CODE:1754  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:1755  0a16            BSF         PCLATH,#0x4
CODE:CODE:1756  8a11            BCF         PCLATH,#0x3
CODE:CODE:1757  d207            ADDWF       BANK-0:INIT_ST1_UNK1,f                  ;= ??
                            LAB_CODE_1758:                ;XREF[1,0]:   CODE:174b
CODE:CODE:1758  d208            MOVF        BANK-0:INIT_ST1_UNK1,f                  ;= ??
CODE:CODE:1759  0319            BTFSC       STATUS,#0x2
CODE:CODE:175a  632f            GOTO        offset LAB_CODE_1763-0x1000
CODE:CODE:175b  ff30            MOVLW       #0xff
CODE:CODE:175c  8316            BSF         STATUS,RP0
CODE:CODE:175d  a400            MOVWF       BANK-1:DAT_BANK-1__0024                 ;= ??
CODE:CODE:175e  d226            CALL        offset Agathe-0x1000                    ;undefined Agathe()
CODE:CODE:175f  0a16            BSF         PCLATH,#0x4
CODE:CODE:1760  8a11            BCF         PCLATH,#0x3
CODE:CODE:1761  8614            BSF         FSR1L=>BANK-0:PORTB,#0x1                ;= ??
CODE:CODE:1762  0800            RETURN
                            LAB_CODE_1763:                ;XREF[1,0]:   CODE:175a
CODE:CODE:1763  d201            CLRF        BANK-0:INIT_ST1_UNK1                    ;= ??
CODE:CODE:1764  702f            GOTO        offset LAB_CODE_1770-0x1000
                            LAB_CODE_1765:                ;XREF[1,0]:   CODE:1789
CODE:CODE:1765  8312            BCF         STATUS,RP0
CODE:CODE:1766  0313            BCF         STATUS,RP1
CODE:CODE:1767  5208            MOVF        BANK-0:INIT_ST1_UNK1,w                  ;= ??
CODE:CODE:1768  473e            ADDLW       #0x47
CODE:CODE:1769  8400            MOVWF       FSR0L
CODE:CODE:176a  8317            BSF         STATUS,IRP
CODE:CODE:176b  0008            MOVF        INDF0=>BANK-2:DAT_BANK-2__0047,w        ;= ??
CODE:CODE:176c  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:176d  0a16            BSF         PCLATH,#0x4
CODE:CODE:176e  8a11            BCF         PCLATH,#0x3
CODE:CODE:176f  d20a            INCF        BANK-0:INIT_ST1_UNK1,f                  ;= ??
                            LAB_CODE_1770:                ;XREF[1,0]:   CODE:1764
CODE:CODE:1770  5108            MOVF        BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:1771  d03a            XORLW       #0xd0
CODE:CODE:1772  0319            BTFSC       STATUS,#0x2
CODE:CODE:1773  762f            GOTO        offset LAB_CODE_1776-0x1000
CODE:CODE:1774  1030            MOVLW       #0x10
CODE:CODE:1775  772f            GOTO        offset LAB_CODE_1777-0x1000
                            LAB_CODE_1776:                ;XREF[1,0]:   CODE:1773
CODE:CODE:1776  0830            MOVLW       #0x8
                            LAB_CODE_1777:                ;XREF[1,0]:   CODE:1775
CODE:CODE:1777  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1778  fa01            CLRF        BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:1779  8312            BCF         STATUS,RP0
CODE:CODE:177a  0313            BCF         STATUS,RP1
CODE:CODE:177b  5208            MOVF        BANK-0:INIT_ST1_UNK1,w                  ;= ??
CODE:CODE:177c  d300            MOVWF       BANK-0:INIT_ST1_UNK2                    ;= ??
CODE:CODE:177d  d401            CLRF        BANK-0:INIT_ST1_UNK3                    ;= ??
CODE:CODE:177e  5408            MOVF        BANK-0:INIT_ST1_UNK3,w                  ;= ??
CODE:CODE:177f  803a            XORLW       #0x80
CODE:CODE:1780  fb00            MOVWF       BANK-0:DAT_DATA_007b                    ;= ??
CODE:CODE:1781  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:1782  803a            XORLW       #0x80
CODE:CODE:1783  7b02            SUBWF       BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:1784  031d            BTFSS       STATUS,#0x2
CODE:CODE:1785  882f            GOTO        offset LAB_CODE_1788-0x1000
CODE:CODE:1786  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:1787  5302            SUBWF       BANK-0:INIT_ST1_UNK2,w                  ;= ??
                            LAB_CODE_1788:                ;XREF[1,0]:   CODE:1785
CODE:CODE:1788  031c            BTFSS       STATUS,#0x0
CODE:CODE:1789  652f            GOTO        offset LAB_CODE_1765-0x1000
CODE:CODE:178a  d226            CALL        offset Agathe-0x1000                    ;undefined Agathe()
CODE:CODE:178b  0a16            BSF         PCLATH,#0x4
CODE:CODE:178c  8a11            BCF         PCLATH,#0x3
CODE:CODE:178d  5108            MOVF        BANK-0:DAT_DATA_0051,w                  ;= ??
CODE:CODE:178e  a03a            XORLW       #0xa0
CODE:CODE:178f  031d            BTFSS       STATUS,#0x2
CODE:CODE:1790  932f            GOTO        offset LAB_CODE_1793-0x1000
CODE:CODE:1791  1930            MOVLW       #0x19
CODE:CODE:1792  c500            MOVWF       BANK-0:DAT_DATA_0045                    ;= ??
                            LAB_CODE_1793:                ;XREF[1,0]:   CODE:1790
CODE:CODE:1793  8614            BSF         FSR1L=>BANK-0:PORTB,#0x1                ;= ??
CODE:CODE:1794  df2e            GOTO        offset Anais-0x1000                     ;void Anais(void)
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Clemence()
                                                          ;XREF[1,0]:   CODE:0708
CODE:CODE:1795  8316            BSF         STATUS,RP0
CODE:CODE:1796  0313            BCF         STATUS,RP1
CODE:CODE:1797  a401            CLRF        0x24
CODE:CODE:1798  d701            CLRF        0x57
CODE:CODE:1799  d801            CLRF        0x58
CODE:CODE:179a  8312            BCF         STATUS,RP0
CODE:CODE:179b  cf01            CLRF        0x4f
CODE:CODE:179c  d001            CLRF        0x50
CODE:CODE:179d  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:179e  0a16            BSF         PCLATH,#0x4
CODE:CODE:179f  8a11            BCF         PCLATH,#0x3
CODE:CODE:17a0  cf00            MOVWF       0x4f
CODE:CODE:17a1  d001            CLRF        0x50
CODE:CODE:17a2  a030            MOVLW       #0xa0
CODE:CODE:17a3  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:17a4  0a16            BSF         PCLATH,#0x4
CODE:CODE:17a5  8a11            BCF         PCLATH,#0x3
CODE:CODE:17a6  cf07            ADDWF       0x4f,f
CODE:CODE:17a7  0318            BTFSC       STATUS,#0x0
CODE:CODE:17a8  d00a            INCF        0x50,f
CODE:CODE:17a9  0030            MOVLW       #0x0
CODE:CODE:17aa  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:17ab  0a16            BSF         PCLATH,#0x4
CODE:CODE:17ac  8a11            BCF         PCLATH,#0x3
CODE:CODE:17ad  cf07            ADDWF       0x4f,f
CODE:CODE:17ae  0318            BTFSC       STATUS,#0x0
CODE:CODE:17af  d00a            INCF        0x50,f
CODE:CODE:17b0  0030            MOVLW       #0x0
CODE:CODE:17b1  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:17b2  0a16            BSF         PCLATH,#0x4
CODE:CODE:17b3  8a11            BCF         PCLATH,#0x3
CODE:CODE:17b4  cf07            ADDWF       0x4f,f
CODE:CODE:17b5  0318            BTFSC       STATUS,#0x0
CODE:CODE:17b6  d00a            INCF        0x50,f
CODE:CODE:17b7  5008            MOVF        0x50,w
CODE:CODE:17b8  4f04            IORWF       0x4f,w
CODE:CODE:17b9  031d            BTFSS       STATUS,#0x2
CODE:CODE:17ba  cd2f            GOTO        offset LAB_CODE_17cd-0x1000
CODE:CODE:17bb  cf01            CLRF        0x4f
CODE:CODE:17bc  d001            CLRF        0x50
CODE:CODE:17bd  4726            CALL        offset Aline-0x1000                     ;undefined Aline()
CODE:CODE:17be  0a16            BSF         PCLATH,#0x4
CODE:CODE:17bf  8a11            BCF         PCLATH,#0x3
CODE:CODE:17c0  cf00            MOVWF       0x4f
CODE:CODE:17c1  d001            CLRF        0x50
CODE:CODE:17c2  a130            MOVLW       #0xa1
CODE:CODE:17c3  1b26            CALL        offset Alice-0x1000                     ;undefined Alice()
CODE:CODE:17c4  0a16            BSF         PCLATH,#0x4
CODE:CODE:17c5  8a11            BCF         PCLATH,#0x3
CODE:CODE:17c6  cf07            ADDWF       0x4f,f
CODE:CODE:17c7  0318            BTFSC       STATUS,#0x0
CODE:CODE:17c8  d00a            INCF        0x50,f
CODE:CODE:17c9  5008            MOVF        0x50,w
CODE:CODE:17ca  4f04            IORWF       0x4f,w
CODE:CODE:17cb  0319            BTFSC       STATUS,#0x2
CODE:CODE:17cc  d12f            GOTO        offset LAB_CODE_17d1-0x1000
                            LAB_CODE_17cd:                ;XREF[1,0]:   CODE:17ba
CODE:CODE:17cd  ff30            MOVLW       #0xff
CODE:CODE:17ce  8316            BSF         STATUS,RP0
CODE:CODE:17cf  a400            MOVWF       0x24
CODE:CODE:17d0  fe2f            GOTO        offset LAB_CODE_17fe-0x1000
                            LAB_CODE_17d1:                ;XREF[1,0]:   CODE:17cc
CODE:CODE:17d1  cf01            CLRF        BANK-0:DAT_DATA_004f                    ;= ??
CODE:CODE:17d2  d001            CLRF        0x50
                            LAB_CODE_17d3:                ;XREF[1,0]:   CODE:17f1
CODE:CODE:17d3  8316            BSF         STATUS,RP0
CODE:CODE:17d4  5a08            MOVF        0x5a,w
CODE:CODE:17d5  fa00            MOVWF       BANK-0:DAT_DATA_007a                    ;= ??
CODE:CODE:17d6  5908            MOVF        0x59,w
CODE:CODE:17d7  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:17d8  ff30            MOVLW       #0xff
CODE:CODE:17d9  f907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:17da  031c            BTFSS       STATUS,#0x0
CODE:CODE:17db  fa07            ADDWF       BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:17dc  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:17dd  8312            BCF         STATUS,RP0
CODE:CODE:17de  5002            SUBWF       0x50,w
CODE:CODE:17df  031d            BTFSS       STATUS,#0x2
CODE:CODE:17e0  e32f            GOTO        offset LAB_CODE_17e3-0x1000
CODE:CODE:17e1  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:17e2  4f02            SUBWF       0x4f,w
                            LAB_CODE_17e3:                ;XREF[1,0]:   CODE:17e0
CODE:CODE:17e3  0318            BTFSC       STATUS,#0x0
CODE:CODE:17e4  f22f            GOTO        offset LAB_CODE_17f2-0x1000
CODE:CODE:17e5  0130            MOVLW       #0x1
CODE:CODE:17e6  f525            CALL        offset Elsa-0x1000                      ;undefined Elsa()
CODE:CODE:17e7  0a16            BSF         PCLATH,#0x4
CODE:CODE:17e8  8a11            BCF         PCLATH,#0x3
CODE:CODE:17e9  8316            BSF         STATUS,RP0
CODE:CODE:17ea  d707            ADDWF       0x57,f
CODE:CODE:17eb  0318            BTFSC       STATUS,#0x0
CODE:CODE:17ec  d80a            INCF        0x58,f
CODE:CODE:17ed  8312            BCF         STATUS,RP0
CODE:CODE:17ee  cf0a            INCF        0x4f,f
CODE:CODE:17ef  0319            BTFSC       STATUS,#0x2
CODE:CODE:17f0  d00a            INCF        0x50,f
CODE:CODE:17f1  d32f            GOTO        offset LAB_CODE_17d3-0x1000
                            LAB_CODE_17f2:                ;XREF[1,0]:   CODE:17e4
CODE:CODE:17f2  0030            MOVLW       #0x0
CODE:CODE:17f3  f525            CALL        offset Elsa-0x1000                      ;undefined Elsa()
CODE:CODE:17f4  0a16            BSF         PCLATH,#0x4
CODE:CODE:17f5  8a11            BCF         PCLATH,#0x3
CODE:CODE:17f6  8316            BSF         STATUS,RP0
CODE:CODE:17f7  d707            ADDWF       0x57,f
CODE:CODE:17f8  0318            BTFSC       STATUS,#0x0
CODE:CODE:17f9  d80a            INCF        0x58,f
CODE:CODE:17fa  d226            CALL        offset Agathe-0x1000                    ;undefined Agathe()
CODE:CODE:17fb  0a16            BSF         PCLATH,#0x4
CODE:CODE:17fc  8a11            BCF         PCLATH,#0x3
CODE:CODE:17fd  df26            CALL        offset Anais-0x1000                     ;void Anais(void)
                            LAB_CODE_17fe:                ;XREF[1,0]:   CODE:17d0
CODE:CODE:17fe  8312            BCF         STATUS,RP0
CODE:CODE:17ff  0800            RETURN
CODE:CODE:1800  82              ??          82h
CODE:CODE:1800.107              ??          07h
CODE:CODE:1801  5034            RETLW       #0x50
CODE:CODE:1802  5234            RETLW       #0x52
CODE:CODE:1803  4534            RETLW       #0x45
CODE:CODE:1804  5334            RETLW       #0x53
CODE:CODE:1805  5334            RETLW       #0x53
CODE:CODE:1806  2034            RETLW       #0x20
CODE:CODE:1807  4534            RETLW       #0x45
CODE:CODE:1808  5334            RETLW       #0x53
CODE:CODE:1809  4334            RETLW       #0x43
CODE:CODE:180a  2034            RETLW       #0x20
CODE:CODE:180b  2b34            RETLW       #0x2b
CODE:CODE:180c  2034            RETLW       #0x20
CODE:CODE:180d  4f34            RETLW       #0x4f
CODE:CODE:180e  4b34            RETLW       #0x4b
CODE:CODE:180f  2034            RETLW       #0x20
CODE:CODE:1810  2034            RETLW       #0x20
CODE:CODE:1811  2034            RETLW       #0x20
CODE:CODE:1812  2034            RETLW       #0x20
CODE:CODE:1813  2034            RETLW       #0x20
CODE:CODE:1814  2034            RETLW       #0x20
CODE:CODE:1815  0034            RETLW       #0x0
CODE:CODE:1816  82              ??          82h
CODE:CODE:1816.107              ??          07h
CODE:CODE:1817  5534            RETLW       #0x55
CODE:CODE:1818  4134            RETLW       #0x41
CODE:CODE:1819  5234            RETLW       #0x52
CODE:CODE:181a  5434            RETLW       #0x54
CODE:CODE:181b  2034            RETLW       #0x20
CODE:CODE:181c  4d34            RETLW       #0x4d
CODE:CODE:181d  4f34            RETLW       #0x4f
CODE:CODE:181e  4434            RETLW       #0x44
CODE:CODE:181f  4534            RETLW       #0x45
CODE:CODE:1820  2034            RETLW       #0x20
CODE:CODE:1821  2034            RETLW       #0x20
CODE:CODE:1822  2034            RETLW       #0x20
CODE:CODE:1823  2034            RETLW       #0x20
CODE:CODE:1824  2034            RETLW       #0x20
CODE:CODE:1825  2034            RETLW       #0x20
CODE:CODE:1826  2034            RETLW       #0x20
CODE:CODE:1827  2034            RETLW       #0x20
CODE:CODE:1828  2034            RETLW       #0x20
CODE:CODE:1829  2034            RETLW       #0x20
CODE:CODE:182a  2034            RETLW       #0x20
CODE:CODE:182b  0034            RETLW       #0x0
CODE:CODE:182c  82              ??          82h
CODE:CODE:182c.107              ??          07h
CODE:CODE:182d  4d34            RETLW       #0x4d
CODE:CODE:182e  4f34            RETLW       #0x4f
CODE:CODE:182f  5434            RETLW       #0x54
CODE:CODE:1830  4f34            RETLW       #0x4f
CODE:CODE:1831  5234            RETLW       #0x52
CODE:CODE:1832  2034            RETLW       #0x20
CODE:CODE:1833  5534            RETLW       #0x55
CODE:CODE:1834  5034            RETLW       #0x50
CODE:CODE:1835  2034            RETLW       #0x20
CODE:CODE:1836  2034            RETLW       #0x20
CODE:CODE:1837  2034            RETLW       #0x20
CODE:CODE:1838  2034            RETLW       #0x20
CODE:CODE:1839  2034            RETLW       #0x20
CODE:CODE:183a  2034            RETLW       #0x20
CODE:CODE:183b  2034            RETLW       #0x20
CODE:CODE:183c  2034            RETLW       #0x20
CODE:CODE:183d  2034            RETLW       #0x20
CODE:CODE:183e  2034            RETLW       #0x20
CODE:CODE:183f  2034            RETLW       #0x20
CODE:CODE:1840  2034            RETLW       #0x20
CODE:CODE:1841  0034            RETLW       #0x0
CODE:CODE:1842  82              ??          82h
CODE:CODE:1842.107              ??          07h
CODE:CODE:1843  2034            RETLW       #0x20
CODE:CODE:1844  2034            RETLW       #0x20
CODE:CODE:1845  2034            RETLW       #0x20
CODE:CODE:1846  2034            RETLW       #0x20
CODE:CODE:1847  2034            RETLW       #0x20
CODE:CODE:1848  2034            RETLW       #0x20
CODE:CODE:1849  2034            RETLW       #0x20
CODE:CODE:184a  2034            RETLW       #0x20
CODE:CODE:184b  2034            RETLW       #0x20
CODE:CODE:184c  2034            RETLW       #0x20
CODE:CODE:184d  2034            RETLW       #0x20
CODE:CODE:184e  2034            RETLW       #0x20
CODE:CODE:184f  2034            RETLW       #0x20
CODE:CODE:1850  2034            RETLW       #0x20
CODE:CODE:1851  2034            RETLW       #0x20
CODE:CODE:1852  2034            RETLW       #0x20
CODE:CODE:1853  2034            RETLW       #0x20
CODE:CODE:1854  2034            RETLW       #0x20
CODE:CODE:1855  2034            RETLW       #0x20
CODE:CODE:1856  2034            RETLW       #0x20
CODE:CODE:1857  0034            RETLW       #0x0
CODE:CODE:1858  82              ??          82h
CODE:CODE:1858.107              ??          07h
CODE:CODE:1859  4534            RETLW       #0x45
CODE:CODE:185a  5634            RETLW       #0x56
CODE:CODE:185b  3134            RETLW       #0x31
CODE:CODE:185c  2034            RETLW       #0x20
CODE:CODE:185d  4f34            RETLW       #0x4f
CODE:CODE:185e  4e34            RETLW       #0x4e
CODE:CODE:185f  2034            RETLW       #0x20
CODE:CODE:1860  2034            RETLW       #0x20
CODE:CODE:1861  2034            RETLW       #0x20
CODE:CODE:1862  2034            RETLW       #0x20
CODE:CODE:1863  2034            RETLW       #0x20
CODE:CODE:1864  2034            RETLW       #0x20
CODE:CODE:1865  2034            RETLW       #0x20
CODE:CODE:1866  2034            RETLW       #0x20
CODE:CODE:1867  2034            RETLW       #0x20
CODE:CODE:1868  2034            RETLW       #0x20
CODE:CODE:1869  2034            RETLW       #0x20
CODE:CODE:186a  2034            RETLW       #0x20
CODE:CODE:186b  2034            RETLW       #0x20
CODE:CODE:186c  2034            RETLW       #0x20
CODE:CODE:186d  0034            RETLW       #0x0
CODE:CODE:186e  82              ??          82h
CODE:CODE:186e.107              ??          07h
CODE:CODE:186f  4534            RETLW       #0x45
CODE:CODE:1870  5634            RETLW       #0x56
CODE:CODE:1871  3234            RETLW       #0x32
CODE:CODE:1872  2034            RETLW       #0x20
CODE:CODE:1873  4f34            RETLW       #0x4f
CODE:CODE:1874  4e34            RETLW       #0x4e
CODE:CODE:1875  2034            RETLW       #0x20
CODE:CODE:1876  2034            RETLW       #0x20
CODE:CODE:1877  2034            RETLW       #0x20
CODE:CODE:1878  2034            RETLW       #0x20
CODE:CODE:1879  2034            RETLW       #0x20
CODE:CODE:187a  2034            RETLW       #0x20
CODE:CODE:187b  2034            RETLW       #0x20
CODE:CODE:187c  2034            RETLW       #0x20
CODE:CODE:187d  2034            RETLW       #0x20
CODE:CODE:187e  2034            RETLW       #0x20
CODE:CODE:187f  2034            RETLW       #0x20
CODE:CODE:1880  2034            RETLW       #0x20
CODE:CODE:1881  2034            RETLW       #0x20
CODE:CODE:1882  2034            RETLW       #0x20
CODE:CODE:1883  0034            RETLW       #0x0
CODE:CODE:1884  82              ??          82h
CODE:CODE:1884.107              ??          07h
CODE:CODE:1885  4734            RETLW       #0x47
CODE:CODE:1886  5234            RETLW       #0x52
CODE:CODE:1887  4934            RETLW       #0x49
CODE:CODE:1888  4e34            RETLW       #0x4e
CODE:CODE:1889  4434            RETLW       #0x44
CODE:CODE:188a  4534            RETLW       #0x45
CODE:CODE:188b  5234            RETLW       #0x52
CODE:CODE:188c  2034            RETLW       #0x20
CODE:CODE:188d  4f34            RETLW       #0x4f
CODE:CODE:188e  4e34            RETLW       #0x4e
CODE:CODE:188f  2034            RETLW       #0x20
CODE:CODE:1890  2034            RETLW       #0x20
CODE:CODE:1891  2034            RETLW       #0x20
CODE:CODE:1892  2034            RETLW       #0x20
CODE:CODE:1893  2034            RETLW       #0x20
CODE:CODE:1894  2034            RETLW       #0x20
CODE:CODE:1895  2034            RETLW       #0x20
CODE:CODE:1896  2034            RETLW       #0x20
CODE:CODE:1897  2034            RETLW       #0x20
CODE:CODE:1898  2034            RETLW       #0x20
CODE:CODE:1899  0034            RETLW       #0x0
CODE:CODE:189a  82              ??          82h
CODE:CODE:189a.107              ??          07h
CODE:CODE:189b  4834            RETLW       #0x48
CODE:CODE:189c  4534            RETLW       #0x45
CODE:CODE:189d  4134            RETLW       #0x41
CODE:CODE:189e  5434            RETLW       #0x54
CODE:CODE:189f  4534            RETLW       #0x45
CODE:CODE:18a0  5234            RETLW       #0x52
CODE:CODE:18a1  2034            RETLW       #0x20
CODE:CODE:18a2  4f34            RETLW       #0x4f
CODE:CODE:18a3  4e34            RETLW       #0x4e
CODE:CODE:18a4  2034            RETLW       #0x20
CODE:CODE:18a5  2034            RETLW       #0x20
CODE:CODE:18a6  2034            RETLW       #0x20
CODE:CODE:18a7  2034            RETLW       #0x20
CODE:CODE:18a8  2034            RETLW       #0x20
CODE:CODE:18a9  2034            RETLW       #0x20
CODE:CODE:18aa  2034            RETLW       #0x20
CODE:CODE:18ab  2034            RETLW       #0x20
CODE:CODE:18ac  2034            RETLW       #0x20
CODE:CODE:18ad  2034            RETLW       #0x20
CODE:CODE:18ae  2034            RETLW       #0x20
CODE:CODE:18af  0034            RETLW       #0x0
CODE:CODE:18b0  82              ??          82h
CODE:CODE:18b0.107              ??          07h
CODE:CODE:18b1  4534            RETLW       #0x45
CODE:CODE:18b2  4c34            RETLW       #0x4c
CODE:CODE:18b3  4534            RETLW       #0x45
CODE:CODE:18b4  4334            RETLW       #0x43
CODE:CODE:18b5  5434            RETLW       #0x54
CODE:CODE:18b6  5234            RETLW       #0x52
CODE:CODE:18b7  4934            RETLW       #0x49
CODE:CODE:18b8  4334            RETLW       #0x43
CODE:CODE:18b9  2034            RETLW       #0x20
CODE:CODE:18ba  5434            RETLW       #0x54
CODE:CODE:18bb  4534            RETLW       #0x45
CODE:CODE:18bc  5334            RETLW       #0x53
CODE:CODE:18bd  5434            RETLW       #0x54
CODE:CODE:18be  2034            RETLW       #0x20
CODE:CODE:18bf  4d34            RETLW       #0x4d
CODE:CODE:18c0  4f34            RETLW       #0x4f
CODE:CODE:18c1  4434            RETLW       #0x44
CODE:CODE:18c2  4534            RETLW       #0x45
CODE:CODE:18c3  2034            RETLW       #0x20
CODE:CODE:18c4  2034            RETLW       #0x20
CODE:CODE:18c5  0034            RETLW       #0x0
CODE:CODE:18c6  82              ??          82h
CODE:CODE:18c6.107              ??          07h
CODE:CODE:18c7  5034            RETLW       #0x50
CODE:CODE:18c8  5534            RETLW       #0x55
CODE:CODE:18c9  4d34            RETLW       #0x4d
CODE:CODE:18ca  5034            RETLW       #0x50
CODE:CODE:18cb  2034            RETLW       #0x20
CODE:CODE:18cc  4f34            RETLW       #0x4f
CODE:CODE:18cd  4e34            RETLW       #0x4e
CODE:CODE:18ce  2034            RETLW       #0x20
CODE:CODE:18cf  2034            RETLW       #0x20
CODE:CODE:18d0  2034            RETLW       #0x20
CODE:CODE:18d1  2034            RETLW       #0x20
CODE:CODE:18d2  2034            RETLW       #0x20
CODE:CODE:18d3  2034            RETLW       #0x20
CODE:CODE:18d4  2034            RETLW       #0x20
CODE:CODE:18d5  2034            RETLW       #0x20
CODE:CODE:18d6  2034            RETLW       #0x20
CODE:CODE:18d7  2034            RETLW       #0x20
CODE:CODE:18d8  2034            RETLW       #0x20
CODE:CODE:18d9  2034            RETLW       #0x20
CODE:CODE:18da  2034            RETLW       #0x20
CODE:CODE:18db  0034            RETLW       #0x0
CODE:CODE:18dc  82              ??          82h
CODE:CODE:18dc.107              ??          07h
CODE:CODE:18dd  5634            RETLW       #0x56
CODE:CODE:18de  4134            RETLW       #0x41
CODE:CODE:18df  5034            RETLW       #0x50
CODE:CODE:18e0  4f34            RETLW       #0x4f
CODE:CODE:18e1  5234            RETLW       #0x52
CODE:CODE:18e2  4934            RETLW       #0x49
CODE:CODE:18e3  5a34            RETLW       #0x5a
CODE:CODE:18e4  4534            RETLW       #0x45
CODE:CODE:18e5  5234            RETLW       #0x52
CODE:CODE:18e6  2034            RETLW       #0x20
CODE:CODE:18e7  4f34            RETLW       #0x4f
CODE:CODE:18e8  4e34            RETLW       #0x4e
CODE:CODE:18e9  2034            RETLW       #0x20
CODE:CODE:18ea  2034            RETLW       #0x20
CODE:CODE:18eb  2034            RETLW       #0x20
CODE:CODE:18ec  2034            RETLW       #0x20
CODE:CODE:18ed  2034            RETLW       #0x20
CODE:CODE:18ee  2034            RETLW       #0x20
CODE:CODE:18ef  2034            RETLW       #0x20
CODE:CODE:18f0  2034            RETLW       #0x20
CODE:CODE:18f1  0034            RETLW       #0x0
CODE:CODE:18f2  82              ??          82h
CODE:CODE:18f2.107              ??          07h
CODE:CODE:18f3  0e34            RETLW       #0xe
CODE:CODE:18f4  0034            RETLW       #0x0
CODE:CODE:18f5  1134            RETLW       #0x11
CODE:CODE:18f6  1134            RETLW       #0x11
CODE:CODE:18f7  1134            RETLW       #0x11
CODE:CODE:18f8  1334            RETLW       #0x13
CODE:CODE:18f9  0d34            RETLW       #0xd
CODE:CODE:18fa  0034            RETLW       #0x0
CODE:CODE:18fb  ff3fff3ff...    db[10]
   |_CODE:CODE:18fb  [0]             db          FFh
   |_CODE:CODE:18fb.1[1]             db          3Fh
   |_CODE:CODE:18fc  [2]             db          FFh
   |_CODE:CODE:18fc.1[3]             db          3Fh
   |_CODE:CODE:18fd  [4]             db          FFh
   |_CODE:CODE:18fd.1[5]             db          3Fh
   |_CODE:CODE:18fe  [6]             db          FFh
   |_CODE:CODE:18fe.1[7]             db          3Fh
   |_CODE:CODE:18ff  [8]             db          FFh
   |_CODE:CODE:18ff.1[9]             db          3Fh
CODE:CODE:1900  82              ??          82h
CODE:CODE:1900.107              ??          07h
CODE:CODE:1901  4d34            RETLW       #0x4d
CODE:CODE:1902  4f34            RETLW       #0x4f
CODE:CODE:1903  5434            RETLW       #0x54
CODE:CODE:1904  4f34            RETLW       #0x4f
CODE:CODE:1905  5234            RETLW       #0x52
CODE:CODE:1906  2034            RETLW       #0x20
CODE:CODE:1907  4434            RETLW       #0x44
CODE:CODE:1908  4f34            RETLW       #0x4f
CODE:CODE:1909  5734            RETLW       #0x57
CODE:CODE:190a  4e34            RETLW       #0x4e
CODE:CODE:190b  2034            RETLW       #0x20
CODE:CODE:190c  2034            RETLW       #0x20
CODE:CODE:190d  2034            RETLW       #0x20
CODE:CODE:190e  2034            RETLW       #0x20
CODE:CODE:190f  2034            RETLW       #0x20
CODE:CODE:1910  2034            RETLW       #0x20
CODE:CODE:1911  2034            RETLW       #0x20
CODE:CODE:1912  2034            RETLW       #0x20
CODE:CODE:1913  2034            RETLW       #0x20
CODE:CODE:1914  2034            RETLW       #0x20
CODE:CODE:1915  0034            RETLW       #0x0
CODE:CODE:1916  82              ??          82h
CODE:CODE:1916.107              ??          07h
CODE:CODE:1917  4c34            RETLW       #0x4c
CODE:CODE:1918  4f34            RETLW       #0x4f
CODE:CODE:1919  4134            RETLW       #0x41
CODE:CODE:191a  4434            RETLW       #0x44
CODE:CODE:191b  2034            RETLW       #0x20
CODE:CODE:191c  5434            RETLW       #0x54
CODE:CODE:191d  4534            RETLW       #0x45
CODE:CODE:191e  5334            RETLW       #0x53
CODE:CODE:191f  5434            RETLW       #0x54
CODE:CODE:1920  2034            RETLW       #0x20
CODE:CODE:1921  4d34            RETLW       #0x4d
CODE:CODE:1922  4f34            RETLW       #0x4f
CODE:CODE:1923  4434            RETLW       #0x44
CODE:CODE:1924  4534            RETLW       #0x45
CODE:CODE:1925  2034            RETLW       #0x20
CODE:CODE:1926  2034            RETLW       #0x20
CODE:CODE:1927  2034            RETLW       #0x20
CODE:CODE:1928  2034            RETLW       #0x20
CODE:CODE:1929  2034            RETLW       #0x20
CODE:CODE:192a  2034            RETLW       #0x20
CODE:CODE:192b  0034            RETLW       #0x0
CODE:CODE:192c  82              ??          82h
CODE:CODE:192c.107              ??          07h
CODE:CODE:192d  4434            RETLW       #0x44
CODE:CODE:192e  4934            RETLW       #0x49
CODE:CODE:192f  5334            RETLW       #0x53
CODE:CODE:1930  5034            RETLW       #0x50
CODE:CODE:1931  4c34            RETLW       #0x4c
CODE:CODE:1932  4134            RETLW       #0x41
CODE:CODE:1933  5934            RETLW       #0x59
CODE:CODE:1934  2034            RETLW       #0x20
CODE:CODE:1935  5434            RETLW       #0x54
CODE:CODE:1936  4534            RETLW       #0x45
CODE:CODE:1937  5334            RETLW       #0x53
CODE:CODE:1938  5434            RETLW       #0x54
CODE:CODE:1939  2034            RETLW       #0x20
CODE:CODE:193a  4d34            RETLW       #0x4d
CODE:CODE:193b  4f34            RETLW       #0x4f
CODE:CODE:193c  4434            RETLW       #0x44
CODE:CODE:193d  4534            RETLW       #0x45
CODE:CODE:193e  2034            RETLW       #0x20
CODE:CODE:193f  2034            RETLW       #0x20
CODE:CODE:1940  2034            RETLW       #0x20
CODE:CODE:1941  0034            RETLW       #0x0
CODE:CODE:1942  82              ??          82h
CODE:CODE:1942.107              ??          07h
CODE:CODE:1943  4234            RETLW       #0x42
CODE:CODE:1944  5534            RETLW       #0x55
CODE:CODE:1945  5434            RETLW       #0x54
CODE:CODE:1946  5434            RETLW       #0x54
CODE:CODE:1947  4f34            RETLW       #0x4f
CODE:CODE:1948  4e34            RETLW       #0x4e
CODE:CODE:1949  2034            RETLW       #0x20
CODE:CODE:194a  2034            RETLW       #0x20
CODE:CODE:194b  2034            RETLW       #0x20
CODE:CODE:194c  2034            RETLW       #0x20
CODE:CODE:194d  2034            RETLW       #0x20
CODE:CODE:194e  2034            RETLW       #0x20
CODE:CODE:194f  2034            RETLW       #0x20
CODE:CODE:1950  2034            RETLW       #0x20
CODE:CODE:1951  2034            RETLW       #0x20
CODE:CODE:1952  2034            RETLW       #0x20
CODE:CODE:1953  2034            RETLW       #0x20
CODE:CODE:1954  2034            RETLW       #0x20
CODE:CODE:1955  2034            RETLW       #0x20
CODE:CODE:1956  2034            RETLW       #0x20
CODE:CODE:1957  0034            RETLW       #0x0
CODE:CODE:1958  82              ??          82h
CODE:CODE:1958.107              ??          07h
CODE:CODE:1959  4c34            RETLW       #0x4c
CODE:CODE:195a  4934            RETLW       #0x49
CODE:CODE:195b  4d34            RETLW       #0x4d
CODE:CODE:195c  4934            RETLW       #0x49
CODE:CODE:195d  5434            RETLW       #0x54
CODE:CODE:195e  2034            RETLW       #0x20
CODE:CODE:195f  5334            RETLW       #0x53
CODE:CODE:1960  5734            RETLW       #0x57
CODE:CODE:1961  4934            RETLW       #0x49
CODE:CODE:1962  5434            RETLW       #0x54
CODE:CODE:1963  4334            RETLW       #0x43
CODE:CODE:1964  4834            RETLW       #0x48
CODE:CODE:1965  2034            RETLW       #0x20
CODE:CODE:1966  4434            RETLW       #0x44
CODE:CODE:1967  4f34            RETLW       #0x4f
CODE:CODE:1968  5734            RETLW       #0x57
CODE:CODE:1969  4e34            RETLW       #0x4e
CODE:CODE:196a  2034            RETLW       #0x20
CODE:CODE:196b  2034            RETLW       #0x20
CODE:CODE:196c  2034            RETLW       #0x20
CODE:CODE:196d  0034            RETLW       #0x0
CODE:CODE:196e  82              ??          82h
CODE:CODE:196e.107              ??          07h
CODE:CODE:196f  2034            RETLW       #0x20
CODE:CODE:1970  2034            RETLW       #0x20
CODE:CODE:1971  2034            RETLW       #0x20
CODE:CODE:1972  2034            RETLW       #0x20
CODE:CODE:1973  2034            RETLW       #0x20
CODE:CODE:1974  2034            RETLW       #0x20
CODE:CODE:1975  2034            RETLW       #0x20
CODE:CODE:1976  2034            RETLW       #0x20
CODE:CODE:1977  2034            RETLW       #0x20
CODE:CODE:1978  2034            RETLW       #0x20
CODE:CODE:1979  2034            RETLW       #0x20
CODE:CODE:197a  2034            RETLW       #0x20
CODE:CODE:197b  2034            RETLW       #0x20
CODE:CODE:197c  2034            RETLW       #0x20
CODE:CODE:197d  2034            RETLW       #0x20
CODE:CODE:197e  2034            RETLW       #0x20
CODE:CODE:197f  2034            RETLW       #0x20
CODE:CODE:1980  2034            RETLW       #0x20
CODE:CODE:1981  2034            RETLW       #0x20
CODE:CODE:1982  2034            RETLW       #0x20
CODE:CODE:1983  0034            RETLW       #0x0
CODE:CODE:1984  82              ??          82h
CODE:CODE:1984.107              ??          07h
CODE:CODE:1985  4c34            RETLW       #0x4c
CODE:CODE:1986  4934            RETLW       #0x49
CODE:CODE:1987  4d34            RETLW       #0x4d
CODE:CODE:1988  4934            RETLW       #0x49
CODE:CODE:1989  5434            RETLW       #0x54
CODE:CODE:198a  2034            RETLW       #0x20
CODE:CODE:198b  5334            RETLW       #0x53
CODE:CODE:198c  5734            RETLW       #0x57
CODE:CODE:198d  4934            RETLW       #0x49
CODE:CODE:198e  5434            RETLW       #0x54
CODE:CODE:198f  4334            RETLW       #0x43
CODE:CODE:1990  4834            RETLW       #0x48
CODE:CODE:1991  2034            RETLW       #0x20
CODE:CODE:1992  5534            RETLW       #0x55
CODE:CODE:1993  5034            RETLW       #0x50
CODE:CODE:1994  2034            RETLW       #0x20
CODE:CODE:1995  2034            RETLW       #0x20
CODE:CODE:1996  2034            RETLW       #0x20
CODE:CODE:1997  2034            RETLW       #0x20
CODE:CODE:1998  2034            RETLW       #0x20
CODE:CODE:1999  0034            RETLW       #0x0
CODE:CODE:199a  82              ??          82h
CODE:CODE:199a.107              ??          07h
CODE:CODE:199b  ff34            RETLW       #0xff
CODE:CODE:199c  ff34            RETLW       #0xff
CODE:CODE:199d  ff34            RETLW       #0xff
CODE:CODE:199e  ff34            RETLW       #0xff
CODE:CODE:199f  ff34            RETLW       #0xff
CODE:CODE:19a0  ff34            RETLW       #0xff
CODE:CODE:19a1  ff34            RETLW       #0xff
CODE:CODE:19a2  ff34            RETLW       #0xff
CODE:CODE:19a3  ff34            RETLW       #0xff
CODE:CODE:19a4  ff34            RETLW       #0xff
CODE:CODE:19a5  ff34            RETLW       #0xff
CODE:CODE:19a6  ff34            RETLW       #0xff
CODE:CODE:19a7  ff34            RETLW       #0xff
CODE:CODE:19a8  ff34            RETLW       #0xff
CODE:CODE:19a9  ff34            RETLW       #0xff
CODE:CODE:19aa  ff34            RETLW       #0xff
CODE:CODE:19ab  ff34            RETLW       #0xff
CODE:CODE:19ac  ff34            RETLW       #0xff
CODE:CODE:19ad  ff34            RETLW       #0xff
CODE:CODE:19ae  ff34            RETLW       #0xff
CODE:CODE:19af  82              ??          82h
CODE:CODE:19af.107              ??          07h
CODE:CODE:19b0  0034            RETLW       #0x0
CODE:CODE:19b1  0034            RETLW       #0x0
CODE:CODE:19b2  0034            RETLW       #0x0
CODE:CODE:19b3  0034            RETLW       #0x0
CODE:CODE:19b4  0034            RETLW       #0x0
CODE:CODE:19b5  0034            RETLW       #0x0
CODE:CODE:19b6  0034            RETLW       #0x0
CODE:CODE:19b7  0034            RETLW       #0x0
CODE:CODE:19b8  0034            RETLW       #0x0
CODE:CODE:19b9  0034            RETLW       #0x0
CODE:CODE:19ba  0034            RETLW       #0x0
CODE:CODE:19bb  0034            RETLW       #0x0
CODE:CODE:19bc  0034            RETLW       #0x0
CODE:CODE:19bd  0034            RETLW       #0x0
CODE:CODE:19be  0034            RETLW       #0x0
CODE:CODE:19bf  0034            RETLW       #0x0
CODE:CODE:19c0  0034            RETLW       #0x0
CODE:CODE:19c1  0034            RETLW       #0x0
CODE:CODE:19c2  0034            RETLW       #0x0
CODE:CODE:19c3  0034            RETLW       #0x0
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined interrupt_handler_usart_tx()
          ;tmp_PIR1      undefined1     HASH...
                                                          ;XREF[1,0]:   CODE:0050
CODE:CODE:19c4  8316            BSF         STATUS,RP0
CODE:CODE:19c5  0313            BCF         STATUS,RP1
CODE:CODE:19c6  4508            MOVF        BANK-1:USART_TX_PACKET_SIZE,w           ;= ??
CODE:CODE:19c7  4402            SUBWF       BANK-1:USART_TX_BUFFER_INDEX,w          ;= ??
CODE:CODE:19c8  0318            BTFSC       STATUS,#0x0
CODE:CODE:19c9  d429            GOTO        offset LAB_CODE_19d4-0x1800
CODE:CODE:19ca  4408            MOVF        BANK-1:USART_TX_BUFFER_INDEX,w          ;= ??
CODE:CODE:19cb  573e            ADDLW       #0x57
CODE:CODE:19cc  8400            MOVWF       FSR0L
CODE:CODE:19cd  8317            BSF         STATUS,IRP
CODE:CODE:19ce  0008            MOVF        INDF0=>BANK-2:USART_PACKET_BUFFER,w     ;= ??
CODE:CODE:19cf  8312            BCF         STATUS,RP0
CODE:CODE:19d0  9900            MOVWF       BANK-0:TXREG                            ;= ??
CODE:CODE:19d1  8316            BSF         STATUS,RP0
CODE:CODE:19d2  c40a            INCF        BANK-1:USART_TX_BUFFER_INDEX,f          ;= ??
CODE:CODE:19d3  d729            GOTO        offset LAB_CODE_19d7-0x1800
                            ;Clear the interrupt flag
                            LAB_CODE_19d4:                ;XREF[1,0]:   CODE:19c9
CODE:CODE:19d4  0c12            BCF         BANK-0:PIR1,#0x4                        ;= ??
CODE:CODE:19d5  0230            MOVLW       #0x2
                            ;I don't know what this is yet
CODE:CODE:19d6  c000            MOVWF       BANK-1:USART_TX_UNKNOWN                 ;= ??
                            LAB_CODE_19d7:                ;XREF[1,0]:   CODE:19d3
CODE:CODE:19d7  8312            BCF         STATUS,RP0
CODE:CODE:19d8  0800            RETURN
CODE:CODE:19d9  82              ??          82h
CODE:CODE:19d9.107              ??          07h
CODE:CODE:19da  1734            RETLW       #0x17
CODE:CODE:19db  1734            RETLW       #0x17
CODE:CODE:19dc  1734            RETLW       #0x17
CODE:CODE:19dd  1734            RETLW       #0x17
CODE:CODE:19de  1734            RETLW       #0x17
CODE:CODE:19df  1734            RETLW       #0x17
CODE:CODE:19e0  1734            RETLW       #0x17
CODE:CODE:19e1  1734            RETLW       #0x17
CODE:CODE:19e2  1734            RETLW       #0x17
CODE:CODE:19e3  1734            RETLW       #0x17
CODE:CODE:19e4  1734            RETLW       #0x17
CODE:CODE:19e5  1734            RETLW       #0x17
CODE:CODE:19e6  1734            RETLW       #0x17
CODE:CODE:19e7  1734            RETLW       #0x17
CODE:CODE:19e8  1734            RETLW       #0x17
CODE:CODE:19e9  1734            RETLW       #0x17
CODE:CODE:19ea  1734            RETLW       #0x17
CODE:CODE:19eb  1734            RETLW       #0x17
CODE:CODE:19ec  1734            RETLW       #0x17
CODE:CODE:19ed  1734            RETLW       #0x17
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Estelle()
                                                          ;XREF[4,0]:   CODE:1225,CODE:1236,CODE:13f5,CODE:1406
CODE:CODE:19ee  fd01            CLRF        BANK-0:DAT_DATA_007d                    ;= ??
CODE:CODE:19ef  fe01            CLRF        BANK-0:DAT_DATA_007e                    ;= ??
                            LAB_CODE_19f0:                ;XREF[1,0]:   CODE:1a02
CODE:CODE:19f0  0310            BCF         STATUS,C
CODE:CODE:19f1  fc0c            RRF         BANK-0:DAT_DATA_007c,f                  ;= ??
CODE:CODE:19f2  fb0c            RRF         BANK-0:DAT_DATA_007b,f                  ;= ??
CODE:CODE:19f3  031c            BTFSS       STATUS,#0x0
CODE:CODE:19f4  fc29            GOTO        offset LAB_CODE_19fc-0x1800
CODE:CODE:19f5  7908            MOVF        BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:19f6  fd07            ADDWF       BANK-0:DAT_DATA_007d,f                  ;= ??
CODE:CODE:19f7  7a08            MOVF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:19f8  0318            BTFSC       STATUS,#0x0
CODE:CODE:19f9  7a0a            INCF        BANK-0:DAT_DATA_007a,w                  ;= ??
CODE:CODE:19fa  fe07            ADDWF       BANK-0:DAT_DATA_007e,f                  ;= ??
CODE:CODE:19fb  0310            BCF         STATUS,C
                            LAB_CODE_19fc:                ;XREF[1,0]:   CODE:19f4
CODE:CODE:19fc  f90d            RLF         BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:19fd  fa0d            RLF         BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:19fe  7b08            MOVF        BANK-0:DAT_DATA_007b,w                  ;= ??
CODE:CODE:19ff  7c04            IORWF       BANK-0:DAT_DATA_007c,w                  ;= ??
CODE:CODE:1a00  0319            BTFSC       STATUS,#0x2
CODE:CODE:1a01  0034            RETLW       #0x0
CODE:CODE:1a02  f029            GOTO        offset LAB_CODE_19f0-0x1800
                            UNKNOWN_DATA_2:
CODE:CODE:1a03  83              ??          83h
CODE:CODE:1a03.101              ??          01h
CODE:CODE:1a04  4b              ??          4Bh    K
CODE:CODE:1a04.108              ??          08h
CODE:CODE:1a05  ca              ??          CAh
CODE:CODE:1a05.100              ??          00h
CODE:CODE:1a06  0d              ??          0Dh
CODE:CODE:1a06.12a              ??          2Ah    *
CODE:CODE:1a07  ca              ??          CAh
CODE:CODE:1a07.103              ??          03h
CODE:CODE:1a08  f6              ??          F6h
CODE:CODE:1a08.130              ??          30h    0
CODE:CODE:1a09  cb              ??          CBh
CODE:CODE:1a09.100              ??          00h
CODE:CODE:1a0a  cb              ??          CBh
CODE:CODE:1a0a.10b              ??          0Bh
CODE:CODE:1a0b  0a              ??          0Ah
CODE:CODE:1a0b.12a              ??          2Ah    *
CODE:CODE:1a0c  64              ??          64h    d
CODE:CODE:1a0c.100              ??          00h
CODE:CODE:1a0d  01              ??          01h
CODE:CODE:1a0d.130              ??          30h    0
CODE:CODE:1a0e  4a              ??          4Ah    J
CODE:CODE:1a0e.102              ??          02h
CODE:CODE:1a0f  03              ??          03h
CODE:CODE:1a0f.118              ??          18h
CODE:CODE:1a10  07              ??          07h
CODE:CODE:1a10.12a              ??          2Ah    *
CODE:CODE:1a11  4a              ??          4Ah    J
CODE:CODE:1a11.108              ??          08h
CODE:CODE:1a12  cb              ??          CBh
CODE:CODE:1a12.100              ??          00h
CODE:CODE:1a13  cb              ??          CBh
CODE:CODE:1a13.10b              ??          0Bh
CODE:CODE:1a14  13              ??          13h
CODE:CODE:1a14.12a              ??          2Ah    *
CODE:CODE:1a15  08              ??          08h
CODE:CODE:1a15.100              ??          00h
CODE:CODE:1a16  04              ??          04h
CODE:CODE:1a16.130              ??          30h    0
CODE:CODE:1a17  83              ??          83h
CODE:CODE:1a17.101              ??          01h
CODE:CODE:1a18  ca              ??          CAh
CODE:CODE:1a18.100              ??          00h
CODE:CODE:1a19  fa              ??          FAh
CODE:CODE:1a19.130              ??          30h    0
CODE:CODE:1a1a  cb              ??          CBh
CODE:CODE:1a1a.100              ??          00h
CODE:CODE:1a1b  cb              ??          CBh
CODE:CODE:1a1b.10b              ??          0Bh
CODE:CODE:1a1c  1b              ??          1Bh
CODE:CODE:1a1c.12a              ??          2Ah    *
CODE:CODE:1a1d  64              ??          64h    d
CODE:CODE:1a1d.100              ??          00h
CODE:CODE:1a1e  ca              ??          CAh
CODE:CODE:1a1e.10b              ??          0Bh
CODE:CODE:1a1f  19              ??          19h
CODE:CODE:1a1f.12a              ??          2Ah    *
CODE:CODE:1a20  ff              ??          FFh
CODE:CODE:1a20.130              ??          30h    0
CODE:CODE:1a21  ca              ??          CAh
CODE:CODE:1a21.107              ??          07h
CODE:CODE:1a22  03              ??          03h
CODE:CODE:1a22.11c              ??          1Ch
CODE:CODE:1a23  cb              ??          CBh
CODE:CODE:1a23.103              ??          03h
CODE:CODE:1a24  4b              ??          4Bh    K
CODE:CODE:1a24.108              ??          08h
CODE:CODE:1a25  4a              ??          4Ah    J
CODE:CODE:1a25.104              ??          04h
CODE:CODE:1a26  03              ??          03h
CODE:CODE:1a26.119              ??          19h
CODE:CODE:1a27  08              ??          08h
CODE:CODE:1a27.100              ??          00h
CODE:CODE:1a28  16              ??          16h
CODE:CODE:1a28.12a              ??          2Ah    *
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined Eloane()
          ;cVar1         byte                 W
                                                          ;XREF[1,0]:   CODE:14db
CODE:CODE:1a29  f900            MOVWF       BANK-0:ENTRY_SUB2_UNK1                  ;= ??
CODE:CODE:1a2a  0030            MOVLW       #0x0
                            LAB_CODE_1a2b:                ;XREF[1,0]:   CODE:1a34
CODE:CODE:1a2b  7a18            BTFSC       BANK-0:DAT_DATA_007a,#0x0               ;= ??
CODE:CODE:1a2c  7907            ADDWF       BANK-0:ENTRY_SUB2_UNK1,w                ;= ??
CODE:CODE:1a2d  0310            BCF         STATUS,C
CODE:CODE:1a2e  f90d            RLF         BANK-0:ENTRY_SUB2_UNK1,f                ;= ??
CODE:CODE:1a2f  0310            BCF         STATUS,C
CODE:CODE:1a30  fa0c            RRF         BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1a31  fa08            MOVF        BANK-0:DAT_DATA_007a,f                  ;= ??
CODE:CODE:1a32  0319            BTFSC       STATUS,#0x2
CODE:CODE:1a33  0800            RETURN
CODE:CODE:1a34  2b2a            GOTO        offset LAB_CODE_1a2b-0x1800
                            CONST_LCD_UNKNOWN1:
CODE:CODE:1a35  82              ??          82h
CODE:CODE:1a35.107              ??          07h
CODE:CODE:1a36  1f34            RETLW       #0x1f
CODE:CODE:1a37  1f34            RETLW       #0x1f
CODE:CODE:1a38  1f34            RETLW       #0x1f
CODE:CODE:1a39  1f34            RETLW       #0x1f
CODE:CODE:1a3a  0034            RETLW       #0x0
CODE:CODE:1a3b  0034            RETLW       #0x0
CODE:CODE:1a3c  0034            RETLW       #0x0
CODE:CODE:1a3d  0034            RETLW       #0x0
CODE:CODE:1a3e  82              ??          82h
CODE:CODE:1a3e.107              ??          07h
CODE:CODE:1a3f  0434            RETLW       #0x4
CODE:CODE:1a40  0434            RETLW       #0x4
CODE:CODE:1a41  0434            RETLW       #0x4
CODE:CODE:1a42  0634            RETLW       #0x6
CODE:CODE:1a43  0c34            RETLW       #0xc
CODE:CODE:1a44  0434            RETLW       #0x4
CODE:CODE:1a45  0434            RETLW       #0x4
CODE:CODE:1a46  0034            RETLW       #0x0
CODE:CODE:1a47  82              ??          82h
CODE:CODE:1a47.107              ??          07h
CODE:CODE:1a48  0834            RETLW       #0x8
CODE:CODE:1a49  1c34            RETLW       #0x1c
CODE:CODE:1a4a  0834            RETLW       #0x8
CODE:CODE:1a4b  0934            RETLW       #0x9
CODE:CODE:1a4c  0634            RETLW       #0x6
CODE:CODE:1a4d  0834            RETLW       #0x8
CODE:CODE:1a4e  0434            RETLW       #0x4
CODE:CODE:1a4f  0034            RETLW       #0x0
CODE:CODE:1a50  ff3fff3ff...    db[2070]
   |_CODE:CODE:1a50  [0]             db          FFh
   |_CODE:CODE:1a50.1[1]             db          3Fh
   |_CODE:CODE:1a51  [2]             db          FFh
   |_CODE:CODE:1a51.1[3]             db          3Fh
   |_CODE:CODE:1a52  [4]             db          FFh
   |_CODE:CODE:1a52.1[5]             db          3Fh
   |_CODE:CODE:1a53  [6]             db          FFh
   |_CODE:CODE:1a53.1[7]             db          3Fh
   |_CODE:CODE:1a54  [8]             db          FFh
   |_CODE:CODE:1a54.1[9]             db          3Fh
   |_CODE:CODE:1a55  [10]            db          FFh
   |_CODE:CODE:1a55.1[11]            db          3Fh
   |_CODE:CODE:1a56  [12]            db          FFh
   |_CODE:CODE:1a56.1[13]            db          3Fh
   |_CODE:CODE:1a57  [14]            db          FFh
   |_CODE:CODE:1a57.1[15]            db          3Fh
   |_CODE:CODE:1a58  [16]            db          FFh
   |_CODE:CODE:1a58.1[17]            db          3Fh
   |_CODE:CODE:1a59  [18]            db          FFh
   |_CODE:CODE:1a59.1[19]            db          3Fh
   |_CODE:CODE:1a5a  [20]            db          FFh
   |_CODE:CODE:1a5a.1[21]            db          3Fh
   |_CODE:CODE:1a5b  [22]            db          FFh
   |_CODE:CODE:1a5b.1[23]            db          3Fh
   |_CODE:CODE:1a5c  [24]            db          FFh
   |_CODE:CODE:1a5c.1[25]            db          3Fh
   |_CODE:CODE:1a5d  [26]            db          FFh
   |_CODE:CODE:1a5d.1[27]            db          3Fh
   |_CODE:CODE:1a5e  [28]            db          FFh
   |_CODE:CODE:1a5e.1[29]            db          3Fh
   |_CODE:CODE:1a5f  [30]            db          FFh
   |_CODE:CODE:1a5f.1[31]            db          3Fh
   |_CODE:CODE:1a60  [32]            db          FFh
   |_CODE:CODE:1a60.1[33]            db          3Fh
   |_CODE:CODE:1a61  [34]            db          FFh
   |_CODE:CODE:1a61.1[35]            db          3Fh
   |_CODE:CODE:1a62  [36]            db          FFh
   |_CODE:CODE:1a62.1[37]            db          3Fh
   |_CODE:CODE:1a63  [38]            db          FFh
   |_CODE:CODE:1a63.1[39]            db          3Fh
   |_CODE:CODE:1a64  [40]            db          FFh
   |_CODE:CODE:1a64.1[41]            db          3Fh
   |_CODE:CODE:1a65  [42]            db          FFh
   |_CODE:CODE:1a65.1[43]            db          3Fh
   |_CODE:CODE:1a66  [44]            db          FFh
   |_CODE:CODE:1a66.1[45]            db          3Fh
   |_CODE:CODE:1a67  [46]            db          FFh
   |_CODE:CODE:1a67.1[47]            db          3Fh
   |_CODE:CODE:1a68  [48]            db          FFh
   |_CODE:CODE:1a68.1[49]            db          3Fh
   |_CODE:CODE:1a69  [50]            db          FFh
   |_CODE:CODE:1a69.1[51]            db          3Fh
   |_CODE:CODE:1a6a  [52]            db          FFh
   |_CODE:CODE:1a6a.1[53]            db          3Fh
   |_CODE:CODE:1a6b  [54]            db          FFh
   |_CODE:CODE:1a6b.1[55]            db          3Fh
   |_CODE:CODE:1a6c  [56]            db          FFh
   |_CODE:CODE:1a6c.1[57]            db          3Fh
   |_CODE:CODE:1a6d  [58]            db          FFh
   |_CODE:CODE:1a6d.1[59]            db          3Fh
   |_CODE:CODE:1a6e  [60]            db          FFh
   |_CODE:CODE:1a6e.1[61]            db          3Fh
   |_CODE:CODE:1a6f  [62]            db          FFh
   |_CODE:CODE:1a6f.1[63]            db          3Fh
   |_CODE:CODE:1a70  [64]            db          FFh
   |_CODE:CODE:1a70.1[65]            db          3Fh
   |_CODE:CODE:1a71  [66]            db          FFh
   |_CODE:CODE:1a71.1[67]            db          3Fh
   |_CODE:CODE:1a72  [68]            db          FFh
   |_CODE:CODE:1a72.1[69]            db          3Fh
   |_CODE:CODE:1a73  [70]            db          FFh
   |_CODE:CODE:1a73.1[71]            db          3Fh
   |_CODE:CODE:1a74  [72]            db          FFh
   |_CODE:CODE:1a74.1[73]            db          3Fh
   |_CODE:CODE:1a75  [74]            db          FFh
   |_CODE:CODE:1a75.1[75]            db          3Fh
   |_CODE:CODE:1a76  [76]            db          FFh
   |_CODE:CODE:1a76.1[77]            db          3Fh
   |_CODE:CODE:1a77  [78]            db          FFh
   |_CODE:CODE:1a77.1[79]            db          3Fh
   |_CODE:CODE:1a78  [80]            db          FFh
   |_CODE:CODE:1a78.1[81]            db          3Fh
   |_CODE:CODE:1a79  [82]            db          FFh
   |_CODE:CODE:1a79.1[83]            db          3Fh
   |_CODE:CODE:1a7a  [84]            db          FFh
   |_CODE:CODE:1a7a.1[85]            db          3Fh
   |_CODE:CODE:1a7b  [86]            db          FFh
   |_CODE:CODE:1a7b.1[87]            db          3Fh
   |_CODE:CODE:1a7c  [88]            db          FFh
   |_CODE:CODE:1a7c.1[89]            db          3Fh
   |_CODE:CODE:1a7d  [90]            db          FFh
   |_CODE:CODE:1a7d.1[91]            db          3Fh
   |_CODE:CODE:1a7e  [92]            db          FFh
   |_CODE:CODE:1a7e.1[93]            db          3Fh
   |_CODE:CODE:1a7f  [94]            db          FFh
   |_CODE:CODE:1a7f.1[95]            db          3Fh
   |_CODE:CODE:1a80  [96]            db          FFh
   |_CODE:CODE:1a80.1[97]            db          3Fh
   |_CODE:CODE:1a81  [98]            db          FFh
   |_CODE:CODE:1a81.1[99]            db          3Fh
   |_CODE:CODE:1a82  [100]           db          FFh
   |_CODE:CODE:1a82.1[101]           db          3Fh
   |_CODE:CODE:1a83  [102]           db          FFh
   |_CODE:CODE:1a83.1[103]           db          3Fh
   |_CODE:CODE:1a84  [104]           db          FFh
   |_CODE:CODE:1a84.1[105]           db          3Fh
   |_CODE:CODE:1a85  [106]           db          FFh
   |_CODE:CODE:1a85.1[107]           db          3Fh
   |_CODE:CODE:1a86  [108]           db          FFh
   |_CODE:CODE:1a86.1[109]           db          3Fh
   |_CODE:CODE:1a87  [110]           db          FFh
   |_CODE:CODE:1a87.1[111]           db          3Fh
   |_CODE:CODE:1a88  [112]           db          FFh
   |_CODE:CODE:1a88.1[113]           db          3Fh
   |_CODE:CODE:1a89  [114]           db          FFh
   |_CODE:CODE:1a89.1[115]           db          3Fh
   |_CODE:CODE:1a8a  [116]           db          FFh
   |_CODE:CODE:1a8a.1[117]           db          3Fh
   |_CODE:CODE:1a8b  [118]           db          FFh
   |_CODE:CODE:1a8b.1[119]           db          3Fh
   |_CODE:CODE:1a8c  [120]           db          FFh
   |_CODE:CODE:1a8c.1[121]           db          3Fh
   |_CODE:CODE:1a8d  [122]           db          FFh
   |_CODE:CODE:1a8d.1[123]           db          3Fh
   |_CODE:CODE:1a8e  [124]           db          FFh
   |_CODE:CODE:1a8e.1[125]           db          3Fh
   |_CODE:CODE:1a8f  [126]           db          FFh
   |_CODE:CODE:1a8f.1[127]           db          3Fh
   |_CODE:CODE:1a90  [128]           db          FFh
   |_CODE:CODE:1a90.1[129]           db          3Fh
   |_CODE:CODE:1a91  [130]           db          FFh
   |_CODE:CODE:1a91.1[131]           db          3Fh
   |_CODE:CODE:1a92  [132]           db          FFh
   |_CODE:CODE:1a92.1[133]           db          3Fh
   |_CODE:CODE:1a93  [134]           db          FFh
   |_CODE:CODE:1a93.1[135]           db          3Fh
   |_CODE:CODE:1a94  [136]           db          FFh
   |_CODE:CODE:1a94.1[137]           db          3Fh
   |_CODE:CODE:1a95  [138]           db          FFh
   |_CODE:CODE:1a95.1[139]           db          3Fh
   |_CODE:CODE:1a96  [140]           db          FFh
   |_CODE:CODE:1a96.1[141]           db          3Fh
   |_CODE:CODE:1a97  [142]           db          FFh
   |_CODE:CODE:1a97.1[143]           db          3Fh
   |_CODE:CODE:1a98  [144]           db          FFh
   |_CODE:CODE:1a98.1[145]           db          3Fh
   |_CODE:CODE:1a99  [146]           db          FFh
   |_CODE:CODE:1a99.1[147]           db          3Fh
   |_CODE:CODE:1a9a  [148]           db          FFh
   |_CODE:CODE:1a9a.1[149]           db          3Fh
   |_CODE:CODE:1a9b  [150]           db          FFh
   |_CODE:CODE:1a9b.1[151]           db          3Fh
   |_CODE:CODE:1a9c  [152]           db          FFh
   |_CODE:CODE:1a9c.1[153]           db          3Fh
   |_CODE:CODE:1a9d  [154]           db          FFh
   |_CODE:CODE:1a9d.1[155]           db          3Fh
   |_CODE:CODE:1a9e  [156]           db          FFh
   |_CODE:CODE:1a9e.1[157]           db          3Fh
   |_CODE:CODE:1a9f  [158]           db          FFh
   |_CODE:CODE:1a9f.1[159]           db          3Fh
   |_CODE:CODE:1aa0  [160]           db          FFh
   |_CODE:CODE:1aa0.1[161]           db          3Fh
   |_CODE:CODE:1aa1  [162]           db          FFh
   |_CODE:CODE:1aa1.1[163]           db          3Fh
   |_CODE:CODE:1aa2  [164]           db          FFh
   |_CODE:CODE:1aa2.1[165]           db          3Fh
   |_CODE:CODE:1aa3  [166]           db          FFh
   |_CODE:CODE:1aa3.1[167]           db          3Fh
   |_CODE:CODE:1aa4  [168]           db          FFh
   |_CODE:CODE:1aa4.1[169]           db          3Fh
   |_CODE:CODE:1aa5  [170]           db          FFh
   |_CODE:CODE:1aa5.1[171]           db          3Fh
   |_CODE:CODE:1aa6  [172]           db          FFh
   |_CODE:CODE:1aa6.1[173]           db          3Fh
   |_CODE:CODE:1aa7  [174]           db          FFh
   |_CODE:CODE:1aa7.1[175]           db          3Fh
   |_CODE:CODE:1aa8  [176]           db          FFh
   |_CODE:CODE:1aa8.1[177]           db          3Fh
   |_CODE:CODE:1aa9  [178]           db          FFh
   |_CODE:CODE:1aa9.1[179]           db          3Fh
   |_CODE:CODE:1aaa  [180]           db          FFh
   |_CODE:CODE:1aaa.1[181]           db          3Fh
   |_CODE:CODE:1aab  [182]           db          FFh
   |_CODE:CODE:1aab.1[183]           db          3Fh
   |_CODE:CODE:1aac  [184]           db          FFh
   |_CODE:CODE:1aac.1[185]           db          3Fh
   |_CODE:CODE:1aad  [186]           db          FFh
   |_CODE:CODE:1aad.1[187]           db          3Fh
   |_CODE:CODE:1aae  [188]           db          FFh
   |_CODE:CODE:1aae.1[189]           db          3Fh
   |_CODE:CODE:1aaf  [190]           db          FFh
   |_CODE:CODE:1aaf.1[191]           db          3Fh
   |_CODE:CODE:1ab0  [192]           db          FFh
   |_CODE:CODE:1ab0.1[193]           db          3Fh
   |_CODE:CODE:1ab1  [194]           db          FFh
   |_CODE:CODE:1ab1.1[195]           db          3Fh
   |_CODE:CODE:1ab2  [196]           db          FFh
   |_CODE:CODE:1ab2.1[197]           db          3Fh
   |_CODE:CODE:1ab3  [198]           db          FFh
   |_CODE:CODE:1ab3.1[199]           db          3Fh
   |_CODE:CODE:1ab4  [200]           db          FFh
   |_CODE:CODE:1ab4.1[201]           db          3Fh
   |_CODE:CODE:1ab5  [202]           db          FFh
   |_CODE:CODE:1ab5.1[203]           db          3Fh
   |_CODE:CODE:1ab6  [204]           db          FFh
   |_CODE:CODE:1ab6.1[205]           db          3Fh
   |_CODE:CODE:1ab7  [206]           db          FFh
   |_CODE:CODE:1ab7.1[207]           db          3Fh
   |_CODE:CODE:1ab8  [208]           db          FFh
   |_CODE:CODE:1ab8.1[209]           db          3Fh
   |_CODE:CODE:1ab9  [210]           db          FFh
   |_CODE:CODE:1ab9.1[211]           db          3Fh
   |_CODE:CODE:1aba  [212]           db          FFh
   |_CODE:CODE:1aba.1[213]           db          3Fh
   |_CODE:CODE:1abb  [214]           db          FFh
   |_CODE:CODE:1abb.1[215]           db          3Fh
   |_CODE:CODE:1abc  [216]           db          FFh
   |_CODE:CODE:1abc.1[217]           db          3Fh
   |_CODE:CODE:1abd  [218]           db          FFh
   |_CODE:CODE:1abd.1[219]           db          3Fh
   |_CODE:CODE:1abe  [220]           db          FFh
   |_CODE:CODE:1abe.1[221]           db          3Fh
   |_CODE:CODE:1abf  [222]           db          FFh
   |_CODE:CODE:1abf.1[223]           db          3Fh
   |_CODE:CODE:1ac0  [224]           db          FFh
   |_CODE:CODE:1ac0.1[225]           db          3Fh
   |_CODE:CODE:1ac1  [226]           db          FFh
   |_CODE:CODE:1ac1.1[227]           db          3Fh
   |_CODE:CODE:1ac2  [228]           db          FFh
   |_CODE:CODE:1ac2.1[229]           db          3Fh
   |_CODE:CODE:1ac3  [230]           db          FFh
   |_CODE:CODE:1ac3.1[231]           db          3Fh
   |_CODE:CODE:1ac4  [232]           db          FFh
   |_CODE:CODE:1ac4.1[233]           db          3Fh
   |_CODE:CODE:1ac5  [234]           db          FFh
   |_CODE:CODE:1ac5.1[235]           db          3Fh
   |_CODE:CODE:1ac6  [236]           db          FFh
   |_CODE:CODE:1ac6.1[237]           db          3Fh
   |_CODE:CODE:1ac7  [238]           db          FFh
   |_CODE:CODE:1ac7.1[239]           db          3Fh
   |_CODE:CODE:1ac8  [240]           db          FFh
   |_CODE:CODE:1ac8.1[241]           db          3Fh
   |_CODE:CODE:1ac9  [242]           db          FFh
   |_CODE:CODE:1ac9.1[243]           db          3Fh
   |_CODE:CODE:1aca  [244]           db          FFh
   |_CODE:CODE:1aca.1[245]           db          3Fh
   |_CODE:CODE:1acb  [246]           db          FFh
   |_CODE:CODE:1acb.1[247]           db          3Fh
   |_CODE:CODE:1acc  [248]           db          FFh
   |_CODE:CODE:1acc.1[249]           db          3Fh
   |_CODE:CODE:1acd  [250]           db          FFh
   |_CODE:CODE:1acd.1[251]           db          3Fh
   |_CODE:CODE:1ace  [252]           db          FFh
   |_CODE:CODE:1ace.1[253]           db          3Fh
   |_CODE:CODE:1acf  [254]           db          FFh
   |_CODE:CODE:1acf.1[255]           db          3Fh
   |_CODE:CODE:1ad0  [256]           db          FFh
   |_CODE:CODE:1ad0.1[257]           db          3Fh
   |_CODE:CODE:1ad1  [258]           db          FFh
   |_CODE:CODE:1ad1.1[259]           db          3Fh
   |_CODE:CODE:1ad2  [260]           db          FFh
   |_CODE:CODE:1ad2.1[261]           db          3Fh
   |_CODE:CODE:1ad3  [262]           db          FFh
   |_CODE:CODE:1ad3.1[263]           db          3Fh
   |_CODE:CODE:1ad4  [264]           db          FFh
   |_CODE:CODE:1ad4.1[265]           db          3Fh
   |_CODE:CODE:1ad5  [266]           db          FFh
   |_CODE:CODE:1ad5.1[267]           db          3Fh
   |_CODE:CODE:1ad6  [268]           db          FFh
   |_CODE:CODE:1ad6.1[269]           db          3Fh
   |_CODE:CODE:1ad7  [270]           db          FFh
   |_CODE:CODE:1ad7.1[271]           db          3Fh
   |_CODE:CODE:1ad8  [272]           db          FFh
   |_CODE:CODE:1ad8.1[273]           db          3Fh
   |_CODE:CODE:1ad9  [274]           db          FFh
   |_CODE:CODE:1ad9.1[275]           db          3Fh
   |_CODE:CODE:1ada  [276]           db          FFh
   |_CODE:CODE:1ada.1[277]           db          3Fh
   |_CODE:CODE:1adb  [278]           db          FFh
   |_CODE:CODE:1adb.1[279]           db          3Fh
   |_CODE:CODE:1adc  [280]           db          FFh
   |_CODE:CODE:1adc.1[281]           db          3Fh
   |_CODE:CODE:1add  [282]           db          FFh
   |_CODE:CODE:1add.1[283]           db          3Fh
   |_CODE:CODE:1ade  [284]           db          FFh
   |_CODE:CODE:1ade.1[285]           db          3Fh
   |_CODE:CODE:1adf  [286]           db          FFh
   |_CODE:CODE:1adf.1[287]           db          3Fh
   |_CODE:CODE:1ae0  [288]           db          FFh
   |_CODE:CODE:1ae0.1[289]           db          3Fh
   |_CODE:CODE:1ae1  [290]           db          FFh
   |_CODE:CODE:1ae1.1[291]           db          3Fh
   |_CODE:CODE:1ae2  [292]           db          FFh
   |_CODE:CODE:1ae2.1[293]           db          3Fh
   |_CODE:CODE:1ae3  [294]           db          FFh
   |_CODE:CODE:1ae3.1[295]           db          3Fh
   |_CODE:CODE:1ae4  [296]           db          FFh
   |_CODE:CODE:1ae4.1[297]           db          3Fh
   |_CODE:CODE:1ae5  [298]           db          FFh
   |_CODE:CODE:1ae5.1[299]           db          3Fh
   |_CODE:CODE:1ae6  [300]           db          FFh
   |_CODE:CODE:1ae6.1[301]           db          3Fh
   |_CODE:CODE:1ae7  [302]           db          FFh
   |_CODE:CODE:1ae7.1[303]           db          3Fh
   |_CODE:CODE:1ae8  [304]           db          FFh
   |_CODE:CODE:1ae8.1[305]           db          3Fh
   |_CODE:CODE:1ae9  [306]           db          FFh
   |_CODE:CODE:1ae9.1[307]           db          3Fh
   |_CODE:CODE:1aea  [308]           db          FFh
   |_CODE:CODE:1aea.1[309]           db          3Fh
   |_CODE:CODE:1aeb  [310]           db          FFh
   |_CODE:CODE:1aeb.1[311]           db          3Fh
   |_CODE:CODE:1aec  [312]           db          FFh
   |_CODE:CODE:1aec.1[313]           db          3Fh
   |_CODE:CODE:1aed  [314]           db          FFh
   |_CODE:CODE:1aed.1[315]           db          3Fh
   |_CODE:CODE:1aee  [316]           db          FFh
   |_CODE:CODE:1aee.1[317]           db          3Fh
   |_CODE:CODE:1aef  [318]           db          FFh
   |_CODE:CODE:1aef.1[319]           db          3Fh
   |_CODE:CODE:1af0  [320]           db          FFh
   |_CODE:CODE:1af0.1[321]           db          3Fh
   |_CODE:CODE:1af1  [322]           db          FFh
   |_CODE:CODE:1af1.1[323]           db          3Fh
   |_CODE:CODE:1af2  [324]           db          FFh
   |_CODE:CODE:1af2.1[325]           db          3Fh
   |_CODE:CODE:1af3  [326]           db          FFh
   |_CODE:CODE:1af3.1[327]           db          3Fh
   |_CODE:CODE:1af4  [328]           db          FFh
   |_CODE:CODE:1af4.1[329]           db          3Fh
   |_CODE:CODE:1af5  [330]           db          FFh
   |_CODE:CODE:1af5.1[331]           db          3Fh
   |_CODE:CODE:1af6  [332]           db          FFh
   |_CODE:CODE:1af6.1[333]           db          3Fh
   |_CODE:CODE:1af7  [334]           db          FFh
   |_CODE:CODE:1af7.1[335]           db          3Fh
   |_CODE:CODE:1af8  [336]           db          FFh
   |_CODE:CODE:1af8.1[337]           db          3Fh
   |_CODE:CODE:1af9  [338]           db          FFh
   |_CODE:CODE:1af9.1[339]           db          3Fh
   |_CODE:CODE:1afa  [340]           db          FFh
   |_CODE:CODE:1afa.1[341]           db          3Fh
   |_CODE:CODE:1afb  [342]           db          FFh
   |_CODE:CODE:1afb.1[343]           db          3Fh
   |_CODE:CODE:1afc  [344]           db          FFh
   |_CODE:CODE:1afc.1[345]           db          3Fh
   |_CODE:CODE:1afd  [346]           db          FFh
   |_CODE:CODE:1afd.1[347]           db          3Fh
   |_CODE:CODE:1afe  [348]           db          FFh
   |_CODE:CODE:1afe.1[349]           db          3Fh
   |_CODE:CODE:1aff  [350]           db          FFh
   |_CODE:CODE:1aff.1[351]           db          3Fh
   |_CODE:CODE:1b00  [352]           db          FFh
   |_CODE:CODE:1b00.1[353]           db          3Fh
   |_CODE:CODE:1b01  [354]           db          FFh
   |_CODE:CODE:1b01.1[355]           db          3Fh
   |_CODE:CODE:1b02  [356]           db          FFh
   |_CODE:CODE:1b02.1[357]           db          3Fh
   |_CODE:CODE:1b03  [358]           db          FFh
   |_CODE:CODE:1b03.1[359]           db          3Fh
   |_CODE:CODE:1b04  [360]           db          FFh
   |_CODE:CODE:1b04.1[361]           db          3Fh
   |_CODE:CODE:1b05  [362]           db          FFh
   |_CODE:CODE:1b05.1[363]           db          3Fh
   |_CODE:CODE:1b06  [364]           db          FFh
   |_CODE:CODE:1b06.1[365]           db          3Fh
   |_CODE:CODE:1b07  [366]           db          FFh
   |_CODE:CODE:1b07.1[367]           db          3Fh
   |_CODE:CODE:1b08  [368]           db          FFh
   |_CODE:CODE:1b08.1[369]           db          3Fh
   |_CODE:CODE:1b09  [370]           db          FFh
   |_CODE:CODE:1b09.1[371]           db          3Fh
   |_CODE:CODE:1b0a  [372]           db          FFh
   |_CODE:CODE:1b0a.1[373]           db          3Fh
   |_CODE:CODE:1b0b  [374]           db          FFh
   |_CODE:CODE:1b0b.1[375]           db          3Fh
   |_CODE:CODE:1b0c  [376]           db          FFh
   |_CODE:CODE:1b0c.1[377]           db          3Fh
   |_CODE:CODE:1b0d  [378]           db          FFh
   |_CODE:CODE:1b0d.1[379]           db          3Fh
   |_CODE:CODE:1b0e  [380]           db          FFh
   |_CODE:CODE:1b0e.1[381]           db          3Fh
   |_CODE:CODE:1b0f  [382]           db          FFh
   |_CODE:CODE:1b0f.1[383]           db          3Fh
   |_CODE:CODE:1b10  [384]           db          FFh
   |_CODE:CODE:1b10.1[385]           db          3Fh
   |_CODE:CODE:1b11  [386]           db          FFh
   |_CODE:CODE:1b11.1[387]           db          3Fh
   |_CODE:CODE:1b12  [388]           db          FFh
   |_CODE:CODE:1b12.1[389]           db          3Fh
   |_CODE:CODE:1b13  [390]           db          FFh
   |_CODE:CODE:1b13.1[391]           db          3Fh
   |_CODE:CODE:1b14  [392]           db          FFh
   |_CODE:CODE:1b14.1[393]           db          3Fh
   |_CODE:CODE:1b15  [394]           db          FFh
   |_CODE:CODE:1b15.1[395]           db          3Fh
   |_CODE:CODE:1b16  [396]           db          FFh
   |_CODE:CODE:1b16.1[397]           db          3Fh
   |_CODE:CODE:1b17  [398]           db          FFh
   |_CODE:CODE:1b17.1[399]           db          3Fh
   |_CODE:CODE:1b18  [400]           db          FFh
   |_CODE:CODE:1b18.1[401]           db          3Fh
   |_CODE:CODE:1b19  [402]           db          FFh
   |_CODE:CODE:1b19.1[403]           db          3Fh
   |_CODE:CODE:1b1a  [404]           db          FFh
   |_CODE:CODE:1b1a.1[405]           db          3Fh
   |_CODE:CODE:1b1b  [406]           db          FFh
   |_CODE:CODE:1b1b.1[407]           db          3Fh
   |_CODE:CODE:1b1c  [408]           db          FFh
   |_CODE:CODE:1b1c.1[409]           db          3Fh
   |_CODE:CODE:1b1d  [410]           db          FFh
   |_CODE:CODE:1b1d.1[411]           db          3Fh
   |_CODE:CODE:1b1e  [412]           db          FFh
   |_CODE:CODE:1b1e.1[413]           db          3Fh
   |_CODE:CODE:1b1f  [414]           db          FFh
   |_CODE:CODE:1b1f.1[415]           db          3Fh
   |_CODE:CODE:1b20  [416]           db          FFh
   |_CODE:CODE:1b20.1[417]           db          3Fh
   |_CODE:CODE:1b21  [418]           db          FFh
   |_CODE:CODE:1b21.1[419]           db          3Fh
   |_CODE:CODE:1b22  [420]           db          FFh
   |_CODE:CODE:1b22.1[421]           db          3Fh
   |_CODE:CODE:1b23  [422]           db          FFh
   |_CODE:CODE:1b23.1[423]           db          3Fh
   |_CODE:CODE:1b24  [424]           db          FFh
   |_CODE:CODE:1b24.1[425]           db          3Fh
   |_CODE:CODE:1b25  [426]           db          FFh
   |_CODE:CODE:1b25.1[427]           db          3Fh
   |_CODE:CODE:1b26  [428]           db          FFh
   |_CODE:CODE:1b26.1[429]           db          3Fh
   |_CODE:CODE:1b27  [430]           db          FFh
   |_CODE:CODE:1b27.1[431]           db          3Fh
   |_CODE:CODE:1b28  [432]           db          FFh
   |_CODE:CODE:1b28.1[433]           db          3Fh
   |_CODE:CODE:1b29  [434]           db          FFh
   |_CODE:CODE:1b29.1[435]           db          3Fh
   |_CODE:CODE:1b2a  [436]           db          FFh
   |_CODE:CODE:1b2a.1[437]           db          3Fh
   |_CODE:CODE:1b2b  [438]           db          FFh
   |_CODE:CODE:1b2b.1[439]           db          3Fh
   |_CODE:CODE:1b2c  [440]           db          FFh
   |_CODE:CODE:1b2c.1[441]           db          3Fh
   |_CODE:CODE:1b2d  [442]           db          FFh
   |_CODE:CODE:1b2d.1[443]           db          3Fh
   |_CODE:CODE:1b2e  [444]           db          FFh
   |_CODE:CODE:1b2e.1[445]           db          3Fh
   |_CODE:CODE:1b2f  [446]           db          FFh
   |_CODE:CODE:1b2f.1[447]           db          3Fh
   |_CODE:CODE:1b30  [448]           db          FFh
   |_CODE:CODE:1b30.1[449]           db          3Fh
   |_CODE:CODE:1b31  [450]           db          FFh
   |_CODE:CODE:1b31.1[451]           db          3Fh
   |_CODE:CODE:1b32  [452]           db          FFh
   |_CODE:CODE:1b32.1[453]           db          3Fh
   |_CODE:CODE:1b33  [454]           db          FFh
   |_CODE:CODE:1b33.1[455]           db          3Fh
   |_CODE:CODE:1b34  [456]           db          FFh
   |_CODE:CODE:1b34.1[457]           db          3Fh
   |_CODE:CODE:1b35  [458]           db          FFh
   |_CODE:CODE:1b35.1[459]           db          3Fh
   |_CODE:CODE:1b36  [460]           db          FFh
   |_CODE:CODE:1b36.1[461]           db          3Fh
   |_CODE:CODE:1b37  [462]           db          FFh
   |_CODE:CODE:1b37.1[463]           db          3Fh
   |_CODE:CODE:1b38  [464]           db          FFh
   |_CODE:CODE:1b38.1[465]           db          3Fh
   |_CODE:CODE:1b39  [466]           db          FFh
   |_CODE:CODE:1b39.1[467]           db          3Fh
   |_CODE:CODE:1b3a  [468]           db          FFh
   |_CODE:CODE:1b3a.1[469]           db          3Fh
   |_CODE:CODE:1b3b  [470]           db          FFh
   |_CODE:CODE:1b3b.1[471]           db          3Fh
   |_CODE:CODE:1b3c  [472]           db          FFh
   |_CODE:CODE:1b3c.1[473]           db          3Fh
   |_CODE:CODE:1b3d  [474]           db          FFh
   |_CODE:CODE:1b3d.1[475]           db          3Fh
   |_CODE:CODE:1b3e  [476]           db          FFh
   |_CODE:CODE:1b3e.1[477]           db          3Fh
   |_CODE:CODE:1b3f  [478]           db          FFh
   |_CODE:CODE:1b3f.1[479]           db          3Fh
   |_CODE:CODE:1b40  [480]           db          FFh
   |_CODE:CODE:1b40.1[481]           db          3Fh
   |_CODE:CODE:1b41  [482]           db          FFh
   |_CODE:CODE:1b41.1[483]           db          3Fh
   |_CODE:CODE:1b42  [484]           db          FFh
   |_CODE:CODE:1b42.1[485]           db          3Fh
   |_CODE:CODE:1b43  [486]           db          FFh
   |_CODE:CODE:1b43.1[487]           db          3Fh
   |_CODE:CODE:1b44  [488]           db          FFh
   |_CODE:CODE:1b44.1[489]           db          3Fh
   |_CODE:CODE:1b45  [490]           db          FFh
   |_CODE:CODE:1b45.1[491]           db          3Fh
   |_CODE:CODE:1b46  [492]           db          FFh
   |_CODE:CODE:1b46.1[493]           db          3Fh
   |_CODE:CODE:1b47  [494]           db          FFh
   |_CODE:CODE:1b47.1[495]           db          3Fh
   |_CODE:CODE:1b48  [496]           db          FFh
   |_CODE:CODE:1b48.1[497]           db          3Fh
   |_CODE:CODE:1b49  [498]           db          FFh
   |_CODE:CODE:1b49.1[499]           db          3Fh
   |_CODE:CODE:1b4a  [500]           db          FFh
   |_CODE:CODE:1b4a.1[501]           db          3Fh
   |_CODE:CODE:1b4b  [502]           db          FFh
   |_CODE:CODE:1b4b.1[503]           db          3Fh
   |_CODE:CODE:1b4c  [504]           db          FFh
   |_CODE:CODE:1b4c.1[505]           db          3Fh
   |_CODE:CODE:1b4d  [506]           db          FFh
   |_CODE:CODE:1b4d.1[507]           db          3Fh
   |_CODE:CODE:1b4e  [508]           db          FFh
   |_CODE:CODE:1b4e.1[509]           db          3Fh
   |_CODE:CODE:1b4f  [510]           db          FFh
   |_CODE:CODE:1b4f.1[511]           db          3Fh
   |_CODE:CODE:1b50  [512]           db          FFh
   |_CODE:CODE:1b50.1[513]           db          3Fh
   |_CODE:CODE:1b51  [514]           db          FFh
   |_CODE:CODE:1b51.1[515]           db          3Fh
   |_CODE:CODE:1b52  [516]           db          FFh
   |_CODE:CODE:1b52.1[517]           db          3Fh
   |_CODE:CODE:1b53  [518]           db          FFh
   |_CODE:CODE:1b53.1[519]           db          3Fh
   |_CODE:CODE:1b54  [520]           db          FFh
   |_CODE:CODE:1b54.1[521]           db          3Fh
   |_CODE:CODE:1b55  [522]           db          FFh
   |_CODE:CODE:1b55.1[523]           db          3Fh
   |_CODE:CODE:1b56  [524]           db          FFh
   |_CODE:CODE:1b56.1[525]           db          3Fh
   |_CODE:CODE:1b57  [526]           db          FFh
   |_CODE:CODE:1b57.1[527]           db          3Fh
   |_CODE:CODE:1b58  [528]           db          FFh
   |_CODE:CODE:1b58.1[529]           db          3Fh
   |_CODE:CODE:1b59  [530]           db          FFh
   |_CODE:CODE:1b59.1[531]           db          3Fh
   |_CODE:CODE:1b5a  [532]           db          FFh
   |_CODE:CODE:1b5a.1[533]           db          3Fh
   |_CODE:CODE:1b5b  [534]           db          FFh
   |_CODE:CODE:1b5b.1[535]           db          3Fh
   |_CODE:CODE:1b5c  [536]           db          FFh
   |_CODE:CODE:1b5c.1[537]           db          3Fh
   |_CODE:CODE:1b5d  [538]           db          FFh
   |_CODE:CODE:1b5d.1[539]           db          3Fh
   |_CODE:CODE:1b5e  [540]           db          FFh
   |_CODE:CODE:1b5e.1[541]           db          3Fh
   |_CODE:CODE:1b5f  [542]           db          FFh
   |_CODE:CODE:1b5f.1[543]           db          3Fh
   |_CODE:CODE:1b60  [544]           db          FFh
   |_CODE:CODE:1b60.1[545]           db          3Fh
   |_CODE:CODE:1b61  [546]           db          FFh
   |_CODE:CODE:1b61.1[547]           db          3Fh
   |_CODE:CODE:1b62  [548]           db          FFh
   |_CODE:CODE:1b62.1[549]           db          3Fh
   |_CODE:CODE:1b63  [550]           db          FFh
   |_CODE:CODE:1b63.1[551]           db          3Fh
   |_CODE:CODE:1b64  [552]           db          FFh
   |_CODE:CODE:1b64.1[553]           db          3Fh
   |_CODE:CODE:1b65  [554]           db          FFh
   |_CODE:CODE:1b65.1[555]           db          3Fh
   |_CODE:CODE:1b66  [556]           db          FFh
   |_CODE:CODE:1b66.1[557]           db          3Fh
   |_CODE:CODE:1b67  [558]           db          FFh
   |_CODE:CODE:1b67.1[559]           db          3Fh
   |_CODE:CODE:1b68  [560]           db          FFh
   |_CODE:CODE:1b68.1[561]           db          3Fh
   |_CODE:CODE:1b69  [562]           db          FFh
   |_CODE:CODE:1b69.1[563]           db          3Fh
   |_CODE:CODE:1b6a  [564]           db          FFh
   |_CODE:CODE:1b6a.1[565]           db          3Fh
   |_CODE:CODE:1b6b  [566]           db          FFh
   |_CODE:CODE:1b6b.1[567]           db          3Fh
   |_CODE:CODE:1b6c  [568]           db          FFh
   |_CODE:CODE:1b6c.1[569]           db          3Fh
   |_CODE:CODE:1b6d  [570]           db          FFh
   |_CODE:CODE:1b6d.1[571]           db          3Fh
   |_CODE:CODE:1b6e  [572]           db          FFh
   |_CODE:CODE:1b6e.1[573]           db          3Fh
   |_CODE:CODE:1b6f  [574]           db          FFh
   |_CODE:CODE:1b6f.1[575]           db          3Fh
   |_CODE:CODE:1b70  [576]           db          FFh
   |_CODE:CODE:1b70.1[577]           db          3Fh
   |_CODE:CODE:1b71  [578]           db          FFh
   |_CODE:CODE:1b71.1[579]           db          3Fh
   |_CODE:CODE:1b72  [580]           db          FFh
   |_CODE:CODE:1b72.1[581]           db          3Fh
   |_CODE:CODE:1b73  [582]           db          FFh
   |_CODE:CODE:1b73.1[583]           db          3Fh
   |_CODE:CODE:1b74  [584]           db          FFh
   |_CODE:CODE:1b74.1[585]           db          3Fh
   |_CODE:CODE:1b75  [586]           db          FFh
   |_CODE:CODE:1b75.1[587]           db          3Fh
   |_CODE:CODE:1b76  [588]           db          FFh
   |_CODE:CODE:1b76.1[589]           db          3Fh
   |_CODE:CODE:1b77  [590]           db          FFh
   |_CODE:CODE:1b77.1[591]           db          3Fh
   |_CODE:CODE:1b78  [592]           db          FFh
   |_CODE:CODE:1b78.1[593]           db          3Fh
   |_CODE:CODE:1b79  [594]           db          FFh
   |_CODE:CODE:1b79.1[595]           db          3Fh
   |_CODE:CODE:1b7a  [596]           db          FFh
   |_CODE:CODE:1b7a.1[597]           db          3Fh
   |_CODE:CODE:1b7b  [598]           db          FFh
   |_CODE:CODE:1b7b.1[599]           db          3Fh
   |_CODE:CODE:1b7c  [600]           db          FFh
   |_CODE:CODE:1b7c.1[601]           db          3Fh
   |_CODE:CODE:1b7d  [602]           db          FFh
   |_CODE:CODE:1b7d.1[603]           db          3Fh
   |_CODE:CODE:1b7e  [604]           db          FFh
   |_CODE:CODE:1b7e.1[605]           db          3Fh
   |_CODE:CODE:1b7f  [606]           db          FFh
   |_CODE:CODE:1b7f.1[607]           db          3Fh
   |_CODE:CODE:1b80  [608]           db          FFh
   |_CODE:CODE:1b80.1[609]           db          3Fh
   |_CODE:CODE:1b81  [610]           db          FFh
   |_CODE:CODE:1b81.1[611]           db          3Fh
   |_CODE:CODE:1b82  [612]           db          FFh
   |_CODE:CODE:1b82.1[613]           db          3Fh
   |_CODE:CODE:1b83  [614]           db          FFh
   |_CODE:CODE:1b83.1[615]           db          3Fh
   |_CODE:CODE:1b84  [616]           db          FFh
   |_CODE:CODE:1b84.1[617]           db          3Fh
   |_CODE:CODE:1b85  [618]           db          FFh
   |_CODE:CODE:1b85.1[619]           db          3Fh
   |_CODE:CODE:1b86  [620]           db          FFh
   |_CODE:CODE:1b86.1[621]           db          3Fh
   |_CODE:CODE:1b87  [622]           db          FFh
   |_CODE:CODE:1b87.1[623]           db          3Fh
   |_CODE:CODE:1b88  [624]           db          FFh
   |_CODE:CODE:1b88.1[625]           db          3Fh
   |_CODE:CODE:1b89  [626]           db          FFh
   |_CODE:CODE:1b89.1[627]           db          3Fh
   |_CODE:CODE:1b8a  [628]           db          FFh
   |_CODE:CODE:1b8a.1[629]           db          3Fh
   |_CODE:CODE:1b8b  [630]           db          FFh
   |_CODE:CODE:1b8b.1[631]           db          3Fh
   |_CODE:CODE:1b8c  [632]           db          FFh
   |_CODE:CODE:1b8c.1[633]           db          3Fh
   |_CODE:CODE:1b8d  [634]           db          FFh
   |_CODE:CODE:1b8d.1[635]           db          3Fh
   |_CODE:CODE:1b8e  [636]           db          FFh
   |_CODE:CODE:1b8e.1[637]           db          3Fh
   |_CODE:CODE:1b8f  [638]           db          FFh
   |_CODE:CODE:1b8f.1[639]           db          3Fh
   |_CODE:CODE:1b90  [640]           db          FFh
   |_CODE:CODE:1b90.1[641]           db          3Fh
   |_CODE:CODE:1b91  [642]           db          FFh
   |_CODE:CODE:1b91.1[643]           db          3Fh
   |_CODE:CODE:1b92  [644]           db          FFh
   |_CODE:CODE:1b92.1[645]           db          3Fh
   |_CODE:CODE:1b93  [646]           db          FFh
   |_CODE:CODE:1b93.1[647]           db          3Fh
   |_CODE:CODE:1b94  [648]           db          FFh
   |_CODE:CODE:1b94.1[649]           db          3Fh
   |_CODE:CODE:1b95  [650]           db          FFh
   |_CODE:CODE:1b95.1[651]           db          3Fh
   |_CODE:CODE:1b96  [652]           db          FFh
   |_CODE:CODE:1b96.1[653]           db          3Fh
   |_CODE:CODE:1b97  [654]           db          FFh
   |_CODE:CODE:1b97.1[655]           db          3Fh
   |_CODE:CODE:1b98  [656]           db          FFh
   |_CODE:CODE:1b98.1[657]           db          3Fh
   |_CODE:CODE:1b99  [658]           db          FFh
   |_CODE:CODE:1b99.1[659]           db          3Fh
   |_CODE:CODE:1b9a  [660]           db          FFh
   |_CODE:CODE:1b9a.1[661]           db          3Fh
   |_CODE:CODE:1b9b  [662]           db          FFh
   |_CODE:CODE:1b9b.1[663]           db          3Fh
   |_CODE:CODE:1b9c  [664]           db          FFh
   |_CODE:CODE:1b9c.1[665]           db          3Fh
   |_CODE:CODE:1b9d  [666]           db          FFh
   |_CODE:CODE:1b9d.1[667]           db          3Fh
   |_CODE:CODE:1b9e  [668]           db          FFh
   |_CODE:CODE:1b9e.1[669]           db          3Fh
   |_CODE:CODE:1b9f  [670]           db          FFh
   |_CODE:CODE:1b9f.1[671]           db          3Fh
   |_CODE:CODE:1ba0  [672]           db          FFh
   |_CODE:CODE:1ba0.1[673]           db          3Fh
   |_CODE:CODE:1ba1  [674]           db          FFh
   |_CODE:CODE:1ba1.1[675]           db          3Fh
   |_CODE:CODE:1ba2  [676]           db          FFh
   |_CODE:CODE:1ba2.1[677]           db          3Fh
   |_CODE:CODE:1ba3  [678]           db          FFh
   |_CODE:CODE:1ba3.1[679]           db          3Fh
   |_CODE:CODE:1ba4  [680]           db          FFh
   |_CODE:CODE:1ba4.1[681]           db          3Fh
   |_CODE:CODE:1ba5  [682]           db          FFh
   |_CODE:CODE:1ba5.1[683]           db          3Fh
   |_CODE:CODE:1ba6  [684]           db          FFh
   |_CODE:CODE:1ba6.1[685]           db          3Fh
   |_CODE:CODE:1ba7  [686]           db          FFh
   |_CODE:CODE:1ba7.1[687]           db          3Fh
   |_CODE:CODE:1ba8  [688]           db          FFh
   |_CODE:CODE:1ba8.1[689]           db          3Fh
   |_CODE:CODE:1ba9  [690]           db          FFh
   |_CODE:CODE:1ba9.1[691]           db          3Fh
   |_CODE:CODE:1baa  [692]           db          FFh
   |_CODE:CODE:1baa.1[693]           db          3Fh
   |_CODE:CODE:1bab  [694]           db          FFh
   |_CODE:CODE:1bab.1[695]           db          3Fh
   |_CODE:CODE:1bac  [696]           db          FFh
   |_CODE:CODE:1bac.1[697]           db          3Fh
   |_CODE:CODE:1bad  [698]           db          FFh
   |_CODE:CODE:1bad.1[699]           db          3Fh
   |_CODE:CODE:1bae  [700]           db          FFh
   |_CODE:CODE:1bae.1[701]           db          3Fh
   |_CODE:CODE:1baf  [702]           db          FFh
   |_CODE:CODE:1baf.1[703]           db          3Fh
   |_CODE:CODE:1bb0  [704]           db          FFh
   |_CODE:CODE:1bb0.1[705]           db          3Fh
   |_CODE:CODE:1bb1  [706]           db          FFh
   |_CODE:CODE:1bb1.1[707]           db          3Fh
   |_CODE:CODE:1bb2  [708]           db          FFh
   |_CODE:CODE:1bb2.1[709]           db          3Fh
   |_CODE:CODE:1bb3  [710]           db          FFh
   |_CODE:CODE:1bb3.1[711]           db          3Fh
   |_CODE:CODE:1bb4  [712]           db          FFh
   |_CODE:CODE:1bb4.1[713]           db          3Fh
   |_CODE:CODE:1bb5  [714]           db          FFh
   |_CODE:CODE:1bb5.1[715]           db          3Fh
   |_CODE:CODE:1bb6  [716]           db          FFh
   |_CODE:CODE:1bb6.1[717]           db          3Fh
   |_CODE:CODE:1bb7  [718]           db          FFh
   |_CODE:CODE:1bb7.1[719]           db          3Fh
   |_CODE:CODE:1bb8  [720]           db          FFh
   |_CODE:CODE:1bb8.1[721]           db          3Fh
   |_CODE:CODE:1bb9  [722]           db          FFh
   |_CODE:CODE:1bb9.1[723]           db          3Fh
   |_CODE:CODE:1bba  [724]           db          FFh
   |_CODE:CODE:1bba.1[725]           db          3Fh
   |_CODE:CODE:1bbb  [726]           db          FFh
   |_CODE:CODE:1bbb.1[727]           db          3Fh
   |_CODE:CODE:1bbc  [728]           db          FFh
   |_CODE:CODE:1bbc.1[729]           db          3Fh
   |_CODE:CODE:1bbd  [730]           db          FFh
   |_CODE:CODE:1bbd.1[731]           db          3Fh
   |_CODE:CODE:1bbe  [732]           db          FFh
   |_CODE:CODE:1bbe.1[733]           db          3Fh
   |_CODE:CODE:1bbf  [734]           db          FFh
   |_CODE:CODE:1bbf.1[735]           db          3Fh
   |_CODE:CODE:1bc0  [736]           db          FFh
   |_CODE:CODE:1bc0.1[737]           db          3Fh
   |_CODE:CODE:1bc1  [738]           db          FFh
   |_CODE:CODE:1bc1.1[739]           db          3Fh
   |_CODE:CODE:1bc2  [740]           db          FFh
   |_CODE:CODE:1bc2.1[741]           db          3Fh
   |_CODE:CODE:1bc3  [742]           db          FFh
   |_CODE:CODE:1bc3.1[743]           db          3Fh
   |_CODE:CODE:1bc4  [744]           db          FFh
   |_CODE:CODE:1bc4.1[745]           db          3Fh
   |_CODE:CODE:1bc5  [746]           db          FFh
   |_CODE:CODE:1bc5.1[747]           db          3Fh
   |_CODE:CODE:1bc6  [748]           db          FFh
   |_CODE:CODE:1bc6.1[749]           db          3Fh
   |_CODE:CODE:1bc7  [750]           db          FFh
   |_CODE:CODE:1bc7.1[751]           db          3Fh
   |_CODE:CODE:1bc8  [752]           db          FFh
   |_CODE:CODE:1bc8.1[753]           db          3Fh
   |_CODE:CODE:1bc9  [754]           db          FFh
   |_CODE:CODE:1bc9.1[755]           db          3Fh
   |_CODE:CODE:1bca  [756]           db          FFh
   |_CODE:CODE:1bca.1[757]           db          3Fh
   |_CODE:CODE:1bcb  [758]           db          FFh
   |_CODE:CODE:1bcb.1[759]           db          3Fh
   |_CODE:CODE:1bcc  [760]           db          FFh
   |_CODE:CODE:1bcc.1[761]           db          3Fh
   |_CODE:CODE:1bcd  [762]           db          FFh
   |_CODE:CODE:1bcd.1[763]           db          3Fh
   |_CODE:CODE:1bce  [764]           db          FFh
   |_CODE:CODE:1bce.1[765]           db          3Fh
   |_CODE:CODE:1bcf  [766]           db          FFh
   |_CODE:CODE:1bcf.1[767]           db          3Fh
   |_CODE:CODE:1bd0  [768]           db          FFh
   |_CODE:CODE:1bd0.1[769]           db          3Fh
   |_CODE:CODE:1bd1  [770]           db          FFh
   |_CODE:CODE:1bd1.1[771]           db          3Fh
   |_CODE:CODE:1bd2  [772]           db          FFh
   |_CODE:CODE:1bd2.1[773]           db          3Fh
   |_CODE:CODE:1bd3  [774]           db          FFh
   |_CODE:CODE:1bd3.1[775]           db          3Fh
   |_CODE:CODE:1bd4  [776]           db          FFh
   |_CODE:CODE:1bd4.1[777]           db          3Fh
   |_CODE:CODE:1bd5  [778]           db          FFh
   |_CODE:CODE:1bd5.1[779]           db          3Fh
   |_CODE:CODE:1bd6  [780]           db          FFh
   |_CODE:CODE:1bd6.1[781]           db          3Fh
   |_CODE:CODE:1bd7  [782]           db          FFh
   |_CODE:CODE:1bd7.1[783]           db          3Fh
   |_CODE:CODE:1bd8  [784]           db          FFh
   |_CODE:CODE:1bd8.1[785]           db          3Fh
   |_CODE:CODE:1bd9  [786]           db          FFh
   |_CODE:CODE:1bd9.1[787]           db          3Fh
   |_CODE:CODE:1bda  [788]           db          FFh
   |_CODE:CODE:1bda.1[789]           db          3Fh
   |_CODE:CODE:1bdb  [790]           db          FFh
   |_CODE:CODE:1bdb.1[791]           db          3Fh
   |_CODE:CODE:1bdc  [792]           db          FFh
   |_CODE:CODE:1bdc.1[793]           db          3Fh
   |_CODE:CODE:1bdd  [794]           db          FFh
   |_CODE:CODE:1bdd.1[795]           db          3Fh
   |_CODE:CODE:1bde  [796]           db          FFh
   |_CODE:CODE:1bde.1[797]           db          3Fh
   |_CODE:CODE:1bdf  [798]           db          FFh
   |_CODE:CODE:1bdf.1[799]           db          3Fh
   |_CODE:CODE:1be0  [800]           db          FFh
   |_CODE:CODE:1be0.1[801]           db          3Fh
   |_CODE:CODE:1be1  [802]           db          FFh
   |_CODE:CODE:1be1.1[803]           db          3Fh
   |_CODE:CODE:1be2  [804]           db          FFh
   |_CODE:CODE:1be2.1[805]           db          3Fh
   |_CODE:CODE:1be3  [806]           db          FFh
   |_CODE:CODE:1be3.1[807]           db          3Fh
   |_CODE:CODE:1be4  [808]           db          FFh
   |_CODE:CODE:1be4.1[809]           db          3Fh
   |_CODE:CODE:1be5  [810]           db          FFh
   |_CODE:CODE:1be5.1[811]           db          3Fh
   |_CODE:CODE:1be6  [812]           db          FFh
   |_CODE:CODE:1be6.1[813]           db          3Fh
   |_CODE:CODE:1be7  [814]           db          FFh
   |_CODE:CODE:1be7.1[815]           db          3Fh
   |_CODE:CODE:1be8  [816]           db          FFh
   |_CODE:CODE:1be8.1[817]           db          3Fh
   |_CODE:CODE:1be9  [818]           db          FFh
   |_CODE:CODE:1be9.1[819]           db          3Fh
   |_CODE:CODE:1bea  [820]           db          FFh
   |_CODE:CODE:1bea.1[821]           db          3Fh
   |_CODE:CODE:1beb  [822]           db          FFh
   |_CODE:CODE:1beb.1[823]           db          3Fh
   |_CODE:CODE:1bec  [824]           db          FFh
   |_CODE:CODE:1bec.1[825]           db          3Fh
   |_CODE:CODE:1bed  [826]           db          FFh
   |_CODE:CODE:1bed.1[827]           db          3Fh
   |_CODE:CODE:1bee  [828]           db          FFh
   |_CODE:CODE:1bee.1[829]           db          3Fh
   |_CODE:CODE:1bef  [830]           db          FFh
   |_CODE:CODE:1bef.1[831]           db          3Fh
   |_CODE:CODE:1bf0  [832]           db          FFh
   |_CODE:CODE:1bf0.1[833]           db          3Fh
   |_CODE:CODE:1bf1  [834]           db          FFh
   |_CODE:CODE:1bf1.1[835]           db          3Fh
   |_CODE:CODE:1bf2  [836]           db          FFh
   |_CODE:CODE:1bf2.1[837]           db          3Fh
   |_CODE:CODE:1bf3  [838]           db          FFh
   |_CODE:CODE:1bf3.1[839]           db          3Fh
   |_CODE:CODE:1bf4  [840]           db          FFh
   |_CODE:CODE:1bf4.1[841]           db          3Fh
   |_CODE:CODE:1bf5  [842]           db          FFh
   |_CODE:CODE:1bf5.1[843]           db          3Fh
   |_CODE:CODE:1bf6  [844]           db          FFh
   |_CODE:CODE:1bf6.1[845]           db          3Fh
   |_CODE:CODE:1bf7  [846]           db          FFh
   |_CODE:CODE:1bf7.1[847]           db          3Fh
   |_CODE:CODE:1bf8  [848]           db          FFh
   |_CODE:CODE:1bf8.1[849]           db          3Fh
   |_CODE:CODE:1bf9  [850]           db          FFh
   |_CODE:CODE:1bf9.1[851]           db          3Fh
   |_CODE:CODE:1bfa  [852]           db          FFh
   |_CODE:CODE:1bfa.1[853]           db          3Fh
   |_CODE:CODE:1bfb  [854]           db          FFh
   |_CODE:CODE:1bfb.1[855]           db          3Fh
   |_CODE:CODE:1bfc  [856]           db          FFh
   |_CODE:CODE:1bfc.1[857]           db          3Fh
   |_CODE:CODE:1bfd  [858]           db          FFh
   |_CODE:CODE:1bfd.1[859]           db          3Fh
   |_CODE:CODE:1bfe  [860]           db          FFh
   |_CODE:CODE:1bfe.1[861]           db          3Fh
   |_CODE:CODE:1bff  [862]           db          FFh
   |_CODE:CODE:1bff.1[863]           db          3Fh
   |_CODE:CODE:1c00  [864]           db          FFh
   |_CODE:CODE:1c00.1[865]           db          3Fh
   |_CODE:CODE:1c01  [866]           db          FFh
   |_CODE:CODE:1c01.1[867]           db          3Fh
   |_CODE:CODE:1c02  [868]           db          FFh
   |_CODE:CODE:1c02.1[869]           db          3Fh
   |_CODE:CODE:1c03  [870]           db          FFh
   |_CODE:CODE:1c03.1[871]           db          3Fh
   |_CODE:CODE:1c04  [872]           db          FFh
   |_CODE:CODE:1c04.1[873]           db          3Fh
   |_CODE:CODE:1c05  [874]           db          FFh
   |_CODE:CODE:1c05.1[875]           db          3Fh
   |_CODE:CODE:1c06  [876]           db          FFh
   |_CODE:CODE:1c06.1[877]           db          3Fh
   |_CODE:CODE:1c07  [878]           db          FFh
   |_CODE:CODE:1c07.1[879]           db          3Fh
   |_CODE:CODE:1c08  [880]           db          FFh
   |_CODE:CODE:1c08.1[881]           db          3Fh
   |_CODE:CODE:1c09  [882]           db          FFh
   |_CODE:CODE:1c09.1[883]           db          3Fh
   |_CODE:CODE:1c0a  [884]           db          FFh
   |_CODE:CODE:1c0a.1[885]           db          3Fh
   |_CODE:CODE:1c0b  [886]           db          FFh
   |_CODE:CODE:1c0b.1[887]           db          3Fh
   |_CODE:CODE:1c0c  [888]           db          FFh
   |_CODE:CODE:1c0c.1[889]           db          3Fh
   |_CODE:CODE:1c0d  [890]           db          FFh
   |_CODE:CODE:1c0d.1[891]           db          3Fh
   |_CODE:CODE:1c0e  [892]           db          FFh
   |_CODE:CODE:1c0e.1[893]           db          3Fh
   |_CODE:CODE:1c0f  [894]           db          FFh
   |_CODE:CODE:1c0f.1[895]           db          3Fh
   |_CODE:CODE:1c10  [896]           db          FFh
   |_CODE:CODE:1c10.1[897]           db          3Fh
   |_CODE:CODE:1c11  [898]           db          FFh
   |_CODE:CODE:1c11.1[899]           db          3Fh
   |_CODE:CODE:1c12  [900]           db          FFh
   |_CODE:CODE:1c12.1[901]           db          3Fh
   |_CODE:CODE:1c13  [902]           db          FFh
   |_CODE:CODE:1c13.1[903]           db          3Fh
   |_CODE:CODE:1c14  [904]           db          FFh
   |_CODE:CODE:1c14.1[905]           db          3Fh
   |_CODE:CODE:1c15  [906]           db          FFh
   |_CODE:CODE:1c15.1[907]           db          3Fh
   |_CODE:CODE:1c16  [908]           db          FFh
   |_CODE:CODE:1c16.1[909]           db          3Fh
   |_CODE:CODE:1c17  [910]           db          FFh
   |_CODE:CODE:1c17.1[911]           db          3Fh
   |_CODE:CODE:1c18  [912]           db          FFh
   |_CODE:CODE:1c18.1[913]           db          3Fh
   |_CODE:CODE:1c19  [914]           db          FFh
   |_CODE:CODE:1c19.1[915]           db          3Fh
   |_CODE:CODE:1c1a  [916]           db          FFh
   |_CODE:CODE:1c1a.1[917]           db          3Fh
   |_CODE:CODE:1c1b  [918]           db          FFh
   |_CODE:CODE:1c1b.1[919]           db          3Fh
   |_CODE:CODE:1c1c  [920]           db          FFh
   |_CODE:CODE:1c1c.1[921]           db          3Fh
   |_CODE:CODE:1c1d  [922]           db          FFh
   |_CODE:CODE:1c1d.1[923]           db          3Fh
   |_CODE:CODE:1c1e  [924]           db          FFh
   |_CODE:CODE:1c1e.1[925]           db          3Fh
   |_CODE:CODE:1c1f  [926]           db          FFh
   |_CODE:CODE:1c1f.1[927]           db          3Fh
   |_CODE:CODE:1c20  [928]           db          FFh
   |_CODE:CODE:1c20.1[929]           db          3Fh
   |_CODE:CODE:1c21  [930]           db          FFh
   |_CODE:CODE:1c21.1[931]           db          3Fh
   |_CODE:CODE:1c22  [932]           db          FFh
   |_CODE:CODE:1c22.1[933]           db          3Fh
   |_CODE:CODE:1c23  [934]           db          FFh
   |_CODE:CODE:1c23.1[935]           db          3Fh
   |_CODE:CODE:1c24  [936]           db          FFh
   |_CODE:CODE:1c24.1[937]           db          3Fh
   |_CODE:CODE:1c25  [938]           db          FFh
   |_CODE:CODE:1c25.1[939]           db          3Fh
   |_CODE:CODE:1c26  [940]           db          FFh
   |_CODE:CODE:1c26.1[941]           db          3Fh
   |_CODE:CODE:1c27  [942]           db          FFh
   |_CODE:CODE:1c27.1[943]           db          3Fh
   |_CODE:CODE:1c28  [944]           db          FFh
   |_CODE:CODE:1c28.1[945]           db          3Fh
   |_CODE:CODE:1c29  [946]           db          FFh
   |_CODE:CODE:1c29.1[947]           db          3Fh
   |_CODE:CODE:1c2a  [948]           db          FFh
   |_CODE:CODE:1c2a.1[949]           db          3Fh
   |_CODE:CODE:1c2b  [950]           db          FFh
   |_CODE:CODE:1c2b.1[951]           db          3Fh
   |_CODE:CODE:1c2c  [952]           db          FFh
   |_CODE:CODE:1c2c.1[953]           db          3Fh
   |_CODE:CODE:1c2d  [954]           db          FFh
   |_CODE:CODE:1c2d.1[955]           db          3Fh
   |_CODE:CODE:1c2e  [956]           db          FFh
   |_CODE:CODE:1c2e.1[957]           db          3Fh
   |_CODE:CODE:1c2f  [958]           db          FFh
   |_CODE:CODE:1c2f.1[959]           db          3Fh
   |_CODE:CODE:1c30  [960]           db          FFh
   |_CODE:CODE:1c30.1[961]           db          3Fh
   |_CODE:CODE:1c31  [962]           db          FFh
   |_CODE:CODE:1c31.1[963]           db          3Fh
   |_CODE:CODE:1c32  [964]           db          FFh
   |_CODE:CODE:1c32.1[965]           db          3Fh
   |_CODE:CODE:1c33  [966]           db          FFh
   |_CODE:CODE:1c33.1[967]           db          3Fh
   |_CODE:CODE:1c34  [968]           db          FFh
   |_CODE:CODE:1c34.1[969]           db          3Fh
   |_CODE:CODE:1c35  [970]           db          FFh
   |_CODE:CODE:1c35.1[971]           db          3Fh
   |_CODE:CODE:1c36  [972]           db          FFh
   |_CODE:CODE:1c36.1[973]           db          3Fh
   |_CODE:CODE:1c37  [974]           db          FFh
   |_CODE:CODE:1c37.1[975]           db          3Fh
   |_CODE:CODE:1c38  [976]           db          FFh
   |_CODE:CODE:1c38.1[977]           db          3Fh
   |_CODE:CODE:1c39  [978]           db          FFh
   |_CODE:CODE:1c39.1[979]           db          3Fh
   |_CODE:CODE:1c3a  [980]           db          FFh
   |_CODE:CODE:1c3a.1[981]           db          3Fh
   |_CODE:CODE:1c3b  [982]           db          FFh
   |_CODE:CODE:1c3b.1[983]           db          3Fh
   |_CODE:CODE:1c3c  [984]           db          FFh
   |_CODE:CODE:1c3c.1[985]           db          3Fh
   |_CODE:CODE:1c3d  [986]           db          FFh
   |_CODE:CODE:1c3d.1[987]           db          3Fh
   |_CODE:CODE:1c3e  [988]           db          FFh
   |_CODE:CODE:1c3e.1[989]           db          3Fh
   |_CODE:CODE:1c3f  [990]           db          FFh
   |_CODE:CODE:1c3f.1[991]           db          3Fh
   |_CODE:CODE:1c40  [992]           db          FFh
   |_CODE:CODE:1c40.1[993]           db          3Fh
   |_CODE:CODE:1c41  [994]           db          FFh
   |_CODE:CODE:1c41.1[995]           db          3Fh
   |_CODE:CODE:1c42  [996]           db          FFh
   |_CODE:CODE:1c42.1[997]           db          3Fh
   |_CODE:CODE:1c43  [998]           db          FFh
   |_CODE:CODE:1c43.1[999]           db          3Fh
   |_CODE:CODE:1c44  [1000]          db          FFh
   |_CODE:CODE:1c44.1[1001]          db          3Fh
   |_CODE:CODE:1c45  [1002]          db          FFh
   |_CODE:CODE:1c45.1[1003]          db          3Fh
   |_CODE:CODE:1c46  [1004]          db          FFh
   |_CODE:CODE:1c46.1[1005]          db          3Fh
   |_CODE:CODE:1c47  [1006]          db          FFh
   |_CODE:CODE:1c47.1[1007]          db          3Fh
   |_CODE:CODE:1c48  [1008]          db          FFh
   |_CODE:CODE:1c48.1[1009]          db          3Fh
   |_CODE:CODE:1c49  [1010]          db          FFh
   |_CODE:CODE:1c49.1[1011]          db          3Fh
   |_CODE:CODE:1c4a  [1012]          db          FFh
   |_CODE:CODE:1c4a.1[1013]          db          3Fh
   |_CODE:CODE:1c4b  [1014]          db          FFh
   |_CODE:CODE:1c4b.1[1015]          db          3Fh
   |_CODE:CODE:1c4c  [1016]          db          FFh
   |_CODE:CODE:1c4c.1[1017]          db          3Fh
   |_CODE:CODE:1c4d  [1018]          db          FFh
   |_CODE:CODE:1c4d.1[1019]          db          3Fh
   |_CODE:CODE:1c4e  [1020]          db          FFh
   |_CODE:CODE:1c4e.1[1021]          db          3Fh
   |_CODE:CODE:1c4f  [1022]          db          FFh
   |_CODE:CODE:1c4f.1[1023]          db          3Fh
   |_CODE:CODE:1c50  [1024]          db          FFh
   |_CODE:CODE:1c50.1[1025]          db          3Fh
   |_CODE:CODE:1c51  [1026]          db          FFh
   |_CODE:CODE:1c51.1[1027]          db          3Fh
   |_CODE:CODE:1c52  [1028]          db          FFh
   |_CODE:CODE:1c52.1[1029]          db          3Fh
   |_CODE:CODE:1c53  [1030]          db          FFh
   |_CODE:CODE:1c53.1[1031]          db          3Fh
   |_CODE:CODE:1c54  [1032]          db          FFh
   |_CODE:CODE:1c54.1[1033]          db          3Fh
   |_CODE:CODE:1c55  [1034]          db          FFh
   |_CODE:CODE:1c55.1[1035]          db          3Fh
   |_CODE:CODE:1c56  [1036]          db          FFh
   |_CODE:CODE:1c56.1[1037]          db          3Fh
   |_CODE:CODE:1c57  [1038]          db          FFh
   |_CODE:CODE:1c57.1[1039]          db          3Fh
   |_CODE:CODE:1c58  [1040]          db          FFh
   |_CODE:CODE:1c58.1[1041]          db          3Fh
   |_CODE:CODE:1c59  [1042]          db          FFh
   |_CODE:CODE:1c59.1[1043]          db          3Fh
   |_CODE:CODE:1c5a  [1044]          db          FFh
   |_CODE:CODE:1c5a.1[1045]          db          3Fh
   |_CODE:CODE:1c5b  [1046]          db          FFh
   |_CODE:CODE:1c5b.1[1047]          db          3Fh
   |_CODE:CODE:1c5c  [1048]          db          FFh
   |_CODE:CODE:1c5c.1[1049]          db          3Fh
   |_CODE:CODE:1c5d  [1050]          db          FFh
   |_CODE:CODE:1c5d.1[1051]          db          3Fh
   |_CODE:CODE:1c5e  [1052]          db          FFh
   |_CODE:CODE:1c5e.1[1053]          db          3Fh
   |_CODE:CODE:1c5f  [1054]          db          FFh
   |_CODE:CODE:1c5f.1[1055]          db          3Fh
   |_CODE:CODE:1c60  [1056]          db          FFh
   |_CODE:CODE:1c60.1[1057]          db          3Fh
   |_CODE:CODE:1c61  [1058]          db          FFh
   |_CODE:CODE:1c61.1[1059]          db          3Fh
   |_CODE:CODE:1c62  [1060]          db          FFh
   |_CODE:CODE:1c62.1[1061]          db          3Fh
   |_CODE:CODE:1c63  [1062]          db          FFh
   |_CODE:CODE:1c63.1[1063]          db          3Fh
   |_CODE:CODE:1c64  [1064]          db          FFh
   |_CODE:CODE:1c64.1[1065]          db          3Fh
   |_CODE:CODE:1c65  [1066]          db          FFh
   |_CODE:CODE:1c65.1[1067]          db          3Fh
   |_CODE:CODE:1c66  [1068]          db          FFh
   |_CODE:CODE:1c66.1[1069]          db          3Fh
   |_CODE:CODE:1c67  [1070]          db          FFh
   |_CODE:CODE:1c67.1[1071]          db          3Fh
   |_CODE:CODE:1c68  [1072]          db          FFh
   |_CODE:CODE:1c68.1[1073]          db          3Fh
   |_CODE:CODE:1c69  [1074]          db          FFh
   |_CODE:CODE:1c69.1[1075]          db          3Fh
   |_CODE:CODE:1c6a  [1076]          db          FFh
   |_CODE:CODE:1c6a.1[1077]          db          3Fh
   |_CODE:CODE:1c6b  [1078]          db          FFh
   |_CODE:CODE:1c6b.1[1079]          db          3Fh
   |_CODE:CODE:1c6c  [1080]          db          FFh
   |_CODE:CODE:1c6c.1[1081]          db          3Fh
   |_CODE:CODE:1c6d  [1082]          db          FFh
   |_CODE:CODE:1c6d.1[1083]          db          3Fh
   |_CODE:CODE:1c6e  [1084]          db          FFh
   |_CODE:CODE:1c6e.1[1085]          db          3Fh
   |_CODE:CODE:1c6f  [1086]          db          FFh
   |_CODE:CODE:1c6f.1[1087]          db          3Fh
   |_CODE:CODE:1c70  [1088]          db          FFh
   |_CODE:CODE:1c70.1[1089]          db          3Fh
   |_CODE:CODE:1c71  [1090]          db          FFh
   |_CODE:CODE:1c71.1[1091]          db          3Fh
   |_CODE:CODE:1c72  [1092]          db          FFh
   |_CODE:CODE:1c72.1[1093]          db          3Fh
   |_CODE:CODE:1c73  [1094]          db          FFh
   |_CODE:CODE:1c73.1[1095]          db          3Fh
   |_CODE:CODE:1c74  [1096]          db          FFh
   |_CODE:CODE:1c74.1[1097]          db          3Fh
   |_CODE:CODE:1c75  [1098]          db          FFh
   |_CODE:CODE:1c75.1[1099]          db          3Fh
   |_CODE:CODE:1c76  [1100]          db          FFh
   |_CODE:CODE:1c76.1[1101]          db          3Fh
   |_CODE:CODE:1c77  [1102]          db          FFh
   |_CODE:CODE:1c77.1[1103]          db          3Fh
   |_CODE:CODE:1c78  [1104]          db          FFh
   |_CODE:CODE:1c78.1[1105]          db          3Fh
   |_CODE:CODE:1c79  [1106]          db          FFh
   |_CODE:CODE:1c79.1[1107]          db          3Fh
   |_CODE:CODE:1c7a  [1108]          db          FFh
   |_CODE:CODE:1c7a.1[1109]          db          3Fh
   |_CODE:CODE:1c7b  [1110]          db          FFh
   |_CODE:CODE:1c7b.1[1111]          db          3Fh
   |_CODE:CODE:1c7c  [1112]          db          FFh
   |_CODE:CODE:1c7c.1[1113]          db          3Fh
   |_CODE:CODE:1c7d  [1114]          db          FFh
   |_CODE:CODE:1c7d.1[1115]          db          3Fh
   |_CODE:CODE:1c7e  [1116]          db          FFh
   |_CODE:CODE:1c7e.1[1117]          db          3Fh
   |_CODE:CODE:1c7f  [1118]          db          FFh
   |_CODE:CODE:1c7f.1[1119]          db          3Fh
   |_CODE:CODE:1c80  [1120]          db          FFh
   |_CODE:CODE:1c80.1[1121]          db          3Fh
   |_CODE:CODE:1c81  [1122]          db          FFh
   |_CODE:CODE:1c81.1[1123]          db          3Fh
   |_CODE:CODE:1c82  [1124]          db          FFh
   |_CODE:CODE:1c82.1[1125]          db          3Fh
   |_CODE:CODE:1c83  [1126]          db          FFh
   |_CODE:CODE:1c83.1[1127]          db          3Fh
   |_CODE:CODE:1c84  [1128]          db          FFh
   |_CODE:CODE:1c84.1[1129]          db          3Fh
   |_CODE:CODE:1c85  [1130]          db          FFh
   |_CODE:CODE:1c85.1[1131]          db          3Fh
   |_CODE:CODE:1c86  [1132]          db          FFh
   |_CODE:CODE:1c86.1[1133]          db          3Fh
   |_CODE:CODE:1c87  [1134]          db          FFh
   |_CODE:CODE:1c87.1[1135]          db          3Fh
   |_CODE:CODE:1c88  [1136]          db          FFh
   |_CODE:CODE:1c88.1[1137]          db          3Fh
   |_CODE:CODE:1c89  [1138]          db          FFh
   |_CODE:CODE:1c89.1[1139]          db          3Fh
   |_CODE:CODE:1c8a  [1140]          db          FFh
   |_CODE:CODE:1c8a.1[1141]          db          3Fh
   |_CODE:CODE:1c8b  [1142]          db          FFh
   |_CODE:CODE:1c8b.1[1143]          db          3Fh
   |_CODE:CODE:1c8c  [1144]          db          FFh
   |_CODE:CODE:1c8c.1[1145]          db          3Fh
   |_CODE:CODE:1c8d  [1146]          db          FFh
   |_CODE:CODE:1c8d.1[1147]          db          3Fh
   |_CODE:CODE:1c8e  [1148]          db          FFh
   |_CODE:CODE:1c8e.1[1149]          db          3Fh
   |_CODE:CODE:1c8f  [1150]          db          FFh
   |_CODE:CODE:1c8f.1[1151]          db          3Fh
   |_CODE:CODE:1c90  [1152]          db          FFh
   |_CODE:CODE:1c90.1[1153]          db          3Fh
   |_CODE:CODE:1c91  [1154]          db          FFh
   |_CODE:CODE:1c91.1[1155]          db          3Fh
   |_CODE:CODE:1c92  [1156]          db          FFh
   |_CODE:CODE:1c92.1[1157]          db          3Fh
   |_CODE:CODE:1c93  [1158]          db          FFh
   |_CODE:CODE:1c93.1[1159]          db          3Fh
   |_CODE:CODE:1c94  [1160]          db          FFh
   |_CODE:CODE:1c94.1[1161]          db          3Fh
   |_CODE:CODE:1c95  [1162]          db          FFh
   |_CODE:CODE:1c95.1[1163]          db          3Fh
   |_CODE:CODE:1c96  [1164]          db          FFh
   |_CODE:CODE:1c96.1[1165]          db          3Fh
   |_CODE:CODE:1c97  [1166]          db          FFh
   |_CODE:CODE:1c97.1[1167]          db          3Fh
   |_CODE:CODE:1c98  [1168]          db          FFh
   |_CODE:CODE:1c98.1[1169]          db          3Fh
   |_CODE:CODE:1c99  [1170]          db          FFh
   |_CODE:CODE:1c99.1[1171]          db          3Fh
   |_CODE:CODE:1c9a  [1172]          db          FFh
   |_CODE:CODE:1c9a.1[1173]          db          3Fh
   |_CODE:CODE:1c9b  [1174]          db          FFh
   |_CODE:CODE:1c9b.1[1175]          db          3Fh
   |_CODE:CODE:1c9c  [1176]          db          FFh
   |_CODE:CODE:1c9c.1[1177]          db          3Fh
   |_CODE:CODE:1c9d  [1178]          db          FFh
   |_CODE:CODE:1c9d.1[1179]          db          3Fh
   |_CODE:CODE:1c9e  [1180]          db          FFh
   |_CODE:CODE:1c9e.1[1181]          db          3Fh
   |_CODE:CODE:1c9f  [1182]          db          FFh
   |_CODE:CODE:1c9f.1[1183]          db          3Fh
   |_CODE:CODE:1ca0  [1184]          db          FFh
   |_CODE:CODE:1ca0.1[1185]          db          3Fh
   |_CODE:CODE:1ca1  [1186]          db          FFh
   |_CODE:CODE:1ca1.1[1187]          db          3Fh
   |_CODE:CODE:1ca2  [1188]          db          FFh
   |_CODE:CODE:1ca2.1[1189]          db          3Fh
   |_CODE:CODE:1ca3  [1190]          db          FFh
   |_CODE:CODE:1ca3.1[1191]          db          3Fh
   |_CODE:CODE:1ca4  [1192]          db          FFh
   |_CODE:CODE:1ca4.1[1193]          db          3Fh
   |_CODE:CODE:1ca5  [1194]          db          FFh
   |_CODE:CODE:1ca5.1[1195]          db          3Fh
   |_CODE:CODE:1ca6  [1196]          db          FFh
   |_CODE:CODE:1ca6.1[1197]          db          3Fh
   |_CODE:CODE:1ca7  [1198]          db          FFh
   |_CODE:CODE:1ca7.1[1199]          db          3Fh
   |_CODE:CODE:1ca8  [1200]          db          FFh
   |_CODE:CODE:1ca8.1[1201]          db          3Fh
   |_CODE:CODE:1ca9  [1202]          db          FFh
   |_CODE:CODE:1ca9.1[1203]          db          3Fh
   |_CODE:CODE:1caa  [1204]          db          FFh
   |_CODE:CODE:1caa.1[1205]          db          3Fh
   |_CODE:CODE:1cab  [1206]          db          FFh
   |_CODE:CODE:1cab.1[1207]          db          3Fh
   |_CODE:CODE:1cac  [1208]          db          FFh
   |_CODE:CODE:1cac.1[1209]          db          3Fh
   |_CODE:CODE:1cad  [1210]          db          FFh
   |_CODE:CODE:1cad.1[1211]          db          3Fh
   |_CODE:CODE:1cae  [1212]          db          FFh
   |_CODE:CODE:1cae.1[1213]          db          3Fh
   |_CODE:CODE:1caf  [1214]          db          FFh
   |_CODE:CODE:1caf.1[1215]          db          3Fh
   |_CODE:CODE:1cb0  [1216]          db          FFh
   |_CODE:CODE:1cb0.1[1217]          db          3Fh
   |_CODE:CODE:1cb1  [1218]          db          FFh
   |_CODE:CODE:1cb1.1[1219]          db          3Fh
   |_CODE:CODE:1cb2  [1220]          db          FFh
   |_CODE:CODE:1cb2.1[1221]          db          3Fh
   |_CODE:CODE:1cb3  [1222]          db          FFh
   |_CODE:CODE:1cb3.1[1223]          db          3Fh
   |_CODE:CODE:1cb4  [1224]          db          FFh
   |_CODE:CODE:1cb4.1[1225]          db          3Fh
   |_CODE:CODE:1cb5  [1226]          db          FFh
   |_CODE:CODE:1cb5.1[1227]          db          3Fh
   |_CODE:CODE:1cb6  [1228]          db          FFh
   |_CODE:CODE:1cb6.1[1229]          db          3Fh
   |_CODE:CODE:1cb7  [1230]          db          FFh
   |_CODE:CODE:1cb7.1[1231]          db          3Fh
   |_CODE:CODE:1cb8  [1232]          db          FFh
   |_CODE:CODE:1cb8.1[1233]          db          3Fh
   |_CODE:CODE:1cb9  [1234]          db          FFh
   |_CODE:CODE:1cb9.1[1235]          db          3Fh
   |_CODE:CODE:1cba  [1236]          db          FFh
   |_CODE:CODE:1cba.1[1237]          db          3Fh
   |_CODE:CODE:1cbb  [1238]          db          FFh
   |_CODE:CODE:1cbb.1[1239]          db          3Fh
   |_CODE:CODE:1cbc  [1240]          db          FFh
   |_CODE:CODE:1cbc.1[1241]          db          3Fh
   |_CODE:CODE:1cbd  [1242]          db          FFh
   |_CODE:CODE:1cbd.1[1243]          db          3Fh
   |_CODE:CODE:1cbe  [1244]          db          FFh
   |_CODE:CODE:1cbe.1[1245]          db          3Fh
   |_CODE:CODE:1cbf  [1246]          db          FFh
   |_CODE:CODE:1cbf.1[1247]          db          3Fh
   |_CODE:CODE:1cc0  [1248]          db          FFh
   |_CODE:CODE:1cc0.1[1249]          db          3Fh
   |_CODE:CODE:1cc1  [1250]          db          FFh
   |_CODE:CODE:1cc1.1[1251]          db          3Fh
   |_CODE:CODE:1cc2  [1252]          db          FFh
   |_CODE:CODE:1cc2.1[1253]          db          3Fh
   |_CODE:CODE:1cc3  [1254]          db          FFh
   |_CODE:CODE:1cc3.1[1255]          db          3Fh
   |_CODE:CODE:1cc4  [1256]          db          FFh
   |_CODE:CODE:1cc4.1[1257]          db          3Fh
   |_CODE:CODE:1cc5  [1258]          db          FFh
   |_CODE:CODE:1cc5.1[1259]          db          3Fh
   |_CODE:CODE:1cc6  [1260]          db          FFh
   |_CODE:CODE:1cc6.1[1261]          db          3Fh
   |_CODE:CODE:1cc7  [1262]          db          FFh
   |_CODE:CODE:1cc7.1[1263]          db          3Fh
   |_CODE:CODE:1cc8  [1264]          db          FFh
   |_CODE:CODE:1cc8.1[1265]          db          3Fh
   |_CODE:CODE:1cc9  [1266]          db          FFh
   |_CODE:CODE:1cc9.1[1267]          db          3Fh
   |_CODE:CODE:1cca  [1268]          db          FFh
   |_CODE:CODE:1cca.1[1269]          db          3Fh
   |_CODE:CODE:1ccb  [1270]          db          FFh
   |_CODE:CODE:1ccb.1[1271]          db          3Fh
   |_CODE:CODE:1ccc  [1272]          db          FFh
   |_CODE:CODE:1ccc.1[1273]          db          3Fh
   |_CODE:CODE:1ccd  [1274]          db          FFh
   |_CODE:CODE:1ccd.1[1275]          db          3Fh
   |_CODE:CODE:1cce  [1276]          db          FFh
   |_CODE:CODE:1cce.1[1277]          db          3Fh
   |_CODE:CODE:1ccf  [1278]          db          FFh
   |_CODE:CODE:1ccf.1[1279]          db          3Fh
   |_CODE:CODE:1cd0  [1280]          db          FFh
   |_CODE:CODE:1cd0.1[1281]          db          3Fh
   |_CODE:CODE:1cd1  [1282]          db          FFh
   |_CODE:CODE:1cd1.1[1283]          db          3Fh
   |_CODE:CODE:1cd2  [1284]          db          FFh
   |_CODE:CODE:1cd2.1[1285]          db          3Fh
   |_CODE:CODE:1cd3  [1286]          db          FFh
   |_CODE:CODE:1cd3.1[1287]          db          3Fh
   |_CODE:CODE:1cd4  [1288]          db          FFh
   |_CODE:CODE:1cd4.1[1289]          db          3Fh
   |_CODE:CODE:1cd5  [1290]          db          FFh
   |_CODE:CODE:1cd5.1[1291]          db          3Fh
   |_CODE:CODE:1cd6  [1292]          db          FFh
   |_CODE:CODE:1cd6.1[1293]          db          3Fh
   |_CODE:CODE:1cd7  [1294]          db          FFh
   |_CODE:CODE:1cd7.1[1295]          db          3Fh
   |_CODE:CODE:1cd8  [1296]          db          FFh
   |_CODE:CODE:1cd8.1[1297]          db          3Fh
   |_CODE:CODE:1cd9  [1298]          db          FFh
   |_CODE:CODE:1cd9.1[1299]          db          3Fh
   |_CODE:CODE:1cda  [1300]          db          FFh
   |_CODE:CODE:1cda.1[1301]          db          3Fh
   |_CODE:CODE:1cdb  [1302]          db          FFh
   |_CODE:CODE:1cdb.1[1303]          db          3Fh
   |_CODE:CODE:1cdc  [1304]          db          FFh
   |_CODE:CODE:1cdc.1[1305]          db          3Fh
   |_CODE:CODE:1cdd  [1306]          db          FFh
   |_CODE:CODE:1cdd.1[1307]          db          3Fh
   |_CODE:CODE:1cde  [1308]          db          FFh
   |_CODE:CODE:1cde.1[1309]          db          3Fh
   |_CODE:CODE:1cdf  [1310]          db          FFh
   |_CODE:CODE:1cdf.1[1311]          db          3Fh
   |_CODE:CODE:1ce0  [1312]          db          FFh
   |_CODE:CODE:1ce0.1[1313]          db          3Fh
   |_CODE:CODE:1ce1  [1314]          db          FFh
   |_CODE:CODE:1ce1.1[1315]          db          3Fh
   |_CODE:CODE:1ce2  [1316]          db          FFh
   |_CODE:CODE:1ce2.1[1317]          db          3Fh
   |_CODE:CODE:1ce3  [1318]          db          FFh
   |_CODE:CODE:1ce3.1[1319]          db          3Fh
   |_CODE:CODE:1ce4  [1320]          db          FFh
   |_CODE:CODE:1ce4.1[1321]          db          3Fh
   |_CODE:CODE:1ce5  [1322]          db          FFh
   |_CODE:CODE:1ce5.1[1323]          db          3Fh
   |_CODE:CODE:1ce6  [1324]          db          FFh
   |_CODE:CODE:1ce6.1[1325]          db          3Fh
   |_CODE:CODE:1ce7  [1326]          db          FFh
   |_CODE:CODE:1ce7.1[1327]          db          3Fh
   |_CODE:CODE:1ce8  [1328]          db          FFh
   |_CODE:CODE:1ce8.1[1329]          db          3Fh
   |_CODE:CODE:1ce9  [1330]          db          FFh
   |_CODE:CODE:1ce9.1[1331]          db          3Fh
   |_CODE:CODE:1cea  [1332]          db          FFh
   |_CODE:CODE:1cea.1[1333]          db          3Fh
   |_CODE:CODE:1ceb  [1334]          db          FFh
   |_CODE:CODE:1ceb.1[1335]          db          3Fh
   |_CODE:CODE:1cec  [1336]          db          FFh
   |_CODE:CODE:1cec.1[1337]          db          3Fh
   |_CODE:CODE:1ced  [1338]          db          FFh
   |_CODE:CODE:1ced.1[1339]          db          3Fh
   |_CODE:CODE:1cee  [1340]          db          FFh
   |_CODE:CODE:1cee.1[1341]          db          3Fh
   |_CODE:CODE:1cef  [1342]          db          FFh
   |_CODE:CODE:1cef.1[1343]          db          3Fh
   |_CODE:CODE:1cf0  [1344]          db          FFh
   |_CODE:CODE:1cf0.1[1345]          db          3Fh
   |_CODE:CODE:1cf1  [1346]          db          FFh
   |_CODE:CODE:1cf1.1[1347]          db          3Fh
   |_CODE:CODE:1cf2  [1348]          db          FFh
   |_CODE:CODE:1cf2.1[1349]          db          3Fh
   |_CODE:CODE:1cf3  [1350]          db          FFh
   |_CODE:CODE:1cf3.1[1351]          db          3Fh
   |_CODE:CODE:1cf4  [1352]          db          FFh
   |_CODE:CODE:1cf4.1[1353]          db          3Fh
   |_CODE:CODE:1cf5  [1354]          db          FFh
   |_CODE:CODE:1cf5.1[1355]          db          3Fh
   |_CODE:CODE:1cf6  [1356]          db          FFh
   |_CODE:CODE:1cf6.1[1357]          db          3Fh
   |_CODE:CODE:1cf7  [1358]          db          FFh
   |_CODE:CODE:1cf7.1[1359]          db          3Fh
   |_CODE:CODE:1cf8  [1360]          db          FFh
   |_CODE:CODE:1cf8.1[1361]          db          3Fh
   |_CODE:CODE:1cf9  [1362]          db          FFh
   |_CODE:CODE:1cf9.1[1363]          db          3Fh
   |_CODE:CODE:1cfa  [1364]          db          FFh
   |_CODE:CODE:1cfa.1[1365]          db          3Fh
   |_CODE:CODE:1cfb  [1366]          db          FFh
   |_CODE:CODE:1cfb.1[1367]          db          3Fh
   |_CODE:CODE:1cfc  [1368]          db          FFh
   |_CODE:CODE:1cfc.1[1369]          db          3Fh
   |_CODE:CODE:1cfd  [1370]          db          FFh
   |_CODE:CODE:1cfd.1[1371]          db          3Fh
   |_CODE:CODE:1cfe  [1372]          db          FFh
   |_CODE:CODE:1cfe.1[1373]          db          3Fh
   |_CODE:CODE:1cff  [1374]          db          FFh
   |_CODE:CODE:1cff.1[1375]          db          3Fh
   |_CODE:CODE:1d00  [1376]          db          FFh
   |_CODE:CODE:1d00.1[1377]          db          3Fh
   |_CODE:CODE:1d01  [1378]          db          FFh
   |_CODE:CODE:1d01.1[1379]          db          3Fh
   |_CODE:CODE:1d02  [1380]          db          FFh
   |_CODE:CODE:1d02.1[1381]          db          3Fh
   |_CODE:CODE:1d03  [1382]          db          FFh
   |_CODE:CODE:1d03.1[1383]          db          3Fh
   |_CODE:CODE:1d04  [1384]          db          FFh
   |_CODE:CODE:1d04.1[1385]          db          3Fh
   |_CODE:CODE:1d05  [1386]          db          FFh
   |_CODE:CODE:1d05.1[1387]          db          3Fh
   |_CODE:CODE:1d06  [1388]          db          FFh
   |_CODE:CODE:1d06.1[1389]          db          3Fh
   |_CODE:CODE:1d07  [1390]          db          FFh
   |_CODE:CODE:1d07.1[1391]          db          3Fh
   |_CODE:CODE:1d08  [1392]          db          FFh
   |_CODE:CODE:1d08.1[1393]          db          3Fh
   |_CODE:CODE:1d09  [1394]          db          FFh
   |_CODE:CODE:1d09.1[1395]          db          3Fh
   |_CODE:CODE:1d0a  [1396]          db          FFh
   |_CODE:CODE:1d0a.1[1397]          db          3Fh
   |_CODE:CODE:1d0b  [1398]          db          FFh
   |_CODE:CODE:1d0b.1[1399]          db          3Fh
   |_CODE:CODE:1d0c  [1400]          db          FFh
   |_CODE:CODE:1d0c.1[1401]          db          3Fh
   |_CODE:CODE:1d0d  [1402]          db          FFh
   |_CODE:CODE:1d0d.1[1403]          db          3Fh
   |_CODE:CODE:1d0e  [1404]          db          FFh
   |_CODE:CODE:1d0e.1[1405]          db          3Fh
   |_CODE:CODE:1d0f  [1406]          db          FFh
   |_CODE:CODE:1d0f.1[1407]          db          3Fh
   |_CODE:CODE:1d10  [1408]          db          FFh
   |_CODE:CODE:1d10.1[1409]          db          3Fh
   |_CODE:CODE:1d11  [1410]          db          FFh
   |_CODE:CODE:1d11.1[1411]          db          3Fh
   |_CODE:CODE:1d12  [1412]          db          FFh
   |_CODE:CODE:1d12.1[1413]          db          3Fh
   |_CODE:CODE:1d13  [1414]          db          FFh
   |_CODE:CODE:1d13.1[1415]          db          3Fh
   |_CODE:CODE:1d14  [1416]          db          FFh
   |_CODE:CODE:1d14.1[1417]          db          3Fh
   |_CODE:CODE:1d15  [1418]          db          FFh
   |_CODE:CODE:1d15.1[1419]          db          3Fh
   |_CODE:CODE:1d16  [1420]          db          FFh
   |_CODE:CODE:1d16.1[1421]          db          3Fh
   |_CODE:CODE:1d17  [1422]          db          FFh
   |_CODE:CODE:1d17.1[1423]          db          3Fh
   |_CODE:CODE:1d18  [1424]          db          FFh
   |_CODE:CODE:1d18.1[1425]          db          3Fh
   |_CODE:CODE:1d19  [1426]          db          FFh
   |_CODE:CODE:1d19.1[1427]          db          3Fh
   |_CODE:CODE:1d1a  [1428]          db          FFh
   |_CODE:CODE:1d1a.1[1429]          db          3Fh
   |_CODE:CODE:1d1b  [1430]          db          FFh
   |_CODE:CODE:1d1b.1[1431]          db          3Fh
   |_CODE:CODE:1d1c  [1432]          db          FFh
   |_CODE:CODE:1d1c.1[1433]          db          3Fh
   |_CODE:CODE:1d1d  [1434]          db          FFh
   |_CODE:CODE:1d1d.1[1435]          db          3Fh
   |_CODE:CODE:1d1e  [1436]          db          FFh
   |_CODE:CODE:1d1e.1[1437]          db          3Fh
   |_CODE:CODE:1d1f  [1438]          db          FFh
   |_CODE:CODE:1d1f.1[1439]          db          3Fh
   |_CODE:CODE:1d20  [1440]          db          FFh
   |_CODE:CODE:1d20.1[1441]          db          3Fh
   |_CODE:CODE:1d21  [1442]          db          FFh
   |_CODE:CODE:1d21.1[1443]          db          3Fh
   |_CODE:CODE:1d22  [1444]          db          FFh
   |_CODE:CODE:1d22.1[1445]          db          3Fh
   |_CODE:CODE:1d23  [1446]          db          FFh
   |_CODE:CODE:1d23.1[1447]          db          3Fh
   |_CODE:CODE:1d24  [1448]          db          FFh
   |_CODE:CODE:1d24.1[1449]          db          3Fh
   |_CODE:CODE:1d25  [1450]          db          FFh
   |_CODE:CODE:1d25.1[1451]          db          3Fh
   |_CODE:CODE:1d26  [1452]          db          FFh
   |_CODE:CODE:1d26.1[1453]          db          3Fh
   |_CODE:CODE:1d27  [1454]          db          FFh
   |_CODE:CODE:1d27.1[1455]          db          3Fh
   |_CODE:CODE:1d28  [1456]          db          FFh
   |_CODE:CODE:1d28.1[1457]          db          3Fh
   |_CODE:CODE:1d29  [1458]          db          FFh
   |_CODE:CODE:1d29.1[1459]          db          3Fh
   |_CODE:CODE:1d2a  [1460]          db          FFh
   |_CODE:CODE:1d2a.1[1461]          db          3Fh
   |_CODE:CODE:1d2b  [1462]          db          FFh
   |_CODE:CODE:1d2b.1[1463]          db          3Fh
   |_CODE:CODE:1d2c  [1464]          db          FFh
   |_CODE:CODE:1d2c.1[1465]          db          3Fh
   |_CODE:CODE:1d2d  [1466]          db          FFh
   |_CODE:CODE:1d2d.1[1467]          db          3Fh
   |_CODE:CODE:1d2e  [1468]          db          FFh
   |_CODE:CODE:1d2e.1[1469]          db          3Fh
   |_CODE:CODE:1d2f  [1470]          db          FFh
   |_CODE:CODE:1d2f.1[1471]          db          3Fh
   |_CODE:CODE:1d30  [1472]          db          FFh
   |_CODE:CODE:1d30.1[1473]          db          3Fh
   |_CODE:CODE:1d31  [1474]          db          FFh
   |_CODE:CODE:1d31.1[1475]          db          3Fh
   |_CODE:CODE:1d32  [1476]          db          FFh
   |_CODE:CODE:1d32.1[1477]          db          3Fh
   |_CODE:CODE:1d33  [1478]          db          FFh
   |_CODE:CODE:1d33.1[1479]          db          3Fh
   |_CODE:CODE:1d34  [1480]          db          FFh
   |_CODE:CODE:1d34.1[1481]          db          3Fh
   |_CODE:CODE:1d35  [1482]          db          FFh
   |_CODE:CODE:1d35.1[1483]          db          3Fh
   |_CODE:CODE:1d36  [1484]          db          FFh
   |_CODE:CODE:1d36.1[1485]          db          3Fh
   |_CODE:CODE:1d37  [1486]          db          FFh
   |_CODE:CODE:1d37.1[1487]          db          3Fh
   |_CODE:CODE:1d38  [1488]          db          FFh
   |_CODE:CODE:1d38.1[1489]          db          3Fh
   |_CODE:CODE:1d39  [1490]          db          FFh
   |_CODE:CODE:1d39.1[1491]          db          3Fh
   |_CODE:CODE:1d3a  [1492]          db          FFh
   |_CODE:CODE:1d3a.1[1493]          db          3Fh
   |_CODE:CODE:1d3b  [1494]          db          FFh
   |_CODE:CODE:1d3b.1[1495]          db          3Fh
   |_CODE:CODE:1d3c  [1496]          db          FFh
   |_CODE:CODE:1d3c.1[1497]          db          3Fh
   |_CODE:CODE:1d3d  [1498]          db          FFh
   |_CODE:CODE:1d3d.1[1499]          db          3Fh
   |_CODE:CODE:1d3e  [1500]          db          FFh
   |_CODE:CODE:1d3e.1[1501]          db          3Fh
   |_CODE:CODE:1d3f  [1502]          db          FFh
   |_CODE:CODE:1d3f.1[1503]          db          3Fh
   |_CODE:CODE:1d40  [1504]          db          FFh
   |_CODE:CODE:1d40.1[1505]          db          3Fh
   |_CODE:CODE:1d41  [1506]          db          FFh
   |_CODE:CODE:1d41.1[1507]          db          3Fh
   |_CODE:CODE:1d42  [1508]          db          FFh
   |_CODE:CODE:1d42.1[1509]          db          3Fh
   |_CODE:CODE:1d43  [1510]          db          FFh
   |_CODE:CODE:1d43.1[1511]          db          3Fh
   |_CODE:CODE:1d44  [1512]          db          FFh
   |_CODE:CODE:1d44.1[1513]          db          3Fh
   |_CODE:CODE:1d45  [1514]          db          FFh
   |_CODE:CODE:1d45.1[1515]          db          3Fh
   |_CODE:CODE:1d46  [1516]          db          FFh
   |_CODE:CODE:1d46.1[1517]          db          3Fh
   |_CODE:CODE:1d47  [1518]          db          FFh
   |_CODE:CODE:1d47.1[1519]          db          3Fh
   |_CODE:CODE:1d48  [1520]          db          FFh
   |_CODE:CODE:1d48.1[1521]          db          3Fh
   |_CODE:CODE:1d49  [1522]          db          FFh
   |_CODE:CODE:1d49.1[1523]          db          3Fh
   |_CODE:CODE:1d4a  [1524]          db          FFh
   |_CODE:CODE:1d4a.1[1525]          db          3Fh
   |_CODE:CODE:1d4b  [1526]          db          FFh
   |_CODE:CODE:1d4b.1[1527]          db          3Fh
   |_CODE:CODE:1d4c  [1528]          db          FFh
   |_CODE:CODE:1d4c.1[1529]          db          3Fh
   |_CODE:CODE:1d4d  [1530]          db          FFh
   |_CODE:CODE:1d4d.1[1531]          db          3Fh
   |_CODE:CODE:1d4e  [1532]          db          FFh
   |_CODE:CODE:1d4e.1[1533]          db          3Fh
   |_CODE:CODE:1d4f  [1534]          db          FFh
   |_CODE:CODE:1d4f.1[1535]          db          3Fh
   |_CODE:CODE:1d50  [1536]          db          FFh
   |_CODE:CODE:1d50.1[1537]          db          3Fh
   |_CODE:CODE:1d51  [1538]          db          FFh
   |_CODE:CODE:1d51.1[1539]          db          3Fh
   |_CODE:CODE:1d52  [1540]          db          FFh
   |_CODE:CODE:1d52.1[1541]          db          3Fh
   |_CODE:CODE:1d53  [1542]          db          FFh
   |_CODE:CODE:1d53.1[1543]          db          3Fh
   |_CODE:CODE:1d54  [1544]          db          FFh
   |_CODE:CODE:1d54.1[1545]          db          3Fh
   |_CODE:CODE:1d55  [1546]          db          FFh
   |_CODE:CODE:1d55.1[1547]          db          3Fh
   |_CODE:CODE:1d56  [1548]          db          FFh
   |_CODE:CODE:1d56.1[1549]          db          3Fh
   |_CODE:CODE:1d57  [1550]          db          FFh
   |_CODE:CODE:1d57.1[1551]          db          3Fh
   |_CODE:CODE:1d58  [1552]          db          FFh
   |_CODE:CODE:1d58.1[1553]          db          3Fh
   |_CODE:CODE:1d59  [1554]          db          FFh
   |_CODE:CODE:1d59.1[1555]          db          3Fh
   |_CODE:CODE:1d5a  [1556]          db          FFh
   |_CODE:CODE:1d5a.1[1557]          db          3Fh
   |_CODE:CODE:1d5b  [1558]          db          FFh
   |_CODE:CODE:1d5b.1[1559]          db          3Fh
   |_CODE:CODE:1d5c  [1560]          db          FFh
   |_CODE:CODE:1d5c.1[1561]          db          3Fh
   |_CODE:CODE:1d5d  [1562]          db          FFh
   |_CODE:CODE:1d5d.1[1563]          db          3Fh
   |_CODE:CODE:1d5e  [1564]          db          FFh
   |_CODE:CODE:1d5e.1[1565]          db          3Fh
   |_CODE:CODE:1d5f  [1566]          db          FFh
   |_CODE:CODE:1d5f.1[1567]          db          3Fh
   |_CODE:CODE:1d60  [1568]          db          FFh
   |_CODE:CODE:1d60.1[1569]          db          3Fh
   |_CODE:CODE:1d61  [1570]          db          FFh
   |_CODE:CODE:1d61.1[1571]          db          3Fh
   |_CODE:CODE:1d62  [1572]          db          FFh
   |_CODE:CODE:1d62.1[1573]          db          3Fh
   |_CODE:CODE:1d63  [1574]          db          FFh
   |_CODE:CODE:1d63.1[1575]          db          3Fh
   |_CODE:CODE:1d64  [1576]          db          FFh
   |_CODE:CODE:1d64.1[1577]          db          3Fh
   |_CODE:CODE:1d65  [1578]          db          FFh
   |_CODE:CODE:1d65.1[1579]          db          3Fh
   |_CODE:CODE:1d66  [1580]          db          FFh
   |_CODE:CODE:1d66.1[1581]          db          3Fh
   |_CODE:CODE:1d67  [1582]          db          FFh
   |_CODE:CODE:1d67.1[1583]          db          3Fh
   |_CODE:CODE:1d68  [1584]          db          FFh
   |_CODE:CODE:1d68.1[1585]          db          3Fh
   |_CODE:CODE:1d69  [1586]          db          FFh
   |_CODE:CODE:1d69.1[1587]          db          3Fh
   |_CODE:CODE:1d6a  [1588]          db          FFh
   |_CODE:CODE:1d6a.1[1589]          db          3Fh
   |_CODE:CODE:1d6b  [1590]          db          FFh
   |_CODE:CODE:1d6b.1[1591]          db          3Fh
   |_CODE:CODE:1d6c  [1592]          db          FFh
   |_CODE:CODE:1d6c.1[1593]          db          3Fh
   |_CODE:CODE:1d6d  [1594]          db          FFh
   |_CODE:CODE:1d6d.1[1595]          db          3Fh
   |_CODE:CODE:1d6e  [1596]          db          FFh
   |_CODE:CODE:1d6e.1[1597]          db          3Fh
   |_CODE:CODE:1d6f  [1598]          db          FFh
   |_CODE:CODE:1d6f.1[1599]          db          3Fh
   |_CODE:CODE:1d70  [1600]          db          FFh
   |_CODE:CODE:1d70.1[1601]          db          3Fh
   |_CODE:CODE:1d71  [1602]          db          FFh
   |_CODE:CODE:1d71.1[1603]          db          3Fh
   |_CODE:CODE:1d72  [1604]          db          FFh
   |_CODE:CODE:1d72.1[1605]          db          3Fh
   |_CODE:CODE:1d73  [1606]          db          FFh
   |_CODE:CODE:1d73.1[1607]          db          3Fh
   |_CODE:CODE:1d74  [1608]          db          FFh
   |_CODE:CODE:1d74.1[1609]          db          3Fh
   |_CODE:CODE:1d75  [1610]          db          FFh
   |_CODE:CODE:1d75.1[1611]          db          3Fh
   |_CODE:CODE:1d76  [1612]          db          FFh
   |_CODE:CODE:1d76.1[1613]          db          3Fh
   |_CODE:CODE:1d77  [1614]          db          FFh
   |_CODE:CODE:1d77.1[1615]          db          3Fh
   |_CODE:CODE:1d78  [1616]          db          FFh
   |_CODE:CODE:1d78.1[1617]          db          3Fh
   |_CODE:CODE:1d79  [1618]          db          FFh
   |_CODE:CODE:1d79.1[1619]          db          3Fh
   |_CODE:CODE:1d7a  [1620]          db          FFh
   |_CODE:CODE:1d7a.1[1621]          db          3Fh
   |_CODE:CODE:1d7b  [1622]          db          FFh
   |_CODE:CODE:1d7b.1[1623]          db          3Fh
   |_CODE:CODE:1d7c  [1624]          db          FFh
   |_CODE:CODE:1d7c.1[1625]          db          3Fh
   |_CODE:CODE:1d7d  [1626]          db          FFh
   |_CODE:CODE:1d7d.1[1627]          db          3Fh
   |_CODE:CODE:1d7e  [1628]          db          FFh
   |_CODE:CODE:1d7e.1[1629]          db          3Fh
   |_CODE:CODE:1d7f  [1630]          db          FFh
   |_CODE:CODE:1d7f.1[1631]          db          3Fh
   |_CODE:CODE:1d80  [1632]          db          FFh
   |_CODE:CODE:1d80.1[1633]          db          3Fh
   |_CODE:CODE:1d81  [1634]          db          FFh
   |_CODE:CODE:1d81.1[1635]          db          3Fh
   |_CODE:CODE:1d82  [1636]          db          FFh
   |_CODE:CODE:1d82.1[1637]          db          3Fh
   |_CODE:CODE:1d83  [1638]          db          FFh
   |_CODE:CODE:1d83.1[1639]          db          3Fh
   |_CODE:CODE:1d84  [1640]          db          FFh
   |_CODE:CODE:1d84.1[1641]          db          3Fh
   |_CODE:CODE:1d85  [1642]          db          FFh
   |_CODE:CODE:1d85.1[1643]          db          3Fh
   |_CODE:CODE:1d86  [1644]          db          FFh
   |_CODE:CODE:1d86.1[1645]          db          3Fh
   |_CODE:CODE:1d87  [1646]          db          FFh
   |_CODE:CODE:1d87.1[1647]          db          3Fh
   |_CODE:CODE:1d88  [1648]          db          FFh
   |_CODE:CODE:1d88.1[1649]          db          3Fh
   |_CODE:CODE:1d89  [1650]          db          FFh
   |_CODE:CODE:1d89.1[1651]          db          3Fh
   |_CODE:CODE:1d8a  [1652]          db          FFh
   |_CODE:CODE:1d8a.1[1653]          db          3Fh
   |_CODE:CODE:1d8b  [1654]          db          FFh
   |_CODE:CODE:1d8b.1[1655]          db          3Fh
   |_CODE:CODE:1d8c  [1656]          db          FFh
   |_CODE:CODE:1d8c.1[1657]          db          3Fh
   |_CODE:CODE:1d8d  [1658]          db          FFh
   |_CODE:CODE:1d8d.1[1659]          db          3Fh
   |_CODE:CODE:1d8e  [1660]          db          FFh
   |_CODE:CODE:1d8e.1[1661]          db          3Fh
   |_CODE:CODE:1d8f  [1662]          db          FFh
   |_CODE:CODE:1d8f.1[1663]          db          3Fh
   |_CODE:CODE:1d90  [1664]          db          FFh
   |_CODE:CODE:1d90.1[1665]          db          3Fh
   |_CODE:CODE:1d91  [1666]          db          FFh
   |_CODE:CODE:1d91.1[1667]          db          3Fh
   |_CODE:CODE:1d92  [1668]          db          FFh
   |_CODE:CODE:1d92.1[1669]          db          3Fh
   |_CODE:CODE:1d93  [1670]          db          FFh
   |_CODE:CODE:1d93.1[1671]          db          3Fh
   |_CODE:CODE:1d94  [1672]          db          FFh
   |_CODE:CODE:1d94.1[1673]          db          3Fh
   |_CODE:CODE:1d95  [1674]          db          FFh
   |_CODE:CODE:1d95.1[1675]          db          3Fh
   |_CODE:CODE:1d96  [1676]          db          FFh
   |_CODE:CODE:1d96.1[1677]          db          3Fh
   |_CODE:CODE:1d97  [1678]          db          FFh
   |_CODE:CODE:1d97.1[1679]          db          3Fh
   |_CODE:CODE:1d98  [1680]          db          FFh
   |_CODE:CODE:1d98.1[1681]          db          3Fh
   |_CODE:CODE:1d99  [1682]          db          FFh
   |_CODE:CODE:1d99.1[1683]          db          3Fh
   |_CODE:CODE:1d9a  [1684]          db          FFh
   |_CODE:CODE:1d9a.1[1685]          db          3Fh
   |_CODE:CODE:1d9b  [1686]          db          FFh
   |_CODE:CODE:1d9b.1[1687]          db          3Fh
   |_CODE:CODE:1d9c  [1688]          db          FFh
   |_CODE:CODE:1d9c.1[1689]          db          3Fh
   |_CODE:CODE:1d9d  [1690]          db          FFh
   |_CODE:CODE:1d9d.1[1691]          db          3Fh
   |_CODE:CODE:1d9e  [1692]          db          FFh
   |_CODE:CODE:1d9e.1[1693]          db          3Fh
   |_CODE:CODE:1d9f  [1694]          db          FFh
   |_CODE:CODE:1d9f.1[1695]          db          3Fh
   |_CODE:CODE:1da0  [1696]          db          FFh
   |_CODE:CODE:1da0.1[1697]          db          3Fh
   |_CODE:CODE:1da1  [1698]          db          FFh
   |_CODE:CODE:1da1.1[1699]          db          3Fh
   |_CODE:CODE:1da2  [1700]          db          FFh
   |_CODE:CODE:1da2.1[1701]          db          3Fh
   |_CODE:CODE:1da3  [1702]          db          FFh
   |_CODE:CODE:1da3.1[1703]          db          3Fh
   |_CODE:CODE:1da4  [1704]          db          FFh
   |_CODE:CODE:1da4.1[1705]          db          3Fh
   |_CODE:CODE:1da5  [1706]          db          FFh
   |_CODE:CODE:1da5.1[1707]          db          3Fh
   |_CODE:CODE:1da6  [1708]          db          FFh
   |_CODE:CODE:1da6.1[1709]          db          3Fh
   |_CODE:CODE:1da7  [1710]          db          FFh
   |_CODE:CODE:1da7.1[1711]          db          3Fh
   |_CODE:CODE:1da8  [1712]          db          FFh
   |_CODE:CODE:1da8.1[1713]          db          3Fh
   |_CODE:CODE:1da9  [1714]          db          FFh
   |_CODE:CODE:1da9.1[1715]          db          3Fh
   |_CODE:CODE:1daa  [1716]          db          FFh
   |_CODE:CODE:1daa.1[1717]          db          3Fh
   |_CODE:CODE:1dab  [1718]          db          FFh
   |_CODE:CODE:1dab.1[1719]          db          3Fh
   |_CODE:CODE:1dac  [1720]          db          FFh
   |_CODE:CODE:1dac.1[1721]          db          3Fh
   |_CODE:CODE:1dad  [1722]          db          FFh
   |_CODE:CODE:1dad.1[1723]          db          3Fh
   |_CODE:CODE:1dae  [1724]          db          FFh
   |_CODE:CODE:1dae.1[1725]          db          3Fh
   |_CODE:CODE:1daf  [1726]          db          FFh
   |_CODE:CODE:1daf.1[1727]          db          3Fh
   |_CODE:CODE:1db0  [1728]          db          FFh
   |_CODE:CODE:1db0.1[1729]          db          3Fh
   |_CODE:CODE:1db1  [1730]          db          FFh
   |_CODE:CODE:1db1.1[1731]          db          3Fh
   |_CODE:CODE:1db2  [1732]          db          FFh
   |_CODE:CODE:1db2.1[1733]          db          3Fh
   |_CODE:CODE:1db3  [1734]          db          FFh
   |_CODE:CODE:1db3.1[1735]          db          3Fh
   |_CODE:CODE:1db4  [1736]          db          FFh
   |_CODE:CODE:1db4.1[1737]          db          3Fh
   |_CODE:CODE:1db5  [1738]          db          FFh
   |_CODE:CODE:1db5.1[1739]          db          3Fh
   |_CODE:CODE:1db6  [1740]          db          FFh
   |_CODE:CODE:1db6.1[1741]          db          3Fh
   |_CODE:CODE:1db7  [1742]          db          FFh
   |_CODE:CODE:1db7.1[1743]          db          3Fh
   |_CODE:CODE:1db8  [1744]          db          FFh
   |_CODE:CODE:1db8.1[1745]          db          3Fh
   |_CODE:CODE:1db9  [1746]          db          FFh
   |_CODE:CODE:1db9.1[1747]          db          3Fh
   |_CODE:CODE:1dba  [1748]          db          FFh
   |_CODE:CODE:1dba.1[1749]          db          3Fh
   |_CODE:CODE:1dbb  [1750]          db          FFh
   |_CODE:CODE:1dbb.1[1751]          db          3Fh
   |_CODE:CODE:1dbc  [1752]          db          FFh
   |_CODE:CODE:1dbc.1[1753]          db          3Fh
   |_CODE:CODE:1dbd  [1754]          db          FFh
   |_CODE:CODE:1dbd.1[1755]          db          3Fh
   |_CODE:CODE:1dbe  [1756]          db          FFh
   |_CODE:CODE:1dbe.1[1757]          db          3Fh
   |_CODE:CODE:1dbf  [1758]          db          FFh
   |_CODE:CODE:1dbf.1[1759]          db          3Fh
   |_CODE:CODE:1dc0  [1760]          db          FFh
   |_CODE:CODE:1dc0.1[1761]          db          3Fh
   |_CODE:CODE:1dc1  [1762]          db          FFh
   |_CODE:CODE:1dc1.1[1763]          db          3Fh
   |_CODE:CODE:1dc2  [1764]          db          FFh
   |_CODE:CODE:1dc2.1[1765]          db          3Fh
   |_CODE:CODE:1dc3  [1766]          db          FFh
   |_CODE:CODE:1dc3.1[1767]          db          3Fh
   |_CODE:CODE:1dc4  [1768]          db          FFh
   |_CODE:CODE:1dc4.1[1769]          db          3Fh
   |_CODE:CODE:1dc5  [1770]          db          FFh
   |_CODE:CODE:1dc5.1[1771]          db          3Fh
   |_CODE:CODE:1dc6  [1772]          db          FFh
   |_CODE:CODE:1dc6.1[1773]          db          3Fh
   |_CODE:CODE:1dc7  [1774]          db          FFh
   |_CODE:CODE:1dc7.1[1775]          db          3Fh
   |_CODE:CODE:1dc8  [1776]          db          FFh
   |_CODE:CODE:1dc8.1[1777]          db          3Fh
   |_CODE:CODE:1dc9  [1778]          db          FFh
   |_CODE:CODE:1dc9.1[1779]          db          3Fh
   |_CODE:CODE:1dca  [1780]          db          FFh
   |_CODE:CODE:1dca.1[1781]          db          3Fh
   |_CODE:CODE:1dcb  [1782]          db          FFh
   |_CODE:CODE:1dcb.1[1783]          db          3Fh
   |_CODE:CODE:1dcc  [1784]          db          FFh
   |_CODE:CODE:1dcc.1[1785]          db          3Fh
   |_CODE:CODE:1dcd  [1786]          db          FFh
   |_CODE:CODE:1dcd.1[1787]          db          3Fh
   |_CODE:CODE:1dce  [1788]          db          FFh
   |_CODE:CODE:1dce.1[1789]          db          3Fh
   |_CODE:CODE:1dcf  [1790]          db          FFh
   |_CODE:CODE:1dcf.1[1791]          db          3Fh
   |_CODE:CODE:1dd0  [1792]          db          FFh
   |_CODE:CODE:1dd0.1[1793]          db          3Fh
   |_CODE:CODE:1dd1  [1794]          db          FFh
   |_CODE:CODE:1dd1.1[1795]          db          3Fh
   |_CODE:CODE:1dd2  [1796]          db          FFh
   |_CODE:CODE:1dd2.1[1797]          db          3Fh
   |_CODE:CODE:1dd3  [1798]          db          FFh
   |_CODE:CODE:1dd3.1[1799]          db          3Fh
   |_CODE:CODE:1dd4  [1800]          db          FFh
   |_CODE:CODE:1dd4.1[1801]          db          3Fh
   |_CODE:CODE:1dd5  [1802]          db          FFh
   |_CODE:CODE:1dd5.1[1803]          db          3Fh
   |_CODE:CODE:1dd6  [1804]          db          FFh
   |_CODE:CODE:1dd6.1[1805]          db          3Fh
   |_CODE:CODE:1dd7  [1806]          db          FFh
   |_CODE:CODE:1dd7.1[1807]          db          3Fh
   |_CODE:CODE:1dd8  [1808]          db          FFh
   |_CODE:CODE:1dd8.1[1809]          db          3Fh
   |_CODE:CODE:1dd9  [1810]          db          FFh
   |_CODE:CODE:1dd9.1[1811]          db          3Fh
   |_CODE:CODE:1dda  [1812]          db          FFh
   |_CODE:CODE:1dda.1[1813]          db          3Fh
   |_CODE:CODE:1ddb  [1814]          db          FFh
   |_CODE:CODE:1ddb.1[1815]          db          3Fh
   |_CODE:CODE:1ddc  [1816]          db          FFh
   |_CODE:CODE:1ddc.1[1817]          db          3Fh
   |_CODE:CODE:1ddd  [1818]          db          FFh
   |_CODE:CODE:1ddd.1[1819]          db          3Fh
   |_CODE:CODE:1dde  [1820]          db          FFh
   |_CODE:CODE:1dde.1[1821]          db          3Fh
   |_CODE:CODE:1ddf  [1822]          db          FFh
   |_CODE:CODE:1ddf.1[1823]          db          3Fh
   |_CODE:CODE:1de0  [1824]          db          FFh
   |_CODE:CODE:1de0.1[1825]          db          3Fh
   |_CODE:CODE:1de1  [1826]          db          FFh
   |_CODE:CODE:1de1.1[1827]          db          3Fh
   |_CODE:CODE:1de2  [1828]          db          FFh
   |_CODE:CODE:1de2.1[1829]          db          3Fh
   |_CODE:CODE:1de3  [1830]          db          FFh
   |_CODE:CODE:1de3.1[1831]          db          3Fh
   |_CODE:CODE:1de4  [1832]          db          FFh
   |_CODE:CODE:1de4.1[1833]          db          3Fh
   |_CODE:CODE:1de5  [1834]          db          FFh
   |_CODE:CODE:1de5.1[1835]          db          3Fh
   |_CODE:CODE:1de6  [1836]          db          FFh
   |_CODE:CODE:1de6.1[1837]          db          3Fh
   |_CODE:CODE:1de7  [1838]          db          FFh
   |_CODE:CODE:1de7.1[1839]          db          3Fh
   |_CODE:CODE:1de8  [1840]          db          FFh
   |_CODE:CODE:1de8.1[1841]          db          3Fh
   |_CODE:CODE:1de9  [1842]          db          FFh
   |_CODE:CODE:1de9.1[1843]          db          3Fh
   |_CODE:CODE:1dea  [1844]          db          FFh
   |_CODE:CODE:1dea.1[1845]          db          3Fh
   |_CODE:CODE:1deb  [1846]          db          FFh
   |_CODE:CODE:1deb.1[1847]          db          3Fh
   |_CODE:CODE:1dec  [1848]          db          FFh
   |_CODE:CODE:1dec.1[1849]          db          3Fh
   |_CODE:CODE:1ded  [1850]          db          FFh
   |_CODE:CODE:1ded.1[1851]          db          3Fh
   |_CODE:CODE:1dee  [1852]          db          FFh
   |_CODE:CODE:1dee.1[1853]          db          3Fh
   |_CODE:CODE:1def  [1854]          db          FFh
   |_CODE:CODE:1def.1[1855]          db          3Fh
   |_CODE:CODE:1df0  [1856]          db          FFh
   |_CODE:CODE:1df0.1[1857]          db          3Fh
   |_CODE:CODE:1df1  [1858]          db          FFh
   |_CODE:CODE:1df1.1[1859]          db          3Fh
   |_CODE:CODE:1df2  [1860]          db          FFh
   |_CODE:CODE:1df2.1[1861]          db          3Fh
   |_CODE:CODE:1df3  [1862]          db          FFh
   |_CODE:CODE:1df3.1[1863]          db          3Fh
   |_CODE:CODE:1df4  [1864]          db          FFh
   |_CODE:CODE:1df4.1[1865]          db          3Fh
   |_CODE:CODE:1df5  [1866]          db          FFh
   |_CODE:CODE:1df5.1[1867]          db          3Fh
   |_CODE:CODE:1df6  [1868]          db          FFh
   |_CODE:CODE:1df6.1[1869]          db          3Fh
   |_CODE:CODE:1df7  [1870]          db          FFh
   |_CODE:CODE:1df7.1[1871]          db          3Fh
   |_CODE:CODE:1df8  [1872]          db          FFh
   |_CODE:CODE:1df8.1[1873]          db          3Fh
   |_CODE:CODE:1df9  [1874]          db          FFh
   |_CODE:CODE:1df9.1[1875]          db          3Fh
   |_CODE:CODE:1dfa  [1876]          db          FFh
   |_CODE:CODE:1dfa.1[1877]          db          3Fh
   |_CODE:CODE:1dfb  [1878]          db          FFh
   |_CODE:CODE:1dfb.1[1879]          db          3Fh
   |_CODE:CODE:1dfc  [1880]          db          FFh
   |_CODE:CODE:1dfc.1[1881]          db          3Fh
   |_CODE:CODE:1dfd  [1882]          db          FFh
   |_CODE:CODE:1dfd.1[1883]          db          3Fh
   |_CODE:CODE:1dfe  [1884]          db          FFh
   |_CODE:CODE:1dfe.1[1885]          db          3Fh
   |_CODE:CODE:1dff  [1886]          db          FFh
   |_CODE:CODE:1dff.1[1887]          db          3Fh
   |_CODE:CODE:1e00  [1888]          db          FFh
   |_CODE:CODE:1e00.1[1889]          db          3Fh
   |_CODE:CODE:1e01  [1890]          db          FFh
   |_CODE:CODE:1e01.1[1891]          db          3Fh
   |_CODE:CODE:1e02  [1892]          db          FFh
   |_CODE:CODE:1e02.1[1893]          db          3Fh
   |_CODE:CODE:1e03  [1894]          db          FFh
   |_CODE:CODE:1e03.1[1895]          db          3Fh
   |_CODE:CODE:1e04  [1896]          db          FFh
   |_CODE:CODE:1e04.1[1897]          db          3Fh
   |_CODE:CODE:1e05  [1898]          db          FFh
   |_CODE:CODE:1e05.1[1899]          db          3Fh
   |_CODE:CODE:1e06  [1900]          db          FFh
   |_CODE:CODE:1e06.1[1901]          db          3Fh
   |_CODE:CODE:1e07  [1902]          db          FFh
   |_CODE:CODE:1e07.1[1903]          db          3Fh
   |_CODE:CODE:1e08  [1904]          db          FFh
   |_CODE:CODE:1e08.1[1905]          db          3Fh
   |_CODE:CODE:1e09  [1906]          db          FFh
   |_CODE:CODE:1e09.1[1907]          db          3Fh
   |_CODE:CODE:1e0a  [1908]          db          FFh
   |_CODE:CODE:1e0a.1[1909]          db          3Fh
   |_CODE:CODE:1e0b  [1910]          db          FFh
   |_CODE:CODE:1e0b.1[1911]          db          3Fh
   |_CODE:CODE:1e0c  [1912]          db          FFh
   |_CODE:CODE:1e0c.1[1913]          db          3Fh
   |_CODE:CODE:1e0d  [1914]          db          FFh
   |_CODE:CODE:1e0d.1[1915]          db          3Fh
   |_CODE:CODE:1e0e  [1916]          db          FFh
   |_CODE:CODE:1e0e.1[1917]          db          3Fh
   |_CODE:CODE:1e0f  [1918]          db          FFh
   |_CODE:CODE:1e0f.1[1919]          db          3Fh
   |_CODE:CODE:1e10  [1920]          db          FFh
   |_CODE:CODE:1e10.1[1921]          db          3Fh
   |_CODE:CODE:1e11  [1922]          db          FFh
   |_CODE:CODE:1e11.1[1923]          db          3Fh
   |_CODE:CODE:1e12  [1924]          db          FFh
   |_CODE:CODE:1e12.1[1925]          db          3Fh
   |_CODE:CODE:1e13  [1926]          db          FFh
   |_CODE:CODE:1e13.1[1927]          db          3Fh
   |_CODE:CODE:1e14  [1928]          db          FFh
   |_CODE:CODE:1e14.1[1929]          db          3Fh
   |_CODE:CODE:1e15  [1930]          db          FFh
   |_CODE:CODE:1e15.1[1931]          db          3Fh
   |_CODE:CODE:1e16  [1932]          db          FFh
   |_CODE:CODE:1e16.1[1933]          db          3Fh
   |_CODE:CODE:1e17  [1934]          db          FFh
   |_CODE:CODE:1e17.1[1935]          db          3Fh
   |_CODE:CODE:1e18  [1936]          db          FFh
   |_CODE:CODE:1e18.1[1937]          db          3Fh
   |_CODE:CODE:1e19  [1938]          db          FFh
   |_CODE:CODE:1e19.1[1939]          db          3Fh
   |_CODE:CODE:1e1a  [1940]          db          FFh
   |_CODE:CODE:1e1a.1[1941]          db          3Fh
   |_CODE:CODE:1e1b  [1942]          db          FFh
   |_CODE:CODE:1e1b.1[1943]          db          3Fh
   |_CODE:CODE:1e1c  [1944]          db          FFh
   |_CODE:CODE:1e1c.1[1945]          db          3Fh
   |_CODE:CODE:1e1d  [1946]          db          FFh
   |_CODE:CODE:1e1d.1[1947]          db          3Fh
   |_CODE:CODE:1e1e  [1948]          db          FFh
   |_CODE:CODE:1e1e.1[1949]          db          3Fh
   |_CODE:CODE:1e1f  [1950]          db          FFh
   |_CODE:CODE:1e1f.1[1951]          db          3Fh
   |_CODE:CODE:1e20  [1952]          db          FFh
   |_CODE:CODE:1e20.1[1953]          db          3Fh
   |_CODE:CODE:1e21  [1954]          db          FFh
   |_CODE:CODE:1e21.1[1955]          db          3Fh
   |_CODE:CODE:1e22  [1956]          db          FFh
   |_CODE:CODE:1e22.1[1957]          db          3Fh
   |_CODE:CODE:1e23  [1958]          db          FFh
   |_CODE:CODE:1e23.1[1959]          db          3Fh
   |_CODE:CODE:1e24  [1960]          db          FFh
   |_CODE:CODE:1e24.1[1961]          db          3Fh
   |_CODE:CODE:1e25  [1962]          db          FFh
   |_CODE:CODE:1e25.1[1963]          db          3Fh
   |_CODE:CODE:1e26  [1964]          db          FFh
   |_CODE:CODE:1e26.1[1965]          db          3Fh
   |_CODE:CODE:1e27  [1966]          db          FFh
   |_CODE:CODE:1e27.1[1967]          db          3Fh
   |_CODE:CODE:1e28  [1968]          db          FFh
   |_CODE:CODE:1e28.1[1969]          db          3Fh
   |_CODE:CODE:1e29  [1970]          db          FFh
   |_CODE:CODE:1e29.1[1971]          db          3Fh
   |_CODE:CODE:1e2a  [1972]          db          FFh
   |_CODE:CODE:1e2a.1[1973]          db          3Fh
   |_CODE:CODE:1e2b  [1974]          db          FFh
   |_CODE:CODE:1e2b.1[1975]          db          3Fh
   |_CODE:CODE:1e2c  [1976]          db          FFh
   |_CODE:CODE:1e2c.1[1977]          db          3Fh
   |_CODE:CODE:1e2d  [1978]          db          FFh
   |_CODE:CODE:1e2d.1[1979]          db          3Fh
   |_CODE:CODE:1e2e  [1980]          db          FFh
   |_CODE:CODE:1e2e.1[1981]          db          3Fh
   |_CODE:CODE:1e2f  [1982]          db          FFh
   |_CODE:CODE:1e2f.1[1983]          db          3Fh
   |_CODE:CODE:1e30  [1984]          db          FFh
   |_CODE:CODE:1e30.1[1985]          db          3Fh
   |_CODE:CODE:1e31  [1986]          db          FFh
   |_CODE:CODE:1e31.1[1987]          db          3Fh
   |_CODE:CODE:1e32  [1988]          db          FFh
   |_CODE:CODE:1e32.1[1989]          db          3Fh
   |_CODE:CODE:1e33  [1990]          db          FFh
   |_CODE:CODE:1e33.1[1991]          db          3Fh
   |_CODE:CODE:1e34  [1992]          db          FFh
   |_CODE:CODE:1e34.1[1993]          db          3Fh
   |_CODE:CODE:1e35  [1994]          db          FFh
   |_CODE:CODE:1e35.1[1995]          db          3Fh
   |_CODE:CODE:1e36  [1996]          db          FFh
   |_CODE:CODE:1e36.1[1997]          db          3Fh
   |_CODE:CODE:1e37  [1998]          db          FFh
   |_CODE:CODE:1e37.1[1999]          db          3Fh
   |_CODE:CODE:1e38  [2000]          db          FFh
   |_CODE:CODE:1e38.1[2001]          db          3Fh
   |_CODE:CODE:1e39  [2002]          db          FFh
   |_CODE:CODE:1e39.1[2003]          db          3Fh
   |_CODE:CODE:1e3a  [2004]          db          FFh
   |_CODE:CODE:1e3a.1[2005]          db          3Fh
   |_CODE:CODE:1e3b  [2006]          db          FFh
   |_CODE:CODE:1e3b.1[2007]          db          3Fh
   |_CODE:CODE:1e3c  [2008]          db          FFh
   |_CODE:CODE:1e3c.1[2009]          db          3Fh
   |_CODE:CODE:1e3d  [2010]          db          FFh
   |_CODE:CODE:1e3d.1[2011]          db          3Fh
   |_CODE:CODE:1e3e  [2012]          db          FFh
   |_CODE:CODE:1e3e.1[2013]          db          3Fh
   |_CODE:CODE:1e3f  [2014]          db          FFh
   |_CODE:CODE:1e3f.1[2015]          db          3Fh
   |_CODE:CODE:1e40  [2016]          db          FFh
   |_CODE:CODE:1e40.1[2017]          db          3Fh
   |_CODE:CODE:1e41  [2018]          db          FFh
   |_CODE:CODE:1e41.1[2019]          db          3Fh
   |_CODE:CODE:1e42  [2020]          db          FFh
   |_CODE:CODE:1e42.1[2021]          db          3Fh
   |_CODE:CODE:1e43  [2022]          db          FFh
   |_CODE:CODE:1e43.1[2023]          db          3Fh
   |_CODE:CODE:1e44  [2024]          db          FFh
   |_CODE:CODE:1e44.1[2025]          db          3Fh
   |_CODE:CODE:1e45  [2026]          db          FFh
   |_CODE:CODE:1e45.1[2027]          db          3Fh
   |_CODE:CODE:1e46  [2028]          db          FFh
   |_CODE:CODE:1e46.1[2029]          db          3Fh
   |_CODE:CODE:1e47  [2030]          db          FFh
   |_CODE:CODE:1e47.1[2031]          db          3Fh
   |_CODE:CODE:1e48  [2032]          db          FFh
   |_CODE:CODE:1e48.1[2033]          db          3Fh
   |_CODE:CODE:1e49  [2034]          db          FFh
   |_CODE:CODE:1e49.1[2035]          db          3Fh
   |_CODE:CODE:1e4a  [2036]          db          FFh
   |_CODE:CODE:1e4a.1[2037]          db          3Fh
   |_CODE:CODE:1e4b  [2038]          db          FFh
   |_CODE:CODE:1e4b.1[2039]          db          3Fh
   |_CODE:CODE:1e4c  [2040]          db          FFh
   |_CODE:CODE:1e4c.1[2041]          db          3Fh
   |_CODE:CODE:1e4d  [2042]          db          FFh
   |_CODE:CODE:1e4d.1[2043]          db          3Fh
   |_CODE:CODE:1e4e  [2044]          db          FFh
   |_CODE:CODE:1e4e.1[2045]          db          3Fh
   |_CODE:CODE:1e4f  [2046]          db          FFh
   |_CODE:CODE:1e4f.1[2047]          db          3Fh
   |_CODE:CODE:1e50  [2048]          db          FFh
   |_CODE:CODE:1e50.1[2049]          db          3Fh
   |_CODE:CODE:1e51  [2050]          db          FFh
   |_CODE:CODE:1e51.1[2051]          db          3Fh
   |_CODE:CODE:1e52  [2052]          db          FFh
   |_CODE:CODE:1e52.1[2053]          db          3Fh
   |_CODE:CODE:1e53  [2054]          db          FFh
   |_CODE:CODE:1e53.1[2055]          db          3Fh
   |_CODE:CODE:1e54  [2056]          db          FFh
   |_CODE:CODE:1e54.1[2057]          db          3Fh
   |_CODE:CODE:1e55  [2058]          db          FFh
   |_CODE:CODE:1e55.1[2059]          db          3Fh
   |_CODE:CODE:1e56  [2060]          db          FFh
   |_CODE:CODE:1e56.1[2061]          db          3Fh
   |_CODE:CODE:1e57  [2062]          db          FFh
   |_CODE:CODE:1e57.1[2063]          db          3Fh
   |_CODE:CODE:1e58  [2064]          db          FFh
   |_CODE:CODE:1e58.1[2065]          db          3Fh
   |_CODE:CODE:1e59  [2066]          db          FFh
   |_CODE:CODE:1e59.1[2067]          db          3Fh
   |_CODE:CODE:1e5a  [2068]          db          FFh
   |_CODE:CODE:1e5a.1[2069]          db          3Fh
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void interrupt_handler_ssp(void)
          ;tmp_PIR1      undefined1     HASH...
          ;received_byte undefined1     HASH...
                                                          ;XREF[1,0]:   CODE:0027
CODE:CODE:1e5b  8301            CLRF        STATUS
                            ;clear SSPIF (synchronous serial port flag) from PIR1
CODE:CODE:1e5c  8c11            BCF         BANK-0:PIR1,#0x3                        ;= ??
CODE:CODE:1e5d  4008            MOVF        BANK-0:SSP_PACKET_SIZE,w                ;= ??
CODE:CODE:1e5e  313e            ADDLW       #0x31
CODE:CODE:1e5f  8400            MOVWF       FSR0L=>BANK-0:FSR                       ;= ??
CODE:CODE:1e60  8317            BSF         STATUS,IRP
CODE:CODE:1e61  1308            MOVF        BANK-0:SSPBUF,w                         ;= ??
CODE:CODE:1e62  8000            MOVWF       INDF0=>BANK-2:SSP_BUFFER                ;= ??
CODE:CODE:1e63  c00a            INCF        BANK-0:SSP_PACKET_SIZE,f                ;= ??
CODE:CODE:1e64  4108            MOVF        BANK-0:SSP_UNK1_PACKET_SIZE_MAX,w       ;= ??
CODE:CODE:1e65  4002            SUBWF       BANK-0:SSP_PACKET_SIZE,w                ;= ??
CODE:CODE:1e66  0318            BTFSC       STATUS,#0x0
CODE:CODE:1e67  6b2e            GOTO        offset LAB_CODE_1e6b-0x1800
CODE:CODE:1e68  0930            MOVLW       #0x9
CODE:CODE:1e69  c400            MOVWF       BANK-0:SSP_UNK2                         ;= ??
CODE:CODE:1e6a  0800            RETURN
                            LAB_CODE_1e6b:                ;XREF[1,0]:   CODE:1e67
CODE:CODE:1e6b  8316            BSF         STATUS,RP0
CODE:CODE:1e6c  8c11            BCF         BANK-1:PIE1,#0x3                        ;= ??
CODE:CODE:1e6d  8312            BCF         STATUS,RP0
CODE:CODE:1e6e  ad16            BSF         BANK-1:SSP_UNK4,#0x5                    ;= ??
CODE:CODE:1e6f  2d12            BCF         BANK-1:SSP_UNK4,#0x4                    ;= ??
CODE:CODE:1e70  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined delay_2ms()
                                                          ;XREF[3,0]:   CODE:0131,CODE:0136,CODE:1013
CODE:CODE:1e71  8301            CLRF        STATUS
CODE:CODE:1e72  d200            MOVWF       BANK-0:INIT_ST1_UNK1                    ;= ??
                            LAB_CODE_1e73:                ;XREF[1,0]:   CODE:1e7d
CODE:CODE:1e73  0430            MOVLW       #0x4
CODE:CODE:1e74  d300            MOVWF       BANK-0:INIT_ST1_UNK2                    ;= ??
                            LAB_CODE_1e75:                ;XREF[1,0]:   CODE:1e7b
CODE:CODE:1e75  a630            MOVLW       #0xa6
CODE:CODE:1e76  d400            MOVWF       BANK-0:INIT_ST1_UNK3                    ;= ??
                            LAB_CODE_1e77:                ;XREF[1,0]:   CODE:1e78
CODE:CODE:1e77  d40b            DECFSZ      BANK-0:INIT_ST1_UNK3,f                  ;= ??
CODE:CODE:1e78  772e            GOTO        offset LAB_CODE_1e77-0x1800
CODE:CODE:1e79  6400            CLRWDT
CODE:CODE:1e7a  d30b            DECFSZ      BANK-0:INIT_ST1_UNK2,f                  ;= ??
CODE:CODE:1e7b  752e            GOTO        offset LAB_CODE_1e75-0x1800
CODE:CODE:1e7c  d20b            DECFSZ      BANK-0:INIT_ST1_UNK1,f                  ;= ??
CODE:CODE:1e7d  732e            GOTO        offset LAB_CODE_1e73-0x1800
CODE:CODE:1e7e  0800            RETURN
                            UNKNOWN_DATA_3:
CODE:CODE:1e7f  83              ??          83h
CODE:CODE:1e7f.101              ??          01h
CODE:CODE:1e80  ca              ??          CAh
CODE:CODE:1e80.100              ??          00h
CODE:CODE:1e81  04              ??          04h
CODE:CODE:1e81.130              ??          30h    0
CODE:CODE:1e82  cb              ??          CBh
CODE:CODE:1e82.100              ??          00h
CODE:CODE:1e83  fa              ??          FAh
CODE:CODE:1e83.130              ??          30h    0
CODE:CODE:1e84  71              ??          71h    q
CODE:CODE:1e84.126              ??          26h    &
CODE:CODE:1e85  64              ??          64h    d
CODE:CODE:1e85.100              ??          00h
CODE:CODE:1e86  cb              ??          CBh
CODE:CODE:1e86.10b              ??          0Bh
CODE:CODE:1e87  83              ??          83h
CODE:CODE:1e87.12e              ??          2Eh    .
CODE:CODE:1e88  ca              ??          CAh
CODE:CODE:1e88.10b              ??          0Bh
CODE:CODE:1e89  81              ??          81h
CODE:CODE:1e89.12e              ??          2Eh    .
CODE:CODE:1e8a  08              ??          08h
CODE:CODE:1e8a.100              ??          00h
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined init_hardware_2()
                                                          ;XREF[1,0]:   CODE:101b
CODE:CODE:1e8b  c630            MOVLW       #0xc6
CODE:CODE:1e8c  8316            BSF         STATUS,RP0
CODE:CODE:1e8d  0313            BCF         STATUS,RP1
CODE:CODE:1e8e  8100            MOVWF       INDF1
CODE:CODE:1e8f  fd30            MOVLW       #0xfd
CODE:CODE:1e90  8312            BCF         STATUS,RP0
CODE:CODE:1e91  8100            MOVWF       INDF1
CODE:CODE:1e92  0b11            BCF         INTCON,TMR0IF
CODE:CODE:1e93  8b16            BSF         INTCON,TMR0IE
CODE:CODE:1e94  0130            MOVLW       #0x1
CODE:CODE:1e95  9000            MOVWF       0x10
CODE:CODE:1e96  a330            MOVLW       #0xa3
CODE:CODE:1e97  8e00            MOVWF       0xe
CODE:CODE:1e98  fc30            MOVLW       #0xfc
CODE:CODE:1e99  8f00            MOVWF       0xf
CODE:CODE:1e9a  0c10            BCF         0xc,#0x0
CODE:CODE:1e9b  8316            BSF         STATUS,RP0
CODE:CODE:1e9c  0c14            BSF         0xc,#0x0
CODE:CODE:1e9d  ac30            MOVLW       #0xac
CODE:CODE:1e9e  8312            BCF         STATUS,RP0
CODE:CODE:1e9f  9700            MOVWF       0x17
CODE:CODE:1ea0  7d30            MOVLW       #0x7d
CODE:CODE:1ea1  8316            BSF         STATUS,RP0
CODE:CODE:1ea2  9200            MOVWF       0x12
CODE:CODE:1ea3  3e30            MOVLW       #0x3e
CODE:CODE:1ea4  8312            BCF         STATUS,RP0
CODE:CODE:1ea5  9500            MOVWF       0x15
CODE:CODE:1ea6  0130            MOVLW       #0x1
CODE:CODE:1ea7  9200            MOVWF       0x12
CODE:CODE:1ea8  1a30            MOVLW       #0x1a
CODE:CODE:1ea9  8316            BSF         STATUS,RP0
CODE:CODE:1eaa  b600            MOVWF       0x36
CODE:CODE:1eab  0a30            MOVLW       #0xa
CODE:CODE:1eac  b500            MOVWF       0x35
CODE:CODE:1ead  b700            MOVWF       0x37
CODE:CODE:1eae  1e30            MOVLW       #0x1e
CODE:CODE:1eaf  be00            MOVWF       0x3e
CODE:CODE:1eb0  4630            MOVLW       #0x46
CODE:CODE:1eb1  bc00            MOVWF       0x3c
CODE:CODE:1eb2  1e30            MOVLW       #0x1e
CODE:CODE:1eb3  c900            MOVWF       0x49
CODE:CODE:1eb4  3c30            MOVLW       #0x3c
CODE:CODE:1eb5  cb00            MOVWF       0x4b
CODE:CODE:1eb6  3230            MOVLW       #0x32
CODE:CODE:1eb7  c700            MOVWF       0x47
CODE:CODE:1eb8  c800            MOVWF       0x48
CODE:CODE:1eb9  1e30            MOVLW       #0x1e
CODE:CODE:1eba  cd00            MOVWF       0x4d
CODE:CODE:1ebb  0a30            MOVLW       #0xa
CODE:CODE:1ebc  b900            MOVWF       0x39
CODE:CODE:1ebd  8312            BCF         STATUS,RP0
CODE:CODE:1ebe  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void interrupt_handler_timer1(void)
          ;tmp_PIR1      undefined1     HASH...
          ;tmp_TIMER1... byte           HASH...
                                                          ;XREF[1,0]:   CODE:003a
CODE:CODE:1ebf  8301            CLRF        STATUS
                            ;Clear TMR1IF (timer 1 overflow interrupt flag) in PIR
                            ;
CODE:CODE:1ec0  0c10            BCF         BANK-0:PIR1,#0x0                        ;= ??
                            ;Set timer to 0xfca3 (or 64675)
                            ;so there's 860 steps to overflow
CODE:CODE:1ec1  a330            MOVLW       #0xa3
CODE:CODE:1ec2  8e00            MOVWF       BANK-0:TMR1L                            ;= ??
CODE:CODE:1ec3  fc30            MOVLW       #0xfc
CODE:CODE:1ec4  8f00            MOVWF       BANK-0:TMR1H                            ;= ??
CODE:CODE:1ec5  8316            BSF         STATUS,RP0
CODE:CODE:1ec6  0317            BSF         STATUS,RP1
CODE:CODE:1ec7  101e            BTFSS       BANK-3:TIMER1_UNK1,#0x4                 ;= ??
CODE:CODE:1ec8  f92e            GOTO        offset LAB_CODE_1ef9-0x1800
                            ;Define UNK3 (the limit for UNK6 counter)
CODE:CODE:1ec9  8312            BCF         STATUS,RP0
CODE:CODE:1eca  0313            BCF         STATUS,RP1
CODE:CODE:1ecb  361f            BTFSS       BANK-0:TIMER1_UNK2,#0x6                 ;= ??
CODE:CODE:1ecc  d12e            GOTO        offset LAB_CODE_1ed1-0x1800
CODE:CODE:1ecd  8316            BSF         STATUS,RP0
CODE:CODE:1ece  e601            CLRF        BANK-1:TIMER1_UNK3                      ;= ??
CODE:CODE:1ecf  e60a            INCF        BANK-1:TIMER1_UNK3,f                    ;= ??
CODE:CODE:1ed0  e62e            GOTO        offset LAB_CODE_1ee6-0x1800
                            LAB_CODE_1ed1:                ;XREF[1,0]:   CODE:1ecc
CODE:CODE:1ed1  3a08            MOVF        BANK-0:TIMER1_UNK4,w                    ;= ??
CODE:CODE:1ed2  3f39            ANDLW       #0x3f
CODE:CODE:1ed3  031d            BTFSS       STATUS,#0x2
CODE:CODE:1ed4  dd2e            GOTO        offset LAB_CODE_1edd-0x1800
CODE:CODE:1ed5  231a            BTFSC       BANK-0:TIMER1_UNK5,#0x4                 ;= ??
CODE:CODE:1ed6  d92e            GOTO        offset LAB_CODE_1ed9-0x1800
CODE:CODE:1ed7  a31d            BTFSS       BANK-0:TIMER1_UNK5,#0x3                 ;= ??
CODE:CODE:1ed8  dd2e            GOTO        offset LAB_CODE_1edd-0x1800
                            LAB_CODE_1ed9:                ;XREF[1,0]:   CODE:1ed6
CODE:CODE:1ed9  0230            MOVLW       #0x2
CODE:CODE:1eda  8316            BSF         STATUS,RP0
CODE:CODE:1edb  e600            MOVWF       BANK-1:TIMER1_UNK3                      ;= ??
CODE:CODE:1edc  e62e            GOTO        offset LAB_CODE_1ee6-0x1800
                            LAB_CODE_1edd:                ;XREF[2,0]:   CODE:1ed4,CODE:1ed8
CODE:CODE:1edd  8316            BSF         STATUS,RP0
CODE:CODE:1ede  e601            CLRF        BANK-1:TIMER1_UNK3                      ;= ??
CODE:CODE:1edf  e62e            GOTO        offset LAB_CODE_1ee6-0x1800
                            LAB_CODE_1ee0:                ;XREF[1,0]:   CODE:1ee9
CODE:CODE:1ee0  8312            BCF         STATUS,RP0
CODE:CODE:1ee1  0513            BCF         FSR0H,#0x6
CODE:CODE:1ee2  f02e            GOTO        offset LAB_CODE_1ef0-0x1800
                            LAB_CODE_1ee3:                ;XREF[2,0]:   CODE:1eec,CODE:1eef
CODE:CODE:1ee3  8312            BCF         STATUS,RP0
CODE:CODE:1ee4  0517            BSF         FSR0H,#0x6
CODE:CODE:1ee5  f02e            GOTO        offset LAB_CODE_1ef0-0x1800
                            LAB_CODE_1ee6:                ;XREF[3,0]:   CODE:1ed0,CODE:1edc,CODE:1edf
CODE:CODE:1ee6  6508            MOVF        BANK-1:TIMER1_UNK6,w                    ;= ??
CODE:CODE:1ee7  003a            XORLW       #0x0
CODE:CODE:1ee8  0319            BTFSC       STATUS,#0x2
CODE:CODE:1ee9  e02e            GOTO        offset LAB_CODE_1ee0-0x1800
CODE:CODE:1eea  013a            XORLW       #0x1
CODE:CODE:1eeb  0319            BTFSC       STATUS,#0x2
CODE:CODE:1eec  e32e            GOTO        offset LAB_CODE_1ee3-0x1800
CODE:CODE:1eed  033a            XORLW       #0x3
CODE:CODE:1eee  0319            BTFSC       STATUS,#0x2
CODE:CODE:1eef  e32e            GOTO        offset LAB_CODE_1ee3-0x1800
                            LAB_CODE_1ef0:                ;XREF[2,0]:   CODE:1ee2,CODE:1ee5
CODE:CODE:1ef0  8316            BSF         STATUS,RP0
                            ;UNK6 is a counter, UNK3 is it's max limit
CODE:CODE:1ef1  6608            MOVF        BANK-1:TIMER1_UNK3,w                    ;= ??
CODE:CODE:1ef2  6502            SUBWF       BANK-1:TIMER1_UNK6,w                    ;= ??
CODE:CODE:1ef3  0318            BTFSC       STATUS,#0x0
CODE:CODE:1ef4  f72e            GOTO        offset LAB_CODE_1ef7-0x1800
CODE:CODE:1ef5  e50a            INCF        BANK-1:TIMER1_UNK6,f                    ;= ??
CODE:CODE:1ef6  fc2e            GOTO        offset LAB_CODE_1efc-0x1800
                            LAB_CODE_1ef7:                ;XREF[1,0]:   CODE:1ef4
CODE:CODE:1ef7  e501            CLRF        BANK-1:TIMER1_UNK6                      ;= ??
CODE:CODE:1ef8  fc2e            GOTO        offset LAB_CODE_1efc-0x1800
                            LAB_CODE_1ef9:                ;XREF[1,0]:   CODE:1ec8
CODE:CODE:1ef9  8312            BCF         STATUS,RP0
CODE:CODE:1efa  0313            BCF         STATUS,RP1
CODE:CODE:1efb  0517            BSF         FSR0H,#0x6
                            LAB_CODE_1efc:                ;XREF[2,0]:   CODE:1ef6,CODE:1ef8
CODE:CODE:1efc  8312            BCF         STATUS,RP0
CODE:CODE:1efd  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;void interrupt_handler_usart_rx(void)
          ;tmp_status    undefined1     Skip...                      ;XREF[1,0]:   CODE:1f0d
          ;tmp_RCSTA     undefined1     HASH...
                                                          ;XREF[1,0]:   CODE:0045
CODE:CODE:1efe  8301            CLRF        STATUS
CODE:CODE:1eff  1819            BTFSC       BANK-0:RCSTA,#0x2                       ;= ??
CODE:CODE:1f00  032f            GOTO        offset LAB_CODE_1f03-0x1800
CODE:CODE:1f01  981c            BTFSS       BANK-0:RCSTA,#0x1                       ;= ??
                            ;Check if there's an framing or overrun error
CODE:CODE:1f02  0b2f            GOTO        offset LAB_CODE_1f0b-0x1800
                            ;Clear CREN (continuous receive enable bit), aka clear overrun error
                            LAB_CODE_1f03:                ;XREF[1,0]:   CODE:1f00
CODE:CODE:1f03  1812            BCF         BANK-0:RCSTA,#0x4                       ;= ??
                            ;Read receive buffer, that clears the framing error
                            ;THIS BYTE IS DISCARDED
CODE:CODE:1f04  1a08            MOVF        BANK-0:RCREG,w                          ;= ??
CODE:CODE:1f05  e500            MOVWF       BANK-0:USART_RX_RCVD_BYTE               ;= ??
CODE:CODE:1f06  8316            BSF         STATUS,RP0
CODE:CODE:1f07  c201            CLRF        BANK-1:USART_RX_BUFFER_INDEX            ;= ??
CODE:CODE:1f08  8312            BCF         STATUS,RP0
                            ;Set CREN (continuous enable bit)
CODE:CODE:1f09  1816            BSF         BANK-0:RCSTA,#0x4                       ;= ??
CODE:CODE:1f0a  452f            GOTO        offset LAB_CODE_1f45-0x1800
                            LAB_CODE_1f0b:                ;XREF[1,0]:   CODE:1f02
CODE:CODE:1f0b  1a08            MOVF        BANK-0:RCREG,w                          ;= ??
CODE:CODE:1f0c  e500            MOVWF       BANK-0:USART_RX_RCVD_BYTE               ;= ??
CODE:CODE:1f0d  ad1d            BTFSS       BANK-0:USART_RX_PACKET_STATUS,#0x3      ;= ??
CODE:CODE:1f0e  2d19            BTFSC       BANK-0:USART_RX_PACKET_STATUS,#0x2      ;= ??
CODE:CODE:1f0f  452f            GOTO        offset LAB_CODE_1f45-0x1800
CODE:CODE:1f10  0230            MOVLW       #0x2
CODE:CODE:1f11  8316            BSF         STATUS,RP0
CODE:CODE:1f12  bf00            MOVWF       BANK-1:USART_RX_UNKNOWN                 ;= ??
CODE:CODE:1f13  c208            MOVF        BANK-1:USART_RX_BUFFER_INDEX,f          ;= ??
CODE:CODE:1f14  031d            BTFSS       STATUS,#0x2
CODE:CODE:1f15  222f            GOTO        offset LAB_CODE_1f22-0x1800
CODE:CODE:1f16  8312            BCF         STATUS,RP0
CODE:CODE:1f17  6508            MOVF        BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f18  0a3a            XORLW       #0xa
CODE:CODE:1f19  031d            BTFSS       STATUS,#0x2
CODE:CODE:1f1a  452f            GOTO        offset LAB_CODE_1f45-0x1800
CODE:CODE:1f1b  6508            MOVF        BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f1c  0317            BSF         STATUS,RP1
CODE:CODE:1f1d  d700            MOVWF       BANK-2:USART_PACKET_BUFFER              ;= ??
CODE:CODE:1f1e  8316            BSF         STATUS,RP0
CODE:CODE:1f1f  0313            BCF         STATUS,RP1
CODE:CODE:1f20  c20a            INCF        BANK-1:USART_RX_BUFFER_INDEX,f          ;= ??
CODE:CODE:1f21  452f            GOTO        offset LAB_CODE_1f45-0x1800
                            LAB_CODE_1f22:                ;XREF[1,0]:   CODE:1f15
CODE:CODE:1f22  420b            DECFSZ      BANK-0:DAT_DATA_0042,w                  ;= ??
CODE:CODE:1f23  372f            GOTO        offset LAB_CODE_1f37-0x1800
CODE:CODE:1f24  1730            MOVLW       #0x17
CODE:CODE:1f25  8312            BCF         STATUS,RP0
CODE:CODE:1f26  6502            SUBWF       BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f27  0318            BTFSC       STATUS,#0x0
CODE:CODE:1f28  342f            GOTO        offset LAB_CODE_1f34-0x1800
CODE:CODE:1f29  6508            MOVF        BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f2a  0317            BSF         STATUS,RP1
CODE:CODE:1f2b  d800            MOVWF       BANK-2:USART_PACKET_BUFFER[1]
CODE:CODE:1f2c  8316            BSF         STATUS,RP0
CODE:CODE:1f2d  0313            BCF         STATUS,RP1
CODE:CODE:1f2e  c20a            INCF        BANK-1:USART_RX_BUFFER_INDEX,f          ;= ??
CODE:CODE:1f2f  8312            BCF         STATUS,RP0
CODE:CODE:1f30  6508            MOVF        BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f31  8316            BSF         STATUS,RP0
CODE:CODE:1f32  c300            MOVWF       BANK-1:USART_RX_PACKET_SIZE             ;= ??
CODE:CODE:1f33  452f            GOTO        offset LAB_CODE_1f45-0x1800
                            LAB_CODE_1f34:                ;XREF[1,0]:   CODE:1f28
CODE:CODE:1f34  8316            BSF         STATUS,RP0
CODE:CODE:1f35  c201            CLRF        BANK-1:USART_RX_BUFFER_INDEX            ;= ??
CODE:CODE:1f36  452f            GOTO        offset LAB_CODE_1f45-0x1800
                            LAB_CODE_1f37:                ;XREF[1,0]:   CODE:1f23
CODE:CODE:1f37  4208            MOVF        BANK-1:USART_RX_BUFFER_INDEX,w          ;= ??
CODE:CODE:1f38  573e            ADDLW       #0x57
CODE:CODE:1f39  8400            MOVWF       FSR0L
CODE:CODE:1f3a  8317            BSF         STATUS,IRP
CODE:CODE:1f3b  8312            BCF         STATUS,RP0
CODE:CODE:1f3c  6508            MOVF        BANK-0:USART_RX_RCVD_BYTE,w             ;= ??
CODE:CODE:1f3d  8000            MOVWF       INDF0
CODE:CODE:1f3e  8316            BSF         STATUS,RP0
CODE:CODE:1f3f  c20a            INCF        BANK-1:USART_RX_BUFFER_INDEX,f          ;= ??
CODE:CODE:1f40  4208            MOVF        BANK-1:USART_RX_BUFFER_INDEX,w          ;= ??
CODE:CODE:1f41  4302            SUBWF       BANK-1:USART_RX_PACKET_SIZE,w           ;= ??
CODE:CODE:1f42  8312            BCF         STATUS,RP0
CODE:CODE:1f43  031c            BTFSS       STATUS,#0x0
CODE:CODE:1f44  ad15            BSF         BANK-0:USART_RX_PACKET_STATUS,#0x3      ;= ??
                            LAB_CODE_1f45:                ;XREF[6,0]:   CODE:1f0a,CODE:1f0f,CODE:1f1a,CODE:1f21
                                                          ;             CODE:1f33,CODE:1f36
CODE:CODE:1f45  8312            BCF         STATUS,RP0
CODE:CODE:1f46  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;undefined init_hardware_1()
          ;tmp           undefined1     HASH...
                                                          ;XREF[1,0]:   CODE:1016
CODE:CODE:1f47  8b13            BCF         INTCON,GIE
CODE:CODE:1f48  0b13            BCF         INTCON,PEIE
CODE:CODE:1f49  7030            MOVLW       #0x70
CODE:CODE:1f4a  8316            BSF         STATUS,RP0
CODE:CODE:1f4b  0313            BCF         STATUS,RP1
CODE:CODE:1f4c  8f00            MOVWF       0xf
CODE:CODE:1f4d  c630            MOVLW       #0xc6
CODE:CODE:1f4e  8100            MOVWF       INDF1
CODE:CODE:1f4f  8b01            CLRF        INTCON
CODE:CODE:1f50  8c01            CLRF        0xc
CODE:CODE:1f51  8d01            CLRF        0xd
CODE:CODE:1f52  8e01            CLRF        0xe
CODE:CODE:1f53  8312            BCF         STATUS,RP0
CODE:CODE:1f54  8c01            CLRF        0xc
CODE:CODE:1f55  8d01            CLRF        0xd
CODE:CODE:1f56  8316            BSF         STATUS,RP0
CODE:CODE:1f57  9501            CLRF        0x15
CODE:CODE:1f58  8501            CLRF        FSR0H
CODE:CODE:1f59  e030            MOVLW       #0xe0
CODE:CODE:1f5a  8600            MOVWF       FSR1L
CODE:CODE:1f5b  9601            CLRF        0x16
CODE:CODE:1f5c  fd30            MOVLW       #0xfd
CODE:CODE:1f5d  8312            BCF         STATUS,RP0
CODE:CODE:1f5e  8100            MOVWF       INDF1
CODE:CODE:1f5f  8b12            BCF         INTCON,TMR0IE
CODE:CODE:1f60  0130            MOVLW       #0x1
CODE:CODE:1f61  9000            MOVWF       0x10
CODE:CODE:1f62  8316            BSF         STATUS,RP0
CODE:CODE:1f63  0c10            BCF         0xc,#0x0
CODE:CODE:1f64  8312            BCF         STATUS,RP0
CODE:CODE:1f65  9101            CLRF        0x11
CODE:CODE:1f66  8730            MOVLW       #0x87
CODE:CODE:1f67  8316            BSF         STATUS,RP0
CODE:CODE:1f68  8700            MOVWF       FSR1H
CODE:CODE:1f69  0130            MOVLW       #0x1
CODE:CODE:1f6a  8312            BCF         STATUS,RP0
CODE:CODE:1f6b  9200            MOVWF       0x12
CODE:CODE:1f6c  ac30            MOVLW       #0xac
CODE:CODE:1f6d  9700            MOVWF       0x17
CODE:CODE:1f6e  5030            MOVLW       #0x50
CODE:CODE:1f6f  8316            BSF         STATUS,RP0
CODE:CODE:1f70  9f00            MOVWF       0x1f
CODE:CODE:1f71  8312            BCF         STATUS,RP0
CODE:CODE:1f72  9f01            CLRF        0x1f
CODE:CODE:1f73  8316            BSF         STATUS,RP0
CODE:CODE:1f74  9101            CLRF        0x11
CODE:CODE:1f75  8312            BCF         STATUS,RP0
CODE:CODE:1f76  0317            BSF         STATUS,RP1
CODE:CODE:1f77  8701            CLRF        FSR1H
CODE:CODE:1f78  9c01            CLRF        0x1c
CODE:CODE:1f79  9d01            CLRF        0x1d
CODE:CODE:1f7a  9e01            CLRF        0x1e
CODE:CODE:1f7b  8901            CLRF        W
CODE:CODE:1f7c  8316            BSF         STATUS,RP0
CODE:CODE:1f7d  0313            BCF         STATUS,RP1
CODE:CODE:1f7e  9401            CLRF        0x14
CODE:CODE:1f7f  8312            BCF         STATUS,RP0
CODE:CODE:1f80  9401            CLRF        0x14
CODE:CODE:1f81  8316            BSF         STATUS,RP0
CODE:CODE:1f82  0317            BSF         STATUS,RP1
CODE:CODE:1f83  8c01            CLRF        0xc
CODE:CODE:1f84  ff30            MOVLW       #0xff
CODE:CODE:1f85  0313            BCF         STATUS,RP1
CODE:CODE:1f86  9c00            MOVWF       0x1c
CODE:CODE:1f87  9d01            CLRF        0x1d
CODE:CODE:1f88  8312            BCF         STATUS,RP0
CODE:CODE:1f89  be01            CLRF        0x3e
CODE:CODE:1f8a  bf01            CLRF        0x3f
CODE:CODE:1f8b  b201            CLRF        0x32
CODE:CODE:1f8c  b401            CLRF        0x34
CODE:CODE:1f8d  b301            CLRF        0x33
CODE:CODE:1f8e  b501            CLRF        0x35
CODE:CODE:1f8f  8316            BSF         STATUS,RP0
CODE:CODE:1f90  a001            CLRF        0x20
CODE:CODE:1f91  b401            CLRF        0x34
CODE:CODE:1f92  b201            CLRF        0x32
CODE:CODE:1f93  0317            BSF         STATUS,RP1
CODE:CODE:1f94  9001            CLRF        0x10
CODE:CODE:1f95  8301            CLRF        STATUS
CODE:CODE:1f96  0800            RETURN
                            ;************************************************************************************************
                            ;*                                           FUNCTION                                           *
                            ;************************************************************************************************
                            ;char interrupt_handler_timer0(void)
                                                          ;XREF[1,0]:   CODE:002f
CODE:CODE:1f97  fd30            MOVLW       #0xfd
CODE:CODE:1f98  8301            CLRF        STATUS
CODE:CODE:1f99  8100            MOVWF       INDF1
CODE:CODE:1f9a  0b11            BCF         INTCON,TMR0IF
CODE:CODE:1f9b  361d            BTFSS       0x36,#0x2
CODE:CODE:1f9c  b12f            GOTO        offset LAB_CODE_1fb1-0x1800
CODE:CODE:1f9d  8316            BSF         STATUS,RP0
CODE:CODE:1f9e  3308            MOVF        0x33,w
CODE:CODE:1f9f  0a3a            XORLW       #0xa
CODE:CODE:1fa0  0319            BTFSC       STATUS,#0x2
CODE:CODE:1fa1  a62f            GOTO        offset LAB_CODE_1fa6-0x1800
CODE:CODE:1fa2  3308            MOVF        0x33,w
CODE:CODE:1fa3  323a            XORLW       #0x32
CODE:CODE:1fa4  031d            BTFSS       STATUS,#0x2
CODE:CODE:1fa5  ab2f            GOTO        offset LAB_CODE_1fab-0x1800
                            LAB_CODE_1fa6:                ;XREF[1,0]:   CODE:1fa1
CODE:CODE:1fa6  ac30            MOVLW       #0xac
CODE:CODE:1fa7  8312            BCF         STATUS,RP0
CODE:CODE:1fa8  9700            MOVWF       BANK-0:CCP1CON                          ;= ??
CODE:CODE:1fa9  1215            BSF         BANK-0:T2CON,#0x2                       ;= ??
CODE:CODE:1faa  b42f            GOTO        offset LAB_CODE_1fb4-0x1800
                            LAB_CODE_1fab:                ;XREF[1,0]:   CODE:1fa5
CODE:CODE:1fab  b308            MOVF        BANK-0:BYTE_DATA_0033,f                 ;= ??
CODE:CODE:1fac  0319            BTFSC       STATUS,#0x2
CODE:CODE:1fad  b02f            GOTO        offset LAB_CODE_1fb0-0x1800
CODE:CODE:1fae  330f            INCFSZ      0x33,w
CODE:CODE:1faf  b42f            GOTO        offset LAB_CODE_1fb4-0x1800
                            LAB_CODE_1fb0:                ;XREF[1,0]:   CODE:1fad
CODE:CODE:1fb0  8312            BCF         STATUS,RP0
                            LAB_CODE_1fb1:                ;XREF[1,0]:   CODE:1f9c
CODE:CODE:1fb1  1211            BCF         0x12,#0x2
CODE:CODE:1fb2  9701            CLRF        0x17
CODE:CODE:1fb3  8716            BSF         FSR1H,#0x5
                            LAB_CODE_1fb4:                ;XREF[2,0]:   CODE:1faa,CODE:1faf
CODE:CODE:1fb4  8312            BCF         STATUS,RP0
CODE:CODE:1fb5  c408            MOVF        0x44,f
CODE:CODE:1fb6  0319            BTFSC       STATUS,#0x2
CODE:CODE:1fb7  c02f            GOTO        offset LAB_CODE_1fc0-0x1800
CODE:CODE:1fb8  c40b            DECFSZ      0x44,f
CODE:CODE:1fb9  c02f            GOTO        offset LAB_CODE_1fc0-0x1800
CODE:CODE:1fba  4008            MOVF        0x40,w
CODE:CODE:1fbb  3c3e            ADDLW       #0x3c
CODE:CODE:1fbc  8400            MOVWF       FSR0L
CODE:CODE:1fbd  8317            BSF         STATUS,IRP
CODE:CODE:1fbe  0008            MOVF        INDF0,w
CODE:CODE:1fbf  9300            MOVWF       0x13
                            LAB_CODE_1fc0:                ;XREF[2,0]:   CODE:1fb7,CODE:1fb9
CODE:CODE:1fc0  c508            MOVF        0x45,f
CODE:CODE:1fc1  031d            BTFSS       STATUS,#0x2
CODE:CODE:1fc2  c503            DECF        0x45,f
CODE:CODE:1fc3  0030            MOVLW       #0x0
CODE:CODE:1fc4  301c            BTFSS       0x30,#0x0
CODE:CODE:1fc5  0130            MOVLW       #0x1
CODE:CODE:1fc6  e500            MOVWF       0x65
CODE:CODE:1fc7  3006            XORWF       0x30,w
CODE:CODE:1fc8  fe39            ANDLW       #0xfe
CODE:CODE:1fc9  6506            XORWF       0x65,w
CODE:CODE:1fca  b000            MOVWF       0x30
CODE:CODE:1fcb  8316            BSF         STATUS,RP0
CODE:CODE:1fcc  341c            BTFSS       0x34,#0x0
CODE:CODE:1fcd  d32f            GOTO        offset LAB_CODE_1fd3-0x1800
CODE:CODE:1fce  8312            BCF         STATUS,RP0
CODE:CODE:1fcf  301c            BTFSS       0x30,#0x0
CODE:CODE:1fd0  d32f            GOTO        offset LAB_CODE_1fd3-0x1800
CODE:CODE:1fd1  0512            BCF         FSR0H,#0x4
CODE:CODE:1fd2  d52f            GOTO        offset LAB_CODE_1fd5-0x1800
                            LAB_CODE_1fd3:                ;XREF[2,0]:   CODE:1fcd,CODE:1fd0
CODE:CODE:1fd3  8312            BCF         STATUS,RP0
CODE:CODE:1fd4  0516            BSF         FSR0H,#0x4
                            LAB_CODE_1fd5:                ;XREF[1,0]:   CODE:1fd2
CODE:CODE:1fd5  8316            BSF         STATUS,RP0
CODE:CODE:1fd6  b41c            BTFSS       0x34,#0x1
CODE:CODE:1fd7  dd2f            GOTO        offset LAB_CODE_1fdd-0x1800
CODE:CODE:1fd8  8312            BCF         STATUS,RP0
CODE:CODE:1fd9  301c            BTFSS       0x30,#0x0
CODE:CODE:1fda  dd2f            GOTO        offset LAB_CODE_1fdd-0x1800
CODE:CODE:1fdb  8511            BCF         FSR0H,#0x3
CODE:CODE:1fdc  df2f            GOTO        offset LAB_CODE_1fdf-0x1800
                            LAB_CODE_1fdd:                ;XREF[2,0]:   CODE:1fd7,CODE:1fda
CODE:CODE:1fdd  8312            BCF         STATUS,RP0
CODE:CODE:1fde  8515            BSF         FSR0H,#0x3
                            LAB_CODE_1fdf:                ;XREF[1,0]:   CODE:1fdc
CODE:CODE:1fdf  bd1e            BTFSS       0x3d,#0x5
CODE:CODE:1fe0  3d1b            BTFSC       0x3d,#0x6
CODE:CODE:1fe1  e62f            GOTO        offset LAB_CODE_1fe6-0x1800
CODE:CODE:1fe2  8316            BSF         STATUS,RP0
CODE:CODE:1fe3  ad08            MOVF        0x2d,f
CODE:CODE:1fe4  0319            BTFSC       STATUS,#0x2
CODE:CODE:1fe5  ec2f            GOTO        offset LAB_CODE_1fec-0x1800
                            LAB_CODE_1fe6:                ;XREF[1,0]:   CODE:1fe1
CODE:CODE:1fe6  0330            MOVLW       #0x3
CODE:CODE:1fe7  8312            BCF         STATUS,RP0
CODE:CODE:1fe8  0317            BSF         STATUS,RP1
CODE:CODE:1fe9  a600            MOVWF       0x26
CODE:CODE:1fea  0313            BCF         STATUS,RP1
CODE:CODE:1feb  b012            BCF         0x30,#0x5
                            LAB_CODE_1fec:                ;XREF[1,0]:   CODE:1fe5
CODE:CODE:1fec  8316            BSF         STATUS,RP0
CODE:CODE:1fed  b908            MOVF        0x39,f
CODE:CODE:1fee  031d            BTFSS       STATUS,#0x2
CODE:CODE:1fef  b903            DECF        0x39,f
CODE:CODE:1ff0  b60b            DECFSZ      0x36,f
CODE:CODE:1ff1  fe2f            GOTO        offset LAB_CODE_1ffe-0x1800
CODE:CODE:1ff2  1a30            MOVLW       #0x1a
CODE:CODE:1ff3  b600            MOVWF       0x36
CODE:CODE:1ff4  8312            BCF         STATUS,RP0
CODE:CODE:1ff5  ac14            BSF         0x2c,#0x1
CODE:CODE:1ff6  8316            BSF         STATUS,RP0
CODE:CODE:1ff7  b308            MOVF        0x33,f
CODE:CODE:1ff8  0319            BTFSC       STATUS,#0x2
CODE:CODE:1ff9  fe2f            GOTO        offset LAB_CODE_1ffe-0x1800
CODE:CODE:1ffa  330a            INCF        0x33,w
CODE:CODE:1ffb  0319            BTFSC       STATUS,#0x2
CODE:CODE:1ffc  fe2f            GOTO        offset LAB_CODE_1ffe-0x1800
CODE:CODE:1ffd  b303            DECF        0x33,f
                            LAB_CODE_1ffe:                ;XREF[3,0]:   CODE:1ff1,CODE:1ff9,CODE:1ffc
CODE:CODE:1ffe  8312            BCF         STATUS,RP0
CODE:CODE:1fff  0800            RETURN
CODE:CODE:2000  ff3fff3ff...    db[8]
   |_CODE:CODE:2000  [0]             db          FFh
   |_CODE:CODE:2000.1[1]             db          3Fh
   |_CODE:CODE:2001  [2]             db          FFh
   |_CODE:CODE:2001.1[3]             db          3Fh
   |_CODE:CODE:2002  [4]             db          FFh
   |_CODE:CODE:2002.1[5]             db          3Fh
   |_CODE:CODE:2003  [6]             db          FFh
   |_CODE:CODE:2003.1[7]             db          3Fh
CODE:CODE:2004  000000000000    db[6]
   |_CODE:CODE:2004  [0]             db          0h
   |_CODE:CODE:2004.1[1]             db          0h
   |_CODE:CODE:2005  [2]             db          0h
   |_CODE:CODE:2005.1[3]             db          0h
   |_CODE:CODE:2006  [4]             db          0h
   |_CODE:CODE:2006.1[5]             db          0h
CODE:CODE:2007  cc33            db[2]
   |_CODE:CODE:2007  [0]             db          CCh
   |_CODE:CODE:2007.1[1]             db          33h
                            END_OF_CODE:
CODE:CODE:2008  000000000...    ??[1008]
   |_CODE:CODE:2008  [0]             ??          00h
   |_CODE:CODE:2008.1[1]             ??          00h
   |_CODE:CODE:2009  [2]             ??          00h
   |_CODE:CODE:2009.1[3]             ??          00h
   |_CODE:CODE:200a  [4]             ??          00h
   |_CODE:CODE:200a.1[5]             ??          00h
   |_CODE:CODE:200b  [6]             ??          00h
   |_CODE:CODE:200b.1[7]             ??          00h
   |_CODE:CODE:200c  [8]             ??          00h
   |_CODE:CODE:200c.1[9]             ??          00h
   |_CODE:CODE:200d  [10]            ??          00h
   |_CODE:CODE:200d.1[11]            ??          00h
   |_CODE:CODE:200e  [12]            ??          00h
   |_CODE:CODE:200e.1[13]            ??          00h
   |_CODE:CODE:200f  [14]            ??          00h
   |_CODE:CODE:200f.1[15]            ??          00h
   |_CODE:CODE:2010  [16]            ??          00h
   |_CODE:CODE:2010.1[17]            ??          00h
   |_CODE:CODE:2011  [18]            ??          00h
   |_CODE:CODE:2011.1[19]            ??          00h
   |_CODE:CODE:2012  [20]            ??          00h
   |_CODE:CODE:2012.1[21]            ??          00h
   |_CODE:CODE:2013  [22]            ??          00h
   |_CODE:CODE:2013.1[23]            ??          00h
   |_CODE:CODE:2014  [24]            ??          00h
   |_CODE:CODE:2014.1[25]            ??          00h
   |_CODE:CODE:2015  [26]            ??          00h
   |_CODE:CODE:2015.1[27]            ??          00h
   |_CODE:CODE:2016  [28]            ??          00h
   |_CODE:CODE:2016.1[29]            ??          00h
   |_CODE:CODE:2017  [30]            ??          00h
   |_CODE:CODE:2017.1[31]            ??          00h
   |_CODE:CODE:2018  [32]            ??          00h
   |_CODE:CODE:2018.1[33]            ??          00h
   |_CODE:CODE:2019  [34]            ??          00h
   |_CODE:CODE:2019.1[35]            ??          00h
   |_CODE:CODE:201a  [36]            ??          00h
   |_CODE:CODE:201a.1[37]            ??          00h
   |_CODE:CODE:201b  [38]            ??          00h
   |_CODE:CODE:201b.1[39]            ??          00h
   |_CODE:CODE:201c  [40]            ??          00h
   |_CODE:CODE:201c.1[41]            ??          00h
   |_CODE:CODE:201d  [42]            ??          00h
   |_CODE:CODE:201d.1[43]            ??          00h
   |_CODE:CODE:201e  [44]            ??          00h
   |_CODE:CODE:201e.1[45]            ??          00h
   |_CODE:CODE:201f  [46]            ??          00h
   |_CODE:CODE:201f.1[47]            ??          00h
   |_CODE:CODE:2020  [48]            ??          00h
   |_CODE:CODE:2020.1[49]            ??          00h
   |_CODE:CODE:2021  [50]            ??          00h
   |_CODE:CODE:2021.1[51]            ??          00h
   |_CODE:CODE:2022  [52]            ??          00h
   |_CODE:CODE:2022.1[53]            ??          00h
   |_CODE:CODE:2023  [54]            ??          00h
   |_CODE:CODE:2023.1[55]            ??          00h
   |_CODE:CODE:2024  [56]            ??          00h
   |_CODE:CODE:2024.1[57]            ??          00h
   |_CODE:CODE:2025  [58]            ??          00h
   |_CODE:CODE:2025.1[59]            ??          00h
   |_CODE:CODE:2026  [60]            ??          00h
   |_CODE:CODE:2026.1[61]            ??          00h
   |_CODE:CODE:2027  [62]            ??          00h
   |_CODE:CODE:2027.1[63]            ??          00h
   |_CODE:CODE:2028  [64]            ??          00h
   |_CODE:CODE:2028.1[65]            ??          00h
   |_CODE:CODE:2029  [66]            ??          00h
   |_CODE:CODE:2029.1[67]            ??          00h
   |_CODE:CODE:202a  [68]            ??          00h
   |_CODE:CODE:202a.1[69]            ??          00h
   |_CODE:CODE:202b  [70]            ??          00h
   |_CODE:CODE:202b.1[71]            ??          00h
   |_CODE:CODE:202c  [72]            ??          00h
   |_CODE:CODE:202c.1[73]            ??          00h
   |_CODE:CODE:202d  [74]            ??          00h
   |_CODE:CODE:202d.1[75]            ??          00h
   |_CODE:CODE:202e  [76]            ??          00h
   |_CODE:CODE:202e.1[77]            ??          00h
   |_CODE:CODE:202f  [78]            ??          00h
   |_CODE:CODE:202f.1[79]            ??          00h
   |_CODE:CODE:2030  [80]            ??          00h
   |_CODE:CODE:2030.1[81]            ??          00h
   |_CODE:CODE:2031  [82]            ??          00h
   |_CODE:CODE:2031.1[83]            ??          00h
   |_CODE:CODE:2032  [84]            ??          00h
   |_CODE:CODE:2032.1[85]            ??          00h
   |_CODE:CODE:2033  [86]            ??          00h
   |_CODE:CODE:2033.1[87]            ??          00h
   |_CODE:CODE:2034  [88]            ??          00h
   |_CODE:CODE:2034.1[89]            ??          00h
   |_CODE:CODE:2035  [90]            ??          00h
   |_CODE:CODE:2035.1[91]            ??          00h
   |_CODE:CODE:2036  [92]            ??          00h
   |_CODE:CODE:2036.1[93]            ??          00h
   |_CODE:CODE:2037  [94]            ??          00h
   |_CODE:CODE:2037.1[95]            ??          00h
   |_CODE:CODE:2038  [96]            ??          00h
   |_CODE:CODE:2038.1[97]            ??          00h
   |_CODE:CODE:2039  [98]            ??          00h
   |_CODE:CODE:2039.1[99]            ??          00h
   |_CODE:CODE:203a  [100]           ??          00h
   |_CODE:CODE:203a.1[101]           ??          00h
   |_CODE:CODE:203b  [102]           ??          00h
   |_CODE:CODE:203b.1[103]           ??          00h
   |_CODE:CODE:203c  [104]           ??          00h
   |_CODE:CODE:203c.1[105]           ??          00h
   |_CODE:CODE:203d  [106]           ??          00h
   |_CODE:CODE:203d.1[107]           ??          00h
   |_CODE:CODE:203e  [108]           ??          00h
   |_CODE:CODE:203e.1[109]           ??          00h
   |_CODE:CODE:203f  [110]           ??          00h
   |_CODE:CODE:203f.1[111]           ??          00h
   |_CODE:CODE:2040  [112]           ??          00h
   |_CODE:CODE:2040.1[113]           ??          00h
   |_CODE:CODE:2041  [114]           ??          00h
   |_CODE:CODE:2041.1[115]           ??          00h
   |_CODE:CODE:2042  [116]           ??          00h
   |_CODE:CODE:2042.1[117]           ??          00h
   |_CODE:CODE:2043  [118]           ??          00h
   |_CODE:CODE:2043.1[119]           ??          00h
   |_CODE:CODE:2044  [120]           ??          00h
   |_CODE:CODE:2044.1[121]           ??          00h
   |_CODE:CODE:2045  [122]           ??          00h
   |_CODE:CODE:2045.1[123]           ??          00h
   |_CODE:CODE:2046  [124]           ??          00h
   |_CODE:CODE:2046.1[125]           ??          00h
   |_CODE:CODE:2047  [126]           ??          00h
   |_CODE:CODE:2047.1[127]           ??          00h
   |_CODE:CODE:2048  [128]           ??          00h
   |_CODE:CODE:2048.1[129]           ??          00h
   |_CODE:CODE:2049  [130]           ??          00h
   |_CODE:CODE:2049.1[131]           ??          00h
   |_CODE:CODE:204a  [132]           ??          00h
   |_CODE:CODE:204a.1[133]           ??          00h
   |_CODE:CODE:204b  [134]           ??          00h
   |_CODE:CODE:204b.1[135]           ??          00h
   |_CODE:CODE:204c  [136]           ??          00h
   |_CODE:CODE:204c.1[137]           ??          00h
   |_CODE:CODE:204d  [138]           ??          00h
   |_CODE:CODE:204d.1[139]           ??          00h
   |_CODE:CODE:204e  [140]           ??          00h
   |_CODE:CODE:204e.1[141]           ??          00h
   |_CODE:CODE:204f  [142]           ??          00h
   |_CODE:CODE:204f.1[143]           ??          00h
   |_CODE:CODE:2050  [144]           ??          00h
   |_CODE:CODE:2050.1[145]           ??          00h
   |_CODE:CODE:2051  [146]           ??          00h
   |_CODE:CODE:2051.1[147]           ??          00h
   |_CODE:CODE:2052  [148]           ??          00h
   |_CODE:CODE:2052.1[149]           ??          00h
   |_CODE:CODE:2053  [150]           ??          00h
   |_CODE:CODE:2053.1[151]           ??          00h
   |_CODE:CODE:2054  [152]           ??          00h
   |_CODE:CODE:2054.1[153]           ??          00h
   |_CODE:CODE:2055  [154]           ??          00h
   |_CODE:CODE:2055.1[155]           ??          00h
   |_CODE:CODE:2056  [156]           ??          00h
   |_CODE:CODE:2056.1[157]           ??          00h
   |_CODE:CODE:2057  [158]           ??          00h
   |_CODE:CODE:2057.1[159]           ??          00h
   |_CODE:CODE:2058  [160]           ??          00h
   |_CODE:CODE:2058.1[161]           ??          00h
   |_CODE:CODE:2059  [162]           ??          00h
   |_CODE:CODE:2059.1[163]           ??          00h
   |_CODE:CODE:205a  [164]           ??          00h
   |_CODE:CODE:205a.1[165]           ??          00h
   |_CODE:CODE:205b  [166]           ??          00h
   |_CODE:CODE:205b.1[167]           ??          00h
   |_CODE:CODE:205c  [168]           ??          00h
   |_CODE:CODE:205c.1[169]           ??          00h
   |_CODE:CODE:205d  [170]           ??          00h
   |_CODE:CODE:205d.1[171]           ??          00h
   |_CODE:CODE:205e  [172]           ??          00h
   |_CODE:CODE:205e.1[173]           ??          00h
   |_CODE:CODE:205f  [174]           ??          00h
   |_CODE:CODE:205f.1[175]           ??          00h
   |_CODE:CODE:2060  [176]           ??          00h
   |_CODE:CODE:2060.1[177]           ??          00h
   |_CODE:CODE:2061  [178]           ??          00h
   |_CODE:CODE:2061.1[179]           ??          00h
   |_CODE:CODE:2062  [180]           ??          00h
   |_CODE:CODE:2062.1[181]           ??          00h
   |_CODE:CODE:2063  [182]           ??          00h
   |_CODE:CODE:2063.1[183]           ??          00h
   |_CODE:CODE:2064  [184]           ??          00h
   |_CODE:CODE:2064.1[185]           ??          00h
   |_CODE:CODE:2065  [186]           ??          00h
   |_CODE:CODE:2065.1[187]           ??          00h
   |_CODE:CODE:2066  [188]           ??          00h
   |_CODE:CODE:2066.1[189]           ??          00h
   |_CODE:CODE:2067  [190]           ??          00h
   |_CODE:CODE:2067.1[191]           ??          00h
   |_CODE:CODE:2068  [192]           ??          00h
   |_CODE:CODE:2068.1[193]           ??          00h
   |_CODE:CODE:2069  [194]           ??          00h
   |_CODE:CODE:2069.1[195]           ??          00h
   |_CODE:CODE:206a  [196]           ??          00h
   |_CODE:CODE:206a.1[197]           ??          00h
   |_CODE:CODE:206b  [198]           ??          00h
   |_CODE:CODE:206b.1[199]           ??          00h
   |_CODE:CODE:206c  [200]           ??          00h
   |_CODE:CODE:206c.1[201]           ??          00h
   |_CODE:CODE:206d  [202]           ??          00h
   |_CODE:CODE:206d.1[203]           ??          00h
   |_CODE:CODE:206e  [204]           ??          00h
   |_CODE:CODE:206e.1[205]           ??          00h
   |_CODE:CODE:206f  [206]           ??          00h
   |_CODE:CODE:206f.1[207]           ??          00h
   |_CODE:CODE:2070  [208]           ??          00h
   |_CODE:CODE:2070.1[209]           ??          00h
   |_CODE:CODE:2071  [210]           ??          00h
   |_CODE:CODE:2071.1[211]           ??          00h
   |_CODE:CODE:2072  [212]           ??          00h
   |_CODE:CODE:2072.1[213]           ??          00h
   |_CODE:CODE:2073  [214]           ??          00h
   |_CODE:CODE:2073.1[215]           ??          00h
   |_CODE:CODE:2074  [216]           ??          00h
   |_CODE:CODE:2074.1[217]           ??          00h
   |_CODE:CODE:2075  [218]           ??          00h
   |_CODE:CODE:2075.1[219]           ??          00h
   |_CODE:CODE:2076  [220]           ??          00h
   |_CODE:CODE:2076.1[221]           ??          00h
   |_CODE:CODE:2077  [222]           ??          00h
   |_CODE:CODE:2077.1[223]           ??          00h
   |_CODE:CODE:2078  [224]           ??          00h
   |_CODE:CODE:2078.1[225]           ??          00h
   |_CODE:CODE:2079  [226]           ??          00h
   |_CODE:CODE:2079.1[227]           ??          00h
   |_CODE:CODE:207a  [228]           ??          00h
   |_CODE:CODE:207a.1[229]           ??          00h
   |_CODE:CODE:207b  [230]           ??          00h
   |_CODE:CODE:207b.1[231]           ??          00h
   |_CODE:CODE:207c  [232]           ??          00h
   |_CODE:CODE:207c.1[233]           ??          00h
   |_CODE:CODE:207d  [234]           ??          00h
   |_CODE:CODE:207d.1[235]           ??          00h
   |_CODE:CODE:207e  [236]           ??          00h
   |_CODE:CODE:207e.1[237]           ??          00h
   |_CODE:CODE:207f  [238]           ??          00h
   |_CODE:CODE:207f.1[239]           ??          00h
   |_CODE:CODE:2080  [240]           ??          00h
   |_CODE:CODE:2080.1[241]           ??          00h
   |_CODE:CODE:2081  [242]           ??          00h
   |_CODE:CODE:2081.1[243]           ??          00h
   |_CODE:CODE:2082  [244]           ??          00h
   |_CODE:CODE:2082.1[245]           ??          00h
   |_CODE:CODE:2083  [246]           ??          00h
   |_CODE:CODE:2083.1[247]           ??          00h
   |_CODE:CODE:2084  [248]           ??          00h
   |_CODE:CODE:2084.1[249]           ??          00h
   |_CODE:CODE:2085  [250]           ??          00h
   |_CODE:CODE:2085.1[251]           ??          00h
   |_CODE:CODE:2086  [252]           ??          00h
   |_CODE:CODE:2086.1[253]           ??          00h
   |_CODE:CODE:2087  [254]           ??          00h
   |_CODE:CODE:2087.1[255]           ??          00h
   |_CODE:CODE:2088  [256]           ??          00h
   |_CODE:CODE:2088.1[257]           ??          00h
   |_CODE:CODE:2089  [258]           ??          00h
   |_CODE:CODE:2089.1[259]           ??          00h
   |_CODE:CODE:208a  [260]           ??          00h
   |_CODE:CODE:208a.1[261]           ??          00h
   |_CODE:CODE:208b  [262]           ??          00h
   |_CODE:CODE:208b.1[263]           ??          00h
   |_CODE:CODE:208c  [264]           ??          00h
   |_CODE:CODE:208c.1[265]           ??          00h
   |_CODE:CODE:208d  [266]           ??          00h
   |_CODE:CODE:208d.1[267]           ??          00h
   |_CODE:CODE:208e  [268]           ??          00h
   |_CODE:CODE:208e.1[269]           ??          00h
   |_CODE:CODE:208f  [270]           ??          00h
   |_CODE:CODE:208f.1[271]           ??          00h
   |_CODE:CODE:2090  [272]           ??          00h
   |_CODE:CODE:2090.1[273]           ??          00h
   |_CODE:CODE:2091  [274]           ??          00h
   |_CODE:CODE:2091.1[275]           ??          00h
   |_CODE:CODE:2092  [276]           ??          00h
   |_CODE:CODE:2092.1[277]           ??          00h
   |_CODE:CODE:2093  [278]           ??          00h
   |_CODE:CODE:2093.1[279]           ??          00h
   |_CODE:CODE:2094  [280]           ??          00h
   |_CODE:CODE:2094.1[281]           ??          00h
   |_CODE:CODE:2095  [282]           ??          00h
   |_CODE:CODE:2095.1[283]           ??          00h
   |_CODE:CODE:2096  [284]           ??          00h
   |_CODE:CODE:2096.1[285]           ??          00h
   |_CODE:CODE:2097  [286]           ??          00h
   |_CODE:CODE:2097.1[287]           ??          00h
   |_CODE:CODE:2098  [288]           ??          00h
   |_CODE:CODE:2098.1[289]           ??          00h
   |_CODE:CODE:2099  [290]           ??          00h
   |_CODE:CODE:2099.1[291]           ??          00h
   |_CODE:CODE:209a  [292]           ??          00h
   |_CODE:CODE:209a.1[293]           ??          00h
   |_CODE:CODE:209b  [294]           ??          00h
   |_CODE:CODE:209b.1[295]           ??          00h
   |_CODE:CODE:209c  [296]           ??          00h
   |_CODE:CODE:209c.1[297]           ??          00h
   |_CODE:CODE:209d  [298]           ??          00h
   |_CODE:CODE:209d.1[299]           ??          00h
   |_CODE:CODE:209e  [300]           ??          00h
   |_CODE:CODE:209e.1[301]           ??          00h
   |_CODE:CODE:209f  [302]           ??          00h
   |_CODE:CODE:209f.1[303]           ??          00h
   |_CODE:CODE:20a0  [304]           ??          00h
   |_CODE:CODE:20a0.1[305]           ??          00h
   |_CODE:CODE:20a1  [306]           ??          00h
   |_CODE:CODE:20a1.1[307]           ??          00h
   |_CODE:CODE:20a2  [308]           ??          00h
   |_CODE:CODE:20a2.1[309]           ??          00h
   |_CODE:CODE:20a3  [310]           ??          00h
   |_CODE:CODE:20a3.1[311]           ??          00h
   |_CODE:CODE:20a4  [312]           ??          00h
   |_CODE:CODE:20a4.1[313]           ??          00h
   |_CODE:CODE:20a5  [314]           ??          00h
   |_CODE:CODE:20a5.1[315]           ??          00h
   |_CODE:CODE:20a6  [316]           ??          00h
   |_CODE:CODE:20a6.1[317]           ??          00h
   |_CODE:CODE:20a7  [318]           ??          00h
   |_CODE:CODE:20a7.1[319]           ??          00h
   |_CODE:CODE:20a8  [320]           ??          00h
   |_CODE:CODE:20a8.1[321]           ??          00h
   |_CODE:CODE:20a9  [322]           ??          00h
   |_CODE:CODE:20a9.1[323]           ??          00h
   |_CODE:CODE:20aa  [324]           ??          00h
   |_CODE:CODE:20aa.1[325]           ??          00h
   |_CODE:CODE:20ab  [326]           ??          00h
   |_CODE:CODE:20ab.1[327]           ??          00h
   |_CODE:CODE:20ac  [328]           ??          00h
   |_CODE:CODE:20ac.1[329]           ??          00h
   |_CODE:CODE:20ad  [330]           ??          00h
   |_CODE:CODE:20ad.1[331]           ??          00h
   |_CODE:CODE:20ae  [332]           ??          00h
   |_CODE:CODE:20ae.1[333]           ??          00h
   |_CODE:CODE:20af  [334]           ??          00h
   |_CODE:CODE:20af.1[335]           ??          00h
   |_CODE:CODE:20b0  [336]           ??          00h
   |_CODE:CODE:20b0.1[337]           ??          00h
   |_CODE:CODE:20b1  [338]           ??          00h
   |_CODE:CODE:20b1.1[339]           ??          00h
   |_CODE:CODE:20b2  [340]           ??          00h
   |_CODE:CODE:20b2.1[341]           ??          00h
   |_CODE:CODE:20b3  [342]           ??          00h
   |_CODE:CODE:20b3.1[343]           ??          00h
   |_CODE:CODE:20b4  [344]           ??          00h
   |_CODE:CODE:20b4.1[345]           ??          00h
   |_CODE:CODE:20b5  [346]           ??          00h
   |_CODE:CODE:20b5.1[347]           ??          00h
   |_CODE:CODE:20b6  [348]           ??          00h
   |_CODE:CODE:20b6.1[349]           ??          00h
   |_CODE:CODE:20b7  [350]           ??          00h
   |_CODE:CODE:20b7.1[351]           ??          00h
   |_CODE:CODE:20b8  [352]           ??          00h
   |_CODE:CODE:20b8.1[353]           ??          00h
   |_CODE:CODE:20b9  [354]           ??          00h
   |_CODE:CODE:20b9.1[355]           ??          00h
   |_CODE:CODE:20ba  [356]           ??          00h
   |_CODE:CODE:20ba.1[357]           ??          00h
   |_CODE:CODE:20bb  [358]           ??          00h
   |_CODE:CODE:20bb.1[359]           ??          00h
   |_CODE:CODE:20bc  [360]           ??          00h
   |_CODE:CODE:20bc.1[361]           ??          00h
   |_CODE:CODE:20bd  [362]           ??          00h
   |_CODE:CODE:20bd.1[363]           ??          00h
   |_CODE:CODE:20be  [364]           ??          00h
   |_CODE:CODE:20be.1[365]           ??          00h
   |_CODE:CODE:20bf  [366]           ??          00h
   |_CODE:CODE:20bf.1[367]           ??          00h
   |_CODE:CODE:20c0  [368]           ??          00h
   |_CODE:CODE:20c0.1[369]           ??          00h
   |_CODE:CODE:20c1  [370]           ??          00h
   |_CODE:CODE:20c1.1[371]           ??          00h
   |_CODE:CODE:20c2  [372]           ??          00h
   |_CODE:CODE:20c2.1[373]           ??          00h
   |_CODE:CODE:20c3  [374]           ??          00h
   |_CODE:CODE:20c3.1[375]           ??          00h
   |_CODE:CODE:20c4  [376]           ??          00h
   |_CODE:CODE:20c4.1[377]           ??          00h
   |_CODE:CODE:20c5  [378]           ??          00h
   |_CODE:CODE:20c5.1[379]           ??          00h
   |_CODE:CODE:20c6  [380]           ??          00h
   |_CODE:CODE:20c6.1[381]           ??          00h
   |_CODE:CODE:20c7  [382]           ??          00h
   |_CODE:CODE:20c7.1[383]           ??          00h
   |_CODE:CODE:20c8  [384]           ??          00h
   |_CODE:CODE:20c8.1[385]           ??          00h
   |_CODE:CODE:20c9  [386]           ??          00h
   |_CODE:CODE:20c9.1[387]           ??          00h
   |_CODE:CODE:20ca  [388]           ??          00h
   |_CODE:CODE:20ca.1[389]           ??          00h
   |_CODE:CODE:20cb  [390]           ??          00h
   |_CODE:CODE:20cb.1[391]           ??          00h
   |_CODE:CODE:20cc  [392]           ??          00h
   |_CODE:CODE:20cc.1[393]           ??          00h
   |_CODE:CODE:20cd  [394]           ??          00h
   |_CODE:CODE:20cd.1[395]           ??          00h
   |_CODE:CODE:20ce  [396]           ??          00h
   |_CODE:CODE:20ce.1[397]           ??          00h
   |_CODE:CODE:20cf  [398]           ??          00h
   |_CODE:CODE:20cf.1[399]           ??          00h
   |_CODE:CODE:20d0  [400]           ??          00h
   |_CODE:CODE:20d0.1[401]           ??          00h
   |_CODE:CODE:20d1  [402]           ??          00h
   |_CODE:CODE:20d1.1[403]           ??          00h
   |_CODE:CODE:20d2  [404]           ??          00h
   |_CODE:CODE:20d2.1[405]           ??          00h
   |_CODE:CODE:20d3  [406]           ??          00h
   |_CODE:CODE:20d3.1[407]           ??          00h
   |_CODE:CODE:20d4  [408]           ??          00h
   |_CODE:CODE:20d4.1[409]           ??          00h
   |_CODE:CODE:20d5  [410]           ??          00h
   |_CODE:CODE:20d5.1[411]           ??          00h
   |_CODE:CODE:20d6  [412]           ??          00h
   |_CODE:CODE:20d6.1[413]           ??          00h
   |_CODE:CODE:20d7  [414]           ??          00h
   |_CODE:CODE:20d7.1[415]           ??          00h
   |_CODE:CODE:20d8  [416]           ??          00h
   |_CODE:CODE:20d8.1[417]           ??          00h
   |_CODE:CODE:20d9  [418]           ??          00h
   |_CODE:CODE:20d9.1[419]           ??          00h
   |_CODE:CODE:20da  [420]           ??          00h
   |_CODE:CODE:20da.1[421]           ??          00h
   |_CODE:CODE:20db  [422]           ??          00h
   |_CODE:CODE:20db.1[423]           ??          00h
   |_CODE:CODE:20dc  [424]           ??          00h
   |_CODE:CODE:20dc.1[425]           ??          00h
   |_CODE:CODE:20dd  [426]           ??          00h
   |_CODE:CODE:20dd.1[427]           ??          00h
   |_CODE:CODE:20de  [428]           ??          00h
   |_CODE:CODE:20de.1[429]           ??          00h
   |_CODE:CODE:20df  [430]           ??          00h
   |_CODE:CODE:20df.1[431]           ??          00h
   |_CODE:CODE:20e0  [432]           ??          00h
   |_CODE:CODE:20e0.1[433]           ??          00h
   |_CODE:CODE:20e1  [434]           ??          00h
   |_CODE:CODE:20e1.1[435]           ??          00h
   |_CODE:CODE:20e2  [436]           ??          00h
   |_CODE:CODE:20e2.1[437]           ??          00h
   |_CODE:CODE:20e3  [438]           ??          00h
   |_CODE:CODE:20e3.1[439]           ??          00h
   |_CODE:CODE:20e4  [440]           ??          00h
   |_CODE:CODE:20e4.1[441]           ??          00h
   |_CODE:CODE:20e5  [442]           ??          00h
   |_CODE:CODE:20e5.1[443]           ??          00h
   |_CODE:CODE:20e6  [444]           ??          00h
   |_CODE:CODE:20e6.1[445]           ??          00h
   |_CODE:CODE:20e7  [446]           ??          00h
   |_CODE:CODE:20e7.1[447]           ??          00h
   |_CODE:CODE:20e8  [448]           ??          00h
   |_CODE:CODE:20e8.1[449]           ??          00h
   |_CODE:CODE:20e9  [450]           ??          00h
   |_CODE:CODE:20e9.1[451]           ??          00h
   |_CODE:CODE:20ea  [452]           ??          00h
   |_CODE:CODE:20ea.1[453]           ??          00h
   |_CODE:CODE:20eb  [454]           ??          00h
   |_CODE:CODE:20eb.1[455]           ??          00h
   |_CODE:CODE:20ec  [456]           ??          00h
   |_CODE:CODE:20ec.1[457]           ??          00h
   |_CODE:CODE:20ed  [458]           ??          00h
   |_CODE:CODE:20ed.1[459]           ??          00h
   |_CODE:CODE:20ee  [460]           ??          00h
   |_CODE:CODE:20ee.1[461]           ??          00h
   |_CODE:CODE:20ef  [462]           ??          00h
   |_CODE:CODE:20ef.1[463]           ??          00h
   |_CODE:CODE:20f0  [464]           ??          00h
   |_CODE:CODE:20f0.1[465]           ??          00h
   |_CODE:CODE:20f1  [466]           ??          00h
   |_CODE:CODE:20f1.1[467]           ??          00h
   |_CODE:CODE:20f2  [468]           ??          00h
   |_CODE:CODE:20f2.1[469]           ??          00h
   |_CODE:CODE:20f3  [470]           ??          00h
   |_CODE:CODE:20f3.1[471]           ??          00h
   |_CODE:CODE:20f4  [472]           ??          00h
   |_CODE:CODE:20f4.1[473]           ??          00h
   |_CODE:CODE:20f5  [474]           ??          00h
   |_CODE:CODE:20f5.1[475]           ??          00h
   |_CODE:CODE:20f6  [476]           ??          00h
   |_CODE:CODE:20f6.1[477]           ??          00h
   |_CODE:CODE:20f7  [478]           ??          00h
   |_CODE:CODE:20f7.1[479]           ??          00h
   |_CODE:CODE:20f8  [480]           ??          00h
   |_CODE:CODE:20f8.1[481]           ??          00h
   |_CODE:CODE:20f9  [482]           ??          00h
   |_CODE:CODE:20f9.1[483]           ??          00h
   |_CODE:CODE:20fa  [484]           ??          00h
   |_CODE:CODE:20fa.1[485]           ??          00h
   |_CODE:CODE:20fb  [486]           ??          00h
   |_CODE:CODE:20fb.1[487]           ??          00h
   |_CODE:CODE:20fc  [488]           ??          00h
   |_CODE:CODE:20fc.1[489]           ??          00h
   |_CODE:CODE:20fd  [490]           ??          00h
   |_CODE:CODE:20fd.1[491]           ??          00h
   |_CODE:CODE:20fe  [492]           ??          00h
   |_CODE:CODE:20fe.1[493]           ??          00h
   |_CODE:CODE:20ff  [494]           ??          00h
   |_CODE:CODE:20ff.1[495]           ??          00h
   |_CODE:CODE:2100  [496]           ??          FFh
   |_CODE:CODE:2100.1[497]           ??          00h
   |_CODE:CODE:2101  [498]           ??          FFh
   |_CODE:CODE:2101.1[499]           ??          00h
   |_CODE:CODE:2102  [500]           ??          FFh
   |_CODE:CODE:2102.1[501]           ??          00h
   |_CODE:CODE:2103  [502]           ??          FFh
   |_CODE:CODE:2103.1[503]           ??          00h
   |_CODE:CODE:2104  [504]           ??          FFh
   |_CODE:CODE:2104.1[505]           ??          00h
   |_CODE:CODE:2105  [506]           ??          FFh
   |_CODE:CODE:2105.1[507]           ??          00h
   |_CODE:CODE:2106  [508]           ??          FFh
   |_CODE:CODE:2106.1[509]           ??          00h
   |_CODE:CODE:2107  [510]           ??          FFh
   |_CODE:CODE:2107.1[511]           ??          00h
   |_CODE:CODE:2108  [512]           ??          FFh
   |_CODE:CODE:2108.1[513]           ??          00h
   |_CODE:CODE:2109  [514]           ??          FFh
   |_CODE:CODE:2109.1[515]           ??          00h
   |_CODE:CODE:210a  [516]           ??          FFh
   |_CODE:CODE:210a.1[517]           ??          00h
   |_CODE:CODE:210b  [518]           ??          FFh
   |_CODE:CODE:210b.1[519]           ??          00h
   |_CODE:CODE:210c  [520]           ??          FFh
   |_CODE:CODE:210c.1[521]           ??          00h
   |_CODE:CODE:210d  [522]           ??          FFh
   |_CODE:CODE:210d.1[523]           ??          00h
   |_CODE:CODE:210e  [524]           ??          FFh
   |_CODE:CODE:210e.1[525]           ??          00h
   |_CODE:CODE:210f  [526]           ??          FFh
   |_CODE:CODE:210f.1[527]           ??          00h
   |_CODE:CODE:2110  [528]           ??          FFh
   |_CODE:CODE:2110.1[529]           ??          00h
   |_CODE:CODE:2111  [530]           ??          FFh
   |_CODE:CODE:2111.1[531]           ??          00h
   |_CODE:CODE:2112  [532]           ??          FFh
   |_CODE:CODE:2112.1[533]           ??          00h
   |_CODE:CODE:2113  [534]           ??          FFh
   |_CODE:CODE:2113.1[535]           ??          00h
   |_CODE:CODE:2114  [536]           ??          FFh
   |_CODE:CODE:2114.1[537]           ??          00h
   |_CODE:CODE:2115  [538]           ??          FFh
   |_CODE:CODE:2115.1[539]           ??          00h
   |_CODE:CODE:2116  [540]           ??          FFh
   |_CODE:CODE:2116.1[541]           ??          00h
   |_CODE:CODE:2117  [542]           ??          FFh
   |_CODE:CODE:2117.1[543]           ??          00h
   |_CODE:CODE:2118  [544]           ??          FFh
   |_CODE:CODE:2118.1[545]           ??          00h
   |_CODE:CODE:2119  [546]           ??          FFh
   |_CODE:CODE:2119.1[547]           ??          00h
   |_CODE:CODE:211a  [548]           ??          FFh
   |_CODE:CODE:211a.1[549]           ??          00h
   |_CODE:CODE:211b  [550]           ??          FFh
   |_CODE:CODE:211b.1[551]           ??          00h
   |_CODE:CODE:211c  [552]           ??          FFh
   |_CODE:CODE:211c.1[553]           ??          00h
   |_CODE:CODE:211d  [554]           ??          FFh
   |_CODE:CODE:211d.1[555]           ??          00h
   |_CODE:CODE:211e  [556]           ??          FFh
   |_CODE:CODE:211e.1[557]           ??          00h
   |_CODE:CODE:211f  [558]           ??          FFh
   |_CODE:CODE:211f.1[559]           ??          00h
   |_CODE:CODE:2120  [560]           ??          FFh
   |_CODE:CODE:2120.1[561]           ??          00h
   |_CODE:CODE:2121  [562]           ??          FFh
   |_CODE:CODE:2121.1[563]           ??          00h
   |_CODE:CODE:2122  [564]           ??          FFh
   |_CODE:CODE:2122.1[565]           ??          00h
   |_CODE:CODE:2123  [566]           ??          FFh
   |_CODE:CODE:2123.1[567]           ??          00h
   |_CODE:CODE:2124  [568]           ??          FFh
   |_CODE:CODE:2124.1[569]           ??          00h
   |_CODE:CODE:2125  [570]           ??          FFh
   |_CODE:CODE:2125.1[571]           ??          00h
   |_CODE:CODE:2126  [572]           ??          FFh
   |_CODE:CODE:2126.1[573]           ??          00h
   |_CODE:CODE:2127  [574]           ??          FFh
   |_CODE:CODE:2127.1[575]           ??          00h
   |_CODE:CODE:2128  [576]           ??          FFh
   |_CODE:CODE:2128.1[577]           ??          00h
   |_CODE:CODE:2129  [578]           ??          FFh
   |_CODE:CODE:2129.1[579]           ??          00h
   |_CODE:CODE:212a  [580]           ??          FFh
   |_CODE:CODE:212a.1[581]           ??          00h
   |_CODE:CODE:212b  [582]           ??          FFh
   |_CODE:CODE:212b.1[583]           ??          00h
   |_CODE:CODE:212c  [584]           ??          FFh
   |_CODE:CODE:212c.1[585]           ??          00h
   |_CODE:CODE:212d  [586]           ??          FFh
   |_CODE:CODE:212d.1[587]           ??          00h
   |_CODE:CODE:212e  [588]           ??          FFh
   |_CODE:CODE:212e.1[589]           ??          00h
   |_CODE:CODE:212f  [590]           ??          FFh
   |_CODE:CODE:212f.1[591]           ??          00h
   |_CODE:CODE:2130  [592]           ??          FFh
   |_CODE:CODE:2130.1[593]           ??          00h
   |_CODE:CODE:2131  [594]           ??          FFh
   |_CODE:CODE:2131.1[595]           ??          00h
   |_CODE:CODE:2132  [596]           ??          FFh
   |_CODE:CODE:2132.1[597]           ??          00h
   |_CODE:CODE:2133  [598]           ??          FFh
   |_CODE:CODE:2133.1[599]           ??          00h
   |_CODE:CODE:2134  [600]           ??          FFh
   |_CODE:CODE:2134.1[601]           ??          00h
   |_CODE:CODE:2135  [602]           ??          FFh
   |_CODE:CODE:2135.1[603]           ??          00h
   |_CODE:CODE:2136  [604]           ??          FFh
   |_CODE:CODE:2136.1[605]           ??          00h
   |_CODE:CODE:2137  [606]           ??          FFh
   |_CODE:CODE:2137.1[607]           ??          00h
   |_CODE:CODE:2138  [608]           ??          FFh
   |_CODE:CODE:2138.1[609]           ??          00h
   |_CODE:CODE:2139  [610]           ??          FFh
   |_CODE:CODE:2139.1[611]           ??          00h
   |_CODE:CODE:213a  [612]           ??          FFh
   |_CODE:CODE:213a.1[613]           ??          00h
   |_CODE:CODE:213b  [614]           ??          FFh
   |_CODE:CODE:213b.1[615]           ??          00h
   |_CODE:CODE:213c  [616]           ??          FFh
   |_CODE:CODE:213c.1[617]           ??          00h
   |_CODE:CODE:213d  [618]           ??          FFh
   |_CODE:CODE:213d.1[619]           ??          00h
   |_CODE:CODE:213e  [620]           ??          FFh
   |_CODE:CODE:213e.1[621]           ??          00h
   |_CODE:CODE:213f  [622]           ??          FFh
   |_CODE:CODE:213f.1[623]           ??          00h
   |_CODE:CODE:2140  [624]           ??          FFh
   |_CODE:CODE:2140.1[625]           ??          00h
   |_CODE:CODE:2141  [626]           ??          FFh
   |_CODE:CODE:2141.1[627]           ??          00h
   |_CODE:CODE:2142  [628]           ??          FFh
   |_CODE:CODE:2142.1[629]           ??          00h
   |_CODE:CODE:2143  [630]           ??          FFh
   |_CODE:CODE:2143.1[631]           ??          00h
   |_CODE:CODE:2144  [632]           ??          FFh
   |_CODE:CODE:2144.1[633]           ??          00h
   |_CODE:CODE:2145  [634]           ??          FFh
   |_CODE:CODE:2145.1[635]           ??          00h
   |_CODE:CODE:2146  [636]           ??          FFh
   |_CODE:CODE:2146.1[637]           ??          00h
   |_CODE:CODE:2147  [638]           ??          FFh
   |_CODE:CODE:2147.1[639]           ??          00h
   |_CODE:CODE:2148  [640]           ??          FFh
   |_CODE:CODE:2148.1[641]           ??          00h
   |_CODE:CODE:2149  [642]           ??          FFh
   |_CODE:CODE:2149.1[643]           ??          00h
   |_CODE:CODE:214a  [644]           ??          FFh
   |_CODE:CODE:214a.1[645]           ??          00h
   |_CODE:CODE:214b  [646]           ??          FFh
   |_CODE:CODE:214b.1[647]           ??          00h
   |_CODE:CODE:214c  [648]           ??          FFh
   |_CODE:CODE:214c.1[649]           ??          00h
   |_CODE:CODE:214d  [650]           ??          FFh
   |_CODE:CODE:214d.1[651]           ??          00h
   |_CODE:CODE:214e  [652]           ??          FFh
   |_CODE:CODE:214e.1[653]           ??          00h
   |_CODE:CODE:214f  [654]           ??          FFh
   |_CODE:CODE:214f.1[655]           ??          00h
   |_CODE:CODE:2150  [656]           ??          FFh
   |_CODE:CODE:2150.1[657]           ??          00h
   |_CODE:CODE:2151  [658]           ??          FFh
   |_CODE:CODE:2151.1[659]           ??          00h
   |_CODE:CODE:2152  [660]           ??          FFh
   |_CODE:CODE:2152.1[661]           ??          00h
   |_CODE:CODE:2153  [662]           ??          FFh
   |_CODE:CODE:2153.1[663]           ??          00h
   |_CODE:CODE:2154  [664]           ??          FFh
   |_CODE:CODE:2154.1[665]           ??          00h
   |_CODE:CODE:2155  [666]           ??          FFh
   |_CODE:CODE:2155.1[667]           ??          00h
   |_CODE:CODE:2156  [668]           ??          FFh
   |_CODE:CODE:2156.1[669]           ??          00h
   |_CODE:CODE:2157  [670]           ??          FFh
   |_CODE:CODE:2157.1[671]           ??          00h
   |_CODE:CODE:2158  [672]           ??          FFh
   |_CODE:CODE:2158.1[673]           ??          00h
   |_CODE:CODE:2159  [674]           ??          FFh
   |_CODE:CODE:2159.1[675]           ??          00h
   |_CODE:CODE:215a  [676]           ??          FFh
   |_CODE:CODE:215a.1[677]           ??          00h
   |_CODE:CODE:215b  [678]           ??          FFh
   |_CODE:CODE:215b.1[679]           ??          00h
   |_CODE:CODE:215c  [680]           ??          FFh
   |_CODE:CODE:215c.1[681]           ??          00h
   |_CODE:CODE:215d  [682]           ??          FFh
   |_CODE:CODE:215d.1[683]           ??          00h
   |_CODE:CODE:215e  [684]           ??          FFh
   |_CODE:CODE:215e.1[685]           ??          00h
   |_CODE:CODE:215f  [686]           ??          FFh
   |_CODE:CODE:215f.1[687]           ??          00h
   |_CODE:CODE:2160  [688]           ??          FFh
   |_CODE:CODE:2160.1[689]           ??          00h
   |_CODE:CODE:2161  [690]           ??          FFh
   |_CODE:CODE:2161.1[691]           ??          00h
   |_CODE:CODE:2162  [692]           ??          FFh
   |_CODE:CODE:2162.1[693]           ??          00h
   |_CODE:CODE:2163  [694]           ??          FFh
   |_CODE:CODE:2163.1[695]           ??          00h
   |_CODE:CODE:2164  [696]           ??          FFh
   |_CODE:CODE:2164.1[697]           ??          00h
   |_CODE:CODE:2165  [698]           ??          FFh
   |_CODE:CODE:2165.1[699]           ??          00h
   |_CODE:CODE:2166  [700]           ??          FFh
   |_CODE:CODE:2166.1[701]           ??          00h
   |_CODE:CODE:2167  [702]           ??          FFh
   |_CODE:CODE:2167.1[703]           ??          00h
   |_CODE:CODE:2168  [704]           ??          FFh
   |_CODE:CODE:2168.1[705]           ??          00h
   |_CODE:CODE:2169  [706]           ??          FFh
   |_CODE:CODE:2169.1[707]           ??          00h
   |_CODE:CODE:216a  [708]           ??          FFh
   |_CODE:CODE:216a.1[709]           ??          00h
   |_CODE:CODE:216b  [710]           ??          FFh
   |_CODE:CODE:216b.1[711]           ??          00h
   |_CODE:CODE:216c  [712]           ??          FFh
   |_CODE:CODE:216c.1[713]           ??          00h
   |_CODE:CODE:216d  [714]           ??          FFh
   |_CODE:CODE:216d.1[715]           ??          00h
   |_CODE:CODE:216e  [716]           ??          FFh
   |_CODE:CODE:216e.1[717]           ??          00h
   |_CODE:CODE:216f  [718]           ??          FFh
   |_CODE:CODE:216f.1[719]           ??          00h
   |_CODE:CODE:2170  [720]           ??          FFh
   |_CODE:CODE:2170.1[721]           ??          00h
   |_CODE:CODE:2171  [722]           ??          FFh
   |_CODE:CODE:2171.1[723]           ??          00h
   |_CODE:CODE:2172  [724]           ??          FFh
   |_CODE:CODE:2172.1[725]           ??          00h
   |_CODE:CODE:2173  [726]           ??          FFh
   |_CODE:CODE:2173.1[727]           ??          00h
   |_CODE:CODE:2174  [728]           ??          FFh
   |_CODE:CODE:2174.1[729]           ??          00h
   |_CODE:CODE:2175  [730]           ??          FFh
   |_CODE:CODE:2175.1[731]           ??          00h
   |_CODE:CODE:2176  [732]           ??          FFh
   |_CODE:CODE:2176.1[733]           ??          00h
   |_CODE:CODE:2177  [734]           ??          FFh
   |_CODE:CODE:2177.1[735]           ??          00h
   |_CODE:CODE:2178  [736]           ??          FFh
   |_CODE:CODE:2178.1[737]           ??          00h
   |_CODE:CODE:2179  [738]           ??          FFh
   |_CODE:CODE:2179.1[739]           ??          00h
   |_CODE:CODE:217a  [740]           ??          FFh
   |_CODE:CODE:217a.1[741]           ??          00h
   |_CODE:CODE:217b  [742]           ??          FFh
   |_CODE:CODE:217b.1[743]           ??          00h
   |_CODE:CODE:217c  [744]           ??          FFh
   |_CODE:CODE:217c.1[745]           ??          00h
   |_CODE:CODE:217d  [746]           ??          FFh
   |_CODE:CODE:217d.1[747]           ??          00h
   |_CODE:CODE:217e  [748]           ??          FFh
   |_CODE:CODE:217e.1[749]           ??          00h
   |_CODE:CODE:217f  [750]           ??          FFh
   |_CODE:CODE:217f.1[751]           ??          00h
   |_CODE:CODE:2180  [752]           ??          FFh
   |_CODE:CODE:2180.1[753]           ??          00h
   |_CODE:CODE:2181  [754]           ??          FFh
   |_CODE:CODE:2181.1[755]           ??          00h
   |_CODE:CODE:2182  [756]           ??          FFh
   |_CODE:CODE:2182.1[757]           ??          00h
   |_CODE:CODE:2183  [758]           ??          FFh
   |_CODE:CODE:2183.1[759]           ??          00h
   |_CODE:CODE:2184  [760]           ??          FFh
   |_CODE:CODE:2184.1[761]           ??          00h
   |_CODE:CODE:2185  [762]           ??          FFh
   |_CODE:CODE:2185.1[763]           ??          00h
   |_CODE:CODE:2186  [764]           ??          FFh
   |_CODE:CODE:2186.1[765]           ??          00h
   |_CODE:CODE:2187  [766]           ??          FFh
   |_CODE:CODE:2187.1[767]           ??          00h
   |_CODE:CODE:2188  [768]           ??          FFh
   |_CODE:CODE:2188.1[769]           ??          00h
   |_CODE:CODE:2189  [770]           ??          FFh
   |_CODE:CODE:2189.1[771]           ??          00h
   |_CODE:CODE:218a  [772]           ??          FFh
   |_CODE:CODE:218a.1[773]           ??          00h
   |_CODE:CODE:218b  [774]           ??          FFh
   |_CODE:CODE:218b.1[775]           ??          00h
   |_CODE:CODE:218c  [776]           ??          FFh
   |_CODE:CODE:218c.1[777]           ??          00h
   |_CODE:CODE:218d  [778]           ??          FFh
   |_CODE:CODE:218d.1[779]           ??          00h
   |_CODE:CODE:218e  [780]           ??          FFh
   |_CODE:CODE:218e.1[781]           ??          00h
   |_CODE:CODE:218f  [782]           ??          FFh
   |_CODE:CODE:218f.1[783]           ??          00h
   |_CODE:CODE:2190  [784]           ??          FFh
   |_CODE:CODE:2190.1[785]           ??          00h
   |_CODE:CODE:2191  [786]           ??          FFh
   |_CODE:CODE:2191.1[787]           ??          00h
   |_CODE:CODE:2192  [788]           ??          FFh
   |_CODE:CODE:2192.1[789]           ??          00h
   |_CODE:CODE:2193  [790]           ??          FFh
   |_CODE:CODE:2193.1[791]           ??          00h
   |_CODE:CODE:2194  [792]           ??          FFh
   |_CODE:CODE:2194.1[793]           ??          00h
   |_CODE:CODE:2195  [794]           ??          FFh
   |_CODE:CODE:2195.1[795]           ??          00h
   |_CODE:CODE:2196  [796]           ??          FFh
   |_CODE:CODE:2196.1[797]           ??          00h
   |_CODE:CODE:2197  [798]           ??          FFh
   |_CODE:CODE:2197.1[799]           ??          00h
   |_CODE:CODE:2198  [800]           ??          FFh
   |_CODE:CODE:2198.1[801]           ??          00h
   |_CODE:CODE:2199  [802]           ??          FFh
   |_CODE:CODE:2199.1[803]           ??          00h
   |_CODE:CODE:219a  [804]           ??          FFh
   |_CODE:CODE:219a.1[805]           ??          00h
   |_CODE:CODE:219b  [806]           ??          FFh
   |_CODE:CODE:219b.1[807]           ??          00h
   |_CODE:CODE:219c  [808]           ??          FFh
   |_CODE:CODE:219c.1[809]           ??          00h
   |_CODE:CODE:219d  [810]           ??          FFh
   |_CODE:CODE:219d.1[811]           ??          00h
   |_CODE:CODE:219e  [812]           ??          FFh
   |_CODE:CODE:219e.1[813]           ??          00h
   |_CODE:CODE:219f  [814]           ??          FFh
   |_CODE:CODE:219f.1[815]           ??          00h
   |_CODE:CODE:21a0  [816]           ??          FFh
   |_CODE:CODE:21a0.1[817]           ??          00h
   |_CODE:CODE:21a1  [818]           ??          FFh
   |_CODE:CODE:21a1.1[819]           ??          00h
   |_CODE:CODE:21a2  [820]           ??          FFh
   |_CODE:CODE:21a2.1[821]           ??          00h
   |_CODE:CODE:21a3  [822]           ??          FFh
   |_CODE:CODE:21a3.1[823]           ??          00h
   |_CODE:CODE:21a4  [824]           ??          FFh
   |_CODE:CODE:21a4.1[825]           ??          00h
   |_CODE:CODE:21a5  [826]           ??          FFh
   |_CODE:CODE:21a5.1[827]           ??          00h
   |_CODE:CODE:21a6  [828]           ??          FFh
   |_CODE:CODE:21a6.1[829]           ??          00h
   |_CODE:CODE:21a7  [830]           ??          FFh
   |_CODE:CODE:21a7.1[831]           ??          00h
   |_CODE:CODE:21a8  [832]           ??          FFh
   |_CODE:CODE:21a8.1[833]           ??          00h
   |_CODE:CODE:21a9  [834]           ??          FFh
   |_CODE:CODE:21a9.1[835]           ??          00h
   |_CODE:CODE:21aa  [836]           ??          FFh
   |_CODE:CODE:21aa.1[837]           ??          00h
   |_CODE:CODE:21ab  [838]           ??          FFh
   |_CODE:CODE:21ab.1[839]           ??          00h
   |_CODE:CODE:21ac  [840]           ??          FFh
   |_CODE:CODE:21ac.1[841]           ??          00h
   |_CODE:CODE:21ad  [842]           ??          FFh
   |_CODE:CODE:21ad.1[843]           ??          00h
   |_CODE:CODE:21ae  [844]           ??          FFh
   |_CODE:CODE:21ae.1[845]           ??          00h
   |_CODE:CODE:21af  [846]           ??          FFh
   |_CODE:CODE:21af.1[847]           ??          00h
   |_CODE:CODE:21b0  [848]           ??          FFh
   |_CODE:CODE:21b0.1[849]           ??          00h
   |_CODE:CODE:21b1  [850]           ??          FFh
   |_CODE:CODE:21b1.1[851]           ??          00h
   |_CODE:CODE:21b2  [852]           ??          FFh
   |_CODE:CODE:21b2.1[853]           ??          00h
   |_CODE:CODE:21b3  [854]           ??          FFh
   |_CODE:CODE:21b3.1[855]           ??          00h
   |_CODE:CODE:21b4  [856]           ??          FFh
   |_CODE:CODE:21b4.1[857]           ??          00h
   |_CODE:CODE:21b5  [858]           ??          FFh
   |_CODE:CODE:21b5.1[859]           ??          00h
   |_CODE:CODE:21b6  [860]           ??          FFh
   |_CODE:CODE:21b6.1[861]           ??          00h
   |_CODE:CODE:21b7  [862]           ??          FFh
   |_CODE:CODE:21b7.1[863]           ??          00h
   |_CODE:CODE:21b8  [864]           ??          FFh
   |_CODE:CODE:21b8.1[865]           ??          00h
   |_CODE:CODE:21b9  [866]           ??          FFh
   |_CODE:CODE:21b9.1[867]           ??          00h
   |_CODE:CODE:21ba  [868]           ??          FFh
   |_CODE:CODE:21ba.1[869]           ??          00h
   |_CODE:CODE:21bb  [870]           ??          FFh
   |_CODE:CODE:21bb.1[871]           ??          00h
   |_CODE:CODE:21bc  [872]           ??          FFh
   |_CODE:CODE:21bc.1[873]           ??          00h
   |_CODE:CODE:21bd  [874]           ??          FFh
   |_CODE:CODE:21bd.1[875]           ??          00h
   |_CODE:CODE:21be  [876]           ??          FFh
   |_CODE:CODE:21be.1[877]           ??          00h
   |_CODE:CODE:21bf  [878]           ??          FFh
   |_CODE:CODE:21bf.1[879]           ??          00h
   |_CODE:CODE:21c0  [880]           ??          FFh
   |_CODE:CODE:21c0.1[881]           ??          00h
   |_CODE:CODE:21c1  [882]           ??          FFh
   |_CODE:CODE:21c1.1[883]           ??          00h
   |_CODE:CODE:21c2  [884]           ??          FFh
   |_CODE:CODE:21c2.1[885]           ??          00h
   |_CODE:CODE:21c3  [886]           ??          FFh
   |_CODE:CODE:21c3.1[887]           ??          00h
   |_CODE:CODE:21c4  [888]           ??          FFh
   |_CODE:CODE:21c4.1[889]           ??          00h
   |_CODE:CODE:21c5  [890]           ??          FFh
   |_CODE:CODE:21c5.1[891]           ??          00h
   |_CODE:CODE:21c6  [892]           ??          FFh
   |_CODE:CODE:21c6.1[893]           ??          00h
   |_CODE:CODE:21c7  [894]           ??          FFh
   |_CODE:CODE:21c7.1[895]           ??          00h
   |_CODE:CODE:21c8  [896]           ??          FFh
   |_CODE:CODE:21c8.1[897]           ??          00h
   |_CODE:CODE:21c9  [898]           ??          FFh
   |_CODE:CODE:21c9.1[899]           ??          00h
   |_CODE:CODE:21ca  [900]           ??          FFh
   |_CODE:CODE:21ca.1[901]           ??          00h
   |_CODE:CODE:21cb  [902]           ??          FFh
   |_CODE:CODE:21cb.1[903]           ??          00h
   |_CODE:CODE:21cc  [904]           ??          FFh
   |_CODE:CODE:21cc.1[905]           ??          00h
   |_CODE:CODE:21cd  [906]           ??          FFh
   |_CODE:CODE:21cd.1[907]           ??          00h
   |_CODE:CODE:21ce  [908]           ??          FFh
   |_CODE:CODE:21ce.1[909]           ??          00h
   |_CODE:CODE:21cf  [910]           ??          FFh
   |_CODE:CODE:21cf.1[911]           ??          00h
   |_CODE:CODE:21d0  [912]           ??          FFh
   |_CODE:CODE:21d0.1[913]           ??          00h
   |_CODE:CODE:21d1  [914]           ??          FFh
   |_CODE:CODE:21d1.1[915]           ??          00h
   |_CODE:CODE:21d2  [916]           ??          FFh
   |_CODE:CODE:21d2.1[917]           ??          00h
   |_CODE:CODE:21d3  [918]           ??          FFh
   |_CODE:CODE:21d3.1[919]           ??          00h
   |_CODE:CODE:21d4  [920]           ??          FFh
   |_CODE:CODE:21d4.1[921]           ??          00h
   |_CODE:CODE:21d5  [922]           ??          FFh
   |_CODE:CODE:21d5.1[923]           ??          00h
   |_CODE:CODE:21d6  [924]           ??          FFh
   |_CODE:CODE:21d6.1[925]           ??          00h
   |_CODE:CODE:21d7  [926]           ??          FFh
   |_CODE:CODE:21d7.1[927]           ??          00h
   |_CODE:CODE:21d8  [928]           ??          FFh
   |_CODE:CODE:21d8.1[929]           ??          00h
   |_CODE:CODE:21d9  [930]           ??          FFh
   |_CODE:CODE:21d9.1[931]           ??          00h
   |_CODE:CODE:21da  [932]           ??          FFh
   |_CODE:CODE:21da.1[933]           ??          00h
   |_CODE:CODE:21db  [934]           ??          FFh
   |_CODE:CODE:21db.1[935]           ??          00h
   |_CODE:CODE:21dc  [936]           ??          FFh
   |_CODE:CODE:21dc.1[937]           ??          00h
   |_CODE:CODE:21dd  [938]           ??          FFh
   |_CODE:CODE:21dd.1[939]           ??          00h
   |_CODE:CODE:21de  [940]           ??          FFh
   |_CODE:CODE:21de.1[941]           ??          00h
   |_CODE:CODE:21df  [942]           ??          FFh
   |_CODE:CODE:21df.1[943]           ??          00h
   |_CODE:CODE:21e0  [944]           ??          FFh
   |_CODE:CODE:21e0.1[945]           ??          00h
   |_CODE:CODE:21e1  [946]           ??          FFh
   |_CODE:CODE:21e1.1[947]           ??          00h
   |_CODE:CODE:21e2  [948]           ??          FFh
   |_CODE:CODE:21e2.1[949]           ??          00h
   |_CODE:CODE:21e3  [950]           ??          FFh
   |_CODE:CODE:21e3.1[951]           ??          00h
   |_CODE:CODE:21e4  [952]           ??          FFh
   |_CODE:CODE:21e4.1[953]           ??          00h
   |_CODE:CODE:21e5  [954]           ??          FFh
   |_CODE:CODE:21e5.1[955]           ??          00h
   |_CODE:CODE:21e6  [956]           ??          FFh
   |_CODE:CODE:21e6.1[957]           ??          00h
   |_CODE:CODE:21e7  [958]           ??          FFh
   |_CODE:CODE:21e7.1[959]           ??          00h
   |_CODE:CODE:21e8  [960]           ??          FFh
   |_CODE:CODE:21e8.1[961]           ??          00h
   |_CODE:CODE:21e9  [962]           ??          FFh
   |_CODE:CODE:21e9.1[963]           ??          00h
   |_CODE:CODE:21ea  [964]           ??          FFh
   |_CODE:CODE:21ea.1[965]           ??          00h
   |_CODE:CODE:21eb  [966]           ??          FFh
   |_CODE:CODE:21eb.1[967]           ??          00h
   |_CODE:CODE:21ec  [968]           ??          FFh
   |_CODE:CODE:21ec.1[969]           ??          00h
   |_CODE:CODE:21ed  [970]           ??          FFh
   |_CODE:CODE:21ed.1[971]           ??          00h
   |_CODE:CODE:21ee  [972]           ??          FFh
   |_CODE:CODE:21ee.1[973]           ??          00h
   |_CODE:CODE:21ef  [974]           ??          FFh
   |_CODE:CODE:21ef.1[975]           ??          00h
   |_CODE:CODE:21f0  [976]           ??          FFh
   |_CODE:CODE:21f0.1[977]           ??          00h
   |_CODE:CODE:21f1  [978]           ??          FFh
   |_CODE:CODE:21f1.1[979]           ??          00h
   |_CODE:CODE:21f2  [980]           ??          FFh
   |_CODE:CODE:21f2.1[981]           ??          00h
   |_CODE:CODE:21f3  [982]           ??          FFh
   |_CODE:CODE:21f3.1[983]           ??          00h
   |_CODE:CODE:21f4  [984]           ??          FFh
   |_CODE:CODE:21f4.1[985]           ??          00h
   |_CODE:CODE:21f5  [986]           ??          FFh
   |_CODE:CODE:21f5.1[987]           ??          00h
   |_CODE:CODE:21f6  [988]           ??          FFh
   |_CODE:CODE:21f6.1[989]           ??          00h
   |_CODE:CODE:21f7  [990]           ??          FFh
   |_CODE:CODE:21f7.1[991]           ??          00h
   |_CODE:CODE:21f8  [992]           ??          FFh
   |_CODE:CODE:21f8.1[993]           ??          00h
   |_CODE:CODE:21f9  [994]           ??          FFh
   |_CODE:CODE:21f9.1[995]           ??          00h
   |_CODE:CODE:21fa  [996]           ??          FFh
   |_CODE:CODE:21fa.1[997]           ??          00h
   |_CODE:CODE:21fb  [998]           ??          FFh
   |_CODE:CODE:21fb.1[999]           ??          00h
   |_CODE:CODE:21fc  [1000]          ??          FFh
   |_CODE:CODE:21fc.1[1001]          ??          00h
   |_CODE:CODE:21fd  [1002]          ??          FFh
   |_CODE:CODE:21fd.1[1003]          ??          00h
   |_CODE:CODE:21fe  [1004]          ??          FFh
   |_CODE:CODE:21fe.1[1005]          ??          00h
   |_CODE:CODE:21ff  [1006]          ??          FFh
   |_CODE:CODE:21ff.1[1007]          ??          00h
                            INDF:
BANK-0:DATA:0000                ??          ??
                            TMR0:
BANK-0:DATA:0001                ??          ??
                            PCL:
BANK-0:DATA:0002                ??          ??
                            STATUS:
BANK-0:DATA:0003                ??          ??
                            FSR:                          ;XREF[1,0]:   CODE:1e5f
BANK-0:DATA:0004                ??          ??
                            PORTA:
BANK-0:DATA:0005                ??          ??
                            PORTB:                        ;XREF[16,0]:  CODE:1648,CODE:164c,CODE:1657,CODE:1659
                                                          ;             CODE:16d3,CODE:16d5,CODE:16d7,CODE:16d8
                                                          ;             CODE:16da,CODE:16ea,CODE:16eb,CODE:16ef
                                                          ;             CODE:16f1,CODE:173a,CODE:1761,CODE:1793
BANK-0:DATA:0006                ??          ??
                            PORTC:
BANK-0:DATA:0007                ??          ??
                            PORTD:
BANK-0:DATA:0008                ??          ??
                            PORTE:
BANK-0:DATA:0009                ??          ??
                            PCLATH:
BANK-0:DATA:000a                ??          ??
                            INTCON:
BANK-0:DATA:000b                ??          ??
                            PIR1:                         ;XREF[12,0]:  CODE:0020,CODE:0023,CODE:0033,CODE:0036
                                                          ;             CODE:003e,CODE:0041,CODE:0049,CODE:004c
                                                          ;             CODE:05ae,CODE:19d4,CODE:1e5c,CODE:1ec0
BANK-0:DATA:000c                ??          ??
                            PIR2:
BANK-0:DATA:000d                ??          ??
                            TMR1L:                        ;XREF[1,0]:   CODE:1ec2
BANK-0:DATA:000e                ??          ??
                            TMR1H:                        ;XREF[1,0]:   CODE:1ec4
BANK-0:DATA:000f                ??          ??
                            T1CON:
BANK-0:DATA:0010                ??          ??
                            TMR2:
BANK-0:DATA:0011                ??          ??
                            T2CON:                        ;XREF[1,0]:   CODE:1fa9
BANK-0:DATA:0012                ??          ??
                            SSPBUF:                       ;XREF[2,0]:   CODE:05b3,CODE:1e61
BANK-0:DATA:0013                ??          ??
                            SSPCON:
BANK-0:DATA:0014                ??          ??
                            CCPR1L:
BANK-0:DATA:0015                ??          ??
                            CCPR1H:
BANK-0:DATA:0016                ??          ??
                            CCP1CON:                      ;XREF[1,0]:   CODE:1fa8
BANK-0:DATA:0017                ??          ??
                            RCSTA:                        ;XREF[4,0]:   CODE:1eff,CODE:1f01,CODE:1f03,CODE:1f09
BANK-0:DATA:0018                ??          ??
                            TXREG:                        ;XREF[2,0]:   CODE:04fb,CODE:19d0
BANK-0:DATA:0019                ??          ??
                            RCREG:                        ;XREF[2,0]:   CODE:1f04,CODE:1f0b
BANK-0:DATA:001a                ??          ??
                            CCPR2L:
BANK-0:DATA:001b                ??          ??
                            CCPR2H:
BANK-0:DATA:001c                ??          ??
                            CCP2CON:
BANK-0:DATA:001d                ??          ??
                            ADRES:
BANK-0:DATA:001e                ??          ??
                            ADCON0:
BANK-0:DATA:001f                ??          ??
                            ;RAM BLOCK START
                            DAT_DATA_0020:                ;XREF[1,0]:   CODE:113d
BANK-0:DATA:0020                ??          ??
BANK-0:DATA:0021                ??          ??
                            DAT_DATA_0022:                ;XREF[2,0]:   CODE:1063,CODE:1072
BANK-0:DATA:0022                ??          ??
                            TIMER1_UNK5:                  ;XREF[7,0]:   CODE:09e2,CODE:0b01,CODE:0b49,CODE:0d81
                                                          ;             CODE:0deb,CODE:1ed5,CODE:1ed7
BANK-0:DATA:0023                ??          ??
                            DAT_DATA_0024:                ;XREF[3,0]:   CODE:111b,CODE:1157,CODE:1730
BANK-0:DATA:0024                ??          ??
                            DAT_DATA_0025:                ;XREF[1,0]:   CODE:055b
BANK-0:DATA:0025                ??          ??
                            DAT_DATA_0026:                ;XREF[1,0]:   CODE:055d
BANK-0:DATA:0026                ??          ??
BANK-0:DATA:0027                ??          ??
BANK-0:DATA:0028                ??          ??
                            DAT_DATA_0029:                ;XREF[1,0]:   CODE:1334
BANK-0:DATA:0029                ??          ??
                            DAT_DATA_002a:                ;XREF[6,0]:   CODE:09b4,CODE:09c3,CODE:09ee,CODE:0a39
                                                          ;             CODE:0a7d,CODE:0aac
BANK-0:DATA:002a                ??          ??
                            DAT_DATA_002b:                ;XREF[1,0]:   CODE:0a67
BANK-0:DATA:002b                ??          ??
                            ENTRY_DATA_UNK3:              ;XREF[3,0]:   CODE:0d3c,CODE:0f2f,CODE:100e
BANK-0:DATA:002c                db          ??
                            USART_RX_PACKET_STATUS:       ;XREF[11,0]:  CODE:04f3,CODE:05ad,CODE:05c8,CODE:0721
                                                          ;             CODE:1006,CODE:16e2,CODE:16e3,CODE:16e6
                                                          ;             CODE:1f0d,CODE:1f0e,CODE:1f44
BANK-0:DATA:002d                db          ??
                            DAT_DATA_002e:                ;XREF[4,0]:   CODE:0595,CODE:078c,CODE:0b54,CODE:0b6f
BANK-0:DATA:002e                ??          ??
                            ENTRY_DATA_UNK1:              ;XREF[6,0]:   CODE:0488,CODE:056c,CODE:09aa,CODE:0a5b
                                                          ;             CODE:0d00,CODE:1007
BANK-0:DATA:002f                db          ??
                            DAT_DATA_0030:                ;XREF[5,0]:   CODE:025b,CODE:02bd,CODE:0b1b,CODE:0b31
                                                          ;             CODE:0b9f
BANK-0:DATA:0030                ??          ??
BANK-0:DATA:0031                ??          ??
BANK-0:DATA:0032                ??          ??
                            BYTE_DATA_0033:               ;XREF[1,0]:   CODE:1fab
BANK-0:DATA:0033                db          ??
BANK-0:DATA:0034                ??          ??
BANK-0:DATA:0035                ??          ??
                            TIMER1_UNK2:                  ;XREF[2,0]:   CODE:0e5f,CODE:1ecb
BANK-0:DATA:0036                ??          ??
                            DAT_DATA_0037:                ;XREF[1,0]:   CODE:0661
BANK-0:DATA:0037                ??          ??
BANK-0:DATA:0038                ??          ??
                            DAT_DATA_0039:                ;XREF[1,0]:   CODE:0986
BANK-0:DATA:0039                ??          ??
                            TIMER1_UNK4:                  ;XREF[7,0]:   CODE:0393,CODE:03a9,CODE:0548,CODE:062f
                                                          ;             CODE:063e,CODE:064a,CODE:1ed1
BANK-0:DATA:003a                ??          ??
                            DAT_DATA_003b:                ;XREF[20,0]:  CODE:0212,CODE:029f,CODE:0319,CODE:0428
                                                          ;             CODE:08e3,CODE:0af4,CODE:0b09,CODE:0b96
                                                          ;             CODE:0c0b,CODE:0c16,CODE:0c1e,CODE:0c93
                                                          ;             CODE:0cc0,CODE:0cd0,CODE:0cf2,CODE:0d96
                                                          ;             CODE:0dd4,CODE:0de3,CODE:0df9,CODE:0e73
BANK-0:DATA:003b                ??          ??
                            DAT_DATA_003c:                ;XREF[7,0]:   CODE:0bee,CODE:0c4e,CODE:0c65,CODE:0c79
                                                          ;             CODE:0c85,CODE:0ccb,CODE:0d20
BANK-0:DATA:003c                ??          ??
                            DAT_DATA_003d:                ;XREF[5,0]:   CODE:10f4,CODE:10fd,CODE:1106,CODE:110d
                                                          ;             CODE:113f
BANK-0:DATA:003d                ??          ??
                            DAT_DATA_003e:                ;XREF[10,0]:  CODE:054c,CODE:0998,CODE:0d63,CODE:0d67
                                                          ;             CODE:0d6b,CODE:0d6f,CODE:0d73,CODE:0d77
                                                          ;             CODE:0d7b,CODE:0def
BANK-0:DATA:003e                ??          ??
BANK-0:DATA:003f                ??          ??
                            SSP_PACKET_SIZE:              ;XREF[4,0]:   CODE:05af,CODE:1e5d,CODE:1e63,CODE:1e65
BANK-0:DATA:0040                ??          ??
                            SSP_UNK1_PACKET_SIZE_MAX:     ;XREF[2,0]:   CODE:05ac,CODE:1e64
BANK-0:DATA:0041                ??          ??
                            DAT_DATA_0042:                ;XREF[1,0]:   CODE:1f22
BANK-0:DATA:0042                ??          ??
BANK-0:DATA:0043                ??          ??
                            SSP_UNK2:                     ;XREF[1,0]:   CODE:1e69
BANK-0:DATA:0044                ??          ??
                            DAT_DATA_0045:                ;XREF[1,0]:   CODE:1792
BANK-0:DATA:0045                ??          ??
BANK-0:DATA:0046                ??          ??
                            DAT_DATA_0047:                ;XREF[3,0]:   CODE:0a7b,CODE:0e00,CODE:153c
BANK-0:DATA:0047                ??          ??
                            DAT_DATA_0048:                ;XREF[4,0]:   CODE:042e,CODE:0aa9,CODE:0c8e,CODE:0e71
BANK-0:DATA:0048                ??          ??
BANK-0:DATA:0049                ??          ??
                            DAT_DATA_004a:                ;XREF[12,0]:  CODE:0bcb,CODE:137a,CODE:1383,CODE:138b
                                                          ;             CODE:1393,CODE:139b,CODE:13a4,CODE:13ac
                                                          ;             CODE:13b5,CODE:16e9,CODE:16f2,CODE:16f4
BANK-0:DATA:004a                ??          ??
                            DAT_DATA_004b:                ;XREF[4,0]:   CODE:0f4e,CODE:1705,CODE:170a,CODE:170d
BANK-0:DATA:004b                ??          ??
                            DAT_DATA_004c:                ;XREF[3,0]:   CODE:1706,CODE:170c,CODE:170e
BANK-0:DATA:004c                ??          ??
                            DAT_DATA_004d:                ;XREF[2,0]:   CODE:0124,CODE:0125
BANK-0:DATA:004d                ??          ??
                            DAT_DATA_004e:                ;XREF[1,0]:   CODE:01f1
BANK-0:DATA:004e                ??          ??
                            DAT_DATA_004f:                ;XREF[7,0]:   CODE:01ea,CODE:04da,CODE:04e3,CODE:055c
                                                          ;             CODE:0563,CODE:1732,CODE:17d1
BANK-0:DATA:004f                ??          ??
                            DAT_DATA_0050:                ;XREF[4,0]:   CODE:055e,CODE:0591,CODE:1452,CODE:1736
BANK-0:DATA:0050                ??          ??
                            DAT_DATA_0051:                ;XREF[9,0]:   CODE:058a,CODE:058c,CODE:058e,CODE:0590
                                                          ;             CODE:173f,CODE:1744,CODE:1748,CODE:1770
                                                          ;             CODE:178d
BANK-0:DATA:0051                ??          ??
                            INIT_ST1_UNK1:                ;XREF[15,0]:  CODE:04a7,CODE:04e8,CODE:05a3,CODE:05cb
                                                          ;             CODE:173e,CODE:1743,CODE:1751,CODE:1757
                                                          ;             CODE:1758,CODE:1763,CODE:1767,CODE:176f
                                                          ;             CODE:177b,CODE:1e72,CODE:1e7c
BANK-0:DATA:0052                db          ??
                            INIT_ST1_UNK2:                ;XREF[9,0]:   CODE:0496,CODE:04e9,CODE:05a5,CODE:05cd
                                                          ;             CODE:1492,CODE:177c,CODE:1787,CODE:1e74
                                                          ;             CODE:1e7a
BANK-0:DATA:0053                db          ??
                            INIT_ST1_UNK3:                ;XREF[7,0]:   CODE:0491,CODE:049a,CODE:04a1,CODE:177d
                                                          ;             CODE:177e,CODE:1e76,CODE:1e77
BANK-0:DATA:0054                db          ??
                            DAT_DATA_0055:                ;XREF[7,0]:   CODE:011c,CODE:01ec,CODE:01f2,CODE:0493
                                                          ;             CODE:049e,CODE:04a5,CODE:04ab
BANK-0:DATA:0055                ??          ??
                            DAT_DATA_0056:                ;XREF[7,0]:   CODE:00fe,CODE:010a,CODE:0494,CODE:0499
                                                          ;             CODE:04a0,CODE:04a6,CODE:04a8
BANK-0:DATA:0056                ??          ??
                            DAT_DATA_0057:                ;XREF[5,0]:   CODE:0102,CODE:0109,CODE:0112,CODE:0116
                                                          ;             CODE:011b
BANK-0:DATA:0057                ??          ??
                            DAT_DATA_0058:                ;XREF[2,0]:   CODE:06a6,CODE:06e3
BANK-0:DATA:0058                ??          ??
BANK-0:DATA:0059                ??          ??
BANK-0:DATA:005a                ??          ??
BANK-0:DATA:005b                ??          ??
                            DAT_DATA_005c:                ;XREF[3,0]:   CODE:165f,CODE:16fb,CODE:174d
BANK-0:DATA:005c                ??          ??
                            DAT_DATA_005d:                ;XREF[2,0]:   CODE:1663,CODE:16fc
BANK-0:DATA:005d                ??          ??
                            DAT_DATA_005e:                ;XREF[6,0]:   CODE:166c,CODE:1671,CODE:1675,CODE:168d
                                                          ;             CODE:16a9,CODE:16fe
BANK-0:DATA:005e                ??          ??
                            DAT_DATA_005f:                ;XREF[13,0]:  CODE:1667,CODE:166b,CODE:1670,CODE:167e
                                                          ;             CODE:1684,CODE:1685,CODE:1688,CODE:168c
                                                          ;             CODE:1692,CODE:1693,CODE:169a,CODE:16b3
                                                          ;             CODE:16c2
BANK-0:DATA:005f                ??          ??
                            DAT_DATA_0060:                ;XREF[2,0]:   CODE:16b4,CODE:16bf
BANK-0:DATA:0060                ??          ??
                            DAT_DATA_0061:                ;XREF[2,0]:   CODE:16b5,CODE:16b6
BANK-0:DATA:0061                ??          ??
BANK-0:DATA:0062                ??          ??
BANK-0:DATA:0063                ??          ??
BANK-0:DATA:0064                ??          ??
                            USART_RX_RCVD_BYTE:           ;XREF[8,0]:   CODE:1f05,CODE:1f0c,CODE:1f17,CODE:1f1b
                                                          ;             CODE:1f26,CODE:1f29,CODE:1f30,CODE:1f3c
BANK-0:DATA:0065                db          ??
BANK-0:DATA:0066                ??          ??
                            ;THIS IS WHERE THE INIT MEMCLEAR ENDS
BANK-0:DATA:0067                ??          ??
BANK-0:DATA:0068                ??          ??
                            ISR_BKP_STATUS:               ;XREF[2,0]:   CODE:0007,CODE:006b
BANK-0:DATA:0069                ??          ??
                            ISR_BKP_FSR:                  ;XREF[2,0]:   CODE:0009,CODE:0067
BANK-0:DATA:006a                ??          ??
                            ISR_BKP_PCLATH:               ;XREF[2,0]:   CODE:000b,CODE:0069
BANK-0:DATA:006b                ??          ??
                            ISR_BKP_JUMPTO_PCL:           ;XREF[2,0]:   CODE:001c,CODE:0063
BANK-0:DATA:006c                ??          ??
                            ISR_BKP_JUMPTO_PCH:           ;XREF[2,0]:   CODE:001e,CODE:0065
BANK-0:DATA:006d                ??          ??
                            FETCH_ADDR_L:                 ;XREF[8,0]:   CODE:001b,CODE:0064,CODE:0077,CODE:00ab
                                                          ;             CODE:00b2,CODE:00b3,CODE:00ba,CODE:00bb
BANK-0:DATA:006e                db          ??
                            FETCH_ADDR_H:                 ;XREF[8,0]:   CODE:001d,CODE:0066,CODE:0075,CODE:00ac
                                                          ;             CODE:00ae,CODE:00b0,CODE:00b5,CODE:00b8
BANK-0:DATA:006f                db          ??
                            ISR_BKP_70:                   ;XREF[2,0]:   CODE:0014,CODE:005b
BANK-0:DATA:0070                ??          ??
                            ISR_BKP_7a:                   ;XREF[2,0]:   CODE:0010,CODE:0057
BANK-0:DATA:0071                ??          ??
                            ISR_BKP_7b:                   ;XREF[2,0]:   CODE:0012,CODE:0059
BANK-0:DATA:0072                ??          ??
                            ISR_BKP_7f:                   ;XREF[2,0]:   CODE:001a,CODE:0061
BANK-0:DATA:0073                ??          ??
                            ISR_BKP_ENTRY_SUB2_UNK1:      ;XREF[2,0]:   CODE:000e,CODE:0055
BANK-0:DATA:0074                ??          ??
                            ISR_BKP_7d:                   ;XREF[2,0]:   CODE:0016,CODE:005d
BANK-0:DATA:0075                ??          ??
                            ISR_BKP_7e:                   ;XREF[2,0]:   CODE:0018,CODE:005f
BANK-0:DATA:0076                ??          ??
BANK-0:DATA:0077                ??          ??
                            ISR_BKP_WREG:                 ;XREF[3,0]:   CODE:0004,CODE:006d,CODE:006e
BANK-0:DATA:0078                ??          ??
                            ENTRY_SUB2_UNK1:              ;XREF[66,0]:  CODE:000d,CODE:0056,CODE:009c,CODE:00a5
                                                          ;             CODE:00ca,CODE:00dc,CODE:00e0,CODE:00f7
                                                          ;             CODE:00f8,CODE:0438,CODE:0440,CODE:0444
                                                          ;             CODE:0853,CODE:0856,CODE:08bb,CODE:08be
                                                          ;             CODE:0936,CODE:0939,CODE:0c2f,CODE:0c32
                                                          ;             CODE:0e88,CODE:0e90,CODE:0e94,CODE:1184
                                                          ;             CODE:1189,CODE:1193,CODE:11a1,CODE:11a6
                                                          ;             CODE:11b0,CODE:11bd,CODE:11c2,CODE:11cc
                                                          ;             CODE:11d9,CODE:11de,CODE:11e8,CODE:11f5
                                                          ;             CODE:11fb,CODE:1221,CODE:1228,CODE:122b
                                                          ;             CODE:126f,CODE:1273,CODE:1282,CODE:13f1
                                                          ;             CODE:13f8,CODE:13fb,CODE:1429,CODE:142d
                                                          ;             CODE:143c,CODE:1455,CODE:1457,CODE:145a
                                                          ;             CODE:1475,CODE:1478,CODE:16b0,CODE:16be
                                                          ;             CODE:1777,CODE:1786,CODE:17d7,CODE:17d9
                                                          ;             CODE:17e1,CODE:19f5,CODE:19fc,CODE:1a29
                                                          ;             CODE:1a2c,CODE:1a2e
BANK-0:DATA:0079                ??          ??
                            DAT_DATA_007a:                ;XREF[47,0]:  CODE:000f,CODE:0058,CODE:00cb,CODE:00d8
                                                          ;             CODE:00e4,CODE:00fa,CODE:00fb,CODE:1182
                                                          ;             CODE:118b,CODE:119f,CODE:11a8,CODE:11bb
                                                          ;             CODE:11c4,CODE:11d7,CODE:11e0,CODE:11f3
                                                          ;             CODE:1222,CODE:1229,CODE:122d,CODE:122f
                                                          ;             CODE:1270,CODE:1275,CODE:127d,CODE:13f2
                                                          ;             CODE:13f9,CODE:13fd,CODE:13ff,CODE:142a
                                                          ;             CODE:142f,CODE:1437,CODE:1453,CODE:1459
                                                          ;             CODE:145d,CODE:14d1,CODE:16b1,CODE:16b9
                                                          ;             CODE:1778,CODE:1781,CODE:17d5,CODE:17db
                                                          ;             CODE:17dc,CODE:19f7,CODE:19f9,CODE:19fd
                                                          ;             CODE:1a2b,CODE:1a30,CODE:1a31
BANK-0:DATA:007a                ??          ??
                            DAT_DATA_007b:                ;XREF[41,0]:  CODE:0011,CODE:005a,CODE:00c6,CODE:00d1
                                                          ;             CODE:00d6,CODE:00db,CODE:00df,CODE:00f2
                                                          ;             CODE:0434,CODE:0437,CODE:0b0b,CODE:0b0e
                                                          ;             CODE:0b1e,CODE:0b21,CODE:0c95,CODE:0c98
                                                          ;             CODE:0e84,CODE:0e87,CODE:117d,CODE:118d
                                                          ;             CODE:1199,CODE:11aa,CODE:11b6,CODE:11c6
                                                          ;             CODE:11d2,CODE:11e2,CODE:11ee,CODE:121d
                                                          ;             CODE:1231,CODE:127c,CODE:127f,CODE:13ed
                                                          ;             CODE:1401,CODE:1436,CODE:1439,CODE:16b8
                                                          ;             CODE:16bb,CODE:1780,CODE:1783,CODE:19f2
                                                          ;             CODE:19fe
BANK-0:DATA:007b                ??          ??
                            DAT_DATA_007c:                ;XREF[34,0]:  CODE:0013,CODE:005c,CODE:00c7,CODE:00d2
                                                          ;             CODE:00d5,CODE:00d7,CODE:00e1,CODE:00e3
                                                          ;             CODE:00f4,CODE:0435,CODE:0461,CODE:0b0c
                                                          ;             CODE:0b16,CODE:0b1f,CODE:0b2c,CODE:0c96
                                                          ;             CODE:0cac,CODE:0e85,CODE:0ec2,CODE:117f
                                                          ;             CODE:118f,CODE:119b,CODE:11ac,CODE:11b7
                                                          ;             CODE:11c8,CODE:11d3,CODE:11e4,CODE:11ef
                                                          ;             CODE:121e,CODE:1233,CODE:13ee,CODE:1403
                                                          ;             CODE:19f1,CODE:19ff
BANK-0:DATA:007c                ??          ??
                            DAT_DATA_007d:                ;XREF[19,0]:  CODE:0015,CODE:005e,CODE:00c4,CODE:00e5
                                                          ;             CODE:00ec,CODE:00ed,CODE:00f1,CODE:1188
                                                          ;             CODE:11a5,CODE:11c1,CODE:11dd,CODE:122a
                                                          ;             CODE:1238,CODE:123b,CODE:13fa,CODE:1408
                                                          ;             CODE:140b,CODE:19ee,CODE:19f6
BANK-0:DATA:007d                ??          ??
                            DAT_DATA_007e:                ;XREF[19,0]:  CODE:0017,CODE:0060,CODE:00c5,CODE:00e6
                                                          ;             CODE:00ef,CODE:00f0,CODE:00f3,CODE:118a
                                                          ;             CODE:11a7,CODE:11c3,CODE:11df,CODE:122e
                                                          ;             CODE:123a,CODE:123e,CODE:13fe,CODE:140a
                                                          ;             CODE:140e,CODE:19ef,CODE:19fa
BANK-0:DATA:007e                ??          ??
                            DAT_DATA_007f:                ;XREF[9,0]:   CODE:0019,CODE:0062,CODE:00c3,CODE:00ce
                                                          ;             CODE:00d0,CODE:00e7,CODE:00e8,CODE:00ea
                                                          ;             CODE:00f5
BANK-0:DATA:007f                ??          ??
                            ;RAM BLOCK END
                            INDF:
BANK-1:BANK-1...                ??          ??
                            OPTION_REG:
BANK-1:BANK-1...                ??          ??
                            PCL:
BANK-1:BANK-1...                ??          ??
                            STATUS:
BANK-1:BANK-1...                ??          ??
                            FSR:
BANK-1:BANK-1...                ??          ??
                            TRISA:
BANK-1:BANK-1...                ??          ??
                            TRISB:                        ;XREF[4,0]:   CODE:164e,CODE:164f,CODE:1655,CODE:16ed
BANK-1:BANK-1...                ??          ??
                            TRISC:
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            TRISE:
BANK-1:BANK-1...                ??          ??
                            PCLATH:
BANK-1:BANK-1...                ??          ??
                            INTCON:
BANK-1:BANK-1...                ??          ??
                            PIE1:                         ;XREF[3,0]:   CODE:04fd,CODE:05b5,CODE:1e6c
BANK-1:BANK-1...                db          ??
                            PIE2:
BANK-1:BANK-1...                ??          ??
                            PCON:
BANK-1:BANK-1...                ??          ??
                            OSCON:
BANK-1:BANK-1...                ??          ??
                            OSTUNE:
BANK-1:BANK-1...                ??          ??
                            ANSEL:
BANK-1:BANK-1...                ??          ??
                            PR2:
BANK-1:BANK-1...                ??          ??
                            SSPADD:
BANK-1:BANK-1...                ??          ??
                            SSPSTAT:
BANK-1:BANK-1...                ??          ??
                            WPUB:
BANK-1:BANK-1...                ??          ??
                            IOCB:
BANK-1:BANK-1...                ??          ??
                            CMCON1:
BANK-1:BANK-1...                ??          ??
                            TXSTA:
BANK-1:BANK-1...                ??          ??
                            SPBRG:
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            CMCON0:
BANK-1:BANK-1...                ??          ??
                            VRCON:
BANK-1:BANK-1...                ??          ??
                            ADRESL:
BANK-1:BANK-1...                ??          ??
                            ADCON1:
BANK-1:BANK-1...                ??          ??
                            ;RAM BLOCK START
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__0021:             ;XREF[1,0]:   CODE:056e
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__0024:             ;XREF[3,0]:   CODE:165d,CODE:1698,CODE:175d
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__002a:             ;XREF[2,0]:   CODE:059b,CODE:1715
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__002b:             ;XREF[1,0]:   CODE:0576
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            SSP_UNK4:                     ;XREF[5,0]:   CODE:0542,CODE:0552,CODE:0588,CODE:1e6e
                                                          ;             CODE:1e6f
BANK-1:BANK-1...                db          ??
                            DAT_BANK-1__002e:             ;XREF[1,0]:   CODE:057e
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            ENTRY_DATA_UNK2:              ;XREF[5,0]:   CODE:0545,CODE:0550,CODE:0555,CODE:0559
                                                          ;             CODE:100c
BANK-1:BANK-1...                db          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            USART_RX_UNKNOWN:             ;XREF[1,0]:   CODE:1f12
BANK-1:BANK-1...                db          ??
                            USART_TX_UNKNOWN:             ;XREF[1,0]:   CODE:19d6
BANK-1:BANK-1...                db          ??
BANK-1:BANK-1...                ??          ??
                            USART_RX_BUFFER_INDEX:        ;XREF[9,0]:   CODE:071f,CODE:1f07,CODE:1f13,CODE:1f20
                                                          ;             CODE:1f2e,CODE:1f35,CODE:1f37,CODE:1f3f
                                                          ;             CODE:1f40
BANK-1:BANK-1...                db          ??
                            USART_RX_PACKET_SIZE:         ;XREF[2,0]:   CODE:1f32,CODE:1f41
BANK-1:BANK-1...                db          ??
                            USART_TX_BUFFER_INDEX:        ;XREF[5,0]:   CODE:04f5,CODE:04f6,CODE:19c7,CODE:19ca
                                                          ;             CODE:19d2
BANK-1:BANK-1...                db          ??
                            USART_TX_PACKET_SIZE:         ;XREF[2,0]:   CODE:04f1,CODE:19c6
BANK-1:BANK-1...                db          ??
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__0047:             ;XREF[1,0]:   CODE:16cb
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__004e:             ;XREF[1,0]:   CODE:071d
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__005b:             ;XREF[4,0]:   CODE:1661,CODE:1680,CODE:1734,CODE:1753
BANK-1:BANK-1...                ??          ??
                            DAT_BANK-1__005c:             ;XREF[3,0]:   CODE:1665,CODE:167a,CODE:1738
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            TIMER1_UNK6:                  ;XREF[4,0]:   CODE:1ee6,CODE:1ef2,CODE:1ef5,CODE:1ef7
BANK-1:BANK-1...                db          ??
                            TIMER1_UNK3:                  ;XREF[5,0]:   CODE:1ece,CODE:1ecf,CODE:1edb,CODE:1ede
                                                          ;             CODE:1ef1
BANK-1:BANK-1...                db          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
BANK-1:BANK-1...                ??          ??
                            ;RAM BLOCK END
BANK-1:BANK-1...                db[16]      ??
   |_BANK-1:BANK-1...[0]             db          ??
   |_BANK-1:BANK-1...[1]             db          ??
   |_BANK-1:BANK-1...[2]             db          ??
   |_BANK-1:BANK-1...[3]             db          ??
   |_BANK-1:BANK-1...[4]             db          ??
   |_BANK-1:BANK-1...[5]             db          ??
   |_BANK-1:BANK-1...[6]             db          ??
   |_BANK-1:BANK-1...[7]             db          ??
   |_BANK-1:BANK-1...[8]             db          ??
   |_BANK-1:BANK-1...[9]             db          ??
   |_BANK-1:BANK-1...[10]            db          ??
   |_BANK-1:BANK-1...[11]            db          ??
   |_BANK-1:BANK-1...[12]            db          ??
   |_BANK-1:BANK-1...[13]            db          ??
   |_BANK-1:BANK-1...[14]            db          ??
   |_BANK-1:BANK-1...[15]            db          ??
                            INDF:
BANK-2:BANK-2...                ??          ??
                            TMR0:
BANK-2:BANK-2...                ??          ??
                            PCL:
BANK-2:BANK-2...                ??          ??
                            STATUS:
BANK-2:BANK-2...                ??          ??
                            FSR:
BANK-2:BANK-2...                ??          ??
                            WDTCON:
BANK-2:BANK-2...                ??          ??
                            PORTB:
BANK-2:BANK-2...                ??          ??
                            LCDCON:
BANK-2:BANK-2...                ??          ??
                            LCDPS:
BANK-2:BANK-2...                ??          ??
                            LVDCON:
BANK-2:BANK-2...                ??          ??
                            PCLATH:
BANK-2:BANK-2...                ??          ??
                            INTCON:
BANK-2:BANK-2...                ??          ??
                            EEDATL:
BANK-2:BANK-2...                ??          ??
                            EEADRL:
BANK-2:BANK-2...                ??          ??
                            EEADATH:
BANK-2:BANK-2...                ??          ??
                            EEADRH:
BANK-2:BANK-2...                ??          ??
                            LCDDATA0:
BANK-2:BANK-2...                ??          ??
                            LCDDATA1:
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            LCDDATA3:
BANK-2:BANK-2...                ??          ??
                            LCDDATA4:
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            LCDDATA6:
BANK-2:BANK-2...                ??          ??
                            LCDDATA7:
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            LCDDATA9:
BANK-2:BANK-2...                ??          ??
                            LCDDATA10:
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            LCDSE0:
BANK-2:BANK-2...                ??          ??
                            LCDSE1:
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            ;RAM BLOCK START
                            DAT_BANK-2__0020:             ;XREF[1,0]:   CODE:0566
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0021:             ;XREF[1,0]:   CODE:059f
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            SSP_BUFFER:                   ;XREF[1,1]:   CODE:1e62,CODE:05e8
BANK-2:BANK-2...                db[11]      ??
   |_BANK-2:BANK-2...[0]             db          ??
   |_BANK-2:BANK-2...[1]             db          ??
   |_BANK-2:BANK-2...[2]             db          ??
   |_BANK-2:BANK-2...[3]             db          ??
   |_BANK-2:BANK-2...[4]             db          ??
   |_BANK-2:BANK-2...[5]             db          ??
   |_BANK-2:BANK-2...[6]             db          ??
   |_BANK-2:BANK-2...[7]             db          ??
   |_BANK-2:BANK-2...[8]             db          ??
   |_BANK-2:BANK-2...[9]             db          ??
   |_BANK-2:BANK-2...[10]            db          ??
                            SSP_BYTE_TOSEND:              ;XREF[2,0]:   CODE:0561,CODE:05b1
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__003d:             ;XREF[1,0]:   CODE:0565
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__003e:             ;XREF[1,0]:   CODE:0567
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__003f:             ;XREF[1,0]:   CODE:0569
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0040:             ;XREF[1,0]:   CODE:0573
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0041:             ;XREF[1,0]:   CODE:057b
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0042:             ;XREF[1,0]:   CODE:0585
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0043:             ;XREF[2,0]:   CODE:0593,CODE:0598
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0044:             ;XREF[1,0]:   CODE:059e
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0045:             ;XREF[1,0]:   CODE:05a0
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0046:             ;XREF[1,0]:   CODE:05a9
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0047:             ;XREF[3,0]:   CODE:1703,CODE:1712,CODE:176b
BANK-2:BANK-2...                ??          ??
                            DAT_BANK-2__0048:             ;XREF[1,0]:   CODE:1708
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            USART_PACKET_BUFFER:          ;XREF[4,7]:   CODE:04dd,CODE:04f9,CODE:19ce,CODE:1f1d
                                                          ;             CODE:04df,CODE:04e1,CODE:04e5,CODE:04e6
                                                          ;             CODE:04ed,CODE:04ee,CODE:1f2b
BANK-2:BANK-2...                db[23]      ??
   |_BANK-2:BANK-2...[0]             db          ??
   |_BANK-2:BANK-2...[1]             db          ??
   |_BANK-2:BANK-2...[2]             db          ??
   |_BANK-2:BANK-2...[3]             db          ??
   |_BANK-2:BANK-2...[4]             db          ??
   |_BANK-2:BANK-2...[5]             db          ??
   |_BANK-2:BANK-2...[6]             db          ??
   |_BANK-2:BANK-2...[7]             db          ??
   |_BANK-2:BANK-2...[8]             db          ??
   |_BANK-2:BANK-2...[9]             db          ??
   |_BANK-2:BANK-2...[10]            db          ??
   |_BANK-2:BANK-2...[11]            db          ??
   |_BANK-2:BANK-2...[12]            db          ??
   |_BANK-2:BANK-2...[13]            db          ??
   |_BANK-2:BANK-2...[14]            db          ??
   |_BANK-2:BANK-2...[15]            db          ??
   |_BANK-2:BANK-2...[16]            db          ??
   |_BANK-2:BANK-2...[17]            db          ??
   |_BANK-2:BANK-2...[18]            db          ??
   |_BANK-2:BANK-2...[19]            db          ??
   |_BANK-2:BANK-2...[20]            db          ??
   |_BANK-2:BANK-2...[21]            db          ??
   |_BANK-2:BANK-2...[22]            db          ??
BANK-2:BANK-2...                ??          ??
BANK-2:BANK-2...                ??          ??
                            ;RAM BLOCK END
BANK-2:BANK-2...                db[16]      ??
   |_BANK-2:BANK-2...[0]             db          ??
   |_BANK-2:BANK-2...[1]             db          ??
   |_BANK-2:BANK-2...[2]             db          ??
   |_BANK-2:BANK-2...[3]             db          ??
   |_BANK-2:BANK-2...[4]             db          ??
   |_BANK-2:BANK-2...[5]             db          ??
   |_BANK-2:BANK-2...[6]             db          ??
   |_BANK-2:BANK-2...[7]             db          ??
   |_BANK-2:BANK-2...[8]             db          ??
   |_BANK-2:BANK-2...[9]             db          ??
   |_BANK-2:BANK-2...[10]            db          ??
   |_BANK-2:BANK-2...[11]            db          ??
   |_BANK-2:BANK-2...[12]            db          ??
   |_BANK-2:BANK-2...[13]            db          ??
   |_BANK-2:BANK-2...[14]            db          ??
   |_BANK-2:BANK-2...[15]            db          ??
                            INDF:
BANK-3:BANK-3...                ??          ??
                            OPTION_REG:
BANK-3:BANK-3...                ??          ??
                            PCL:
BANK-3:BANK-3...                ??          ??
                            STATUS:
BANK-3:BANK-3...                ??          ??
                            FSR:
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
                            TRISB:
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
                            PCLATH:
BANK-3:BANK-3...                ??          ??
                            INTCON:
BANK-3:BANK-3...                ??          ??
                            EECON1:
BANK-3:BANK-3...                ??          ??
                            EECON2:
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
                            ;RAM BLOCK START
                            TIMER1_UNK1:                  ;XREF[2,0]:   CODE:100a,CODE:1ec7
BANK-3:BANK-3...                db          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
                            DAT_BANK-3__0069:             ;XREF[1,0]:   CODE:08ca
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
BANK-3:BANK-3...                ??          ??
                            ;RAM BLOCK END
BANK-3:BANK-3...                db[16]      ??
   |_BANK-3:BANK-3...[0]             db          ??
   |_BANK-3:BANK-3...[1]             db          ??
   |_BANK-3:BANK-3...[2]             db          ??
   |_BANK-3:BANK-3...[3]             db          ??
   |_BANK-3:BANK-3...[4]             db          ??
   |_BANK-3:BANK-3...[5]             db          ??
   |_BANK-3:BANK-3...[6]             db          ??
   |_BANK-3:BANK-3...[7]             db          ??
   |_BANK-3:BANK-3...[8]             db          ??
   |_BANK-3:BANK-3...[9]             db          ??
   |_BANK-3:BANK-3...[10]            db          ??
   |_BANK-3:BANK-3...[11]            db          ??
   |_BANK-3:BANK-3...[12]            db          ??
   |_BANK-3:BANK-3...[13]            db          ??
   |_BANK-3:BANK-3...[14]            db          ??
   |_BANK-3:BANK-3...[15]            db          ??
