/**
 The purpose of this file is to provide the C-level facilities
 to create, modify and manage internal XML DOM nodes at the S
 language level. We want to be able to use the interface defined
 by xmlOutputDOM() and xmlOutputBuffer() but with an implementation
 that returns a tree that is built to be used with the libxml 
 data structures. So the intent is to incrementally add nodes
 to the tree in memory and then pass this to libxml to add it to 
 another tree or write it to a file, etc.

  The essential public/high-level functionality provided by the the S-leve interface 
  for building trees consists of:
 
   1) addTag
   2) closeTag
   3) addComment
   4) value

 addNode

   a) getOpenTag
   b) reset
 */

#include "RSCommon.h"
#include "RS_XML.h"


#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parserInternals.h>
#include <gnome-xml/xmlmemory.h>
#else
#include <libxml/parserInternals.h>
#include <libxml/xmlmemory.h>
#include <libxml/HTMLtree.h>
#endif


#define R_USE_XML_ENCODING 1
#include "Utils.h"  /* R_createXMLNodeRef, Encoding macros. */

#include "NodeGC.h"

#ifdef USE_OLD_ROOT_CHILD_NAMES
# define XML_ROOT(n) (n)->childs
#else
# define XML_ROOT(n) (n)->xmlRootNode
#endif

void incrementDocRef(xmlDocPtr doc);
int getNodeCount(xmlNodePtr node);
void incrementDocRefBy(xmlDocPtr doc, int num);

void RS_XML_recursive_unsetListDoc(xmlNodePtr list);


/**
 Create a libxml comment node and return it as an S object
 referencing this value.
*/

USER_OBJECT_
R_xmlNewComment(USER_OBJECT_ str, USER_OBJECT_ sdoc, USER_OBJECT_ manageMemory)
{
    xmlNodePtr node;
    xmlDocPtr doc = NULL;
    xmlChar *txt;

    if(GET_LENGTH(sdoc))
	doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

    txt = CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(str, 0)));
    node =  doc ? xmlNewDocComment(doc, txt) : xmlNewComment(txt);

    return(R_createXMLNodeRef(node, manageMemory));  
}

USER_OBJECT_
R_newXMLTextNode(USER_OBJECT_ value, USER_OBJECT_ sdoc, SEXP manageMemory)
{
   xmlNodePtr node;
    xmlDocPtr doc = NULL;
    xmlChar *txt;
    
    if(GET_LENGTH(sdoc))
	doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

    txt = CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(value, 0)));
    if(doc)
	node = xmlNewDocTextLen(doc, txt, strlen(XMLCHAR_TO_CHAR(txt)));
    else
	node = xmlNewText(txt);
	
    return(R_createXMLNodeRef(node, manageMemory));
}

USER_OBJECT_
R_newXMLCDataNode(USER_OBJECT_ sdoc, USER_OBJECT_ value, USER_OBJECT_ manageMemory)
{
  xmlDocPtr  doc = NULL;
  xmlNodePtr node;
  const char *tmp;

  if(GET_LENGTH(sdoc))
    doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

  tmp = CHAR_DEREF(STRING_ELT(value,0));

  node = xmlNewCDataBlock(doc, CHAR_TO_XMLCHAR(tmp), strlen(tmp));

  return(R_createXMLNodeRef(node, manageMemory));
}


USER_OBJECT_
R_newXMLPINode(USER_OBJECT_ sdoc, USER_OBJECT_ name, USER_OBJECT_ content, USER_OBJECT_ manageMemory)
{
  xmlNodePtr node;

  node = xmlNewPI(CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(name, 0))), CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(content, 0))));
  return( R_createXMLNodeRef(node, manageMemory) ); 
}


USER_OBJECT_
R_newXMLNode(USER_OBJECT_ name, USER_OBJECT_ attrs, USER_OBJECT_ nameSpace, USER_OBJECT_ sdoc,
              USER_OBJECT_ nameSpaceDefinitions, USER_OBJECT_ manageMemory)
{
   xmlDocPtr doc = NULL;
   xmlNsPtr ns = NULL;
   xmlNodePtr node;

   if(GET_LENGTH(sdoc)) {
       doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

       if(doc->type != XML_DOCUMENT_NODE && doc->type != XML_HTML_DOCUMENT_NODE) 
	   doc = doc->doc;
   }

    
   if(GET_LENGTH(nameSpace) > 0) {
       /* Need the default namespace and then also any other */
      CHAR_DEREF(STRING_ELT(nameSpace, 0));
   }

   node = xmlNewDocNode(doc, ns, CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(name, 0))), NULL);

   if(doc && XML_ROOT(doc) == NULL) {
       XML_ROOT(doc) = node;
   }

   return( R_createXMLNodeRef(node, manageMemory) );
}

USER_OBJECT_
RS_XML_getNextSibling(USER_OBJECT_ s_node, USER_OBJECT_ s_prev, USER_OBJECT_ manageMemory)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node), ptr;

    ptr = LOGICAL(s_prev)[0] ? node->next : node->prev;

    return(ptr ? R_createXMLNodeRef(ptr, manageMemory) : NULL_USER_OBJECT);
}


/*
  Add attributes to an existing node.
  At present, doesn't check for duplicates.
  Can do this in C or in R, but need to remove existing values, 
  and ensure that namespace considerations are handled properly.
 */
USER_OBJECT_
RS_XML_addNodeAttributes(USER_OBJECT_ s_node, USER_OBJECT_ attrs)
{
    int i, n;
    USER_OBJECT_ attr_names;
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);

    n = GET_LENGTH(attrs);
    attr_names = GET_NAMES(attrs);
    for(i = 0; i < n; i++) {
	xmlSetProp(node, CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(attr_names, i))), CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(attrs, i))));
    }
    
    return(ScalarInteger(n));
}

USER_OBJECT_
RS_XML_setNodeName(USER_OBJECT_ s_node, USER_OBJECT_ s_name)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    xmlChar *name = CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(s_name, 0)));
    xmlNodeSetName(node, name);

    return(NULL_USER_OBJECT);
}


#if 0
int
removeNodeNamespace(xmlNodePtr node, xmlNsPtr p)
{
    if(!p) 
	return(0);

    if(!node->prev)
	node->ns = p->next;
    else
	p->v->next = p->next;

    return(1);
}
#endif

int
removeNodeNamespaceByName(xmlNodePtr node, const char * const id)
{
    xmlNsPtr p, prev;

    if(!node->nsDef)
	return(0);
    prev = node->nsDef;
    p = node->nsDef;
    if(!(id[0] && !p->prefix) || (p->prefix && strcmp(p->prefix, id) ==  0)) {
                /*XXX Free or not */
        if(node->ns == p)
	    node->ns = NULL;
	node->nsDef = p->next;
	return(1);
    }

    while(1) {
	if((!id[0] && !p->prefix) || (p->prefix && strcmp(p->prefix, id) == 0)) {
	    prev->next = p->next;
	    if(node->ns == p)
		node->ns = NULL;
	    return(1);
	}
	prev = p;
	p = p->next;
    }

    return(0);
}

SEXP
R_replaceDummyNS(USER_OBJECT_ s_node, USER_OBJECT_ newNS, USER_OBJECT_ prefix)
{
    xmlNodePtr node;
    if(TYPEOF(s_node) != EXTPTRSXP) {
	PROBLEM "non external pointer passed to R_replaceDummyNS"
	    ERROR;
    }
	
    node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    removeNodeNamespaceByName(node, CHAR(STRING_ELT(prefix, 0)));
    
    return(R_xmlSetNs(s_node, newNS, ScalarLogical(0))); 
//    return(newNS);
}


SEXP 
RS_XML_removeAllNodeNamespaces(SEXP s_node)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    xmlNsPtr p, tmp;
    int n = 0;

    if(!node)
	return(ScalarLogical(FALSE));	

    p = node->nsDef;
    while(p) {
	if(node->ns == p) {
	    node->ns = NULL;
	}
	tmp = p;
	p = p->next;
	if(0 && tmp->type)
	   xmlFreeNs(tmp); 
	n++;
    }
    node->nsDef = NULL;

    return(ScalarInteger(n));
}

SEXP 
RS_XML_removeNodeNamespaces(SEXP s_node, SEXP r_ns)
{
    int i, n;
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    SEXP el, ans;
    const char *prefix;
//    xmlNsPtr p;
//    int t = TYPEOF(r_ns);
    n = Rf_length(r_ns);
    PROTECT(ans = allocVector(LGLSXP, n));

    for(i = 0; i < n; i++) {
	el = VECTOR_ELT(r_ns, i);
	if(TYPEOF(el) == STRSXP) {
	   prefix = CHAR(STRING_ELT(el, 0));
	    LOGICAL(ans)[i] = removeNodeNamespaceByName(node, prefix);
	} else if(TYPEOF(el) == EXTPTRSXP) {
	    xmlNsPtr p = (xmlNsPtr) R_ExternalPtrAddr(el);
	    LOGICAL(ans)[i] = removeNodeNamespaceByName(node, p->prefix);
	}
    }

    UNPROTECT(1);
    return(ans);
}


/*
    attrs is a vector whose names identify
 */
USER_OBJECT_
RS_XML_removeNodeAttributes(USER_OBJECT_ s_node, USER_OBJECT_ attrs, USER_OBJECT_ asNamespace)
{
    int i, n;
    USER_OBJECT_ attr_names, ans;
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);

    n = GET_LENGTH(attrs);
    PROTECT(ans = NEW_LOGICAL(n));
    
    attr_names = GET_NAMES(attrs);
    for(i = 0; i < n; i++) {
	if(TYPEOF(attrs) == INTSXP) {
	    int which = INTEGER(attrs)[i] - i - 1;
	    xmlAttrPtr p;
	    int j = 0; 
	    
		p = node->properties;
		while(j < which && p) {
		    p = p->next;
                    j++;
		}
		xmlUnsetNsProp(node, p->ns, p->name);
/*
            if(p)
		xmlFree(p);
*/
	} else if(LOGICAL(asNamespace)[0]) {
	    xmlNsPtr ns = NULL;
	    xmlChar *id;
	    id = CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(attr_names, i)));
	    ns = (xmlNsPtr) R_ExternalPtrAddr(VECTOR_ELT(attrs, i));
	    if(id[0])
		INTEGER(ans)[i] = xmlUnsetNsProp(node, ns, id);
	} else
	    INTEGER(ans)[i] = xmlUnsetProp(node, CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(attrs, i))));
                             
    }
    UNPROTECT(1);
    
    return(ans);
}

#define GET_R_XML_NODE_PTR(x)   (xmlNodePtr) R_ExternalPtrAddr(s_node);


USER_OBJECT_
RS_XML_getNsList(USER_OBJECT_ s_node, USER_OBJECT_ asRef)
{
    xmlNodePtr node = GET_R_XML_NODE_PTR(s_node);
    xmlNsPtr *els, el;
    int n = 0, i;
    USER_OBJECT_ ans, names;
    DECL_ENCODING_FROM_NODE(node)

    els = xmlGetNsList(node->doc, node);
    if(!els) 
	return(NULL_USER_OBJECT);

    el = *els;
    while(el) {
	n++;
	el = el->next;
    }
    el = *els;

    if(LOGICAL(asRef)[0]) {
	PROTECT(ans = NEW_LIST(n));	
	PROTECT(names = NEW_CHARACTER(n));    
	for(i = 0; i < n ; i++, el = el->next) {
	    if(el->prefix)
		SET_STRING_ELT(names, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(el->prefix)));
	    SET_VECTOR_ELT(ans, i, R_createXMLNsRef(el));
	}
    } else {
	
	PROTECT(ans = NEW_CHARACTER(n));
	PROTECT(names = NEW_CHARACTER(n));    
	for(i = 0; i < n ; i++, el = el->next) {
	    if(el->prefix)
		SET_STRING_ELT(names, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(el->prefix)));
	    if(el->href)
   	        SET_STRING_ELT(ans, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(el->href)));
	}
    }

    SET_NAMES(ans, names);
    UNPROTECT(2);
    return(ans);
}

SEXP
R_removeInternalNode(SEXP r_node, SEXP r_free)
{
    xmlNodePtr node;
    int n = GET_LENGTH(r_node), i;

    for(i = 0; i < n; i++) {
	SEXP el = VECTOR_ELT(r_node, i);
	if(TYPEOF(el) != EXTPTRSXP) {
	    PROBLEM "removeInternalNode needs ans external pointer object"
	    ERROR;
	}

	node = (xmlNodePtr) R_ExternalPtrAddr(el);
	if(!node) {
	    PROBLEM "removeInternalNode ignoring a NULL external pointer object"
		WARN;	
	}
	xmlUnlinkNode(node);
    
	if(LOGICAL(r_free)[i])
	    xmlFreeNode(node);
    }

    return(NULL_USER_OBJECT);
}

SEXP
RS_XML_setRootNode(USER_OBJECT_ r_doc, USER_OBJECT_ r_node)
{
    xmlDocPtr doc;
    xmlNodePtr node;

    doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);

    /*  Set the reference counting information. */
    //if(!node->doc)
    //    node->doc = doc;
    xmlDocSetRootElement(doc, node);

    return(ScalarLogical(TRUE));
}

SEXP
R_isNodeChildOfAt(SEXP rkid, SEXP rnode, SEXP rat)
{
    int i=0, at;
    xmlNodePtr kid, node, ptr;
    node = (xmlNodePtr) R_ExternalPtrAddr(rnode);	
    kid = (xmlNodePtr) R_ExternalPtrAddr(rkid);	

    if(!node || !kid || !kid->parent)
	return(ScalarLogical(FALSE));

    at = INTEGER(rat)[0] - 1;
    ptr = node->children;
    while(i < at && ptr)  {
	ptr = ptr->next;
	i++;
    }
    return(ScalarLogical(ptr == kid));
}


/**
   Add the internal XML node represented by the S object @node
   as a child of the XML node represented by the S object @parent.
 */
USER_OBJECT_
R_insertXMLNode(USER_OBJECT_ node, USER_OBJECT_ parent, USER_OBJECT_ at, USER_OBJECT_ shallow)
{
    xmlNodePtr n, p, check, tmp = NULL;
    
    if(TYPEOF(parent) != EXTPTRSXP) {
       PROBLEM "R_insertXMLNode expects XMLInternalNode objects for the parent node"
       ERROR;
    }

    if(IS_LIST(node))  {
      int i;
      for(i = 0; i < GET_LENGTH(node); i++)
	  R_insertXMLNode(VECTOR_ELT(node, i), parent, R_NilValue/*XXX*/, shallow);

      return(NULL_USER_OBJECT);
    }


    if(TYPEOF(node) == STRSXP) {
        int i;
	p = (xmlNodePtr) R_ExternalPtrAddr(parent);	
	for(i = 0; i < GET_LENGTH(node); i++) {
  	    n = xmlNewText(CHAR(STRING_ELT(node, i)));
   	    xmlAddChild(p, n);
	}
	return(NULL_USER_OBJECT);
    }

    if(TYPEOF(node) != EXTPTRSXP) {
       PROBLEM "R_insertXMLNode expects XMLInternalNode objects"
       ERROR;
    }

    p = (xmlNodePtr) R_ExternalPtrAddr(parent);
    n = (xmlNodePtr) R_ExternalPtrAddr(node);

    if(!p || !n) {
	PROBLEM "either the parent or child node is NULL"
        ERROR;
    }

#if 0
    if(0 && n->parent == p || n->parent) {
      /*XX Need to decrement the reference count if there is a document. */
	xmlUnlinkNode(n);
    }
#endif 

      /* Make certain the nodes belong to this document if they already belong to another by copying. */
    if(n->doc && n->doc != p->doc) {
	n = xmlDocCopyNode(n, p->doc, 1);
    } else if(!n->doc && LOGICAL(shallow)[0]) {
	/* XXX This is intended to avoid setting all the nodes to this document and then having to undo that
                later on.*/
      n->doc = p->doc;
    }

    
    
    switch(p->type) {
    case XML_ELEMENT_NODE:
	/* Need to be careful that if n is a text node, it could be
	 * absorbed into its nearest sibling and then freed. So we
           take a copy of the text node*/
	if(n->type == XML_TEXT_NODE) {
	    tmp = xmlNewText(n->content);
	    /* tmp = xmlCopyNode(n, 1); */
	} else {
	    tmp = n;

            if(n->_private) {
#ifdef R_XML_DEBUG
               fprintf(stderr, "insertXMLNode: %p to %p, incrementing document (%p)  %d\n", n, p, p->doc, *(int *) n->_private);
#endif
	       if(p->doc)
 	           incrementDocRefBy(p->doc, getNodeCount(n));
            }
	}
	check = xmlAddChild(p, tmp);

#if 0
/* XXXX */
	if(n->type == XML_TEXT_NODE && check != tmp)
	    xmlFreeNode(tmp);
#endif
	break;
    case XML_DOCUMENT_NODE:	
    case XML_HTML_DOCUMENT_NODE:	
	check = xmlAddChild(p, n);
	incrementDocRef((xmlDocPtr) p);
	break;
    case XML_PI_NODE:
	xmlAddSibling(p, n);
	break;
    default:
       {
	   PROBLEM "ignoring request to add child (types parent: %d, child %d)",
               p->type, n->type
	    WARN
       }
	break;
    }

#if 0
    /* This is where we handle the case where n being a text node may
     * have been freed by xmlAddChild. */
    if(check != n) {
	fprintf(stderr, "xmlAddChild() may have freed the node\n");fflush(stderr);
	R_ClearExternalPtr(node);
    }
#endif


    /* ??? internal_incrementNodeRefCount(n); */

    return(NULL_USER_OBJECT);     
}

USER_OBJECT_
RS_XML_xmlAddSiblingAt(USER_OBJECT_ r_to, USER_OBJECT_ r_node, USER_OBJECT_ r_after, USER_OBJECT_ manageMemory)
{
    xmlNodePtr p, n, ans;
    
    xmlNodePtr (*f)(xmlNodePtr, xmlNodePtr);

    if(TYPEOF(r_to) != EXTPTRSXP) {
       PROBLEM "RS_XML_xmlAddSiblingAt expects XMLInternalNode objects for the parent node"
       ERROR;
    }

    if(TYPEOF(r_node) != EXTPTRSXP) {
       PROBLEM "RS_XML_xmlAddSiblingAt expects XMLInternalNode objects for the node to add"
       ERROR;
    }

    p = (xmlNodePtr) R_ExternalPtrAddr(r_to);
    n = (xmlNodePtr) R_ExternalPtrAddr(r_node);

    if(!p || !n) {
	PROBLEM "either the parent or child node is NULL"
        ERROR;
    }
	
    f = LOGICAL(r_after)[0] ?  xmlAddNextSibling : xmlAddPrevSibling ;
    ans = f(p, n);

    /* If adding to the root node and inserting a node before the
     * current first child, update the document.*/
    if(p->doc && p->doc->children == p && n->next == p)
	p->doc->children = n;

    incrementDocRefBy(p->doc, getNodeCount(n));
    return(R_createXMLNodeRef(ans, manageMemory));
}

USER_OBJECT_
RS_XML_replaceXMLNode(USER_OBJECT_ r_old, USER_OBJECT_ r_new, USER_OBJECT_ manageMemory)
{
    xmlNodePtr Old, New, ans;

    if(TYPEOF(r_old) != EXTPTRSXP && TYPEOF(r_new) != EXTPTRSXP) {
       PROBLEM "R_replaceXMLNode expects XMLInternalNode objects"
       ERROR;
    }
    Old = (xmlNodePtr) R_ExternalPtrAddr(r_old);
    New = (xmlNodePtr) R_ExternalPtrAddr(r_new);

    if(!Old) {
	PROBLEM "NULL value for XML node to replace"
	    ERROR;
    }

    ans = xmlReplaceNode(Old, New);
    return(R_createXMLNodeRef(ans, manageMemory));  
}


/*
  a = newXMLNode("a", newXMLNode("b", newXMLNode("c", 3)), newXMLNode("d", "text"))
  removeChildren(a, 2)
 */
USER_OBJECT_
RS_XML_removeChildren(USER_OBJECT_ s_node, USER_OBJECT_ kids, USER_OBJECT_ freeNode)
{
    int i, n;
    USER_OBJECT_ ans;
    xmlNodePtr node = NULL, tmp;
    if(GET_LENGTH(s_node)) {
	node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    
	if(!node) {
	    PROBLEM "Empty XMLInternalNode"
		ERROR;
	}
    }
    
    n = GET_LENGTH(kids);
    PROTECT(ans = NEW_LOGICAL(n));
    for(i = 0; i < n; i++) {
	tmp = (xmlNodePtr)  R_ExternalPtrAddr(VECTOR_ELT(kids, i));
	if(!tmp)
	    continue;
	if(node && tmp->parent != node) {
	    PROBLEM "trying to remove a child node from a different parent node"
   	     ERROR;
	}

	xmlUnlinkNode(tmp);
	if(LOGICAL(freeNode)[0])
	    xmlFreeNode(tmp);
	LOGICAL(ans)[i]  = TRUE;
    }
    UNPROTECT(1);

    return(ans);
}

USER_OBJECT_
R_xmlRootNode(USER_OBJECT_ sdoc, USER_OBJECT_ skipDtd, USER_OBJECT_ manageMemory)
{
  xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);
  xmlNodePtr node = NULL;

  if(doc)
      node = doc->children;
  
  if(!node) {
      PROBLEM "empty XML document"
	  WARN;
      return(NULL_USER_OBJECT);
  }

  if(LOGICAL(skipDtd)[0]) {
      while(node && node->type != XML_ELEMENT_NODE /* (node->type == XML_DTD_NODE || node->type == XML_COMMENT_NODE) */) {
	  node = node->next;
      }
  }

  if(node == NULL) 
      return(NULL_USER_OBJECT);


  return(R_createXMLNodeRef(node, manageMemory));  
}


/**
 Create an S object representing a newly created internal 
 XML document object.
 */

int R_numXMLDocs = 0;
int R_numXMLDocsFreed = 0;

USER_OBJECT_
R_newXMLDoc(USER_OBJECT_ dtd, USER_OBJECT_ namespaces, USER_OBJECT_ isHTML)
{
  xmlDocPtr doc;
  if(LOGICAL(isHTML)[0]) {
      const char *d = (TYPEOF(dtd) == STRSXP && Rf_length(dtd)) ? 
                                CHAR_DEREF(STRING_ELT(dtd, 0)) : NULL;
      if(d[0] == '5')
	  doc = htmlNewDoc("", NULL);
      else
	  doc = htmlNewDocNoDtD(d && d[0] ? CHAR_TO_XMLCHAR(d) : NULL, NULL);

  } else
      doc = xmlNewDoc(CHAR_TO_XMLCHAR("1.0"));

  R_numXMLDocs++;

  return(R_createXMLDocRef(doc));
}




USER_OBJECT_
R_newXMLDtd(USER_OBJECT_ sdoc, USER_OBJECT_ sdtdName, USER_OBJECT_ sexternalID, USER_OBJECT_ ssysID, USER_OBJECT_ manageMemory)
{

    xmlDocPtr doc = NULL;
    xmlChar *dtdName = NULL;
    xmlChar *externalID = NULL;
    xmlChar *sysID = NULL;
    xmlDtdPtr node;

#define  GET_STR_VAL(x)  \
    if(GET_LENGTH(s##x) > 0) { \
   	   x =  CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(s##x, 0)));	\
           if(!x[0]) \
               x = NULL; \
    }

    GET_STR_VAL(dtdName)
    GET_STR_VAL(externalID)
    GET_STR_VAL(sysID)

    if(sdoc != NULL_USER_OBJECT && TYPEOF(sdoc) == EXTPTRSXP)
      doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

    node = xmlNewDtd(doc, dtdName, externalID, sysID);


/* should we do this???
      xmlAddChild((xmlNodePtr) doc, (xmlNodePtr) DTD); 
*/
    return(R_createXMLNodeRef((xmlNodePtr) node, manageMemory));
}


/*

 */
USER_OBJECT_
R_xmlSetNs(USER_OBJECT_ s_node, USER_OBJECT_ s_ns, USER_OBJECT_ append)
{
  xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
  xmlNsPtr ns = NULL;
  if(s_ns != NULL_USER_OBJECT)
      ns = (xmlNsPtr) R_ExternalPtrAddr(s_ns);

  if(LOGICAL(append)[0]) {
      xmlNsPtr el;
      if(!node->ns)  
	  xmlSetNs(node, xmlNewNs(node, NULL, NULL));
      el = node->ns;
      while(el->next) 
	  el = el->next;
      el->next = ns;
  } else  
      xmlSetNs(node, ns);

  return(s_ns);
}

#if 0
/* remove if the above is sufficient. */
SEXP
RS_XML_setNS(SEXP s_node, SEXP r_ns)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    xmlNsPtr ns = (xmlNsPtr) R_ExternalPtrAddr(r_ns);
    xmlSetNS(node, ns);
    return(NULL_USER_OBJECT);
}
#endif


static const char *DummyNamespaceHREF = "<dummy>";

USER_OBJECT_
R_xmlNewNs(USER_OBJECT_ sdoc, USER_OBJECT_ shref, USER_OBJECT_ sprefix)
{
  xmlNodePtr doc = (xmlNodePtr) R_ExternalPtrAddr(sdoc);
  const char *href = Rf_length(shref) == 0 ? DummyNamespaceHREF : CHAR_DEREF(STRING_ELT(shref, 0));
  const char *prefix = NULL;
  xmlNsPtr ns;

  if(Rf_length(sprefix)) {
      prefix = CHAR_DEREF(STRING_ELT(sprefix, 0));
      if(!prefix[0])
	  prefix = NULL;
  }

  if(!href[0])
      href = NULL;

  ns = xmlNewNs(doc, CHAR_TO_XMLCHAR(href), CHAR_TO_XMLCHAR(prefix));

  return(R_createXMLNsRef(ns)); /*XXX */
}


USER_OBJECT_
RS_XML_clone(USER_OBJECT_ obj, USER_OBJECT_ recursive, USER_OBJECT_ manageMemory)
{
    if(TYPEOF(obj) != EXTPTRSXP) {
	PROBLEM  "clone can only be applied to an internal, C-level libxml2 object"
        ERROR;
    }

    if(!R_ExternalPtrAddr(obj)) {
	PROBLEM  "NULL value passed to clone, possibly from a previous session"
        ERROR;
    }

    if(R_isInstanceOf(obj, "XMLInternalElementNode")) {
	xmlNodePtr node, node_ans;
	node = (xmlNodePtr) R_ExternalPtrAddr(obj);
	node_ans = xmlCopyNode(node, INTEGER(recursive)[0]);
	return(R_createXMLNodeRef(node_ans, manageMemory));
    } else if(R_isInstanceOf(obj, "XMLInternalDocument") || R_isInstanceOf(obj, "XMLInternalDOM")) {
	xmlDocPtr doc;
	doc = (xmlDocPtr) R_ExternalPtrAddr(obj);
	return(R_createXMLDocRef(xmlCopyDoc(doc, INTEGER(recursive)[0]))); // , manageMemory));
    }
    
    PROBLEM "clone doesn't (yet) understand this internal data type"
    ERROR;

    return(NULL_USER_OBJECT); /* never reached */
}

#ifdef R_XML_DEBUG
xmlDocPtr currentDoc;
#endif


USER_OBJECT_
R_createXMLDocRef(xmlDocPtr doc)
{
  SEXP ref, tmp;

#ifdef R_XML_DEBUG
  currentDoc = doc;
#endif

  if(!doc)
     return(R_NilValue);

  initDocRefCounter(doc);
  incrementDocRef(doc);

#ifdef R_XML_DEBUG
  fprintf(stderr, "creating document reference %s %p, count = %d\n", 
  	      doc->URL ? doc->URL : "internally created", doc,
              * ((int*) doc->_private));
#endif

  PROTECT(ref = R_MakeExternalPtr(doc, Rf_install("XMLInternalDocument"), R_NilValue));
  PROTECT(tmp = NEW_CHARACTER(1));
  SET_STRING_ELT(tmp, 0, mkChar( doc->type == XML_HTML_DOCUMENT_NODE ? "HTMLInternalDocument" : "XMLInternalDocument"));
  SET_CLASS(ref, tmp);
  UNPROTECT(2);
  return(ref);
}

USER_OBJECT_
R_removeXMLNsRef(xmlNsPtr ns)
{
/*XXX    xmlNsPtr p = (xmlNsPtr) R_ExternalPtrAddr(); */
    PROBLEM "C routine R_removeXMLNsRef() not implemented yet" 
    ERROR;
    return(R_NilValue);
}

USER_OBJECT_
R_createXMLNsRef(xmlNsPtr ns)
{
  SEXP ref, tmp;

  PROTECT(ref = R_MakeExternalPtr(ns, Rf_install("XMLNamespaceRef"), R_NilValue));
  PROTECT(tmp = NEW_CHARACTER(1));
  SET_STRING_ELT(tmp, 0, mkChar("XMLNamespaceRef"));
  SET_CLASS(ref, tmp);
  UNPROTECT(2);
  return(ref);
}

USER_OBJECT_
R_convertXMLNsRef(SEXP r_ns)
{
  SEXP ref, ans;
  xmlNsPtr ns;

  if(TYPEOF(r_ns) != EXTPTRSXP) {
      PROBLEM "wrong type for namespace reference"
	  ERROR;
  }

  ns = (xmlNsPtr) R_ExternalPtrAddr(r_ns);

  PROTECT(ans =  mkString(ns->href));
  SET_NAMES(ans, mkString(ns->prefix ? XMLCHAR_TO_CHAR(ns->prefix) : ""));

  UNPROTECT(1);

  return(ans);
}

USER_OBJECT_
R_getXMLNsRef(USER_OBJECT_ r_node)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);

    if(!node) 
	return(R_NilValue);

    return(node->ns ? R_createXMLNsRef(node->ns) : R_NilValue);
}


const char * 
R_getInternalNodeClass(xmlElementType type)
{
    const char * p = "";
    switch(type) {
        case XML_ELEMENT_NODE:
              p = "XMLInternalElementNode";
              break;
        case XML_ELEMENT_DECL:
              p = "XMLInternalElementDeclNode";
              break;
        case XML_TEXT_NODE:
              p = "XMLInternalTextNode";
              break;
        case XML_CDATA_SECTION_NODE:
              p = "XMLInternalCDataNode";
              break;
        case XML_ENTITY_NODE:
              p = "XMLInternalEntityNode";
              break;
        case XML_ENTITY_REF_NODE:
              p = "XMLInternalEntityRefNode";
              break;
        case XML_PI_NODE:
              p = "XMLInternalPINode";
              break;
        case XML_COMMENT_NODE:
              p = "XMLInternalCommentNode";
              break;
        case XML_NOTATION_NODE:
              p = "XMLInternalNotationNode";
              break;
        case XML_DTD_NODE:
              p = "XMLDTDNode";
              break;
        case XML_NAMESPACE_DECL:
              p = "XMLNamespaceDeclaration";
              break;
        case XML_XINCLUDE_START:
              p = "XMLXIncludeStartNode";
              break;
        case XML_XINCLUDE_END:
              p = "XMLXIncludeEndNode";
              break;
        case XML_ENTITY_DECL:
              p = "XMLInternalEntityRefNode";
              break;
        case XML_ATTRIBUTE_DECL:
              p = "XMLAttributeDeclNode";
              break;
        case XML_DOCUMENT_NODE:
              p = "XMLDocumentNode";
              break;
        case XML_HTML_DOCUMENT_NODE:
              p = "XMLHTMLDocumentNode";
              break;
        case XML_DOCUMENT_TYPE_NODE:
              p = "XMLDocumentTypeNode";
              break;
        case XML_DOCUMENT_FRAG_NODE:
              p = "XMLDocumentFragNode";
              break;
        case XML_ATTRIBUTE_NODE:
              p = "XMLAttributeNode";
              break;
        default:
              p = "XMLUnknownInternalNode";
    }

    return(p);
}



SEXP
R_createXMLNodeRefDirect(xmlNodePtr node, int addFinalizer)
{
  SEXP ref, tmp;

  PROTECT(ref = R_MakeExternalPtr(node, Rf_install("XMLInternalNode"), R_NilValue));

#ifdef XML_REF_COUNT_NODES

  if(addFinalizer > 0 || (addFinalizer < 0 && !IS_NOT_OUR_NODE_TO_TOUCH(node))) {
#ifdef R_XML_DEBUG
fprintf(stderr, "Creating reference with finalizer for %s (%p) '%s'\n", 
            node->name, node, node->type == XML_TEXT_NODE ? node->content : "");fflush(stderr);
#endif
     R_RegisterCFinalizer(ref, decrementNodeRefCount);
  }
/*
#else
#warning "no ref counting enabled"
*/
#endif
  PROTECT(tmp = NEW_CHARACTER(3));
  SET_STRING_ELT(tmp, 0, mkChar(R_getInternalNodeClass(node->type)));
  SET_STRING_ELT(tmp, 1, mkChar("XMLInternalNode"));
  SET_STRING_ELT(tmp, 2, mkChar("XMLAbstractNode"));
  SET_CLASS(ref, tmp);
  UNPROTECT(2);
  return(ref);
}




/**
Used to be used as 
R_XML_getManageMemory(manageMemory, node->doc, node) > 0 ? R_createXMLNodeRef() : R_createXMLNodeRefDirect(node, 0)); 
 */
USER_OBJECT_
R_createXMLNodeRef(xmlNodePtr node, USER_OBJECT_ finalize)
{
  int *val;
  int addFinalizer = 0;

  if(!node)
      return(NULL_USER_OBJECT);


  addFinalizer = R_XML_getManageMemory(finalize, node->doc, node);

/*  !IS_NOT_OUR_NODE_TO_TOUCH(node) */
  if(addFinalizer && ((node->_private && ((int*)node->_private)[1] == (int) R_MEMORY_MANAGER_MARKER)
		      || !node->doc || (!(IS_NOT_OUR_DOC_TO_TOUCH(node->doc))))) {
      if(node->_private == NULL) {
        node->_private = calloc(2, sizeof(int));
	val = (int *) node->_private;
	val[1] = R_MEMORY_MANAGER_MARKER;
      }

      val = (int *) node->_private;
      (*val)++;
      if(*val == 1)
	  incrementDocRef(node->doc);
#ifdef R_XML_DEBUG
  fprintf(stderr, "creating reference to node (%s, %d) count = %d (%p) (doc = %p count = %d)\n", node->name, node->type, (int) *val, node, node->doc,  (node->doc && node->doc->_private) ? ((int *)node->doc->_private)[0] : -1);
#endif
  }

  return(R_createXMLNodeRefDirect(node, addFinalizer /* !IS_NOT_OUR_NODE_TO_TOUCH(node) */ ));
}


/*
 May not be used. Not yet.
 The idea is to allow the R user to explicitly add a finalizer, like
 we do for a document.
 */
SEXP
R_addXMLNodeFinalizer(SEXP r_node)
{
#ifdef XML_REF_COUNT_NODES /* ??? should this be ifndef or ifdef.??  */
   xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);
  R_RegisterCFinalizer(r_node, decrementNodeRefCount);
#endif
  return(r_node);
}


#define ValOrNULL(x) CHAR_TO_XMLCHAR ((x && x[0] ? x : NULL))



/**
 Write the XML tree/DOM to a file or into a buffer (depending on the value
 of sfileName)

 It would be nice to use connections, but this is not yet possible
 in full generality.  Later

 @sdoc: the S object that is a reference to the top-level XML DOM.
 @sfileName: the S object that gives the name of the file to which the
  DOM should be written or alternatively, the S value `NULL' indicating
  that the DOM should be dumped to a buffer and returned as an S string.
 @compression: if @sfileName is the name of a file and we are not
  returning the DOM as a string, then we set the compression level
  to the value of this integer, unless it is omitted and specified as 
  the S value `NULL'.
 */
USER_OBJECT_
R_saveXMLDOM(USER_OBJECT_ sdoc, USER_OBJECT_ sfileName, USER_OBJECT_ compression, USER_OBJECT_ sindent,
	     USER_OBJECT_ prefix, USER_OBJECT_ r_encoding)
{
    xmlDocPtr doc;
    const char *fileName = NULL;
    USER_OBJECT_ ans = NULL_USER_OBJECT;
    xmlDtdPtr dtd = NULL;

    int oldIndent = xmlIndentTreeOutput;
    const char *encoding = CHAR_DEREF(STRING_ELT(r_encoding, 0));
    
    if(TYPEOF(sdoc) != EXTPTRSXP) {
       PROBLEM "document passed to R_saveXMLDOM is not an external pointer"
	   ERROR;
    }

    doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

    if(doc == NULL)
	return(NEW_CHARACTER(0));

    xmlIndentTreeOutput = LOGICAL_DATA(sindent)[0];

    if(GET_LENGTH(prefix) == 3) {
	dtd = xmlNewDtd(doc, ValOrNULL(CHAR_DEREF(STRING_ELT(prefix, 0))), 
                             ValOrNULL(CHAR_DEREF(STRING_ELT(prefix, 1))), 
     	                     ValOrNULL(CHAR_DEREF(STRING_ELT(prefix, 2))));
	dtd->parent = doc;
	dtd->doc = doc;

	dtd->prev = doc->children->prev;
	dtd->next = doc->children;
	doc->children->prev = (xmlNodePtr) dtd;

	doc->children = (xmlNodePtr) dtd;
    }


    /* Figure out what the name of the file is, or if it is NULL. */
    if(GET_LENGTH(sfileName))
      fileName = CHAR_DEREF(STRING_ELT(sfileName, 0));

    /* If the user specified a file name, write to it and honor 
       the compression setting they supplied. 
     */
    if(fileName && fileName[0]) {
        int compressionLevel = -1;
        if(GET_LENGTH(compression)) {
	    compressionLevel = xmlGetDocCompressMode(doc);
	    xmlSetDocCompressMode(doc, INTEGER_DATA(compression)[0]);
	}
	if(encoding && encoding[0])
	    xmlSaveFileEnc(CHAR_DEREF(STRING_ELT(sfileName, 0)),  doc, encoding);
#if 0
	else
	    xmlSaveFile(CHAR_DEREF(STRING_ELT(sfileName, 0)),  doc);
#else
	else {
	  FILE *f;
	  f = fopen(CHAR_DEREF(STRING_ELT(sfileName, 0)), "w");
	  xmlDocFormatDump(f, doc, 1);
	  fclose(f);
	}
#endif
        if(compressionLevel != -1) {
	    xmlSetDocCompressMode(doc, compressionLevel);
	}
    } else {
	/* So we are writing to a buffer and returning the DOM as an S string. */
        xmlChar *mem;
        int size;
/*??? Do we need to allocate this memory? */
        PROTECT(ans = NEW_CHARACTER(1));
	if(encoding && encoding[0])
	    xmlDocDumpFormatMemoryEnc(doc, &mem, &size, encoding, LOGICAL_DATA(sindent)[0]);
	else {
	    xmlDocDumpFormatMemory(doc, &mem, &size, 1); 
	    /* xmlDocDumpMemory(doc, &mem, &size);  original */
	}


	if(dtd) {
	    xmlNodePtr tmp;
	    doc->extSubset  = NULL;
            tmp = doc->children->next;
	    tmp->prev = NULL;
            doc->children = tmp;
	    xmlFreeDtd(dtd);
	}

	if(mem) {
	    DECL_ENCODING_FROM_DOC(doc)
	    SET_STRING_ELT(ans, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(mem))); 
	    xmlFree(mem);
	} else { 
               /*XXX get the error message from libxml2 */
	    PROBLEM "failed to write XML document contents"
		ERROR;
	}
        UNPROTECT(1);

       return(ans);
    }

    xmlIndentTreeOutput = oldIndent;
    return(ans);
}


USER_OBJECT_
RS_XML_setDoc(USER_OBJECT_ snode, USER_OBJECT_ sdoc)
{
/*Might use xmlCopyNode or xmlCopyNodeList if we have to make a copy*/
    xmlDocPtr doc;
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);

    if(sdoc != NULL_USER_OBJECT) {
       doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);
    } else {
	doc = xmlNewDoc(CHAR_TO_XMLCHAR("1.0"));
	R_numXMLDocs++;
    }
 
    xmlDocSetRootElement(doc, node);
    return(R_createXMLDocRef(doc));
}

#if 0
void
RS_XML_recursive_unsetDoc(xmlNodePtr node)
{
    xmlNodePtr tmp;
    node->doc = NULL;
    tmp = node->children;
    while(tmp) {
	RS_XML_recursive_unsetDoc(tmp);
	tmp = tmp->next;
    }
}
#endif

/* The following two routines are from Paul Murrell.
   They fix a problem with xpathApply() changing the document
   presumably when doing an XPath query on a node within a document.
   The old version didn't deal with the properties on the node.
 */
void
RS_XML_recursive_unsetTreeDoc(xmlNodePtr node) {
    xmlAttrPtr prop;

    if (node == NULL)
	return;
    if(node->type == XML_ELEMENT_NODE) {
        prop = node->properties;
        while (prop != NULL) {
            prop->doc = NULL;
            RS_XML_recursive_unsetListDoc(prop->children);
            prop = prop->next;
        }
    }
    if (node->children != NULL)
        RS_XML_recursive_unsetListDoc(node->children);
    node->doc = NULL;
}

void
RS_XML_recursive_unsetListDoc(xmlNodePtr list) {
    xmlNodePtr cur;

    if (list == NULL)
	return;
    cur = list;
    while (cur != NULL) {
        RS_XML_recursive_unsetTreeDoc(cur);
	cur = cur->next;
    }
}

USER_OBJECT_
RS_XML_unsetDoc(USER_OBJECT_ snode, USER_OBJECT_ unlink, USER_OBJECT_ r_parent, USER_OBJECT_ recursive)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    if(!node) {
	return(NULL_USER_OBJECT);
    }

    if(node->doc && node->doc->children == node) {
	xmlDocSetRootElement(node->doc, NULL);
    }

    if(LOGICAL(unlink)[0]) 
	xmlUnlinkNode(node);


    node->doc = NULL;
    node->parent = NULL;

    if(r_parent != R_NilValue) {
        node->parent = (xmlNodePtr) R_ExternalPtrAddr(snode);
    }

    if(LOGICAL(recursive)[0]) {
	RS_XML_recursive_unsetTreeDoc(node);
    }

    return(ScalarLogical(TRUE));
}

SEXP
RS_XML_setDocEl(SEXP r_node, SEXP r_doc)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);
    xmlSetTreeDoc(node, doc);
/*    node->doc = doc; */
    return(R_NilValue);
}



#ifdef ADD_XML_OUTPUT_BUFFER_CODE

/* These two taken from libxml2-2.6.27 
   They are needed if xmlOutputBufferCreateBuffer()
   is not in the installed libxml2.
   It appeared in libxml2-2.6.23, released on Jan 5 2006
*/
static int
xmlBufferWrite (void * context, const char * buffer, int len) {
    int ret;

    ret = xmlBufferAdd((xmlBufferPtr) context, (const xmlChar *) buffer, len);
    if (ret != 0)
        return(-1);
    return(len);
}

xmlOutputBufferPtr
xmlOutputBufferCreateBuffer(xmlBufferPtr buffer,
                            xmlCharEncodingHandlerPtr encoder) {
    xmlOutputBufferPtr ret;

    if (buffer == NULL) return(NULL);

    ret = xmlOutputBufferCreateIO((xmlOutputWriteCallback)
                                  xmlBufferWrite,
                                  (xmlOutputCloseCallback)
                                  NULL, (void *) buffer, encoder);

    return(ret);
}

#endif


/* Not completed.
   This could put the node into a new document and then call R_saveXMLDOM()
   but we are doing it in separate steps with separate C routines and 
   calling these from R.

    xmlNodeDumpOutput

Test:
  a = newXMLNode("a", "first bit", newXMLNode("b", "contents of b", newXMLNode("c", 3)), "more text")
  a = newXMLNode("a", newXMLNode("b", newXMLNode("c", 3))) 
  .Call("RS_XML_printXMLNode", a, as.integer(1), as.integer(1), character())
*/
USER_OBJECT_
RS_XML_printXMLNode(USER_OBJECT_ r_node, USER_OBJECT_ level, USER_OBJECT_ format, 
		    USER_OBJECT_ indent, USER_OBJECT_ r_encoding, USER_OBJECT_ r_encoding_int)
{
    USER_OBJECT_ ans;
    xmlNodePtr node;
    const char *encoding = NULL;
    xmlOutputBufferPtr buf;
    xmlBufferPtr xbuf;

    int oldIndent;

    oldIndent = xmlIndentTreeOutput;

    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);

    xmlIndentTreeOutput =  LOGICAL(indent)[0];

    xbuf = xmlBufferCreate();
   
    if(GET_LENGTH(r_encoding))
	encoding = CHAR_DEREF(STRING_ELT(r_encoding, 0));

    buf = xmlOutputBufferCreateBuffer(xbuf, NULL);
//    xmlKeepBlanksDefault(0);

    xmlNodeDumpOutput(buf,  node->doc, node, INTEGER(level)[0], INTEGER(format)[0], encoding);
    xmlOutputBufferFlush(buf);
    xmlIndentTreeOutput = oldIndent;

    if(xbuf->use > 0) {
        /*XXX this const char * in CHARSXP means we have to make multiple copies. */
     if(INTEGER(r_encoding_int)[0] == CE_NATIVE)
        ans = ScalarString(CreateCharSexpWithEncoding(encoding, xbuf->content));
     else
        ans = ScalarString(mkCharCE(xbuf->content, INTEGER(r_encoding_int)[0]));
    } else
      ans = NEW_CHARACTER(1);

    xmlOutputBufferClose(buf);

    return(ans);
}

SEXP
R_setXMLInternalTextNode_noenc(SEXP node)
{
     xmlNodePtr n = (xmlNodePtr) R_ExternalPtrAddr(node);
     if(!n) {
	 PROBLEM "null value passed for XMLInternalTextNode"
	     ERROR;
     }
     n->name = (const xmlChar *) (&xmlStringTextNoenc);
     return(ScalarLogical(TRUE));
}

SEXP
/*R_setXMLInternalTextNode_value(SEXP node, SEXP value, SEXP r_encoding)*/
R_setXMLInternalTextNode_value(SEXP node, SEXP value)
{
   xmlNodePtr n = (xmlNodePtr) R_ExternalPtrAddr(node);
//   xmlChar *tmp;
   const char *str;

   DECL_ENCODING_FROM_NODE(n)

   if(n->type != XML_TEXT_NODE) {
       PROBLEM  "Can only set value on an text node"
	   ERROR;
   }

   str = CHAR(STRING_ELT(value, 0));
   xmlNodeSetContent(n, str);
    
   return(node);
}

SEXP 
R_xmlSetContent(SEXP node, SEXP content)
{
    xmlNodePtr n = (xmlNodePtr) R_ExternalPtrAddr(node);
    xmlNodeSetContent(n, CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(content, 0))));
    return(R_NilValue);
}

SEXP
R_xmlNodeValue(SEXP node, SEXP raw, SEXP r_encoding)
{
   xmlNodePtr n = (xmlNodePtr) R_ExternalPtrAddr(node);
   xmlChar *tmp;
   SEXP ans;
   DECL_ENCODING_FROM_NODE(n)

   if(!n) {
      PROBLEM  "null value for xml node reference"
      ERROR;
   }

   tmp  = xmlNodeGetContent(n);
/*
  xmlGetNodeRawString
  xmlGetNodeString

   if(GET_LENGTH(raw) == 0)
   else if(LOGICAL(raw)[0]) {
   } else {

   }
*/
   if(tmp) {
     if(INTEGER(r_encoding)[0] == CE_NATIVE)
        ans = ScalarString(CreateCharSexpWithEncoding(encoding, tmp));
     else
        ans = ScalarString(mkCharCE(tmp, INTEGER(r_encoding)[0]));


     free(tmp);
//     ans = mkString(XMLCHAR_TO_CHAR(tmp));
     // Just playing:  ans = ScalarString(mkCharCE(tmp, CE_UTF8));
   } else 
       ans = NEW_CHARACTER(0);

   return(ans);
}

USER_OBJECT_
R_xmlNsAsCharacter(USER_OBJECT_ s_ns)
{
  xmlNsPtr ns = NULL;
  USER_OBJECT_ ans, names;
  const xmlChar *encoding = NULL;
  ns = (xmlNsPtr) R_ExternalPtrAddr(s_ns);  
#ifdef LIBXML_NAMESPACE_HAS_CONTEXT
  encoding = ns->context ? ns->context->encoding : NULL;
#endif

  PROTECT(ans = NEW_CHARACTER(2));
  PROTECT(names = NEW_CHARACTER(2));

  SET_STRING_ELT(names, 0, mkChar("prefix"));
  SET_STRING_ELT(names, 1, mkChar("href"));

  if(ns->prefix)
      SET_STRING_ELT(ans, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(ns->prefix)));
  if(ns->href)
      SET_STRING_ELT(ans, 1, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(ns->href)));

  SET_NAMES(ans, names);
  UNPROTECT(2);
  return(ans);
}

USER_OBJECT_
R_getXMLNodeDocument(USER_OBJECT_ s_node)
{
    xmlNodePtr n = (xmlNodePtr) R_ExternalPtrAddr(s_node);
    if(!n->doc)
	return(NULL_USER_OBJECT);

       /*??? Does this arrange to free it? */
    return(R_createXMLDocRef(n->doc));
}


USER_OBJECT_
RS_XML_isDescendantOf(USER_OBJECT_ r_node, USER_OBJECT_ r_top, USER_OBJECT_ strict)
{
    xmlNodePtr node, ptr, top;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    top = (xmlNodePtr) R_ExternalPtrAddr(r_top);    

    if(!node || !top) {
	PROBLEM  "null value passed to RS_XML_isDescendantOf"
	    ERROR;
    }

/*XXX */
    if(node->type == XML_NAMESPACE_DECL)
	return(ScalarLogical(TRUE));

    ptr = node;

    while(ptr && ptr->type != XML_DOCUMENT_NODE && ptr->type != XML_HTML_DOCUMENT_NODE) {
	if(ptr == top)
	    return(ScalarLogical(ptr == node && LOGICAL(strict)[0] ? FALSE : TRUE));
	ptr = ptr->parent;
    }
    
    return(ScalarLogical(FALSE));
}


SEXP
R_XML_indexOfChild(SEXP r_node)
{
    xmlNodePtr node, ptr; // parent
    int i = 0;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    ptr = node->parent->children;

    while(ptr) {
	if(ptr == node)
	    return(ScalarInteger(i + 1));

	i++;
	ptr = ptr->next;
    }

    return(R_NilValue);
}



SEXP
R_setNamespaceFromAncestors(SEXP r_node)
{
    xmlNodePtr node, ptr;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    ptr = node->parent;
    while(ptr) {
	if((ptr->type != XML_HTML_DOCUMENT_NODE && ptr->type != XML_DOCUMENT_NODE) && 
              ptr->ns && ptr->ns->href && (!ptr->ns->prefix || !ptr->ns->prefix[0])) {
	    xmlSetNs(node, ptr->ns);
	    return(ScalarLogical(TRUE));
	}
	ptr = ptr->parent;
    }
    return(ScalarLogical(FALSE));
}


#ifdef R_HAS_REMOVE_FINALIZERS
int
xmlNode_removeFinalizers(xmlNodePtr node)
{
  xmlNodePtr tmp;
  int count = 0;

#if R_XML_DEBUG
fprintf(stderr, "xml removeFinalizers  %p %s\n", node, node->name);
#endif
  count = R_RemoveExtPtrWeakRef_direct(node);

  tmp = node->children;
  while(tmp) {
      count += xmlNode_removeFinalizers(tmp);
      tmp = tmp->next;
  }
  return(count);
}

SEXP
R_xmlNode_removeFinalizers(SEXP r_node)
{
    int num;
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    num = xmlNode_removeFinalizers(node);
    return(ScalarInteger(num));
}
#endif






SEXP
R_xmlSearchNs(SEXP r_doc, SEXP r_node, SEXP r_ns, SEXP r_asPrefix)
{
    const char * val;
    xmlNsPtr ns;

    xmlDocPtr doc = (xmlDocPtr) r_doc == NULL_USER_OBJECT ? NULL : R_ExternalPtrAddr(r_doc);    
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    

    if(Rf_length(r_ns) == 0)
	return(NEW_CHARACTER(0));

    val = CHAR_DEREF(STRING_ELT(r_ns, 0));
    
    ns = LOGICAL(r_asPrefix)[0] ? xmlSearchNs(doc, node, val) : xmlSearchNsByHref(doc, node, val);

    if(!ns)
	return(NEW_CHARACTER(0));
    else {
	SEXP r_ans;
	PROTECT(r_ans =  mkString(ns->href));
	SET_NAMES(r_ans, mkString(ns->prefix ? XMLCHAR_TO_CHAR(ns->prefix) : ""));
	UNPROTECT(1);
	return(r_ans);
    }
}


USER_OBJECT_
R_getChildByIndex(USER_OBJECT_ r_node, USER_OBJECT_ r_index, USER_OBJECT_ r_addFinalizer)
{
    xmlNodePtr node, parent, ptr;
    int i = 0, idx;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    ptr = node->children;
    idx = INTEGER(r_index)[0];

    while(ptr && i < idx) {
	ptr = ptr->next;
	i++;
    }

    return(R_createXMLNodeRef(ptr, r_addFinalizer));
}


USER_OBJECT_
R_getChildByName(USER_OBJECT_ r_node, USER_OBJECT_ r_index, USER_OBJECT_ r_addFinalizer)
{
    xmlNodePtr node, parent, ptr;
    int i = 0, idx;
    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    ptr = node->children;
    const char *name = CHAR_DEREF(STRING_ELT(r_index, 0));

    while(ptr) {
	if(ptr->name && strcmp(name, ptr->name) == 0)
	    break;
	ptr = ptr->next;
    }

    return(R_createXMLNodeRef(ptr, r_addFinalizer));
}


/*
 This is a C-level version equivalent to
     xmlApply(node, xmlValue)

 
*/

USER_OBJECT_
R_childStringValues(SEXP r_node, SEXP r_len, SEXP r_asVector, SEXP r_encoding, SEXP r_addNames)
{
    xmlNodePtr node, kid;
    int len, i;
    SEXP ans, names = NULL;
    int asVector = LOGICAL(r_asVector)[0];
    int encoding = INTEGER(r_encoding)[0];
    xmlChar *tmp;
    int nprotect = 0;

    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);    
    len = INTEGER(r_len)[0];

    if(asVector)
	ans = NEW_CHARACTER(len);
    else
	ans = NEW_LIST(len);

    PROTECT(ans); nprotect++;

    if(LOGICAL(r_addNames)[0]) {
	PROTECT(names = NEW_CHARACTER(len));
	nprotect++;
    }


    for(i = 0, kid = node->children; kid && i < len; i++, kid = kid->next) {
	tmp  = xmlNodeGetContent(kid);	
	SEXP val = mkCharCE(tmp, encoding);
	PROTECT(val);
	if(asVector)
	    SET_STRING_ELT(ans, i, val);
	else
	    SET_VECTOR_ELT(ans, i, ScalarString(val));
	if(names && kid->name) {
	    SET_STRING_ELT(names, i, mkCharCE(kid->name, encoding));
	}
	UNPROTECT(1);
    }

    if(names)
	SET_NAMES(ans, names);

    UNPROTECT(nprotect);
    return(ans);
}
