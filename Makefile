#!/usr/bin/make -f
# -*- makefile -*-
#
#	Copyright (C) 2003-2008 Jari Aalto
#
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License as
#	published by the Free Software Foundation; either version 2 of the
#	License, or (at your option) any later version
#
#	This program is distributed in the hope that it will be useful, but
#	WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#	General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with program. If not, write to the Free Software
#	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#	02110-1301, USA.
#
#	Visit <http://www.gnu.org/copyleft/gpl.html>

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE	= cygbuild

MAKE_INCLUDEDIR = etc/makefile

include $(MAKE_INCLUDEDIR)/id.mk
include $(MAKE_INCLUDEDIR)/vars.mk
include $(MAKE_INCLUDEDIR)/unix.mk
include $(MAKE_INCLUDEDIR)/cygwin.mk
include $(MAKE_INCLUDEDIR)/net-sf.mk

PL		= etc/lib/$(PACKAGE).pl
SH		= bin/$(PACKAGE).sh \
		  bin/$(PACKAGE)-rebuild.sh

#   There are directories fromt he archive, not install dirs. See vars.mk

FROM_ETC_MAIN	 = etc/etc
FROM_ETC_TMPL	 = etc/template
FROM_ETC_DATA	 = etc/data
ETCDIR_TMPL	 = $(SHAREDIR)/template
ETCDIR_DATA	 = $(SHAREDIR)/data
ETCDIR_TMPL_USER = $(ETCDIR)/template

SRCS		= $(PL) $(SH)
OBJS		= $(SRCS) Makefile README ChangeLog
OBJS_ETC_MAIN	= `find $(FROM_ETC_MAIN) -maxdepth 1 -type f ! -name ".[\#]*" -a ! -name "*[\#~]" `
OBJS_ETC_TMPL	= `find $(FROM_ETC_TMPL) -maxdepth 1 -type f ! -name ".[\#]*" -a ! -name "*[\#~]" `
OBJS_ETC_DATA	= `find $(FROM_ETC_DATA) -maxdepth 1 -type f ! -name ".[\#]*" -a ! -name "*[\#~]" `

# ######################################################### &targets ###

.PHONY: all clean distclean realclean test doc
.PHONY: install-dir-structure
.PHONY: install-share-template install-template-symlinks install

# Rule: all - Make and compile all.
all:	doc


# Rule: clean - Remove unnecessary files
clean: clean-temp-files

# Rule: distclean - [maintenance] Remove files that can be generated
distclean: clean
	@-rm -rf $(DOCDIR)

# Rule: realclean - [maintenance] Clean everything that is not needed
realclean: distclean

test:
	@echo "Nothing to test. Try and report bugs to <$(EMAIL)>"

# Rule: doc - [maintenance] Generate or update documentation
# "docs" is infact synonym for target "doc"
docs: doc

doc: $(DOCDIR)/$(PACKAGE).1
doc: $(DOCDIR)/$(PACKAGE).html
doc: $(DOCDIR)/$(PACKAGE).txt
doc: $(DOCDIR)/cygbuild-rebuild.1

# Rule: doc-readme - [maintenance] Convert README into HTML, you need perl-text2html.sourceforge.net
doc-readme:
	t2html.pl --title "cygbuild README" \
	    --as-is --simple README > doc/README.html

# Rule: install-dir-structure - [maintenance] Create /etc directory
install-dir-structure:
	# install-dir-structure
	$(INSTALL_BIN) -d $(ETCDIR_TMPL) $(ETCDIR_DATA) $(ETCDIR_TMPL_USER)

# Rule: install-etc-main - [maintenance] Install configuration files
install-etc-main: install-dir-structure
	# install-etc-main
	@for file in $(OBJS_ETC_MAIN);					\
	do								\
	    if [ -f $$file ]; then					\
		echo $(INSTALL_DATA) $$file $(ETCDIR);			\
		$(INSTALL_DATA) $$file $(ETCDIR);			\
	    fi;								\
	done

# Rule: install-etc-main-symlink - [maintenance] Install symlinks to configuration dir
# FIXME: remove. 2008-03-03 no longer used.
install-etc-main-symlink: install-dir-structure
	# install-etc-main-symlink
	@for file in $(OBJS_ETC_MAIN);					\
	do								\
	    if [ -f $$file ]; then					\
		ln -vsf `pwd`/$$file $(ETCDIR)/`basename $$file`;	\
	    fi;								\
	done

# Rule: install-share-template - [maintenance] Install template configuration files
install-share-template: install-dir-structure
	# install-share-template
	-rm -f	$(ETCDIR_TMPL)/*
	@for file in $(OBJS_ETC_TMPL);					\
	do								\
	    if [ -f $$file ]; then					\
		echo $(INSTALL_DATA) $$file $(ETCDIR_TMPL);		\
		$(INSTALL_DATA) $$file $(ETCDIR_TMPL);			\
	    fi;								\
	done

# Rule: install-share-data - [maintenance] Install data configuration files
install-share-data: install-dir-structure
	# install-share-data
	-rm -f	$(ETCDIR_DATA)/*
	@for file in $(OBJS_ETC_DATA);					\
	do								\
	    if [ -f $$file ]; then					\
		echo $(INSTALL_DATA) $$file $(ETCDIR_DATA);		\
		$(INSTALL_DATA) $$file $(ETCDIR_DATA);			\
	    fi;								\
	done

# Rule: install-template-symlinks - [maintenance] Install templates using symlinks
install-template-symlinks: install-dir-structure
	# install-template-symlinks
	-rm -f	$(ETCDIR_TMPL)/*
	@for file in $(OBJS_ETC_TMPL);					\
	do								\
	    if [ -f $$file ]; then					\
		ln -vsf `pwd`/$$file $(ETCDIR_TMPL)/`basename $$file`;	\
	    fi;								\
	done

# Rule: install-data-symlinks - [maintenance] Install data using symlinks
install-data-symlinks: install-dir-structure
	# install-data-symlinks
	-rm -f	$(ETCDIR_DATA)/*
	@for file in $(OBJS_ETC_DATA);					\
	do								\
	    if [ -f $$file ]; then					\
		ln -vsf `pwd`/$$file $(ETCDIR_DATA)/`basename $$file`;	\
	    fi;								\
	done

# Rule: install-etc - [maintenance] Install /etc directories
install-share: install-share-data install-share-template

# Rule: install-in-place - Install from current dir using symlinks
install-in-place: install-data-symlinks		\
		install-template-symlinks	\
		install-bin-symlink

# Rule: install - install everything to system directories
install: install-unix install-share

# ######################################################### &release ###

.PHONY: kit release

release: kit

# xRule: kit - [maintenance] Make a World and Cygwin binary release kits
kit: release-world release-cygwin

# #################################################### &dependencies ###

# Pod generates .x~~ extra files, remove those

.SUFFIXES:
.SUFFIXES: .1 .html .txt .pod

install-docdir:
	$(INSTALL_BIN) -d $(DOCDIR)

$(DOCDIR)/$(PACKAGE).1: $(PL) install-docdir
	perl ./$< help --man > $(DOCDIR)/$(PACKAGE).1
	@-rm -f *.x~~ pod*.tmp

$(DOCDIR)/$(PACKAGE).html: $(PL) install-docdir
	perl ./$< help --html > $(DOCDIR)/$(PACKAGE).html
	@-rm -f *.x~~ pod*.tmp

$(DOCDIR)/$(PACKAGE).txt: $(PL) install-docdir
	perl ./$< help > $(DOCDIR)/$(PACKAGE).txt
	@-rm -f *.x~~ pod*.tmp

$(DOCDIR)/cygbuild-rebuild.1: doc/cygbuild-rebuild.pod install-docdir
	name=`echo $< | sed -e 's/.*\///; s/.pod//'`; pod2man $< > $(DOCDIR)/$$name.1
	@-rm -f *.x~~ pod*.tmp

# End of file
