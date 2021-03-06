FROM innovanon/doom-base as builder

USER root
RUN sleep 91            \
 && apt update          \
 && apt full-upgrade -y \
 && apt install      -y clang llvm polygen

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

#ENV CHOST=x86_64-pc-linux-gnu
#ENV CC=$CHOST-gcc
#ENV CXX=$CHOST-g++
##ENV FC=$CHOST-gfortran
#ENV NM=$CC-nm
#ENV AR=$CC-ar
#ENV RANLIB=$CC-ranlib
#ENV STRIP=$CHOST-strip
#ENV LD=$CHOST-ld
#ENV AS=$CHOST-as

ENV CHOST=x86_64-linux-gnu

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

ENV PREFIX=/usr/local
#ENV PREFIX=/opt/cpuminer
ENV CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
ENV CPATH="$PREFIX/incude:$CPATH"
ENV    C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH"
ENV OBJC_INCLUDE_PATH="$PREFIX/include:$OBJC_INCLUDE_PATH"

ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV    LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
ENV     LD_RUN_PATH="$PREFIX/lib:$LD_RUN_PATH"

ENV PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR"
ENV PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:$PKG_CONFIG_PATH"

ARG ARCH=native
ENV ARCH="$ARCH"

ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer  $CFLAGS"
ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer $LDFLAGS"

# Debug
ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# Static
#ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
#ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
#ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
# TODO
#ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"
ENV CFLAGS="$CLANGFLAGS"

ENV CLANGXXFLAGS="$CLANGFLAGS $CXXFLAGS"
ENV CXXFLAGS="$CFLAGS $CXXFLAGS"

WORKDIR /tmp

RUN ls -ltra

COPY ./llvm.grm ./
RUN command -v "$CC"                               \
 \
 && FLAG=0                                         \
  ; for k in $(seq 1009) ; do                      \
      /usr/games/polygen -pedantic -o fingerprint.bc llvm.grm \
   || continue                                     \
    ; clang -c -o fingerprint.o                    \
        fingerprint.bc -static                     \
   || continue                                     \
    ; ar vcrs libfingerprint.a fingerprint.o       \
   || continue                                     \
    ; FLAG=1                                       \
    ; break                                        \
  ; done                                           \
 && test "$FLAG" -ne 0                             \
 && install -v -D {,"$PREFIX/lib/"}libfingerprint.a    \
 && test -d "$PREFIX"                              \
 && ldconfig

RUN sleep 91                                 \
 && git clone --depth=1 --recursive          \
      https://github.com/madler/zlib.git     \
 && cd                          zlib         \
 && ./configure --prefix=$PREFIX             \
      --const --static --64                  \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd .. \
 && ldconfig

RUN sleep 91 \
 && chown -R root:root . \
 && ls -ltra \
 && git clone --depth=1 --recursive          \
      https://github.com/akheron/jansson.git \
 && cd                           jansson     \
 && chown -R root:root . \
 && ls -ltra \
 && autoreconf -fi                           \
 && ./configure --prefix=$PREFIX             \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--disable-shared                     \
	--enable-static                      \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd ..                                    \
 && cd $PREFIX                               \
 && rm -rf etc man share ssl \
 && ldconfig

#ENV CC=
#ENV CXX=
##ENV FC=
#ENV NM=
#ENV AR=
#ENV RANLIB=
#ENV STRIP=
#ENV LD=
#ENV AS=
        #--cross-compile-prefix=$CHOST-                \
#	no-rmd160 no-sctp no-dso no-ssl2              \
#	no-ssl3 no-comp no-idea no-dtls               \
#	no-dtls1 no-err no-psk no-srp                 \
#	no-ec2m no-weak-ssl-ciphers                   \
#	no-afalgeng no-autoalginit                    \
#	no-engine no-ec no-ecdsa no-ecdh              \
#	no-deprecated no-capieng no-des               \
#	no-bf no-dsa no-camellia no-cast              \
#	no-gost no-md2 no-md4 no-rc2                  \
#	no-rc4 no-rc5 no-whirlpool                    \
#	no-autoerrinit no-blake2 no-chacha            \
#	no-cmac no-cms no-crypto-mdebug               \
#	no-ct no-crypto-mdebug-backtrace              \
#	no-dgram no-dtls1-method                      \
#	no-dynamic-engine no-egd                      \
#	no-heartbeats no-hw no-hw-padlock             \
#	no-mdc2 no-multiblock                         \
#	no-nextprotoneg no-ocb no-ocsp                \
#	no-poly1305 no-rdrand no-rfc3779              \
#	no-scrypt no-seed no-srp no-srtp              \
#	no-ssl3-method no-ssl-trace no-tls            \
#	no-tls1 no-tls1-method no-ts no-ui            \
#	no-unit-test no-whirlpool                     \
#	no-posix-io no-async no-deprecated            \
#	no-stdio no-egd                               \
RUN sleep 91                                          \
 && GIT_TRACE=true \
    git clone --depth=1 --recursive -b OpenSSL_1_1_1i \
      https://github.com/openssl/openssl.git          \
 && cd                           openssl              \
 && ./Configure --prefix=$PREFIX                      \
        threads no-shared zlib                        \
	-static                                       \
        -DOPENSSL_SMALL_FOOTPRINT                     \
        -DOPENSSL_USE_IPV6=0                          \
        linux-x86_64                                  \
 && make                                              \
 && make install                                      \
 && git reset --hard                                  \
 && git clean -fdx                                    \
 && git clean -fdx                                    \
 && cd .. \
 && ldconfig

RUN ls -ltra $PREFIX/lib
RUN ls -ltra $PREFIX/lib | grep libcrypto.a

#ENV CC=$CHOST-gcc
#ENV CXX=$CHOST-g++
##ENV FC=$CHOST-gfortran
#ENV NM=$CC-nm
#ENV AR=$CC-ar
#ENV RANLIB=$CC-ranlib
#ENV STRIP=$CHOST-strip
#ENV LD=$CHOST-ld
#ENV AS=$CHOST-as
RUN test -n "$PREFIX"                              \
 \
 && sleep 91                                          \
 && git clone --depth=1 --recursive -b curl-7_74_0    \
      https://github.com/curl/curl.git                \
 && cd                        curl                    \
 && autoreconf -fi                                    \
 && ./configure --prefix=$PREFIX                      \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--with-zlib="$PREFIX"                         \
	--with-ssl="$PREFIX"                          \
        --disable-shared                              \
	--enable-static                               \
	--enable-optimize                             \
	--disable-curldebug                           \
	--disable-ares                                \
	--disable-rt                                  \
	--disable-ech                                 \
	--disable-largefile                           \
	--enable-http                                 \
	--disable-ftp                                 \
	--disable-file                                \
	--disable-ldap                                \
	--disable-ldaps                               \
	--disable-rtsp                                \
	--enable-proxy                                \
	--disable-dict                                \
	--disable-telnet                              \
	--disable-tftp                                \
	--disable-pop3                                \
	--disable-imap                                \
	--disable-smb                                 \
	--disable-smtp                                \
	--disable-gopher                              \
	--disable-mqtt                                \
	--disable-manual                              \
	--disable-libcurl-option                      \
	--disable-ipv6                                \
	--disable-sspi                                \
	--disable-crypto-auth                         \
	--disable-ntlm-wb                             \
	--disable-tls-srp                             \
	--disable-unix-sockets                        \
	--disable-cookies                             \
	--disable-socketpair                          \
	--disable-http-auth                           \
	--disable-doh                                 \
	--disable-mine                                \
	--disable-dataparse                           \
	--disable-netrc                               \
	--disable-progress-meter                      \
	--disable-alt-svc                             \
	--disable-hsts                                \
	--without-brotli                              \
	--without-zstd                                \
	--without-winssl                              \
	--without-schannel                            \
	--without-darwinssl                           \
	--without-secure-transport                    \
	--without-amissl                              \
	--without-gnutls                              \
	--without-mbedtls                             \
	--without-wolfssl                             \
	--without-mesalink                            \
	--without-bearssl                             \
	--without-nss                                 \
	--without-libpsl                              \
	--without-libmetalink                         \
	--without-librtmp                             \
	--without-winidn                              \
	--without-libidn2                             \
	--without-nghttp2                             \
	--without-ngtcp2                              \
	--without-nghttp3                             \
	--without-quiche                              \
	--disable-threaded-resolver                   \
	CPPFLAGS="$CPPFLAGS"                          \
	CXXFLAGS="$CXXFLAGS"                          \
	CFLAGS="$CFLAGS"                              \
	LDFLAGS="$LDFLAGS"                            \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
 && make                                              \
 && make install                                      \
 && git reset --hard                                  \
 && git clean -fdx                                    \
 && git clean -fdx                                    \
 && cd ..                                             \
 && rm -v $PREFIX/bin/*curl* \
 && ldconfig
 
RUN ls -ltra $PREFIX/lib
RUN ls -ltra $PREFIX/lib | grep libcrypto.a

#RUN sleep 91 \
# && git clone --depth=1 --recursive                   \
#      https://github.com/InnovAnon-Inc/cpuminer-yescrypt.git \
COPY ./ ./cpuminer-yescrypt
RUN cd                                 cpuminer-yescrypt     \
 && ./autogen.sh                                             \
 && ./configure --prefix=$PREFIX                             \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--disable-shared                                     \
	--enable-static                                      \
	--enable-assembly                                    \
        --with-curl=$PREFIX                                  \
        --with-crypto=$PREFIX                                \
	CPPFLAGS="-DCURL_STATICLIB $CPPFLAGS"                \
	CXXFLAGS="$CXXFLAGS"                                 \
	CFLAGS="$CFLAGS"                                     \
	LDFLAGS="$LDFLAGS"                                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        LIBS='-lz -lcrypto -lssl -lcurl -ljansson' \
 && cd $PREFIX                                               \
 && rm -rf etc man share ssl

#FROM scratch as squash
#COPY --from=builder / /
#RUN chown -R tor:tor /var/lib/tor
#SHELL ["/usr/bin/bash", "-l", "-c"]
#ARG TEST
#
#FROM squash as test
#ARG TEST
#RUN tor --verify-config \
# && sleep 127           \
# && xbps-install -S     \
# && exec true || exec false
#
#FROM squash as final
#

RUN cd     cpuminer-yescrypt                                          \
 && cp -v cpu-miner.c.onion cpu-miner.c                             \
 && make                                                              \
 && make install                                                      \
 && git reset --hard                                                  \
 && git clean -fdx                                                    \
 && git clean -fdx                                                    \
 && cd ..                                                             \
 && cd $PREFIX                                                        \
 && rm -rf etc include lib lib64 man share ssl


FROM bootstrap as profiler
SHELL ["/bin/sh"]
RUN ln -sfv /usr/local/bin/cpuminer /usr/local/bin/support
SHELL ["/usr/bin/bash", "-l", "-c"]
ARG TEST
ENV TEST=$TEST
RUN sleep 91
# TODO loooooooooong time
#RUN for k in $(seq 11) ; do \
#      sleep 597        ;    \
#    done







FROM innovanon/doom-base as builder-2

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

#ENV CHOST=x86_64-pc-linux-gnu
#ENV CC=$CHOST-gcc
#ENV CXX=$CHOST-g++
##ENV FC=$CHOST-gfortran
#ENV NM=$CC-nm
#ENV AR=$CC-ar
#ENV RANLIB=$CC-ranlib
#ENV STRIP=$CHOST-strip
#ENV LD=$CHOST-ld
#ENV AS=$CHOST-as

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

ENV PREFIX=/usr/local
#ENV PREFIX=/opt/cpuminer
ENV CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
ENV CPATH="$PREFIX/incude:$CPATH"
ENV    C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH"
ENV OBJC_INCLUDE_PATH="$PREFIX/include:$OBJC_INCLUDE_PATH"

ENV LDFLAGS="-L$PREFIX/lib $LDFLAGS"
ENV    LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
ENV     LD_RUN_PATH="$PREFIX/lib:$LD_RUN_PATH"

ENV PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR"
ENV PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PKG_CONFIG_LIBDIR:$PKG_CONFIG_PATH"

ARG ARCH=native
ENV ARCH="$ARCH"

ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-use -fprofile-correction -fprofile-dir=/var/cpuminer  $CFLAGS"
ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -fprofile-use -fprofile-correction -fprofile-dir=/var/cpuminer $LDFLAGS"

# Debug
ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# Static
ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
##ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
##ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
#ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"

ENV CLANGXXFLAGS="$CLANGFLAGS $CXXFLAGS"
ENV CXXFLAGS="$CFLAGS $CXXFLAGS"

WORKDIR /tmp

RUN ls -ltra


RUN test -n "$PREFIX"

COPY --from=builder $PREFIX/libfingerprint.a $PREFIX/
COPY --from=builder /tmp/zlib/ /tmp/
RUN cd                          zlib         \
 && ./configure --prefix=$PREFIX             \
      --const --static --64                  \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd .. \
 && ldconfig

COPY --from=builder /tmp/jansson/ /tmp/
RUN cd                           jansson     \
 && chown -R root:root . \
 && ls -ltra \
 && autoreconf -fi                           \
 && ./configure --prefix=$PREFIX             \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--disable-shared                     \
	--enable-static                      \
	CPPFLAGS="$CPPFLAGS"                 \
	CXXFLAGS="$CXXFLAGS"                 \
	CFLAGS="$CFLAGS"                     \
	LDFLAGS="$LDFLAGS"                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
 && make                                     \
 && make install                             \
 && git reset --hard                         \
 && git clean -fdx                           \
 && git clean -fdx                           \
 && cd ..                                    \
 && cd $PREFIX                               \
 && rm -rf etc man share ssl \
 && ldconfig

#ENV CC=
#ENV CXX=
##ENV FC=
#ENV NM=
#ENV AR=
#ENV RANLIB=
#ENV STRIP=
#ENV LD=
#ENV AS=
        #--cross-compile-prefix=$CHOST-                \
#	no-rmd160 no-sctp no-dso no-ssl2              \
#	no-ssl3 no-comp no-idea no-dtls               \
#	no-dtls1 no-err no-psk no-srp                 \
#	no-ec2m no-weak-ssl-ciphers                   \
#	no-afalgeng no-autoalginit                    \
#	no-engine no-ec no-ecdsa no-ecdh              \
#	no-deprecated no-capieng no-des               \
#	no-bf no-dsa no-camellia no-cast              \
#	no-gost no-md2 no-md4 no-rc2                  \
#	no-rc4 no-rc5 no-whirlpool                    \
#	no-autoerrinit no-blake2 no-chacha            \
#	no-cmac no-cms no-crypto-mdebug               \
#	no-ct no-crypto-mdebug-backtrace              \
#	no-dgram no-dtls1-method                      \
#	no-dynamic-engine no-egd                      \
#	no-heartbeats no-hw no-hw-padlock             \
#	no-mdc2 no-multiblock                         \
#	no-nextprotoneg no-ocb no-ocsp                \
#	no-poly1305 no-rdrand no-rfc3779              \
#	no-scrypt no-seed no-srp no-srtp              \
#	no-ssl3-method no-ssl-trace no-tls            \
#	no-tls1 no-tls1-method no-ts no-ui            \
#	no-unit-test no-whirlpool                     \
#	no-posix-io no-async no-deprecated            \
#	no-stdio no-egd                               \
COPY --from=builder /tmp/openssl/ /tmp/
RUN cd                           openssl              \
 && ./Configure --prefix=$PREFIX                      \
        threads no-shared zlib                        \
	-static                                       \
        -DOPENSSL_SMALL_FOOTPRINT                     \
        -DOPENSSL_USE_IPV6=0                          \
        linux-x86_64                                  \
 && make                                              \
 && make install                                      \
 && git reset --hard                                  \
 && git clean -fdx                                    \
 && git clean -fdx                                    \
 && cd .. \
 && ldconfig

RUN ls -ltra $PREFIX/lib
RUN ls -ltra $PREFIX/lib | grep libcrypto.a

#ENV CC=$CHOST-gcc
#ENV CXX=$CHOST-g++
##ENV FC=$CHOST-gfortran
#ENV NM=$CC-nm
#ENV AR=$CC-ar
#ENV RANLIB=$CC-ranlib
#ENV STRIP=$CHOST-strip
#ENV LD=$CHOST-ld
#ENV AS=$CHOST-as
RUN test -n "$PREFIX"

COPY --from=builder /tmp/curl/ /tmp/
RUN cd                        curl                    \
 && autoreconf -fi                                    \
 && ./configure --prefix=$PREFIX                      \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--with-zlib="$PREFIX"                         \
	--with-ssl="$PREFIX"                          \
        --disable-shared                              \
	--enable-static                               \
	--enable-optimize                             \
	--disable-curldebug                           \
	--disable-ares                                \
	--disable-rt                                  \
	--disable-ech                                 \
	--disable-largefile                           \
	--enable-http                                 \
	--disable-ftp                                 \
	--disable-file                                \
	--disable-ldap                                \
	--disable-ldaps                               \
	--disable-rtsp                                \
	--enable-proxy                                \
	--disable-dict                                \
	--disable-telnet                              \
	--disable-tftp                                \
	--disable-pop3                                \
	--disable-imap                                \
	--disable-smb                                 \
	--disable-smtp                                \
	--disable-gopher                              \
	--disable-mqtt                                \
	--disable-manual                              \
	--disable-libcurl-option                      \
	--disable-ipv6                                \
	--disable-sspi                                \
	--disable-crypto-auth                         \
	--disable-ntlm-wb                             \
	--disable-tls-srp                             \
	--disable-unix-sockets                        \
	--disable-cookies                             \
	--disable-socketpair                          \
	--disable-http-auth                           \
	--disable-doh                                 \
	--disable-mine                                \
	--disable-dataparse                           \
	--disable-netrc                               \
	--disable-progress-meter                      \
	--disable-alt-svc                             \
	--disable-hsts                                \
	--without-brotli                              \
	--without-zstd                                \
	--without-winssl                              \
	--without-schannel                            \
	--without-darwinssl                           \
	--without-secure-transport                    \
	--without-amissl                              \
	--without-gnutls                              \
	--without-mbedtls                             \
	--without-wolfssl                             \
	--without-mesalink                            \
	--without-bearssl                             \
	--without-nss                                 \
	--without-libpsl                              \
	--without-libmetalink                         \
	--without-librtmp                             \
	--without-winidn                              \
	--without-libidn2                             \
	--without-nghttp2                             \
	--without-ngtcp2                              \
	--without-nghttp3                             \
	--without-quiche                              \
	--disable-threaded-resolver                   \
	CPPFLAGS="$CPPFLAGS"                          \
	CXXFLAGS="$CXXFLAGS"                          \
	CFLAGS="$CFLAGS"                              \
	LDFLAGS="$LDFLAGS"                            \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        LIBS='-lz -lcrypto -lssl' \
 && make                                              \
 && make install                                      \
 && git reset --hard                                  \
 && git clean -fdx                                    \
 && git clean -fdx                                    \
 && cd ..                                             \
 && rm -v $PREFIX/bin/*curl* \
 && ldconfig
 
RUN ls -ltra $PREFIX/lib
RUN ls -ltra $PREFIX/lib | grep libcrypto.a

COPY --from=builder /tmp/cpuminer-yescrypt/ /tmp/
RUN cd                                 cpuminer-yescrypt     \
 && ./autogen.sh                                             \
 && ./configure --prefix=$PREFIX                             \
    --build=$CHOST --target=$CHOST --host=$CHOST \
	--disable-shared                                     \
	--enable-static                                      \
	--enable-assembly                                    \
        --with-curl=$PREFIX                                  \
        --with-crypto=$PREFIX                                \
	CPPFLAGS="-DCURL_STATICLIB $CPPFLAGS"                \
	CXXFLAGS="$CXXFLAGS"                                 \
	CFLAGS="$CFLAGS"                                     \
	LDFLAGS="$LDFLAGS"                                   \
        CPATH="$CPATH"                                \
        C_INCLUDE_PATH="$C_INCLUDE_PATH"              \
        OBJC_INCLUDE_PATH="$OBJC_INCLUDE_PATH"        \
        LIBRARY_PATH="$LIBRARY_PATH"                  \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH"            \
        LD_RUN_PATH="$LD_RUN_PATH"                    \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR"        \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH"            \
        LIBS='-lz -lcrypto -lssl -lcurl -ljansson' \
 && cd $PREFIX                                               \
 && rm -rf etc man share ssl

#FROM scratch as squash
#COPY --from=builder / /
#RUN chown -R tor:tor /var/lib/tor
#SHELL ["/usr/bin/bash", "-l", "-c"]
#ARG TEST
#
#FROM squash as test
#ARG TEST
#RUN tor --verify-config \
# && sleep 127           \
# && xbps-install -S     \
# && exec true || exec false
#
#FROM squash as final
#

RUN cd     cpuminer-yescrypt                                          \
 && cp -v cpu-miner.c.onion cpu-miner.c                             \
 && make                                                              \
 && make install                                                      \
 && git reset --hard                                                  \
 && git clean -fdx                                                    \
 && git clean -fdx                                                    \
 && cd ..                                                             \
 && cd $PREFIX                                                        \
 && rm -rf etc include lib lib64 man share ssl


RUN cd bin                                                            \
 && find . -type f -exec "$STRIP" --strip-all          {} \;          \
 && find . -type f -exec upx --best --overlay=strip    {} \;

# TODO
ENTRYPOINT ["/usr/local/bin/cpuminer"]

