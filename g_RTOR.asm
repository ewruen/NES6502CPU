; trans REG to REG 
; tXN
;   X source REG
;   N target REG 
; TXS not set Z-N flag (only this.. other must set Z-N flag)... 
; cycles all 2 cycles ... 

        OPAA: ; TAX
            and     ebx,    07Dh                ;U - 
            mov     eax,    $a                  ;V -  eax <- A      
            mov     $x,     eax                 ;U -  X <- eax 
            and     eax,    0FFh                ;V -  
            add     ebp,    2                   ;U -  
            or      ebx,    dwot[zn_t+eax*4];V -  
            jmp     PollInt                     ;N -  
            
        OP8A: ; TXA
            and     ebx,    07Dh                ;U -  
            mov     eax,    $x                  ;V -  eax <- X  
            mov     $a,     eax                 ;U -  A <- eax 
            and     eax,    0FFh                ;V -  
            add     ebp,    2                   ;U -  
            or      ebx,    dwot[zn_t+eax*4];V -  
            jmp     PollInt                     ;N -  
            
        OPA8: ; TAY
            and     ebx,    07Dh                ;U -  
            mov     eax,    $a                  ;V -  eax <- A      
            mov     $y,     eax                 ;U -  Y <- eax 
            and     eax,    0FFh                ;V -  
            add     ebp,    2                   ;U -  
            or      ebx,    dwot[zn_t+eax*4];V -  
            jmp     PollInt                     ;N -  
        
        OP98: ; TYA
            and     ebx,    07Dh                ;U -  
            mov     eax,    $y                  ;V -  eax <- Y      
            mov     $a,     eax                 ;U -  A <- eax 
            and     eax,    0FFh                ;V -  
            add     ebp,    2                   ;U -  
            or      ebx,    dwot[zn_t+eax*4];V -  
            jmp     PollInt                     ;N -  
            
        OPBA: ; TSX     
            and     ebx,    07Dh                ;U -  
            mov     eax,    $s                  ;V -  eax <- S      
            mov     $x,     eax                 ;U -  X <- eax 
            and     eax,    0FFh                ;V -  
            add     ebp,    2                   ;U -  
            or      ebx,    dwot[zn_t+eax*4];V -  
            jmp     PollInt                     ;N -  
            
        OP9A: ; TXS (RTOR only this not set flag)
            mov     eax,    $x                  ;U -  eax <- X          
            add     ebp,    2                   ;V -  
            mov     $s,     eax                 ;U -  S <- eax 
            jmp     PollInt                     ;N -  