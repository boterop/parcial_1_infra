# Fundamentos de Infraestructura - Ensamblador

Curso de ensamblador x86-64 (NASM) para "Fundamentos de Infraestructura",
Ingenieria de Sistemas.

Cada clase es una carpeta con:

- **`clase-XX.asm`** - el codigo ensamblado (sin libc, syscalls crudos).
- **`compilar.sh`** - compila y ejecuta la clase.
- **`claseXX.md`** - la explicacion pedagogica de la clase.

Las clases:

- **`clase-01/`** - "El heroe habla" - el heroe imprime su nombre con `write` (syscall 1) y se despide con `exit` (syscall 60).
- **`clase-02/`** - "El heroe escucha" - el heroe aprende `read` (syscall 0) y valida entradas del usuario.
- **`clase-03/`** - "Los atributos del heroe" - el heroe valida FUE/AGI, calcula Vida y Nivel con `add`/`sub`/`inc`, decide ELITE vs NOVATO con `cmp`/`jge` e imprime numeros.

Cada carpeta es independiente. Compila la clase 1 primero, luego la clase 2, y asi sucesivamente.
