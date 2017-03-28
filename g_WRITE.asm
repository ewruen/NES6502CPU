;***
;   STA  
;               85: ZERO PAGE       3 cycles
;               95: ZERO PAGE X     4 cycles
;               80: ABS             4 cycles
;               90: ABS X           5 cycles 
;               99: ABS Y           5 cycles
;               81: X INDIRECT      6 cycles
;               91: INDIRECT Y      6 cycles (no test cross page)   
;           X   86: ZERO PAGE       3 cycles
;           X   96: ZERO PAGE Y     4 cycles 
;           X   8E: ABS             4 cycles 
;           Y   84: ZERO PAGE       3 cycles
;           Y   94: ZERO PAGE X     4 cycles
;           Y   8C: ABS             4 cycles
;
;   Algorithm:
;   
;           STORE(address, A);
;
;*************************************************

; =====
    ;   A
        ; =====     

        OP85: ; STA ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real 
            mov     ecx,    $a              ;U -  ecx <- A 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
            
        OP95: ; STA ZERO PAGE X 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]      ;U - 
            mov     dl,     dl              ;V -
            mov     ecx,    $a              ;U -  ecx <- A
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
            
        OP8D: ; STA ABS 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    $a                      ;U -  
            push    eax                     ;V -  
            call    CpuAMwrite@8                ;N -  
            lea     esi,    [esi+2]         ;U -  ++ PC 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            jmp     PollInt                 ;V - 
            
        OP9D: ; STA ABS X 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+4]      ;N -  ecx <- X  
            push    $a                      ;U -  
            add     eax,    ecx             ;V -  eax <- a16Real
            push    eax                     ;U -  
            lea     ebp,    [ebp+5]         ;V -  5 Cycles 
            call    CpuAMwrite@8                ;N -  
            lea     esi,    [esi+2]         ;U -  ++ PC 
            jmp     PollInt                 ;V - /N ... 
            
        OP99: ; STA ABS Y 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Temp 
            movzx   ecx,    byt[edi+8]      ;N -  ecx <- Y
            push    $a                      ;U -  
            add     eax,    ecx             ;V -  eax <- a16Real
            push    eax                     ;U -  
            lea     ebp,    [ebp+5]         ;V -  5 Cycles 
            call    CpuAMwrite@8                ;N -  
            lea     esi,    [esi+2]         ;U -  ++ PC 
            jmp     PollInt                 ;V - /N ... 
            
        OP81: ; STA X INDIRECT 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp
            add     al,     byt[edi+4]      ;U -  eax <- a8Real
            mov     cl,     cl              ;V - 
            mov     dx,     wot[eax+ram]    ;U -  edx <- a16Real 
            add     bp,     6               ;V -  6 Cycles 
            push    $a                      ;U -  
            push    edx                     ;V -  
            call    CpuAMwrite@8                ;N -  call CpuAMwrite@8 
            add     esi,    1               ;U -  ++ PC 
            jmp     PollInt                 ;V - 
                
        OP91: ; STA INDIRECT Y
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real
            movzx   edx,    byt[edi+8]      ;N -  edx <- Y
            mov     cx,     wot[ram+eax]    ;U -  ecx <- a16Temp
            add     si,     1               ;V -  ++ PC 
            add     cx,     dx              ;U -  ecx <- a16Real
            add     bp,     6               ;V -  6 Cycles 
            push    $a                      ;U -  
            push    ecx                     ;V -  
            call    CpuAMwrite@8                ;N - 
            jmp     PollInt                 ;V - 


; =====
    ;   X
        ; =====     
        
        OP86: ; STX ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real 
            mov     ecx,    $x              ;U -  ecx <- X 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
                
        OP96: ; STX ZERO PAGE Y 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+8]      ;U - 
            mov     dl,     dl              ;V -
            mov     ecx,    $x              ;U -  ecx <- X 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
                    
        OP8E: ; STX ABS 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    $x                      ;U -  
            push    eax                     ;V -  
            call    CpuAMwrite@8                ;N -  
            lea     esi,    [esi+2]         ;U -  ++ PC 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            jmp     PollInt                 ;V - 


; =====
    ;   y
        ; =====     
        
        OP84: ; STY ZERO PAGE 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real 
            mov     ecx,    $y              ;U -  ecx <- Y 
            lea     ebp,    [ebp+3]         ;V -  3 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
            
        OP94: ; STY ZERO PAGE X
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]      ;U - 
            mov     dl,     dl              ;V -
            mov     ecx,    $y              ;U -  ecx <- Y 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            mov     bl,     bl              ;V - 
            lea     esi,    [esi+1]         ;U -  ++ PC 
            jmp     PollInt                 ;V - 
            
        OP8C: ; STY ABS 
            movzx   eax,    wot[edx]        ;N -  eax <- a16Real 
            push    $y                      ;U -  
            push    eax                     ;V -  
            call    CpuAMwrite@8                ;N -  
            lea     esi,    [esi+2]         ;U -  ++ PC 
            lea     ebp,    [ebp+4]         ;V -  4 Cycles 
            jmp     PollInt                 ;V - 
        