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
