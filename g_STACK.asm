            OP48: ; PHA             
                mov     eax,    $a                      ;U -  eax <- A 
                mov     edx,    $s                      ;V -  edx <- S 
                and     edx,    0FFh                    ;U -  purify 
                add     ebp,    3                       ;V -  3 Cycles          
                mov     byt[ram+0100h+edx], al          ;U -  STACK <- A 
                dec     dl                              ;V -  STACK --  
                mov     $s,     edx                     ;U -  
                jmp     PollInt                         ;V -
                
            OP08: ; PHP 
                mov     edx,    $s                      ;U -  edx <- S 
                add     ebp,    3                       ;V -  3 Cycles      
                and     edx,    0FFh                    ;U -  purify 
                or      ebx,    B_FLAG                  ;V -  set B Flag            
                mov     byt[ram+0100h+edx], bl          ;U -  STACK <- P
                dec     dl                              ;V -  STACK --          
                mov     $s,     edx                     ;U -  
                jmp     PollInt                         ;V - 
                
            OP68: ; PLA 
                mov     edx,    $s                      ;U -  edx <- S 
                and     ebx,    07Dh                    ;V -  clr Z-N 
                and     edx,    0FFh                    ;U -  purify 
                add     ebp,    4                       ;V -  4 Cycles          
                mov     al,     byt[ram+0101h+edx]      ;U -  A <- STACK  
                add     dl,     1                       ;V -  ++ STACK          
                and     eax,    0FFh                    ;U -  purify 
                mov     $s,     edx                     ;V -            
                mov     $a,     eax                     ;U -  
                or      ebx,    dwot[zn_t+eax*4]    ;V -  set Z-N 
                jmp     PollInt                         ;N -  
                
            OP28: ; PLP 
                mov     edx,    $s                      ;U -  edx <- S          
                add     ebp,    4                       ;V -  4 Cycles
                and     edx,    0FFh                    ;U -  purify 
                mov     ecx,    ecx                     ;V -            
                mov     bl,     byt[ram+0101h+edx]      ;U -  P <- STACK 
                add     dl,     1                       ;V -  ++ STACK           
                mov     $s,     edx                     ;U -  
                jmp     PollInt                         ;V - 
                
                
                
                
                
                
                