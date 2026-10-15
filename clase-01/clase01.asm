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
    titulo    db "LA LEYENDA DEL REGISTRO v0.1", 10      ; título del juego
    len_titulo equ $ - titulo                             ; su longitud en bytes
    mensaje   db "Bienvenido, heroe. Tu aventura empieza aqui.", 10
    len_mensaje equ $ - mensaje
    adios     db "El sistema operativo te despidio con elegancia (código 0).", 10
    len_adios equ $ - adios

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

    ; ---------- Accion final: terminar el programa ----------
    mov rax, 60                   ; número de syscall: sys_exit (terminar)
    mov rdi, 0                    ; código de salida 0 = todo salió bien
    syscall                       ; el kernel termina el proceso. ¡Fin!
