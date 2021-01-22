#! /bin/sh
set -evx
git reset --hard
git clean -fdx
git clean -fdx
git pull
cp -v cpu-miner.c.local cpu-miner.c
./autogen.sh
./configure
make
make install

