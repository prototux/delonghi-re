# Tools

- `pic14dis.py`: a PIC16F916 disassembler that follows RP0/RP1/IRP and PCLATH through the control flow graph.
  - Registers are named after the bank they are really in, and CALL/GOTO targets resolve to the right page.
  - Computed-goto tables and RETLW tables are followed.
  - RAM and function names come from `symbols.py`, which uses the same names as `../reimplem/`. The old Ghidra names are kept in `OLD_NAMES`.

  ```
  FW=../../files/machines/ECAM_23.450/display_board_5513220041_v30_firmware.bin
  ./pic14dis.py $FW                  # full listing
  ./pic14dis.py $FW -f link_update   # one function (by name or address)
  ./pic14dis.py $FW --xref 0x4f      # accesses to a RAM address (linear, e.g. 0xa9, 0x123)
  ./pic14dis.py $FW --calls          # call graph
  ```

  The bank column shows `b0`..`b3`, `b?` when several banks can reach the instruction, and `b-` for code that is never reached (data or dead code).
