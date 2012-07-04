#include <libxml/tree.h>

#include "RSCommon.h"
#include "RS_XML.h"

#define R_USE_XML_ENCODING 1
#include "Utils.h"  /* R_createXMLNodeRef, Encoding macros. */

// need to release any <dummy> namespace.


int fixDummyNS(xmlNodePtr node, int recursive);
int setDummyNS(xmlNodePtr node, const xmlChar *prefix);
xmlNs *findNSByPrefix(xmlNodePtr node, const xmlChar *prefix);

SEXP
R_fixDummyNS(SEXP r_node, SEXP r_recursive)
{
    xmlNodePtr node;
    int status;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);	
    status = fixDummyNS(node, LOGICAL(r_recursive)[0]);
    return(ScalarInteger(status));
}

int
fixDummyNS(xmlNodePtr node, int recursive)
{
    xmlNs *ns = node->ns;
    int count = 0;

    if(ns && strcmp(ns->href, "<dummy>") == 0)
	count = setDummyNS(node, ns->prefix);

    if(recursive)  {
	xmlNodePtr ptr = node->children;
	while(ptr) {
	    count += fixDummyNS(ptr, recursive);
	    ptr = ptr->next;
	}
    }

    return(count);
}

int
setDummyNS(xmlNodePtr node, const xmlChar *prefix)
{
    xmlNodePtr a = node->parent;
    while(a) {
	xmlNs *ns;
	ns = findNSByPrefix(a, prefix);
	if(ns) {
#ifdef R_XML_DEBUG
	    fprintf(stderr, "mapping %s to %s\n", prefix, ns->href);fflush(stderr);
#endif
	    node->nsDef = node->nsDef->next;
	    xmlSetNs(node, ns);
	    return(1);
	}
	a = a->parent;
    }
    return(0);
}


xmlNs *
findNSByPrefix(xmlNodePtr node, const xmlChar *prefix)
{
    xmlNs *ptr = node->nsDef;
    while(ptr) {
	if((!prefix || !prefix[0]) && !ptr->prefix)
	    return(ptr);

	if(prefix && ptr->prefix && strcmp(ptr->prefix, prefix) == 0)
	    return(ptr);
	ptr = ptr->next;
    }

    return(NULL);
}


void
setDefaultNs(xmlNodePtr node, xmlNsPtr ns, int recursive)
{
    if(!node->ns)
	xmlSetNs(node, ns);
    if(recursive) {
	xmlNodePtr cur = node->children;
	while(cur) {
	    setDefaultNs(cur, ns, 1);
	    cur = cur->next;
	}
    }
}


SEXP
R_getAncestorDefaultNSDef(SEXP r_node, SEXP r_recursive)
{
   xmlNodePtr cur, node;
   xmlNs *ans = NULL;
   cur = (xmlNodePtr) R_ExternalPtrAddr(r_node);

   node = cur->parent;

   while(node && (node->type != XML_DOCUMENT_NODE && 
		  node->type != XML_HTML_DOCUMENT_NODE)) {  /* Need to check for HTML_DOC or XML_DOC ?*/
       ans = findNSByPrefix(node, NULL);
       if(ans)
	   break;
       node = node->parent;
   }

   if(ans) {
       xmlSetNs(cur, ans);
       if(LOGICAL(r_recursive)[0]) {
	   setDefaultNs(cur, ans, 1);
       }
       return(ScalarLogical(1)); // R_createXMLNsRef(ans));
   }

   return(R_NilValue);
}

