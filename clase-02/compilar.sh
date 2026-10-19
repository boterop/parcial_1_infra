#!/usr/bin/env bash
# Compila y ejecuta el programa de la Clase 2
set -e
echo "== Ensamblando (traduciendo asm -> binario) =="
nasm -f elf64 clase02.asm -o clase02.o
echo "== Enlazando (creando el ejecutable) =="
ld clase02.o -o clase02
echo "== Ejecutando (escribe el nombre del heroe y presiona Enter) =="
./clase02
echo "== Codigo de salida: $? =="
