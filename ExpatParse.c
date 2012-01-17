/* only compile this if LIBEXPAT is defined. */
#ifdef LIBEXPAT

/*
 File that provides the entry point for an event driven XML parser
 that performs callbacks to the different user-level functions in
 the closure passed to it.

 * See Copyright for the license status of this software.

 */

#include "EventParse.h"
#include "Utils.h" /* For the findFunction and invokeFunction. */

#include "RSCommon.h"
#include "ExpatParse.h"



void 
RS_XML(initParser)(XML_Parser parser, RS_XMLParserData *parserData)
{
  XML_SetUserData(parser, parserData);
  XML_SetElementHandler(parser, RS_XML(startElement), RS_XML(endElement));
  XML_SetCommentHandler(parser, RS_XML(commentHandler));
  XML_SetExternalEntityRefHandler(parser, RS_XML(externalEntityHandler));
  XML_SetUnparsedEntityDeclHandler(parser, RS_XML(entityDeclarationHandler));
  XML_SetCharacterDataHandler(parser, RS_XML(textHandler));
  XML_SetProcessingInstructionHandler(parser, RS_XML(processingInstructionHandler));
  XML_SetCdataSectionHandler(parser, RS_XML(startCdataSectionHandler), RS_XML(endCdataSectionHandler));
  XML_SetBase(parser, parserData->fileName);
  XML_SetNotStandaloneHandler(parser, RS_XML(notStandAloneHandler));
}


int RS_XML(parse)(FILE *file, USER_OBJECT_ handlers)
{
  RS_XMLParserData *parserData;
   parserData = RS_XML(createParserData)(handlers);
  return(RS_XML(parseWithParserData)(file, parserData));
}

int RS_XML(parseWithParserData)(FILE *file, RS_XMLParserData *parserData)
{
  char buf[BUFSIZ];
  int done;
  XML_Parser parser = XML_ParserCreate(NULL);

  RS_XML(initParser)(parser, parserData);
  do {
    size_t len = fread(buf, 1, sizeof(buf), file);
    done = len < sizeof(buf);
    if (!XML_Parse(parser, buf, len, done)) {
      PROBLEM 
	      "%s at line %d\n",
	      XML_ErrorString(XML_GetErrorCode(parser)),
   	      XML_GetCurrentLineNumber(parser)
        WARN;
      return 1;
    }
  } while (!done);
  XML_ParserFree(parser);
  return 0;
}



int
RS_XML(parseBufferWithParserData)(char *buf, RS_XMLParserData *parserData)
{
  int status;
  XML_Parser parser = XML_ParserCreate(NULL);
    RS_XML(initParser)(parser, parserData);
    status = XML_Parse(parser, buf, strlen(buf), 1);

  if(status == 0) {
    const char *msg = XML_ErrorString(XML_GetErrorCode(parser));
    PROBLEM "XML Parser Error: %s", msg
    ERROR;
  }

  return(status);
}



int 
RS_XML(externalEntityHandler)(XML_Parser parser, const XML_Char *context, 
                              const XML_Char *base, const XML_Char *systemId, 
                                const XML_Char *publicId)
{
 RS_XMLParserData *parserData = (RS_XMLParserData*)XML_GetUserData(parser);
 USER_OBJECT_ opArgs;
 int i, num;
  const XML_Char *xml_args[4];
  num = sizeof(xml_args)/sizeof(xml_args[0]);
   xml_args[0] = context; xml_args[1] = base;xml_args[2] = systemId; xml_args[3] = publicId;

  opArgs = NEW_LIST(num);
  for(i =0;i < num; i++) {
    RECURSIVE_DATA(opArgs)[i] = NEW_CHARACTER(1); 
    CHARACTER_DATA(RECURSIVE_DATA(opArgs)[i])[0] = ENC_COPY_TO_USER_STRING(xml_args[i] ? xml_args[i] : "");
  }

 RS_XML(callUserFunction)("externalEntity", NULL, parserData, opArgs);
 return(1); /* ok to go on */
}

#else
/* Something to avoid an empty file.*/
void 
XML_Expat_unused_dummy(void)
{
}
#endif /* only if LIBEXPAT is defined */
