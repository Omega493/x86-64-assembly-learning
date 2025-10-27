[bits 64]
global main

section .data
    x dq 57
    y dq -74

section .text
    main:
        mov rbx, [rel x]
        mov rcx, [rel y]
        mov rax, 0
        cmp rbx, rcx
        jge rbx_greater_than_or_equal_to_rcx
        jl rbx_lesser_than_or_equal_to_rcx
        rbx_greater_than_or_equal_to_rcx:
            mov rax, 1
            jmp comp_complete ; This is similar to the `break` keyword in C++
        rbx_lesser_than_or_equal_to_rcx:
            mov rax, -1
            jmp comp_complete
        comp_complete:
            ret ; Should return 1 as 57 >= -74 satisfies

; In C++, all this is similar to just writing:
; int main() {
;     return ((57 >= -74) ? 1 : -1);
; }