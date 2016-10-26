#!/bin/bash

# abort the script if any commands fail
set -e

# I keep my pucrunch and 64tass binaries in ./bin for simplicity
PATH=$PATH:bin

# Assemble the program into a temporary object file
64tass -C -a -I inc/ -i ${1}/`basename ${1}`.asm -o ${1}/`basename ${1}`.tmp
echo "====================================="

# make the PROGRAMS/ dir if it doesn't exist
[ -d PROGRAMS ] || mkdir PROGRAMS

# generate a .PRG file with pucrunch
basename=`basename ${1}`
pucrunch ${1}/`basename ${1}`.tmp PROGRAMS/${basename^^}.PRG -x 4096 -ffast -m5

# remove the temporary file
rm ${1}/`basename ${1}`.tmp

