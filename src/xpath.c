#include "RS_XML.h"
#include <libxml/xpath.h>
#include "Utils.h"


void xpathTolower(xmlXPathParserContextPtr ctxt, int nargs);
void xpathGrepl(xmlXPathParserContextPtr ctxt, int nargs);
void xpathReplace(xmlXPathParserContextPtr ctxt, int nargs);
void xpathEndswith(xmlXPathParserContextPtr ctxt, int nargs);
void xpathAbs(xmlXPathParserContextPtr ctxt, int nargs);
void xpathBaseURI(xmlXPathParserContextPtr ctxt, int nargs);
void xpathMin(xmlXPathParserContextPtr ctxt, int nargs);
void xpathMax(xmlXPathParserContextPtr ctxt, int nargs);
void R_genericXPathFun(xmlXPathParserContextPtr ctxt, int nargs);
void R_genericAnonXPathFun(xmlXPathParserContextPtr ctxt, int nargs);


static SEXP
convertNodeSetToR(xmlNodeSetPtr obj, SEXP fun, int encoding, SEXP manageMemory)
{
  SEXP ans, expr = NULL, arg = NULL, ref;
  int i;
  int nprot = 0;

  if(!obj)
     return(NULL_USER_OBJECT);

  PROTECT(ans = NEW_LIST(obj->nodeNr)); nprot++;

  if(GET_LENGTH(fun) && (TYPEOF(fun) == CLOSXP || TYPEOF(fun) == BUILTINSXP)) {
    PROTECT(expr = allocVector(LANGSXP, 2)); nprot++;
    SETCAR(expr, fun);
    arg = CDR(expr);
  } else if(TYPEOF(fun) == LANGSXP) {
    // From Tomas  Kalibera 20016-11-10
    PROTECT(expr = duplicate(fun)); nprot++;
    arg = CDR(expr);
  }

  for(i = 0; i < obj->nodeNr; i++) {
      xmlNodePtr el;
      el = obj->nodeTab[i];
      if(el->type == XML_ATTRIBUTE_NODE) {
#if 0
	  PROTECT(ref = mkString((el->children && el->children->content) ? XMLCHAR_TO_CHAR(el->children->content) : ""));
	  nprot++;
	  SET_NAMES(ref, mkString(el->name));
#else
	  PROTECT(ref = ScalarString(mkCharCE((el->children && el->children->content) ? XMLCHAR_TO_CHAR(el->children->content) : "", encoding)));
	  SET_NAMES(ref, ScalarString(mkCharCE(XMLCHAR_TO_CONST_CHAR(el->name), encoding)));
#endif
	  SET_CLASS(ref, mkString("XMLAttributeValue"));
	  UNPROTECT(1);
      } else if(el->type == XML_NAMESPACE_DECL)
	  ref = R_createXMLNsRef((xmlNsPtr) el);
      else
          ref = R_createXMLNodeRef(el, manageMemory);

    if(expr) {
      PROTECT(ref);
      SETCAR(arg, ref);
      PROTECT(ref = Rf_eval(expr, R_GlobalEnv)); /*XXX do we want to catch errors here? Maybe to release the namespaces. */
      SET_VECTOR_ELT(ans, i, ref);
      UNPROTECT(2);
    } else
      SET_VECTOR_ELT(ans, i, ref);
  }

  if(!expr)   // change from Tomas Kalibera 2016-11-10
    SET_CLASS(ans, mkString("XMLNodeSet"));

  UNPROTECT(nprot);

  return(ans);
}

SEXP
convertXPathObjectToR(xmlXPathObjectPtr obj, SEXP fun, int encoding, SEXP manageMemory)
{
  SEXP ans = NULL_USER_OBJECT;

  switch(obj->type) {

    case XPATH_NODESET:
        ans = convertNodeSetToR(obj->nodesetval, fun, encoding, manageMemory);
	break;
    case XPATH_BOOLEAN:
	ans = ScalarLogical(obj->boolval);
	break;
    case XPATH_NUMBER:
	ans = ScalarReal(obj->floatval);
	if(xmlXPathIsInf(obj->floatval))
	    REAL(ans)[0] = xmlXPathIsInf(obj->floatval) < 0 ? R_NegInf : R_PosInf;
        else if(xmlXPathIsNaN(obj->floatval))
	    REAL(ans)[0] = NA_REAL;
	break;
    case XPATH_STRING:
        ans = mkString(XMLCHAR_TO_CHAR(obj->stringval)); //XXX encoding
	break;
#ifdef LIBXML_XPTR_LOCS_ENABLED  // XXX check. Comes from CRAN.	
    case XPATH_POINT:
    case XPATH_RANGE:
    case XPATH_LOCATIONSET:
#endif 	
    case XPATH_USERS:
	Rf_warning("currently unsupported xmlXPathObject type %d in convertXPathObjectToR. Please send mail to maintainer.",
		   obj->type);

    default:
	ans = R_NilValue;
  }

  return(ans);
}


#include <libxml/xpathInternals.h> /* For xmlXPathRegisterNs() */
xmlNsPtr *
R_namespaceArray(SEXP namespaces, xmlXPathContextPtr ctxt)
{
 int i, n;
 SEXP names = GET_NAMES(namespaces);
 xmlNsPtr *els;

 n = GET_LENGTH(namespaces);
 els = xmlMallocAtomic(sizeof(xmlNsPtr) * n);

 if(!els) 
     Rf_error("Failed to allocated space for namespaces");

 for(i = 0; i < n; i++) {
/*XXX who owns these strings. */
   const xmlChar *prefix, *href;
   href = CHAR_TO_XMLCHAR(strdup(CHAR_DEREF(STRING_ELT(namespaces, i))));
   prefix = names == NULL_USER_OBJECT ?  CHAR_TO_XMLCHAR("") /* NULL */
                                      :  CHAR_TO_XMLCHAR(strdup(CHAR_DEREF(STRING_ELT(names, i))));
   els[i] = xmlNewNs(NULL, href, prefix);
   if(ctxt)
       xmlXPathRegisterNs(ctxt, prefix, href);
 }

 return(els);
}


#if R_XML_DEBUG_WEAK_REFS
SEXP LastDoc = NULL;

SEXP
R_isWeakRef(SEXP sdoc)
{
   void *ptr;
   if(sdoc == R_NilValue) {
       if(LastDoc == NULL)
	   return(R_NilValue);
       sdoc = LastDoc;
   }

   ptr = R_ExternalPtrAddr(sdoc);


   return(ScalarLogical(R_findExtPtrWeakRef(ptr)));
}
#endif

SEXP
R_addXMLInternalDocument_finalizer(SEXP sdoc, SEXP fun)
{
    R_CFinalizer_t action = NULL;
#if R_XML_DEBUG_WEAK_REFS
    LastDoc = sdoc;
#endif
    if(TYPEOF(fun) == CLOSXP) {
	R_RegisterFinalizer(sdoc, fun);
	return(sdoc);
    }

    if(fun == R_NilValue)    {
        action = R_xmlFreeDoc;
    } else if(TYPEOF(fun) == EXTPTRSXP)
	action = (R_CFinalizer_t) R_ExternalPtrAddr(fun);

    R_RegisterCFinalizer(sdoc, action);
#ifdef R_XML_DEBUG_WEAK_REFS
    void *ptr = R_ExternalPtrAddr(sdoc);
    int status = R_findExtPtrWeakRef(ptr);
    fprintf(stderr, "is weak ref %d\n", status);
#endif
    return(sdoc);
}


SEXP
R_XMLInternalDocument_free(SEXP sdoc)
{
  if(TYPEOF(sdoc) != EXTPTRSXP || R_ExternalPtrTag(sdoc) != Rf_install("XMLInternalDocument")) 
      Rf_error("R_free must be given an internal XML document object, 'XMLInternalDocument'");

  R_xmlFreeDoc(sdoc);

  return(sdoc);
}


/* This may go into the context object */
static SEXP R_AnonXPathFuns = NULL;

SEXP
RS_XML_xpathEval(SEXP sdoc, SEXP r_node, SEXP path, SEXP namespaces, SEXP fun, SEXP charEncoding,
		 SEXP manageMemory, SEXP xpathFuns, SEXP anonFuns)
{
 xmlXPathContextPtr ctxt = NULL;
 xmlXPathObjectPtr result;
 SEXP ans = NULL_USER_OBJECT;

 xmlDocPtr doc;

 if(TYPEOF(sdoc) != EXTPTRSXP || R_ExternalPtrTag(sdoc) != Rf_install("XMLInternalDocument"))
     Rf_error("xpathEval must be given an internal XML document object, 'XMLInternalDocument'");

 doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);
 ctxt = xmlXPathNewContext(doc);

 if(GET_LENGTH(r_node)) {
     ctxt->node = ctxt->origin = R_ExternalPtrAddr(r_node);
 }

 if(GET_LENGTH(namespaces)) {
     ctxt->namespaces =  R_namespaceArray(namespaces, ctxt); /* xmlCopyNamespaceList(doc); */
     ctxt->nsNr = GET_LENGTH(namespaces);
 }

 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "lower-case", xpathTolower);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "ends-with", xpathEndswith);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "matches", xpathGrepl);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "replace", xpathReplace);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "abs", xpathAbs);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "base-uri", xpathBaseURI);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "min", xpathMin);
 xmlXPathRegisterFunc(ctxt, (const xmlChar *) "max", xpathMax);

 R_AnonXPathFuns = anonFuns;
 if(Rf_length(xpathFuns)) {
     SEXP names = GET_NAMES(xpathFuns), el;
     int i;
     xmlXPathFunction routine;
     const xmlChar *id;
     for(i = 0; i < Rf_length(xpathFuns); i++) {
	 el = VECTOR_ELT(xpathFuns, i);
	 id = (names != R_NilValue) ? (const xmlChar *) CHAR(STRING_ELT(names, i)) : NULL;
	 if(TYPEOF(el) == EXTPTRSXP) {
	     routine = R_ExternalPtrAddr(el);
	     if(!id) 
		 Rf_error("no name for XPath function routine");
	 } else if(TYPEOF(el) == CLOSXP) {
	     routine = R_genericAnonXPathFun;
	 } else {
	     routine = R_genericXPathFun;
	     if(TYPEOF(el) == STRSXP)
		 id = (const xmlChar *) CHAR(STRING_ELT(el, 0));
	 }

	 xmlXPathRegisterFunc(ctxt, id,  routine);
     }
 }

 result = xmlXPathEvalExpression(CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(path, 0))), ctxt);

 if(result)
     ans = convertXPathObjectToR(result, fun, INTEGER(charEncoding)[0], manageMemory);

 xmlXPathFreeObject(result);
 xmlXPathFreeContext(ctxt);
 R_AnonXPathFuns = NULL;

 if(!result) 
     Rf_error("error evaluating xpath expression %s", CHAR_DEREF(STRING_ELT(path, 0)));

 return(ans);
}

USER_OBJECT_
RS_XML_createDocFromNode(USER_OBJECT_ s_node)
{
 xmlDocPtr doc;
 xmlNodePtr node, ptr;
 SEXP ans;

 node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
 doc = xmlNewDoc(CHAR_TO_XMLCHAR("1.0"));
 R_numXMLDocs++;

 ptr = xmlDocCopyNode(node, doc, 1);
 node = (xmlNodePtr) doc;
 xmlAddChild(node, ptr);

 ans = R_createXMLDocRef(doc);
 return(ans);
}

USER_OBJECT_
RS_XML_copyNodesToDoc(USER_OBJECT_ s_node, USER_OBJECT_ s_doc, USER_OBJECT_ manageMemory)
{
 xmlDocPtr doc;
 xmlNodePtr node, ptr;
 int len, i;
 SEXP ans;

 doc = (xmlDocPtr) R_ExternalPtrAddr(s_doc);

 if(TYPEOF(s_node) == EXTPTRSXP) {
     node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
     ptr = xmlDocCopyNode(node, doc, 1);
     return(R_createXMLNodeRef(ptr, manageMemory));
 }

 len = Rf_length(s_node);
 PROTECT(ans = NEW_LIST(len));
 for(i = 0; i < len; i++) {
     node = (xmlNodePtr) R_ExternalPtrAddr(VECTOR_ELT(s_node, i));
     ptr = xmlDocCopyNode(node, doc, 1);
     SET_VECTOR_ELT(ans, i, R_createXMLNodeRef(ptr, manageMemory));
 }
 UNPROTECT(1);
 return(ans);
}

/*
 Thoughts that we could set the kids to NULL and then free the doc
  after we createDocFromNode but the return of xpathApply will return
  these nodes and we need to be able to get to a document
 */
SEXP
RS_XML_killNodesFreeDoc(SEXP sdoc)
{
   xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);
   if(!doc) {
       Rf_warning("null xmlDocPtr passed as externalptr to RS_XML_killNodesFreeDoc");
       return(ScalarLogical(FALSE));
   }
   doc->children = NULL;
   xmlFree(doc);
   return(ScalarLogical(TRUE));
}


#if 0
SEXP
RS_XML_xpathNodeEval(SEXP s_node, SEXP path, SEXP namespaces, SEXP fun)
{
 xmlXPathContextPtr ctxt = NULL;
 xmlXPathObjectPtr result;
 SEXP ans = NULL_USER_OBJECT;

 xmlDocPtr doc;

 if(TYPEOF(s_node) != EXTPTRSXP || R_ExternalPtrTag(s_node) != Rf_install("XMLInternalNode")) 
     Rf_error("xpathEval must be given an internal XML document object, 'XMLInternalNode'");

 ctxt = xmlXPathNewContext(doc);

 if(GET_LENGTH(namespaces)) {
     ctxt->namespaces =  R_namespaceArray(namespaces, ctxt); /* xmlCopyNamespaceList(doc); */
     ctxt->nsNr = GET_LENGTH(namespaces);
 }

 result = xmlXPathEvalExpression(CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(path, 0))), ctxt);

 if(result)
     ans = convertXPathObjectToR(result, fun);

 xmlXPathFreeObject(result);
 xmlXPathFreeContext(ctxt);

 if(!result) 
     Rf_error("error evaluating xpath expression %s", CHAR_DEREF(STRING_ELT(path, 0)));

 return(ans);
}
#endif


SEXP
R_matchNodesInList(SEXP r_nodes, SEXP r_target, SEXP r_nomatch)
{
    xmlNodePtr el;
    int i, j, n, n2;
    SEXP ans;

    n = GET_LENGTH(r_nodes);
    n2 = GET_LENGTH(r_target);
    ans = NEW_INTEGER( n );
    for(i = 0; i < n ; i++) {
	el = R_ExternalPtrAddr(VECTOR_ELT(r_nodes, i));
	INTEGER(ans)[i] = INTEGER(r_nomatch)[0];
	for(j = 0; j < n2; j++) {
	    if(el == R_ExternalPtrAddr(VECTOR_ELT(r_target, j))) {
		INTEGER(ans)[i] = j;
		break;
	    }
	}
    }

    return(ans);
}



#if 0  /* taken from Sxslt and should be left there or moved here.*/

USER_OBJECT_
RXSLT_export_xmlXPathObject(xmlNodeSetPtr val, const char * className)
{
  USER_OBJECT_ ans;
  USER_OBJECT_ klass;
  PROTECT(klass = MAKE_CLASS(className));
  PROTECT(ans = NEW(klass));
  SET_SLOT(ans, Rf_install("ref"), R_MakeExternalPtr(val, Rf_install(className), R_NilValue));
  UNPROTECT(2);
  return(ans);
}


USER_OBJECT_
R_xmlXPathNewNodeSet(USER_OBJECT_ s_node)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);

    xmlXPathObjectPtr nodeset;
    nodeset = xmlXPathNewNodeSet(node);
    return(RXSLT_export_xmlXPathObject(nodeset->nodesetval, "XPathNodeSet"));
}

#endif



#include <ctype.h>

/*
 XXX Does not handle unicode in any way. Very simple-minded for now.
 */
void
xpathTolower(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(nargs == 0)
	return;

    xmlXPathObjectPtr obj = valuePop(ctxt);
    if (obj->type != XPATH_STRING) {
	valuePush(ctxt, obj);
	xmlXPathStringFunction(ctxt, 1);
	obj = valuePop(ctxt);
    }

    xmlChar *str = xmlStrdup(obj->stringval);

    // xmlChar *ptr = str;
    int i, n = xmlStrlen(str);
    for(i = 0; i < n ; i++)
	str[i] = (xmlChar) tolower(str[i]);

    valuePush(ctxt, xmlXPathNewString(str));
}

void
xpathEndswith(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(nargs < 2)
	return;

    xmlChar *pattern = xmlXPathPopString(ctxt);
    xmlChar *input = xmlXPathPopString(ctxt);

    int i, n = xmlStrlen(input), lenPattern = xmlStrlen(pattern);

    if(n < lenPattern)
	xmlXPathReturnBoolean(ctxt, 0);

    xmlChar *ptr = input + n - lenPattern;
    for(i = 0; i < lenPattern ; i++) {
	if(ptr[i] != pattern[i])
	    break;
    }

    xmlXPathReturnBoolean(ctxt, i == lenPattern);
}

void
xpathAbs(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(nargs < 1)
	return;

    double num = xmlXPathPopNumber(ctxt);
    xmlXPathReturnNumber(ctxt, num < 0 ? - num : num);
}

void
xpathBaseURI(xmlXPathParserContextPtr ctxt, int nargs)
{
    xmlDocPtr doc;
    if(nargs == 0) {
	doc = ctxt->context->doc;
    } else {
	xmlXPathObjectPtr obj = valuePop(ctxt);
	if(obj->type != XPATH_NODESET)
	    return;

	xmlNodePtr node = obj->nodesetval->nodeTab[0];
	doc = node->doc;
    }
    xmlXPathReturnString(ctxt, xmlStrdup((doc && doc->URL) ? doc->URL : (const xmlChar *) ""));
}


#define MIN(x, y) (x) < (y) ? (x) : (y)
#define MAX(x, y) (x) > (y) ? (x) : (y)

void
xpathExtreme(xmlXPathParserContextPtr ctxt, int nargs, int isMax)
{
    if(nargs < 1)
	return;

    double ans  = 0.;
    int set = 0;
    int i, a;
    xmlXPathObjectPtr obj;
    double tmp = 0.0;
    for(a = 0; a < nargs; a++) {
	obj = valuePop(ctxt);
	if(obj->type == XPATH_NODESET) {
	    for(i = 0; i < obj->nodesetval->nodeNr; i++) {
		tmp = xmlXPathCastNodeToNumber(obj->nodesetval->nodeTab[i]);
		if(set)
		    ans = isMax ? MAX(tmp, ans) : MIN(tmp, ans);
		else {
		    ans = tmp;
		    set = 1;
		}
	    }
	} else if(obj->type == XPATH_NUMBER) {
	    if(set)
		ans = isMax ? MAX(tmp, ans) : MIN(tmp, ans);
	    else {
		ans = tmp;
		set = 1;
	    }
	}
	xmlXPathFreeObject(obj);
    }

    xmlXPathReturnNumber(ctxt, ans);
}

void
xpathMin(xmlXPathParserContextPtr ctxt, int nargs)
{
    xpathExtreme(ctxt, nargs, 0);
}

void
xpathMax(xmlXPathParserContextPtr ctxt, int nargs)
{
    xpathExtreme(ctxt, nargs, 1);
}

void
xpathGrepl(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(nargs < 2)
	return;

    xmlChar *pattern = xmlXPathPopString(ctxt);
    xmlChar *input = xmlXPathPopString(ctxt);

    SEXP e = Rf_allocVector(LANGSXP, 3);
    PROTECT(e);
    SETCAR(e, Rf_install("grepl"));
    SETCAR(CDR(e), ScalarString(mkChar( (const char *) pattern)));
    SETCAR(CDR(CDR(e)), ScalarString(mkChar( (const char *) input)));

    SEXP ans = Rf_eval(e, R_GlobalEnv);

    xmlXPathReturnBoolean(ctxt, INTEGER(ans)[0]);
    UNPROTECT(1);
}

void
xpathReplace(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(nargs < 3)
	return;

    xmlChar *replacement = xmlXPathPopString(ctxt);
    xmlChar *pattern = xmlXPathPopString(ctxt);
    xmlChar *input = xmlXPathPopString(ctxt);

    SEXP e = Rf_allocVector(LANGSXP, 4);
    PROTECT(e);
    SEXP cur = e;
    SETCAR(e, Rf_install("gsub")); cur = CDR(cur);
    SETCAR(cur, ScalarString(mkChar( (const char *) pattern))); cur = CDR(cur);
    SETCAR(cur, ScalarString(mkChar( (const char *) replacement))); cur = CDR(cur);
    SETCAR(cur, ScalarString(mkChar( (const char *) input)));

    SEXP ans = Rf_eval(e, R_GlobalEnv);

    xmlXPathReturnString(ctxt, xmlStrdup( (const xmlChar *) CHAR(STRING_ELT(ans, 0))));
    UNPROTECT(1);
}




SEXP
convertXPathVal(xmlXPathObjectPtr xval)
{
    SEXP ans = R_NilValue;
    switch(xval->type) {
    case XPATH_BOOLEAN:
	ans = ScalarLogical(xval->boolval);
	break;
    case XPATH_NUMBER:
	ans = ScalarReal(xval->floatval);
	break;
    case XPATH_STRING:
	ans = ScalarString(mkChar( (const char *) xval->stringval));
	break;
    case XPATH_NODESET:
      {
	SEXP tmp = ScalarLogical(FALSE);
	PROTECT(tmp);
	ans = convertXPathObjectToR(xval, R_NilValue, 0, tmp);
	UNPROTECT(1);
      }
	break;
    default:
	Rf_warning("converting an XPath type %d to R not supported now", xval->type);
    }
    return(ans);
}

void
R_pushResult(xmlXPathParserContextPtr ctxt, SEXP ans)
{
    switch(TYPEOF(ans)) {
    case LGLSXP:
	xmlXPathReturnBoolean(ctxt, INTEGER(ans)[0]);
	break;
    case INTSXP:
	xmlXPathReturnNumber(ctxt, INTEGER(ans)[0]);
	break;
    case REALSXP:
	xmlXPathReturnNumber(ctxt, REAL(ans)[0]);
	break;
    case STRSXP:
	xmlXPathReturnString(ctxt, xmlStrdup((const xmlChar *) CHAR(STRING_ELT(ans, 0))));
	break;
    default:
	Rf_error("R type not supported as result of XPath function");
    }
}


void
R_callGenericXPathFun(xmlXPathParserContextPtr ctxt, int nargs, SEXP fun)
{
    SEXP e = Rf_allocVector(LANGSXP, nargs + 1);
    PROTECT(e);
    SETCAR(e, fun);

    SEXP cur = CDR(e);
    xmlXPathObjectPtr tmp;

    int j;
    for(int i = nargs ; i > 0; i--) {
        /* The arguments are on the stack with the last on the top, second to last next, and so on.
           So we have to add them to our expression starting at the end. */
	cur = e;
	for(j = 0 ; j < i; j++)  cur = CDR(cur);

	tmp = valuePop(ctxt);
	SETCAR(cur, convertXPathVal(tmp));
	xmlXPathFreeObject(tmp);
    }

    SEXP ans = Rf_eval(e, R_GlobalEnv);
    PROTECT(ans);

    R_pushResult(ctxt, ans);

    UNPROTECT(2);
}

void
R_genericAnonXPathFun(xmlXPathParserContextPtr ctxt, int nargs)
{
    if(!R_AnonXPathFuns || R_AnonXPathFuns == R_NilValue)
	return;

    int i, n = Rf_length(R_AnonXPathFuns);
    SEXP names = GET_NAMES(R_AnonXPathFuns);
    for(i = 0; i < n; i++) {
	if(strcmp((const char *) ctxt->context->function, CHAR(STRING_ELT(names, i))) == 0) {
	    R_callGenericXPathFun(ctxt, nargs, VECTOR_ELT(R_AnonXPathFuns, i));
	    return;
	}
    }
}

void
R_genericXPathFun(xmlXPathParserContextPtr ctxt, int nargs)
{
    SEXP f = Rf_install( (const char *) ctxt->context->function);
    PROTECT(f);
    R_callGenericXPathFun(ctxt, nargs, f);
    UNPROTECT(1);
}


