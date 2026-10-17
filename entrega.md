# Parte A 
## A.1
### A.1.1
- Compilamos el .asm en .o con `nasm -f elf64 clase01.asm -o clase01.o`
- Enlazamos el .o con `ld clase01.o -o clase01`
- Salida
```sh
ubuntu@infra:~/Downloads/examen/clase-01$ nasm -f elf64 clase01.asm -o clase01.o
ubuntu@infra:~/Downloads/examen/clase-01$ ls
clase01.asm  clase01.md  clase01.o  compilar.sh
ubuntu@infra:~/Downloads/examen/clase-01$ ld clase01.o -o clase01
ubuntu@infra:~/Downloads/examen/clase-01$ ls
clase01  clase01.asm  clase01.md  clase01.o  compilar.sh
ubuntu@infra:~/Downloads/examen/clase-01$ ./clase01 
MI GRAN AVENTURA v0.2
Welcome to assembler hell 😈
El sistema operativo te despidio con elegancia (código 7).
Presiona enter para continuar...
Presiona enter para continuar...
ubuntu@infra:~/Downloads/examen/clase-01$ echo $?
7
```
### A.1.2
```sh
ubuntu@infra:~/Downloads/examen/clase-01$ strace -e trace=write,exit_group ./clase01 2> trace1.txt
MI GRAN AVENTURA v0.2
Welcome to assembler hell 😈
El sistema operativo te despidio con elegancia (código 7).
Presiona enter para continuar...
Presiona enter para continuar...

ubuntu@infra:~/Downloads/examen/clase-01$ cat trace1.txt 
write(1, "MI GRAN AVENTURA v0.2\n", 22) = 22
write(1, "Welcome to assembler hell \360\237\230\210\n", 31) = 31
write(1, "El sistema operativo te despidio"..., 60) = 60
write(1, "Presiona enter para continuar..."..., 33) = 33
write(1, "Presiona enter para continuar..."..., 33) = 33
+++ exited with 7 +++
```

1. Hay 5 llamadas a `write` en total.
2. El codigo de salida del exit_group es 7.
3. El numero de syscall que usa write es 1.
### A.4
Codigo
<details>
<summary>Haz clic aquí para ver el heroe.asm</summary>
```asm
section .data
  input_title db "Nombre: "
  input_title_len equ $ - input_title

  newline db 10
  newline_len equ $ - newline

  name_len equ 16
section .bss
  name resb name_len
section .text
  global _start
_start:
  mov rax, 1
  mov rdi, 1
  mov rsi, input_title
  mov rdx, input_title_len
  syscall

  mov rax, 0
  mov rdi, 0
  mov rsi, name
  mov rdx, name_len
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, name
  mov rdx, name_len
  syscall

  ; Como el name fue ingresado por consola ya tiene salto de linea
  ; Pero voy a imprimir otro para completar el punto 4
  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, newline_len
  syscall

  mov rax, 60
  mov rdi, 0
  syscall
```
</details>

Salida
```sh
ubuntu@infra:~/Downloads/examen/examen$ ./build.sh 
Nombre: Sauron
Sauron

ubuntu@infra:~/Downloads/examen/examen$ 
```
