;***
;   JMP 
;               4C: ABS             3 cycles 
;               6C: inDirect        5 cycles
;   Algorithm:
;   
;               PC = (src);
;
;*************************************************  
    
            OP4C: ; JMP ABS 
                mov     si,     wot[edx]    ;U -  get PC  
                add     bp,     3           ;V -  3 Cycles 
                jmp     PollInt             ;N -  
                
            OP6C:   
                ; in-direct JMP expection crossing page boundaries in 6C 
                ; NES JMP(only 6C)'s BUG: if addr is 0x--FF(Crossing Page) IP's High Bit Will Not Add 
                ; 
                ; $2500: 33
                ; $25FF: 76
                ; $2600: 89
                ; $7574: 6C FF 25
                ; PC <- $7574 
                ;
                ; Step1-> Get PC's Low  Bit FF 
                ; Step2-> Get PC's High Bit 25 
                ; $(25FF-2600) will crossing page so low bit is $25FF high Bit is $2500
                ; jmp to $3376 ...  
                
                movzx   eax,    wot[edx]    ;N -  load indirect addr ...        
                push    eax                 ;U -  push arg wait call CpuAMread@4/CpuAMreadW@4
                add     ebp,    5           ;V -  5 Cycles
                cmp     al,     0FFh        ;U -  low addr is FF ? 
                jne     noCrossPageBUG      ;V -  FF:no jmp else immed read word no CrossPage 
                mov     $t1,    eax         ;U -  save addr 
                mov     ebp,    ebp         ;V -   
                call    CpuAMread@4             ;N -  call read PROC - BYTE
                mov     esi,    eax         ;U -  addr - low bit        
                mov     eax,    $t1         ;V -  load org addr  
                sub     eax,    0FFh        ;U -  crossPage BUG deal 
                and     esi,    0FFh        ;V -  limit byte 
                push    eax                 ;U -  push arg wait call CpuAMread@4
                mov     eax,    eax         ;V -   
                call    CpuAMread@4         ;N -  call read PROC - BYTE
                shl     eax,    8           ;U -  shift to high 8 bits 
                mov     ecx,    ecx         ;V -   
                or      esi,    eax         ;U -  get PC over 
                jmp     PollInt             ;V - /N 
                ALIGNXMM 
                noCrossPageBUG:
                    call    CpuAMreadW@4    ;   - N call read PROC - WORD
                    mov     esi,    eax ;   - U PC <- EAX 
                    jmp     PollInt     ;   - V/N 

;***
;   JSR         20: ABS             6 cycles 
;
;
;   Algorithm:
;   
;               PC--;
;               PUSH((PC >> 8) & 0xff); /* Push return address onto the stack. */
;               PUSH(PC & 0xff);
;               PC = (src);
;
;*************************************************  
                    
            OP20: ; JSR             
                movzx   eax,    wot[edx]    ;N -  load future PC 
                mov     ecx,    $s          ;U -  load REG S 
                add     ebp,    6           ;V -  6 Cycles 
                and     ecx,    0FFh        ;U -  limits bits 
                lea     edx,    [esi+1]     ;V -  ++ PC 
                mov     esi,    eax         ;U -  write back PC     
                mov     eax,    eax         ;V -   
                mov     wot[ram+0100h+ecx-1],   dx  ;U -  wrte back STACK PC 
                sub     cx,     2                   ;V - /N STACK --
                mov     $s,     ecx                 ;U -  write back STACK
                jmp     PollInt                     ;V - /N continue deal interrupt 

;***
;   RTI         40          
;
;
;   Algorithm:
;   
;               src = PULL();
;               SET_SR(src);
;               src = PULL();
;               src |= (PULL() << 8);   /* Load return address from stack. */
;               PC = (src);
;
;*************************************************  
            
            OP40: ; RTI
                mov     ecx,    $s      ;U -  load REG S 
                add     ebp,    6       ;V -  6 Cycles 
                and     ecx,    0FFh    ;U -   
                mov     eax,    eax     ;V -   
                lea     ecx,    [ecx+3] ;U -  ++ STACK 
                mov     ebx,    ebx     ;V -  
                mov     bl,     byt[ram+0100h+ecx-2]    ;U -  write back REG P 
                mov     al,     al                      ;V -    
                mov     si,     wot[ram+0100h+ecx-1]    ;U -  write back REG PC 
                mov     bx,     bx                      ;V -            
                mov     $s,     ecx                     ;U -  write back REG S
                jmp     PollInt                         ;V - /N continue deal interrupt 

;***
;   RTS         60          
;
;
;   Algorithm:
;   
;               src = PULL();
;               src += ((PULL()) << 8) + 1; /* Load return address from stack and add 1. */
;               PC = (src);
;
;*************************************************  

            OP60: ; RTS         
                mov     ecx,    $s      ;U -  load REG S 
                add     ebp,    6       ;V -  6 Cycles              
                and     ecx,    255     ;U -  limit Bits
                mov     eax,    eax     ;V -  
                add     ecx,    2       ;U -  ++STACK 
                mov     eax,    eax     ;V -  
                mov     si,     wot[ram+0100h+ecx-1]    ;U -  load PC 
                mov     ax,     ax                      ;V -   
                mov     $s,     ecx                     ;U -  write back S 
                lea     esi,    [esi+1]                 ;V -  ++ PC 
                jmp     PollInt                         ;V - /N continue deal interrupt 