#! /bin/bash
set -euvxo pipefail
(( ! UID ))
(( ! $#  ))

INSTALL_DEPS=1
BUILD_ZLIB=1
BUILD_CRYPTO=1
BUILD_CURL=1
BUILD_JANSSON=1
USE_PACKER=1
BUILD_STATIC=1

if (( INSTALL_DEPS )) ; then
  deps=(automake autoconf make gcc g++ libtool linux-headers)
  (( BUILD_ZLIB    )) || deps=("${deps[@]}"    zlib-dev)
  (( BUILD_CRYPTO  )) || deps=("${deps[@]}" openssl-dev)
  (( BUILD_CURL    )) || deps=("${deps[@]}"    curl-dev)
  (( BUILD_JANSSON )) || deps=("${deps[@]}" jansson-dev)
  (( USE_PACKER    )) || deps=("${deps[@]}" upx)
  pkg install -y "${deps[@]}"
fi

#export CHOST=i586-alpine-linux-musl
#export CHOST=i386-alpine-linux-musl

PREFIX="${PREFIX:-/data/data/com.termux/files/usr/local}"
#PREFIX="${PREFIX:-/usr/local}"
#PREFIX="${PREFIX:-$HOME}"
#export PATH="$PREFIX/bin:$PATH"
#
LP="$PREFIX/include"
CPPFLAGS="-I$LP ${CPPFLAGS:-}"
CPATH="$LP:${CPATH:-}"
C_INCLUDE_PATH="$LP:${C_INCLUDE_PATH:-}"
CPLUS_INCLUDE_PATH="$LP:${CPLUS_INCLUDE_PATH:-}"
OBJC_INCLUDE_PATH="$LP:${OBJC_INCLUDE_PATH:-}"
unset LP

LP="$PREFIX/lib"
LDFLAGS="-L$LP ${LDFLAGS:-}"
#LDFLAGS="-Wl,$LP $LDFLAGS"
LIBRARY_PATH="$LP:${LIBRARY_PATH:-}"
LD_LIBRARY_PATH="$LP:${LD_LIBRARY_PATH:-}"
LD_RUN_PATH="$LP:${LD_RUN_PATH:-}"
unset LP
#
PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:${PKG_CONFIG_LIBDIR:-}"
PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:${PKG_CONFIG_PATH:-}"
#
export PREFIX
export CPPFLAGS CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH
export LDFLAGS LIBRARY_PATH LD_LIBRARY_PATH LD_RUN_PATH
export PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

CPPFLAGS="${CPPFLAGS:-} -DNDEBUG -DNOASM -DNO_ASM"
#CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -fuse-linker-plugin -flto"
#CFLAGS1="-fuse-linker-plugin -flto"
CFLAGS1=""
if (( BUILD_STATIC )) ; then
  CFLAGS1="$CFLAGS1 -static -static-libgcc -static-libstdc++"
fi
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 $CFLAGS1"
CFLAGS0="-m32 $CFLAGS1"
#CFLAGS0="-march=pentium4 $CFLAGS0"
CFLAGS="${CFLAGS:-} $CFLAGS0"
CXXFLAGS="${CXXFLAGS:-} $CFLAGS0"
#LDFLAGS="${LDFLAGS:-} $CFLAGS1 -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
LDFLAGS="${LDFLAGS:-} $CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS

function github {
	(( $# == 1 ))
	local dir="$(basename "$1")"
	if [[ ! -d "$dir" ]] ; then
		git clone --depth=1 --recursive "https://github.com/$1.git"
		pushd "$dir"
	else
		pushd "$dir"
		git reset --hard
		git clean -fdx
		git clean -fdx
		git pull
	fi
	return $?
}

#if (( BUILD_ZLIB )) && (( BUILD_CRYPTO )) && (( BUILD_CURL )) && (( BUILD_JANSSON )) ; then
#  rm -rf $PREFIX
#fi

if (( BUILD_ZLIB )) ; then
  github madler/zlib
  #[[ -e zlib-1.2.11.tar.gz ]] ||
  #wget                                               https://zlib.net/fossils/zlib-1.2.11.tar.gz
  #rm -rf zlib-1.2.11
  #tar xf zlib-1.2.11.tar.gz
  #pushd  zlib-1.2.11
  ./configure --prefix=$PREFIX --static --const
  make
  make install
  ldconfig
  popd
fi

if (( BUILD_CRYPTO )) ; then
  #github openssl/openssl
  [[ -e openssl-1.1.1i.tar.gz ]] ||
  wget                                                  https://www.openssl.org/source/openssl-1.1.1i.tar.gz
  rm -rf openssl-1.1.1i
  tar xf openssl-1.1.1i.tar.gz
  pushd  openssl-1.1.1i
	#"-D__ANDROID_API__=16"   \
  #./config    \
  ./Configure \
	--prefix="$PREFIX"             \
	threads no-shared zlib             \
	-DOPENSSL_SMALL_FOOTPRINT          \
	-DOPENSSL_USE_IPV6=0               \
	$CPPFLAGS                          \
	no-rmd160 no-sctp no-dso no-ssl2   \
	no-ssl3 no-comp no-idea no-dtls    \
	no-dtls1 no-err no-psk no-srp      \
	no-ec2m no-weak-ssl-ciphers        \
	no-afalgeng no-autoalginit         \
	no-engine no-ec no-ecdsa no-ecdh   \
	no-deprecated no-capieng no-des    \
	no-bf no-dsa no-camellia no-cast   \
	no-gost no-md2 no-md4 no-rc2       \
	no-rc4 no-rc5 no-whirlpool         \
	no-autoerrinit no-blake2 no-chacha \
	no-cmac no-cms no-crypto-mdebug    \
	no-ct no-crypto-mdebug-backtrace   \
	no-dgram no-dtls1-method           \
	no-dynamic-engine no-egd           \
	no-heartbeats no-hw no-hw-padlock  \
	no-mdc2 no-multiblock              \
	no-nextprotoneg no-ocb no-ocsp     \
	no-poly1305 no-rdrand no-rfc3779   \
	no-scrypt no-seed no-srp no-srtp   \
	no-ssl3-method no-ssl-trace no-tls \
	no-tls1 no-tls1-method no-ts no-ui \
	no-unit-test no-whirlpool          \
	no-posix-io no-async no-deprecated \
	no-stdio no-egd                    \
	-static \
    linux-x86
  make
  make install
  ldconfig
  popd
fi

if (( BUILD_CURL )) ; then
##github curl/curl
#	dir="$(basename "curl/curl")"
#	if [[ ! -d "$dir" ]] ; then
#		git clone --depth=1 --recursive -b curl-7_74_0 "https://github.com/curl/curl.git"
#		pushd "$dir"
#	else
#		pushd "$dir"
#		git reset --hard
#		git clean -fdx
#		git clean -fdx
#		git pull
#	fi
#	unset dir
  [[ -e curl-7.74.0.tar.gz ]] ||
  wget                                               https://curl.se/download/curl-7.74.0.tar.gz
  rm -rf curl-7.74.0
  tar xf curl-7.74.0.tar.gz
  pushd  curl-7.74.0
  autoreconf -fi
  ./configure --prefix=$PREFIX \
	--with-zlib="$PREFIX"  \
	--with-ssl="$PREFIX"   \
	--disable-shared           \
	--enable-static            \
	--enable-optimize          \
	--disable-curldebug        \
	--disable-ares             \
	--disable-rt               \
	--disable-ech              \
	--disable-largefile        \
	--enable-http              \
	--disable-ftp              \
	--disable-file             \
	--disable-ldap             \
	--disable-ldaps            \
	--disable-rtsp             \
	--enable-proxy             \
	--disable-dict             \
	--disable-telnet           \
	--disable-tftp             \
	--disable-pop3             \
	--disable-imap             \
	--disable-smb              \
	--disable-smtp             \
	--disable-gopher           \
	--disable-mqtt             \
	--disable-manual           \
	--disable-libcurl-option   \
	--disable-ipv6             \
	--disable-sspi             \
	--disable-crypto-auth      \
	--disable-ntlm-wb          \
	--disable-tls-srp          \
	--disable-unix-sockets     \
	--disable-cookies          \
	--disable-socketpair       \
	--disable-http-auth        \
	--disable-doh              \
	--disable-mine             \
	--disable-dataparse        \
	--disable-netrc            \
	--disable-progress-meter   \
	--disable-alt-svc          \
	--disable-hsts             \
	--without-brotli           \
	--without-zstd             \
	--without-winssl           \
	--without-schannel         \
	--without-darwinssl        \
	--without-secure-transport \
	--without-amissl           \
	--without-gnutls           \
	--without-mbedtls          \
	--without-wolfssl          \
	--without-mesalink         \
	--without-bearssl          \
	--without-nss              \
	--without-libpsl           \
	--without-libmetalink      \
	--without-librtmp          \
	--without-winidn           \
	--without-libidn2          \
	--without-nghttp2          \
	--without-ngtcp2           \
	--without-nghttp3          \
	--without-quiche           \
	--disable-threaded-resolver \
	CPPFLAGS="$CPPFLAGS"       \
	CXXFLAGS="$CXXFLAGS"       \
	CFLAGS="$CFLAGS"           \
	LDFLAGS="$LDFLAGS"         \
	#LIBS='-lz -lcrypto -lssl'
  make
  make install
  ldconfig
  popd
fi

# TODO
if (( BUILD_JANSSON )) ; then
  #github akheron/jansson
  [[ -e jansson-2.13.1.tar.gz ]] ||
  wget https://digip.org/jansson/releases/jansson-2.13.1.tar.gz
  #curl -L --proxy $SOCKS_PROXY -o jansson-2.13.1.tar.gz https://digip.org/jansson/releases/jansson-2.13.1.tar.gz
  rm -rf jansson-2.13.1
  tar xf jansson-2.13.1.tar.gz
  pushd  jansson-2.13.1
  autoreconf -fi
  ./configure --prefix=$PREFIX \
	--disable-shared           \
	--enable-static            \
	CPPFLAGS="$CPPFLAGS"       \
	CXXFLAGS="$CXXFLAGS"       \
	CFLAGS="$CFLAGS"           \
	LDFLAGS="$LDFLAGS"         \
  make
  make install
  ldconfig
  popd
fi

github InnovAnon-Inc/cpuminer-yescrypt
#cp -v cpu-miner.c{.lmaddox-iphone,}
cp -v cpu-miner.c{.local-android,}
./autogen.sh
if (( BUILD_STATIC )) ; then
  export CPPFLAGS="-DCURL_STATICLIB $CPPFLAGS"
fi
./configure --prefix=$HOME \
	--disable-shared           \
	--enable-static            \
	--disable-assembly         \
    --with-crypto=$PREFIX      \
    --with-curl=$PREFIX        \
	CPPFLAGS="$CPPFLAGS" \
	CXXFLAGS="$CXXFLAGS" \
	CFLAGS="$CFLAGS" \
	LDFLAGS="$LDFLAGS"
	#LIBS='-lz -lcrypto -lssl -lcurl -ljansson -lpthread'
make
make install
popd

if (( USE_PACKER )) ; then
  rm -rf $PREFIX/bin
  pushd "$HOME/bin"
  find . \
	\( \! -iname '*.upx' \) \
	-type f                 \
	-exec strip --strip-all {} \;

  for k in * ; do
	[[ -f "$k" ]]             || continue
	[[ ! -e "$k.upx" ]]       ||
	[[ "$k" -nt "$k.upx" ]]   || continue
	[[ "${k/.upx/}" = "$k" ]] || continue
	cp -v "$k" "$k.upx"
	upx --best --overlay=strip "$k.upx" ||
	rm -v "$k.upx"
  done
  popd
fi

ln -sfv "$HOME/bin/cpuminer" "$HOME/cpuminer"
~/cpuminer

##! /bin/sh
#set -evx
#
#CPPFLAGS="$CPPFLAGS -DNDEBUG"
##CFLAGS0="-march=native -mtune=native -fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -Ofast -g0 -fuse-linker-plugin -flto -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all"
#CFLAGS1=""
#CFLAGS0=""
#CFLAGS="$CFLAGS $CFLAGS0"
#CXXFLAGS="$CXXFLAGS $CFLAGS0"
##LDFLAGS="$LDFLAGS -fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -fuse-linker-plugin -flto -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
#LDFLAGS="$LDFLAGS $CFLAGS1"
#unset CLAGS0 CFLAGS1
#export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS
#
#
##CFLAGS="-march=native -mtune=native -Ofast -g0 -fmerge-all-constants"
##LDFLAGS=""
#
#git reset --hard
#git clean -fdx
#git clean -fdx
##git pull
#cp -v cpu-miner.c.local-android cpu-miner.c
#./autogen.sh
#./configure NWITH_GETLINE=1 CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
#make
##make install
#install -bv cpuminer ~/
#
#~/cpuminer
##~/cpuminer &
##cpid=$!
##for k in $(seq 10) ; do
##  sleep 30
##  kill -0 $cpid
##done
##kill $cpid
##wait $cpid || :
##
##make distclean
##./autogen.sh
##./configure NWITH_GETLINE=1 CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
##make
##strip --strip-all cpuminer
##install -bv cpuminer ~/
#




