#! /bin/sh
set -evx
git reset --hard
git clean -fdx
git clean -fdx
git pull
cp -v cpu-miner.c.local cpu-miner.c
export NWITH_GETLINE=1
./autogen.sh
NWITH_GETLINE=1 ./configure CPPFLAGS="$CPPFLAGS -DNWITH_GETLINE=1"
make
make install

