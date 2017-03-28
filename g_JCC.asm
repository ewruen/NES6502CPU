        OP90: ; BCC C clr JMP
            test    ebx,    00000001b
            je      Fhit
            jmp     Fnhit
            
        OPD0: ; BNE Z clr JMP 
            test    ebx,    00000010b
            je      Fhit
            jmp     Fnhit
            
        OP10: ; BPL N clr JMP
            test    ebx,    10000000b
            je      Fhit
            jmp     Fnhit
            
        OP50: ; BVC V clr JMP
            test    ebx,    01000000b
            je      Fhit
            jmp     Fnhit
            
        OPB0: ; BCS C set JMP
            test    ebx,    00000001b
            jne     Fhit
            jmp     Fnhit
            
        OPF0: ; BEQ Z set JMP
            test    ebx,    00000010b
            jne     Fhit
            jmp     Fnhit
            
        OP30: ; BMI N set JMP
            test    ebx,    10000000b
            jne     Fhit
            jmp     Fnhit   
            
        OP70: ; BVS V set JMP 
            test    ebx,    01000000b
            jne     Fhit
            jmp     Fnhit   
            
            ALIGNXMM
            Fhit:           
                add     ebp,    3 ; hit 3 Cycles            
                movsx   ecx,    byt[edx]
                lea     esi,    [ecx+esi+1]
                jmp     PollInt     
                
            ALIGNXMM
            Fnhit:              
                add     ebp,    2 ; miss 2 Cycles
                add     esi,    1           
                jmp     PollInt
