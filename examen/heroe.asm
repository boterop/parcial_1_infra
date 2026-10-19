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
