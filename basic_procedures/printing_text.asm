[bits 64]
global main
extern GetStdHandle
extern WriteConsoleA

section .data
    var db `Hello, x86-64 Assembly!`, 0
    bytes_written dq 0

section .text
    main:
        ; Stack alignment: We must reserve 32-bytes of "shadow space" + 8 bytes for the fifth arg + 8 bytes for alignement on the stack for the func. to use
        ; We do this before the call with `sub rsp, 48` (`rsp` -> stack pointer)
        ; We clean this up later with `add rsp, 48`
        ; Stack alignment ALWAYS remains the same, no matter whether the length of string is 26 or 26000!

        sub rsp, 48 ; 48 bytes = 32 bytes shadow + 8 byte for arg 5 + 8 for alignment
        
        ; First call: GetStdHandle
        ; As per 64-bit Windoes calling convensions, the first arg. to a func. must be placed in `rcx`
        mov rcx, -11
        ; Call the function
        call GetStdHandle ; `rax` now holds our console handle

        ; `WriteConsoleA` takes 5 args:
        ; First arg: `rcx` -> The console handle
        ; Second arg: `rdx` -> The address of our string
        ; Third arg: `r8` -> The number of characters to write
        ; Fourth arg: `r9` -> An address to store the number of bytes actually written. We can just reuse the address of `var` for this - it's not important here
        ; Fifth arg and onwards: Placed on the stack -> A reserved arg, which must be 0

        mov rcx, rax ; Copy `GetStdhandle` from `rax` and put it in `rcx`
        lea rdx, [rel var] ; Load the address of `var` to `rdx`
        mov r8, 26 ; `26` -> length of the string
        lea r9, [rel bytes_written]
        mov QWORD [rsp+32], 0 ; Set the fifth arg (at rsp + 32 bytes) to 0

        call WriteConsoleA

        add rsp, 48 ; Clean up the stack

        mov rax, 0
        ret