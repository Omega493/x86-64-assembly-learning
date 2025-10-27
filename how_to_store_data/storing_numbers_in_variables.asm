[bits 64]
global main

section .data
    ; `dq` stands for "define quadword" - it represents a 64-bit number
    x dq 10 ; `x` is a label for a memory location holding 10
    y dq 5 ; `y` is a label for a memory location holding 5

section .text
    main:
        mov rax, [rel x] ; Copies the value stored at the address `x` into `rax`. Had we used `mov rax, x`, it would've instead copied the address itself
        mov rbx, [rel y] ; Copies the value stored at the address `y` into `rbx`
        add rax, rbx ; Add the values contained in `rax` and `rbx` and place in `rax`
        ; `rax` is now 15
        sub rbx, rax ; Subtract the value stored in `rax` from `rbx` and place in `rbx`
        ; `rbx` is now -10
        mov rax, rbx ; Copy the value stored in `rbx` to `rax`

        imul rbx ; Multiply the value in `rbx` with `rax` and store in `rax`
        ; `rax` now contains 100
        
        cqo ; Sign extends `rax` into `rdx`, `rdx` is now 0 
        idiv rbx ; Divide the value in `rax` with that in `rbx`, and place the result in `rax`
        ; `rax` now contains -10, `rdx` contains 0

        cqo ; Sign extends `rax` into `rdx`, `rdx` is now -1 (all bits set to 1)
        idiv rax ; Divide the value in `rax` with itself, and place the result in `rax`
        ;`rax` now holds 1, and `rdx` holds 0
        ret ; The value stored in `rax` is used as the exit code of the program

; The following comments describe the values stored in each registered. Grouped as `rax`, `rbx`, `rdx`
; Line 11: 10, N/A, N/A
; Line 12: 10, 5, N/A
; Line 13: 15, 5, N/A
; Line 15: 15, -10, N/A
; Line 17: -10, -10, N/A
; Line 19: 100, -10, N/A
; Line 22: 100, -10, 0
; Line 23: -10, -10, 0
; Line 26: -10, -10, -1
; Line 27: 1, -10, -1
; Return code: 1