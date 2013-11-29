.PHONY: all clean install untar nginx php curl

PREFIX ?= $(shell pwd)/output

BUILD = $(shell pwd)/build
ROOT = $(shell pwd)
SOURCE=$(ROOT)/src
TARTMP=$(ROOT)/tmpsrc

PHPVER=5.4.17
NGINXVER=1.4.4
PCREVER=8.33
CURLVER=7.33.0

RM=rm -f
MV=mv -f
CP=cp -pd
MKDIR=mkdir -p
TAR=tar --owner=0 --group=0 -C $(TARTMP)
LN=ln -f

all: clean untar nginx php phpredis

nginx:
	cd $(TARTMP)/nginx-$(NGINXVER) && ./configure --prefix=$(BUILD) \
		--with-pcre=$(TARTMP)/pcre-$(PCREVER) --error-log-path=/dev/null \
		&& $(MAKE) && $(MAKE) install

php: curl
	cd $(TARTMP)/php-$(PHPVER) && ./configure --prefix=$(BUILD) \
		--enable-cgi --enable-fpm --with-zlib --enable-soap \
		--with-mysql=mysqlnd --with-pdo-mysql --with-curl=$(BUILD) \
		--with-config-file-scan-dir=etc/php.d && $(MAKE) && $(MAKE) install
	$(LN) -s phar.phar $(BUILD)/bin/phar
	$(MV) $(BUILD)/bin/php $(BUILD)/bin/php-cli
	$(CP) bin/php.script $(BUILD)/bin/php

phpredis:
	cd $(TARTMP)/phpredis && $(BUILD)/bin/phpize && ./configure \
		--with-php-config=$(BUILD)/bin/php-config && $(MAKE) && $(MAKE) install

curl:
	cd $(TARTMP)/curl-$(CURLVER) && ./configure --prefix=$(BUILD) && \
		$(MAKE) && $(MAKE) install

untar:
	$(MKDIR) $(TARTMP)
	cd $(SOURCE) && \
		$(TAR) -zxf nginx-$(NGINXVER).tar.gz && \
		$(TAR) -jxf php-$(PHPVER).tar.bz2 && \
		$(TAR) -zxf pcre-$(PCREVER).tar.gz && \
		$(TAR) -zxf phpredis.tar.gz && \
		$(TAR) -zxf curl-$(CURLVER).tar.gz

install:
	$(MKDIR) $(PREFIX)/run $(PREFIX)/log
	$(CP) -r $(BUILD)/lib $(PREFIX)
	$(CP) -r $(BUILD)/bin $(PREFIX)
	$(CP) -r $(BUILD)/include $(PREFIX)
	$(CP) -r $(BUILD)/sbin $(PREFIX)
	$(CP) -r $(BUILD)/php $(PREFIX)
	$(CP) -r $(BUILD)/etc $(PREFIX)
	$(CP) -r $(wildcard $(BUILD)/conf/*) $(PREFIX)/etc
	$(CP) -r $(ROOT)/etc $(PREFIX)
	$(CP) -r $(ROOT)/bin $(PREFIX)
	$(CP) -r $(ROOT)/htdocs $(PREFIX)

clean:
	$(RM) -r $(TARTMP)
	$(RM) -r $(BUILD)

