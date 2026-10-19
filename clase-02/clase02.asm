; ============================================================
;  LA LEYENDA DEL REGISTRO - CLASE 2
;  "El nombre del heroe"
; ------------------------------------------------------------
;  Arquitectura : x86-64 (Intel/AMD de 64 bits)
;  Ensamblador  : NASM (sintaxis Intel)
;  Sistema      : Linux (Ubuntu en VM)
;  Compilar     : nasm -f elf64 clase02.asm -o clase02.o
;  Enlazar      : ld clase02.o -o clase02
;  Ejecutar     : ./clase02
; ------------------------------------------------------------
;  En la clase 1 el heroe solo HABLABA (write).
;  En la clase 2 el heroe empieza a ESCUCHAR (read):
;  lee el nombre del jugador desde el teclado y lo guarda
;  en memoria. Ahora el programa es interactivo.
; ============================================================

; ------------------------------------------------------------
; default rel: le pide a NASM que genere referencias RELATIVAS
; (RIP-relative) en vez de absolutas. Es la forma moderna de
; direccionar en 64 bits: el binario queda portable y NASM 3.02
; ya emite advertencia si se usa la forma absoluta por defecto.
; ------------------------------------------------------------
default rel

; ------------------------------------------------------------
; SECCION DE DATOS  ->  las frases del heroe (siempre iguales)
; ------------------------------------------------------------
section .data
    titulo    db "LA LEYENDA DEL REGISTRO v0.2", 10
    len_titulo equ $ - titulo
    pregunta  db "Como se llama el heroe? (max 31 letras)", 10
    len_pregunta equ $ - pregunta
    saludo   db "Bienvenido al reino extraordinoario heroe, "
    len_saludo equ $ - saludo
    despedida db "Tu historia esta a punto de comenzar", 10
    len_despedida equ $ - despedida
    salto     db 10                                    ; un salto de linea suelto

; ------------------------------------------------------------
; SECCION .bss  ->  memoria RESERVADA para lo que aün no existe:
;                   el nombre lo va a ESCRIBIR el jugador.
;                   resb = "reserve bytes": el enlazador crea
;                   el espacio, pero no giga bytes en el binario.
; ------------------------------------------------------------
section .bss
    nombre    resb 32        ; 31 letras + 1 byte para el salto de linea
    lon       resq 1         ; 8 bytes (un entero) para la longitud leida

; ------------------------------------------------------------
; SECCION DE CODIGO  ->  las acciones del heroe
; ------------------------------------------------------------
section .text
    global _start

_start:
    ; ---------- Accion 1: mostrar el titulo (igual que clase 1) ----------
    mov rax, 1                ; syscall: sys_write
    mov rdi, 1                ; fd 1 = stdout (pantalla)
    mov rsi, titulo
    mov rdx, len_titulo
    syscall

    ; ---------- Accion 2: preguntar el nombre ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, pregunta
    mov rdx, len_pregunta
    syscall

    ; ---------- Accion 3: LEER el nombre desde el teclado ----------
    ; sys_read: el kernel copia bytes DESDE el fd 0 HASTA nuestro buffer
    mov rax, 0                ; syscall: sys_read
    mov rdi, 0                ; fd 0 = stdin (el teclado)
    mov rsi, nombre           ; buffer .bss donde caen los bytes
    mov rdx, 32               ; a lo sumo 32 bytes (no desbordamos)
    syscall                   ; ¡el kernel escribe en NUESTRA memoria!

    ; Al volver, RAX trae la CANTIDAD REAL de bytes leidos.
    ; Ese valor ES la longitud: la guardamos en memoria.
    mov [lon], rax

    ; ---------- Accion 4: quitar el salto de linea final ----------
    ; El jugador presiono Enter: el ultimo byte leido es 10 (LF).
    ; Lo descontamos para no imprimir un salto de linea doble.
    cmp rax, 0                ; si no lee nada, no hay que revisar
    je .sin_nombre
    cmp byte [nombre + rax - 1], 10
    jne .sin_saltolinea
    dec rax                   ; un byte menos: el LF
    mov [lon], rax
.sin_saltolinea:

    ; ---------- Accion 5: saludar con el nombre ----------
    ; Primero el texto fijo...
    mov rax, 1
    mov rdi, 1
    mov rsi, saludo
    mov rdx, len_saludo
    syscall
    ; ...y luego el nombre. ¡Ojo!: la longitud YA NO viene de
    ; un 'equ' fijo, sino de la memoria donde la guardamos.
    mov rax, 1
    mov rdi, 1
    mov rsi, nombre
    mov rdx, [lon]
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; ---------- Accion 6: despedida ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, despedida
    mov rdx, len_despedida
    syscall

.sin_nombre:
    ; ---------- Accion final: terminar el programa ----------
    mov rax, 60               ; syscall: sys_exit
    mov rdi, 0                ; codigo de salida 0 = todo salio bien
    syscall
