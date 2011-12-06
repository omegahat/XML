OMEGA_HOME=../..
ifdef ADMIN
 include Install/GNUmakefile.admin
endif


#
# This is not used when installing the R package.
# Instead, the command 
#        R INSTALL XML
# or 
#        R INSTALL XML.tar.gz
# is used.


CC=gcc
#CC=cc

# Command for invoking S.
S=Splus5
SHOME=/usr/local/src/Splus5.1

# Set this to be R or S
#LANGUAGE=S
LANGUAGE=R


# Set either of these as appropriate.
#LIBXML=/usr2/Downloads/libxml-1.8.6
#LIBXML=/home/duncan/XML/libxml2-2.0.0
#LIBXML=/home/duncan/XML/libxml-1.8.9

#LIBXML=/home/duncan/XML/libxml2-2.2.7
LIBXML=/home/rgentlem/XML/libxml2-2.2.11
LIBXML2=1
#LIBEXPAT=$(HOME)/XML/expat


ifndef LIBXML
ifndef LIBEXPAT
message: 
endif
endif
ifndef LIBEXPAT
ifndef LIBXML
message: 
endif
endif


SRC=\
    Utils \
    $(LANGUAGE)Utils \
    RSDTD \
    EventParse  \
    xpath


LIBXML_SRC= DocParse XMLEventParse XMLTree
LIBEXPAT_SRC= ExpatParse 

ifdef LIBXML
 SRC += $(LIBXML_SRC)
 LIBXML_INCLUDES=. libxml
 LIBXML_LIBS= xml
 CFLAGS+= -DLIBXML
ifdef LIBXML2
 LIBXML_DIRS=$(LIBXML)/.libs
 CFLAGS+= -DLIBXML2
 LIBXML_LIBS= xml2
endif
endif



ifdef LIBEXPAT
 SRC += $(LIBEXPAT_SRC)
 EXPATXML_INCLUDES= xmlparse xmltok
 EXPATLIB_DIRS=$(LIBEXPAT)/lib
 EXPAT_LIBS= xmlparse xmltok
 CFLAGS+= -DLIBEXPAT
endif

OBJS=$(SRC:%=%.o)

INCLUDES+= $(OMEGA_HOME)/include/Corba $(LIBXML_INCLUDES:%=$(LIBXML)/%) $(EXPATXML_INCLUDES:%=$(LIBEXPAT)/%)

LIB_DIRS=$(EXPATLIB_DIRS) $(LIBXML_DIRS:%=%)
LIBS= $(EXPAT_LIBS) $(LIBXML_LIBS)

ifeq ($(CC),gcc)
# -Wall
 CFLAGS+= -g -fpic -Wall
 LD_PIC_FLAG=-shared
 RPATH_FLAG=--rpath
else
 CFLAGS+= -g -KPIC
 LD_PIC_FLAG=-G
 RPATH_FLAG=-R
endif

ifeq ($(LANGUAGE),R)
  CFLAGS+=-DUSE_R=1 -D_R_=1
  INCLUDES+=$(R_HOME)/include
  LIBNAME=XML.so
else
#  SHOME=$(HOME)/Projects/S4
  CFLAGS+= -DUSE_S -D_S_=1 -D_S4_=1
  INCLUDES+=$(SHOME)/include
  LIBS+= z
  LIBNAME=S.so
endif



$(LIBNAME): $(OBJS)
	$(CC) $(LD_PIC_FLAG) -o $@ $^ $(LIB_DIRS:%=-L%)  $(LIB_DIRS:%=$(RPATH_FLAG)%) $(LIBS:%=-l%)  

%.o: %.c
	$(CC) $(INCLUDES:%=-I%) $(CFLAGS) -c $<


clean:
	for f in $(OBJS) ; do \
	 if [ -f $$f ] ; then \
	   rm $$f ; \
	 fi \
	done


distclean: clean
	for f in  R.so ; do \
	  if [ -f $$f ] ; then rm $$f ; fi \
	done


again: distclean
	$(MAKE)

dom: DOMParse.o
	$(CC) -o $@ $^ $(LIB_DIRS:%=-L%)  $(LIB_DIRS:%=--rpath%) $(LIBS:%=-l%) 


message:
	@echo "Error:"
	@echo "   You must specify a value for either LIBXML or LIBEXPAT, or both."



.PHONY: expat libxml
expat:
	cd expat ; tar cf - . | (cd $(LIBEXPAT) ; tar xf - )
libxml:
	cd libxml ; tar cf - . | (cd $(LIBXML) ; tar xf - )


# Make the patch to libxml/SAX.c to change the symbol
# `attribute' to something else to avoid the conflict with Splus5/S4.
libxmlpatch:
	 (PWD=`pwd`; export PWD ; cd $(LIBXML) ; patch -f < $(PWD)/PATCH.attribute)


Src/XML:
	(cd Src ; cat * > XML ; echo "" >> XML)

initS:  Src/XML
	$(S) CHAPTER
	$(S) < Src/XML 

  
ifndef C_SRC_FILES
C_SRC_FILES=\
  DocParse.c DocParse.h \
  EventParse.c EventParse.h \
  ExpatParse.c ExpatParse.h \
  RSDTD.c RSDTD.h \
  RS_XML.h \
  RUtils.c \
  Utils.c Utils.h \
  XMLEventParse.c \
  XMLTree.c \
  xpath.c
endif
  

# MAN_FILES=$(shell find man -not -type d -not -name '*~')

# DATA_FILES=$(shell find examples data -not -type d -maxdepth 1 -not -name '*~')


MANUALS=$(shell find Docs -name '*.nw')
manuals: $(MANUALS:%.nw=%.ps)

%.ps: %.nw
	$(MAKE) -C $(@D) $(@F)


schema.o: schema.c
	gcc  -I$(R_HOME)/include -DLIBXML -I/usr/local/include/libxml2 -DUSE_EXTERNAL_SUBSET=1 -DROOT_HAS_DTD_NODE=1 -DDUMP_WITH_ENCODING=1 -DUSE_XML_VERSION_H=1 -DXML_ELEMENT_ETYPE=1 -DXML_ATTRIBUTE_ATYPE=1 -DNO_XML_HASH_SCANNER_RETURN=1 -DUSE_R=1 -D_R_=1  -DHAVE_VALIDITY=1 -I. -DLIBXML2=1 -I/usr/local/include   -fPIC  -g -g  -c schema.c -o schema.o

