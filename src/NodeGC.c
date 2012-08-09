/*
 THIS COMMENT MAY NOT BE UP TO DATE. Sep 19 2011.

 The idea is as follows. We use the private field in the xmlDocPtr
 object to store information about nodes that are out in the wild,
 i.e. that have been returned to R across the .Call() interface.
 Each time a node is returned, we increment the number of references
 to that node by incrementing a table in the xmlDocPtr.
 Each time these R objects are garbage collected, we decrement the 
 reference count.  When the number of references to that node go to 0,
 we remove that entry from the table. When all the node entries 
 are removed and the document itself is no longer being pointed to,
 we free the document.

 What about circularity? Does it occur? 
 What happens when we reparent a node?

 What happens when we put a node into an R object
  e.g.  x = node[[2]]
        y[[3]] = x
  Will R's garbage collection handle this for us?

*/


/* 
  This now contains the code related to our memory management.
 */

#include "Utils.h"
#include "NodeGC.h"



void R_xmlFreeDoc(SEXP ref)
{
  xmlDocPtr doc;
  doc = (xmlDocPtr) R_ExternalPtrAddr(ref);

  if(doc && !IS_NOT_OUR_DOC_TO_TOUCH(doc)) {
      int *val;
      val = doc->_private;
      if(val) {
	  (*val)--;
	  if(*val) {
#ifdef R_XML_DEBUG
	      fprintf(stderr, "Not freeing XML document %p (%s); still has %d references in the wild\n", doc, doc->URL ? doc->URL : "?", *val);
#endif
	      R_ClearExternalPtr(ref);
	      return;
	  }
      }
      
#ifdef R_XML_DEBUG
      const xmlChar *url = doc->URL ? doc->URL : (doc->name ? doc->name : (const xmlChar *)"?? (internally created)");
      fprintf(stderr, "Cleaning up document %p, %s, has children %d\n", (void *) doc, url, (int) (doc->children != NULL));
#endif
      if(val) {
	  free(val);
	  doc->_private = NULL;

#ifdef R_XML_DEBUG
	  fprintf(stderr, "Freeing the XML doc %p\n", doc);
#endif
          xmlFreeDoc(doc);
          R_numXMLDocsFreed++;
     } /* was before the xmlFreeDoc so that that was unconditional.*/
  }
  R_ClearExternalPtr(ref);
}


SEXP
RS_XML_freeDoc(SEXP ref)
{
    R_xmlFreeDoc(ref); 
    return(R_NilValue);
}


SEXP
RS_XML_forceFreeDoc(SEXP ref)
{
    xmlDocPtr doc;
    doc = (xmlDocPtr) R_ExternalPtrAddr(ref);
    xmlFreeDoc(doc); 
    return(R_NilValue);
}




/* This is a finalizer that removes the nodes and disassociates the
   node and the document and then frees the document structure.

   Does xmlFreeDoc() deal with the URL and name fields in the doc?

XXX With the nodes and document under garbage collection, do we really
need this?
*/
void R_xmlFreeDocLeaveChildren(SEXP ref)
{
 xmlDocPtr doc;
 doc = (xmlDocPtr) R_ExternalPtrAddr(ref);

  if(doc) {
      xmlNodePtr tmp;
#ifdef R_XML_DEBUG
      const xmlChar *url = doc->URL ? doc->URL : (doc->name ? doc->name : (const xmlChar *) "?? (internally created)");
      fprintf(stderr, "Cleaning up document but not children: %p, %s\n", (void *) doc, url);
#endif
      tmp = doc->children;
      xmlUnlinkNode(doc->children);
      tmp->doc = NULL;
      xmlFreeDoc(doc);
      R_numXMLDocsFreed++;
  }
  R_ClearExternalPtr(ref);
}



int R_XML_MemoryMgrMarker = 1010101011;
int R_XML_NoMemoryMgmt = 111111111;

/*
  This returns a value that indicates whether we should 
  add a finalizer and put the XML node under a C finalizer
  to reduce the reference count.
  user is an R object that should be an integer vector of length
  1 and should be 0, 1 or NA  (effectively a logical)
  If it is NA, we consult the document object in which  the node
  is located (or NULL if not part of a document). This document
  object can have a value in the _private field that tells us 
  no to 
 */
int 
R_XML_getManageMemory(SEXP user, xmlDocPtr doc, xmlNodePtr node)
{

    int manage;

    if(TYPEOF(user) == STRSXP || TYPEOF(user) == EXTPTRSXP)
	return(0);

    manage = INTEGER(user)[0]; // TYPEOF(user) == INTSXP ? INTEGER(user)[0] : INTEGER(asInteger(user))[0];
    if(manage == R_NaInt) {
        if(!doc)
	  manage = 1;
        else
	  manage = doc->_private != &R_XML_NoMemoryMgmt;
    }       
#ifdef R_XML_DEBUG
    if(manage)
	fprintf(stderr, "getManageMemory (%p) %d  (type = %d, name = %s)\n", doc, manage, node->type, node->name);fflush(stderr);
#endif
    return(manage);
}

SEXP
R_xmlSetNoMemoryMgmt(SEXP r_doc)
{
    xmlDocPtr doc;
    doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);
    doc->_private = &R_XML_NoMemoryMgmt;
    return(NULL_USER_OBJECT);
}

void
initDocRefCounter(xmlDocPtr doc)
{
    int *val;
    if(doc->_private)
	return;

    doc->_private = calloc(2, sizeof(int));
    val = (int *) doc->_private;
    val[1] = R_MEMORY_MANAGER_MARKER;
}

void 
incrementDocRefBy(xmlDocPtr doc, int num)
{
    int *val;
    if(!doc || IS_NOT_OUR_DOC_TO_TOUCH(doc))
	return;

    if(!doc->_private) {
	initDocRefCounter(doc);
    }

    val = (int *) doc->_private;

    (*val) += num;
}

void
incrementDocRef(xmlDocPtr doc)
{ 
  incrementDocRefBy(doc, 1);
}

#define GET_NODE_COUNT(n) \
   n->_private ? *((int*) (n)->_private) : 0



int getNodeCount(xmlNodePtr node)
{
  int val = 0;
  xmlNodePtr p = node->children;

  if(!node || IS_NOT_OUR_NODE_TO_TOUCH(node))
    return(0);

  val = GET_NODE_COUNT(node);
  while(p) {
    val += getNodeCount(p);
    p = p->next;
  }
  return(val);
}


void
internal_incrementNodeRefCount(xmlNodePtr node)
{
    int *val;
    if(!node || IS_NOT_OUR_NODE_TO_TOUCH(node) || !node->_private)
	return;
    val = (int *) node->_private;
    (*val)++;
}


SEXP
R_getXMLRefCount(SEXP rnode)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(rnode);
    if(!node || IS_NOT_OUR_NODE_TO_TOUCH(node) || !node->_private)
	return(ScalarInteger(-1));
    return(ScalarInteger(*((int *) node->_private)));
}

int
checkDescendantsInR(xmlNodePtr node, int process)
{
    xmlNodePtr p;
    if(!node && (process || IS_NOT_OUR_NODE_TO_TOUCH(node)))
	return(0);

    if(node->_private)
	return(1);

    p = node->children;
    while(p) {
	if(checkDescendantsInR(p, 0))
	    return(1);
	p = p->next;
    }
    return(0);
}

int
internal_decrementNodeRefCount(xmlNodePtr node)
{
    int *val, status = 0;
       /* */    
    if(!node || IS_NOT_OUR_NODE_TO_TOUCH(node))
                                 /* if node->_private == NULL, should
				  * we free this node?, i.e. if it is
				  * not in a parent or a document.
                                  No! Basically we shouldn't get here
                                  if we have not set the _private. We
                                  set the finalizer having set the _private */
	return(status);

    if(!node->_private)
	return(status);


    /*  Get the value of the reference count and decrement it by 1.
        If we are now at 0, then we can potentially free this node.
        Certainly, if we are at 0, we should remove the reference
        count memory altogether.
        Now that _we_ no longer need the node, perhaps we can free it.
        But we have to make certain that we don't free it if
         a) it is a child of another node or 
         b) if it is within a document and that document is still "in  play".
              To determine if the document is "in play" we look at it's
              reference count. 
              We decrement it by one since we added one to it for this
              node.
              If that makes the document's reference count 0, then we
              free it.
      
     */
    val = (int *) node->_private;
    (*val)--;
#ifdef R_XML_DEBUG
    fprintf(stderr, "decremented node (%s, %d) to %d (%p)   %s\n", node->name, node->type, *val, node, *val == 0 ? "***" : "");fflush(stderr);
#endif
    if(*val == 0) {

	free(node->_private);
        node->_private = NULL;
	if(node->doc && !IS_NOT_OUR_DOC_TO_TOUCH(node->doc)) {
	    val = (int *) node->doc->_private;
	    if(val) (*val)--;
	    if(!val || *val == 0) {
		/* Consolidate with R_xmlFreeDoc */
#ifdef R_XML_DEBUG
		fprintf(stderr, "releasing document (for node) %p %s (%s)\n", node->doc, node->doc->URL ? node->doc->URL : "?", val ? "has zero count" : "no count");fflush(stderr);
#endif
		if(val) 
                    free(node->doc->_private);
		node->doc->_private = NULL;
		xmlFreeDoc(node->doc);
                status = 1;
		R_numXMLDocsFreed++;
	    }
	} else if(!node->parent) {
	    /* If the node is not in a tree by having a parent, then
	     * check the children and if they aren't being referenced
               by an R variable, we can free those too. */
            int hold;
	    hold = checkDescendantsInR(node, 1);
            if(!hold) {
#ifdef R_XML_DEBUG
		fprintf(stderr, "Calling xmlFreeNode() for %p (type = %d)\n", node, node->type);fflush(stderr);
#endif
   	       xmlFreeNode(node);
	       status = 1;
	    }
	} else {
            /* So we have a parent.  But what if that parent is not
               being held as an R variable. We need to free the node.
               We need to make this smarter to see what parts of the 
               tree we can remove.  For instance, we might be holding
               onto this one, but not the parent, but that parent has
               a second child which is being held onto.

               So we go to the top of the node tree and check for its descendants
            */
	    int hold;
            xmlNodePtr p = node->parent;
	    while(p->parent) 
                p = p->parent;

	    hold = checkDescendantsInR(p, 0);
	    if(!hold) {
#ifdef R_XML_DEBUG
		fprintf(stderr, "Calling xmlFree() for %p\n", node);fflush(stderr);
#endif
		xmlFree(p); //XXX xmlFree() or xmlFreeNode() ?
		status = 1;
	    }
        
	}
    }

    return(status);
}



void
decrementNodeRefCount(SEXP rnode)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(rnode);
    int status;
    status = internal_decrementNodeRefCount(node);
    if(status)
	R_ClearExternalPtr(rnode);
}


int
clearNodeMemoryManagement(xmlNodePtr node)
{
    xmlNodePtr tmp;
    int ctr = 0;
    if(node->_private) {
	int a, b;
	int isOurs = (a = node->_private != &R_XML_NoMemoryMgmt) && (b = ((int *)(node->_private))[1] == (int) &R_XML_MemoryMgrMarker);
	if(isOurs) {
#if R_XML_DEBUG
 fprintf(stderr, "Removing memory management from %p, %s\n", node, node->name);fflush(stderr);
#endif
   	   free(node->_private);
   	   ctr++;
	}
	node->_private = NULL;
    }

    tmp = node->children;
    while(tmp) {
        if(tmp)
   	   ctr += clearNodeMemoryManagement(tmp);
	tmp = tmp->next;
    }
    return(ctr);
}

SEXP
R_clearNodeMemoryManagement(SEXP r_node)
{
   xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);
   int val;

   if(!node) 
       return(ScalarInteger(-1));

   val = clearNodeMemoryManagement(node);

   return(ScalarInteger(val));
}



SEXP
R_xmlRefCountEnabled()
{
  int ans =
#ifdef XML_REF_COUNT_NODES
      1;
#else 
      0;
#endif
      return(ScalarLogical(ans));
}
