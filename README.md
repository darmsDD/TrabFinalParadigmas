# TrabFinalParadigmas
Repositório do trabalho final de paradigmas
## Basename em assemblyx86

## Intruções

### Instalação
1. $ sudo apt-get install nasm, para ter o nasm instalado em sua máquina e poder executar.

### Navegue até a pasta deste repositório pelo terminal e execute os comandos abaixo:
1- $ nasm -f elf mybasename.s

2- $ ld -m elf_i386 mybasename.o -o mybasename

3- $ ./mybasename --help, este comando serve para você poder ver quais opções pode executar no programa
lembrando que as opções são executadas com ./mybasename. Exemplo: ./mybasename /Documentos/Ivan/Paradigmas/mybasename.s, que retornará mybasename.s
