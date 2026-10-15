#!/usr/bin/env bash
# Compila y ejecuta clase03.asm (x86-64, Linux).
# Funciona desde cualquier carpeta: cd a su propia ruta.
set -euo pipefail
cd "$(dirname "$0")"
nasm -f elf64 clase03.asm -o clase03.o
ld clase03.o -o clase03
echo "OK: binario 'clase03' generado. Ejecutalo con: ./clase03"
