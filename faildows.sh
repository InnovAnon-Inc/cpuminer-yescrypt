#! /bin/sh
set -evx

CPPFLAGS="-DNDEBUG"
#CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -fuse-linker-plugin -flto"
CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg"
#CFLAGS1="-fuse-linker-plugin -flto"
#CFLAGS1=""
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
CFLAGS="$CFLAGS0"
CXXFLAGS="$CFLAGS0"
#LDFLAGS="$LDFLAGS $CFLAGS1 -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
LDFLAGS="$CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS


#CFLAGS="-march=native -mtune=native -Ofast -g0 -fmerge-all-constants"
#LDFLAGS=""

git reset --hard
git clean -fdx
git clean -fdx
#git pull
cp -v cpu-miner.c.local-nice cpu-miner.c
sed -i 's/-lpthreadGC2/-lpthread/' configure.ac
./autogen.sh
./configure --enable-assembly --with-curl=/usr --with-crypto=/usr CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make
#make install
install -bv cpuminer ~/

~/cpuminer &
cpid=$!
for k in $(seq 11) ; do
  sleep 300
  kill -0 $cpid
done
kill $cpid
wait $cpid || :

CPPFLAGS="-DNDEBUG"
CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-use -fprofile-correction -fprofile-dir=$HOME/pg"
CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
CFLAGS="$CFLAGS0"
CXXFLAGS="$CFLAGS0"
LDFLAGS="$CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS

make distclean
./autogen.sh
./configure --enable-assembly --with-curl=/usr --with-crypto=/usr CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make
strip --strip-all cpuminer
install -bv cpuminer ~/






CPPFLAGS="-DNDEBUG"
CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg"
CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
CFLAGS="$CFLAGS0"
CXXFLAGS="$CFLAGS0"
LDFLAGS="$CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS
cp -v cpu-miner.c.local-android cpu-miner.c
sed -i 's/-lpthreadGC2/-lpthread/' configure.ac
./autogen.sh
./configure --program-suffix=-dedicated --enable-assembly --with-curl=/usr --with-crypto=/usr CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make
#make install
install -bv cpuminer-dedicated ~/

~/cpuminer-dedicated &
cpid=$!
for k in $(seq 11) ; do
  sleep 300
  kill -0 $cpid
done
kill $cpid
wait $cpid || :

CPPFLAGS="-DNDEBUG"
CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-use -fprofile-correction -fprofile-dir=$HOME/pg"
CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
CFLAGS="$CFLAGS0"
CXXFLAGS="$CFLAGS0"
LDFLAGS="$CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS

make distclean
./autogen.sh
./configure --program-suffix=-dedicated --enable-assembly --with-curl=/usr --with-crypto=/usr CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make
strip --strip-all cpuminer-dedicated
install -bv cpuminer-dedicated ~/

