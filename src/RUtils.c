#include "Utils.h"

#include <libxml/catalog.h>
/*
  Utilities used in the R XML parsing facilities for invoking user-level functions from C.

 * See Copyright for the license status of this software.

 */

#include "Rinternals.h" /* Macros, etc. */


USER_OBJECT_
R_makeXMLContextRef(xmlParserCtxtPtr ctx)
{
  USER_OBJECT_ ans;
  PROTECT(ans = R_MakeExternalPtr(ctx, Rf_install(XML_PARSER_CONTEXT_TYPE_NAME), R_NilValue));
  SET_CLASS(ans, mkString(XML_PARSER_CONTEXT_TYPE_NAME));
  UNPROTECT(1); 
  return(ans);
}

USER_OBJECT_ R_InternalRecursiveApply(USER_OBJECT_ top, USER_OBJECT_ func, USER_OBJECT_ klasses);

USER_OBJECT_
RS_XML(invokeFunction)(USER_OBJECT_ fun, USER_OBJECT_ opArgs, USER_OBJECT_ data, xmlParserCtxtPtr context)
{
  int i;
  long n;
  USER_OBJECT_ c, call;
  USER_OBJECT_ ans;
  int addContext = 0;

  if(context && TYPEOF(fun) == CLOSXP && OBJECT(fun) && R_isInstanceOf(fun, XML_PARSE_CONTEXT_FUNCTION))
      addContext = 1;

  n = Rf_length(opArgs) + addContext + 1;
  if(data)
    n++;


  if(n  > 0) {
#if 1
    PROTECT(call = allocVector(LANGSXP, n));      
    c = call;
    SETCAR(call, fun); c = CDR(c);

    if(addContext)  {
	SETCAR(c, R_makeXMLContextRef(context));
	c = CDR(c);
    }

    for (i = 0; i < Rf_length(opArgs); i++) {
      SETCAR(c, VECTOR_ELT(opArgs, i));
      c = CDR(c);
    }


    if(data) {
       SETCAR(c, data);
       SET_TAG(c, Rf_install(".state"));
    }    
#else
    PROTECT(c = call = allocList(n));
    if(addContext)  {
	SETCAR(c, R_makeXMLContextRef(context));
	c = CDR(c);
    }

    for (i = 0; i < GET_LENGTH(opArgs); i++) {
      SETCAR(c, VECTOR_ELT(opArgs, i));
      c = CDR(c);
    }
    if(data) {
       SETCAR(c, data);
       SET_TAG(c, Rf_install(".state"));
    }

    call = LCONS(fun, call);
    UNPROTECT(1);
#endif
  } else  {
     PROTECT(call = allocVector(LANGSXP, 1 + addContext));
     SETCAR(call, fun);
     if(addContext)
	 SETCAR(CDR(call), R_makeXMLContextRef(context));
  }  


  ans = eval(call, R_GlobalEnv);
  UNPROTECT(1);

  return(ans);
}

USER_OBJECT_
RS_XML(RecursiveApply)(USER_OBJECT_ top, USER_OBJECT_ func, USER_OBJECT_ klasses)
{
  USER_OBJECT_ ans;
  PROTECT(top = duplicate(top));
  ans = R_InternalRecursiveApply(top, func, klasses);
  UNPROTECT(1);
  return(ans);
}

USER_OBJECT_
R_InternalRecursiveApply(USER_OBJECT_ top, USER_OBJECT_ func, USER_OBJECT_ klasses)
{
  int CHILD_NODE = 2, i;
  USER_OBJECT_ kids;
  int numChildren;
  USER_OBJECT_ args, tmp;


  if(GET_LENGTH(top) > CHILD_NODE) {
    kids = VECTOR_ELT(top, CHILD_NODE);
    numChildren = GET_LENGTH(kids);
        /* Do the children first. */
    PROTECT(args = NEW_LIST(1));
    PROTECT(tmp = NEW_LIST(numChildren));  
    for(i = 0; i < numChildren; i++) {
      SET_VECTOR_ELT(tmp, i, R_InternalRecursiveApply(VECTOR_ELT(kids, i), func, klasses));
    }
    SET_VECTOR_ELT(top, CHILD_NODE, tmp);
    UNPROTECT(2);
  }

  PROTECT(args = NEW_LIST(1));
  SET_VECTOR_ELT(args, 0, top);
  tmp =  RS_XML(invokeFunction)(func, args, NULL, NULL); /*XXX get the context and user data!!! */
  UNPROTECT(1);

  return(tmp);
}

USER_OBJECT_
RS_XML_SubstituteEntitiesDefault(USER_OBJECT_ replaceEntities)
{
    int value;
    USER_OBJECT_ ans;
    value = xmlSubstituteEntitiesDefault(LOGICAL_DATA(replaceEntities)[0]);   
    ans = NEW_LOGICAL(1);
    LOGICAL_DATA(ans)[0] = value;
    return(ans);
}

#include <R_ext/Rdynload.h>

/* Simple macro for expanding ENTRY(x, n) to {"<x>", (DL_FUNC) &<x>, <n>} */

#define ENTRY(name, n)  { #name, (DL_FUNC) &name, n }

static R_CallMethodDef callMethods[] = {
	ENTRY(RS_XML_RecursiveApply, 3),
#ifdef UNUSED_DOT_CALLS
	ENTRY(RS_XML_HtmlParseTree, 7),
        ENTRY(RS_XML_setDoc, 2),
        ENTRY(R_xmlNsAsCharacter, 1),
	ENTRY(R_addXMLNodeFinalizer, 1),
#endif
	ENTRY(RS_XML_getDTD, 5),
	ENTRY(RS_XML_libxmlVersion, 0),
	ENTRY(RS_XML_Parse, 17),
	ENTRY(RS_XML_ParseTree, 21),
	ENTRY(R_newXMLDtd, 5),
	ENTRY(R_newXMLDoc, 3),
	ENTRY(R_newXMLNode, 6),
	ENTRY(R_newXMLTextNode, 3),
	ENTRY(R_xmlNewComment, 3),
	ENTRY(R_newXMLCDataNode, 3),
	ENTRY(R_newXMLPINode, 4),
	ENTRY(R_xmlNewNs, 3),
	ENTRY(R_xmlSetNs, 3),
	ENTRY(R_xmlRootNode, 3),
	ENTRY(R_insertXMLNode, 4),
	ENTRY(R_saveXMLDOM, 6),
	ENTRY(R_xmlCatalogResolve, 3),
	ENTRY(RS_XML_xmlNodeNumChildren, 1),
        ENTRY(RS_XML_unsetDoc, 4),
        ENTRY(RS_XML_printXMLNode, 6),
        ENTRY(RS_XML_dumpHTMLDoc, 5),
        ENTRY(RS_XML_removeChildren, 3),
        ENTRY(RS_XML_clone, 3),
        ENTRY(RS_XML_addNodeAttributes, 2),
        ENTRY(RS_XML_removeNodeAttributes, 3),
        ENTRY(RS_XML_getNsList, 2),
        ENTRY(RS_XML_setNodeName, 2),
        ENTRY(RS_XML_SubstituteEntitiesDefault, 1),
        ENTRY(RS_XML_getNextSibling, 3),
        ENTRY(R_getXMLNodeDocument, 1),
        ENTRY(RS_XML_createDocFromNode, 1),
        ENTRY(R_removeInternalNode, 2),
	ENTRY(RS_XML_replaceXMLNode, 3),
	ENTRY(RS_XML_xmlAddSiblingAt, 4),
	ENTRY(RS_XML_loadCatalog, 1),
	ENTRY(RS_XML_clearCatalog, 0),
	ENTRY(RS_XML_catalogAdd, 3),
	ENTRY(RS_XML_catalogDump, 1),
	ENTRY(RS_XML_setDocumentName, 2),
	ENTRY(RS_XML_setKeepBlanksDefault, 1),
	ENTRY(R_getDocEncoding, 1),
	ENTRY(R_getLineNumber, 1),
        ENTRY(RS_XML_xpathEval, 7),
        ENTRY(RS_XML_xmlNodeChildrenReferences, 3),
	ENTRY(RS_XML_freeDoc, 1),
	ENTRY(RS_XML_setRootNode, 2),
	ENTRY(R_getNodeChildByIndex, 3),
	ENTRY(RS_XML_setDocEl, 2),
	ENTRY(RS_XML_isDescendantOf, 3),
	ENTRY(RS_XML_getStructuredErrorHandler, 0),
	ENTRY(RS_XML_setStructuredErrorHandler, 1),
	ENTRY(R_convertDOMToHashTree, 4),
	ENTRY(R_parseURI, 1),
	ENTRY(R_getXMLFeatures, 0),
	ENTRY(R_xmlReadMemory, 5), //XXX
	ENTRY(R_xmlReadFile, 3), //XXX
	ENTRY(RS_XML_internalNodeNamespaceDefinitions, 2),
	ENTRY(R_libxmlTypeTable_names, 2),
	ENTRY(R_libxmlTypeTable_lookup, 3),
	ENTRY(RS_XML_xmlSchemaValidateDoc, 4),
	ENTRY(R_XML_indexOfChild, 1),
	ENTRY(RS_XML_xmlStopParser, 1),
	ENTRY(R_clearNodeMemoryManagement, 1),
	ENTRY(R_XMLInternalDocument_free, 1),
	ENTRY(R_addXMLInternalDocument_finalizer, 2),
	ENTRY(R_createXMLNode, 4),
	ENTRY(RS_XML_xmlNodeName, 1),
	ENTRY(RS_XML_xmlNodeNamespace, 1),
	ENTRY(RS_XML_xmlNodeAttributes, 3),
	ENTRY(RS_XML_xmlNodeChildrenReferences, 3),
	ENTRY(R_xmlNodeValue, 3),
	ENTRY(R_setXMLInternalTextNode_value, 2),
	ENTRY(RS_XML_xmlNodeParent, 2),
	ENTRY(R_getXMLNsRef, 1), // XXX
	ENTRY(R_setXMLInternalTextNode_noenc, 1),
	ENTRY(R_isNodeChildOfAt, 3),
	ENTRY(R_findXIncludeStartNodes, 2),
	ENTRY(RS_XML_removeAllNodeNamespaces, 1),
	ENTRY(RS_XML_removeNodeNamespaces, 2),
	ENTRY(R_matchNodesInList, 3),
	ENTRY(RS_XML_copyNodesToDoc, 3),
	ENTRY(RS_XML_getDocumentName, 1),
	ENTRY(RS_XML_getDefaultValiditySetting, 1),
	ENTRY(RS_XML_xmlXIncludeProcessFlags, 2),
	ENTRY(RS_XML_xmlXIncludeProcessTreeFlags, 2),
	ENTRY(R_convertXMLNsRef, 1),
	{NULL, NULL, 0}
};

static R_CMethodDef cmethods[] = {
    ENTRY(RSXML_setErrorHandlers, 0),
    ENTRY(xmlInitializeCatalog, 0),
    {NULL, NULL, 0}
};

void
R_init_XML(DllInfo *dll)
{
   R_useDynamicSymbols(dll, FALSE);
   R_registerRoutines(dll, cmethods, callMethods, NULL, NULL);
}





Rboolean
R_isInstanceOf(USER_OBJECT_ obj, const char *klass)
{

    USER_OBJECT_ klasses;
    int n, i;

    klasses = GET_CLASS(obj);
    n = GET_LENGTH(klasses);
    for(i = 0; i < n ; i++) {
	if(strcmp(CHAR_DEREF(STRING_ELT(klasses, i)), klass) == 0)
	    return(TRUE);
    }


    return(FALSE);
}


SEXP
RS_XML_getStructuredErrorHandler()
{
    SEXP ans;
    PROTECT(ans = NEW_LIST(2));
    SET_VECTOR_ELT(ans, 0, R_MakeExternalPtr(xmlGenericErrorContext, Rf_install("xmlGenericErrorContext"), R_NilValue));
    SET_VECTOR_ELT(ans, 1, R_MakeExternalPtr(xmlStructuredError, Rf_install("xmlStructuredErrorFunc"), R_NilValue));
    UNPROTECT(1);
    return(ans);
}

SEXP
RS_XML_setStructuredErrorHandler(SEXP els)
{
    void *ctx;
    xmlStructuredErrorFunc handler;
    SEXP fun, sym;
    
    fun = VECTOR_ELT(els, 0);
    sym = VECTOR_ELT(els, 1);

    if(sym != R_NilValue && TYPEOF(sym) != EXTPTRSXP) {
	PROBLEM "invalid symbol object for XML error handler. Need an external pointer, e.g from getNativeSymbolInfo"
        ERROR;
    }

    if(fun == R_NilValue)
	ctx = NULL;
    else if(TYPEOF(fun) == EXTPTRSXP)
        ctx = R_ExternalPtrAddr(fun);
    else {
	ctx = fun = Rf_duplicate(fun); /* Should R_PreserveObject and
				  * ReleaseObject() but then we have
                                    to be able "remember" if it is an
				    R function or not.*/
	R_PreserveObject(fun);
     }


    handler = (sym == R_NilValue) ? NULL : (xmlStructuredErrorFunc) R_ExternalPtrAddr(sym);
    xmlSetStructuredErrorFunc(ctx, handler);

    return(ScalarLogical(TRUE));
}


SEXP
CreateCharSexpWithEncoding(const xmlChar *encoding, const xmlChar *str)
{
    SEXP ans;

#ifdef HAVE_R_CETYPE_T
    cetype_t enc = CE_NATIVE;

    if(encoding == (const xmlChar *) NULL || encoding == (const xmlChar *) "") {
  	    enc = CE_NATIVE;
    } else if(xmlStrcmp(encoding, "UTF-8") == 0 || xmlStrcmp(encoding, "utf-8") == 0)
	    enc = CE_UTF8;
    else if(xmlStrcmp(encoding, "ISO-8859-1") == 0 || xmlStrcmp(encoding, "iso-8859-1") == 0)
	    enc = CE_LATIN1;
    else {
	str = translateChar(mkChar(str));
    }
// REprintf("encoding: %d\n", enc);
    ans = mkCharCE(str, enc);
#else
    ans = mkChar(str);
#endif
    return(ans);
}


SEXP
R_lookString(SEXP rstr)
{
    const char *str;
    str = CHAR(STRING_ELT(rstr, 0));
    return(ScalarInteger(strlen(str)));
}


#if 0
#include <libxml/uri.h>
SEXP
R_relativeURL(SEXP r_url, SEXP r_base)
{
    xmlChar *url, *base;
    const xmlChar *ans;
    SEXP rans;
    url = CHAR_DEREF(STRING_ELT(r_url, 0));
    base = CHAR_DEREF(STRING_ELT(r_base, 0));
    ans = xmlBuildRelativeURI(url, base);
    rans = ScalarString(COPY_TO_USER_STRING(ans));
    xmlFree(ans);
    return(rans);
}
#endif


