
if WANT_JANSSON
JANSSON_INCLUDES= -I$(top_srcdir)/compat/jansson
else
JANSSON_INCLUDES=
endif

EXTRA_DIST	= example-cfg.json nomacro.pl

SUBDIRS		= compat

ALL_INCLUDES	= @PTHREAD_FLAGS@ -fno-strict-aliasing $(JANSSON_INCLUDES) -I.

bin_PROGRAMS	= cpuminer

dist_man_MANS	= cpuminer.1

cpuminer_SOURCES = \
  cpu-miner.c util.c \
  api.c sysinfos.c \
  uint256.cpp \
  yescrypt/yescrypt-common.c yescrypt/yescrypt-best.c \
  yescrypt/sha256_Y.c \
  algo/yescrypt.c \
  algo/sha2.c

if NWITH_GETLINE
   cpuminer_SOURCES += getline/getline.c
endif

disable_flags =

if USE_ASM
   cpuminer_SOURCES += asm/neoscrypt_asm.S
if ARCH_x86
   cpuminer_SOURCES += asm/sha2-x86.S asm/scrypt-x86.S asm/aesb-x86.S
endif
if ARCH_x86_64
   cpuminer_SOURCES += asm/sha2-x64.S asm/scrypt-x64.S asm/aesb-x64.S
endif
if ARCH_ARM
   cpuminer_SOURCES += asm/sha2-arm.S asm/scrypt-arm.S
endif
else
   disable_flags += -DNOASM
endif

if HAVE_WINDOWS
   cpuminer_SOURCES += compat/winansi.c
endif

cpuminer_LDFLAGS	= @LDFLAGS@
cpuminer_LDADD	= @LIBCURL@ @JANSSON_LIBS@ @PTHREAD_LIBS@ @WS2_LIBS@
cpuminer_CPPFLAGS = @LIBCURL_CPPFLAGS@ $(ALL_INCLUDES)
cpuminer_CFLAGS   = -Wno-pointer-sign -Wno-pointer-to-int-cast $(disable_flags)
#cpuminer_CFLAGS  += -fprofile-use=/tmp/cpuminer-multi.gcda -fipa-profile -fprofile-reorder-functions -fvpt -fprofile -fprofile-abs-path -fprofile-arcs -fprofile-dir=/tmp/cpuminer-multi -fprofile-reproducible multithreaded
#cpuminer_CFLAGS  += -fprofile-generate=/tmp/cpuminer-multi.gcda -fipa-profile -fprofile-reorder-functions -fvpt -fprofile -fprofile-abs-path -fprofile-arcs -fprofile-dir=/tmp/cpuminer-multi -fprofile-reproduciblemultithreaded
cpuminer_CFLAGS  += @PGFLAGS@

if HAVE_WINDOWS
cpuminer_CFLAGS += -Wl,--stack,10485760
cpuminer_LDADD += -lcrypt32 -lgdi32 -lgcc -lgcc_eh
endif

if ARCH_ARM
cpuminer_CFLAGS += -D__arm__
endif

if HAVE_WINDOWS
# use to profile an object
# gprof_cflags = -pg -g3
# cpuminer_LDFLAGS += -pg
# cpuminer_CFLAGS += -fno-inline-functions -static

# copy/paste from generated Makefile
common_ccflags = $(DEFS) $(ALL_INCLUDES) $(cpuminer_CPPFLAGS) $(CPPFLAGS) $(cpuminer_CFLAGS) $(CFLAGS)

endif
