LIBS=parse tok
all: $(LIBS:%=lib/libxml%.so)

lib/libxmltok.so:
	$(MAKE) -C xmltok

lib/libxmlparse.so:
	$(MAKE) -C xmlparse