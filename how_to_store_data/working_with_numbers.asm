[bits 64]
; The format  for `add`, `sub` and `mov` is `opcode destination, source`
; The format for `mul` and `div` is `opcode operand` -> the result is always stored in `rax`

global main ; Announce `main` as the entry point

section .text ; The executable code is here
    main: ; label for `main`
        mov rax, 10 ; Copy 10 to register `rax`
        mov rbx, 5 ; Copy 5 to register `rbx`
        add rax, rbx ; Add the values contained in `rax` and `rbx` and place in `rax`
        ; `rax` is now 15
        sub rbx, rax ; Subtract the value stored in `rax` from `rbx` and place in `rbx`
        ; `rbx` is now -10
        mov rax, rbx ; Copy the value stored in `rbx` to `rax`

        ; `mul` takes one operand: the multiplier, it's output is stored in `rax`
        ; 'mul' is for unsigned integers, `imul` is used for signed ones
        imul rbx ; Multiply the value in `rbx` with `rax` and store in `rax`
        ; `rax` now contains 100
        
        ; Like `mul`, `div` takes one operand: the divisor, it stores output in `rax`
        ; 'div' is for unsigned integers, `idiv` is used for signed ones
        ; `rax` contains the quotient (the result)
        ; `rdx` contains the remainder
        
        cqo ; Sign extends `rax` into `rdx`, `rdx` is now 0 
        idiv rbx ; Divide the value in `rax` with that in `rbx`, and place the result in `rax`
        ; `rax` now contains -10, `rdx` contains 0

        cqo ; Sign extends `rax` into `rdx`, `rdx` is now -1 (all bits set to 1)
        idiv rax ; Divide the value in `rax` with itself, and place the result in `rax`
        ;`rax` now holds 1, and `rdx` holds 0
        ret ; The value stored in `rax` is used as the exit code of the program

; The following comments describe the values stored in each registered. Grouped as `rax`, `rbx`, `rdx`
; Line 09: 10, N/A, N/A
; Line 10: 10, 5, N/A
; Line 11: 15, 5, N/A
; Line 13: 15, -10, N/A
; Line 15: -10, -10, N/A
; Line 19: 100, -10, N/A
; Line 27: 100, -10, 0
; Line 28: -10, -10, 0
; Line 31: -10, -10, -1
; Line 32: 1, -10, -1
; Return code: 1