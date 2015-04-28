#!/bin/bash

64tass -C -T -a -I inc/ -i ${1}/${1}.asm -o ${1}/${1}.tmp
echo "====================================="
pucrunch ${1}/${1}.tmp ${1}/${1}.prg -x 4096 -ffast -m5 
rm ${1}/${1}.tmp
