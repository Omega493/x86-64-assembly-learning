[bits 64]
global main
extern GetStdHandle
extern WriteConsoleA

section .bss
    buffer resb 20 ; Reserves 20 bytes of space in an unitialized memory

section .data
    bytes_written dq 0 ; For WriteConsoleA

section .text
    main:
        lea rdi, [rel buffer] ; `rdi` -> "register destination index". From now on, we use it for passing the second arguments
        ; `lea` is used here instead of `mov` because `mov` tells the asembler to find the exact address of the buffer
        ; `lea` instead generates a special instruction that use `rip` (instruction ptr)-relative addressing
        ; This doesn't store the memory address, but the offset
        add rdi, 20 ; Move the ptr to the end of the buffer
        mov [rdi], BYTE 0 ; Write the null terminator
        mov rax, 493 ; Load 493 to `rax`
        mov rbx, 10 ; Our divisor
        mov rcx, 0 ; Our counter

        print_num:
            cmp rax, 0
            je loop_end

            sub rdi, 1 ; Last-in approach. Here we move the `rdi` (the address) by 1-byte
            cqo ; Clear `rdx` for divison
            idiv rbx ; After this, `rdx` will hold the remainder. The remainder is a number, we need a character
            add rdx, 48 ; ASCII for 0 is 48, so we add 48 to the remainder value stored in `rdx`
            mov [rdi], dl ; Write the 1-byte char into the buffer
            add rcx, 1 ; Increment the counter by 1
            jmp print_num
        loop_end:
            ; Here, `rdi` points to the start of our new strind (ex. - `493`)
            ; And, `rcx` holds the length of said string

            sub rsp, 48 ; Prepare the stack. 32-bytes "shadow space" + 8-byte for arg 5 + 8 byte for alignment

            mov rbx, rcx ; Copy the length of string to `rbx`

            ; Get the console handle
            mov rcx, -11
            call GetStdHandle
            ; `rax` now holds the handle
            mov rcx, rax ; Copy `GetStdhandle` from `rax` and put it in `rcx`
            mov rdx, rdi ; The address of the string
            mov r8, rbx ; Copy the length of string from `rbx`
            lea r9, [rel bytes_written] ; Output address

            mov QWORD [rsp+32], 0 ; Set the fifth arg (at rsp + 32 bytes) to 0
            call WriteConsoleA 
        add rsp, 48 ; Clean up the stack
        mov rax, 0 ; Set 0 as the return code
        ret