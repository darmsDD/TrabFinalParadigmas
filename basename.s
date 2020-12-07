SECTION .data
msg     db  'a',0Ah, 0  ; msg + '\n' + zero terminador
msg2     db  0Ah, 0  ; msg + '\n' + zero terminador

section .bss           ;Uninitialized data
   buffer resb 256
   num     resb 5

SECTION .text
 global _start
        
_start:
    pop ebx
    mov esi,ebx
    pop ebx


initialize:
    pop ecx
    mov edx, 0
getlen:
    
    cmp byte [ecx + edx], 0
    jz gotlenFinish
    cmp byte [ecx + edx], '/'
    jz gotlen
    
    inc edx
    jmp getlen
gotlen:
    inc edx
    cmp byte [ecx + edx], 0
    jz removeUltimaBarra
   
    add ecx,edx
    mov edx,0
    jmp getlen


removeUltimaBarra:
    dec edx

gotlenFinish:
    
    mov [buffer], ecx
    mov ecx,[buffer]
	mov eax,4	;the system call for write
	mov ebx,1	;file descriptor for std output
	int 80h		;call kernal	int 80h	

    mov edx, 3    ; msg tem um total de 14 bytes
    mov ecx, msg2    ; msg contém o endereço da mensagem
    mov ebx, 1      ; A saída é o console
    mov eax, 4      ; Optcode de SYS_WRITE
    int 80h   


exit:
    mov EAX, 1 ; sys_exit()
    mov EBX, 0 ; return 0
    int 0x80
