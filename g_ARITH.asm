;***
;   ADC 
;               69: #$              2 cycles
;               65: ZERO PAGE       3 cycles
;               75: ZERO PAGE X     4 cycles
;               6D: ABS             4 cycles
;               7D: ABS X           4 cycles (crossing page ++ cycles)
;               79: ABS Y           4 cycles (crossing page ++ cycles)
;               61: X INDIRECT      6 cycles
;               71: INDIRECT Y      4 cycles (crossing page ++ cycles)
;   Algorithm: 
;   
;           unsigned int temp = src + AC + (IF_CARRY() ? 1 : 0);
;           SET_ZERO(temp & 0xff);  /* This is not valid in decimal mode */
;           if (IF_DECIMAL()) {
;                   if (((AC & 0xf) + (src & 0xf) + (IF_CARRY() ? 1 : 0)) > 9) {
;                       temp += 6;
;                   }
;                   SET_SIGN(temp);
;                   SET_OVERFLOW(!((AC ^ src) & 0x80) && ((AC ^ temp) & 0x80));
;                   if (temp > 0x99) {
;                       temp += 96;
;                   }
;                   SET_CARRY(temp > 0x99);
;           } else {
;                   SET_SIGN(temp);
;                   SET_OVERFLOW(!((AC ^ src) & 0x80) && ((AC ^ temp) & 0x80));
;                   SET_CARRY(temp > 0xff);
;           }
;           AC = ((BYTE) temp);
;*************************************************      
        
        OP69: ; ADC #$ 2 cycles 

            movzx   ecx,    byt[edx]    ;N -  load #$ 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+2]     ;V -  2 Cycles 
            adc     al,     cl          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    cl                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ... 
            
        OP65: ; ADC ZERO PAGE 3 cycles 
            movzx   eax,    byt[edx]    ;N -  load addr8Real 
            movzx   ecx,    byt[ram+eax];N -  load addr8Real's VAL 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+3]     ;V -  3 Cycles 
            adc     al,     cl          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    cl                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
        OP75: ; ADC ZERO PAGE X 4 cycles        
            movzx   eax,    byt[edx]    ;N -  load addr8Temp 
            add     al,     byt[edi+4]  ;U -  get addr8Real
            mov     bl,     bl          ;V -   
            movzx   ecx,    byt[ram+eax];N -  load addr8Real's VAL 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+4]     ;V -  4 Cycles 
            adc     al,     cl          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    cl                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  

        OP6D: ; ADC ABS 4 cycles 
            mov     ax,     wot[edx]    ;U -  load addr16Real 
            add     si,     2           ;V -  ++ PC                  
            push    eax                 ;U -  PUSH addr16Real
            lea     ebp,    [ebp+4]     ;V -  4 Cycles
            call    CpuAMread@4         ;N -  call PROC     
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            and     eax,    0FFh        ;V -  limit Bits 
            shr     ebx,    1           ;U -  with C 
            mov     ebp,    ebp         ;V -   
            adc     cl,     al          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    al                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  

        OP7D: ; ADC ABS X 4 cycles (corssing page)
            movzx   eax,    wot[edx]    ;N -  load addr16Temp
            movzx   ecx,    byt[edi+4]  ;N -  load REG X 
            add     ecx,    eax         ;U -  ABS X 
            lea     esi,    [esi+2]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            mov     edx,    edx         ;V -   
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            adc     cl,     al          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    al                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
        
        OP79: ; ADC ABS Y 4 cycles (corssing page)
            movzx   eax,    wot[edx]    ;N -  load addr16Temp
            movzx   ecx,    byt[edi+8]  ;N -  load REG Y
            add     ecx,    eax         ;U -  ABS Y
            lea     esi,    [esi+2]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            mov     edx,    edx         ;V -   
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            adc     cl,     al          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    al                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
        OP61: ; ADC X INDIRECT 6 cycles
            movzx   eax,    byt[edx]    ;N -  load addr8Temp
            add     al,     byt[edi+4]  ;U -  X INDIRECT 
            and     bl,     00111101b   ;V -  clr N-V-Z Flags
            mov     cx,     wot[eax+ram];U -  get addr16Real
            add     bp,     6           ;V -  6 Cycles 
            push    ecx                 ;U -  PUSH addr16Real
            lea     esi,    [esi+1]     ;V -  ++ PC 
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            mov     edx,    edx         ;V -   
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            adc     cl,     al          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    al                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
        
        OP71: ; ADC INDIRECT Y  
            movzx   edx,    byt[edx]    ;N -  load addr8Real
            movzx   eax,    wot[edx+ram];N -  load addr16Temp
            movzx   ecx,    byt[edi+8]  ;N -  load REG Y
            add     ecx,    eax         ;U -  ABS Y
            lea     esi,    [esi+1]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            mov     edx,    edx         ;V -   
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            adc     cl,     al          ;U -  ADC 
            mov     dl,     dl          ;V -   
            seto    al                  ;N -  SETcc set O flag 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ... 

;***
;   SBC 
;               EB: #$              2 cycles (unofficial)
;               E9: #$              2 cycles
;               E5: ZERO PAGE       3 cycles
;               F5: ZERO PAGE X     4 cycles
;               ED: ABS             4 cycles
;               FD: ABS X           4 cycles (crossing page ++ cycles)
;               F9: ABS Y           4 cycles (crossing page ++ cycles)
;               E1: X INDIRECT      6 cycles
;               F1: INDIRECT Y      4 cycles (crossing page ++ cycles)
;   Algorithm:
;   
;               unsigned int temp = AC - src - (IF_CARRY() ? 0 : 1);
;               SET_SIGN(temp);
;               SET_ZERO(temp & 0xff);  /* Sign and Zero are invalid in decimal mode */
;               SET_OVERFLOW(((AC ^ temp) & 0x80) && ((AC ^ src) & 0x80));
;               if (IF_DECIMAL()) {
;                   if ( ((AC & 0xf) - (IF_CARRY() ? 0 : 1)) < (src & 0xf)) /* EP */ {
;                       temp -= 6;
;                   }
;                   if (temp > 0x99) {
;                       temp -= 0x60;
;                   }
;               }
;               SET_CARRY(temp < 0x100);
;               AC = (temp & 0xff);
;*************************************************
                    
        OPE9: ; SBC #$ 2 cycles 
            movzx   ecx,    byt[edx]    ;N -  load #$ 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+2]     ;V -  2 Cycles 
            sbb     al,     cl          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    cl                  ;N -  SETcc set O flag 
ELSE    
            setno   cl                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
        OPE5: ; SBC ZERO PAGE 3 cycles  
            movzx   ecx,    byt[edx]    ;N -  load addr8Real 
            movzx   ecx,    byt[ram+ecx];N -  load VAL 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+3]     ;V -  3 Cycles 
            sbb     al,     cl          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    cl                  ;N -  SETcc set O flag 
ELSE    
            setno   cl                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
        OPF5: ; SBC ZERO PAGE X  4 cycles
            movzx   ecx,    byt[edx]    ;N -  load addr8Real 
            add     cl,     byt[edi+4]  ;U -  ZERO PAGE X 
            mov     dl,     dl          ;V -   
            movzx   ecx,    byt[ram+ecx];N -  load VAL 
            movzx   eax,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            lea     esi,    [esi+1]     ;V -  ++ PC 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shr     ebx,    1           ;U -  with C 
            lea     ebp,    [ebp+4]     ;V -  4 Cycles 
            sbb     al,     cl          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    cl                  ;N -  SETcc set O flag 
ELSE    
            setno   cl                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     ecx,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+eax*4]    ;V -  reset Z-N Flags 
            or      ebx,    ecx                     ;U -  reset V Flag 
            mov     $a,     eax                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
        OPED: ; SBC ABS 4 cycles 
            mov     ax,     wot[edx]    ;U -  load addr16Real 
            add     si,     2           ;V -  ++ PC                  
            push    eax                 ;U -  PUSH addr16Real
            lea     ebp,    [ebp+4]     ;V -  4 Cycles
            call    CpuAMread@4         ;N -  call PROC     
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     ebx,    00111101b   ;U -  clr N-V-Z Flags 
            and     eax,    0FFh        ;V -  limit Bits 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shr     ebx,    1           ;U -  with C 
            mov     ebp,    ebp         ;V -   
            sbb     cl,     al          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    al                  ;N -  SETcc set O flag 
ELSE    
            setno   al                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
            
            
        OPFD: ; SBC ABS X 4 cycles (corssing page)
            movzx   eax,    wot[edx]    ;N -  load addr16Temp
            movzx   ecx,    byt[edi+4]  ;N -  load REG X 
            add     ecx,    eax         ;U -  ABS X 
            lea     esi,    [esi+2]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            xor     ebx,    1           ;V -  NEG C 
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            sbb     cl,     al          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    al                  ;N -  SETcc set O flag 
ELSE    
            setno   al                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
        
        OPF9: ; SBC ABS Y 4 cycles (corssing page)
            movzx   eax,    wot[edx]    ;N -  load addr16Temp
            movzx   ecx,    byt[edi+8]  ;N -  load REG Y
            add     ecx,    eax         ;U -  ABS Y
            lea     esi,    [esi+2]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            xor     ebx,    1           ;V -  NEG C 
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            sbb     cl,     al          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    al                  ;N -  SETcc set O flag 
ELSE    
            setno   al                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ... 
            
        OPE1: ; SBC X INDIRECT 
            movzx   eax,    byt[edx]    ;N -  load addr8Temp
            add     al,     byt[edi+4]  ;U -  X INDIRECT 
            and     bl,     00111101b   ;V -  clr N-V-Z Flags
            mov     cx,     wot[eax+ram];U -  get addr16Real
            add     bp,     6           ;V -  6 Cycles 
            push    ecx                 ;U -  PUSH addr16Real
            lea     esi,    [esi+1]     ;V -  ++ PC 
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            xor     ebx,    1           ;V -  NEG C  
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            sbb     cl,     al          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    al                  ;N -  SETcc set O flag 
ELSE    
            setno   al                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...  
        
        OPF1: ; SBC INDIRECT Y 
            movzx   edx,    byt[edx]    ;N -  load addr8Real
            movzx   eax,    wot[edx+ram];N -  load addr16Temp
            movzx   ecx,    byt[edi+8]  ;N -  load REG Y
            add     ecx,    eax         ;U -  ABS Y
            lea     esi,    [esi+1]     ;V -  ++ PC 
            and     bl,     00111101b   ;U -  clr N-V-Z Flags
            sub     ah,     ch          ;V -  test CrossPage 
            adc     ebp,    4           ;U -  4/5 Cycles 
            push    ecx                 ;V -  PUSH addr16Real
            call    CpuAMread@4         ;N -  call PROC 
            movzx   ecx,    byt[edi]    ;N -  load REG A 
            and     eax,    0FFh        ;U -  limit Bits 
            xor     ebx,    1           ;V -  NEG C 
            shr     ebx,    1           ;U -  with C 
            mov     ebx,    ebx         ;V -   
            sbb     cl,     al          ;U -  SBC 
            mov     dl,     dl          ;V -   
IFDEF DUMMY_SBC_V_TEST
            seto    al                  ;N -  SETcc set O flag 
ELSE    
            setno   al                  ;N -  SETcc set O flag 
ENDIF 
            rcl     ebx,    1           ;N -  C Flag into NES's Flag REG 
            xor     ebx,    1           ;U -  NEG C 
            mov     eax,    eax         ;V -   
            shl     eax,    6                       ;U -  reset pos (ready to NES's V Flag)
            or      ebx,    dwot[zn_t+ecx*4]    ;V -  reset Z-N Flags 
            or      ebx,    eax                     ;U -  reset V Flag 
            mov     $a,     ecx                     ;V -  write Back REG A 
            jmp     PollInt                         ;N -  ...