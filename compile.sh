#!/bin/bash

PATH=$PATH:bin
64tass -C -a -I inc/ -i ${1}/`basename ${1}`.asm -o ${1}/`basename ${1}`.tmp
echo "====================================="
pucrunch ${1}/`basename ${1}`.tmp ${1}/`basename ${1}`.prg -x 4096 -ffast -m5 
rm ${1}/`basename ${1}`.tmp
