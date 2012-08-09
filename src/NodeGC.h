#ifndef NODEGC_H
#define NODEGC_H


#if 1
/*
 We use the address of a global variable as a marker/signature that
 indicates we created the value of _private.
*/
extern int R_XML_MemoryMgrMarker;
extern int R_XML_NoMemoryMgmt;
#define R_MEMORY_MANAGER_MARKER &R_XML_MemoryMgrMarker

#define IS_NOT_OUR_DOC_TO_TOUCH(doc) (doc->_private == NULL || (doc->_private && doc->_private == &R_XML_NoMemoryMgmt) || ((int*)doc->_private)[1] != (int) R_MEMORY_MANAGER_MARKER)
#define IS_NOT_OUR_NODE_TO_TOUCH(node) ((node->_private == NULL) || (node->doc && node->doc->_private && node->doc->_private == &R_XML_NoMemoryMgmt) || ((int*)node->_private)[1] != (int) R_MEMORY_MANAGER_MARKER)

#else
  /* Not used. */
#define IS_NOT_OUR_DOC_TO_TOUCH(doc) (doc && doc->name && strcmp((doc)->name, " fake node libxslt") == 0)
#define IS_NOT_OUR_NODE_TO_TOUCH(node) (node && (node)->doc && IS_NOT_OUR_DOC_TO_TOUCH((node)->doc))

#endif

void decrementNodeRefCount(SEXP rnode);
void initDocRefCounter(xmlDocPtr doc);
void decrementNodeRefCount(SEXP rnode);

#endif


