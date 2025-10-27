[bits 64]
global main

section .data
    var db 'Hello', 0

section .text
    main:
        lea rax, [rel var]
        mov bl, [rax]
        mov rcx, 0 ; Initialize `rcx` to 0
        loop_start:
            mov bl, [rax] ; Load the character
            cmp bl, 0 ; Compare the character with 0
            je loop_end ; `je` -> "jump if equal". If the first comparison succeeds, the control is given to `loop_end`
            add rcx, 1 ; To keep count
            add rax, 1
            jne loop_start ; `jne` -> "jump if not equal". If the comparison fails, the control is given to `loop_start`, which essentially is a recurring call
        loop_end:
            mov rax, rcx
            ret