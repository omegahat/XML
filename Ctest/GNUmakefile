rogerK: rogerK.o
	$(CC) -o $@ $^ $(LDFLAGS)

CFLAGS=-g $(shell xml2-config --cflags)
LDFLAGS=$(shell xml2-config --libs)

run: rogerK
	rogerK 2>1 | grep Finished

	

text: text.o
