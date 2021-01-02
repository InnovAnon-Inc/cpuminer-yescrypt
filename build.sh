#!/bin/bash
set -euxo pipefail
(( $# == 1 )) || (( $# == 2 ))
[[ -n "$1" ]]
if (( $# == 1 )) ; then
  ARCH='-march=native -mtune=native'
else
  ARCH="-mcpu=$2 -mtune=$2" # TODO
fi

[[ ! -f cpuminer ]] ||
mv -v cpuminer{,.bkf}

if [[ "$1" = PGO-1 ]] ; then
  make distclean || echo clean
else
  make clean # || echo clean
fi

rm -f config.status Makefile.in
./autogen.sh

extracflags="${extracflags:-}"

if [[ "$1" = PGO-1 ]] ; then

  sudo rm -rf /tmp/cpuminer-multi.gcda /tmp/cpuminer-multi *.gcno

  # Linux build

  # Ubuntu 10.04 (gcc 4.4)
  # extracflags="-O3 -march=native -Wall -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"

  # Debian 7.7 / Ubuntu 14.04 (gcc 4.7+)
  extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"
  extracflags="$extracflags -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"
  extracflags="$extracflags $ARCH -g0 -Ofast -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
  #extracflags="-g -O0"
  if (( $# >= 2 )) && [[ "$2" = 7450 ]] ; then
    PGFLAGS="-fprofile-generate=/tmp/cpuminer-multi.gcda -fipa-profile -fprofile-reorder-functions -fvpt -fprofile -fprofile-arcs -fprofile-dir=/tmp/cpuminer-multi"
    CPPFLAGS='-DNOASM'
  else
    PGFLAGS="-fprofile-generate=/tmp/cpuminer-multi.gcda -fipa-profile -fprofile-reorder-functions -fvpt -fprofile -fprofile-abs-path -fprofile-arcs -fprofile-dir=/tmp/cpuminer-multi"
    CPPFLAGS='-DUSE_ASM'
  fi

  #extracflags=
  PGFLAGS=
  #CPPFLAGS=-DNOASM

  #PFLAGS=
  # CFLAGS -pg
  # LDFLAGS -pg
  # -static

  #./configure --with-crypto --with-curl CFLAGS="$extracflags -DUSE_ASM -pg"
  if (( $# >= 2 )) && [[ "$2" = 7450 ]] ; then
    ./configure --with-crypto --with-curl --disable-assembly \
      PGFLAGS="$PGFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$extracflags" \
      LDFLAGS='-static -static-libgcc'
      #LDFLAGS='-lgcov --coverage'
  else
    ./configure --with-crypto --with-curl --enable-assembly \
      PGFLAGS="$PGFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$extracflags" \
      LDFLAGS='-static -static-libgcc'
      #LDFLAGS='-lgcov --coverage'
  fi
  make -j$(nproc)

elif [[ "$1" = PGO-2 ]] ; then

  extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"
  extracflags="$extracflags -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"
  extracflags="$extracflags $ARCH -g0 -Ofast -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
  if (( $# >= 2 )) && [[ "$2" = 7450 ]] ; then
    PGFLAGS="-fprofile-use -fprofile-dir=/tmp/cpuminer-multi"
    CPPFLAGS='-DNOASM'
  else
    PGFLAGS="-fprofile-use -fprofile-dir=/tmp/cpuminer-multi -fprofile-correction"
    CPPFLAGS='-DUSE_ASM'
  fi
  if (( $# >= 2 )) && [[ "$2" = 7450 ]] ; then
    ./configure --with-crypto --with-curl --disable-assembly \
      PGFLAGS="$PGFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$extracflags"
  else
    ./configure --with-crypto --with-curl \
      PGFLAGS="$PGFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$extracflags"
  fi
  make -j$(nproc)
  cp -v cpuminer{,.unstripped}
  strip --strip-all cpuminer
  cp -v cpuminer{,.unpacked}
  upx --all-filters --ultra-brute cpuminer

else exit 1 ; fi

