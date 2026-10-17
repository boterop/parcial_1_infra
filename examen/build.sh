rm -rf build/
mkdir build/
nasm -f elf64 heroe.asm -o build/heroe.o
ld build/heroe.o -o build/heroe
./build/heroe
