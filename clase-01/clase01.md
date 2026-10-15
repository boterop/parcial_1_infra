# Clase 01 — Enciende la consola del héroe

**Curso:** Fundamentos de Infraestructura
**Carrera:** Ingeniería de Sistemas — Universidad del Quindío
**Duración sugerida:** 2 horas (teoría + práctica guiada)
**Requisitos:** VM Ubuntu (20.04 / 22.04 / 24.04), acceso a terminal.

---

## 1. ¿Por qué ensamblador y por qué un RPG?

Antes de tocar una sola línea de código, el contrato con los estudiantes:

> Cada línea de ensamblador que escriban esta semana será una
> habilidad del héroe. Al final del curso, el héroe tendrá nombre,
> atributos, un inventario y enemigos que pelear. Cada clase agrega
> una pieza del juego. Nadie "estudia ensamblador": se construye
> *La Leyenda del Registro*.

**Objetivos de la clase 1:**

1. Instalar y usar la cadena de herramientas `nasm` + `ld` + `gcc` en Ubuntu.
2. Entender qué hace el sistema operativo cuando un programa "imprime" un texto.
3. Leer y escribir un programa x86-64 completo: secciones, etiquetas, `mov`, `syscalls`.
4. Compilar, enlazar, ejecutar y **depurar** un binario con `strace` y `objdump`.
5. Cerrar el programa devolviendo un código de salida (la "vida" del proceso).

**Resultado observable:** el programa muestra la pantalla de título del juego y el shell confirma la salida limpia.

---

## 2. Preparación de la VM (15 min, en clase)

En Ubuntu las herramientas de ensamblado no están instaladas por defecto.
Ejecutar en la VM (con contraseña del usuario, si se pide):

```bash
sudo apt update
sudo apt install -y nasm
```

`nasm` (Netwide Assembler) traduce texto ensamblador a binario `.o`.
No hace falta instalar nada más: `ld` (enlazador) y `gcc` llegan con
el sistema en la imagen de Ubuntu para desarrollo.

Verificación rápida:

```bash
nasm --version
ld --version | head -1
```

Se crea la carpeta de trabajo (o se copia la entregada por el profesor):

```bash
mkdir -p ~/ensamblador-rpg/clase-01 && cd ~/ensamblador-rpg/clase-01
```

### Los dos archivos de la clase

| Archivo       | Rol                                        |
|---------------|--------------------------------------------|
| `clase01.asm` | Código fuente: el "guion" del héroe        |
| `compilar.sh` | Receta: cómo convertir el guion en binario |

---

## 3. Teoría mínima indispensable (20 min)

### 3.1 La CPU x86-64 y sus registros

La CPU de la VM tiene registros, memoria de **1 byte (8 bits)** cada uno:

```
RAX  RBX  RCX  RDX  RSI  RDI  RBP  RSP
 64 bits cada uno. La CPU "piensa" en 64 bits; nosotros empezamos
 usando solo los 32 de abajo (EAX, EBX, ...) porque los syscalls
 de 64 bits lo aceptan y evita el dolor de las bandas de 64.
```

Los nombres no son arbitrarios:

- **RAX** — Accumulator. Resultado de la mayoría de operaciones.
- **RDI, RSI, RDX, RCX, R8, R9** — Argumentos de funciones, en ese orden.
- **RSP** — Stack Pointer: dónde termina la pila (el "estante" de memoria
  que el programa usa para guardar datos temporales).
- **RBP** — Base Pointer: referencia fija de la pila.
- **RIP** — Instruction Pointer: la instrucción que se ejecuta AHORA.
  Nadie lo escribe directamente; el enlazador lo mantiene.

### 3.2 Syscalls: cómo se le habla al sistema operativo

Un programa en espacio de usuario **no** puede escribir en la terminal solo.
La terminal, el disco y la red pertenecen al SO. El puente es la
instrucción `syscall` (en x86-64 Linux):

1. Se pone el **número de syscall** en `RAX`.
2. Los **argumentos** en `RDI, RSI, RDX, R10, R8, R9`.
3. Se ejecuta `syscall`. El CPU cambia a modo kernel.
4. Al volver, `RAX` trae el **código de retorno** (o `-1` con `errno`).

Los dos syscalls de esta clase:

| `RAX` | Nombre   | Argumentos                       | Qué hace                          |
|-------|----------|----------------------------------|-----------------------------------|
| 1     | `write`  | `RDI`=fd, `RSI`=buffer, `RDX`=longitud | Escribe bytes a un descriptor de archivo |
| 60    | `exit`   | `RDI`=código                     | Termina el proceso con ese código |

`fd 1` es `STDOUT` (la terminal). `fd 0` es `STDIN`, `fd 2` es `STDERR`.

### 3.3 Secciones de un objeto: `.data` / `.bss` / `.text`

`nasm` organiza el programa en secciones que el enlazador coloca en el binario:

- **`.data`** — datos inicializados (nuestras cadenas de texto).
- **`.bss`** — espacio sin inicializar (variables grandes que valdrán 0).
- **`.text`** — código ejecutable (nuestras instrucciones).

### 3.4 El flujo de un programa en Linux

```
SO crea el proceso → salta a _start (lo provee el enlazador/libc)
  → tu código (main) → syscall 60 (exit) → SO recolecta el código de salida
```

`$?` en bash es exactamente ese código: `0` = éxito, `≠0` = error.
Nuestro héroe "muerde" al SO con el código 0 al final.

---

## 4. El código, línea por línea (40 min, el corazón de la clase)

Abren `clase01.asm`. Se recomienda proyectarlo. Se lee **una línea a la vez**
y se responde la pregunta "¿por qué está aquí?" antes de pasar.

```asm
; ============================================================
;  Clase 01 - La Leyenda del Registro
;  Objetivo: imprimir la pantalla de titulo del juego y salir
;  con codigo de exito (0).
; ============================================================

section .data
    titulo    db "LA LEYENDA DEL REGISTRO v0.1", 10
    len_titulo equ $ - titulo
    mensaje   db "Bienvenido, heroe. Tu aventura empieza aqui.", 10
    len_mensaje equ $ - mensaje
    adios     db "El sistema operativo te despidio con elegancia (código 0).", 10
    len_adios equ $ - adios

section .text
    global _start

_start:
    ; ---------- Accion 1: mostrar el titulo ----------
    mov rax, 1                  ; syscall: sys_write (escribir)
    mov rdi, 1                  ; fd 1 = stdout (la pantalla)
    mov rsi, titulo             ; direccion del texto a imprimir
    mov rdx, len_titulo         ; cuantos bytes escribir
    syscall                     ; ¡llamada al kernel!

    ; ---------- Accion 2: mostrar la bienvenida ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, mensaje
    mov rdx, len_mensaje
    syscall

    ; ---------- Accion 3: despedirse ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, adios
    mov rdx, len_adios
    syscall

    ; ---------- Accion final: terminar ----------
    mov rax, 60                 ; syscall: sys_exit (terminar)
    mov rdi, 0                  ; codigo de salida 0 = exito
    syscall
```

**Preguntas guía durante la lectura** (haz que alguien responda antes de pasar):

1. ¿Qué haría el kernel si `rdx` fuera mayor que la longitud real del texto?
   R/= Imprimiria el texto incompleto
2. ¿Qué cambia entre la Acción 1 y la Acción 3? (Sólo `rsi` y `rdx`: el texto y su tamaño.)
   R/= Cambia espacio de memoria a usar, dando como resultado texto y tamaño distintos
3. ¿Por qué `mov rax, 60` y no `mov rax, 1` en la última acción?
   R/= Porque rax = 1 significa "write" y no "exit", como queremos un exit "bonito" el codigo será 60
4. ¿Qué pasaría si elimináramos la línea `syscall` final? (El proceso seguiría vivo, sin terminar.)
   R/= El proceso seguiría vivo, sin terminar.


---

## 5. Compilar y ejecutar (10 min)

El script `compilar.sh` de esta carpeta hace los 3 pasos de una vez:

```bash
#!/usr/bin/env bash
# Compila y ejecuta el programa de la Clase 1
set -e
echo "== Ensamblando (traduciendo asm -> binario) =="
nasm -f elf64 clase01.asm -o clase01.o
echo "== Enlazando (creando el ejecutable) =="
ld clase01.o -o clase01
echo "== Ejecutando =="
./clase01
echo "== Código de salida: $? =="
```

Detalle: `set -e` hace que el script se detenga en cuanto cualquier comando
falla. Si `nasm` o `ld` no están instalados, `sudo apt install nasm` (Ubuntu).

Salida esperada en la terminal:

```
== Ensamblando (traduciendo asm -> binario) ==
== Enlazando (creando el ejecutable) ==
== Ejecutando ==
LA LEYENDA DEL REGISTRO v0.1
Bienvenido, heroe. Tu aventura empieza aqui.
El sistema operativo te despidio con elegancia (código 0).
== Codigo de salida: 0 ==
```

---

## 6. Verificar que el héroe hizo lo que debía (15 min)

No nos creemos la salida a ciegas. Inspeccionamos el binario y lo que pidió
al kernel.

### 6.1 Ver el código máquina generado

```bash
objdump -d clase01 | grep -A 30 _start
```

Deben verse las 4 llamadas `syscall` (una por cada `syscall` del `.asm`).
Cada una está precedida de `mov` que cargan `rax, rdi, rsi, rdx`.

### 6.2 Ver las secciones de datos

```bash
objdump -s -j .data clase01
```

Muestra los 3 textos tal como están en memoria, incluidos los `\n` finales
(`0a` en hexadecimal).

### 6.3 Espiar el diálogo con el kernel (strace)

```bash
sudo apt install strace        # una sola vez
strace -e trace=write,exit_group ./clase01
```

Salida esperada (números verificados sobre el binario real):

```
write(1, "LA LEYENDA DEL REGISTRO v0.1\n", 29) = 29
write(1, "Bienvenido, heroe. Tu aventura empieza aqui.\n", 45) = 45
write(1, "El sistema operativo te despidio con elegancia (código 0).\n", 60) = 60
exit_group(0) = 0
+ proceso terminado
```

Observación: la despedida mide **60 bytes** y no 59, porque la "ó" de
"código" está acentuada y en UTF-8 ocupa 2 bytes (`c3 b3`). `strace` cuenta
bytes, no letras.

### 6.4 Confirmar el código de salida

```bash
./clase01
echo $?
```

Debe imprimir `0`. `$?` guarda el último código de salida del proceso.

---

## 7. Retos (15 min, trabajo en parejas)

| #   | Reto                                                                                          | Dificultad |
|-----|-----------------------------------------------------------------------------------------------|------------|
| R1  | Cambia el título por "MI GRAN AVENTURA v0.2" y el mensaje de bienvenida por uno propio.       | fácil      |
| R2  | Agrega un cuarto texto (por ejemplo, la frase "Presiona Enter para continuar...") y un `write` más. | medio   |
| R3  | Haz que el programa termine con código de salida `7` en vez de `0`. Verifica con `echo $?`.   | fácil      |
| R4  | Con `strace`, confirma que el número de llamadas `write` crece al agregar el texto de R2.     | medio      |
| R5  | **Estiramiento:** imprime dos veces el mismo texto sin duplicar la línea `db`. (Pista: un solo `equ` de longitud, dos `write`.) | difícil |

Regla de oro de los retos: **cambiar un byte en el texto sin cambiar `rdx`
rompe la salida.** El kernel escribe exactamente `rdx` bytes desde `rsi`.
Si el texto es más largo, imprime basura extra; si es más corto, se corta.

---

## 8. Lo que viene (clase 2)

En clase 1 el héroe **habla**. En clase 2 el héroe **escucha**:

- `sys_read` (syscall 0) para leer el nombre del héroe desde el teclado.
- La sección `.bss` para reservar memoria sin inicializarla (`resb 32`).
- Cómo usar el valor que el kernel devuelve en `RAX` (cuántos bytes leyó).
- Cómo quitar el `\n` que el teclado agrega al presionar Enter.
- Cómo imprimir un texto **dinámico** (el nombre, no un texto fijo).

El héroe deja de ser un hablante y se convierte en un oyente.

---

## 9. Checklist de salida de la clase 1

- [ ] Puedo decir qué hace cada registro (`rax, rdi, rsi, rdx`) en `sys_write`.
- [ ] Sé que `syscall` es la "puerta" al kernel y `rax` el número de acción.
- [ ] Diferencié `.data` (texto fijo) de `.text` (instrucciones).
- [ ] Entendí `equ $ - etiqueta` como "medir la distancia" en bytes.
- [ ] Corrí `./compilar.sh` y vi la salida completa con `código 0`.
- [ ] Usé `objdump -d` y conté las 4 llamadas `syscall`.
- [ ] Usé `strace` y vi los 3 `write` + el `exit_group(0)`.
- [ ] Verifiqué `echo $?` = `0`.
- [ ] Completé al menos R1 y R3.
- [ ] Puedo explicar, sin mirar, por qué la despedida mide 60 bytes.

**Fin de la clase 1.** El héroe ha despertado, ha hablado y ha sido despedido
con elegancia por el sistema operativo. En clase 2 aprenderá a escuchar.
