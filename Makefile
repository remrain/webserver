.PHONY: all clean install untar nginx php

PREFIX ?= $(shell pwd)/output

BUILD = $(shell pwd)/build
ROOT = $(shell pwd)
SOURCE=$(ROOT)/src
TARTMP=$(ROOT)/tmpsrc

PHPVER=5.4.17
NGINXVER=1.4.2
PCREVER=8.33

RM=rm -f
MV=mv -f
CP=cp -pd
MKDIR=mkdir -p
TAR=tar --owner=0 --group=0 -C $(TARTMP)
LN=ln -f

all: clean untar nginx php phpredis

nginx:
	cd $(TARTMP)/nginx-$(NGINXVER) && ./configure --prefix=$(BUILD) \
		--with-pcre=$(TARTMP)/pcre-$(PCREVER) && make && make install

php:
	cd $(TARTMP)/php-$(PHPVER) && ./configure --prefix=$(BUILD) \
		--enable-cgi --enable-fpm --with-zlib && make && make install
	$(LN) -s phar.phar $(BUILD)/bin/phar

phpredis:
	cd $(TARTMP)/phpredis && $(BUILD)/bin/phpize && ./configure \
		--with-php-config=$(BUILD)/bin/php-config && make && make install

untar:
	$(MKDIR) $(TARTMP)
	cd $(SOURCE) && \
		$(TAR) -zxf nginx-$(NGINXVER).tar.gz && \
		$(TAR) -jxf php-$(PHPVER).tar.bz2 && \
		$(TAR) -zxf pcre-$(PCREVER).tar.gz && \
		$(TAR) -zxf phpredis.tar.gz

install:
	$(MKDIR) $(PREFIX)/run $(PREFIX)/log $(PREFIX)/logs
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

