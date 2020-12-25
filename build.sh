#!/bin/bash
set -exo pipefail
[[ -n "$1" ]]

make clean || echo clean

rm -f config.status Makefile.in
./autogen.sh

if [[ "$1" = PGO-1 ]] ; then

rm -rf /tmp/cpuminer-multi.gcda /tmp/cpuminer-multi *.gcno

# Linux build

# Ubuntu 10.04 (gcc 4.4)
# extracflags="-O3 -march=native -Wall -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"

# Debian 7.7 / Ubuntu 14.04 (gcc 4.7+)
extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"
extracflags="$extracflags -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"
extracflags="$extracflags -march=native -mtune=native -g0 -Ofast -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
PGFLAGS="-fprofile-generate=/tmp/cpuminer-multi.gcda -fipa-profile -fprofile-reorder-functions -fvpt -fprofile -fprofile-abs-path -fprofile-arcs -fprofile-dir=/tmp/cpuminer-multi -fprofile-reproduciblemultithreaded"
# CFLAGS -pg
# LDFLAGS -pg
# -static

#./configure --with-crypto --with-curl CFLAGS="$extracflags -DUSE_ASM -pg"
./configure --with-crypto --with-curl PGFLAGS="$PGFLAGS" CFLAGS="$extracflags -DUSE_ASM" LDFLAGS='-lgcov --coverage'

elif [[ "$1" = PGO-2 ]] ; then

extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"
extracflags="$extracflags -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"
extracflags="$extracflags -march=native -mtune=native -g0 -Ofast -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
PGFLAGS="-fprofile-use -fprofile-dir=/tmp/cpuminer-multi -fprofile-correction"
./configure --with-crypto --with-curl PGFLAGS="$PGFLAGS" CFLAGS="$extracflags -DUSE_ASM" # LDFLAGS='-lgcov --coverage'

else exit 1 ; fi

make -j$(nproc)
strip --strip-all cpuminer

