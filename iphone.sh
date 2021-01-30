#! /bin/bash
set -euvxo pipefail
(( ! UID ))
(( ! $#  ))

apk add automake autoconf make gcc g++ zlib-dev openssl-dev curl-dev jansson-dev

#PREFIX="${PREFIX:-/data/data/com.termux/files/usr/local}"
PREFIX="${PREFIX:-/usr/local}"
PREFIX="${PREFIX:-$HOME}"
#export PATH="$PREFIX/bin:$PATH"
#
#LP="$PREFIX/include"
#CPPFLAGS="-I$LP ${CPPFLAGS:-}"
#CPATH="$LP:${CPATH:-}"
#C_INCLUDE_PATH="$LP:${C_INCLUDE_PATH:-}"
#CPLUS_INCLUDE_PATH="$LP:${CPLUS_INCLUDE_PATH:-}"
#OBJC_INCLUDE_PATH="$LP:${OBJC_INCLUDE_PATH:-}"
#unset LP
#
#LP="$PREFIX/lib"
#LDFLAGS="-L$LP ${LDFLAGS:-}"
##LDFLAGS="-Wl,$LP $LDFLAGS"
#LIBRARY_PATH="$LP:${LIBRARY_PATH:-}"
#LD_LIBRARY_PATH="$LP:${LD_LIBRARY_PATH:-}"
#LD_RUN_PATH="$LP:${LD_RUN_PATH:-}"
#unset LP
#
#PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:${PKG_CONFIG_LIBDIR:-}"
#PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:${PKG_CONFIG_PATH:-}"
#
#export PREFIX
#export CPPFLAGS CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH
#export LDFLAGS LIBRARY_PATH LD_LIBRARY_PATH LD_RUN_PATH
#export PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

CONFIG=(./configure --prefix="$PREFIX")

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

if false ; then
#github madler/zlib
[[ -e zlib-1.2.11.tar.gz ]] ||
curl -L                      -o zlib-1.2.11.tar.gz https://zlib.net/fossils/zlib-1.2.11.tar.gz
rm -rf zlib-1.2.11
tar xf zlib-1.2.11.tar.gz
pushd  zlib-1.2.11
"${CONFIG[@]}" --static --const
make
make install
popd
fi

if false ; then
#github openssl/openssl
[[ -e openssl-1.1.1i.tar.gz ]] ||
curl -L                      -o openssl-1.1.1i.tar.gz https://www.openssl.org/source/openssl-1.1.1i.tar.gz
rm -rf openssl-1.1.1i
tar xf openssl-1.1.1i.tar.gz
pushd  openssl-1.1.1i
	#"-D__ANDROID_API__=16"   \
./config    \
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
	-static
make
make install
popd
fi

if false ; then
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
curl -L                      -o curl-7.74.0.tar.gz https://curl.se/download/curl-7.74.0.tar.gz
rm -rf curl-7.74.0
tar xf curl-7.74.0.tar.gz
pushd  curl-7.74.0
autoreconf -fi
"${CONFIG[@]}" \
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
	CC="$CC"                   \
	CXX="$CXX"
	#LIBS='-lz -lcrypto -lssl'
make
make install
popd
fi

if false ; then
#github akheron/jansson
[[ -e jansson-2.13.1.tar.gz ]] ||
wget https://digip.org/jansson/releases/jansson-2.13.1.tar.gz
#curl -L --proxy $SOCKS_PROXY -o jansson-2.13.1.tar.gz https://digip.org/jansson/releases/jansson-2.13.1.tar.gz
rm -rf jansson-2.13.1
tar xf jansson-2.13.1.tar.gz
pushd  jansson-2.13.1
autoreconf -fi
"${CONFIG[@]}" \
	--disable-shared           \
	--enable-static            \
	CPPFLAGS="$CPPFLAGS"       \
	CXXFLAGS="$CXXFLAGS"       \
	CFLAGS="$CFLAGS"           \
	LDFLAGS="$LDFLAGS"         \
	CC="$CC"                   \
	CXX="$CXX"
make
make install
popd
fi

github InnovAnon-Inc/cpuminer-yescrypt
#github tpruvot/cpuminer-multi

#sed -i \
#	-e 's@\(^bool have_stratum = \)false\(;\)@\1true\2@' \
#	-e 's@\(^bool opt_randomize = \)false\(;\)@\1true\2@' \
#	-e 's@\(^static enum algos opt_algo = \)ALGO_SCRYPT\(;\)@\1ALGO_YESCRYPT\2@' \
#	-e 's#\(printf("** " PACKAGE_NAME " " PACKAGE_VERSION " by \)tpruvot@github\( **\n");\)#\1InnovAnon-Inc@protonmail.com\2#' \
#	-e 's@\(printf("BTC donation address: \)1FhDPLPpw18X4srecguG3MxJYe4a1JsZnd (tpruvot)\(\n\n");\)@\119X2uN5AyUUyVGbeNh1tpAi8HzUrgGZhXW (InnovAnon, Inc.)\2@'
#        -e 's@/* parse command line */@
#	rpc_url = strdup ("stratum+tcp://192.168.1.69:3333");
#	short_url = rpc_url + 8;
#	rpc_user = strdup ("");
#	rpc_userpass = strdup ("");@' \
#	cpu-miner.c

#sed -i -f "$PREFIX/cpuminer-multi.sed" cpu-miner.c

# low power settings
#	-e 's@\(^int opt_n_threads = \)0\(;\)@\11\2@'         \
#	-e 's@\(^int64_t opt_affinity = \)-1L\(;\)@\10x01\2@' \
#	-e 's@\(^int opt_priority = \)5\(;\)@\11\2@'          \

# local settings
#	-e 's@\(rpc_url  *= strdup ("stratum+tcp://\)lmaddox.chickenkiller.com:3333\(");\)@\1192.168.1.69\2@' \

#sed -i \
#	-e 's@\(^long opt_proxy_type\) = CURLPROXY_SOCKS5\(;\)@\1\2@' \
#	-e 's@opt_proxy = strdup ("socks5h://127.0.0.1:9050");@@'   \
#	cpu-miner.c
#cp -v cpu-miner.c{.local-nice,}

CPPFLAGS="${CPPFLAGS:-} -DNDEBUG"
#CFLAGS1="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-arcs -pg -fprofile-abs-path -fprofile-dir=$HOME/pg -fuse-linker-plugin -flto"
#CFLAGS1="-fuse-linker-plugin -flto"
CFLAGS1=""
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-march=native -mtune=native -Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants -fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffunction-sections -fdata-sections -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 -ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS1"
#CFLAGS0="-Ofast -g0 $CFLAGS1"
CFLAGS0="$CFLAGS1"
CFLAGS="${CFLAGS:-} $CFLAGS0"
CXXFLAGS="${CXXFLAGS:-} $CFLAGS0"
#LDFLAGS="${LDFLAGS:-} $CFLAGS1 -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
LDFLAGS="${LDFLAGS:-} $CFLAGS1"
unset CLAGS0 CFLAGS1
export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS

#cp -v cpu-miner.c{.lmaddox-iphone,}
cp -v cpu-miner.c{.local,}
./autogen.sh
"${CONFIG[@]}" \
    --prefix=$HOME             \
	--disable-shared           \
	--enable-static            \
	--disable-assembly         \
	CPPFLAGS="$CPPFLAGS" \
	LDFLAGS="$LDFLAGS"         \
	LIBS='-lz -lcrypto -lssl -lcurl -ljansson -lpthread'
make
make install

popd

if false ; then
find "$SCRIPTPATH/bin" \
	\( \! -iname '*.upx' \) \
	-type f                 \
	-exec strip --strip-all {} \;

pushd "$SCRIPTPATH/bin"
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

