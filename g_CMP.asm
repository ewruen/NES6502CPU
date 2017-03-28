;***
;   CMP 
;               C9: #$              2 cycles
;               C5: ZERO PAGE       3 cycles
;               D5: ZERO PAGE X     4 cycles
;               CD: ABS             4 cycles
;               DD: ABS X           4 cycles (crossing page ++ cycles)
;               D9: ABS Y           4 cycles (crossing page ++ cycles)
;               C1: X INDIRECT      6 cycles
;               D1: INDIRECT Y      5 cycles (crossing page ++ cycles)
;           X   E0: #$              2 cycles
;           X   E4: ZERO PAGE       3 cycles 
;           X   EC: ABS             4 cycles 
;           Y   C0: #$              2 cycles
;           Y   C4: ZERO PAGE       3 cycles
;           Y   CC: ABS             4 cycles
;
;   Algorithm:
;   
;               src = AC - src;
;               SET_CARRY(src < 0x100);
;               SET_SIGN(src);
;               SET_ZERO(src &= 0xff);
;*************************************************  

; =====
    ;   A
        ; ===== 

        OPC9: ; CMP #$ 2 cycles 
            mov     cl,     byt[edx]    ;U -  ecx <- MEM 
            mov     al,     byt[edi]    ;V -  eax <- A 
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
            
        OPC5: ; CMP ZERO PAGE 3 cycles 
            movzx   ecx,    byt[edx]    ;N -  ecx <- a8Real 
            mov     cl,     byt[ram+ecx];U -  ecx <- MEM 
            mov     al,     byt[edi]    ;V -  eax <- A 
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+3]     ;U -  3 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
            
        OPD5: ; CMP ZERO PAGE X 4 cycles
            movzx   ecx,    byt[edx]    ;N -  ecx <- a8Temp 
            add     cl,     byt[edi+4]  ;U -  ecx <- a8Real 
            mov     al,     al          ;V -   
            mov     dl,     byt[ram+ecx];U -  edx <- MEM 
            mov     al,     byt[edi]    ;V -  eax <- A 
            and     bl,     01111100b   ;U -  clr Z-N-C 
            sub     al,     dl          ;V -  CMP 
            setnc   dl                  ;N -  
            lea     ebp,    [ebp+4]     ;U -  4 Cycles 
            and     eax,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    edx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
    
        OPCD: ; CMP ABS 4 cycles 
            mov     ax,     wot[edx]    ;U -  eax <- a16Real 
            add     si,     2           ;V -  ++ PC 
            push    eax                 ;U -  
            lea     ebp,    [ebp+4]     ;V -  4 Cycles
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi]    ;V -  ecx <- A 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
            
        
        OPDD: ; CMP ABS X (test cross page)
            movzx   ecx,    byt[edi+4]  ;N -  ecx <- X 
            movzx   eax,    wot[edx]    ;U -  eax <- a16Temp 
            add     ecx,    eax         ;U -
            lea     esi,    [esi+2]     ;V -  ++ PC  
            push    ecx                 ;U - 
            mov     esi,    esi         ;V -
            sub     ah,     ch          ;U - 
            mov     dh,     dh          ;V - 
            adc     ebp,    4           ;U -  4/5 Cycles
            mov     eax,    eax         ;V - 
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi]    ;V -  ecx <- A 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
        
        OPD9: ; CMP ABS Y (test cross page)
            movzx   ecx,    byt[edi+8]  ;N -  ecx <- Y 
            movzx   eax,    wot[edx]    ;U -  eax <- a16Temp 
            add     ecx,    eax         ;U -
            lea     esi,    [esi+2]     ;V -  ++ PC  
            push    ecx                 ;U - 
            mov     esi,    esi         ;V -
            sub     ah,     ch          ;U - 
            mov     dh,     dh          ;V - 
            adc     ebp,    4           ;U -  4/5 Cycles
            mov     eax,    eax         ;V - 
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi]    ;V -  ecx <- A 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
        
        OPC1: ; CMP X INDIRECT 6 cycles 
            movzx   eax,    byt[edx]    ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]  ;U -  eax <- a8Real
            mov     bl,     bl          ;V - 
            movzx   eax,    wot[ram+eax];N - 
            lea     esi,    [esi+1]     ;U - ++ PC 
            mov     ebx,    ebx         ;V - 
            push    eax                 ;U -  
            lea     ebp,    [ebp+6]     ;V -  6 Cycles
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi]    ;V -  ecx <- A 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
        
        OPD1: ; CMP INDIRECT Y (test cross page)
            movzx   ecx,    byt[edi+8]  ;N -  ecx <- Y 
            movzx   eax,    byt[edx]    ;N -  eax <- a8Real
            movzx   eax,    wot[ram+eax];N -  eax <- a16Real 
            add     ecx,    eax         ;U -
            lea     esi,    [esi+1]     ;V -  ++ PC  
            push    ecx                 ;U - 
            mov     esi,    esi         ;V -
            sub     ah,     ch          ;U - 
            mov     dh,     dh          ;V - 
            adc     ebp,    5           ;U -  5/6 Cycles
            mov     eax,    eax         ;V - 
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi]    ;V -  ecx <- A 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...

; =====
    ;   X
        ; ===== 
            
        OPE0: ; CPX #$ 
            mov     cl,     byt[edx]    ;U -  ecx <- MEM 
            mov     al,     byt[edi+4]  ;V -  eax <- X
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
        
        OPE4: ; CPX ZERO PAGE 
            movzx   ecx,    byt[edx]    ;N -  ecx <- a8Real 
            mov     cl,     byt[ram+ecx];U -  ecx <- MEM 
            mov     al,     byt[edi+4]  ;V -  eax <- X 
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+3]     ;U -  3 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
        
        OPEC: ; CPX ABS 
            mov     ax,     wot[edx]    ;U -  eax <- a16Real 
            add     si,     2           ;V -  ++ PC 
            push    eax                 ;U -  
            lea     ebp,    [ebp+4]     ;V -  4 Cycles
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi+4]  ;V -  ecx <- X 
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
; =====
    ;   y
        ; ===== 

            
        OPC0: ; CPY #$ 
            mov     cl,     byt[edx]    ;U -  ecx <- MEM 
            mov     al,     byt[edi+8]  ;V -  eax <- Y 
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+2]     ;U -  2 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
        
        OPC4: ; CPY ZERO PAGE 
            movzx   ecx,    byt[edx]    ;N -  ecx <- a8Real 
            mov     cl,     byt[ram+ecx];U -  ecx <- MEM 
            mov     al,     byt[edi+8]  ;V -  eax <- Y 
            and     bl,     01111100b   ;U -  clr Z-N-C
            sub     al,     cl          ;V -  CMP 
            setnc   cl                  ;N -  get C  
            lea     ebp,    [ebp+3]     ;U -  3 Cycles 
            and     eax,    0FFh        ;V -   
            or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            or      ebx,    ecx         ;U -  set C 
            jmp     PollInt             ;V - /N ...
            
        OPCC: ; CPY ABS     
            mov     ax,     wot[edx]    ;U -  eax <- a16Real 
            add     si,     2           ;V -  ++ PC 
            push    eax                 ;U -  
            lea     ebp,    [ebp+4]     ;V -  4 Cycles
            call    CpuAMread@4         ;N -  
            and     bl,     01111100b   ;U -  clr Z-N-C 
            mov     cl,     byt[edi+8]  ;V -  ecx <- Y
            sub     cl,     al          ;U -  CMP  
            mov     dl,     dl          ;V -   
            setnc   al                  ;N -  SETcc 
            or      ebx,    eax         ;U -  set C 
            and     ecx,    0FFh        ;V -  
            or      ebx,    dwot[zn_t+ecx*4] ;U -  set Z-N 
            jmp     PollInt             ;V - /N ...
        