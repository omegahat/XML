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
	if(strcmp(ptr->prefix, prefix) == 0)
	    return(ptr);
	ptr = ptr->next;
    }

    return(NULL);
}
