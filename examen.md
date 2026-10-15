# Examen — La Leyenda del Registro

**Asignatura:** Fundamentos de Infraestructura
**Unidad:** Ensamblador x86-64 (NASM) — Clases 1, 2 y 3
**Duración:** 90 minutos
**Modalidad:** individual, en la VM de Ubuntu con NASM instalado
**Material permitido:** las carpetas `clase-01/`, `clase-02/`, `clase-03/` y la documentación de syscalls de Linux. **No** se permite internet, IA generativa ni copiar entre estudiantes.

---

## Instrucciones generales

1. Trabaja dentro de tu propia carpeta de examen. Copia las tres clases a `examen/clase-01`, `examen/clase-02`, `examen/clase-03`.
2. **Cada entrega es un archivo.** Donde se pide "muestra", pega la salida real entre bloques de código. No inventes salidas: el profesor puede re-ejecutar tu binario.
3. **Parte práctica:** los artefactos (salidas, `strace`, código modificado, binarios) van en `examen/entrega.md` (creas tú este archivo).
4. **Preguntas conceptuales** (tanto de la Parte A como de la B) se responden directamente en este documento, dentro de los bloques `[RESOLVER AQUÍ]`.
5. Al final, entrega: tu carpeta `examen/` con los `.asm`, los binarios, `entrega.md` y este `examen.md` con las respuestas.

**Criterio de aprobación:** ≥ 70% de la nota total. Cada sección indica su puntaje.

---

# PARTE A — PRÁCTICA: seguir y ejecutar las clases (60 pts)

> Regla de oro: si algo no compila, no pasa a la siguiente. **No se acepta "no compiló" como respuesta.**
> Documenta el error completo y el intento de solución.

---

## A.1 — El despertar (Clase 1) — 10 pts

### A.1.1 (4 pts)
Compila y ejecuta la clase 1. Documenta en `entrega.md`:

- El comando exacto de compilación y el de enlazado.
- La salida completa del programa.
- El código de salida (`echo $?`).

### A.1.2 (6 pts)
Ejecuta `strace -e trace=write,exit_group ./clase01 2> trace1.txt` y responde (pega también el
`strace` en `entrega.md`):

1. ¿Cuántas llamadas `write` hay en total?
2. ¿Cuál es el código de salida que devuelve `exit_group`?
3. ¿Qué número de syscall usa `write`? (pista: mira la columna `syscall` o el `strace` completo).

[RESOLVER AQUÍ: ]

1. Hay 5 llamadas a `write` en total.
2. El codigo de salida del exit_group es 7.
3. El numero de syscall que usa write es 1.
---

## A.2 — El nombre del héroe (Clase 2) — 15 pts

### A.2.1 (5 pts)
Compila y ejecuta la clase 2 con **tres** nombres distintos:

1. Un nombre corto (≤ 5 letras).
2. Un nombre de **exactamente 31** letras.
3. Un nombre de **40** letras.

Documenta la salida de cada caso en `entrega.md`.

[RESOLVER AQUÍ: ¿Qué ocurre en el caso 3? Explica por qué, citando qué línea del `.asm` lo provoca.]

### A.2.2 (5 pts)
Ejecuta `strace -e trace=read,write ./clase02` con un nombre de 10 letras (pega el `strace` en `entrega.md`) y responde:

1. ¿Cuántos bytes devuelve la llamada `read`?
2. ¿Por qué ese número y no 32 (el tamaño del buffer)?
3. ¿En qué variable del código se guarda ese valor de retorno?

[RESOLVER AQUÍ: ]

### A.2.3 (5 pts) — Modificación obligatoria
En tu copia de `clase02.asm`, cambia **dos** cosas y haz que siga compilando y ejecutando:

1. Cambia el saludo (`saludo`) a una frase tuya (debe incluir "reino" o "heroe").
2. Cambia la despedida (`despedida`) a una frase tuya.

Pega en `entrega.md` el bloque `.data` modificado y la salida de tu programa con el nombre `Gandalf`.

---

## A.3 — Los atributos del héroe (Clase 3) — 20 pts

### A.3.1 (8 pts)
Compila la clase 3 y ejecútala con las **cinco** combinaciones de (FUE, AGI) de la tabla. Completa la tabla con la salida real (ELITE / NOVATO / ERROR) y el código de salida:

| Caso | FUE | AGI | ¿ELITE o NOVATO o ERROR? | Código salida (`$?`) |
|------|-----|-----|--------------------------|----------------------|
| 1    | 3   | 5   |                          |                      |
| 2    | 0   | 9   |                          |                      |
| 3    | 9   | 9   |                          |                      |
| 4    | 0   | 0   |                          |                      |
| 5    | `x` | 5   |                          |                      |

> Caso 5: en lugar de un dígito, escribe la letra `x`.

[RESOLVER AQUÍ: ¿Qué hace el programa con la letra `x`? ¿Por qué no se rompe?]

### A.3.2 (6 pts)
Con `strace -e trace=write,read,exit_group ./clase03`, usando FUE=8, AGI=2 (pega el `strace` en `entrega.md`), responde:

1. ¿Cuántas llamadas `write` hay? Enuméralas (qué texto escribe cada una).
2. ¿Cuántas llamadas `read` hay?
3. ¿Por qué `read` devuelve siempre `2` y no `1`?

[RESOLVER AQUÍ: ]

### A.3.3 (6 pts) — Modificación obligatoria
Implementa el **Ejercicio 1** de la clase 3 ("El heroe se enfada"): si FUE es 0, muestra la frase
`"Un heroe sin fuerza no es heroe."` y sigue el flujo normal.

Requisitos:

- Usa `cmp byte [v_fue], 0` y un salto `je` a un bloque nuevo `.sin_fuerza`.
- El programa debe seguir imprimiendo el bloque de atributos y terminar con código 0.
- Pega en `entrega.md` las líneas que agregaste y la salida completa con FUE=0, AGI=3.

---

## A.4 — Crear desde cero (15 pts)

Escribe un programa **nuevo** (`examen/heroe.asm`) **sin usar libc** que:

1. Imprima `"Nombre: "` (sin salto de línea).
2. Lea el nombre desde el teclado (buffer de 16 bytes en `.bss`).
3. Imprima el nombre.
4. Imprima un salto de línea.
5. Termine con código de salida 0.

Compílalo con `nasm -f elf64` y `ld`. Pega en `entrega.md` el código completo y la salida al ejecutarlo con el nombre `Sauron`.

> No copies la clase 2: el programa debe ser más corto (solo 4 `write`/`read` + `exit`).

---

# PARTE B — TEORÍA: preguntas (40 pts)

> Responde dentro de los bloques `[RESOLVER AQUÍ]`.
> Se valora **explicar con tus palabras**, no solo la respuesta correcta.

---

## B.1 — Selección múltiple (5 pts, 1 pt c/u)

**1.** ¿Cuál es el número de syscall de `sys_write` en Linux x86-64?

- a) 0
- b) 1
- c) 60
- d) 2

[RESOLVER AQUÍ: ]

---

**2.** ¿En qué registro se pone el **número de syscall** antes de ejecutar `syscall`?

- a) `rdi`
- b) `rsi`
- c) `rax`
- d) `rdx`

[RESOLVER AQUÍ: ]

---

**3.** ¿Qué sección usa `resb` para reservar memoria sin ocuparla en el binario?

- a) `.data`
- b) `.text`
- c) `.bss`
- d) `.rodata`

[RESOLVER AQUÍ: ]

---

**4.** ¿Qué valor de retorno trae `rax` después de un `sys_read`?

- a) 0 siempre
- b) La cantidad de bytes leídos realmente
- c) El tamaño del buffer
- d) El código de error

[RESOLVER AQUÍ: ]

---

**5.** En clase 3, ¿qué instrucción decide entre ELITE y NOVATO?

- a) `add`
- b) `inc`
- c) `cmp` + `jge`
- d) `sub`

[RESOLVER AQUÍ: ]

---

## B.2 — Verdadero o Falso con justificación (10 pts, 2 pts c/u)
> Marca V o F. Si es F, escribe la corrección. Una respuesta correcta sin justificación vale 1 pt.

**1.** `db` declara 8 bits (1 byte) por elemento de datos.
[RESOLVER AQUÍ: ]

---

**2.** `mov rax, 60` seguido de `syscall` es la forma estándar de terminar un programa en este curso.
[RESOLVER AQUÍ: ]

---

**3.** `resb 32` escribe 32 bytes de ceros en el binario.
[RESOLVER AQUÍ: ]

---

**4.** En clase 2, el valor de `lon` (la longitud leída) viene de un `equ` fijo calculado por el ensamblador.
[RESOLVER AQUÍ: ]

---

**5.** `add al, 48` convierte un dígito numérico (0–9) en su carácter ASCII imprimible.
[RESOLVER AQUÍ: ]

---

## B.3 — Lectura de código: predice la salida (6 pts)

Dado este fragmento (un programa mínimo y completo):

```asm
section .data
    msg db "HOLA", 10
    len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall
    mov rax, 60
    mov rdi, 3
    syscall
```

1. ¿Qué imprime el programa? (2 pts)
2. ¿Con qué código de salida termina? ¿Qué significa ese código? (2 pts)
3. ¿Cuántas llamadas al kernel (`syscall`) hay? (2 pts)

[RESOLVER AQUÍ: ]

---

## B.4 — Encuentra el error (4 pts)

El siguiente código **debería** imprimir `7` pero **no lo hace**. Encuentra el error, explícalo y escribe la línea corregida.

```asm
section .bss
    d resb 1

section .text
    global _start
_start:
    mov al, 7          ; el número a imprimir
    mov [d], al        ; guardar el carácter
    mov rax, 1
    mov rdi, 1
    mov rsi, d
    mov rdx, 1
    syscall
    mov rax, 60
    mov rdi, 0
    syscall
```

> Pista: el programa **debería** imprimir el carácter `7` en pantalla.
> ¿Qué byte está guardando realmente en `d`? ¿Qué instrucción de la
> clase 3 está ausente para que un número (0–9) se vuelva un carácter
> imprimible?

[RESOLVER AQUÍ: ]

---

## B.5 — Respuesta corta (10 pts, 2.5 pts c/u)

**1.** ¿Por qué en clase 2 se reserva `resb 32` para un nombre de "máximo 31 letras"?

[RESOLVER AQUÍ: ]

---

**2.** ¿Por qué la clase 2 quita el último byte (LF) del nombre antes de imprimirlo, usando `dec rax`?

[RESOLVER AQUÍ: ]

---

**3.** En clase 3, ¿por qué el programa valida FUE y AGI por separado (0–9) **y además** valida que la suma sea ≤ 9?

[RESOLVER AQUÍ: ]

---

**4.** ¿Qué significa `equ $ - etiqueta` y por qué es útil en vez de contar los bytes a mano?

[RESOLVER AQUÍ: ]

---

## B.6 — Escribe el código (5 pts)

**1. (2 pts)** Escribe el bloque exacto (registros + `syscall`) para **imprimir la cadena**
`"FIN\n"` (con salto de línea) usando `sys_write`. Supón que la cadena está en la etiqueta `fin` y su longitud en `len_fin`.

[RESOLVER AQUÍ: ]

---

**2. (3 pts)** Escribe las líneas de ensamblador para:

- Leer hasta **2 bytes** (1 dígito + el LF del Enter) desde el teclado en un buffer `b` (de `.bss`), usando `sys_read` — igual que la clase 3.
- Validar que sea un dígito entre `'0'` (48) y `'9'` (57); si no lo es, saltar a una etiqueta `.mal`.
- Si es dígito, convertirlo a número (restando 48) y guardarlo en la variable numérica `n` (1 byte, de `.bss`).

[RESOLVER AQUÍ: ]

---

# RÚBRICA DE CALIFICACIÓN

| Sección | Tema | Puntos |
|---------|------|--------|
| A.1 | Clase 1: compilar, ejecutar, strace | 10 |
| A.2 | Clase 2: leer, buffer, modificación | 15 |
| A.3 | Clase 3: atributos, validación, modif. | 20 |
| A.4 | Crear desde cero | 15 |
| **Parte A** | **Práctica** | **60** |
| B.1 | Selección múltiple | 5 |
| B.2 | Verdadero/Falso (5 × 2) | 10 |
| B.3 | Predicción de salida (3 × 2) | 6 |
| B.4 | Encontrar el error (1 pregunta) | 4 |
| B.5 | Respuesta corta (4 × 2.5) | 10 |
| B.6 | Escribir código (2 + 3) | 5 |
| **Parte B** | **Teoría** | **40** |
| **TOTAL** | | **100** |

> **Nota final = (puntos obtenidos / 100) × 20.**
> Aprobación: ≥ 14/20 (es decir, ≥ 70% = 70 pts).

---

# CHECKLIST DE ENTREGA

Antes de entregar, verifica que tu carpeta `examen/` contenga:

- [ ] `clase-01/clase01.asm`, `clase-01/clase01` (binario), `clase-01/trace1.txt`
- [ ] `clase-02/clase02.asm` (modificado), `clase-02/clase02` (binario)
- [ ] `clase-03/clase03.asm` (modificado), `clase-03/clase03` (binario)
- [ ] `heroe.asm` y `heroe` (binario)
- [ ] `entrega.md` con todas las salidas y modificaciones pegadas
- [ ] Este `examen.md` con todos los bloques `[RESOLVER AQUÍ]` respondidos
- [ ] `strace` guardados donde se pidieron

**Recuerda:** el héroe del examen no es el que más rápido termina, sino el que
puede explicar cada línea que escribió.
