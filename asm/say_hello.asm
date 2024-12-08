;say_hello.asm
[SECTION .text]

global _start

_start:
    xor eax, eax
    cdq
    xor ebx, ebx
    xor ecx, ecx
    jmp label_hello

    label_write:
    pop ecx
    mov al, 4       
    mov bl, 1
    mov dl, 11
    int 0x80
    xor eax, eax
    mov al, 1 
    xor ebx,ebx
    int 0x80

    label_hello:

    call label_write
    db 'hello world'