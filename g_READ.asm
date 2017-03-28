;***
;   LDA  
;               A9: ACC             2 cycles 
;               A5: ZERO PAGE       3 cycles
;               B5: ZERO PAGE X     4 cycles
;               AD: ABS             4 cycles
;               BD: ABS X           4 cycles (test cross page)
;               B9: ABS Y           4 cycles (test cross page)
;               A1: X INDIRECT      6 cycles
;               B1: INDIRECT Y      5 cycles (test cross page)  
;           X   A5: X REG           2 cycles 
;           X   A6: ZERO PAGE       3 cycles
;           X   B6: ZERO PAGE Y     4 cycles 
;           X   AE: ABS             4 cycles 
;           X   BE: ABS Y           4 cycles (test cross page)
;           Y   A0: Y REG           2 cycles 
;           Y   A4: ZERO PAGE       3 cycles
;           Y   B4: ZERO PAGE X     4 cycles 
;           Y   AC: ABS             4 cycles 
;           Y   BC: ABS X           4 cycles (test cross page)
;
;   Algorithm:
;   
;           SET_SIGN(src);
;           SET_ZERO(src);
;           AC = (src);
;
;*************************************************

; =====
    ;   A
        ; ===== 
        
        OPA9: ; LDA #$  
            movzx   eax,    byt[edx]    ;N -  eax <- #$ 
            mov     $a,     eax         ;U -  A <- eax 
            and     ebx,    07Dh        ;V -  clr Z-N 
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N 
            jmp     PollInt                         ;V - 
                        
        OPA5: ; LDA ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real  
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $a,     eax             ;U -  A <- MEM 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  

        OPB5: ; LDA ZERO PAGE X
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]      ;U -  eax <- a8Real 
            mov     dl,     dl              ;V - 
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $a,     eax             ;U -  A <- MEM 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  
                        
        OPAD: ; LDA ABS --
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    eax                     ;U -  
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            call    CpuAMread@4             ;N -  
            and     eax,    0FFh            ;U -   
            mov     edx,    edx             ;V -  
            and     ebx,    07Dh            ;U -  clr Z-N 
            mov     $a,     eax             ;V -  A <- MEM 
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            jmp     PollInt                 ;N - 
                            
        OPBD: ; LDA ABS X 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+4]      ;N -  ecx <- X 
            add     ecx,    eax             ;U - 
            lea     esi,    [esi+2]         ;V -  ++ PC   
            push    ecx                     ;U - 
            mov     eax,    eax             ;V -            
            and     bl,     07Dh            ;U -  clr Z-N 
            sub     ah,     ch              ;V -  test CrossPage 
            adc     ebp,    4               ;U - 
            mov     ebx,    ebx             ;V - 
            call    CpuAMread@4             ;N -  
            mov     $a,     eax             ;U -  A <- MEM 
            and     eax,    0FFh            ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V/N - 
            

        OPB9: ; LDA ABS Y 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+8]      ;N -  ecx <- Y 
            add     ecx,    eax             ;U - 
            lea     esi,    [esi+2]         ;V -  ++ PC   
            push    ecx                     ;U - 
            mov     eax,    eax             ;V -            
            and     bl,     07Dh            ;U -  clr Z-N 
            sub     ah,     ch              ;V -  test CrossPage 
            adc     ebp,    4               ;U - 
            mov     ebx,    ebx             ;V - 
            call    CpuAMread@4             ;N -  
            mov     $a,     eax             ;U -  A <- MEM 
            and     eax,    0FFh            ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V/N - 
        
        OPA1: ; LDA X INDIRECT 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp  
            add     al,     byt[edi+4]      ;U -  eax <- a8Real 
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     cx,     wot[ram+eax]    ;U -  ecx <- a16Real 
            add     bp,     6               ;V -  6 Cycles 
            push    ecx                     ;U -  
            lea     esi,    [esi+1]         ;V -  ++ PC 
            call    CpuAMread@4             ;N - 
            mov     $a,     eax             ;U -  A <- MEM 
            and     eax,    0FFh            ;V -  
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V - /N ... 

        OPB1: ; LDA INDIRECT Y
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real 
            movzx   eax,    wot[ram+eax]    ;N -  eax <- a16Temp
            movzx   ecx,    byt[edi+8]      ;N -  ecx <- Y 
            add     ecx,    eax             ;U - 
            lea     esi,    [esi+1]         ;V -  ++ PC   
            push    ecx                     ;U - 
            mov     eax,    eax             ;V -            
            and     bl,     07Dh            ;U -  clr Z-N 
            sub     ah,     ch              ;V -  test CrossPage 
            adc     ebp,    5               ;U -  
            mov     ebx,    ebx             ;V - 
            call    CpuAMread@4             ;N -  
            mov     $a,     eax             ;U -  A <- MEM 
            and     eax,    0FFh            ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V/N - 
            
; =====
    ;   X
        ; ===== 
        
        OPA2: ; LDX #$
            movzx   eax,    byt[edx]    ;N -  eax <- #$ 
            mov     $x,     eax         ;U -  X <- eax 
            and     ebx,    07Dh        ;V -  clr Z-N 
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N 
            jmp     PollInt                         ;V - 
            
        OPA6: ; LDX ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real  
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $x,     eax             ;U -  X <- MEM 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  
            
        OPB6: ; LDX ZERO PAGE Y 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+8]      ;U -  eax <- a8Real 
            mov     dl,     dl              ;V - 
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $x,     eax             ;U -  X <- MEM 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  
                
        OPAE: ; LDX ABS 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    eax                     ;U -  
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            call    CpuAMread@4             ;N -  
            and     eax,    0FFh            ;U -   
            mov     edx,    edx             ;V -  
            and     ebx,    07Dh            ;U -  clr Z-N 
            mov     $x,     eax             ;V -  X <- MEM 
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            jmp     PollInt                 ;N - 
                
        OPBE: ; LDX ABS Y 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+8]      ;N -  ecx <- Y 
            add     ecx,    eax             ;U - 
            lea     esi,    [esi+2]         ;V -  ++ PC   
            push    ecx                     ;U - 
            mov     eax,    eax             ;V -            
            and     bl,     07Dh            ;U -  clr Z-N 
            sub     ah,     ch              ;V -  test CrossPage 
            adc     ebp,    4               ;U - 
            mov     ebx,    ebx             ;V - 
            call    CpuAMread@4             ;N -  
            mov     $x,     eax             ;U -  X <- MEM 
            and     eax,    0FFh            ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V/N - 
            
; =====
    ;   y
        ; =====
        
        OPA0: ; LDY #$
            movzx   eax,    byt[edx]    ;N -  eax <- #$ 
            mov     $y,     eax         ;U -  Y <- eax 
            and     ebx,    07Dh        ;V -  clr Z-N 
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N 
            jmp     PollInt                         ;V - 

        OPA4: ; LDY ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real  
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $y,     eax             ;U -  Y <- MEM 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  
            
        OPB4: ; LDY ZERO PAGE X 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]      ;U -  eax <- a8Real 
            mov     dl,     dl              ;V - 
            mov     al,     byt[ram+eax]    ;U -  eax <- MEM  
            and     bl,     07Dh            ;V -  clr Z-N 
            mov     $y,     eax             ;U -  Y <- MEM 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
            jmp     PollInt                         ;N -  
                        
        OPAC: ; LDY ABS
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    eax                     ;U -  
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            call    CpuAMread@4             ;N -  
            and     eax,    0FFh            ;U -   
            mov     edx,    edx             ;V -  
            and     ebx,    07Dh            ;U -  clr Z-N 
            mov     $y,     eax             ;V -  Y <- MEM 
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            jmp     PollInt                 ;N - 
            
        OPBC: ; LDY ABS X 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+4]      ;N -  ecx <- X 
            add     ecx,    eax             ;U - 
            lea     esi,    [esi+2]         ;V -  ++ PC   
            push    ecx                     ;U - 
            mov     eax,    eax             ;V -            
            and     bl,     07Dh            ;U -  clr Z-N 
            sub     ah,     ch              ;V -  test CrossPage 
            adc     ebp,    4               ;U - 
            mov     ebx,    ebx             ;V - 
            call    CpuAMread@4             ;N -  
            mov     $y,     eax             ;U -  Y <- MEM 
            and     eax,    0FFh            ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            jmp     PollInt                 ;V/N - 
                
