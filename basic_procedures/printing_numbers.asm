[bits 64]
global main
extern GetStdHandle
extern WriteConsoleA

section .data
    var dq -49354
    bytes_written dq 0

section .bss
    buffer resb 20

section .text
    main:
        lea rdi, [rel buffer] ; `rdi` -> "register destination index"
        ; `lea` is used here instead of `mov` because `mov` tells the asembler to find the exact address of the buffer
        ; `lea` instead generates a special instruction that use `rip` (instruction ptr)-relative addressing
        ; This doesn't store the memory address, but the offset
        add rdi, 20 ; Move the ptr to the end of the buffer
        mov [rdi], BYTE 0 ; Write the null terminator at the end of the buffer
        
        mov rax, [rel var] ; Load the number
        mov rbx, 10 ; Our divisor
        mov rcx, 0 ; Our length counter

        cmp rax, 0 ; What if number itself is zero?
        je if_num_is_0
        jg positive_to_str
        jl negative_to_str

        if_num_is_0: ; If number is zero
            sub rdi, 1
            mov rdx, 48 ; Initialize `rdx` to 48, the ASCII for 0
            mov [rdi], dl ; Write zero to the buffer
            add rcx, 1
            jmp print_num

        positive_to_str: ; If number > 0
            cmp rax, 0
            je print_num
            sub rdi, 1
            cqo ; Clear `rdx`
            idiv rbx
            add rdx, 48 ; 48 is ASCII for zero
            mov [rdi], dl ; Copy the 1-byte char to `rdi`
            add rcx, 1
            jmp positive_to_str
        
        modulus_to_str: ; Helper function for `negative_to_str`
            cmp rax, 0
            je ret_to_caller
            sub rdi, 1
            cqo ; Clear `rdx`
            idiv rbx
            add rdx, 48 ; 48 is ASCII for zero
            mov [rdi], dl ; Copy the 1-byte char to `rdi`
            add rcx, 1
            jmp modulus_to_str
        
        ret_to_caller:
            ret
        
        negative_to_str:
            mov r15, -1 ; Since we are out of registers, we use r15
            imul r15 ; More or less a "hack" to convert the number to a string
            call modulus_to_str ; `call` returns control to the caller, `jmp` or others don't
            mov rdx, 45 ; 45 is the ASCII for minus symbol
            sub rdi, 1
            mov [rdi], dl
            add rcx, 1
            jmp print_num

        print_num:
            sub rsp, 48 ; Initialize the stach

            mov rbx, rcx ; Move the length of the string

            mov rcx, -11
            call GetStdHandle

            mov rcx, rax ; Console handle
            mov rdx, rdi ; Address of string
            mov r8, rbx ; Length of string
            lea r9, [rel bytes_written]
            mov QWORD [rsp+32], 0

            call WriteConsoleA
        add rsp, 48 ; Clear the stack

        mov rax, 0
        ret