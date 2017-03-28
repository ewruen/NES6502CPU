;***
;   ASL 
;               0A: ACC             2 cycles
;               06: ZERO PAGE       5 cycles
;               16: ZERO PAGE X     6 cycles
;               0E: ABS             6 cycles
;               1E: ABS X           7 cycles 
;   Algorithm:
;   
;           SET_CARRY(src & 0x80);
;           src <<= 1;
;           src &= 0xff;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           STORE src in memory or accumulator depending on addressing mode.
;
;*************************************************      
 
            OP0A: ; ASL A - 2 cycles        
                movzx   eax,    byt[edi]    ;N -  eax <- A   
                and     ebx,    01111100b   ;U -  clr N-Z-C 
                lea     ebp,    [ebp+2]     ;V -  2 Cycles 
                shl     al,     1           ;U -  ASL A 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                mov     $a,     eax         ;V -  A <- eax  
                or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
                jmp     PollInt             ;V - /N 
                
            OP06: ; ASL ZERO PAGE 5 cycles 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Real
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111100b   ;U -  clr N-Z-C
                lea     ebp,    [ebp+5]     ;V -  5 Cycles 
                shl     al,     1           ;U -  ASL 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N -  
                
            OP16: ; ASL ZERO PAGE X 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Temp
                add     dl,     byt[edi+4]  ;U -  edx <- a8Real 
                mov     al,     al          ;V -  
                movzx   eax,    byt[ram+edx];N -  eax <- MEM   
                and     ebx,    01111100b   ;U -  clr N-Z-C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                shl     al,     1           ;U -  ASL 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
                
            OP0E: ; ASL ABS     
                mov     ax,     wot[edx]    ;U -  eax <- a16Real
                add     si,     2           ;V -  ++ PC                 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify
                and     ebx,    01111100b   ;V -  clr Z-N-C 
                shl     al,     1           ;U -  ASL 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N  
                push    eax                 ;V -  push MEM 
                push    $t1                 ;U -  push a16Real
                mov     eax,    eax         ;V -  
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  

            OP1E: ; ASL ABS X 
                movzx   ecx,    byt[edi+4]  ;N -  ecx <- X 
                mov     ax,     wot[edx]    ;U -  eax <- a16Temp 
                mov     bx,     bx          ;V -  
                add     ax,     cx          ;U -  eax <- a16Real
                add     si,     2           ;V -  ++ PC                 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111100b   ;V -  clr Z-N-C 
                shl     al,     1           ;U -  ASL 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     ebp,    [ebp+7]     ;V -  7 Cycles 
                or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N 
                push    eax                 ;V -  push MEM 
                push    $t1                 ;U -  push a16Real
                mov     eax,    eax         ;V -  
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  

;***
;   LSR 
;               4A: ACC             2 cycles
;               46: ZERO PAGE       5 cycles
;               56: ZERO PAGE X     6 cycles
;               4E: ABS             6 cycles
;               5E: ABS X           7 cycles 
;   Algorithm:
;   
;           SET_CARRY(src & 0x01);
;           src >>= 1;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           STORE src in memory or accumulator depending on addressing mode.
;
;*************************************************
    
            OP4A: ; LSR A 
                movzx   eax,    byt[edi]    ;N -  eax <- A   
                and     ebx,    01111100b   ;U -  clr N-Z-C 
                lea     ebp,    [ebp+2]     ;V -  2 Cycles 
                shr     al,     1           ;U -  LSR A 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                mov     $a,     eax         ;V -  A <- eax  
                or      ebx,    dwot[zn_t+eax*4] ;U -  set Z-N 
                jmp     PollInt             ;V - /N 
                
            OP46: ; LSR ZERO PAGE 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Real
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111100b   ;U -  clr N-Z-C
                lea     ebp,    [ebp+5]     ;V -  5 Cycles 
                shr     al,     1           ;U -  LSR 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N -  
                
            OP56: ; LSR ZERO PAGE X 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Temp
                add     dl,     byt[edi+4]  ;U -  edx <- a8Real 
                mov     al,     al          ;V -  
                movzx   eax,    byt[ram+edx];N -  eax <- MEM   
                and     ebx,    01111100b   ;U -  clr N-Z-C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                shr     al,     1           ;U -  LSR 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
                
            OP4E: ; LSR ABS 
                mov     ax,     wot[edx]    ;U -  eax <- a16Real
                add     si,     2           ;V -  ++ PC                 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify
                and     ebx,    01111100b   ;V -  clr Z-N-C 
                shr     al,     1           ;U -  LSR 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N  
                push    eax                 ;V -  push MEM 
                push    $t1                 ;U -  push a16Real
                mov     eax,    eax         ;V -  
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  
                
            OP5E: ; LSR ABS X 
                movzx   ecx,    byt[edi+4]  ;N -  ecx <- X 
                mov     ax,     wot[edx]    ;U -  eax <- a16Temp 
                mov     bx,     bx          ;V -  
                add     ax,     cx          ;U -  eax <- a16Real
                add     si,     2           ;V -  ++ PC                 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111100b   ;V -  clr Z-N-C 
                shr     al,     1           ;U -  LSR 
                mov     dl,     dl          ;V -  
                adc     ebx,    0           ;U -  set C 
                lea     ebp,    [ebp+7]     ;V -  7 Cycles 
                or      ebx,    dwot[zn_t+eax*4]    ;U -  set Z-N 
                push    eax                 ;V -  push MEM 
                push    $t1                 ;U -  push a16Real
                mov     eax,    eax         ;V -  
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  

;***
;   ROL 
;               2A: ACC             2 cycles
;               26: ZERO PAGE       5 cycles
;               36: ZERO PAGE X     6 cycles
;               2E: ABS             6 cycles
;               3E: ABS X           7 cycles 
;   Algorithm:
;   
;           src <<= 1;
;           if (IF_CARRY()) {
;               src |= 0x1;
;           }
;           SET_CARRY(src > 0xff);
;           src &= 0xff;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           STORE src in memory or accumulator depending on addressing mode.
;
;*************************************************      

                
            OP2A: ; ROL A       
                movzx   eax,    byt[edi]    ;N -  eax <- A 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+2]     ;V -  2 Cycles 
                shr     ebx,    1           ;U -  throw C 
                mov     eax,    eax         ;V -  
                rcl     al,     1           ;N -  ROL A 
                rcl     bl,     1           ;N -  receive C 
                mov     $a,     eax         ;U -  A <- eax 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
                jmp     PollInt             ;N - 
                
            OP26: ; ROL ZERO PAGE 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Real
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+5]     ;V -  5 Cycles 
                shr     ebx,    1           ;U -  throw C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                rcl     al,     1           ;N -  ROL 
                rcl     bl,     1           ;N -  receive C 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
                
                
            OP36: ; ROL ZERO PAGE X 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Temp 
                add     dl,     byt[edi+4]  ;U -  edx <- a8Real 
                mov     bl,     bl          ;V - 
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                shr     ebx,    1           ;U -  throw C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                rcl     al,     1           ;N -  ROL 
                rcl     bl,     1           ;N -  receive C 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
            
            OP2E: ; ROL ABS 
                mov     ax,     wot[edx]    ;U -  eax <- a16Real 
                add     si,     2           ;V -  ++ PC 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111101b   ;V -  clr Z-N-C
                shr     ebx,    1           ;U -  throw C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                rcl     al,     1           ;N -  ROL 
                rcl     bl,     1           ;N -  receive C 
                push    eax                 ;U -  
                push    $t1                 ;V -  
                mov     edx,    edx         ;U - 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  


            OP3E: ; ROL ABS X   
                movzx   ecx,    byt[edi+4]  ;N -  ecx <- X 
                mov     ax,     wot[edx]    ;U -  eax <- a16Temp 
                add     si,     2           ;V -  ++ PC 
                add     ax,     cx          ;U -  eax <- a16Real
                mov     dx,     dx          ;V - 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111101b   ;V -  clr Z-N-C
                shr     ebx,    1           ;U -  throw C 
                lea     ebp,    [ebp+7]     ;V -  7 Cycles 
                rcl     al,     1           ;N -  ROL 
                rcl     bl,     1           ;N -  receive C 
                push    eax                 ;U -  
                push    $t1                 ;V -  
                mov     edx,    edx         ;U - 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  
                
;***
;   ROR 
;               6A: ACC             2 cycles
;               66: ZERO PAGE       5 cycles
;               76: ZERO PAGE X     6 cycles
;               6E: ABS             6 cycles
;               7E: ABS X           7 cycles 
;   Algorithm:
;   
;           if (IF_CARRY()) {
;               src |= 0x100;
;           }
;           SET_CARRY(src & 0x01);
;           src >>= 1;
;           SET_SIGN(src);
;           SET_ZERO(src);
;           STORE src in memory or accumulator depending on addressing mode.
;
;*************************************************  

            OP6A: ; ROR A 
                movzx   eax,    byt[edi]    ;N -  eax <- A 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+2]     ;V -  2 Cycles 
                shr     ebx,    1           ;U -  throw C 
                mov     eax,    eax         ;V -  
                rcr     al,     1           ;N -  ROR A 
                rcl     bl,     1           ;N -  receive C 
                mov     $a,     eax         ;U -  A <- eax 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
                jmp     PollInt             ;N -    
                
            OP66: ; ROR ZERO PAGE 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Real
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+5]     ;V -  5 Cycles 
                shr     ebx,    1           ;U -  throw C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                rcr     al,     1           ;N -  ROR 
                rcl     bl,     1           ;N -  receive C 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
                
                
            OP76: ; ROR ZERO PAGE X 
                movzx   edx,    byt[edx]    ;N -  edx <- a8Temp 
                add     dl,     byt[edi+4]  ;U -  edx <- a8Real 
                mov     bl,     bl          ;V - 
                movzx   eax,    byt[ram+edx];N -  eax <- MEM 
                and     ebx,    01111101b   ;U -  set C     
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                shr     ebx,    1           ;U -  throw C 
                lea     esi,    [esi+1]     ;V -  ++ PC 
                rcr     al,     1           ;N -  ROR
                rcl     bl,     1           ;N -  receive C 
                mov     byt[ram+edx], al    ;U -  MEM <- eax 
                or      bl,     byt[zn_t+eax*4] ;V -  set Z-N 
                jmp     PollInt             ;N - 
            
            OP6E: ; ROR ABS 
                mov     ax,     wot[edx]    ;U -  eax <- a16Real 
                add     si,     2           ;V -  ++ PC 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111101b   ;V -  clr Z-N-C
                shr     ebx,    1           ;U -  throw C 
                lea     ebp,    [ebp+6]     ;V -  6 Cycles 
                rcr     al,     1           ;N -  ROR
                rcl     bl,     1           ;N -  receive C 
                push    eax                 ;U -  
                push    $t1                 ;V -  
                mov     edx,    edx         ;U - 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  
                        
            OP7E: ; ROR ABS X   
                movzx   ecx,    byt[edi+4]  ;N -  ecx <- X 
                mov     ax,     wot[edx]    ;U -  eax <- a16Temp 
                add     si,     2           ;V -  ++ PC 
                add     ax,     cx          ;U -  eax <- a16Real
                mov     dx,     dx          ;V - 
                mov     $t1,    eax         ;U -  t1 <- a16Real
                push    eax                 ;V -  
                call    CpuAMread@4         ;N -  
                and     eax,    0FFh        ;U -  purify 
                and     ebx,    01111101b   ;V -  clr Z-N-C
                shr     ebx,    1           ;U -  throw C 
                lea     ebp,    [ebp+7]     ;V -  7 Cycles 
                rcr     al,     1           ;N -  ROR
                rcl     bl,     1           ;N -  receive C 
                push    eax                 ;U -  
                push    $t1                 ;V -  
                mov     edx,    edx         ;U - 
                or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
                call    CpuAMwrite@8            ;N -  
                jmp     PollInt             ;N -  