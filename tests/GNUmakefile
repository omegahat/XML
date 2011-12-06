CFLAGS=$(shell xml2-config --cflags)
LIBS=$(shell xml2-config --libs)

entities: entities.o
	  $(CC) -o $@ $^ $(LIBS)

pull: pull.c
	$(CC) -o pull  pull.c `xml2-config --libs`