daemon.asm
[SECTION .text]

global _start

_start:
        xor eax, eax
        cdq
        xor ebx, ebx
        xor ecx, ecx

        label_ffork:       
        mov al, 2       
        int 0x80
        xor eax, eax
        mov al, 20
        int 0x80
        mov ebx, eax
        mov eax, 37
        mov ecx, 15
        dec ebx
        int 0x80
        jmp label_setsid

        label_setsid:
        xor eax, eax
        mov al, 66
        int 0x80
        jmp label_chdir

        label_chdir:
        xor eax, eax
        push word '/'
        mov ebx, esp
        mov al, 12
        int 0x80
        jmp label_umask


        label_umask:
        xor eax, eax
        xor ebx, ebx
        mov al, 60
        int 0x80
        xor eax, eax
        cdq
        xor ebx, ebx
        xor ecx, ecx
        jmp label_closes

        label_closes:
        xor eax, eax
        cmp ecx, 256           
        jge label_path         

        mov ebx, ecx           
        mov al, 6              
        int 0x80               

        inc ecx                
        jmp label_closes       

        label_devnull:
        xor eax, eax
        cdq
        xor ebx, ebx
        xor ecx, ecx
        mov al, 6
        int 0x80
        xor eax, eax
        xor ebx, ebx
        mov al, 5           
        pop ebx  
        mov ecx, 2          
        xor edx, edx        
        int 0x80            
        mov ebx, eax        
        xor eax, eax
        mov al, 63          
        xor ecx, ecx        
        int 0x80            
        xor eax, eax
        mov al, 63          
        mov ecx, 1          
        int 0x80            
        xor eax, eax
        mov eax, 63         
        mov ecx, 2          
        int 0x80            
        jmp label_sleep

        label_sleep:
        xor eax, eax
        xor ebx, ebx
        push ax
        push 60
        mov ebx, esp
        mov al, 162
        int 0x80
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        mov al, 1
        int 0x80

        label_path:
        call label_devnull
        db '/dev/null'
