#!/bin/bash

if [ "$OS" = "Windows_NT" ]; then
    ./mingw64.sh
    exit 0
fi

# Linux build

make clean || echo clean

rm -f config.status
./autogen.sh || echo done

# Ubuntu 10.04 (gcc 4.4)
# extracflags="-O3 -march=native -Wall -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"

# Debian 7.7 / Ubuntu 14.04 (gcc 4.7+)
extracflags="$extracflags -Ofast -ftree-loop-if-convert-stores -ftree-vectorize"

if [ ! "0" = `cat /proc/cpuinfo | grep -c avx` ]; then
    # march native doesn't always works, ex. some Pentium Gxxx (no avx)
    extracflags="$extracflags -march=native"
fi

extracflags="$extracflags -g -DSPH_KECCAK_UNROLL=1 -DSPH_CUBEHASH_UNROLL=2 -DSPH_CUBEHASH_NOCOPY=1"

./configure --with-crypto --with-curl CFLAGS="-O2 $extracflags -DUSE_ASM"

make -j 4

strip -s cpuminer
