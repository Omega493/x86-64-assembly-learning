[bits 64]
global main

section .data
    var dq 10, 50, 2, 99, 45, 109, 164, -456, 201 ; No terminator is used as we manually kep count of length
    length_of_arr dq 9 ; Whatever is placed here, will be used as the array length for the check
    ; Example - if we replace `9` with `5`, only the first 5 elements will be checked

section .text
    main:
        lea rdi, [rel var] ; Load the effective address of `var` into `rdi`
        mov rdx, [rel length_of_arr] ; Load the length of array

        cmp rdx, 0 ; If length is 0
        je if_arr_is_empty

        mov rax, [rdi] ; Our current pointer

        mov rbx, [rdi] ; Our storage (largest number)
        ; Initialize both to the start of the array

        mov rcx, 1 ; Length counter - initialize it to 1 as we already read the initial element

        largest_number:
            cmp rcx, rdx ; If the length counter is equal to array length, terminate the loop
            je loop_end

            add rcx, 1 ; Add 1 to the length counter

            add rdi, 8 ; Each int is 8-bytes long
            mov rax, [rdi] ; Copy the latest value in `rdi` to `rax`

            cmp rax, rbx ; Is the value in `rax` > that in `rbx`
            jg new_large ; If number is greater, copy it to `rbx`
            jmp largest_number ; Else, jump to the beginning of this label

        new_large:
            mov rbx, rax ; Copy our new largest to `rbx`
            jmp largest_number ; Jump to the beginning of the loop
            
        loop_end:
            mov rax, rbx ; Set the value in `rbx` (the largest) as the return code
            ret

        if_arr_is_empty: 
            mov rax, -1
            ret