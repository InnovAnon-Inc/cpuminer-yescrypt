CPUMiner-Multi
==============

[![Build Status](https://travis-ci.org/InnovAnon-Inc/cpuminer-multi.svg)](https://travis-ci.org/InnovAnon-Inc/cpuminer-multi)

This is a multi-threaded CPU miner,
fork of [pooler](//github.com/pooler)'s cpuminer (see AUTHORS for list of contributors).

#### Table of contents

* [Algorithms](#algorithms)
* [Dependencies](#dependencies)
* [Download](#download)
* [Build](#build)
* [Usage instructions](#usage-instructions)
* [Donations](#donations)
* [Credits](#credits)
* [License](#license)

Algorithms
==========
#### Currently supported
 * ✓ __yescrypt__ (GlobalBoostY [BSTY], Unitus [UIS], MyriadCoin [MYR])

#### Implemented, but untested

#### Planned support for
 
Dependencies
============
 * libcurl http://curl.haxx.se/libcurl/
 * jansson http://www.digip.org/jansson/ (jansson source is included in-tree)
 * openssl libcrypto https://www.openssl.org/
 * pthreads
 * zlib (for curl/ssl)

Download
========
 * Windows releases: https://github.com/tpruvot/cpuminer-multi/releases
 * Git tree:   https://github.com/InnovAnon-Inc/cpuminer-multi
   * Clone with `git clone --depth=1 https://github.com/InnovAnon-Inc/cpuminer-multi`

Build
=====

#### Basic *nix build instructions:
 * just use `./build.sh`
 * run the program `./cpuminer`
 * refer to the CIS configs (.travis.yml) for more information.

_OR_

```
 ./autogen.sh	# only needed if building from git repo
 ./nomacro.pl	# only needed if building on Mac OS X or with Clang
 ./configure CFLAGS="*-march=native*" --with-crypto --with-curl
 # Use -march=native if building for a single machine
 make
```

#### System Administration (Optional)
 * Ephemeral settings
   ```
    sysctl -w vm.nr_huge_pages=$(nproc) # TBH, I think this is for RandomX
    sysctl -w kernel.perf_event_paranoid=-1 # for AutoFDO
   ```
 * Persistent settings
   ```
    cat >> /etc/sysctl.conf << EOF
    # ----- BEGIN cpuminer-yescrypt config -----
    # some crypto algos run faster
    vm.nr_huge_pages = $(nproc)
    # perf/autofdo
    kernel.perf_event_paranoid = -1
    # ----- END cpuminer-yescrypt config -----
    EOF
    sysctl -p
   ```

#### Profile-Guided Optimizations
 PGOs offer an average of ~60% speedup for applications.
 (TODO sudo necessary?)
 * Compile the program with code coverage instrumentation.
   This binary may be a little slower and fatter.
   ```
    ./build.sh PGO-1
   ```
 * Run the program under "normal conditions" for some time.
   ```
    sudo ./cpuminer [-o <url>]
   ```
 * Recompile the program using the generated profiles.
   ```
     sudo chown -R $UID /tmp/cpuminer-multi.gcda
     ./build.sh PGO-2
   ```

#### AutoFDO (TODO)
 FDOs are said to be superior to PGOs.
 * just use `./build.sh`
 * Run the program under "normal conditions" for some time.
   ```
    sudo ./cpuminer [-o <url>] & P="$!"
   ```
 * Collect performance counter information.
   ```
    sudo perf record -e br_inst_retired:near_taken -b -o /tmp/cpuminer-multi-perf.data -p "$P"
   ```
 * Convert the perf.data format into profile.afdo format,
   and recompile the program using the collected performance metrics.
   ```
    sudo chown -R $UID /tmp/cpuminer-multi-perf.data
    create_gcov --binary="$PWD/cpuminer" --profile=/tmp/cpuminer-multi-perf.data --gcov=/tmp/cpuminer-multi-profile.afdo
    ./build.sh FDO-2
   ```

#### Note for Debian/Ubuntu users:

```
 apt install automake autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev zlib1g-dev make g++
```

#### Note for OS X users:

```
 brew install openssl curl
 ./build.sh # if curl was installed to /usr/local/opt, else update build.sh paths in darwin section
```

#### Note for pi64 users:

```
 ./autogen.sh
 ./configure --disable-assembly CFLAGS="-Ofast -march=native" --with-crypto --with-curl
```

#### Notes for AIX users:
 * To build a 64-bit binary, export OBJECT_MODE=64
 * GNU-style long options are not supported, but are accessible via configuration file

#### Basic Windows build with Visual Studio 2013
 * All the required .lib files are now included in tree (windows only)
 * AVX enabled by default for x64 platform (AVX2 and XOP could also be used)

#### Basic Windows build instructions, using MinGW64:
 * Install MinGW64 and the MSYS Developer Tool Kit (http://www.mingw.org/)
   * Make sure you have mstcpip.h in MinGW\include
 * install pthreads-w64
 * Install libcurl devel (http://curl.haxx.se/download.html)
   * Make sure you have libcurl.m4 in MinGW\share\aclocal
   * Make sure you have curl-config in MinGW\bin
 * Install openssl devel (https://www.openssl.org/related/binaries.html)
 * In the MSYS shell, run:
   * for 64bit, you can use `./mingw64.sh` else :
     `./autogen.sh	# only needed if building from git repo`
   ```
   LIBCURL="-lcurldll" ./configure CFLAGS="*-march=native*"
   # Use -march=native if building for a single machine
   make
    ```

#### Architecture-specific notes:
 * ARM:
   * No runtime CPU detection. The miner can take advantage of some instructions specific to ARMv5E and later processors, but the decision whether to use them is made at compile time, based on compiler-defined macros.
   * To use NEON instructions, add `-mfpu=neon` to CFLAGS.
 * x86:
   * The miner checks for SSE2 instructions support at runtime, and uses them if they are available.
 * x86-64:	
   * The miner can take advantage of AVX, AVX2 and XOP instructions, but only if both the CPU and the operating system support them.
     * Linux supports AVX starting from kernel version 2.6.30.
     * FreeBSD supports AVX starting with 9.1-RELEASE.
     * Mac OS X added AVX support in the 10.6.8 update.
     * Windows supports AVX starting from Windows 7 SP1 and Windows Server 2008 R2 SP1.
   * The configure script outputs a warning if the assembler doesn't support some instruction sets. In that case, the miner can still be built, but unavailable optimizations are left off.
 * PPC:
   * It's been hacked to compile on PPC. No special optimizations. See build.sh for more information.

Usage instructions
==================
Run `cpuminer --help` to see options.

### Connecting through a proxy

Use the `--proxy` option.

To use a SOCKS proxy, add a socks4:// or socks5:// prefix to the proxy host  
Protocols socks4a and socks5h, allowing remote name resolving, are also available since libcurl 7.18.0.

If no protocol is specified, the proxy is assumed to be a HTTP proxy.  
When the --proxy option is not used, the program honors the http_proxy and all_proxy environment variables.

Donations
=========
Donations for the work done in this fork are accepted :

Tanguy Pruvot :
* BTC: `1FhDPLPpw18X4srecguG3MxJYe4a1JsZnd`

Lucas Jones :
* MRO: `472haywQKoxFzf7asaQ4XKBc2foAY4ezk8HiN63ifW4iAbJiLnfmJfhHSR9XmVKw2WYPnszJV9MEHj9Z5WMK9VCNHaGLDmJ`
* BTC: `139QWoktddChHsZMWZFxmBva4FM96X2dhE`

Credits
=======
CPUMiner-multi was forked from pooler's CPUMiner, and has been started by Lucas Jones.
* [tpruvot](https://github.com/tpruvot) added all the recent features and newer algorythmns
* [Wolf9466](https://github.com/wolf9466) helped with Intel AES-NI support for CryptoNight

License
=======
GPLv2.  See COPYING for details.
Modifications since forking are in the public domain.

