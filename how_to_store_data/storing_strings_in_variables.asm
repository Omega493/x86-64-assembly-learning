[bits 64]
global main

section .data
    var db `Hello`, 0 ; Both single- and double- quotes can be used. The difference is backticks allow escape codes such as `\n`

section .text
    main:
        lea rax, [rel var] ; `lea` stands for load effective address. For this string here, it loads the memory address of the 'H' of "Hello"
        mov bl, [rax] ; Get the 8-bit value from the address `rax` holds and put it in `bl`. `bl` holds 'H'
        
        add rax, 1 ; `rax` now holds the address of the `e` is "Hello"
        mov cl, [rax] ; Get the 8-bit value from the address `rax` holds and put it in `cl`. `cl` holds 'e'
        
        add rax, 1 ; `rax` now holds the address of the `l` is "Hello"
        mov dl, [rax] ; Get the 8-bit value from the address `rax` holds and put it in `dl`. `dl` holds 'l`
