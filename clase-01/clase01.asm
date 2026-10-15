; ============================================================
;  LA LEYENDA DEL REGISTRO - CLASE 1
;  "El despertar del héroe"
; ------------------------------------------------------------
;  Arquitectura : x86-64 (Intel/AMD de 64 bits)
;  Ensamblador  : NASM (sintaxis Intel)
;  Sistema      : Linux (Ubuntu en VM)
;  Compilar     : nasm -f elf64 clase01.asm -o clase01.o
;  Enlazar      : ld clase01.o -o clase01
;  Ejecutar     : ./clase01
; ============================================================

; ------------------------------------------------------------
; SECCION DE DATOS  ->  el "tesoro" y los "diálogos" del héroe
; ------------------------------------------------------------
section .data
    titulo    db "MI GRAN AVENTURA v0.2", 10      ; título del juego
    len_titulo equ $ - titulo                             ; su longitud en bytes
    mensaje   db "Welcome to assembler hell 😈", 10
    len_mensaje equ $ - mensaje
    adios     db "El sistema operativo te despidio con elegancia (código 7).", 10
    len_adios equ $ - adios
    press_enter     db "Presiona enter para continuar...", 10
    len_enter equ $ - press_enter

; ------------------------------------------------------------
; SECCION DE CODIGO  ->  las "acciones" que el héroe ejecuta
; ------------------------------------------------------------
section .text
    global _start                                  ; punto de entrada del programa

_start:
    ; ---------- Accion 1: mostrar el título ----------
    mov rax, 1                    ; número de syscall: sys_write (escribir)
    mov rdi, 1                    ; descriptor de archivo 1 = pantalla (stdout)
    mov rsi, titulo               ; dirección de memoria del texto a imprimir
    mov rdx, len_titulo           ; cantidad de bytes a escribir
    syscall                       ; ¡llamada al kernel de Linux!

    ; ---------- Accion 2: mostrar la bienvenida ----------
    mov rax, 1                    ; de nuevo: sys_write
    mov rdi, 1                    ; de nuevo: pantalla (stdout)
    mov rsi, mensaje              ; dirección del mensaje de bienvenida
    mov rdx, len_mensaje          ; su longitud
    syscall                       ; ¡otra llamada al kernel!

    ; ---------- Accion 3: despedirse ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, adios
    mov rdx, len_adios
    syscall

    ; ---------- Accion 4: presiona enter para continuar ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, press_enter
    mov rdx, len_enter
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, press_enter
    mov rdx, len_enter
    syscall

    ; ---------- Accion final: terminar el programa ----------
    mov rax, 60                   ; número de syscall: sys_exit (terminar)
    mov rdi, 7                    ; código de salida 0 = todo salió bien
    syscall                       ; el kernel termina el proceso. ¡Fin!
