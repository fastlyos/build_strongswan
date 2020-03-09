#
#   Copyright (C) 2015 MINZKN.COM , HWPORT.COM
#   All rights reserved.
#
#   Maintainers
#     JaeHyuk Cho ( <mailto:minzkn@minzkn.com> , https://www.minzkn.com/ )
#

# check for minimal make version (NOTE: this check will break at make 10.x !)
override DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION:=3.81#
ifneq ($(firstword $(sort $(MAKE_VERSION) $(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION))),$(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION))
  $(error you have make "$(MAKE_VERSION)". GNU make >= $(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION) is required !)
endif

# ----
  
ifneq ($(wildcard /bin/bash),)
  SHELL=/bin/bash# default bash shell
else
  ifeq ($(strip $(SHELL)),)
    SHELL=/bin/sh# default unix shell
  endif
endif

JOBS:=8#

# ----

# Delete default rules. We don't use them. This saves a bit of time.
.SUFFIXES:

# ----

DEF_HWPORT_PATH_CURRENT:=$(abspath .)#
DEF_HWPORT_PATH_DISTFILES:=$(abspath $(DEF_HWPORT_PATH_CURRENT)/../distfiles)#
DEF_HWPORT_PATH_STAGE1:=$(DEF_HWPORT_PATH_CURRENT)/objs#
DEF_HWPORT_PATH_STAGE2:=$(DEF_HWPORT_PATH_CURRENT)/objs/output#
DEF_HWPORT_PATH_STAGE3:=$(DEF_HWPORT_PATH_CURRENT)/objs/rootfs#

DEF_HWPORT_PATH_SOURCE_GMP:=$(DEF_HWPORT_PATH_CURRENT)/gmp-6.1.2#
DEF_HWPORT_PATH_SOURCE_ZLIB:=$(DEF_HWPORT_PATH_CURRENT)/zlib-1.2.11#
DEF_HWPORT_PATH_SOURCE_OPENSSL:=$(DEF_HWPORT_PATH_CURRENT)/openssl-1.1.0e# FAILED: openldap-2.4.44
DEF_HWPORT_PATH_SOURCE_LIBRESSL:=$(DEF_HWPORT_PATH_CURRENT)/libressl-2.5.4#
#DEF_HWPORT_PATH_SOURCE_OPENLDAP:=$(DEF_HWPORT_PATH_CURRENT)/openldap-2.4.40#
DEF_HWPORT_PATH_SOURCE_OPENLDAP:=$(DEF_HWPORT_PATH_CURRENT)/openldap-2.4.44#
DEF_HWPORT_PATH_SOURCE_CURL:=$(DEF_HWPORT_PATH_CURRENT)/curl-7.54.0#
#DEF_HWPORT_PATH_SOURCE_STRONGSWAN:=$(DEF_HWPORT_PATH_CURRENT)/strongswan-5.5.2#
DEF_HWPORT_PATH_SOURCE_STRONGSWAN:=$(DEF_HWPORT_PATH_CURRENT)/strongswan-5.8.2#

# ----

.PHONY: all maintainer-clean distclean clean mostlyclean
.PHONY: dist installcheck installdirs install install-strip uninstall check info dvi TAGS
.PHONY: help build

all: build

maintainer-clean: distclean
	@echo "maintainer-clean"

distclean: clean
	@echo "distclean"

clean: mostlyclean
	@echo "clean"

mostlyclean:
	@echo "mostlyclean"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE3)"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE2)"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE1)"

dist: install
	@echo "dist install"

installcheck: install

installdirs:
	@echo "installing directory"

install: all installdirs
	@echo "installing"

install-strip: install
	@echo "stripping"

uninstall:

check: all

info:

dvi:

TAGS:

help:
	@echo "help"

build: \
$(DEF_HWPORT_PATH_STAGE1)/strongswan/.done
	@echo "build complete."

# ----

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/gmp.html
.PHONY: gmp
gmp: $(DEF_HWPORT_PATH_STAGE1)/gmp/.done
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done: $(DEF_HWPORT_PATH_SOURCE_GMP)
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    ABI=64 \
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)/usr/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    ./configure \
	    --prefix='/usr' \
	    --sysconfdir='/etc' \
	    --localstatedir='/var' \
	    --enable-cxx \
	    --disable-static
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/libgmp\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/libgmp.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libgmpxx.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)/usr/lib'," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libgmp.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)/usr/lib'," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libgmpxx.la"
	@touch "$(@)"

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/zlib.html
.PHONY: zlib
zlib: $(DEF_HWPORT_PATH_STAGE1)/zlib/.done
$(DEF_HWPORT_PATH_STAGE1)/zlib/.done: $(DEF_HWPORT_PATH_SOURCE_ZLIB)
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CROSS_PREFIX="" \
	    CFLAGS="-fPIC" \
	    LDFLAGS="" \
	    $(<)/configure \
	    --prefix='/usr' \
	    --includedir="/usr/include" \
	    --libdir="/usr/lib" \
	    --shared
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@touch "$(@)"

# http://www.linuxfromscratch.org/blfs/view/7.8/postlfs/openssl.html
# https://wiki.openssl.org/index.php/Compilation_and_Installation
.PHONY: openssl
openssl: $(DEF_HWPORT_PATH_STAGE1)/openssl/.done
$(DEF_HWPORT_PATH_STAGE1)/openssl/.done: $(DEF_HWPORT_PATH_SOURCE_OPENSSL) \
$(DEF_HWPORT_PATH_STAGE1)/zlib/.done \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    ./Configure \
	    --prefix='/usr' \
	    --openssldir='/etc/ssl' \
	    --libdir='lib' \
	    -I$(DEF_HWPORT_PATH_STAGE2)/usr/include \
	    -L$(DEF_HWPORT_PATH_STAGE2)/usr/lib \
	    shared \
	    threads \
	    zlib-dynamic \
	    no-asm \
	    enable-seed \
	    enable-camellia \
	    enable-gmp \
	    enable-ec \
	    enable-idea \
	    enable-rc5 \
	    enable-mdc2 \
	    enable-tls \
	    enable-tlsext \
	    linux-x86_64
	@make -j$(JOBS) -C "$(dir $(@))" INSTALL_PREFIX="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" INSTALL_PREFIX="$(DEF_HWPORT_PATH_STAGE2)" MANDIR="$(DEF_HWPORT_PATH_STAGE2)/usr/share/man" MANSUFFIX=ssl install
	@touch "$(@)"

# https://www.libressl.org/
.PHONY: libressl
libressl: $(DEF_HWPORT_PATH_STAGE1)/libressl/.done
$(DEF_HWPORT_PATH_STAGE1)/libressl/.done: $(DEF_HWPORT_PATH_SOURCE_LIBRESSL)
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)/usr/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    ./configure \
	    --prefix='/usr' \
	    --sysconfdir='/etc' \
	    --localstatedir='/var' \
	    --disable-static \
	    --enable-shared
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/libcrypto\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/libcrypto.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libssl.la"
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/libcrypto\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/libcrypto.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libtls.la"
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/libssl\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/libssl.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libtls.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)/usr/lib'," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libcrypto.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)/usr/lib'," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libssl.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)/usr/lib'," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libtls.la"
	@touch "$(@)"

.PHONY: openldap
openldap: $(DEF_HWPORT_PATH_STAGE1)/openldap/.done
$(DEF_HWPORT_PATH_STAGE1)/openldap/.done: $(DEF_HWPORT_PATH_SOURCE_OPENLDAP) \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done \
$(DEF_HWPORT_PATH_STAGE1)/libressl/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)/usr/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    ac_cv_func_memcmp_working=yes \
	    ./configure \
	    --prefix='/usr' \
	    --sysconfdir='/etc' \
	    --localstatedir='/var' \
	    --libexecdir='/usr/lib' \
	    --enable-ldap \
	    --disable-static \
	    --disable-debug \
	    --enable-slapd \
	    --with-threads \
	    --with-tls=openssl \
	    --enable-crypt \
	    --with-mp=gmp \
	    --enable-modules \
	    --enable-rlookups \
	    --disable-ndb \
	    --disable-sql \
	    --disable-shell \
	    --disable-bdb \
	    --disable-hdb \
	    --disable-mdb \
	    --enable-overlays=mod \
	    --with-yielding-select \
	    --enable-dynamic=yes
	@make -j1 -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" depend
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/liblber\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/liblber.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libldap.la"
	@sed -i -e "s,^dependency_libs\=\(.*\)\s/usr/lib/liblber\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)/usr/lib/liblber.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libldap_r.la"
	@sed -i -e "s,^libdir=.*$$,libdir=$(DEF_HWPORT_PATH_STAGE2)/usr/lib," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/liblber.la"
	@sed -i -e "s,^libdir=.*$$,libdir=$(DEF_HWPORT_PATH_STAGE2)/usr/lib," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libldap.la"
	@sed -i -e "s,^libdir=.*$$,libdir=$(DEF_HWPORT_PATH_STAGE2)/usr/lib," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libldap_r.la"
	@touch "$(@)"

.PHONY: curl
curl: $(DEF_HWPORT_PATH_STAGE1)/curl/.done
$(DEF_HWPORT_PATH_STAGE1)/curl/.done: $(DEF_HWPORT_PATH_SOURCE_CURL) \
$(DEF_HWPORT_PATH_STAGE1)/libressl/.done \
$(DEF_HWPORT_PATH_STAGE1)/openldap/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)/usr/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    ac_cv_lib_crypto_CRYPTO_lock=yes \
	    ./configure \
	    --prefix='/usr' \
	    --sysconfdir='/etc' \
	    --localstatedir='/var' \
	    --disable-debug \
	    --enable-shared \
	    --disable-static \
	    --disable-ldap \
	    --without-kerberos \
	    --without-libssh2 \
	    --disable-static-libs \
	    --enable-ipv6 \
	    --enable-threads \
	    --disable-ares \
	    --enable-http \
	    --enable-ftp \
	    --disable-gopher \
	    --enable-file \
	    --disable-dict \
	    --enable-manual \
	    --disable-telnet \
	    --enable-smtp \
	    --enable-pop3 \
	    --enable-imap \
	    --enable-rtsp \
	    --enable-nonblocking \
	    --enable-largefile \
	    --enable-maintainer-mode \
	    --disable-sspi \
	    --disable-manual \
	    --disable-ntlm-wb \
	    --enable-hidden-symbols \
	    --disable-curldebug \
	    --without-krb4 \
	    --without-librtmp \
	    --without-spnego \
	    --without-gnutls \
	    --without-nss \
	    --with-zlib='$(DEF_HWPORT_PATH_STAGE2)/usr' \
	    --without-libidn \
	    --with-ssl='$(DEF_HWPORT_PATH_STAGE2)/usr' \
	    --with-ca-path='/etc/ssl/certs' \
	    --without-ca-bundle \
	    --with-random=/dev/urandom \
	    --with-lber-lib=liblber.so
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^libdir=.*$$,libdir=$(DEF_HWPORT_PATH_STAGE2)/usr/lib," "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libcurl.la"
	@touch "$(@)"

.PHONY: strongswan
strongswan: $(DEF_HWPORT_PATH_STAGE1)/strongswan/.done
$(DEF_HWPORT_PATH_STAGE1)/strongswan/.done: $(DEF_HWPORT_PATH_SOURCE_STRONGSWAN) \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done \
$(DEF_HWPORT_PATH_STAGE1)/libressl/.done \
$(DEF_HWPORT_PATH_STAGE1)/curl/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)/usr/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    LD_LIBRARY_PATH="$(DEF_HWPORT_PATH_STAGE2)/usr/lib" \
	    $(<)/configure \
	    --prefix='/usr' \
	    --sysconfdir='/etc' \
	    --localstatedir='/var' \
	    --without-lib-prefix \
	    --enable-acert=yes \
	    --enable-addrblock=yes \
	    --enable-led \
	    --enable-pkcs11=yes \
	    --enable-kernel-netlink=yes \
	    --enable-socket-default=yes \
	    --enable-openssl=no \
	    --enable-gcrypt=no \
	    --enable-gmp=yes \
	    --enable-af-alg=no \
	    --enable-curl=yes \
	    --enable-charon=yes \
	    --enable-tnccs-11=no \
	    --enable-tnccs-20=no \
	    --enable-tnccs-dynamic=no \
	    --enable-eap-sim-pcsc=no \
	    --enable-eap-sim \
	    --enable-eap-sim-file \
	    --enable-eap-aka \
	    --enable-eap-aka-3gpp2 \
	    --enable-eap-simaka-sql \
	    --enable-eap-simaka-pseudonym \
	    --enable-eap-simaka-reauth \
	    --enable-eap-identity \
	    --enable-eap-md5 \
	    --enable-eap-gtc \
	    --enable-eap-mschapv2 \
	    --enable-eap-tls \
	    --enable-eap-ttls \
	    --enable-eap-peap \
	    --enable-eap-tnc \
	    --enable-eap-dynamic \
	    --enable-eap-radius \
	    --enable-unity=no \
	    --enable-stroke=yes \
	    --enable-sql=no \
	    --enable-pki=yes \
	    --enable-scepclient=no \
	    --enable-scripts=yes \
	    --enable-vici=no \
	    --enable-swanctl=yes \
	    --enable-socket-dynamic \
	    --disable-monolithic \
	    --enable-ldap \
	    --disable-xauth-pam \
	    --disable-connmark \
	    --disable-forecast \
	    --disable-soup
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@touch "$(@)"

# ----

.DEFAULT:
	@echo "unknown goals ($@))"

# End of Makefile
