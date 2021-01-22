#! /bin/sh
set -euvx
git reset --hard
git clean -fdx
git clean -fdx
git pull
cp -v cpu-miner.c.local cpu-miner.c
export NWITH_GETLINE=1
./autogen.sh
NWITH_GETLINE=1 ./configure
make
make install

