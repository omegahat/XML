/**
  Routines for parsing and processing an XML document
  into an R/S data structure.


 * See Copyright for the license status of this software.

 */

#include "DocParse.h"

#define R_USE_XML_ENCODING 1
#include "Utils.h"  /* For isBlank() */


                    /* For the call to stat. */
#include <sys/stat.h>
#include <unistd.h>  

#include "RSDTD.h"

#include <stdarg.h>


#include <libxml/xmlschemas.h>
#include <libxml/xinclude.h>



int RS_XML(setNodeClass)(xmlNodePtr node, USER_OBJECT_ ans);
USER_OBJECT_ RS_XML(notifyNamespaceDefinition)(USER_OBJECT_ ns, R_XMLSettings *parserSettings);


void RS_XML(ValidationWarning)(void *ctx, const char *msg, ...);
void RS_XML(ValidationError)(void *ctx, const char *msg, ...);


static USER_OBJECT_ convertNode(USER_OBJECT_ ans, xmlNodePtr node, R_XMLSettings *parserSettings);
static void NodeTraverse(xmlNodePtr doc, USER_OBJECT_ converterFunctions, R_XMLSettings *parserSettings, int rootFirst);


static USER_OBJECT_ makeSchemaReference(xmlSchemaPtr ref);



USER_OBJECT_
RS_XML(libxmlVersionRuntime)()
{
    return(mkString(*__xmlParserVersion()));
}


USER_OBJECT_
RS_XML(getDefaultValiditySetting)(USER_OBJECT_ val)
{
#ifdef HAVE_VALIDITY

 extern int xmlDoValidityCheckingDefaultValue;
 USER_OBJECT_ ans;
 ans = NEW_INTEGER(1);
 INTEGER_DATA(ans)[0] = xmlDoValidityCheckingDefaultValue;

  if(GET_LENGTH(val))
     xmlDoValidityCheckingDefaultValue = INTEGER_DATA(val)[0];
  return(ans);

#else

  return(NEW_INTEGER(0));

#endif
}

#include <libxml/parser.h>
void
R_xmlStructuredErrorHandler(void *data, xmlErrorPtr err)
{
	RSXML_structuredStop((SEXP) data, err);
}

/**
  Entry point for reading, parsing and converting an XML tree
  to an R object.

  fileName is the string identifying the file, and is
  expanded using the normal rules for an R file name.
  That is, it can contain environment variables, ~, etc. 
 
  converterFunctions is a collection of functions used to 
  map a node into an R object. This would normally
  be a closure. It is not currently used, but will be enabled in
  the future.

  skipBlankLines controls whether text elements consisting
  simply of white space are included in the resulting
  structure.


  The return value is a simple list with named elements
     file, version and children
  The children element is itself a list consisting of 
  objects of class `XMLNode'. Each of these has the characteristic
 
 */
USER_OBJECT_
RS_XML(ParseTree)(USER_OBJECT_ fileName, USER_OBJECT_ converterFunctions, 
                    USER_OBJECT_ skipBlankLines, USER_OBJECT_ replaceEntities,
                     USER_OBJECT_ asText, USER_OBJECT_ trim, USER_OBJECT_ validate,
                      USER_OBJECT_ getDTD, USER_OBJECT_ isURL,
                       USER_OBJECT_ addNamespaceAttributes,
                        USER_OBJECT_ internalNodeReferences, 
		        USER_OBJECT_ s_useHTML, USER_OBJECT_ isSchema,
		        USER_OBJECT_ fullNamespaceInfo, USER_OBJECT_ r_encoding,
		        USER_OBJECT_ useDotNames,
      		         USER_OBJECT_ xinclude, USER_OBJECT_ errorFun,
  	        	  USER_OBJECT_ manageMemory, USER_OBJECT_ r_parserOptions,
                          USER_OBJECT_ r_rootFirst)
{

  const char *name;
  xmlDocPtr doc;
  USER_OBJECT_ rdoc, rdocObj; /* rdocObj is used to put the doc object
			       * under R's garbage collection.*/
  USER_OBJECT_ className;
  R_XMLSettings parserSettings;

  int asTextBuffer = LOGICAL_DATA(asText)[0];
  int isURLDoc = LOGICAL_DATA(isURL)[0];
  int useHTML = LOGICAL_DATA(s_useHTML)[0];

  const char *encoding = NULL;
  int freeName = 0;
  int parserOptions = 0;
  int rootFirst = INTEGER(r_rootFirst)[0];

  if(GET_LENGTH(r_encoding)) {
      encoding = CHAR(STRING_ELT(r_encoding, 0));
      if(!encoding[0])
	  encoding = NULL;
  }

  if(Rf_length(r_parserOptions))
     parserOptions = INTEGER(r_parserOptions)[0];

  parserSettings.skipBlankLines = LOGICAL_DATA(skipBlankLines)[0];
  parserSettings.converters = converterFunctions;
  parserSettings.useDotNames = LOGICAL_DATA(useDotNames)[0];
  parserSettings.trim = LOGICAL_DATA(trim)[0];
  parserSettings.xinclude = LOGICAL_DATA(xinclude)[0];
  parserSettings.fullNamespaceInfo = LOGICAL_DATA(fullNamespaceInfo)[0];

  parserSettings.internalNodeReferences = LOGICAL_DATA(internalNodeReferences)[0];

  parserSettings.addAttributeNamespaces = LOGICAL_DATA(addNamespaceAttributes)[0];
  parserSettings.finalize = manageMemory;

  if(asTextBuffer == 0) {
    struct stat tmp_stat;  
#ifdef USE_R
    name = CHAR(STRING_ELT(fileName, 0));
#else
    name = CHARACTER_DATA(fileName)[0];
#endif
    if(!isURLDoc && (name == NULL || stat(name, &tmp_stat) < 0)) {
      PROBLEM "Can't find file %s", CHAR_DEREF(STRING_ELT(fileName, 0))
      ERROR;
    }
  } else {
    name = strdup(CHAR_DEREF(STRING_ELT(fileName, 0)));
    freeName = 1;
  }

#if 0 /* Done in R now.*/
    /* If one wants entities expanded directly and to appear as text.  */
  if(LOGICAL_DATA(replaceEntities)[0]) 
      xmlSubstituteEntitiesDefault(1);   
#endif


  if(LOGICAL_DATA(isSchema)[0]) {
      xmlSchemaPtr schema = NULL;
      xmlSchemaParserCtxtPtr ctxt;

      ctxt = xmlSchemaNewParserCtxt(name);
      schema = xmlSchemaParse(ctxt);
      xmlSchemaFreeParserCtxt(ctxt);


/*XXX make certain to cleanup the settings. 
  Put a finalizer on this in makeSchemaReference.
*/

      return(makeSchemaReference(schema));
  }

#ifdef RS_XML_SET_STRUCTURED_ERROR 
  xmlSetStructuredErrorFunc(errorFun == NULL_USER_OBJECT ? NULL : errorFun, R_xmlStructuredErrorHandler);
#endif

  if(asTextBuffer) {
      doc = useHTML ? htmlParseDoc(CHAR_TO_XMLCHAR(name), encoding) : 
	              xmlReadMemory(name, strlen(name), NULL, encoding, parserOptions) ;
                	  /* xmlParseMemory(name, strlen(name)) */ 

      if(doc != NULL) 
         doc->name = (char *) xmlStrdup(CHAR_TO_XMLCHAR("<buffer>"));

  } else {
      doc = useHTML ? htmlParseFile(XMLCHAR_TO_CHAR(name), encoding) : 
	              xmlReadFile(name, encoding, parserOptions) /* xmlParseFile(name) */ ;
  }

#ifdef RS_XML_SET_STRUCTURED_ERROR 
  xmlSetStructuredErrorFunc(NULL, NULL);
#endif

  if(doc == NULL) {
      if(freeName && name) {
#ifdef EXPERIMENTING
	  free((char *) name);
#endif
      }
      /*XXX Just freed the name ! */
      if(errorFun != NULL_USER_OBJECT) {
        RSXML_structuredStop(errorFun, NULL);
      } else
        return(stop("XMLParseError", "error in creating parser for %s", name));

      PROBLEM "error in creating parser for %s", name
      ERROR;
  }

  if(TYPEOF(xinclude) == LGLSXP && LOGICAL_DATA(xinclude)[0]) {
      xmlXIncludeProcessFlags(doc, XML_PARSE_XINCLUDE);
  } else if(TYPEOF(xinclude) == INTSXP && GET_LENGTH(xinclude) > 0) {
      xmlXIncludeProcessFlags(doc, INTEGER(xinclude)[0]);
  }

  if(!useHTML && LOGICAL_DATA(validate)[0]) {
      xmlValidCtxt ctxt;
      ctxt.error = RS_XML(ValidationError);
      ctxt.warning = RS_XML(ValidationWarning);

      if(!xmlValidateDocument(&ctxt, doc)) {
	  if(freeName && name)
   	      free((char *) name);


	  PROBLEM "XML document is invalid"
          ERROR;
      }
  }

  if(parserSettings.internalNodeReferences) {
      /* Use a different approach - pass internal nodes to the converter functions*/
      if(GET_LENGTH(converterFunctions) > 0) {
	  xmlNodePtr root;
#ifdef USE_OLD_ROOT_CHILD_NAMES
	  root = doc->root;
#else
	  root = doc->xmlRootNode;
#ifdef ROOT_HAS_DTD_NODE
	  if(root->next && root->children == NULL)
	      root = root->next;
#endif
#endif   
          PROTECT(rdocObj = R_createXMLDocRef(doc));
	  NodeTraverse(root, converterFunctions, &parserSettings, rootFirst);
	  UNPROTECT(1);
      }
      PROTECT(rdoc = NULL_USER_OBJECT);
  } else {
      PROTECT(rdoc = RS_XML(convertXMLDoc)(name, doc, converterFunctions, &parserSettings));
  }

  if(asTextBuffer && name)
      free((char *) name);


  if(!useHTML && !parserSettings.internalNodeReferences && LOGICAL_DATA(getDTD)[0]) {
    USER_OBJECT_ ans, klass, tmp;
    const char *names[] = {"doc", "dtd"};
      PROTECT(ans = NEW_LIST(2));
        SET_VECTOR_ELT(ans, 0, rdoc);
        SET_VECTOR_ELT(ans, 1, tmp = RS_XML(ConstructDTDList)(doc, 1, NULL));

        PROTECT(klass = NEW_CHARACTER(1));
        SET_STRING_ELT( klass, 0, mkChar("DTDList"));
        SET_CLASS(tmp, klass);

        RS_XML(SetNames)(sizeof(names)/sizeof(names[0]), names, ans);

      UNPROTECT(2); /* release the ans */
      rdoc = ans;
  }

  if(parserSettings.internalNodeReferences && GET_LENGTH(converterFunctions) < 1) {
     UNPROTECT(1);
     return(R_createXMLDocRef(doc));
  }


  if(!parserSettings.internalNodeReferences) {
     /* Set the class for the document. */
    className = NEW_CHARACTER(1);
    PROTECT(className);
      SET_STRING_ELT(className, 0, mkChar(useHTML ? "HTMLDocument" : "XMLDocument"));   
      SET_CLASS(rdoc, className);
    UNPROTECT(1);
  }


 UNPROTECT(1); 
 return(rdoc);
}

enum { FILE_ELEMENT_NAME, VERSION_ELEMENT_NAME, CHILDREN_ELEMENT_NAME, NUM_DOC_ELEMENTS};



void
NodeTraverse(xmlNodePtr root, USER_OBJECT_ converterFunctions, R_XMLSettings *parserSettings, int rootFirst)
{
  xmlNodePtr c, tmp;
    c = root;

    while(c) {
	USER_OBJECT_ ref;
#ifndef USE_OLD_ROOT_CHILD_NAMES
         tmp = c->xmlChildrenNode;
#else
               c->childs;
#endif
       
        if(!rootFirst && tmp)
	    NodeTraverse(tmp, converterFunctions, parserSettings, rootFirst);

        PROTECT(ref = R_createXMLNodeRef(c, parserSettings->finalize));
        convertNode(ref, c, parserSettings);
    	UNPROTECT(1);

        if(rootFirst && tmp)
	    NodeTraverse(tmp, converterFunctions, parserSettings, rootFirst);

	c = c->next;
    }
}





/**
   Returns a named list whose elements are
   file:  the name of the file being processed.
   version: the XML version.
   root: the collection of children.
 */
USER_OBJECT_
RS_XML(convertXMLDoc)(const char *fileName, xmlDocPtr doc, USER_OBJECT_ converterFunctions, 
                    R_XMLSettings *parserSettings)
{
  USER_OBJECT_ rdoc;
  USER_OBJECT_ rdoc_el_names, klass;
  int n = NUM_DOC_ELEMENTS;
  const char *version = "";
  DECL_ENCODING_FROM_DOC(doc)


  PROTECT(rdoc = NEW_LIST(n));
  PROTECT(rdoc_el_names = NEW_CHARACTER(n));
 
    /* Insert the name of the file being processed */
    SET_VECTOR_ELT(rdoc, FILE_ELEMENT_NAME, NEW_CHARACTER(1));
    SET_STRING_ELT(VECTOR_ELT(rdoc, FILE_ELEMENT_NAME), 0, ENC_COPY_TO_USER_STRING(doc->name ? XMLCHAR_TO_CHAR(doc->name) : fileName));
    SET_STRING_ELT(rdoc_el_names, FILE_ELEMENT_NAME, COPY_TO_USER_STRING("file"));

    /* Insert the XML version information */
  SET_VECTOR_ELT(rdoc, VERSION_ELEMENT_NAME, NEW_CHARACTER(1));
  if(doc->version)
	version = XMLCHAR_TO_CHAR(doc->version);

  SET_STRING_ELT(VECTOR_ELT(rdoc, VERSION_ELEMENT_NAME), 0, 
                                     COPY_TO_USER_STRING(version));
  SET_STRING_ELT(rdoc_el_names, VERSION_ELEMENT_NAME, COPY_TO_USER_STRING("version"));

    /* Compute the nodes for this tree, recursively. 
       Note the SIDEWAYS argument to get the sibling nodes
       at the root, rather than just the first and its children.
     */
{
  xmlNodePtr root;
#ifdef USE_OLD_ROOT_CHILD_NAMES
    root = doc->root;
#else
    root = doc->xmlRootNode;

#ifdef ROOT_HAS_DTD_NODE
    if(root->next && root->children == NULL)
       root = root->next;
#endif
#endif
  SET_VECTOR_ELT(rdoc, CHILDREN_ELEMENT_NAME, RS_XML(createNodeChildren)(root,  SIDEWAYS, parserSettings)); 
}
  SET_STRING_ELT(rdoc_el_names, CHILDREN_ELEMENT_NAME, COPY_TO_USER_STRING("children"));

  SET_NAMES(rdoc, rdoc_el_names);

  PROTECT(klass = NEW_CHARACTER(1));
  SET_STRING_ELT(klass, 0, COPY_TO_USER_STRING("XMLDocumentContent"));
  SET_CLASS(rdoc, klass);

  UNPROTECT(3);

  return(rdoc);
}

USER_OBJECT_
processNamespaceDefinitions(xmlNs *ns, xmlNodePtr node, R_XMLSettings *parserSettings)
{
  int n = 0;
  xmlNs *ptr = ns;
  USER_OBJECT_ ans, tmp, names;
  DECL_ENCODING_FROM_NODE(node)

  while(ptr) {
    ptr = ptr->next;
    n++;
  }
  PROTECT(ans = NEW_LIST(n));
  PROTECT(names = NEW_CHARACTER(n));

  for(n = 0, ptr = ns; ptr ; n++, ptr = ptr->next) {
    tmp = RS_XML(createNameSpaceIdentifier)(ptr,node);
    (void) RS_XML(notifyNamespaceDefinition)(tmp, parserSettings);
    SET_VECTOR_ELT(ans, n, tmp);
    if(ptr->prefix)
       SET_STRING_ELT(names, n, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(ptr->prefix)));
  }

  SET_NAMES(ans, names);
  SET_CLASS(ans, mkString("XMLNamespaceDefinitions"));
  UNPROTECT(2);
  return(ans);
}

/**
   Creates an R object representing the specified node, and its children
   if recursive is non-zero. Certain types of nodes have 

   direction controls whether we take the siblings of this node
   or alternatively its children.

   parentUserNode the previously created user-leve node for the parent of the
            target node. 

 */

enum { NODE_NAME, NODE_ATTRIBUTES, NODE_CHILDREN, NODE_NAMESPACE, NODE_NAMESPACE_DEFS, NUM_NODE_ELEMENTS};

USER_OBJECT_
getNamespaceDefs(xmlNodePtr node, int recursive)
{
  USER_OBJECT_ nsDef = NULL_USER_OBJECT;
  
  if(node->nsDef || recursive) {
      int numProtects = 0;
      xmlNs *ptr = node->nsDef;
      int n = 0;
      while(ptr) {
          n++;  ptr = ptr->next;
      }

      PROTECT(nsDef = NEW_LIST(n)); numProtects++;
      ptr = node->nsDef; n = 0;
      while(ptr) {
          SET_VECTOR_ELT(nsDef, n, RS_XML(createNameSpaceIdentifier)(ptr, node));
          n++;  ptr = ptr->next;
      }

      if(recursive && node->children) {
	  xmlNodePtr ptr = node->children;
	  USER_OBJECT_ tmp;
	  int i;

	  while(ptr) {
	      tmp = getNamespaceDefs(ptr, 1);
/*	  nsDef = Rf_appendList(nsDef, tmp); */
	      if(Rf_length(tmp)) {
		  n = Rf_length(nsDef); 
		  PROTECT(SET_LENGTH(nsDef, n + Rf_length(tmp)));
		  numProtects++;
		  for(i = 0; i < Rf_length(tmp); i++) 
		      SET_VECTOR_ELT(nsDef, n + i, VECTOR_ELT(tmp, i));
	      }
	      ptr = ptr->next;
	  }
      }

      SET_CLASS(nsDef, mkString("NamespaceDefinitionList"));
      UNPROTECT(numProtects);
  }
  return(nsDef);
}

USER_OBJECT_
RS_XML(internalNodeNamespaceDefinitions)(USER_OBJECT_ r_node, USER_OBJECT_ recursive)
{
  xmlNodePtr node;

  if(TYPEOF(r_node) != EXTPTRSXP) {
       PROBLEM "R_internalNodeNamespaceDefinitions expects InternalXMLNode objects"
       ERROR;
    }

  node = (xmlNodePtr) R_ExternalPtrAddr(r_node);
  return(getNamespaceDefs(node, LOGICAL(recursive)[0]));
}

static USER_OBJECT_
RS_XML(createXMLNode)(xmlNodePtr node, int recursive, int direction, R_XMLSettings *parserSettings, USER_OBJECT_ parentUserNode)
{
  int n = NUM_NODE_ELEMENTS;
  USER_OBJECT_ ans;
  USER_OBJECT_ ans_el_names;
  USER_OBJECT_ nsDef = NULL_USER_OBJECT;
  int addValue;
  DECL_ENCODING_FROM_NODE(node)
  char *contentValue = XMLCHAR_TO_CHAR(node->content);

#ifdef ROOT_HAS_DTD_NODE
  if(node->type == XML_DTD_NODE)
    return(NULL);
#endif

  if(parserSettings->trim) {
    contentValue = trim(XMLCHAR_TO_CHAR(node->content));
  }

  addValue = (contentValue && strlen(contentValue) && isBlank(contentValue) == 0);

#ifdef LIBXML2
  if(node->type == XML_ENTITY_DECL)
    return(NULL);
#endif
 
        /* Drop text nodes that are blank, if that is what the user wanted. */
  if(parserSettings->skipBlankLines && addValue == 0 && node->type == XML_TEXT_NODE)
    return(NULL);

  
  if(addValue)
    n++;


  /* If we have a */
  if(node->type != XML_ELEMENT_DECL)  {


     /* Create the default return value being a list of name, attributes, children 
        and possibly value. 


      */
 PROTECT(ans = NEW_LIST(n));
 PROTECT(ans_el_names = NEW_CHARACTER(n));

   /* If there are namespace definitions within this node, */
  if(node->nsDef)  {
    nsDef = processNamespaceDefinitions(node->nsDef, node, parserSettings);
    SET_VECTOR_ELT(ans, NODE_NAMESPACE_DEFS, nsDef);
  }


  SET_VECTOR_ELT(ans, NODE_NAME, NEW_CHARACTER(1));
  if(node->name)
    SET_STRING_ELT(VECTOR_ELT(ans, NODE_NAME), 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(node->name)));

  SET_VECTOR_ELT(ans, NODE_ATTRIBUTES, RS_XML(AttributeList)(node, parserSettings));

  if(recursive)
    SET_VECTOR_ELT(ans, NODE_CHILDREN, RS_XML(createNodeChildren)(node, direction, parserSettings));
  else
    SET_VECTOR_ELT(ans, NODE_CHILDREN, NULL_USER_OBJECT); 



  SET_STRING_ELT(ans_el_names, NODE_NAME, mkChar("name"));
  SET_STRING_ELT(ans_el_names, NODE_ATTRIBUTES,  mkChar("attributes"));
  SET_STRING_ELT(ans_el_names, NODE_CHILDREN, mkChar("children"));
  SET_STRING_ELT(ans_el_names, NODE_NAMESPACE, mkChar("namespace"));
  SET_STRING_ELT(ans_el_names, NODE_NAMESPACE_DEFS, mkChar("namespaceDefinitions"));

  if(node->ns) {
    PROTECT(nsDef = NEW_CHARACTER(1));
    if(!parserSettings->fullNamespaceInfo) {
	if(node->ns->prefix) {
	    SET_STRING_ELT(nsDef, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(node->ns->prefix))); 
	    SET_CLASS(nsDef, mkString("XMLNamespacePrefix"));
	}
    } else {
	if(node->ns->href)
	    SET_STRING_ELT(nsDef, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(node->ns->href)));
	if(node->ns->prefix)
		SET_NAMES(nsDef, ScalarString(ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(node->ns->prefix)))); /* XXX change! */
	SET_CLASS(nsDef, mkString("XMLNamespace"));
    }
    SET_VECTOR_ELT(ans, NODE_NAMESPACE, nsDef);
    UNPROTECT(1);
  }



  if(addValue) {
    SET_STRING_ELT(ans_el_names, NUM_NODE_ELEMENTS, COPY_TO_USER_STRING("value"));
    SET_VECTOR_ELT(ans, NUM_NODE_ELEMENTS, NEW_CHARACTER(1));
    SET_STRING_ELT(VECTOR_ELT(ans, NUM_NODE_ELEMENTS), 0, ENC_COPY_TO_USER_STRING(contentValue));

    if(node->type == XML_ENTITY_REF_NODE) 
	    SET_NAMES(VECTOR_ELT(ans, NUM_NODE_ELEMENTS), ScalarString(ENC_COPY_TO_USER_STRING(node->name)));
  }

  SET_NAMES(ans, ans_el_names);
  

    /* Compute the class of this object based on the type in the
       XML node.
     */

  RS_XML(setNodeClass)(node, ans);
  } else {
      /* XML_ELEMENT_DECL */
      ans = NULL_USER_OBJECT;
      PROTECT(ans);
      PROTECT(ans);
  }
     /* Now invoke any user-level converters.  */
  if(recursive || direction)
    ans = convertNode(ans, node, parserSettings);

  UNPROTECT(1);
  UNPROTECT(1);
  return(ans);
}

static USER_OBJECT_
convertNode(USER_OBJECT_ ans, xmlNodePtr node, R_XMLSettings *parserSettings)
{
    USER_OBJECT_ val = ans; 

  if(parserSettings != NULL) {
    USER_OBJECT_  fun = NULL;
    const char *funName;

    if(parserSettings->xinclude && (node->type == XML_XINCLUDE_START || node->type == XML_XINCLUDE_END)) {
	return(NULL);
    }


       if(node->name) {
          funName = XMLCHAR_TO_CHAR(node->name);
          fun = RS_XML(findFunction)(funName, parserSettings->converters);
       } 

      if(fun == NULL) {
	/* Didn't find the tag-specific function in the handlers. 
           So see if there is one for this type node.
         */
        fun = RS_XML(lookupGenericNodeConverter)(node, ans, parserSettings);
      }
      if(fun != NULL) {
        USER_OBJECT_ opArgs = NEW_LIST(1);
	 PROTECT(opArgs);
	 SET_VECTOR_ELT(opArgs, 0, ans);
	 val = RS_XML(invokeFunction)(fun, opArgs, NULL, NULL);
   	 UNPROTECT(1);
      }
  }
  return(val);
}


const char * const XMLNodeClassHierarchy[] = {"XMLNode", "RXMLAbstractNode", "XMLAbstractNode", "oldClass"};        

int
RS_XML(setNodeClass)(xmlNodePtr node, USER_OBJECT_ ans)
{
 char *className = NULL;
 int numEls = 1;
 int lenHier = sizeof(XMLNodeClassHierarchy)/sizeof(XMLNodeClassHierarchy[0]);

 numEls = lenHier + 1;

  switch(node->type) {
    case XML_ENTITY_REF_NODE:
      className = "XMLEntityRef";
      break;
    case XML_PI_NODE:
      className = "XMLProcessingInstruction";
      break;
    case XML_COMMENT_NODE:
      className = "XMLCommentNode";
      break;
    case XML_TEXT_NODE:
      className = "XMLTextNode";
      break;
    case XML_CDATA_SECTION_NODE:
      className = "XMLCDataNode";
      break;
#ifdef LIBXML2
    case XML_ENTITY_DECL:
      className = "XMLEntityDeclaration";
      break;
#endif
   default:
     numEls--;
     break;
  }

  if(1) {
     USER_OBJECT_ Class;
     int ctr = 0, i;
     PROTECT(Class = NEW_CHARACTER(numEls));
        if(className)
            SET_STRING_ELT(Class, ctr++, mkChar(className));

        for(i = 0; i < lenHier; i++)
          SET_STRING_ELT(Class, ctr++, mkChar(XMLNodeClassHierarchy[i]));
        SET_CLASS(ans, Class);
      UNPROTECT(1);
  }

  return(node->type);
}


const char *RS_XML(NameSpaceSlotNames)[] = {"id", "uri", "local"};
enum {NAMESPACE_PREFIX_SLOT, NAMESPACE_URI_SLOT, NAMESPACE_TYPE_SLOT, NAMESPACE_NUM_SLOTS};

/**
  Create a local object identifying the name space used by a particular node.
  This is not the name space definition which would have a URL/URI and a type.
 */
USER_OBJECT_
RS_XML(createNameSpaceIdentifier)(xmlNs *space, xmlNodePtr node)
{

 USER_OBJECT_ ans;
 DECL_ENCODING_FROM_NODE(node)

 if(node->nsDef) {
   PROTECT(ans = NEW_LIST(3));
     SET_VECTOR_ELT(ans, NAMESPACE_PREFIX_SLOT, NEW_CHARACTER(1));
     SET_STRING_ELT(VECTOR_ELT(ans, NAMESPACE_PREFIX_SLOT), 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR( (space->prefix ? space->prefix : (xmlChar*)"")))); 

     SET_VECTOR_ELT(ans, NAMESPACE_URI_SLOT, NEW_CHARACTER(1));
     SET_STRING_ELT(VECTOR_ELT(ans, NAMESPACE_URI_SLOT), 0, space->href ? ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(space->href)) : NA_STRING); 


     SET_VECTOR_ELT(ans, NAMESPACE_TYPE_SLOT, NEW_LOGICAL(1));
     LOGICAL_DATA(VECTOR_ELT(ans, NAMESPACE_TYPE_SLOT))[0] = (space->type == XML_LOCAL_NAMESPACE);

     RS_XML(SetNames)(NAMESPACE_NUM_SLOTS, RS_XML(NameSpaceSlotNames), ans);

   {
    USER_OBJECT_ klass;
    PROTECT(klass = NEW_CHARACTER(1));
     SET_STRING_ELT(klass, 0, COPY_TO_USER_STRING("XMLNamespaceDefinition"));
     SET_CLASS(ans, klass);
    UNPROTECT(1);
   }
   UNPROTECT(1);
 } else {
   PROTECT(ans =  NEW_CHARACTER(1));
   if(space->prefix)
      SET_STRING_ELT(ans, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(space->prefix)));
   UNPROTECT(1);
 }


 return(ans);
}

/**
  Attempt to find a function in the handler methods corresponding to the
  type of the node, not its specific tag name.
 */
USER_OBJECT_
RS_XML(lookupGenericNodeConverter)(xmlNodePtr node, USER_OBJECT_ defaultNodeValue, 
                                     R_XMLSettings *parserSettings)
{
#define DOT(x) parserSettings->useDotNames ? "." x : x
  char *name;
  USER_OBJECT_ fun = NULL;
  switch(node->type) {
    case XML_ENTITY_REF_NODE:
	name = DOT("entity");
      break;
    case XML_ENTITY_NODE:
	name = DOT("entity");
      break;
    case XML_ELEMENT_NODE:
	name = DOT("startElement");
      break;
    case XML_PI_NODE:
	name = DOT("proccesingInstruction");
      break;
    case XML_COMMENT_NODE:
	name = DOT("comment");
      break;
    case XML_TEXT_NODE:
	name = DOT("text");
      break;
    case XML_CDATA_SECTION_NODE:
	name = DOT("cdata");
      break;
  default:
      name = NULL;     
  }

  if(name && name[0])
   fun = RS_XML(findFunction)(name, parserSettings->converters);   
 
 return(fun);
}

/*
 XXX Unravel this recursive call into a loop.

  Starting at the top node, fix the id to be empty.
  Then add the node and get the ID.
  Then loop over the children, and the node and call the routine
  on its children
  

 */

/*
   at a given node, make the node
*/
void
addNodeAndChildrenToTree(xmlNodePtr node, SEXP id, SEXP e, R_XMLSettings *parserSettings, int *ctr)
{
   SEXP tmp;
   xmlNodePtr n;

   if(!node)
     return;

        /* Create a skeleton node with no children. */
   tmp = RS_XML(createXMLNode)(node, 0, 0/* doesn't matter */, parserSettings, R_NilValue);/*XXX*/
   if(!tmp) 
     return;
   SETCAR(CDR(e), tmp);
   (*ctr)++;

   id = Rf_eval(e, R_GlobalEnv);
   PROTECT(id);

   n = node->children;
   while(n) {

     SETCAR(CDR(CDR(e)), id);
     addNodeAndChildrenToTree(n, id, e, parserSettings, ctr);
     (*ctr)++;
     n = n->next;
   }

   UNPROTECT(1);
}



SEXP
addNodesToTree(xmlNodePtr node, R_XMLSettings *parserSettings)
{
   xmlNodePtr ptr = node;
   SEXP e, id;
   int ctr = 0;
   PROTECT(e = allocVector(LANGSXP, 3));
   SETCAR(e, parserSettings->converters);
   id = NEW_CHARACTER(0);

   ptr = node;

   /* loop over the sibling nodes here in case we have multiple roots, 
      e.g. a comment, PI and a real node. See xysize.svg
    */
   while(ptr) {
      SETCAR(CDR(CDR(e)), id);
      addNodeAndChildrenToTree(ptr, id, e, parserSettings, &ctr);
      ptr = ptr->next;
   }

   UNPROTECT(1);
   return(ScalarInteger(ctr));
}



/**
  Creates the R objects representing the children or siblings of the specified
  node, handling simple text cases with no children, as well as recursively
  processing the children.

  node   the node whose children or siblings should be converted.
        
  direction DOWN or SIDEWAYS indicating the children or siblings should
    be processed, respectively. If SIDEWAYS is specified, the node itself
    is included in the result.

  parserSettings  "global" information about the parsing conversion for the duration of the parser.


  Return  list of XMLNode objects.
 */
USER_OBJECT_
RS_XML(createNodeChildren)(xmlNodePtr node, int direction, R_XMLSettings *parserSettings)
{
  int n = 0, i;
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  USER_OBJECT_ elNames = NULL;
  int unProtect = 0;
  xmlNodePtr base, c = (direction == SIDEWAYS) ? node : 
#ifndef USE_OLD_ROOT_CHILD_NAMES
                              node->xmlChildrenNode;
#else
                              node->childs;
#endif

  DECL_ENCODING_FROM_NODE(node)

  base = c;

  if(IS_FUNCTION(parserSettings->converters)) {
    return(addNodesToTree(node, parserSettings));
  }

      /* Count the number of elements being converted. */
  while(c) {
    c = c->next;
    n++;
  }

  if(n > 0) {
    USER_OBJECT_ tmp;
    USER_OBJECT_ tmpNames;
    int count = 0;


    c = base;

    PROTECT(ans = NEW_LIST(n));
    PROTECT(elNames = NEW_CHARACTER(n));

    unProtect = 2;

    for(i = 0; i < n; i++, c = c->next) {
	tmp = RS_XML(createXMLNode)(c, 1, DOWN, parserSettings, ans);
	if(tmp && tmp != NULL_USER_OBJECT) {
	    SET_VECTOR_ELT(ans, count, tmp); 
	    if(c->name)
		SET_STRING_ELT(elNames, count, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(c->name)));
            count++;
	}
    }

     if(count < n) {
      /* Reset the length! */
#ifdef USE_S
#else
      PROTECT(tmp  = NEW_LIST(count));
      PROTECT(tmpNames = NEW_CHARACTER(count));
      for(i = 0 ;  i < count ; i++) {
        SET_VECTOR_ELT(tmp, i, VECTOR_ELT(ans, i));
        SET_STRING_ELT(tmpNames, i, STRING_ELT(elNames, i));
      }
      ans = tmp;
      SET_NAMES(ans, tmpNames);
      UNPROTECT(4);
      PROTECT(ans);
      unProtect = 1;
#endif
     } else {
         SET_NAMES(ans, elNames);
     }

    if(unProtect > 0)  
       UNPROTECT(unProtect);
  }

  return(ans);
}



USER_OBJECT_
RS_XML(notifyNamespaceDefinition)(USER_OBJECT_ arg, R_XMLSettings *parserSettings)
{
 USER_OBJECT_ fun, ans = NULL_USER_OBJECT;

     fun = RS_XML(findFunction)("namespace", parserSettings->converters);
     if(fun != NULL) {
        USER_OBJECT_ opArgs = NEW_LIST(1);
        USER_OBJECT_ tmp;
	 PROTECT(opArgs);
	 SET_VECTOR_ELT(opArgs, 0, arg);
	 tmp = RS_XML(invokeFunction)(fun, opArgs, NULL, NULL);
         ans = tmp;
   	 UNPROTECT(1);
      }

 return(ans);
}

#ifdef USE_XML_VERSION_H
#ifndef LIBXML_TEST_VERSION
#include <libxml/xmlversion.h>
#endif
#endif

USER_OBJECT_
RS_XML(libxmlVersion)()
{
 USER_OBJECT_ ans;
 unsigned int val;

#ifdef LIBXML_VERSION_NUMBER
 val = LIBXML_VERSION_NUMBER;
#else 
#ifdef LIBXML_VERSION
 val = LIBXML_VERSION;
#else
 val = 0;
#endif
#endif

 ans = NEW_NUMERIC(1);
 NUMERIC_DATA(ans)[0] = val;
 return(ans);
}



static 
void
notifyError(const char *msg, va_list ap, Rboolean isError)
{
#if 0
    if(isError) {
	 PROBLEM "error in validating XML document"
	 ERROR;
    } else {
	 PROBLEM "warning when validating XML document"
	 ERROR;
    }

#else
#define BUFSIZE 2048
    char buf[BUFSIZE];

    memset(buf, '\0', BUFSIZE);
    vsnprintf(buf, BUFSIZE, msg, ap);

    Rf_warning(buf);
#if 0
    PROBLEM buf
        WARN;
#endif

#endif
}



void
RS_XML(ValidationError)(void *ctx, const char *format, ...)
{
  char *msg = "Message unavailable";
  va_list(ap);
  va_start(ap, format);

  if(strcmp(format, "%s") == 0)
    msg = va_arg(ap, char *);

  va_end(ap);
  notifyError(msg, ap, TRUE);
}

void
RS_XML(ValidationWarning)(void *ctx, const char *format, ...)
{
  char *msg = "Message unavailable";
  va_list(ap);
  va_start(ap, format);

  if(strcmp(format, "%s") == 0)
    msg = va_arg(ap, char *);

  va_end(ap);
  notifyError(msg, ap, FALSE);
}


USER_OBJECT_
R_createXMLNode(USER_OBJECT_ snode, USER_OBJECT_ handlers, USER_OBJECT_ r_trim, USER_OBJECT_ r_skipBlankLines)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    R_XMLSettings parserSettings;

    parserSettings.converters = handlers;
    parserSettings.trim = LOGICAL(r_trim)[0];
    parserSettings.skipBlankLines = LOGICAL(r_skipBlankLines)[0];

    return(RS_XML(createNodeChildren)(node, SIDEWAYS, &parserSettings));
}



USER_OBJECT_
RS_XML_xmlNodeName(USER_OBJECT_ snode)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    USER_OBJECT_ ans;
    DECL_ENCODING_FROM_NODE(node)


    PROTECT(ans = NEW_CHARACTER(1));
    SET_STRING_ELT(ans, 0, node->name ? ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(node->name)) : R_NaString);
    UNPROTECT(1);    
    return(ans);
}


USER_OBJECT_
RS_XML_xmlNodeNamespace(USER_OBJECT_ snode)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    USER_OBJECT_ ans;
    xmlNs *ns;
    DECL_ENCODING_FROM_NODE(node)

    ns = node->ns;
    if(!ns)
	return(NEW_CHARACTER(0));

    PROTECT(ans = NEW_CHARACTER(1));
    if(ns->href)
        SET_STRING_ELT(ans, 0, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(ns->href)));
    if(ns->prefix)
        SET_NAMES(ans, ScalarString(ENC_COPY_TO_USER_STRING(ns->prefix))); 

    SET_CLASS(ans, mkString("XMLNamespace"));
    UNPROTECT(1);    
    return(ans);
}

enum  {
    R_XML_NS_ADD_PREFIX = 1,
    R_XML_NS_ADD_URL_DEFS = 2
};

USER_OBJECT_
RS_XML_xmlNodeAttributes(USER_OBJECT_ snode, USER_OBJECT_ addNamespaces, USER_OBJECT_ addNamespaceURLs)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    R_XMLSettings parserSettings;
    parserSettings.addAttributeNamespaces = 0;
    if(LOGICAL_DATA(addNamespaces)[0])
	parserSettings.addAttributeNamespaces |= R_XML_NS_ADD_PREFIX;
    if(LOGICAL_DATA(addNamespaceURLs)[0])
	parserSettings.addAttributeNamespaces |= R_XML_NS_ADD_URL_DEFS;

    return(RS_XML(AttributeList)(node, &parserSettings));
}

USER_OBJECT_
RS_XML_xmlNodeParent(USER_OBJECT_ snode, USER_OBJECT_ manageMemory)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    if(node->parent && (node->parent->type == XML_DOCUMENT_NODE || node->parent->type == XML_HTML_DOCUMENT_NODE))
	return(NULL_USER_OBJECT);
    return(R_createXMLNodeRef(node->parent, manageMemory));
}


USER_OBJECT_
RS_XML_xmlNodeNumChildren(USER_OBJECT_ snode)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    int count = 0;
    xmlNodePtr ptr =  node->children;

    while(ptr) {
	count++;
	ptr = ptr->next;
    }
    return(ScalarInteger(count));
}


USER_OBJECT_
RS_XML_xmlNodeChildrenReferences(USER_OBJECT_ snode, USER_OBJECT_ r_addNames, USER_OBJECT_ manageMemory)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    USER_OBJECT_ ans, names = R_NilValue;
    int count = 0, i;
    xmlNodePtr ptr =  node->children;
    int addNames = LOGICAL(r_addNames)[0];
    DECL_ENCODING_FROM_NODE(node)

    while(ptr) {
	count++;
	ptr = ptr->next;
    }

    ptr = node->children;

    PROTECT(ans = NEW_LIST(count));
    if(addNames) 
	PROTECT(names = NEW_CHARACTER(count));

    for(i = 0; i < count ; i++, ptr = ptr->next) {
	SET_VECTOR_ELT(ans, i, R_createXMLNodeRef(ptr, manageMemory));
	if(addNames)
	    SET_STRING_ELT(names, i, ENC_COPY_TO_USER_STRING(ptr->name ? XMLCHAR_TO_CHAR(ptr->name) : ""));
    }
    if(addNames)
	SET_NAMES(ans, names);
    UNPROTECT(1 + addNames);
   
    return(ans);
}

USER_OBJECT_
R_getNodeChildByIndex(USER_OBJECT_ snode, USER_OBJECT_ r_index, USER_OBJECT_ manageMemory)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(snode);
    int count = 0, num;
    xmlNodePtr ptr = node->children;
    
    num = INTEGER(r_index)[0] - 1;
    if(num < 0) {
	PROBLEM "cannot index an internal node with a negative number %d", num
	    ERROR;
    }
	

    while(ptr && count < num) {
	count++;
	ptr = ptr->next;
    }

    return(ptr ? R_createXMLNodeRef(ptr, manageMemory) : NULL_USER_OBJECT);
}



static USER_OBJECT_
makeSchemaReference(xmlSchemaPtr schema)
{
    return(R_makeRefObject(schema, "xmlSchemaRef"));
/*
    USER_OBJECT_ ans;
    PROTECT(ans = R_MakeExternalPtr(schema, Rf_install("XMLSchema"), R_NilValue));
    SET_CLASS(ans, mkString("XMLSchema"));
    UNPROTECT(1);
    return(ans);
*/
}


#ifndef NO_XML_MEMORY_SHOW_ROUTINE
void
RS_XML_MemoryShow()
{
    xmlMemDisplay(stderr);
}
#endif

USER_OBJECT_
RS_XML_setDocumentName(USER_OBJECT_ sdoc, USER_OBJECT_ sname)
{
    /* if doc is NULL in C , return NULL in R
       If doc->name is NULL in C, return NA
       Otherwise,  return the string.
       */
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);

    if(!doc) {
	PROBLEM "NULL pointer supplied for internal document"
	    WARN;
	return(R_NilValue);
    }

    doc->URL = xmlStrdup(CHAR_TO_XMLCHAR(CHAR_DEREF(STRING_ELT(sname, 0))));

    return(sdoc);
}



USER_OBJECT_
RS_XML_getDocumentName(USER_OBJECT_ sdoc)
{
    /* if doc is NULL in C , return NULL in R
       If doc->name is NULL in C, return NA
       Otherwise,  return the string.
       */
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(sdoc);
    USER_OBJECT_ ans;
    const xmlChar *encoding;
    if(!doc) {
	PROBLEM "NULL pointer supplied for internal document"
	    WARN;
	return(R_NilValue);
    }
    encoding = doc->encoding;
    PROTECT(ans = NEW_CHARACTER(1));
    SET_STRING_ELT(ans, 0, doc->URL ? ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(doc->URL)) : R_NaString);
    UNPROTECT(1);    
    return(ans);
}


USER_OBJECT_
RS_XML_setKeepBlanksDefault(USER_OBJECT_ val)
{
    int prev;
    prev = xmlKeepBlanksDefault(INTEGER(val)[0]);
    return(ScalarInteger(prev));
}


USER_OBJECT_
RS_XML_xmlXIncludeProcessFlags(USER_OBJECT_ r_doc, USER_OBJECT_ r_flags)
{
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);
    int ans;

    ans = xmlXIncludeProcessFlags(doc, INTEGER(r_flags)[0]);
    return(ScalarInteger(ans));
}

USER_OBJECT_
RS_XML_xmlXIncludeProcessTreeFlags(USER_OBJECT_ r_node, USER_OBJECT_ r_flags)
{
    xmlNodePtr node;
    int flags = INTEGER(r_flags)[0];
    int n;
    xmlNodePtr prev, parent;
    SEXP ans = R_NilValue;

    node = (xmlNodePtr) R_ExternalPtrAddr(r_node);
    prev = node->prev;
    parent = node->parent;

    n = xmlXIncludeProcessTreeFlags(node, flags);

    if(n == 0)
	return(R_NilValue);
    else if(n == -1) {
	PROBLEM "failed in XInclude"
        ERROR;
    }

#if 0
    if(!prev)  {
	fprintf(stderr, "Adding to children of %s\n", prev->name);
        prev = parent->children;
    } else {
	fprintf(stderr, "Adding after  %s\n", prev->name);
	prev = prev->next;
    }

    prev = node->next;

    PROTECT(ans = NEW_LIST(n));
    for(i = 0; i < n; i++) {
	SET_VECTOR_ELT(ans, i, prev ? R_createXMLNodeRef(prev) : R_NilValue);
	prev = prev->next;
    }
    UNPROTECT(1);
#endif

    return(ans);
}



/**
   Create an R named list containing the attributes of the specified node.
 */

/*
   We could use the CONS mechanism rather than doing a double pass.
   Not certain what is quicker in this situation. Also, doesn't
   work that way in S4, so keep it this way.
*/
USER_OBJECT_ 
RS_XML(AttributeList)(xmlNodePtr node, R_XMLSettings *parserSettings)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  USER_OBJECT_ ans_names;
  xmlAttr * atts;
  const xmlChar *encoding = node->doc ? node->doc->encoding : NULL;

  int n = 0, i;

      /* Count the number of attributes*/
    atts = node->properties;

    while(atts) {
      n++;
      atts = atts->next;
    }

  if(n > 0) {
    SEXP ans_namespaces, ans_namespaceDefs;
    int nonTrivialAttrNamespaces = 0;
    int addNSPrefix = parserSettings->addAttributeNamespaces & R_XML_NS_ADD_PREFIX;
    int retNSDefs = parserSettings->addAttributeNamespaces & R_XML_NS_ADD_URL_DEFS;

    PROTECT(ans = NEW_CHARACTER(n));
    PROTECT(ans_names = NEW_CHARACTER(n));
    PROTECT(ans_namespaces = NEW_CHARACTER(n));
    PROTECT(ans_namespaceDefs = NEW_CHARACTER(retNSDefs ? n : 0));

         /* Loop over the attributes and create the string elements
            and the elements of the name vector.
          */

      atts = node->properties;

      for(i=0; i < n ; i++) {
	/* Have to be careful that atts->val and atts->val->context are non-null. Something like
           <a href=""> kills it otherwise.
         */
#ifdef LIBXML2
         SET_STRING_ELT(ans, i, 
                         ENC_COPY_TO_USER_STRING(
                                       XMLCHAR_TO_CHAR(
                                          ((atts->xmlChildrenNode != (xmlNode*)NULL && atts->xmlChildrenNode->content != (xmlChar*)NULL )
                                                       ? atts->xmlChildrenNode->content : (xmlChar*)""))));
#else
         SET_STRING_ELT(ans, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(((atts->val != (xmlNode*)NULL && atts->val->content != (xmlChar*)NULL )
                                                            ? atts->val->content : (xmlChar*)""))));

#endif
         if(atts->name) {
           if(addNSPrefix && atts->ns && atts->ns->prefix) {
             char buf[400];
             sprintf(buf, "%s:%s", atts->ns->prefix, atts->name);
             SET_STRING_ELT(ans_names, i, ENC_COPY_TO_USER_STRING(buf));
	   } else
             SET_STRING_ELT(ans_names, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(atts->name)));

	   if((addNSPrefix | retNSDefs) && atts->ns && atts->ns->prefix) {
	     SET_STRING_ELT(ans_namespaces, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(atts->ns->prefix)));

	     if(retNSDefs)
    	         SET_STRING_ELT(ans_namespaceDefs, i, ENC_COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(atts->ns->href)));

	     nonTrivialAttrNamespaces++;
	   }
	 }

         atts = atts->next;
     }

   if(nonTrivialAttrNamespaces) {
       if(retNSDefs) 
          Rf_setAttrib(ans_namespaces, Rf_install("names"), ans_namespaceDefs);
       Rf_setAttrib(ans, Rf_install("namespaces"), ans_namespaces);
   }
    SET_NAMES(ans, ans_names);

    UNPROTECT(nonTrivialAttrNamespaces ? 4 : 4);
   }
#if 0
   else
      ans = NEW_CHARACTER(0);
#endif

  return(ans);
}



SEXP
R_getDocEncoding(SEXP r_doc)
{
    xmlDocPtr doc = (xmlDocPtr) R_ExternalPtrAddr(r_doc);

    const xmlChar *encoding;
    SEXP ans;

    if(doc->type != XML_DOCUMENT_NODE && doc->type != XML_HTML_DOCUMENT_NODE)
	doc = ((xmlNodePtr) doc)->doc;
    if(!doc)
	return(NEW_CHARACTER(0));

    encoding = doc->encoding;
    PROTECT(ans = NEW_CHARACTER(1));
    SET_STRING_ELT(ans, 0, encoding ? CreateCharSexpWithEncoding(doc->encoding, doc->encoding) : R_NaString);
    UNPROTECT(1);

    return(ans);
}


int 
getTextElementLineNumber(xmlNodePtr node)
{
    int val = -1;

    if(node->parent)
	val = node->parent->line;

    xmlNodePtr prev = node->prev;
    while(prev) {
	if(prev->line > 0) {
	    val = prev->line;
	    break;
	}
	prev = prev->prev;
    }
    return(val);
}

SEXP
R_getLineNumber(SEXP r_node)
{
    xmlNodePtr node = (xmlNodePtr) R_ExternalPtrAddr(r_node);

    if(!node) {
	return(NEW_INTEGER(0));
    }

//    XML_GET_LINE(node)
    return(ScalarInteger(node->line == 0 ? 
			 getTextElementLineNumber(node) : node->line));
}


SEXP
R_xmlReadFile(SEXP r_filename, SEXP r_encoding, SEXP r_options) //, SEXP manageMemory)
{
    const char *filename;
    const char *encoding = NULL;
    int options;
    xmlDocPtr doc;

    filename = CHAR_DEREF(STRING_ELT(r_filename, 0));
    if(Rf_length(r_encoding))
       encoding = CHAR_DEREF(STRING_ELT(r_encoding, 0));
    options = INTEGER(r_options)[0];

    doc = xmlReadFile(filename, encoding, options);
    return(R_createXMLDocRef(doc));
}

SEXP
R_xmlReadMemory(SEXP r_txt, SEXP len, SEXP r_encoding, SEXP r_options, SEXP r_base) //, SEXP manageMemory)
{
    const char *txt;
    const char *encoding = NULL;
    const char *baseURL = NULL;
    int options;
    xmlDocPtr doc;

    txt = CHAR_DEREF(STRING_ELT(r_txt, 0));
    if(Rf_length(r_encoding))
       encoding = CHAR_DEREF(STRING_ELT(r_encoding, 0));
    options = INTEGER(r_options)[0];

    if(Rf_length(r_base))
	baseURL = CHAR_DEREF(STRING_ELT(r_base, 0));

    doc = xmlReadMemory(txt, INTEGER(len)[0], baseURL, encoding, options);
    return(R_createXMLDocRef(doc));
}



#if 1

int 
addXInclude(xmlNodePtr ptr, SEXP *ans, int level, SEXP manageMemory)
{
	if(ptr->type == XML_XINCLUDE_START) {
            int len = Rf_length(*ans) + 1;
	    PROTECT(*ans = SET_LENGTH(*ans, len));
	    SET_VECTOR_ELT(*ans, len - 1, R_createXMLNodeRef(ptr, manageMemory));
	    return(1);
	} else
	    return(0);

}

int
processKids(xmlNodePtr ptr, SEXP *ans, int  level, SEXP manageMemory)
{
        xmlNodePtr kids;
	int count = 0;
	kids = ptr->children;
        while(kids) {
	    count += addXInclude(kids, ans, level, manageMemory);
            count += processKids(kids, ans, level + 1, manageMemory);
            kids = kids->next;
      	}
	return(count);
}

#if 0
int
findXIncludeStartNodes(xmlNodePtr node, SEXP *ans, int level)
{
    const char * prefix[] = {"", "     ", "           ", "                " };
    xmlNodePtr ptr = node;
    int count = 0;

    addXInclude(node, ans, level);
    ptr = node;
    while(ptr) {
	count += addXInclude(ptr, ans, level);
	count += processKids(ptr, ans, level);
	ptr = ptr->next;
    }

//fprintf(stderr, "%s level = %d, %s: %p, type = %d\n", prefix[level], level, ptr->name, node, ptr->type);

//fprintf(stderr, "%p, %s, level = %d, type = %d\n", ptr, ptr->name, level, ptr->type);

    return(count);
}
#endif

/*
 This is a recursive version. We want an iterative version.
 */
SEXP
R_findXIncludeStartNodes(SEXP r_root, SEXP manageMemory)
{
    xmlNodePtr root;
    SEXP ans;
    int count;

    root = (xmlNodePtr) R_ExternalPtrAddr(r_root);
    if(!root)
	return(R_NilValue);

    PROTECT(ans = allocVector(VECSXP, 0));
//    count = findXIncludeStartNodes(root, &ans, 0);
    count = addXInclude(root, &ans, 0, manageMemory) + processKids(root, &ans, 0, manageMemory);
    UNPROTECT(count + 1);
    return(ans);
}

#endif
