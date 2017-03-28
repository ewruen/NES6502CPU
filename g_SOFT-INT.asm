        OP00: 
        OPEA:
        ; When the MOS 6502 processor was modified into the Ricoh 2A03 chip for the NES,\
        ; the BRK (Force Break) opcode was eliminated. 
        ; Thus, the BRK command doesn't actually do anything on the NES and is effectively identical to NOP. 
        ; Because of this, when you see a BRK in decompiled NES code,\
        ; you can be fairly certain that the #00 value is either game data or unused.
        ; Having a BRK execute on the NES won't harm anything, it will only eat up a clock cycle to process. 
        ; You can take advantage of this feature when making game cheats. 
        ; For example, if you want to change an opcode that takes a two-byte operand into an opcode that uses a one-byte operand,\ 
        ; you can ignore the second byte of the operand if it is a #00 because the NES will simply treat it as a BRK, which is ignored.
        ; On an original MOS 6502 processor,\
        ; BRK would set the Interrupt Flag to prevent further interrupts and then move the Program Counter Register to the new location.
        ; Addressing Modes
        ; ==================================================================
        ; Addressing Mode   Assembly Language Form  Opcode  # Bytes # Cycles
        ; ===============   ======================  ======   ======   =====
        ;   Implied                 BRK              00         1       2
        ; ========================================================================
        ; ref link: www.thealmightyguru.com/Games/Hacking/Wiki/index.php?title=BRK
        ; ========================================================================
            add     ebp,    2 
            jmp     PollInt 