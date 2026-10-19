# GUION clase 3 - "Los atributos del heroe"

> Duracion: 10-15 minutos. El heroe ya sabe decir hola. Ahora le toca CONTAR.

## 1. La promesa (30 seg)

"En la clase 2 el heroe escucho lo que dijiste y lo guardo. Pero aun no
hizo NADA con lo que guardo. Hoy cambia: le vas a pedir Fuerza y Agilidad,
y el va a calcular su Vida, su Nivel y a decirte si despierto como ELITE
o como NOVATO. Por primera vez, el heroe hace MATEMATICAS."

## 2. El problema (2 min)

Muestra el programa funcionando. Pregunta a la clase:

- "El heroe dijo 'FUE: 3'. ¿De donde saco ese 3? (Del usuario.)
  ¿Donde lo tiene ahora? (En un byte que el usuario lleno.)"
- "El heroe dijo 'VID: 1'. ¿Quien calculo el 1? (El heroe: 9 - 3 - 5.)
  ¿Con que instruccion suma y resta? (add y sub.)"
- "¿Por que el heroe puede ser ELITE o NOVATO? (Porque compara el total
  gastado contra 6.)"

## 3. El nuevo truco: contar con bytes (3 min)

Explica, con el codigo en pantalla:

1. **`add` y `sub` son las primeras matematicas del heroe.**
   `add al, [v_agi]` toma el FUE del byte y le suma el AGI del otro byte.
   El resultado queda en `al`. Es la primera suma del curso.
2. **`inc` es sumar 1 sin escribir el 1.**
   `inc byte [v_nivel]` sube el nivel de 1 a 2. Es el caso especial
   de `add 1`, mas corto y mas claro.
3. **Leer es convertir letra en numero; imprimir es lo contrario.**
   Al leer: `sub al, 48` ('3' - 48 = 3). Al imprimir: `add al, 48`
   (3 + 48 = '3'). El mismo camino, en sentido contrario.
4. **`resb 1` reserva un byte sin escribir nada.**
   Los atributos no existen todavia: los va a crear el usuario.
   Por eso van en `.bss` (reservado) y no en `.data` (fijo).
5. **`cmp` + `jge` son el "if" de ensamblador.**
   `cmp byte [v_used], 6` compara y deja una senal. `jge .elite` salta
   si la senal dice "mayor o igual". No hay `if`; hay comparar y saltar.

## 4. La validacion (2 min)

Muestra el bloque de validacion y pregunta:

- "¿Que pasa si el usuario escribe 'x'? (El heroe lo trata como 0.
  No se rompe: la entrada invalida vale 0.)"
- "¿Que pasa si escribe 5 y 5? (Suma 10, que supera 9. El heroe se
  niega a existir: error y salida 1.)"
- "¿Por que 48 y 57? (Porque '0' vale 48 en ASCII y '9' vale 57.
  Si la letra esta entre ambas, es un digito.)"

## 5. La demostracion (2 min)

Corre el programa 3 veces con entradas distintas:

- `3` y `5` → gastado 8, VID 1, ELITE (gasto 6 o mas).
- `2` y `3` → gastado 5, VID 4, NOVATO (gasto 5 o menos).
- `5` y `5` → gastado 10 > 9 → Error. Salida 1.

Pregunta: "¿Que numero cambia entre las tres ejecuciones? (Todos.)
¿Que numero NUNCA cambia? (El 9: los puntos totales del heroe.)"

## 6. El reto (30 seg)

"El heroe ahora cuenta, valida y decide. En la clase 4 va a PIENSAR:
va a combinar FUE y AGI para calcular un cuarto atributo (Velocidad)
y decidir si puede atrapar al lobo. Para eso va a necesitar `imul`
y `div`. Hasta ahora."

## 7. Que practicar en casa

1. **El heroe se compara**: muestra "FUE > AGI", "FUE < AGI" o
   "FUE = AGI". (El `cmp` + `ja`/`jb`/`je` del ejercicio 5.)
2. **Critico**: si FUE y AGI son iguales, el heroe duplica su VID.
   (El `cmp` + `je` del ejercicio 3.)
3. **El heroe se esconde**: si VID es 0, no imprime FUE ni AGI.
   (El `cmp` + `je` del ejercicio 9.)

## 8. Errores comunes (para el doc)

| Error | Causa | Solucion |
|---|---|---|
| `add al, [v_agi]` no suma lo que espera | `al` no tenia el FUE todavia | `mov al, [v_fue]` antes del `add` |
| El FUE impreso es una letra rara | Olvido `add al, 48` antes de `write` | convertir numero→letra antes de imprimir |
| La validacion deja pasar 'x' | Comparo con `0` en vez de `48` | `cmp byte [buf], 48` y `cmp byte [buf], 57` |
| `resb` no aparece en el binario | Es normal: `.bss` no escribe nada | reservar espacio no es escribir datos |
| El ELITE no se activa con gasto 6 | `jge` apunta al bloque equivocado | verificar que `jge .elite` salta al bloque correcto |
