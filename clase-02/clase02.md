# Clase 02 — El nombre del héroe

**Curso:** Fundamentos de Infraestructura
**Carrera:** Ingeniería de Sistemas — Universidad del Quindío
**Duración sugerida:** 2 horas (teoría + práctica guiada)
**Requisitos:** Clase 01 completada (cadena `nasm` + `ld` instalada y funcionando).

---

## 1. El contrato de la semana

> En la clase 1 el héroe **despertó**: encendió la consola, mostró su
> título y se despidió con elegancia. Pero un héroe sin nombre no es
> héroe: es un fantasma. Hoy el héroe aprende su segunda habilidad:
> **escuchar**.
>
> Por primera vez, los datos dejan de salir del programa y empiezan a
> **entrar**: el jugador escribe su nombre, el kernel lo copia a la
> memoria del proceso, y el héroe lo saluda por su nombre real.

**Objetivos de la clase 2:**

1. Leer bytes desde el teclado con el syscall `read` (número 0).
2. Usar la sección `.bss` para reservar memoria que el jugador llenará.
3. Guardar un valor de retorno (la longitud leída) **en memoria** y
   leerlo de vuelta: primera vez que el héroe toca una casilla de RAM.
4. Manipular un buffer con cabeza: límite de lectura, salto de línea
   final y protección contra desbordamiento.
5. Ver con `strace` cómo el kernel mueve bytes entre el terminal y
   nuestro proceso.

**Resultado observable:** el programa pregunta el nombre del héroe y
responde *"Bienvenido al reino, <nombre>"* usando exactamente los bytes
que el jugador escribió (ni uno más).

---

## 2. Preparación (5 min)

Todo lo que necesitamos ya está instalado desde la clase 1. Solo hay que
cambiar de campamento:

```bash
cd ~/ensamblador-rpg/clase-02
```

### Los dos archivos de la clase

| Archivo       | Rol                                             |
|---------------|-------------------------------------------------|
| `clase02.asm` | Código fuente: el héroe aprende a escuchar      |
| `compilar.sh` | Receta: ensamblando, enlazando y ejecutando     |

Si en la clase 1 `strace` no estaba disponible, se puede instalar ya
(se usará en la sección 6):

```bash
sudo apt install -y strace
```

---

## 3. Teoría mínima indispensable (25 min)

### 3.1 La tercera sección: `.bss`

En la clase 1 solo usamos dos secciones:

- **`.data`** — datos que ya existen y siempre son iguales (nuestras frases).
- **`.text`** — las instrucciones.

Pero el nombre del héroe **aún no existe**: lo va a crear el jugador, en
tiempo de ejecución. Para eso existe la tercera sección:

- **`.bss`** — *Block Started by Symbol*. Espacio de memoria **reservado**
  pero sin contenido inicial. El enlazador crea el hueco, pero no gasta
  bytes en el binario: una reserva de 1 MB de `.bss` no hace que el
  archivo `.o` pese 1 MB.

La instrucción para reservar espacio es `resb` (*reserve bytes*):

```asm
section .bss
    nombre  resb 32    ; "resérvenme 32 bytes aquí, aún no sé qué serán"
    lon     resq 1     ; y 8 bytes para un entero (la longitud)
```

Regla mnemotécnica:
`db` = **d**efinir **b**ytes (ya sé qué son) · `resb` = **res**ervar **b**ytes (lo decidirán los usuarios).

### 3.2 `sys_read`: los bytes entran al héroe

En la clase 1 aprendimos que `write` (syscall 1) **saca** bytes del
proceso hacia la pantalla. Su gemelo es `read` (syscall 0), que los
**trae** de vuelta desde un descriptor de archivo:

| `RAX` | Nombre  | Argumentos                                  | Qué hace                              |
|-------|---------|---------------------------------------------|---------------------------------------|
| 0     | `read`  | `RDI`=fd, `RSI`=buffer, `RDX`=máx bytes     | Copia bytes del fd al buffer          |
| 1     | `write` | `RDI`=fd, `RSI`=buffer, `RDX`=bytes         | Copia bytes del buffer al fd          |

La simetría es exacta: **los mismos tres registros, la misma `syscall`** —
cambia el número y la dirección del flujo. El "archivo" que hoy leemos es
el teclado:

| fd | Descriptor | Qué es en la terminal |
|----|------------|------------------------|
| 0  | `STDIN`    | lo que el usuario escribe (hoy: el nombre) |
| 1  | `STDOUT`   | lo que el programa muestra |
| 2  | `STDERR`   | errores (llegará en su clase) |

Punto clave que hay que subrayar: **`read` no "pregunta" nada al usuario
por su cuenta**. Lo que hace es simple: "copia hasta N bytes desde el
fd 0 a esta dirección de memoria". El kernel bloquea la instrucción
hasta que hay bytes disponibles (el terminal los entrega cuando el
jugador presiona Enter) y luego **escribe en nuestra RAM**. El usuario
no existe para el syscall: solo hay un buffer, una dirección, una
cantidad.

### 3.3 El valor de retorno: la longitud como variable

`write` no nos devolvía nada útil, pero `read` sí: **al volver de la
`syscall`, `RAX` trae la cantidad real de bytes leídos** (o `-1` si
hubo error). Ese número es oro, porque es la longitud del nombre.

Y aquí viene el cambio de mentalidad de la clase:

```
Clase 1:  mov rdx, len_titulo      ; la longitud era un EQU: una constante
Clase 2:  mov rdx, [lon]          ; la longitud ES un valor en memoria
```

Para que la longitud sobreviva entre syscalls hay que **guardarla en una
casilla de RAM**:

```asm
mov rax, 0
mov rdi, 0
mov rsi, nombre
mov rdx, 32
syscall             ; RAX ahora = bytes leidos (ej. 7 por "Arthas\n")
mov [lon], rax      ; ¡primera escritura en memoria del curso!
```

`[lon]` entre corchetes significa *"el contenido de la casilla cuyo
dirección es `lon`"*. En la clase 1 los corchetes no aparecieron; hoy
son el pan de cada día.

### 3.4 El salto de línea que el jugador trae

Cuando el jugador escribe `Arthas` y presiona Enter, el terminal no
envía 6 bytes: envía **7** — la séptima es el carácter LF (byte `10`),
la marca de "fin de línea". Si no la quitamos, el saludo sale con un
salto de línea extra en medio. La técnica es comparar el **último byte**
leído con `10`:

```asm
cmp byte [nombre + rax - 1], 10   ; ¿el último byte es LF?
jne .sin_saltolinea
dec rax                           ; si es: la longitud real es una menos
```

(El modificador `byte` le dice a NASM que está comparando 1 byte, no 8.)

### 3.5 El escudo del buffer

`read` copiará **hasta** `RDX` bytes, nunca más. Reservamos 32 y leemos
32: si el jugador escribe 200 caracteres, el kernel se queda en 32 y el
resto lo descarta. No hay desbordamiento posible, porque el límite lo
pone *nuestro* código. En los cursos de C esto se llama
"buffer overflow" y es la familia de bugs más explotada de la historia;
aquí el diseño lo evita de gratis.

### 3.6 Nota de herramienta: `default rel`

NASM 3.02 emite una advertencia nueva si no decimos explícitamente cómo
queremos las referencias a memoria:

```
warning: implicit DEFAULT ABS is deprecated
```

El significado: por defecto NASM 64-bit generaba referencias
**absolutas** (la dirección completa de la casilla). La forma moderna,
que NASM adoptará como defecto, es la **relativa** (una distancia desde
la instrucción actual, "RIP-relative"). La línea que encabeza nuestro
`.asm` lo declara:

```asm
default rel
```

No cambia cómo se piensa el código; solo cambia cómo el binario
referencia las casillas de memoria.

---

## 4. El código, línea por línea (40 min, el corazón de la clase)

Abrir `clase02.asm` y leerlo como en la clase 1: una línea a la vez,
respondiendo "¿por qué está aquí?" antes de pasar.

```asm
; ============================================================
;  LA LEYENDA DEL REGISTRO - CLASE 2
;  "El nombre del heroe"
; ============================================================

default rel                 ; referencias RIP-relative (la forma moderna)

section .data
    titulo    db "LA LEYENDA DEL REGISTRO v0.2", 10
    len_titulo equ $ - titulo
    pregunta  db "Como se llama el heroe? (max 31 letras)", 10
    len_pregunta equ $ - pregunta
    saludo   db "Bienvenido al reino, "
    len_saludo equ $ - saludo
    despedida db "Tu nombre ya vive en la memoria del proceso.", 10
    len_despedida equ $ - despedida
    salto     db 10

section .bss
    nombre    resb 32        ; 31 letras + 1 para el LF
    lon       resq 1         ; entero para la longitud leida

section .text
    global _start

_start:
    ; ---------- Accion 1: mostrar el titulo (igual que clase 1) ----------
    mov rax, 1
    mov rdi, 1
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
    mov rax, 0                ; syscall: sys_read
    mov rdi, 0                ; fd 0 = stdin (el teclado)
    mov rsi, nombre           ; buffer .bss donde caen los bytes
    mov rdx, 32               ; a lo sumo 32 bytes (no desbordamos)
    syscall

    ; RAX trae la CANTIDAD REAL de bytes leidos: la guardamos.
    mov [lon], rax

    ; ---------- Accion 4: quitar el salto de linea final ----------
    cmp rax, 0                ; si no leio nada, no hay que revisar
    je .sin_nombre
    cmp byte [nombre + rax - 1], 10
    jne .sin_saltolinea
    dec rax
    mov [lon], rax
.sin_saltolinea:

    ; ---------- Accion 5: saludar con el nombre ----------
    mov rax, 1
    mov rdi, 1
    mov rsi, saludo
    mov rdx, len_saludo
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, nombre
    mov rdx, [lon]            ; ¡la longitud VIENE DE MEMORIA!
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
    ; ---------- Accion final: terminar ----------
    mov rax, 60
    mov rdi, 0
    syscall
```

Preguntas guía durante la lectura:

- ¿Por qué `resb 32` y no `resb 31`? (El Enter del jugador ocupa un byte.)
- ¿Qué pasaría si en la acción 5 usamos `mov rdx, 32` en vez de
  `mov rdx, [lon]`? (Imprimiría 32 bytes: el nombre + basura del buffer.)
- ¿Dónde está la protección contra desbordamiento? (En `mov rdx, 32` de la
  acción 3: el kernel no lee más de eso.)
- ¿Por qué `je .sin_nombre` antes de revisar el último byte? (Si `RAX` es
  0, `nombre + rax - 1` apuntaría *antes* del buffer.)

---

## 5. Compilar y ejecutar (15 min)

La receta es idéntica a la clase 1, cambia solo el nombre de los archivos:

```bash
./compilar.sh
```

```
$ Arthas
LA LEYENDA DEL REGISTRO v0.2
Como se llama el heroe? (max 31 letras)
Bienvenido al reino, Arthas
Tu nombre ya vive en la memoria del proceso.
```

Probemos los tres casos límite (todos deben terminar con código 0):

```bash
echo "Arthas" | ./clase02                      # nombre normal
echo "" | ./clase02                            # solo Enter: nombre vacio
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" | ./clase02
# nombre de 56 letras: el kernel se queda en 32 y el resto se pierde
```

---

## 6. Verificar con strace (15 min)

`strace` espía los syscalls del proceso. Con el nombre `Arthas`:

```bash
echo "Arthas" | strace -e trace=read,write ./clase02 2>&1 | grep -E 'read|write'
```

Salida esperada (los números entre paréntesis son los bytes movidos):

```
write(1, "LA LEYENDA DEL REGISTRO v0.2\n", 29) = 29
write(1, "Como se llama el heroe? (max 31 letras)\n", 40) = 40
read(0, "Arthas\n", 32)                     = 7
write(1, "Bienvenido al reino, ", 21)       = 21
write(1, "Arthas", 6)                       = 6
write(1, "\n", 1)                           = 1
write(1, "Tu nombre ya vive en la memoria del proceso.\n", 45) = 45
```

Leela en voz alta con los estudiantes:

1. Dos `write` a la pantalla (título y pregunta).
2. Un `read` del teclado: pedimos 32, el kernel nos da 7 (6 letras + LF).
3. Cuatro `write` de salida: saludo, **nombre** (6 bytes, sin el LF),
   salto de línea y despedida.

El kernel es un mensajero: los bytes viajan `teclado → memoria del
proceso → pantalla`, y en cada cruce aparece un syscall.

También podemos inspeccionar el objeto ensamblado:

```bash
objdump -d clase02.o | head -40
readelf -r clase02.o
```

La tabla de reubicaciones muestra `R_X86_64_PC32` para las
referencias a `.bss`: la prueba de que `default rel` hizo su trabajo.

---

## 7. Retos (20 min, individual o en parejas)

| #   | Reto                                                                                          | Dificultad |
|-----|-------------------------------------------------------------------------------------------------|------------|
| R1  | Cambia la pregunta y el saludo a una frase tuya. El programa debe seguir funcionando.         | fácil      |
| R2  | Haz que el héroe repita el nombre dos veces seguidas (pista: reutiliza la acción 5).          | fácil      |
| R3  | Quita la acción 4 (la que quita el LF) y observa qué pasa al ejecutar. Vuelve a ponerla.      | fácil      |
| R4  | Cambia `resb 32` por `resb 8` y el `mov rdx, 32` por `mov rdx, 8`. ¿Qué pasa con `echo "Arthas" \| ./clase02`? ¿Y con un nombre de 30 letras? | medio      |
| R5  | Con `strace` verifica que la cantidad que devuelve `read` cambia con la longitud del nombre.  | medio      |
| R6  | **Estiramiento:** si el nombre mide 1 dígito (1–9), imprímelo: guarda `lon + 48` en un buffer de 1 byte y haz un `write` de 1 byte. (48 = código ASCII de `'0'`). | difícil |

R6 es la semilla de la clase 3: convertir números en texto es la
primera "magia" del héroe.

---

## 8. Lo que viene: la clase 3

En la clase 2 el héroe aprendió a escuchar. En la clase 3 aprende a
**contar**:

- Atributos del héroe: **FUE** (fuerza), **AGI** (agilidad), **VID** (vida).
- Instrucciones aritméticas: `inc`, `add`, `sub`, `mov` entre registros.
- Comparar y saltar: `cmp` + `jle`/`jg` — el primer "¿gano o pierdo?".
- Convertir un número en sus dígitos ASCII (el reto R6 se vuelve rutina).

El contrato no cambia: al final del curso, `La Leyenda del Registro`
tendrá nombre, atributos, inventario y enemigos. Ya tiene nombre.

---

## 9. Checklist de salida de la clase

- [ ] El estudiante ejecutó `./compilar.sh` sin warnings de `nasm`.
- [ ] El estudiante leyó el `strace` en voz alta y puede nombrar los tres
      descriptors de archivo.
- [ ] El estudiante puede explicar por qué `resb` y no `db`.
- [ ] El estudiante resolvió al menos R1–R3.
- [ ] El héroe tiene nombre.
