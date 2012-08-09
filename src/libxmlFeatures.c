#include "RS_XML.h"
#include "Utils.h"

#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif

SEXP
R_getXMLFeatures()
{

#ifdef HAVE_XML_HAS_FEATURE

    int features[] = {
           XML_WITH_THREAD,
           XML_WITH_TREE,
           XML_WITH_OUTPUT,
           XML_WITH_PUSH,
           XML_WITH_READER,
           XML_WITH_PATTERN,
           XML_WITH_WRITER,
           XML_WITH_SAX1,
           XML_WITH_FTP,
           XML_WITH_HTTP,
           XML_WITH_VALID,
           XML_WITH_HTML,
           XML_WITH_LEGACY,
           XML_WITH_C14N,
           XML_WITH_CATALOG,
           XML_WITH_XPATH,
           XML_WITH_XPTR,
           XML_WITH_XINCLUDE,
           XML_WITH_ICONV,
           XML_WITH_ISO8859X,
           XML_WITH_UNICODE,
           XML_WITH_REGEXP,
           XML_WITH_AUTOMATA,
           XML_WITH_EXPR,
           XML_WITH_SCHEMAS,
           XML_WITH_SCHEMATRON,
           XML_WITH_MODULES,
           XML_WITH_DEBUG,
           XML_WITH_DEBUG_MEM,
           XML_WITH_DEBUG_RUN,
#ifdef HAVE_XML_WITH_ZLIB
           XML_WITH_ZLIB
#else
           -1
#endif
   };

    const char * const names[] = {
           "THREAD",   
           "TREE",
           "OUTPUT",
           "PUSH",
           "READER",
           "PATTERN",
           "WRITER",
           "SAX1",
           "FTP",
           "HTTP",
           "VALID",
           "HTML",
           "LEGACY",
           "C14N",
           "CATALOG",
           "XPATH",
           "XPTR",
           "XINCLUDE",
           "ICONV",
           "ISO8859X",
           "UNICODE",
           "REGEXP",
           "AUTOMATA",
           "EXPR",
           "SCHEMAS",
           "SCHEMATRON",
           "MODULES",
           "DEBUG",
           "DEBUG_MEM",
           "DEBUG_RUN",
           "ZLIB"
     };     

    SEXP ans, rnames;
    int n = sizeof(features)/sizeof(features[0]), i;

    PROTECT(ans = allocVector(LGLSXP, n));
    PROTECT(rnames = allocVector(STRSXP, n));
    for(i = 0; i < n; i++)  {
        if(features[i] > -1)
	   LOGICAL(ans)[i] = xmlHasFeature(features[i]);
        else
 	   LOGICAL(ans)[i] = NA_LOGICAL;
	SET_STRING_ELT(rnames, i, mkChar(names[i]));
    }
    SET_NAMES(ans, rnames);
    UNPROTECT(2);

    return(ans);
#else
    return(allocVector(STRSXP, 0));
#endif
}
