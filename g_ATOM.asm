;***
;   DEC 
;               C6: ZERO PAGE       5 cycles
;               D6: ZERO PAGE X     6 cycles
;               CE: ABS             6 cycles
;               DE: ABS X           7 cycles 
;           X   CA: REG             2 cycles
;           Y   88: REG             2 cycles
;   Algorithm:
;   
;               src = (src - 1) & 0xff;
;               SET_SIGN(src);
;               SET_ZERO(src);
;               STORE(address, (src));
;*************************************************  


        OPC6: ; DEC ZERO PAGE 5 Cycles 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Real 
            movzx   ecx,    byt[ram+eax]    ;N -  ecx <- MEM 
            dec     ecx                     ;U -  DEC   
            lea     esi,    [esi+1]         ;V -  ++ PC 
            and     ecx,    0FFh            ;U - 
            lea     ebp,    [ebp+5]         ;V -  5 Cycles  
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            and     bl,     07Dh            ;V -  clr Z-N   
            or      ebx,    dwot[zn_t+ecx*4]    ;U -  set Z-N
            jmp     PollInt                 ;N -  
            
        OPD6: ; DEC ZERO PAGE X 6 cycles 
            movzx   eax,    byt[edx]        ;N -  eax <- a8Temp 
            add     al,     byt[edi+4]      ;U -  eax <- a8Real 
            mov     dl,     dl              ;V - 
            movzx   ecx,    byt[ram+eax]    ;N -  ecx <- MEM 
            dec     ecx                     ;U -  DEC   
            lea     esi,    [esi+1]         ;V -  ++ PC 
            and     ecx,    0FFh            ;U - 
            lea     ebp,    [ebp+6]         ;V -  6 Cycles  
            mov     byt[ram+eax],   cl      ;U -  MEM <- ecx 
            and     bl,     07Dh            ;V -  clr Z-N   
            or      ebx,    dwot[zn_t+ecx*4]    ;U -  set Z-N
            jmp     PollInt                 ;N -  
            
        OPCE: ; DEC ABS 6 cycles
            movzx   ecx,    wot[edx]        ;N -  load addr16Real 
            push    ecx                     ;U -  ready addr16Real<-nes_Read's arg 
            mov     $t1,    ecx             ;V -  save old frame
            call    CpuAMread@4             ;N -  call CpuAMread@4
            dec     eax                     ;U -  DEC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            push    eax                     ;U -  arg2
            push    $t1                     ;V -  arg1 
            and     eax,    0FFh            ;U -  limit Bits 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            lea     ebp,    [ebp+6]         ;V -  6 Cycles      
            call    CpuAMwrite@8                ;N -  call CpuAMwrite@8
            jmp     PollInt                 ;N -  ...
            
        OPDE: ; DEC ABS X 7 cycles
            movzx   ecx,    wot[edx]        ;N -  load addr16Temp
            movzx   eax,    byt[edi+4]      ;N -  load REG X 
            mov     ebx,    ebx             ;U -   
            add     ecx,    eax             ;V -  ABS X get addr16Real
            push    ecx                     ;U -  ready addr16Real<-nes_Read's arg 
            mov     $t1,    ecx             ;V -  save old frame
            call    CpuAMread@4             ;N -  call CpuAMread@4
            dec     eax                     ;U -  DEC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            push    eax                     ;U -  arg2
            push    $t1                     ;V -  arg1 
            and     eax,    0FFh            ;U -  limit Bits 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            lea     ebp,    [ebp+7]         ;V -  7 Cycles      
            call    CpuAMwrite@8                ;N -  call CpuAMwrite@8
            jmp     PollInt                 ;N -  ...
            
        OPCA: ; DEX 2 cycles 
            mov     eax,    $x              ;U -  load REG X 
            lea     ebp,    [ebp+2]         ;V -  2 Cycles 
            dec     eax                     ;U -  DEC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            mov     $x,     eax             ;U -  write REG X 
            and     eax,    0FFh            ;V -  limit Bits 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            jmp     PollInt                 ;V - /N ...
                
        OP88: ; DEY 
            mov     eax,    $y              ;U -  load REG Y
            lea     ebp,    [ebp+2]         ;V -  2 Cycles 
            dec     eax                     ;U -  DEC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            mov     $y,     eax             ;U -  write REG Y
            and     eax,    0FFh            ;V -  limit Bits 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            jmp     PollInt                 ;V - /N ...

;***
;   INC 
;               E6: ZERO PAGE       5 cycles
;               F6: ZERO PAGE X     6 cycles
;               EE: ABS             6 cycles
;               FE: ABS X           7 cycles 
;           X   E8: REG             2 cycles
;           Y   C8: REG             2 cycles
;   Algorithm:
;   
;               src = (src + 1) & 0xff;
;               SET_SIGN(src);
;               SET_ZERO(src);
;               STORE(address, (src));
;*************************************************

            
        OPE6: ; INC ZERO PAGE 5 cycles
            movzx   eax,    byt[edx]        ;N -  load ZeroPage Index 
            movzx   ecx,    byt[ram+eax]    ;N -  load From MEM ->
            inc     cl                      ;U -  INC OPR   
            mov     ebx,    ebx             ;V -   
            mov     ecx,    ecx             ;U -   
            lea     esi,    [esi+1]         ;V -  ++ PC 
            mov     byt[ram+eax],   cl      ;U -  write Back MEM <-
            and     bl,     07Dh            ;V -  clr Z-N Flags 
            lea     ebp,    [ebp+5]         ;U -  5 Cycles 
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            jmp     PollInt                 ;N -  ... 
            
        OPF6: ; INC ZERO PAGE X 6 cycles
            movzx   eax,    byt[edx]        ;N -  load ZeroPage Index 
            add     al,     byt[edi+4]      ;U -  ZERO PAGE X 
            mov     bl,     bl              ;V -   
            movzx   ecx,    byt[ram+eax]    ;N -  load From MEM ->
            inc     cl                      ;U -  INC OPR   
            mov     ebx,    ebx             ;V -   
            mov     ecx,    ecx             ;U -   
            lea     esi,    [esi+1]         ;V -  ++ PC 
            mov     byt[ram+eax],   cl      ;U -  write Back MEM <-
            and     bl,     07Dh            ;V -  clr Z-N Flags 
            lea     ebp,    [ebp+6]         ;U -  6 Cycles 
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            jmp     PollInt                 ;N -  ... 
            
        OPEE: ; INC ABS 6 cycles
            movzx   ecx,    wot[edx]        ;N -  load addr16Real 
            push    ecx                     ;U -  ready addr16Real<-nes_Read's arg 
            mov     $t1,    ecx             ;V -  save old frame
            call    CpuAMread@4             ;N -  call CpuAMread@4
            inc     eax                     ;U -  INC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            push    eax                     ;U -  arg2
            push    $t1                     ;V -  arg1 
            and     eax,    0FFh            ;U -  limit Bits 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            lea     ebp,    [ebp+6]         ;V -  6 Cycles      
            call    CpuAMwrite@8                ;N -  call CpuAMwrite@8
            jmp     PollInt                 ;N -  ...
            
        OPFE: ; INC ABS X 7 cycles 
            movzx   ecx,    wot[edx]        ;N -  load addr16Temp
            movzx   eax,    byt[edi+4]      ;N -  load REG X 
            mov     ebx,    ebx             ;U -   
            add     ecx,    eax             ;V -  ABS X get addr16Real
            push    ecx                     ;U -  ready addr16Real<-nes_Read's arg 
            mov     $t1,    ecx             ;V -  save old frame
            call    CpuAMread@4             ;N -  call CpuAMread@4
            inc     eax                     ;U -  INC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            push    eax                     ;U -  arg2
            push    $t1                     ;V -  arg1 
            and     eax,    0FFh            ;U -  limit Bits 
            lea     esi,    [esi+2]         ;V -  ++ PC 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            lea     ebp,    [ebp+7]         ;V -  7 Cycles      
            call    CpuAMwrite@8                ;N -  call CpuAMwrite@8
            jmp     PollInt                 ;N -  ...
            
        OPE8: ; INX     
            mov     eax,    $x              ;U -  load REG X 
            lea     ebp,    [ebp+2]         ;V -  2 Cycles 
            inc     eax                     ;U -  INC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            mov     $x,     eax             ;U -  write REG X 
            and     eax,    0FFh            ;V -  limit Bits 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            jmp     PollInt                 ;V - /N ...
    
        OPC8: ; INY 
            mov     eax,    $y              ;U -  load REG Y
            lea     ebp,    [ebp+2]         ;V -  2 Cycles 
            inc     eax                     ;U -  INC OPR 
            and     ebx,    07Dh            ;V -  clr Z-N Flags 
            mov     $y,     eax             ;U -  write REG Y
            and     eax,    0FFh            ;V -  limit Bits 
            or      ebx,    dwot[zn_t+eax*4] ;U -  reset Z-N Flags 
            jmp     PollInt                 ;V - /N ...