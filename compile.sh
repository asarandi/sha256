#!/bin/bash
rm -f sha256.o sha256

os=`uname -s`

if [ "$os" == "Linux" ]; then
    nasm -f elf64 sha256.asm
fi

if [ "$os" == "Darwin" ]; then
    nasm -f macho64 sha256.asm
fi

cc -I. main.c sha256.o -o sha256
