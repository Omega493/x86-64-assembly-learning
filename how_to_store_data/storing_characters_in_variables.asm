[bits 64]
global main

section .data
    ; `db` stands for "define byte" - it sets aside a byte of memory
    initial db 'J' ; Stores 'J' in `initial`
    initial2 db 67 ; Stores 67 in `initial2`

section .text
    main:
        ; Some information about registers:
        ; `rax` -> represents the full 64-bit register
        ; `eax` -> represents the lower 32-bit part
        ; `ax` -> represents the lower 16-bit part
        ; `al` -> represents the lower 8-bit part
        
        ; First we initialize both `rax` and `rbx` to 0
        mov rax, 0
        mov rbx, 0
        
        ; Since our characters are 1-byte, we store them in the `a1` register
        mov al, [rel initial] ; Copies `74` (the ASCII code of 'J') to `al`, and its 64-bit representation to `rax`
        mov bl, [rel initial2] ; ; Copies `67` `bl`, and its 64-bit representation to `rbx`

        ; `add` only knows how to do one thing: add numbers
        ; So, the following result will instead be 67 + 74 = 141, which gets stored in `rax`
        add al, bl
        ret