SECTION .data
msg     db  0Ah, 0  ; msg + '\n' + zero terminador
msg2     db  0Ah, 0  ; msg + '\n' + zero terminador
msgErroParametro db 'basename: falta operando',0AH,'Tente "basename --help" para mais informações.',0AH,0
lenErroParametro equ $-msgErroParametro 

msgHelp db 'Uso:  basename NOME [SUFIXO]',0Ah,' ou:  basename OPÇÃO... NOME...',0Ah,'Mostra o NOME sem quaisquer componentes iniciais de diretório.',0Ah,'Se especificado, remove também o SUFIXO final.',0Ah,'Argumentos obrigatórios para opções longas também o são para opções curtas.',0Ah,'    -a, --multiple       provê suporte a múltiplos argumentos e trata cada um como um NOME',0Ah,'    -s, --suffix=SUFIXO  remove um SUFIXO',59,' implica em -a',0Ah,'    -z, --zero           termina as linhas de saída com NULO, e não nova linha',0Ah,'        --help     mostra esta ajuda e sai',0Ah,'        --version  informa a versão e sai',0Ah,'Exemplos:',0Ah,'    basename /usr/bin/sort          -> "sort"',0Ah,'    basename include/stdio.h .h     -> "stdio"',0Ah, '    basename -s .h include/stdio.h  -> "stdio"',0Ah,'    basename -a algo/txt1 algo/txt2 -> "txt1" seguido de "txt2"',0Ah,0Ah,'Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>',0Ah,'Relate erros de tradução do basename: <https://translationproject.org/team/pt_BR.html>',0Ah,'Documentação completa em: <https://www.gnu.org/software/coreutils/basename>',0Ah,'ou disponível localmente via: info "(coreutils) basename invocation"',0Ah,0
lenHelp equ $-msgHelp




section .bss           ;Uninitialized data
   buffer resb 256
   num     resb 5

SECTION .text
 global _start
        
_start:
    mov esi,0
    pop ebx
    mov [num],ebx
    cmp ebx,2
    jl erroParametro
    
    
    pop ebx
    pop ecx

    cmp byte [ecx + edx], '-'
    je flags

    ;cmp ebx,2
    ;je eMensagemHelp

   
initialize:
    mov edx, 0
getlen:
    
    cmp byte [ecx + edx], 0
    je gotlenFinish
    cmp byte [ecx + edx], '/'
    je gotlen
    
    inc edx
    jmp getlen
gotlen:
    inc edx
    cmp byte [ecx + edx], 0
    je removeUltimaBarra
   
    add ecx,edx
    mov edx,0
    jmp getlen



removeUltimaBarra:
    dec edx

gotlenFinish:
    
	mov eax,4	;the system call for write
	mov ebx,1	;file descriptor for std output
	int 80h		;call kernal	int 80h	

    cmp esi,1 ; caso a flag seja -z nao imprime /n
    je exit


    mov edx, 2    ; msg tem um total de 14 bytes
    mov ecx, msg2    ; msg contém o endereço da mensagem
    mov ebx, 1      ; A saída é o console
    mov eax, 4      ; Optcode de SYS_WRITE
    int 80h
    jmp exit   


exit:
    mov EAX, 1 ; sys_exit()
    mov EBX, 0 ; return 0
    int 0x80

erroParametro:

    mov edx,lenErroParametro    ; msg tem um total de 14 bytes
    mov ecx, msgErroParametro    ; msg contém o endereço da mensagem
    mov ebx, 1      ; A saída é o console
    mov eax, 4      ; Optcode de SYS_WRITE
    int 80h 

    

    jmp exit  


flagHelp: 
   ;checa se é a flag help
    cmp byte [ecx+2], 'h'
    jne erroParametro
    cmp byte [ecx+3], 'e'
    jne erroParametro
    cmp byte [ecx+4], 'l'
    jne erroParametro
    cmp byte [ecx+5], 'p'
    jne erroParametro

    cmp byte [ecx+6], 0
    jne erroParametro

    mov edx,lenHelp    ; msg tem um total de 14 bytes
    mov ecx, msgHelp    ; msg contém o endereço da mensagem
    mov ebx, 1      ; A saída é o console
    mov eax, 4      ; Optcode de SYS_WRITE
    int 80h 
    
    jmp exit


flagImprimeSemEnter:
    ; checa se a flag é -z e não -za ou outra coisa
    cmp byte [ecx+2], 0
    jne erroParametro
    
    ; checa caso a pessoa entra a flag -z  porém nao passe mais nenhum parâmetro
    mov ebx,[num] 
    cmp ebx,2     
    je erroParametro 
    
    mov esi,1
    pop ecx
    jmp initialize


flags:
    cmp byte [ecx+1], '-'
    je flagHelp

    cmp byte [ecx+1], 'z'
    je flagImprimeSemEnter


    jmp erroParametro
