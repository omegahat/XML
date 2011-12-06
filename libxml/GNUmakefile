CC=gcc

ifeq ($(CC),gcc)
# Use with gcc.
  PIC_FLAG=-fpic
  PIC_LD_FLAG=-shared
else
# Use with Solaris compilers.
  PIC_FLAG=-Kpic
  PIC_LD_FLAG=-G
endif


CFLAGS=-DLIBXML_VERSION="\"1\"" $(PIC_FLAG)


SRC=$(shell ls *.c)
SRC=\
HTMLparser.c \
HTMLtree.c \
SAX.c \
debugXML.c \
encoding.c \
entities.c \
error.c \
nanohttp.c \
parser.c \
tree.c \
valid.c \
xmlIO.c \
xmlmemory.c \
xpath.c

OBJS=$(SRC:%.c=%.o)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

libxml.so: $(OBJS)
	$(CC) $(PIC_LD_FLAG) -o $@ $(OBJS)