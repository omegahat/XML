#ifndef EXPAT_PARSE_H
#define EXPAT_PARSE_H

/* */
#include "xmlparse.h"


int RS_XML(parseWithParserData)(FILE *file, RS_XMLParserData *parserData);
void RS_XML(initParser)(XML_Parser parser, RS_XMLParserData *parserData);
int RS_XML(parse)(FILE *file, USER_OBJECT_ handlers);
int RS_XML(parseBufferWithParserData)(char *buf, RS_XMLParserData *parserData);


int RS_XML(externalEntityHandler)(XML_Parser parser, const XML_Char *context, 
                          const XML_Char *base, const XML_Char *systemId, 
                          const XML_Char *publicId);

#endif
