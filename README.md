# Basic Shellcoding For Linux - The Full Guide

***disclaimer***  
This guide was created for educational purposes only, it was formed after long hours of browsing on the internet and learning the basic principles of shellcoding, article by article, gathering small bits of information until the entire image became clearer.  
Before reading I should clarify, my struggle learning shellcoding came from my lack of knowledge in assembly while having a decent understanding of the logic needed in order to write a successful shellcode.  
So without further ado, lets dive in.  

## What Is A Shellcode?

A shellcode is basically a payload used by attackers, crafted in order to exploit a vulnerability, it should be as small in size as possible.  
As mentioned above, a shellcode needs to be meticulously crafted and so it is usually written in assembly by hand.  
One might ask themselves, why not just write a piece of c language code, compile it, hex dump it and use it as a payload?   
Well since a shellcode is basically a "string" if we have null bytes in the middle it will cut the payload in the middle, a thing that will most probably occur in the given scenario.  

Before we dive further in regarding the technical details of writing a successful shellcode there are couple required tools:  
- a Linux machine, i use ubuntu 22.04, kernel version 6.8.0-48, with disabled aslr (echo 0 > /proc/sys/kernel/randomize_va_space)  
- nasm (gcc-multilib)  
- ld  
- objdump  
- gcc  

For the sake of this guide i'll write the examples in 32-bit  
After writing our assembly code we will compile it to object file using the following command:  
```
nasm -f elf32 -o <prog_name>.o <prog_name>.asm
```
Next, we'll compile the object file into an executable:  
```
ld -m elf_i386 -o <prog_name> <prog_name>.o
```
The last step is extracting the payload from the executable:  
```
objdump -d ./<prog_name> | grep '[0-9a-f]:' | grep -v 'file' | cut -f2 -d: | cut -f1-6 -d' ' | tr -s ' ' | tr '\t' ' ' | sed 's/ $//g' | sed 's/ /\\x/g' |paste -d '' -s | sed 's/^/"/' | sed 's/$/"/g'   
```

## Do's And Don'ts - Spot The Differences
Let's start with a simple example, these 2 instructions are used for a simple, yet inevitable task, initializing a register.  
```
xor  eax, eax
```
```
mov  eax, 0
```
The first option is optimal, uses only one instruction and wont cause any null bytes. on the other hand the second option, while being one instruction will cause a null terminator in the middle of our payload.  

In the following example, both will work perfectly fine for writing a shellcode and wont cause any vital errors
```
xor  eax, eax
cdq
```
```
xor  eax, eax
xor  edx, edx
```
As we can see, both options will work perfectly for a shellcode but the first code block will result in a shorter payload.  
Working with strings in assembly can be quit a headache, lucky for us we can use the data segment! (or can we?)
```
section .text
global _start
_start:
    xor     eax, eax
    cdq
    ... 
    jmp     my_label
my_label_again:                         
    ...
    pop    ecx 
    int    0x80
my_label:
    call    my_label_again
    db "hello world"
```
```
section .data
thing    db "hello world", 0

section .text
global _start
_start:
    ...
    mov ecx, thing
    int    0x80
```
even though the second option requires about half the instructions, in shellcodes only the text section can be extracted into the payload so sadly our string in the data section in the second example will be lost during the payload extraction process.

## From Registers To Syscalls
Now that the fundamental principles for shellcoding are clear we can start crafting an actual working payload.  
The first I reccomend doing is trying to imagine the goal of our shellcode and understand what syscalls are needed in order to achieve it, the simplest example it printing hello world to the terminal.  
As we know the syscall needed is write() to fd 1 (stdout), a quick look in a syscall table for x86 shows us that in order to execute this syscall we need the following registers to contain some certain data:
- eax = syscall number (int)
- ebx = fd (int)
- ecx = buffer for printing (const char *)
- edx = buffer size (int)  

And of course we'll need to exit the shellcode as well using the syscall exit():
- eax = syscall number
- ebx = error number (if there is no error just put 0)
When implementing everything we learned so far we end up with the following code:
```
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
```
The next step is preforming the shellcode extraction, the output is the following
```
\x31\xc0\x99\x31\xdb\x31\xc9\xeb\x11\x59\xb0\x04\xb3\x01\xb2\x0b\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xea\xff\xff\xff\x68\x65\x6c\x6c\x6f\x20\x77\x6f\x72\x6c\x64
```
No null bytes and quite a small size - great success
