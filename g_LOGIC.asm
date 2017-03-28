;***
;   ORA 
;               09: #$              2 cycles
;               05: ZERO PAGE       3 cycles
;               15: ZERO PAGE X     4 cycles
;               0D: ABS             4 cycles
;               1D: ABS X           4 cycles (crossing page ++ cycles)
;               19: ABS Y           4 cycles (crossing page ++ cycles)
;               01: X INDIRECT      6 cycles
;               11: INDIRECT Y      4 cycles (crossing page ++ cycles)
;   Algorithm:
;   
;           src |= AC;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           AC = src;
;*************************************************      

            OP09: ; ORA #$      
                movzx   eax,    byt[edx]    ;N -  load #$ 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      ecx,    eax         ;U -  ORA OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+2]     ;U -  2 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP05: ; ORA ZERO PAGE 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      ecx,    eax         ;U -  ORA OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+3]     ;U -  3 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP15: ; ORA ZERO PAGE X 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                add     cl,     byt[edi+4]  ;U -  ZERO PAGE X 
                mov     dl,     dl          ;V -   
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      ecx,    eax         ;U -  ORA OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+4]     ;U -  4 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP0D: ; ORA ABS 
                movzx   ecx,    wot[edx]    ;N -  load addr16Real
                push    ecx                 ;U -  
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                call    CpuAMread@4         ;N -  
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      cl,     al          ;U -  ORA OPR 
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     $a,     ecx         ;U -  write Back REG A 
                lea     esi,    [esi+2]     ;V -  ++ PC 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP1D: ; ORA ABS X 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+4]  ;N -  load REG X 
                add     dx,     ax          ;U -  ABS X 
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      cl,     al          ;U -  ORA OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ...         
                
            OP19: ; ORA ABS Y 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx,     ax          ;U -  ABS Y
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      cl,     al          ;U -  ORA OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP01: ; ORA X INDIRECT 
                movzx   eax,    byt[edx]    ;N -  load addr8Real 
                add     al,     byt[edi+4]  ;U -  X INDIRECT 
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     dx,     wot[ram+eax];U -  load addr16Real 
                add     si,     1           ;V -  ++ PC 
                push    edx                 ;U -  
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      cl,     al          ;U -  ORA OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 

            OP11: ; ORA INDIRECT Y 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real 
                movzx   eax,    wot[ram+ecx];N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx, ax              ;U -  ABS Y
                add     si, 1               ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                or      cl,     al          ;U -  ORA OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
            
;***
;   EOR 
;               49: #$              2 cycles
;               45: ZERO PAGE       3 cycles
;               55: ZERO PAGE X     4 cycles
;               4D: ABS             4 cycles
;               5D: ABS X           4 cycles (crossing page ++ cycles)
;               59: ABS Y           4 cycles (crossing page ++ cycles)
;               41: X INDIRECT      6 cycles
;               51: INDIRECT Y      4 cycles (crossing page ++ cycles)
;   Algorithm:
;   
;           src ^= AC;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           AC = src;
;*************************************************          
        
            OP49: ; EOR #$ 
                movzx   eax,    byt[edx]    ;N -  load #$ 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     ecx,    eax         ;U -  EOR OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+2]     ;U -  2 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP45: ; EOR ZERO PAGE 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     ecx,    eax         ;U -  EOR OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+3]     ;U -  3 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP55: ; EOR ZERO PAGE X 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                add     cl,     byt[edi+4]  ;U -  ZERO PAGE X 
                mov     dl,     dl          ;V -   
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     ecx,    eax         ;U -  EOR OPR
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+4]     ;U -  4 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP4D: ; EOR ABS 
                movzx   ecx,    wot[edx]    ;N -  load addr16Real
                push    ecx                 ;U -  
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                call    CpuAMread@4         ;N -  
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     cl,     al          ;U -  EOR OPR
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     $a,     ecx         ;U -  write Back REG A 
                lea     esi,    [esi+2]     ;V -  ++ PC 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP5D: ; EOR ABS X 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+4]  ;N -  load REG X 
                add     dx,     ax          ;U -  ABS X 
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     cl,     al          ;U -  EOR OPR
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP59: ; EOR ABS Y 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx,     ax          ;U -  ABS Y
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     cl,     al          ;U -  EOR OPR
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ...
                
            OP41: ; EOR X INDIRECT 
                movzx   eax,    byt[edx]    ;N -  load addr8Real 
                add     al,     byt[edi+4]  ;U -  X INDIRECT 
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     dx,     wot[ram+eax];U -  load addr16Real 
                add     si,     1           ;V -  ++ PC 
                push    edx                 ;U -  
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     cl,     al          ;U -  EOR OPR
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP51: ; EOR INDIRECT Y 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real 
                movzx   eax,    wot[ram+ecx];N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx, ax              ;U -  ABS Y
                add     si, 1               ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                xor     cl,     al          ;U -  EOR OPR
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
;***
;   AND 
;               29: #$              2 cycles
;               25: ZERO PAGE       3 cycles
;               35: ZERO PAGE X     4 cycles
;               2D: ABS             4 cycles
;               3D: ABS X           4 cycles (crossing page ++ cycles)
;               39: ABS Y           4 cycles (crossing page ++ cycles)
;               21: X INDIRECT      6 cycles
;               31: INDIRECT Y      4 cycles (crossing page ++ cycles)
;   Algorithm:
;   
;           src &= AC;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           AC = src;
;*************************************************  
                
            OP29: ; AND #$ 
                movzx   eax,    byt[edx]    ;N -  load #$ 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     ecx,    eax         ;U -  AND OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+2]     ;U -  2 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP25: ; AND ZERO PAGE 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     ecx,    eax         ;U -  AND OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+3]     ;U -  3 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ...
                
            OP35: ; AND ZERO PAGE X 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real
                add     cl,     byt[edi+4]  ;U -  ZERO PAGE X 
                mov     dl,     dl          ;V -   
                movzx   eax,    byt[ram+ecx];N -  load VAL 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     ecx,    eax         ;U -  AND OPR 
                and     ebx,    07Dh        ;V -  clr Z-N Flags 
                lea     ebp,    [ebp+4]     ;U -  4 Cycles 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
                lea     esi,    [esi+1]     ;U -  ++ PC 
                mov     $a,     ecx         ;V -  write Back REG A 
                jmp     PollInt             ;N -  ... 
                
            OP2D: ; AND ABS 
                movzx   ecx,    wot[edx]    ;N -  load addr16Real
                push    ecx                 ;U -  
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                call    CpuAMread@4         ;N -  
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     cl,     al          ;U -  AND OPR 
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     $a,     ecx         ;U -  write Back REG A 
                lea     esi,    [esi+2]     ;V -  ++ PC 
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP3D: ; AND ABS X 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+4]  ;N -  load REG X 
                add     dx,     ax          ;U -  ABS X 
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     cl,     al          ;U -  AND OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ...     
                
            OP39: ; AND ABS Y 
                movzx   eax,    wot[edx]    ;N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx,     ax          ;U -  ABS Y
                add     si,     2           ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     cl,     al          ;U -  AND OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP21: ; AND X INDIRECT 
                movzx   eax,    byt[edx]    ;N -  load addr8Real 
                add     al,     byt[edi+4]  ;U -  X INDIRECT 
                and     bl,     07Dh        ;V -  clr Z-N Flags 
                mov     dx,     wot[ram+eax];U -  load addr16Real 
                add     si,     1           ;V -  ++ PC 
                push    edx                 ;U -  
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     cl,     al          ;U -  AND OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 
                
            OP31: ; AND INDIRECT Y 
                movzx   ecx,    byt[edx]    ;N -  load addr8Real 
                movzx   eax,    wot[ram+ecx];N -  load addr16Temp 
                movzx   edx,    byt[edi+8]  ;N -  load REG Y
                add     dx, ax              ;U -  ABS Y
                add     si, 1               ;V -  ++ PC 
                push    edx                 ;U -  PUSH arg wait call PROC 
                lea     ebp,    [ebp+4]     ;V -  4 Cycles 
                and     bl,     07Dh            ;U -  clr Z-N Flags 
                sub     ah,     dh          ;V -  test CrossPage 
                adc     ebp,    0           ;U -  
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call PROC 
                movzx   ecx,    byt[edi]    ;N -  load REG A            
                and     cl,     al          ;U -  AND OPR 
                mov     dl,     dl          ;V -  
                mov     $a,     ecx         ;U -  write Back REG A 
                mov     eax,    eax         ;V -   
                or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags   
                jmp     PollInt             ;V - /N ... 