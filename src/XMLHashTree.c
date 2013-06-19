/*

This set of functions is designed to map an internal
XML DOM tree to an xmlHashTree.

An xmlHashTree() is an environment, and so is mutable.
It contains the following elements:
  1) nodes each with a unique identifier, e.g. 1, 2, 3.
     which are used to index them in the elements that 
     specify the structure.

  2)  .children - an environment
  3)  .parents - an environment

  4)  top  - the root node


 Functions
    .addNode and .nodeIdGenerator

  If we are not going to be adding to this tree,
we don't need these functions.


  As we move through the internal tree, we can construct
 a node and then the character vector of children for 
 that node and assign it to the .children environment


Suppose we have a tree like

           A
         /  \
       B     C
            / | \
           D  E  F
              |
              G

We start giving the nodes names by number, i.e. 1, 2, 3,....
To create A, we make the node object as a list
with name (A), attributes (NULL), namespace (""), [children],  
  id (1) and env.

The children are
   2 and 3
The parents

*/

#include <libxml/tree.h>
#include <Rdefines.h>

#include "DocParse.h"
#include "Utils.h"

static const char * const nodeElementNames[] =  {
   "name", "attributes", "namespace", "children", "id", "env"
};

/*
  Identifier for the node. Could be anything, so we use the pointer address to ensure
   uniqueness.  Ignore the next definition in the comment!
#define SET_NODE_NAME(x, id) sprintf(x, "%d", id)
*/
#define SET_NODE_NAME(x, id, node) sprintf(x, "%p", node)


SEXP
makeHashNode(xmlNodePtr node, char *buf, SEXP env, R_XMLSettings *parserSettings)
{
  SEXP ans, names, tmp;
  int i = 0, numEls = sizeof(nodeElementNames)/sizeof(nodeElementNames[0]);
  DECL_ENCODING_FROM_NODE(node)

  int hasValue = node->type == XML_TEXT_NODE || node->type == XML_COMMENT_NODE 
                    || node->type == XML_CDATA_SECTION_NODE || node->type == XML_PI_NODE;

  if(hasValue)
      numEls++;
  if(node->nsDef) 
     numEls++;

  PROTECT(ans = NEW_LIST(numEls));
  PROTECT(tmp = mkString(node->name ? XMLCHAR_TO_CHAR(node->name) : ""));
  if(node->ns) 
    SET_NAMES(tmp, mkString(node->ns->prefix));

  SET_VECTOR_ELT(ans, i++, tmp);
  UNPROTECT(1);

  SET_VECTOR_ELT(ans, i++, RS_XML(AttributeList)(node, parserSettings));
  SET_VECTOR_ELT(ans, i++, ScalarString(ENC_COPY_TO_USER_STRING(node->ns && node->ns->prefix ? XMLCHAR_TO_CHAR(node->ns->prefix) : "")));
     /* skip the children */
  i = 4; 
  SET_VECTOR_ELT(ans, i++, mkString(buf));
  SET_VECTOR_ELT(ans, i++, env);
  if(hasValue) 
     SET_VECTOR_ELT(ans, i++, mkString(node->content));
  if(node->nsDef) 
    SET_VECTOR_ELT(ans, i++, processNamespaceDefinitions(node->nsDef, node, parserSettings));



  PROTECT(names = NEW_CHARACTER(numEls));
  for(i = 0; i < sizeof(nodeElementNames)/sizeof(nodeElementNames[0]); i++) 
      SET_STRING_ELT(names, i, ENC_COPY_TO_USER_STRING(nodeElementNames[i]));
  if(hasValue)
      SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("value"));
  if(node->nsDef)
      SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("namespaceDefinitions"));


  SET_NAMES(ans, names);
  UNPROTECT(1);

   /* The class of the node */
  PROTECT(names = NEW_CHARACTER( node->type == XML_ELEMENT_NODE ? 2 : 3));
  i = 0;
  SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLHashTreeNode"));
  if(node->type == XML_TEXT_NODE) 
     SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLTextNode")); 
  else if(node->type == XML_COMMENT_NODE) 
     SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLCommentNode")); 
  else if(node->type == XML_CDATA_SECTION_NODE) 
     SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLCDataNode")); 
  else if(node->type == XML_PI_NODE) 
     SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLPINode")); 

  SET_STRING_ELT(names, i++, COPY_TO_USER_STRING("XMLNode")); 
  SET_CLASS(ans, names);

  UNPROTECT(2);

  return(ans);
}


unsigned int
countChildNodes(xmlNodePtr root, unsigned int *ctr)
{
  xmlNodePtr node;
  for(node = root->children; node; node = node->next)  {
     if(node->type == XML_XINCLUDE_START) 
        countChildNodes(node, ctr);
     else if(node->type != XML_XINCLUDE_END)
        (*ctr)++;
  }
  return(*ctr);
}

void
collectChildNodes(xmlNodePtr root, unsigned int *ctr, SEXP kids)
{
    xmlNodePtr node;
    for(node = root->children; node; node = node->next)  {

	if(node->type == XML_XINCLUDE_END)
	    continue;

	if(node->type == XML_XINCLUDE_START) 
	    collectChildNodes(node, ctr, kids);
	else {
	    char buf[20];
	    SET_NODE_NAME(buf, *ctr + 1,  node);
	    SET_STRING_ELT(kids, *ctr, mkChar(buf));
	    (*ctr)++;
	}
    }
}



/*
 This is the recursive function that process a node and then its children.
 It builds the node (via makeHashNode) and then adds an entry for the
   children
 and 
   parent
 These provide the structure for the tree.
*/
void
processNode(xmlNodePtr root, xmlNodePtr parent, unsigned int *ctr, int parentId, char *id, SEXP env, SEXP childrenEnv, SEXP parentEnv, R_XMLSettings *parserSettings)
{
//  int i;
  xmlNodePtr node;
  SEXP rnode, kids;
  unsigned int curId = *ctr;
  char buf[20];

  SET_NODE_NAME(id, curId, root);


  if(root->type != XML_XINCLUDE_START && root->type != XML_XINCLUDE_END) {
  rnode = makeHashNode(root, id, env, parserSettings);
  
  defineVar(Rf_install(id), rnode, env);

  if(root->parent && root->parent->type != XML_DOCUMENT_NODE && root->parent->type != XML_HTML_DOCUMENT_NODE) {
      /* Put an entry in the .parents environment for this current id with the single value
         which is the value of the parentId as a string, equivalent of 
           assign(curId,  parentId, parentEnv)
       */
     SET_NODE_NAME(id, curId, root);
     SET_NODE_NAME(buf, parentId, parent);
     defineVar(Rf_install(id), mkString(buf), parentEnv);
   }

  if(root->children) {
        /* We have to deal with */
      unsigned int i = 0;
      countChildNodes(root, &i);

      PROTECT(kids = NEW_CHARACTER(i));
      i = 0; collectChildNodes(root, &i, kids);
      defineVar(Rf_install(id), kids, childrenEnv);
      UNPROTECT(1);
  }

  (*ctr)++;
 }

  if(root->type != XML_XINCLUDE_END) {
        /* Discard XML_INCLUDE_END nodes, but for XML_INCLUDE_START, we need to specify a different parent,
             i.e.,  the parent of the XML_INCLUDE_START node so that it will act as the parent of the  
             included nodes.
         */
      xmlNodePtr parent;
      parent = root->type == XML_XINCLUDE_START ? root->parent : root;
      for(node = root->children; node; node = node->next) 
          processNode(node, parent, ctr, curId, id, env, childrenEnv, parentEnv, parserSettings);
  }
}


/*
 This is the top-level C entry point for starting the conversion of the node.
*/
unsigned int
convertDOMToHashTree(xmlNodePtr root, SEXP env, SEXP childrenEnv, SEXP parentEnv, R_XMLSettings *parserSettings)
{
//  SEXP rnode;
  unsigned int ctr = 0;
  xmlNodePtr tmp;
  char id[20];
  memset(id, '\0', sizeof(id));

  for(tmp = root; tmp; tmp = tmp->next) 
    processNode(tmp, (xmlNodePtr) NULL, &ctr, -1, id, env, childrenEnv, parentEnv, parserSettings);


  return(ctr);
}


/*
  This is the R entry point for the conversion of the node and its subnode.
*/
SEXP
R_convertDOMToHashTree(SEXP rnode, SEXP env, SEXP childrenEnv, SEXP parentEnv)
{
  unsigned int ctr;
  xmlNodePtr node;
  R_XMLSettings parserSettings;
  parserSettings.addAttributeNamespaces = 0;
  parserSettings.converters = NULL_USER_OBJECT;

  node = (xmlNodePtr) R_ExternalPtrAddr(rnode);
  ctr = convertDOMToHashTree(node, env, childrenEnv, parentEnv, &parserSettings);

  return(ScalarInteger(ctr));
}
