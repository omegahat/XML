
tu: libxml2.tu

%.tu:  %.c
	gcc -fdump-translation-unit -c `xml2-config --cflags` -o /dev/null libxml2.c 

xmlsec.tu:  xmlsec.c
	gcc -fdump-translation-unit -c `xml2-config --cflags` `xmlsec1-config --cflags` -o /dev/null $<
