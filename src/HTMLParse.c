/*
  This file uses the HTML parser in libxml to provide an HTML
  parser in R that is basically identical to the XML parsing interface.
  It can handle files, URLs, compressed files, and raw HTML text.
  It drops the DTD and validation options since these are not very relevant
  for HTML. (We can add put them back if anyone wants!)
 */

#include "DocParse.h"
#include "Utils.h"

#include "libxml/HTMLparser.h"
#include "libxml/HTMLtree.h"

#include <sys/stat.h>
#include <unistd.h>  

USER_OBJECT_
RS_XML(HtmlParseTree)(USER_OBJECT_ fileName, USER_OBJECT_ converterFunctions, 
                       USER_OBJECT_ skipBlankLines, USER_OBJECT_ replaceEntities,
                       USER_OBJECT_ asText, USER_OBJECT_ trim, USER_OBJECT_ isURL)
{
  const char *name;
  xmlDocPtr doc;
  USER_OBJECT_ rdoc;
  USER_OBJECT_ className;
  R_XMLSettings parserSettings;
  int freeName = 0;

  int asTextBuffer = LOGICAL_DATA(asText)[0];
  int isURLDoc = LOGICAL_DATA(isURL)[0];

  parserSettings.skipBlankLines = LOGICAL_DATA(skipBlankLines)[0];
  parserSettings.converters = converterFunctions;
  parserSettings.trim = LOGICAL_DATA(trim)[0];

  if(asTextBuffer == 0) {
    struct stat tmp_stat;  
#ifdef USE_R
    name = CHAR(STRING_ELT(fileName, 0));
#else
    name = CHARACTER_DATA(fileName)[0];
#endif
    if(!isURLDoc && (name == NULL || stat(name, &tmp_stat) < 0)) {
      PROBLEM "Can't find file %s", CHAR_DEREF(STRING_ELT(fileName, 0))
      ERROR;
    }
  } else {
     name = strdup(CHAR_DEREF(STRING_ELT(fileName, 0)));
     freeName = 1;
  }


#if 0
    /* If one wants entities expanded directly and to appear as text.  */
  if(LOGICAL_DATA(replaceEntities)[0])
    xmlSubstituteEntitiesDefault(1);   
#endif

  if(asTextBuffer) {
   doc = htmlParseDoc(CHAR_TO_XMLCHAR(name), NULL);
   if(doc != NULL) {
      doc->name = (char *) xmlStrdup(CHAR_TO_XMLCHAR("<buffer>"));
   }
  } else {
      doc = htmlParseFile(name, NULL);
  }

  if(doc == NULL) {
    if(freeName && name)
        free((char *) name);
    PROBLEM "error in creating parser for %s", name
    ERROR;
  }

  PROTECT(rdoc = RS_XML(convertXMLDoc)(name, doc, converterFunctions, &parserSettings));

  if(freeName && name)
      free((char *) name);


#if 0
  xmlFreeDoc(doc);
  R_numXMLDocsFreed++;
#endif

     /* Set the class for the document. */
  className = NEW_CHARACTER(1);
  PROTECT(className);
    SET_STRING_ELT(className, 0, mkChar("HTMLDocument"));   
    SET_CLASS(rdoc, className);
  UNPROTECT(1);


 UNPROTECT(1); 
 return(rdoc);
}




/*
  Copied from  RS_XML_printXMLNode (XMLTree.c)  with minor changes.
 */
USER_OBJECT_
RS_XML_dumpHTMLDoc(USER_OBJECT_ r_node, USER_OBJECT_ format, USER_OBJECT_ r_encoding, USER_OBJECT_ indent, USER_OBJECT_ outFile)
{
    USER_OBJECT_ ans;
    xmlDocPtr node;
    const char *encoding = NULL;
    xmlOutputBufferPtr buf;
    xmlBufferPtr xbuf;

    int oldIndent;

    oldIndent = xmlIndentTreeOutput;

    node = (xmlDocPtr) R_ExternalPtrAddr(r_node);

    xmlIndentTreeOutput =  LOGICAL(indent)[0];

#if ADD_XML_OUTPUT_BUFFER_CODE
    if(Rf_length(outFile)) {
       htmlSaveFile(CHAR_DEREF(STRING_ELT(outFile, 0)), node);
       return(R_NilValue);
    }
#endif

   
    if(GET_LENGTH(r_encoding))
	encoding = CHAR_DEREF(STRING_ELT(r_encoding, 0));

    xbuf = xmlBufferCreate();

#if 1
    buf = xmlOutputBufferCreateBuffer(xbuf, NULL);
#else
    buf = xmlOutputBufferCreateFilename("/tmp/test.out", NULL, 0);
#endif

    htmlDocContentDumpFormatOutput(buf, node, encoding, INTEGER(format)[0]);
    xmlOutputBufferFlush(buf);
    xmlIndentTreeOutput = oldIndent;

    if(xbuf->use > 0) {
        /*XXX this const char * in CHARSXP means we have to make multiple copies. */
#if 0
	char *rbuf = R_alloc(sizeof(char) * (xbuf->use + 1));
	memcpy(rbuf, xbuf->content, xbuf->use + 1);
	PROTECT(tmp = mkChar(rbuf));
#endif
	// ans = ScalarString(mkChar(xbuf->content));
	DECL_ENCODING_FROM_DOC(node)
	ans = ScalarString(ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(xbuf->content)));
    } else
      ans = NEW_CHARACTER(1);

    xmlOutputBufferClose(buf);

    return(ans);
}
