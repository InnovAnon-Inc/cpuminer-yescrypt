#! /bin/sh
set -evx
git reset --hard
git clean -fdx
git clean -fdx
git pull
cp -v cpu-miner.c.local cpu-miner.c
sed -i 's@^#ifdef NWITH_GETLINE@#if true@' sysinfos.c
./autogen.sh
export NWITH_GETLINE=1
./configure
make
make install

