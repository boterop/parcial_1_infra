# Clase 3 - "Los atributos del heroe"

| | |
|---|---|
| **Objetivo** | El heroe por fin **CUENTA**: reparte 9 puntos entre FUE y AGI, el programa calcula la vida (VID), decide si el heroe es ELITE o NOVATO e imprime los numeros. |
| **Nuevo concepto** | Aritmetica real: `add`, `sub`, `inc`, validacion de entrada, y conversion numero→letra→numero. |
| **Duracion sugerida** | 10-15 minutos |

## Que hace el programa

```
LA LEYENDA DEL REGISTRO v0.3
Tienes 9 puntos para repartir. El resto se vuelve vida (VID).
FUE (fuerza, 0 a 9): AGI (agilidad, 0 a 9): El heroe despierta como ELITE del reino.
FUE: 3
AGI: 5
VID: 1
Puntos gastados: 8
Nivel: 2
Los atributos quedaron grabados en los registros del heroe.
```

Reglas del juego (muy simples a proposito):

- FUE y AGI valen de 0 a 9 (un solo digito).
- Juntos no pueden superar 9 puntos. Si lo intentas, el heroe **no existe**: error y salida 1.
- Lo que no gastas se convierte en vida: `VID = 9 - (FUE + AGI)`.
- Si gastas 6 o mas puntos, el heroe despierta como **ELITE** (nivel 2).
- Si gastas 5 o menos, sigue siendo **NOVATO** (nivel 1).
- Si escribes letras o presionas Enter sin nada, el valor vale 0 (el programa no se rompe).

## Lo nuevo en esta clase (y lo que ya sabias)

### 1. El heroe hace matematicas

```nasm
mov al, [v_fue]      ; al = FUE
add al, [v_agi]      ; al = FUE + AGI  ->  la primera SUMA del curso
mov [v_used], al     ; guardar el total gastado
```

```nasm
mov al, 9
sub al, [v_used]     ; al = 9 - gastado  ->  la RESTA
mov [v_vid], al      ; guardar la vida
```

```nasm
mov byte [v_nivel], 1 ; nivel base: 1
inc byte [v_nivel]    ; +1 si el heroe es ELITE  ->  la INCREMENTACION
```

Tres instrucciones nuevas que van a acompanarte todo el curso: `add`, `sub`, `inc`.
Son tan basicas que casi todos los programas del mundo las usan.

### 2. El heroe VALIDA lo que el usuario escribe

En clase 2 el heroe escucho cualquier cosa. Ahora es mas cuidadoso:

```nasm
mov rax, 0
mov rdi, 0
mov rsi, buf
mov rdx, 2
syscall
cmp rax, 0              ; ¿el usuario presiono Enter sin escribir nada?
je .fue_vacio
cmp byte [buf], 48      ; ¿es '0'?
jb .fue_vacio           ; si es menor, no es un digito
cmp byte [buf], 57      ; ¿es '9'?
ja .fue_vacio           ; si es mayor, tampoco
mov al, byte [buf]
sub al, 48              ; convertir '3' en 3
mov [v_fue], al
jmp .fue_leido
.fue_vacio:
mov byte [v_fue], 0     ; si no es digito, vale 0 (no se rompe)
```

El truco: `48` es `'0'` y `57` es `'9'`. Si la letra esta entre ambas,
es un digito. Si no, el heroe usa 0 y sigue su camino.

### 3. El heroe IMPRIME numeros (no letras)

En clase 1 y 2 el heroe solo hablaba frases fijas. Ahora tiene que mostrar
un numero que el usuario eligio. El truco:

```nasm
mov al, [v_fue]     ; al = 3 (el numero)
add al, 48          ; al = 51 = '3' (la letra)
mov [outd], al      ; guardarlo donde write pueda verlo
mov rax, 1
mov rdi, 1
mov rsi, outd
mov rdx, 1
syscall
```

Es el inverso de la conversion al leer: donde antes se RESTABA 48,
ahora se SUMA 48. El heroe aprendio el camino de ida y de vuelta.

### 4. `resb` y la seccion `.bss`

Los datos del heroe (FUE, AGI, VID) **no existen todavia**: los va a crear
el usuario con el teclado. Por eso no van en `.data` (que es para cosas
fijas), sino en `.bss`:

```nasm
section .bss
    v_fue   resb 1      ; reservo 1 byte para FUE (valdran lo que el usuario diga)
    v_agi   resb 1
    v_vid   resb 1
    v_used  resb 1
    v_nivel resb 1
    outd    resb 1
```

`resb 1` = "reserva 1 byte". No escribe nada, solo aparta espacio.
Cuando el programa lea `mov al, [v_fue]`, ese byte ya tendra valor:
el que el usuario escribio o el que el programa calculo.

### 5. El heroe toma decisiones

```nasm
mov byte [v_nivel], 1
cmp byte [v_used], 6   ; ¿gaste 6 o mas puntos?
jge .elite             ; si, saltar a ELITE
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
```

`cmp` compara dos cosas y deja una "senal" en los registros de estado.
`jge` (jump if greater or equal) salta si la primera es mayor o igual.
Con esto, el heroe ya no hace siempre lo mismo: hace algo distinto
según lo que el usuario le diga.

## El mapa de registros en esta clase

| Registro | Para que lo usa el heroe |
|----------|--------------------------|
| `rax`    | el numero de accion (0, 1, 60) y a veces el valor a imprimir |
| `rdi`    | la "pantalla" (1) o el "teclado" (0) o el codigo de salida |
| `rsi`    | donde esta el texto a mostrar o donde leer |
| `rdx`    | cuantos bytes |
| `al`     | el valor de un solo digito (el heroe cuenta aqui) |
| `[v_fue]` | la fuerza del heroe (en memoria) |
| `[v_agi]` | la agilidad del heroe (en memoria) |
| `[v_vid]` | la vida del heroe (en memoria) |
| `[v_used]` | puntos gastados (en memoria) |
| `[v_nivel]` | el nivel del heroe (en memoria) |

## Ejercicios

1. **El heroe se enfada**: si FUE es 0, muestra la frase
   "Un heroe sin fuerza no es heroe" (y sigue). (Pista: `cmp byte [v_fue], 0`
   y `je`.)
2. **El heroe miente**: imprime el FUE y el AGI **intercambiados**.
   (Pista: en el bloque que imprime FUE, usa `[v_agi]` y viceversa.)
3. **Critico**: si FUE y AGI son iguales, el heroe hace un "critico" y
   duplica su VID (si hay vida para duplicar). (Pista: `cmp byte [v_fue], [v_agi]`
   y `je` a un bloque que hace `add [v_vid], [v_vid]`.)
4. **El heroe se olvida**: si FUE es 9, AGI pasa a valer 0 (el heroe
   gasta todo en fuerza). (Pista: `cmp byte [v_fue], 9` y `je` a un
   bloque que hace `mov byte [v_agi], 0` antes de calcular used.)
5. **El heroe se compara**: en el bloque de resultados, muestra
   "FUE > AGI", "FUE < AGI" o "FUE = AGI" segun el caso.
   (Pista: `cmp byte [v_fue], [v_agi]` con `ja`/`jb`/`je`.)
6. **El heroe duerme**: si el usuario presiona Enter dos veces sin
   escribir nada (FUE y AGI vacios), muestra "El heroe duerme" y sale.
   (Pista: despues de leer, `cmp byte [v_fue], 0` y `cmp byte [v_agi], 0`
   juntos.)
7. **El heroe se celebra**: si el heroe es ELITE, muestra la frase ELITE
   **dos veces** en lugar de una. (Pista: duplicar el bloque `write`
   dentro de `.elite`.)
8. **El heroe se rinde**: si gastas exactamente 9 puntos (VID = 0),
   muestra "El heroe se rinde: no tiene vida" despues de los resultados.
   (Pista: `cmp byte [v_vid], 0` y `je`.)
9. **El heroe se esconde**: si VID es 0, no imprime FUE ni AGI, solo
   el nivel. (Pista: `cmp byte [v_vid], 0` y `je` a un bloque que salta
   los dos primeros `write`.)
10. **El heroe se cuenta al reves**: imprime los 5 datos en orden
    inverso (Nivel, gastados, VID, AGI, FUE). (Pista: recortar y
    pegar los bloques `write` en orden contrario.)

## Preguntas de reflexion

- ¿Por que el heroe valida FUE y AGI por separado (0 a 9), y ademas
  valida la suma (<= 9)? (Pista: cada digito vale de 0 a 9, pero dos
  digitos juntos valen hasta 18. La primera validacion es de formato,
  la segunda es de reglas del juego.)
- ¿Por que `sub al, 48` al leer y `add al, 48` al imprimir? (Pista:
  son el mismo camino en sentido contrario. En memoria vive el numero,
  en pantalla vive la letra.)
- ¿Por que `resb 1` en vez de `db 0` para los atributos? (Pista:
  `db 0` seria "un valor fijo que ya existe". `resb 1` es "un espacio
  reservado para lo que el usuario diga". En ensamblador, la diferencia
  entre dato y variable.)
- ¿Por que `inc byte [v_nivel]` en vez de `add byte [v_nivel], 1`?
  (Pista: `inc` es el caso especial de sumar 1: mas corto y mas claro.
  Cuando sumas 1, usa `inc`. Cuando sumas otra cosa, usa `add`.)
- ¿Por que `cmp` + `jge` y no un `if`? (Pista: en ensamblador no existe
  `if`. Solo existe "comparar y dejar una senal" (`cmp`) y "saltar si
  la senal dice que si" (`jge`). Los `if` de los otros lenguajes son
  azucar sobre esto.)

## Soluciones (spoiler)

<details>
<summary>Ver soluciones</summary>

1. **El heroe se enfada**: despues de leer FUE, antes de pedir AGI:
```nasm
cmp byte [v_fue], 0
jne .con_fuerza
mov rax, 1
mov rdi, 1
mov rsi, sin_fuerza
mov rdx, len_sin_fuerza
syscall
.con_fuerza:
```
(con `sin_fuerza db "Un heroe sin fuerza no es heroe.", 10` en `.data`)

2. **El heroe miente**: en el bloque "FUE: <digito>" cambia
`mov al, [v_fue]` por `mov al, [v_agi]`, y en el bloque "AGI: <digito>"
cambia `mov al, [v_agi]` por `mov al, [v_fue]`. Nada mas.

3. **Critico**: despues de calcular VID:
```nasm
cmp byte [v_fue], [v_agi]
jne .sin_critico
add [v_vid], [v_vid]
mov rax, 1
mov rdi, 1
mov rsi, critico
mov rdx, len_critico
syscall
.sin_critico:
```

4. **El heroe se olvida**: despues de leer AGI, antes de sumar:
```nasm
cmp byte [v_fue], 9
jne .con_agi
mov byte [v_agi], 0
.con_agi:
```
(asi `used = 9 + 0 = 9` y VID = 0, el heroe es ELITE puro)

5. **El heroe se compara**: despues de los 5 datos:
```nasm
cmp byte [v_fue], [v_agi]
ja .fue_mayor
jb .fue_menor
; si llego aqui, son iguales
mov rax, 1
mov rdi, 1
mov rsi, fue_igual
mov rdx, len_fue_igual
syscall
jmp .fin_cmp
.fue_mayor:
mov rax, 1
mov rdi, 1
mov rsi, fue_mayor
mov rdx, len_fue_mayor
syscall
jmp .fin_cmp
.fue_menor:
mov rax, 1
mov rdi, 1
mov rsi, fue_menor
mov rdx, len_fue_menor
syscall
.fin_cmp:
```

6. **El heroe duerme**: despues de leer ambos y validar:
```nasm
cmp byte [v_fue], 0
jne .despierto
cmp byte [v_agi], 0
jne .despierto
mov rax, 1
mov rdi, 1
mov rsi, duerme
mov rdx, len_duerme
syscall
mov rax, 60
mov rdi, 0
syscall
.despierto:
```

7. **El heroe se celebra**: dentro de `.elite`, repite el bloque
`write` de `elite` dos veces (o usa un `jmp` de vuelta al bloque).

8. **El heroe se rinde**: al final, antes de despedirse:
```nasm
cmp byte [v_vid], 0
jne .con_vida
mov rax, 1
mov rdi, 1
mov rsi, rinde
mov rdx, len_rinde
syscall
.con_vida:
```

9. **El heroe se esconde**: al inicio del bloque de resultados:
```nasm
cmp byte [v_vid], 0
jne .muestra_todo
; se esconde: salta FUE y AGI y va directo al nivel
mov rax, 1
mov rdi, 1
mov rsi, niv_lbl
mov rdx, len_niv_lbl
syscall
; ... (imprimir nivel)
jmp .fin_resultados
.muestra_todo:
; ... (bloques normales de FUE, AGI, VID, used, nivel)
.fin_resultados:
```

10. **El heroe se cuenta al reves**: recorta los 5 bloques de
    resultados y pega el de `niv_lbl` primero, despues `used_lbl`,
    `vid_lbl`, `agi_lbl` y por ultimo `fue_lbl`. El codigo de cada
    bloque no cambia, solo su orden.

</details>

## Resumen de la clase

- El heroe ahora **CUENTA**: suma, resta e incrementa.
- El heroe **VALIDA** lo que el usuario escribe (digitos de 0 a 9).
- El heroe **IMPRIME numeros** (convertir numero→letra con `add al, 48`).
- El heroe **TOMA DECISIONES** con `cmp` y `jge`/`jb`/`ja`/`je`.
- Los atributos del heroe viven en `.bss` con `resb 1` (memoria reservada).
- `resb` no escribe nada: solo aparta espacio para lo que el usuario diga.
- `add`, `sub`, `inc` son las tres instrucciones basicas de aritmetica.
- `cmp` es el "if" de ensamblador: compara y deja una senal.
- `jge`, `jb`, `ja`, `je` son los "si" de ensamblador: saltan si la senal dice que si.

## Siguiente clase

En la **clase 4**, el heroe **PIENSA**: combina varios atributos para
calcular un cuarto valor (velocidad = AGI + FUE/2) y decide si puede
atrapar al lobo. El heroe ya no solo cuenta: razona.
