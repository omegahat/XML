
OMEGA_HOME=../../..
include $(OMEGA_HOME)/Config/GNUmakefile.config

job.xml: Outline.nw
	$(WEB) -R'$@' $^ > $@


# %.tex: %.nw
#	echo "\\input{WebHeader}" > $@
#	echo "\\noindent\\parindent=0pt" >> $@
#	$(NOWEB_MARKUP) $< | $(OMEGA_HOME)/bin/verbatimNoweave >> $@
#	echo "\\input{WebFooter}" >> $@


roundTripSub.xml: roundTrip.xml
	($(XSLT_PROCESSOR) -in roundTrip.xml -xsl roundTrip.xsl -out $@)



#include $(OMEGA_HOME)/Config/GNUmakefile.rules


OMEGAHAT_DEPENDS=Omegahat.sty WebMacros.tex  ELispMacros.tex html.sty SMacros.tex
FILES=RNewsLetter.tex  $(OMEGAHAT_DEPENDS:%=$(OMEGA_HOME)/Docs/%)
PKG_NAME=XML
TARGET_DIR=/tmp/$(PKG_NAME)

install:
	if test -d $(TARGET_DIR) ; then rm -fr $(TARGET_DIR) ; fi
	mkdir -p $(TARGET_DIR)
	cp $(FILES) $(TARGET_DIR)
	mv $(TARGET_DIR)/RNewsLetter.tex $(TARGET_DIR)/$(PKG_NAME).tex

PWD=$(shell pwd)
tar $(PKG_NAME).tar.gz:
	(cd $(TARGET_DIR)/.. ; tar zcvf $(PWD)/$(PKG_NAME).tar.gz $(PKG_NAME))


#include $(OMEGA_HOME)/Config/GNUmakefile.xml


ifndef DYN_DOCS
  DYN_DOCS=$(HOME)/Classes/StatComputing/XDynDocs/inst
endif

USE_DOCBOOK_SHORTHAND=1
include $(DYN_DOCS)/Make/Makefile
