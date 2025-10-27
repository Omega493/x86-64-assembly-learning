
; Program to read from a string, count its length, print the string and return the length of the string 

[bits 64]
global main
extern GetStdHandle
extern WriteConsoleA

section .data
    var db `These programs may overwhelm you at first. However, go through them with diligence, read them and their explanations as many times as necessary, and you will have a solid foundation of knowledge to build on.`, 0
    bytes_written dq 0

section .text
main:
    lea rax, [rel var] ; Load the address of `T` in `var`
    mov bl, [rax] ; `bl` and consequently `rbx` is alrd used here
    mov rcx, 0 ; Our length counter
    len_count_start:
        mov bl, [rax] ; Load the value contained in memory address contained `rax`
        cmp bl, 0 ; Compare if null terminator
        je len_count_end
        add rcx, 1 ; Keep count
        add rax, 1
        jmp len_count_start
    len_count_end: ; Here, `rcx` contains the length of the string
        mov rbx, rcx ; Copy the length of string in `rcx` to `rbx`
        
        sub rsp, 48 ; Shadow space + 5th arg + alignment

        mov rcx, -11
        call GetStdHandle ; `rax` now contains address of GetStdHandle

        mov rcx, rax ; Copy the address of the handle at `rax` to `rcx`
        lea rdx, [rel var] ; The address of our string
        mov r8, rbx ; The length of the string
        lea r9, [rel bytes_written] ; Address to store the bytes written on the string
        mov QWORD [rsp+32], 0 ; Set the 5th arg

        call WriteConsoleA

        add rsp, 48 ; Clean the stack

        mov rax, rbx ; The return code is set as the length of the string
        ret