#include "Utils.h"  /* For isBlank() */

#include <libxml/catalog.h>


USER_OBJECT_
R_xmlCatalogResolve(USER_OBJECT_ r_id, USER_OBJECT_ type, USER_OBJECT_ debug)
{
    xmlChar *id;
    SEXP r_ans = R_NilValue;
    xmlChar* ans = NULL;
    int debugLevel = -1;
    int n, i;

    debugLevel = xmlCatalogSetDebug(LOGICAL(debug)[0]);
    
    n = GET_LENGTH(r_id);
    PROTECT(r_ans = NEW_CHARACTER(n));

    for(i = 0; i < n; i++) {
       id = CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(r_id, i)));	    

       switch(INTEGER(type)[i]) {
       case 1:
          ans = xmlCatalogResolveURI(id);
	  break;
       case 2:
	  ans = xmlCatalogResolvePublic(id);
	  break;
       case 3:
	  ans = xmlCatalogResolveSystem(id);
	  break;
       default:
          break;
       }

       if(ans) {
          SET_STRING_ELT(r_ans, i, mkChar(XMLCHAR_TO_CHAR(ans)));
   	  xmlFree(ans);
       } else {
 	 SET_STRING_ELT(r_ans, i, NA_STRING);
       }
    }

    UNPROTECT(1);

    xmlCatalogSetDebug(debugLevel);

    return(r_ans);
}


SEXP
RS_XML_loadCatalog(SEXP catalogs)
{
    int i, n;
    SEXP ans;
    n = GET_LENGTH(catalogs);
    ans = NEW_LOGICAL(n);
    for(i = 0; i < n ; i++) {
	LOGICAL(ans)[i] = (xmlLoadCatalog(CHAR(STRING_ELT(catalogs, i))) == 0);
    }
    return(ans);
}

SEXP
RS_XML_clearCatalog()
{
    xmlCatalogCleanup();
    return(ScalarLogical(1));
}

SEXP 
RS_XML_catalogAdd(SEXP orig, SEXP replace, SEXP type)
{
    int i, n;
    SEXP ans;

    n =  LENGTH(orig);
    ans = NEW_LOGICAL(n);
    for(i = 0; i < n ; i++) {
	LOGICAL(ans)[i] = (xmlCatalogAdd(CHAR_TO_XMLCHAR(CHAR(STRING_ELT(type, i))), 
                                         CHAR_TO_XMLCHAR(CHAR(STRING_ELT(orig, i))), 
					 CHAR_TO_XMLCHAR(CHAR(STRING_ELT(replace, i)))) == 0);
    }

    return(ans);
}

SEXP
RS_XML_catalogDump(SEXP fileName)
{
    FILE *out;
    out = fopen(CHAR(STRING_ELT(fileName, 0)), "w");
    if(!out) {
	PROBLEM "Can't open file %s for write access", CHAR(STRING_ELT(fileName, 0))
	    ERROR;
    }

    xmlCatalogDump(out);
    return(ScalarLogical(TRUE));
}

void
R_xmlInitializeCatalog()
{
    xmlInitializeCatalog();
}
