        OP18: ; CLC 
            add     ebp,    2 
            and     ebx,    11111110b
            jmp     PollInt 
            
        OPD8: ; CLD 
            add     ebp,    2 
            and     ebx,    11110111b
            jmp     PollInt 
            
        OP58: ; CLI 
            add     ebp,    2 
            and     ebx,    11111011b
            jmp     PollInt 
            
        OPB8: ; CLV 
            add     ebp,    2 
            and     ebx,    10111111b
            jmp     PollInt 
            
        OP38: ; SEC 
            add     ebp,    2 
            or      ebx,    00000001b
            jmp     PollInt 
            
        OPF8: ; SED 
            add     ebp,    2 
            or      ebx,    00001000b
            jmp     PollInt 
            
        OP78: ; SEI 
            add     ebp,    2 
            or      ebx,    00000100b
            jmp     PollInt 