PERL=perl
CUR_DIR=$(shell pwd)

include ../VersionInfo

INDEX=../../index.html
INDEX=index.html
FAQ=../../FAQ.html
CHANGES=../../Changes
BUGS=../../Bugs.html
TODO=../../Todo.html

DOCS= Howto.pdf Examples.pdf Internals.pdf Features.pdf

DOCS=Outline.pdf MathML.pdf Tour.pdf WritingXML.html  description.pdf manual.pdf

PKG_WEB_NAME=RSXML


PKG_TAR_FILE=../../$(TAR_FILE)
PACKAGE=$(PKG_NAME)

all: man.pdf html examples Rdocs $(INDEX) ../../index.html

$(INDEX): update

update: configure ../VersionInfo
	./configure

configure: configure.in	
	autoconf

pkg/man: $(PKG_TAR_FILE)
	if [ ! -d pkg ] ; then mkdir pkg  ; fi
	(cd  pkg ; tar zxvf ../$(PKG_TAR_FILE) )

$(PKG_TAR_FILE):
	(cd ../.. ; $(MAKE) ADMIN=1 tar )

man.pdf: pkg/man
	${R_HOME}/bin/R CMD Rd2dvi --pdf pkg/$(PKG_NAME)/man
	mv Rd2.pdf $@

html: pkg/man
	$(R_HOME)/bin/R CMD perl $(R_HOME)/share/perl/build-help.pl -d --html pkg/$(PKG_NAME) $(CUR_DIR)/man
	$(PERL) -npe 'if(m/logo.jpg/) {$$_ = "<h1>The Omegahat XML Parsing package for R &amp; SPlus</h1><center><h2>Function Help Pages</h2></center>";} if(m|html/packages|){$$_="";} if(m|Package List|){$$_="";} if(m|up.jpg|){$$_="";}' man/$(PKG_NAME)/html/00Index.html > man/$(PKG_NAME)/html/00Index.html-
	mv man/$(PKG_NAME)/html/00Index.html- man/$(PKG_NAME)/html/00Index.html


#	if test ! -d $(CUR_DIR)/man ; then mkdir -p $(CUR_DIR) ; fi
#	(cd ../../.. ; R_LIBS=. ; export R_LIBS ; $(R_HOME)/bin/R CMD build-help -d --html $(PKG_NAME) $(CUR_DIR) )

.PHONY:	examples
examples: ../../examples
	if  test -d examples  ; then rm -fr examples ; fi
	cp -r ../../examples .
	find examples -name '*~' -exec rm {} \;

#	mv tests examples


R_SUPPORT_DOCS=R.css left.jpg logo.jpg logosm.jpg right.jpg up.jpg 
#packages-foot.html

Rdocs:
	if test ! -d doc/html ; then mkdir -p doc/html ; fi
	cp $(R_SUPPORT_DOCS:%=$(R_HOME)/doc/html/%) doc/html

install: all installDocs
	$(update-r-mirror)

installDocs: all
	scp -r $(PKG_TAR_FILE) doc man $(DOCS:%=pkg/$(PKG_NAME)/inst/Docs/%) man.pdf $(INDEX) Requirements.html $(OMEGA_HOME)/Docs/OmegaTech.css  $(FAQ) $(CHANGES) $(BUGS) $(TODO) examples $(TARGET_DIR)
	scp ../../index.html $(TARGET_DIR)/Overview.html

installBasicDocs: index.html
	scp -r  $(INDEX)  Requirements.html $(OMEGA_HOME)/Docs/OmegaTech.css  $(FAQ) $(CHANGES) $(BUGS) $(TODO) $(TARGET_DIR)
	scp ../../index.html $(TARGET_DIR)/Overview.html

indexInstall: $(INDEX)
	scp $(INDEX) $(TARGET_DIR)


include $(OMEGA_HOME)/R/Config/RPackageWebConfig


clean:
	for f in $(DOCS) man.pdf ; do \
	   if [ -f  $$f ] ; then rm $$f ; fi \
	done
	for d in man pkg doc examples ; do \
	  if [ -d $$d ] ; then rm -fr $$d ; fi \
	done


../../index.html: ../../index.html.in   configure
	./configure
