SECTION .data
msg     db  0Ah, 0  ; msg + '\n' + zero terminador
msg2     db  0Ah, 0  ; msg + '\n' + zero terminador
msgErroParametro db 'basename: falta operando',0AH,'Tente "basename --help" para mais informações.',0AH,0
lenErroParametro equ $-msgErroParametro 

msgHelp db 'Uso:  basename NOME [SUFIXO]',0Ah,' ou:  basename OPÇÃO... NOME...',0Ah,'Mostra o NOME sem quaisquer componentes iniciais de diretório.',0Ah,'Se especificado, remove também o SUFIXO final.',0Ah,'Argumentos obrigatórios para opções longas também o são para opções curtas.',0Ah,'    -a, --multiple       provê suporte a múltiplos argumentos e trata cada um como um NOME',0Ah,'    -s, --suffix=SUFIXO  remove um SUFIXO',59,' implica em -a',0Ah,'    -z, --zero           termina as linhas de saída com NULO, e não nova linha',0Ah,'        --help     mostra esta ajuda e sai',0Ah,'        --version  informa a versão e sai',0Ah,'Exemplos:',0Ah,'    basename /usr/bin/sort          -> "sort"',0Ah,'    basename include/stdio.h .h     -> "stdio"',0Ah, '    basename -s .h include/stdio.h  -> "stdio"',0Ah,'    basename -a algo/txt1 algo/txt2 -> "txt1" seguido de "txt2"',0Ah,0Ah,'Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>',0Ah,'Relate erros de tradução do basename: <https://translationproject.org/team/pt_BR.html>',0Ah,'Documentação completa em: <https://www.gnu.org/software/coreutils/basename>',0Ah,'ou disponível localmente via: info "(coreutils) basename invocation"',0Ah,0
lenHelp equ $-msgHelp

msgVersion db 'basename (GNU coreutils) 8.30',0Ah,'Copyright (C) 2018 Free Software Foundation, Inc.',0Ah,'Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>',0Ah,'Este é um software livre: você é livre para alterá-lo e redistribuí-lo.',0Ah,'NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.',0Ah,0Ah,'Escrito por David MacKenzie.',0Ah,0
lenVersion equ $-msgVersion

a db 'a',0
c db 'c',0
lenA equ $-a
lenC equ $-c

section .bss           ;Uninitialized data
    lenSuffix resb 5
    lenArgument resb 5
    suffix resb 2000
    argument resb 2000
    condicional resb 5
    var resb 1

SECTION .text
 global _start
        
_start:

    
    pop ebx ; pega o argc
    mov edi,ebx
    cmp edi,2 ; checa se existe menos de 2 parâmetro
    jl erroParametro
    
    
    pop ebx ; remove o ./basename
    pop ecx ; pega o primeiro argv depois de ./basename

    cmp byte [ecx], '-' ;checa se há flags
    je flags

   
initialize:
    mov edx, 0
getlen:
    ; incrementa o contador até encontrar fim da string ou '/'
    cmp byte [ecx + edx], 0
    je gotlenFinish
    cmp byte [ecx + edx], '/'
    je gotlen
    
    inc edx
    jmp getlen
gotlen:
    ;ao encontrar '/' zera o contador e move a posiçao de inicio da string
    ; Exemplo /Documentos/arroz, ao encontrar a / após Documentos a string em
    ; ecx começaria a partir de a de arroz. 

    inc edx
    cmp byte [ecx + edx], 0 ; caso depois do '/' acabe a string em ecx, remove ela e imprime a string
    je removeUltimaBarra
   
    add ecx,edx
    mov edx,0
    jmp getlen



removeUltimaBarra:
    
    cmp edx,1 ; se o arquivo tiver o nome /
    je gotlenFinish
    dec edx

gotlenFinish:
    

    mov eax,[condicional]
    cmp eax,2
    jg trataSuffix
    posMensagemAlterada:
	
    mov eax,4	
	mov ebx,1	
	int 80h		

    mov eax,[condicional]
    cmp eax,1
    je exit

    
    mov edx, 2   
    mov ecx, msg2    
    mov ebx, 1      
    mov eax, 4
    int 80h


    mov eax,[condicional]
    cmp eax,2
    jge singleFlagMultiple


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


doubleFlagHelp: 
   ;checa se é a flag help
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



singleFlagZero:   
    mov eax,1
    mov [condicional],eax
    pop ecx
    jmp initialize



initializeSingleFlagMultiple:
    mov eax,2
    mov [condicional],eax

singleFlagMultiple:
    cmp edi,0
    je exit
    dec edi
    pop ecx ; pega o argumento com o caminho do documento
    jmp initialize


singleFlagSufix:
   
    pop ecx ; pega o argumento do sufixo, exemplo: .c

    mov esi, ecx ; aponta a string(que é o sufixo) para esi
    mov eax,3
    mov [condicional],eax

    ; salva o tamanho do sufixo
    mov edx,-1
    tamanhoSuffix:
        inc edx
        cmp byte [ecx+edx],0
        jne tamanhoSuffix

    mov [suffix],ecx
    mov [lenSuffix],edx
   
    jmp singleFlagMultiple

argumentoSemSufixo:
    mov ecx,[argument]
    mov edx,[lenArgument]
    jmp posMensagemAlterada


trataSuffix:

   
    ; restaura valor de esi com o sufixo
    mov esi, [suffix]

    ; insere os novos valores do argumento atual
    ; insere o argumento em ebx para realizar a comparação
    mov [argument],ecx
    mov [lenArgument], edx
    mov ebx,ecx
    
    mov ecx,[lenSuffix]

    ;determina onde deve começar a comparação entre o argumento e o sufixo
    sub edx,ecx
    cmp edx,0
    jle  argumentoSemSufixo

    ; compara o argumento e o sufixo
    loop_here:
        lodsb
        cmp byte [ebx+edx],al
        jne argumentoSemSufixo
        inc edx
    loop    loop_here    ;jump when ecx != 0
    
    
    mov edx,[lenArgument]
    sub edx,[lenSuffix]
    mov ecx, [argument]
    jmp posMensagemAlterada
    


doubleFlagVersion:

    cmp byte [ecx+3], 'e'
    jne erroParametro
    cmp byte [ecx+4], 'r'
    jne erroParametro
    cmp byte [ecx+5], 's'
    jne erroParametro
    cmp byte [ecx+6], 'i'
    jne erroParametro
    cmp byte [ecx+7], 'o'
    jne erroParametro
    cmp byte [ecx+8], 'n'
    jne erroParametro
    cmp byte [ecx+9], 0
    jne erroParametro
    


    mov edx,lenVersion    ; msg tem um total de 14 bytes
    mov ecx, msgVersion    ; msg contém o endereço da mensagem
    mov ebx, 1      ; A saída é o console
    mov eax, 4      ; Optcode de SYS_WRITE
    int 80h 
    
    jmp exit




doubleFlagMultiple:
    cmp byte [ecx+3], 'u'
    jne erroParametro
    cmp byte [ecx+4], 'l'
    jne erroParametro
    cmp byte [ecx+5], 't'
    jne erroParametro
    cmp byte [ecx+6], 'i'
    jne erroParametro
    cmp byte [ecx+7], 'p'
    jne erroParametro
    cmp byte [ecx+8], 'l'
    jne erroParametro
    cmp byte [ecx+9], 'e'
    jne erroParametro
    cmp byte [ecx+10], 0
    jne erroParametro

    jmp initializeSingleFlagMultiple




doubleFlagZero:
    cmp byte [ecx+3], 'e'
    jne erroParametro
    cmp byte [ecx+4], 'r'
    jne erroParametro
    cmp byte [ecx+5], 'o'
    jne erroParametro
    cmp byte [ecx+6], 0
    jne erroParametro
    
    jmp singleFlagZero




doubleFlagSufix:
    cmp byte [ecx+3], 'u'
    jne erroParametro
    cmp byte [ecx+4], 'f'
    jne erroParametro
    cmp byte [ecx+5], 'f'
    jne erroParametro
    cmp byte [ecx+6], 'i'
    jne erroParametro
    cmp byte [ecx+7], 'x'
    jne erroParametro
    cmp byte [ecx+8], 0
    jne erroParametro
    
    jmp singleFlagSufix







flagsDouble:

    cmp byte [ecx+2], 'v' ;version
    je doubleFlagVersion

    cmp byte [ecx+2], 'h' ; help
    je doubleFlagHelp

    cmp edi,0     
    je erroParametro

    cmp byte [ecx+2], 'm' ; multiple
    je doubleFlagMultiple

    cmp byte [ecx+2], 'z' ; zero
    je doubleFlagZero

    cmp edi,1     
    je erroParametro 
    sub edi,1
    cmp byte [ecx+2], 's' ; suffix
    je doubleFlagSufix

    jmp erroParametro




flags:
    sub edi,2 ; retira da contagem do argc 2 parametros o ./main e a possivel flag

    cmp byte [ecx+1], '-'
    je flagsDouble
    
    ; todas as flags que nao sao --algumacoisa, precisam de um 3 argumento minimo
    cmp edi,0     
    je erroParametro 

    ; checa se as flag são -z e não -za ou outra coisa
    cmp byte [ecx+2], 0
    jne erroParametro

    cmp byte [ecx+1], 'z'
    je singleFlagZero

    cmp byte [ecx+1], 'a'
    je initializeSingleFlagMultiple

    ; suffixo precisa de um argumento a mais minimo, ou seja 4 mínimo. ./basename -s .c main.c
    cmp edi,1     
    je erroParametro 
    sub edi,1
    cmp byte [ecx+1], 's'
    je singleFlagSufix

    jmp erroParametro
