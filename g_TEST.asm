;***
;   BIT 
;               24: ZERO PAGE       3 cycles
;               2C: ABS             4 cycles
;   Algorithm:
;   
;               SET_SIGN(src);
;               SET_OVERFLOW(0x40 & src);   
;               SET_ZERO(src & AC);
;*************************************************  

        OP24: ; BIT ZERO PAGE 3 cycles
            movzx   eax,    byt[edx]    ;N -  eax <- a8Real     
            mov     al,     byt[ram+eax];U -  eax <- MEM    
            and     bl,     00111101b   ;V -  clr N-Z-V 
            mov     ecx,    $a          ;U -  ecx <- A 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            test    al,     cl          ;U -  
            mov     bl,     bl          ;V - 
            setz    cl                  ;N -  set Z  
            and     eax,    0C0h        ;U -  get N-V 
            and     ecx,    001h        ;V -  get Z 
            lea     edx,    [eax+ecx*2] ;U -  mix N-V-Z 
            lea     ebp,    [ebp+3]     ;V -  3 Cycles 
            or      ebx,    edx         ;U -  set N-V-Z 
            jmp     PollInt             ;V - 
            
        OP2C: ; BIT ABS 4 cycles 
            mov     ax,     wot[edx]    ;U -  eax <- a16Real
            and     bx,     00111101b   ;V -  clr N-Z-V
            push    eax                 ;U - 
            lea     esi,    [esi+2]     ;V -  ++ PC 
            call    CpuAMread@4             ;N - 
            mov     ecx,    $a          ;U -  ecx <- A 
            lea     ebx,    [ebx]       ;V - 
            test    al,     cl          ;U -  
            mov     bl,     bl          ;V - 
            setz    cl                  ;N -  set Z  
            and     eax,    0C0h        ;U -  get N-V 
            and     ecx,    001h        ;V -  get Z 
            lea     edx,    [eax+ecx*2] ;U -  mix N-V-Z 
            lea     ebp,    [ebp+4]     ;V -  4 Cycles 
            or      ebx,    edx         ;U -  set N-V-Z 
            jmp     PollInt             ;V - 