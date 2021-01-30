#! /bin/sh
set -evx

CPPFLAGS=""
#CFLAGS="-march=native -mtune=native -fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -Ofast -g0 -fuse-linker-plugin -flto -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
CFLAGS="-march=native -mtune=native -fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -Ofast -g0 -fuse-linker-plugin -flto -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
CXXFLAGS="$CFLAGS"
#LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -fuse-linker-plugin -flto -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -fuse-linker-plugin -flto -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"

git reset --hard
git clean -fdx
git clean -fdx
git pull
cp -v cpu-miner.c.local-android cpu-miner.c
./autogen.sh
./configure NWITH_GETLINE=1 CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make
#make install
install -bv cpuminer ~/

~/cpuminer
#~/cpuminer &
#cpid=$!
#for k in $(seq 10) ; do
#  sleep 30
#  kill -0 $cpid
#done
#kill $cpid
#wait $cpid || :
#
#make distclean
#./autogen.sh
#./configure NWITH_GETLINE=1 CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
#make
#strip --strip-all cpuminer
#install -bv cpuminer ~/
