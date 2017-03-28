        .686                      ; create 32 bit code
        .mmx
        .xmm                     
        .model flat, stdcall      ; 32 bit memory model
        option casemap :none      ; case sensitive

        
        
        
        
        
        
;   ===========================================================================
;
;       
;       
;   this source is based on VirtuaNES && (\virtuanessrc097\NES\Cpu.cpp)
;                           nesterJ   && (nesterj_0_51_05_src\gui\SRC\NES\CPU\Nes6502.c)
;
;
;   2A03 Instruction comment from nesdev.com  (nesdev_weekly\www\6502.txt)
;
;
;
;   ===========================================================================





;=======================
;       Interrupt    
;=======================

        NMI_VECTOR  equ FFFAh       ; nmi    
        RES_VECTOR  equ FFFCh       ; reset
        IRQ_VECTOR  equ FFFEh       ; irq  

        NMI_FLAG    equ 2           ; nmi interrupt pending flag
        IRQ_FLAG    equ 1           ; irq interrupt pending flag 
        
        
        
;=======================
;      Pro Status    
;=======================


        C_FLAG      equ 01h             ; 1: carry
        Z_FLAG      equ 02h             ; 1: zero 
        I_FLAG      equ 04h             ; 1: intterrupt enable 
        D_FLAG      equ 08h             ; 1: dec mode nes did not use this mode
        B_FLAG      equ 10h             ; 1: software intterrupt flag 
        R_FLAG      equ 20h             ; 1: this flag is reserved
        V_FLAG      equ 40h             ; 1: overflow flag
        N_FLAG      equ 80h             ; 1: negative flag 
        
        INT_C       equ 7
        ; USEASM2A03    equ 0
        DUMMY_SBC_V_TEST equ 0
        byt         equ byte ptr
        wot         equ word ptr
        dwot        equ dword ptr 
        
        $a          equ dword ptr[edi] ; 0
        $x          equ dword ptr[edi+4] ; 1
        $y          equ dword ptr[edi+8] ; 2
        $s          equ dword ptr[edi+12] ; 3
        $p          equ dword ptr[edi+16] ; 4
        $pc         equ dword ptr[edi+20] ; 5
        $dma        equ dword ptr[edi+24] ; 6
        $dis        equ dword ptr[edi+28] ; 7
        $t1         equ dword ptr[edi+32] ; 8
        $t2         equ dword ptr[edi+36] ; 9
        $ct         equ dword ptr[edi+40] ; A 
        
        PC_1        equ inc esi
        PC_2        equ add esi, 2 
        DO_CYC      equ add ebp, 4 
        ALIGNXMM    equ align 16
        
        
;=======================
;    extern symbols    
;=======================        

    extrn CpuAMread@4:proc
    extrn CpuAMwrite@8:proc
    extrn CpuAMreadW@4:proc
    
    extrn ram:far
    extrn regs:far
    extrn zn_t:far
    extrn dma_c:far
    extrn cpuBanks:far
    extrn int_pending:far

    
    
;===================
;    Function    
;===================    

    .code

FastCall2A03 proc C 
             option prologue:none, epilogue:none
             
        push    ebx ;U -  save old frame
        push    esi ;V -  save old frame        
        push    edi ;U -  save old frame
        push    ebp ;V -  save old frame 
        
        ; esi edi ebx ebp unscratch regs we can use this to do useful things        
        ; eax ecx edx scratch regs to do logic opr use completion can be discarded
        
        ; ebx <- save now P (nes's PSW reg)
        ; ebp <- save exec Cycles counter 
        ; esi <- save now PC (nes's EIP reg)
        ; edi <- save regs root
        
        lea     edi,    regs        ;U -  ebx <- save regs root     
        mov     eax,    dwot[esp+20];V - /N load dispatch Cycles-> arg1 
        xor     ebp,    ebp         ;U -  reset Cycles counter 
        mov     $dis,   eax         ;V -  write back adjacent mem reduce cache pollute
        mov     esi,    $pc         ;U -  load PC 
        mov     ebx,    $p          ;V -  load P 
    ALIGNXMM ; align 
    main_Loop:
        mov     eax,    $dis        ;U -  load dispatch Cycles
        mov     edx,    ebp         ;V -  copy Now Cycles counter   
        mov     ecx,    $dma        ;U - /N load now DMA Cycles 
        mov     ebp,    edx         ;V -   
        
        cmp     eax,    edx         ;U -  dispatch Cycles > Cycles counter ?
        jg      do_DMA_test         ;V -  TRUE:remain Cycles alive do DMA test FALSE:remain burning out 
        
        mov     eax,    ebp         ;U -  return now Cycles counter     
        mov     ecx,    edx         ;V -   
        mov     $pc,    esi         ;U -  write back PC 
        mov     $p,     ebx         ;V -  write back P
        pop     ebp                 ;U -  thaw old frame
        pop     edi                 ;V -  thaw old frame
        pop     esi                 ;U -  thaw old frame
        pop     ebx                 ;V -  thaw old frame
        ret                         ;N -  proc ret ...
        
        ALIGNXMM        
        do_DMA_test:
            test    ecx,    ecx     ;U -  DMA Cycles active ?
            je      dec_Begin       ;V -  TRUE calc Cycles FALSE:immed decode 
            
            sub     eax,    edx     ;U -  remain Cycles
            lea     edi,    [edi]   ;V -        
            cmp     ecx,    eax     ;U -  cmp DMA Cycles/remain Cycles 
            jge     remain_Out      ;V -  TRUE:remain Cycles burning out FALSE: DMA Cycles burning out      
            
            add     ebp,    ecx     ;U -  dma buring out 
            mov     $dma,   0       ;V -  reset DMA Cycles
            lea     eax,    [eax]   ;U -  
            jmp     dec_Begin       ;V -  jmp decode ... short jmp 

            ALIGNXMM
            remain_Out:         
                sub     ecx,    eax ;U -  remain cycles buring out 
                mov     eax,    $dis;V -  Cycles just enough        
                mov     $dma,   ecx ;U -  write back DMA Cycles
                mov     $pc,    esi ;U -  write back PC 
                mov     $p,     ebx ;V -  write back P
                pop     ebp         ;U -  thaw old frame
                pop     edi         ;V -  thaw old frame
                pop     esi         ;U -  thaw old frame
                pop     ebx         ;V -  thaw old frame
                ret                 ;N -  proc ret ...

                ALIGNXMM
                dec_Begin:
                    mov     eax,    esi                     ;U -  load PC 
                    inc     esi                             ;V -  ++ PC 
                    mov     edx,    eax                     ;U -  copy PC 
                    and     eax,    0FFFFh                  ;V -  limit bits 
                    shr     eax,    13                      ;U -  get Bank ID 
                    and     edx,    01FFFh                  ;V -  Bank's interval 
                    mov     ecx,    dwot[cpuBanks+eax*4]    ;U -  get Bank ID
                    lea     edx,    [edx]                   ;V -            
                    movzx   eax,    byt[ecx+edx]            ;N -  get PC's val          
                    lea     edx,    [edx+ecx+1]             ;U -  next addr index 
                    jmp             [OPTAB+eax*4]           ;V - /N short/far jmp 

                    ; =======================   
                    ;   instr decode begin
                    ; =======================
                        include     g_ARITH.asm
                        include     g_ATOM.asm
                        include     g_CMP.asm
                        include     g_JCC.asm
                        include     g_LOGIC.asm
                        include     g_PROC.asm
                        include     g_PSW.asm
                        include     g_READ.asm
                        include     g_REMAIN.asm
                        include     g_RTOR.asm
                        include     g_SHIFT.asm
                        include     g_SOFT-INT.asm
                        include     g_STACK.asm 
                        include     g_TEST.asm
                        include     g_WRITE.asm 
                ALIGNXMM
                PollInt:
                        mov     eax,    dwot[int_pending]   ;U -  load Pending signal 
                        and     eax,    3                   ;V -  clr bits 
                        lea     ecx,    [ecx]               ;U -  
                        jmp     dwot[INT_TAB+eax*4]         ;V -  decode interrupt
                        ALIGNXMM
                        IRQ_:                   
                            and     eax,    1               ;U -  clr NMI flag ... 
                            mov     ecx,    $s              ;V -  load S stack 
                            and     ecx,    0FFh            ;U -  clr bits 
                            lea     edx,    [edx]           ;V -        
                            mov     dwot[int_pending],  eax ;U -  write back Pending_int            
                            mov     wot[ecx+ram+0100h-1], si;V -  push now PC 
                            and     ebx,    0EFh            ;U -  clr B flag ... 
                            add     ebp,    INT_C           ;V -  add INT Cycles 
                            mov     byt[ecx+ram+0100h-2], bl;U -  push Flags 
                            sub     cl,     3               ;V -  sub Stack 
                            or      ebx,    I_FLAG          ;U -  set Interrupt Disable Flags
                            mov     eax,    dwot[cpuBanks+28];V -  get last Bank
                            mov     $s,     ecx             ;U -  write back Stack          
                            mov     si,     wot[eax+01FFEh] ;V - /N set IRQ addr 
                            jmp     main_Loop               ;N -                            
                        ALIGNXMM
                        NMI_:
                            and     eax,    1               ;U -  clr NMI flag ... 
                            mov     ecx,    $s              ;V -  load S stack 
                            and     ecx,    0FFh            ;U -  clr bits 
                            lea     edx,    [edx]           ;V -        
                            mov     dwot[int_pending],  eax ;U -  write back Pending_int            
                            mov     wot[ecx+ram+0100h-1], si;V -  push now PC 
                            and     ebx,    0EFh            ;U -  clr B flag ... 
                            add     ebp,    INT_C           ;V -  add INT Cycles 
                            mov     byt[ecx+ram+0100h-2], bl;U -  push Flags 
                            sub     cl,     3               ;V -  sub Stack 
                            or      ebx,    I_FLAG          ;U -  set Interrupt Disable Flags
                            mov     eax,    dwot[cpuBanks+28];V -  get last Bank
                            mov     $s,     ecx             ;U -  write back Stack          
                            mov     si,     wot[eax+01FFAh] ;V - /N set NMI addr 
                            jmp     main_Loop               ;N -  
                            
                        ALIGNXMM
                        NO_DEAL:
                            jmp main_Loop
                            
                        INT_TAB dd NO_DEAL, IRQ_, NMI_, NMI_        
FastCall2A03 endp
        
setNMI proc C 
             option prologue:none, epilogue:none
             
       or dwot[int_pending], NMI_FLAG
       ret 
     
setNMI endp

setIRQ proc C 
             option prologue:none, epilogue:none
         
       or dwot[int_pending], IRQ_FLAG
       ret 
       
setIRQ endp

fastNMI proc C 
             option prologue:none, epilogue:none
         
fastNMI endp

fastIRQ proc C 
             option prologue:none, epilogue:none
         
fastIRQ endp

cpuReset proc C 
             option prologue:none, epilogue:none
         push ebx
         lea edi, regs
         
         xor ecx, ecx 
         or $p, 022h
         
         mov $a, ecx
         mov $x, ecx 
         
         mov $y, ecx
         mov $s, 0FFh 
         
         mov eax, dwot[cpuBanks+28]
         mov ecx, dwot[eax+01FFCh] ; set RESET addr 
         
         mov $pc, ecx
         pop ebx 
         
         ret
cpuReset endp

set_DMA_Cycles proc C 
             option prologue:none, epilogue:none
             
        test dword ptr[esp+4], -1 
        je __No_Force
        mov dwot[dma_c], 514
__No_Force:
        add dwot[dma_c], 514
        ret

set_DMA_Cycles endp

    end

