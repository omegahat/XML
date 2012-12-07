#include <libxml/SAX2.h>

#include "stdio.h"

static int numCalls = 0;

getNextLine(void *context, char *buffer, int len)
{
    int n;
    char *tmp;
    xmlParserCtxtPtr ctx = (xmlParserCtxtPtr) context;
    fprintf(stderr, "<getNextLine> len = %d\n", len);
    tmp = fgets(buffer, len, ctx->_private);
    numCalls++;

    if(!tmp)
	return(-1);

    return(strlen(buffer));
}

int
main(int argc, char *argv[])
{
    FILE *in;
    xmlParserCtxtPtr ctx = NULL;
    xmlParserInputBufferPtr buf;
    int status;

    in = fopen(argv[1], "r");
    if(!in) {
	fprintf(stderr, "Cannot open %s\n", argv[1]);
	return(2);
    }

    ctx = xmlNewParserCtxt();
    ctx->_private = in;
    buf = (xmlParserInputBufferPtr) calloc(1, sizeof(xmlParserInputBuffer));
    buf->readcallback = getNextLine;
    buf->context = (void*) ctx;
    buf->buffer = xmlBufferCreate();
    buf->raw = NULL; /* buf->buffer; */

    ctx->input = xmlNewIOInputStream(ctx, buf, XML_CHAR_ENCODING_NONE);

    inputPush(ctx, ctx->input);

    status = xmlParseDocument(ctx);
    fprintf(stderr, "Status from parsing: %d, number of calls to getNextLine: %d\n", status, numCalls);

    return(0);
}

