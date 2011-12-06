#include "RS_XML.h"
#include "RSCommon.h"
#include <libxml/parser.h>
#include <libxml/xmlschemas.h>
#include <libxml/schemasInternals.h>

#include "Utils.h"

#if 0
#define R_GET_EXTERNAL_REF(type, name) \
type \
name(SEXP obj) \
{ \
   SEXP ref = GET_SLOT(obj, Rf_install("ref")); \
   if(TYPEOF(ref) != EXTPTRSXP) { \
      PROBLEM "Expected external pointer object" \
      ERROR; \
   } \
\
   if(R_ExternalPtrTag(ref) != Rf_install(#type)) { \
      PROBLEM "Expected external pointer to have internal tag %s, got %s",  \
               #type, PRINTNAME(ref) \
      ERROR; \
   } \
\
   return((type) R_ExternalPtrAddr(ref)); \
} 


R_GET_EXTERNAL_REF(xmlHashTablePtr, R_libxmlTypeTableGetRef)
R_GET_EXTERNAL_REF(xmlSchemaElementPtr, R_libxmlSchemaElementGetRef)
#endif


void *
R_getExternalRef(SEXP obj, const char *className) 
{
   SEXP ref = GET_SLOT(obj, Rf_install("ref")); 
   void *ans;

   if(TYPEOF(ref) != EXTPTRSXP) { 
      PROBLEM "Expected external pointer object" 
      ERROR; 
   } 

   if(className && R_ExternalPtrTag(ref) != Rf_install(className)) { 
      PROBLEM "Expected external pointer to have internal tag %s, got %s",  
  	     className, CHAR(PRINTNAME(R_ExternalPtrTag(ref)))
      ERROR; 
   } 

   ans = R_ExternalPtrAddr(ref);
   if(!ans) {
       PROBLEM "Got NULL value in reference for %s", className
       ERROR;
   }

   return(ans); 
} 






typedef struct {
   int pos;
   USER_OBJECT_ els;
   USER_OBJECT_ names;
   char *elType;
} HashGatherer;


static void
getKeys(void *el, void *data, xmlChar *name)
{
   HashGatherer *d = (HashGatherer *)data;
   SET_STRING_ELT(d->names, d->pos, COPY_TO_USER_STRING(name));
   if(d->elType) {
      SET_VECTOR_ELT(d->els, d->pos, R_makeRefObject(el, d->elType));
   }
   d->pos++;
}


USER_OBJECT_
R_libxmlTypeTable_names(USER_OBJECT_ table, USER_OBJECT_ s_elType)
{
   xmlHashTablePtr t;
   int n = 0, ctr = 0;
   int getElements = GET_LENGTH(s_elType) > 0;
   HashGatherer d = {0, NULL_USER_OBJECT, NULL_USER_OBJECT, NULL};

   t = R_getExternalRef(table, NULL); /* R_libxmlTypeTableGetRef(table); */

   n = xmlHashSize(t);
   PROTECT(d.names = NEW_CHARACTER(n)); ctr++;
   if(getElements) {
       PROTECT(d.els = NEW_LIST(n)); ctr++;
       d.elType = (char *) CHAR_DEREF(STRING_ELT(s_elType, 0));
   }
   xmlHashScan(t, getKeys, &d);

   if(getElements) 
     SET_NAMES(d.els, d.names);
   else
      d.els = d.names;

   UNPROTECT(ctr);
   return(d.els);
}


USER_OBJECT_
R_libxmlTypeTable_lookup(USER_OBJECT_ table, USER_OBJECT_ name, USER_OBJECT_ s_elType)
{
   xmlHashTablePtr t;
   USER_OBJECT_ ans;
   void *p;

   t = R_getExternalRef(table, NULL); /* R_libxmlTypeTableGetRef(table); */
   p = xmlHashLookup(t, CHAR_DEREF(STRING_ELT(name, 0)));
   ans = R_makeRefObject(p, CHAR_DEREF(STRING_ELT(s_elType, 0)));

   return(ans);
}


#define SchemaElement(id, type) \
USER_OBJECT_ \
R_libxmlTypeTable_##id(USER_OBJECT_ s) \
{ \
   xmlSchemaPtr schema; \
   schema = R_getExternalRef(s, "xmlSchemaRef"); \
\
   return(schema->id != NULL ? R_makeRefObject(schema->id, type) : R_NilValue);	\
} 

SchemaElement(elemDecl, "SchemaElementTable")
SchemaElement(typeDecl, "SchemaTypeTable")
SchemaElement(attrDecl, "SchemaAttributeTable")
SchemaElement(attrgrpDecl, "SchemaAttributeGroupTable")
SchemaElement(notaDecl, "SchemaNotationTable")

/*
USER_OBJECT_
R_libxmlTypeTable_elemDecl(USER_OBJECT_ s)
{
   xmlSchemaPtr schema;
   schema = R_getExternalRef(s, "xmlSchemaRef");

   return(R_makeRefObject(schema->typeDecl, "SchemaElementTable"));
}
*/


#include <stdarg.h>

typedef struct {
    SEXP fun;
} R_SchemaValidCallback;

void
R_schemaValidityFunctionCall(R_SchemaValidCallback *ctx, int warning, const char *msg, va_list args)
{
    SEXP arg;
    char buf[10000];
    vsnprintf(buf, sizeof(buf)/sizeof(buf[0]), msg, args);
    PROTECT(arg = mkString(buf));
    SET_CLASS(arg, mkString(warning ? "XMLSchemaWarning" : "XMLSchemaError"));
    SETCAR(CDR(ctx->fun), arg);
    Rf_eval(ctx->fun, R_GlobalEnv);
    UNPROTECT(1);
}


void
R_schemaValidityErrorFunc(R_SchemaValidCallback *ctx, const char *msg, ...)
{
    va_list args;
    va_start(args, msg);
    R_schemaValidityFunctionCall(ctx, 0, msg, args);
    va_end(args);
}

void
R_schemaValidityWarningFunc(R_SchemaValidCallback *ctx, const char *msg, ...)
{
    va_list args;
    va_start(args, msg);
    R_schemaValidityFunctionCall(ctx, 1, msg, args);
    va_end(args);
}


SEXP 
RS_XML_xmlSchemaValidateDoc(SEXP r_schema, SEXP r_doc, SEXP r_options, SEXP r_errorHandlers)
{
    xmlSchemaValidCtxtPtr ctxt;
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);
    xmlSchemaPtr schema = (xmlSchemaPtr) R_ExternalPtrAddr(r_schema);
//    ctxt = (xmlSchemaValidCtxtPtr) R_ExternalPtrAddr(r_ctxt);

    int status;
    int numErrHandlers;

    ctxt = xmlSchemaNewValidCtxt(schema);
    if(LENGTH(r_options))
	xmlSchemaSetValidOptions(ctxt, INTEGER(r_options)[0]);

    numErrHandlers = Rf_length(r_errorHandlers);
    if(numErrHandlers > 0) {
	R_SchemaValidCallback cbinfo;
	PROTECT(cbinfo.fun = allocVector(LANGSXP, 2));
	SETCAR(cbinfo.fun, VECTOR_ELT(r_errorHandlers, 0));
	xmlSchemaSetValidErrors(ctxt, (xmlSchemaValidityErrorFunc) R_schemaValidityErrorFunc, 
                                      (xmlSchemaValidityWarningFunc) R_schemaValidityWarningFunc, &cbinfo);
    }

    status = xmlSchemaValidateDoc(ctxt, doc);
    xmlSchemaFreeValidCtxt(ctxt); /* R_alloc this if possible. */
    if(numErrHandlers > 0) 
	UNPROTECT(1);

    return(ScalarInteger(status));
}


#if 0
SEXP
RS_XML_xmlSchemaNewValidCtxt(SEXP r_schema, SEXP r_options, SEXP r_errorHandlers)
{
    xmlSchemaPtr schema = (xmlSchemaPtr) R_ExternalPtrAddr(r_schema);
    xmlSchemaValidCtxtPtr ctxt;
    int numErrHandlers;
    ctxt = xmlSchemaNewValidCtxt(schema);
    if(LENGTH(r_options))
	xmlSchemaSetValidOptions(ctxt, INTEGER(r_options)[0]);

    numErrHandlers = LENGTH(r_errorHandlers);
    if(numErrHandlers > 0) {
	R_SchemaValidCallback *cbinfo = (R_SchemaValidCallback*) malloc(sizeof(R_SchemaValidCallback));
	cbinfo->fun = VECTOR_ELT(r_errorHandlers);
	xmlSchemaSetValidErrors(routine);
    }
    
    return();
}
#endif
