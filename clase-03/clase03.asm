; ============================================================
;  LA LEYENDA DEL REGISTRO - CLASE 3
;  "Los atributos del heroe"
; ------------------------------------------------------------
;  Arquitectura : x86-64 (Intel/AMD de 64 bits)
;  Ensamblador  : NASM (sintaxis Intel)
;  Sistema      : Linux (Ubuntu en VM)
;  Compilar     : nasm -f elf64 clase03.asm -o clase03.o
;  Enlazar      : ld clase03.o -o clase03
;  Ejecutar     : ./clase03
; ------------------------------------------------------------
;  Clase 1: el heroe HABLABA (write).
;  Clase 2: el heroe ESCUCHABA (read).
;  Clase 3: el heroe CUENTA (aritmetica):
;  el jugador reparte 9 puntos entre FUE y AGI, el programa
;  calcula la vida (VID), decide si el heroe despierta ELITE
;  o NOVATO e imprime los numeros.
;
;  Por primera vez el heroe hace algo nuevo: convierte letras
;  en numeros, les hace matematicas (add / sub / inc) y los
;  convierte de vuelta en letras para mostrarselos.
; ============================================================

default rel

; ------------------------------------------------------------
; SECCION DE DATOS  ->  las frases del heroe (siempre iguales)
; ------------------------------------------------------------
section .data
    titulo    db "LA LEYENDA DEL REGISTRO v0.3", 10
    len_titulo equ $ - titulo
    intro     db "Tienes 9 puntos para repartir. El resto se vuelve vida (VID).", 10
    len_intro equ $ - intro
    p_fue     db "FUE (fuerza, 0 a 9): "
    len_p_fue equ $ - p_fue
    p_agi     db "AGI (agilidad, 0 a 9): "
    len_p_agi equ $ - p_agi
    fue_lbl   db "FUE: "
    len_fue_lbl equ $ - fue_lbl
    agi_lbl   db "AGI: "
    len_agi_lbl equ $ - agi_lbl
    vid_lbl   db "VID: "
    len_vid_lbl equ $ - vid_lbl
    used_lbl  db "Puntos gastados: "
    len_used_lbl equ $ - used_lbl
    niv_lbl   db "Nivel: "
    len_niv_lbl equ $ - niv_lbl
    elite     db "El heroe despierta como ELITE del reino.", 10
    len_elite equ $ - elite
    novato    db "El heroe sigue siendo NOVATO: hay margen para crecer.", 10
    len_novato equ $ - novato
    error     db "Error: no te alcanzan los 9 puntos.", 10
    len_error equ $ - error
    final     db "Los atributos quedaron grabados en los registros del heroe.", 10
    len_final equ $ - final
    salto     db 10

; ------------------------------------------------------------
; SECCION .bss  ->  memoria RESERVADA: los numeros del heroe
;                   todavia no existen. El jugador los creara
;                   con el teclado y el programa los calculara.
; ------------------------------------------------------------
section .bss
    buf       resb 2        ; lectura: 1 digito + el LF del Enter
    v_fue     resb 1        ; el numero FUE (0 a 9)
    v_agi     resb 1        ; el numero AGI (0 a 9)
    v_vid     resb 1        ; el numero VID (0 a 9), calculado
    v_used    resb 1        ; puntos gastados: FUE + AGI
    v_nivel   resb 1        ; el nivel del heroe (1 o 2)
    outd      resb 1        ; un digito convertido, listo para write

; ------------------------------------------------------------
; SECCION DE CODIGO  ->  las acciones del heroe
; ------------------------------------------------------------
section .text
    global _start

_start:
    ; ---------- Accion 1: mostrar el titulo ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, titulo
    mov rdx, len_titulo
    syscall

    ; ---------- Accion 2: explicar la regla del juego ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, intro
    mov rdx, len_intro
    syscall

    ; ---------- Accion 3: pedir FUE ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, p_fue
    mov rdx, len_p_fue
    syscall

    ; ---------- Accion 4: LEER y validar FUE (0 a 9) ----------
    ; Si no es un digito, FUE queda en 0 (el heroe no se rompe).
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 2
    syscall
    cmp rax, 0
    je .fue_vacio
    cmp byte [buf], 48
    jb .fue_vacio
    cmp byte [buf], 57
    ja .fue_vacio
    mov al, byte [buf]
    sub al, 48
    mov [v_fue], al
    jmp .fue_leido
.fue_vacio:
    mov byte [v_fue], 0
.fue_leido:

    ; ---------- Accion 5: pedir AGI ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, p_agi
    mov rdx, len_p_agi
    syscall

    ; ---------- Accion 6: LEER y validar AGI (0 a 9) ----------
    ; Mismo ritual que FUE: leer, validar, guardar.
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 2
    syscall
    cmp rax, 0
    je .agi_vacio
    cmp byte [buf], 48
    jb .agi_vacio
    cmp byte [buf], 57
    ja .agi_vacio
    mov al, byte [buf]
    sub al, 48
    mov [v_agi], al
    jmp .agi_leido
.agi_vacio:
    mov byte [v_agi], 0
.agi_leido:

    ; ---------- Accion 7: SUMAR los puntos gastados ----------
    ; used = FUE + AGI. La primera suma real del curso.
    mov al, [v_fue]
    add al, [v_agi]
    mov [v_used], al

    ; ---------- Accion 8: ¿te alcanzan los 9 puntos? ----------
    ; Si gastaste mas de 9, el heroe no puede existir: error.
    cmp byte [v_used], 9
    jbe .puntos_ok
    mov rax, 1
    mov rdi, 1
    mov rsi, error
    mov rdx, len_error
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

.puntos_ok:
    ; ---------- Accion 9: RESTAR para obtener la vida ----------
    ; VID = 9 - used. Lo que no se gasta, se vuelve vida.
    mov al, 9
    sub al, [v_used]
    mov [v_vid], al

    ; ---------- Accion 10: decidir el nivel del heroe ----------
    ; Nivel base 1. Si gastaste 6 o mas, el heroe es ELITE.
    mov byte [v_nivel], 1
    cmp byte [v_used], 6
    jge .elite
    mov rax, 1
    mov rdi, 1
    mov rsi, novato
    mov rdx, len_novato
    syscall
    jmp .fin_nivel
.elite:
    inc byte [v_nivel]
    mov rax, 1
    mov rdi, 1
    mov rsi, elite
    mov rdx, len_elite
    syscall
.fin_nivel:

    ; ---------- Accion 11: imprimir el bloque de atributos ----------
    ; FUE: <digito>
    mov rax, 1
    mov rdi, 1
    mov rsi, fue_lbl
    mov rdx, len_fue_lbl
    syscall
    mov al, [v_fue]
    add al, 48
    mov [outd], al
    mov rax, 1
    mov rdi, 1
    mov rsi, outd
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; AGI: <digito>
    mov rax, 1
    mov rdi, 1
    mov rsi, agi_lbl
    mov rdx, len_agi_lbl
    syscall
    mov al, [v_agi]
    add al, 48
    mov [outd], al
    mov rax, 1
    mov rdi, 1
    mov rsi, outd
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; VID: <digito>
    mov rax, 1
    mov rdi, 1
    mov rsi, vid_lbl
    mov rdx, len_vid_lbl
    syscall
    mov al, [v_vid]
    add al, 48
    mov [outd], al
    mov rax, 1
    mov rdi, 1
    mov rsi, outd
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; Puntos gastados: <digito>
    mov rax, 1
    mov rdi, 1
    mov rsi, used_lbl
    mov rdx, len_used_lbl
    syscall
    mov al, [v_used]
    add al, 48
    mov [outd], al
    mov rax, 1
    mov rdi, 1
    mov rsi, outd
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; Nivel: <digito>
    mov rax, 1
    mov rdi, 1
    mov rsi, niv_lbl
    mov rdx, len_niv_lbl
    syscall
    mov al, [v_nivel]
    add al, 48
    mov [outd], al
    mov rax, 1
    mov rdi, 1
    mov rsi, outd
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, salto
    mov rdx, 1
    syscall

    ; ---------- Accion final: despedida ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, final
    mov rdx, len_final
    syscall

    ; ---------- Accion final: terminar el programa ----------
    mov rax, 60
    mov rdi, 0
    syscall
