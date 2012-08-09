/**
  This file defines the top-level entry routine called from R and S to parse and convert
  a DTD into a user-level object.

  Most of the routines are support routines. We leave them as global symbols (as opposed to static) so that others might be
  able to utilize them. Some are called from the other files (DocParse, specifically).


 * See Copyright for the license status of this software.

 */

#include "RSDTD.h"

#ifdef USE_S
extern char *strdup(const char *);
#endif



#include "Utils.h" /* for SET_CLASS_NAME */

#include <sys/stat.h>

/* For reading DTDs directly from text, not files. 
   Copied directly from parser.c in the libxml(-1.7.3) library.
*/

#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parserInternals.h>
#else
#include <libxml/parserInternals.h>
#endif


#define INPUT_CHUNK	250
#define CUR (ctxt->token ? ctxt->token : (*ctxt->input->cur))

#ifdef OLD_SKIP_BLANKS

#define SKIP_BLANKS 							\
    do { 								\
	while (IS_BLANK(CUR)) NEXT;					\
	if (*ctxt->input->cur == '%') xmlParserHandlePEReference(ctxt);	\
	if (*ctxt->input->cur == '&') xmlParserHandleReference(ctxt);	\
    } while (IS_BLANK(CUR));

#define NEXT {								\
    if (ctxt->token != 0) ctxt->token = 0;				\
    else {								\
    if ((*ctxt->input->cur == 0) &&					\
        (xmlParserInputGrow(ctxt->input, INPUT_CHUNK) <= 0)) {		\
	    xmlPopInput(ctxt);						\
    } else {								\
        if (*(ctxt->input->cur) == '\n') {				\
	    ctxt->input->line++; ctxt->input->col = 1;			\
	} else ctxt->input->col++;					\
	ctxt->input->cur++;						\
        if (*ctxt->input->cur == 0)					\
	    xmlParserInputGrow(ctxt->input, INPUT_CHUNK);		\
    }									\
    if (*ctxt->input->cur == '%') xmlParserHandlePEReference(ctxt);	\
    if (*ctxt->input->cur == '&') xmlParserHandleReference(ctxt);	\
}}

#else

#define SKIP_BLANKS xmlSkipBlankChars(ctxt)
#define NEXT xmlNextChar(ctxt)

#endif


/* end temporary. */



/* Macro that sets the name of an enumerated value by indexing into an array of
   names based on the value being represented.
 */
#define SET_ENUM_NAME(names, which, obj) RS_XML_SetNames(1, RS_XML_##names+which-1,obj);



enum {DTD_ELEMENTS_SLOT, DTD_ENTITIES_SLOT, DTD_NUM_SLOTS};
const char *RS_XML(DtdNames)[] = {"elements", "entities"};
/**
  Top-level entry point for reading the DTD.
   dtdFileName - name of the DTD.
   externalId  - file identfying the DTD from which its contents are read.
 */
USER_OBJECT_
RS_XML(getDTD)(USER_OBJECT_ dtdFileName, USER_OBJECT_ externalId, 
  	       USER_OBJECT_ asText, USER_OBJECT_ isURL, USER_OBJECT_ errorFun)
{
 USER_OBJECT_ ans;
 const char * dtdName = strdup(CHAR_DEREF(STRING_ELT(dtdFileName, 0)));
 const char * extId = strdup(CHAR_DEREF(STRING_ELT(externalId, 0)));
 int localAsText = LOGICAL_DATA(asText)[0];
 xmlParserCtxtPtr ctxt;
 xmlDtdPtr        dtd;
 

 if(localAsText) {
     ctxt = xmlCreateDocParserCtxt((xmlChar*) extId);
 } else {
     if(LOGICAL_DATA(isURL)[0] == 0) {
	 struct stat tmp_stat;
	 if(extId == NULL || stat(extId, &tmp_stat) < 0) {
             PROBLEM "Can't find file %s", extId
	     ERROR;
	 }
     }

      ctxt = xmlCreateFileParserCtxt(extId);  /* from parser.c xmlSAXParseFile */
 }

 if(ctxt == NULL) {
    PROBLEM "error creating XML parser for `%s'", extId
    ERROR;
 }

  ctxt->validate = 1;

#ifdef RS_XML_SET_STRUCTURED_ERROR  /* Done in R code now. */
  xmlSetStructuredErrorFunc(errorFun == NULL_USER_OBJECT ? NULL : errorFun, R_xmlStructuredErrorHandler);
#endif

  if(ctxt->myDoc == NULL)
    ctxt->myDoc = xmlNewDoc(BAD_CAST "1.0");


  if(localAsText) {
    xmlCreateIntSubset(ctxt->myDoc, CHAR_TO_XMLCHAR(dtdName), NULL, NULL);
    while(ctxt->input->cur && ctxt->input->cur[0]) {
      SKIP_BLANKS;
      xmlParseMarkupDecl(ctxt);
    }
    dtd = ctxt->myDoc->intSubset;
  }  else {
       /* Read the file. */
       /* Added for 2.2.12. May need to be conditional for 1.8.9 */
    ctxt->sax->internalSubset(ctxt->userData, CHAR_TO_XMLCHAR(dtdName), CHAR_TO_XMLCHAR(extId), CHAR_TO_XMLCHAR(extId));
       /* Warnings will ensue about not being in internal subset if we don't go to level 2. */
#ifdef USE_EXTERNAL_SUBSET
    ctxt->inSubset = 2;
    ctxt->sax->externalSubset(ctxt->userData, CHAR_TO_XMLCHAR(dtdName), CHAR_TO_XMLCHAR(extId), CHAR_TO_XMLCHAR(extId));
    ctxt->inSubset = 0;
#endif
    dtd = ctxt->myDoc->extSubset;
  }

#ifdef RS_XML_SET_STRUCTURED_ERROR 
  xmlSetStructuredErrorFunc(NULL, NULL);
#endif

  if(dtd == NULL) {
      if(errorFun != NULL_USER_OBJECT) {
        RSXML_structuredStop(errorFun, NULL);
      } else
        return(stop("DTDParseError", "error parsing %s", dtdName));

   PROBLEM "error in DTD %s", extId
   ERROR;
  }

  if(localAsText) {
      /* Don't bother with the internal and external split, just do the internal and return it. */
    ans = RS_XML(createDTDParts)(dtd, ctxt);
  } else 
    ans = RS_XML(ConstructDTDList)(ctxt->myDoc, 0, ctxt);

  return(ans);
}


const char *RS_XML(DtdTypeNames)[] = {"external", "internal"};
/**
  Create the representation of the DTD contained in the Document pointer,
  using both the internal and external descriptions and returning a list
  of the appropriate length. If the external description is empty, then we just
  return the description of the internal description. Otherwise, we return a named
  list of length 2 containing descriptions of both. 
 */
USER_OBJECT_
RS_XML(ConstructDTDList)(xmlDocPtr myDoc, int processInternals, xmlParserCtxtPtr ctxt)
{
 USER_OBJECT_ ans, el, klass;
 int i;
 xmlDtdPtr sets[2];
  
 int num = processInternals ? 2  : 1;
 sets[0] = myDoc->extSubset;

 if(processInternals) {
   sets[1] = myDoc->intSubset;
 }

  PROTECT(ans = NEW_LIST(num));
  for(i = 0; i < num; i++) {
    if(sets[i]) {
      SET_VECTOR_ELT(ans, i, el= RS_XML(createDTDParts)(sets[i], ctxt));
      PROTECT(klass = NEW_CHARACTER(1));
      SET_STRING_ELT(klass, 0, mkChar(i==0 ? "ExternalDTD" : "InternalDTD"));
      SET_CLASS(el, klass);
      UNPROTECT(1);
    }
  }
   RS_XML(SetNames)(num, RS_XML(DtdTypeNames), ans);

   UNPROTECT(1);


 return(processInternals ? ans : VECTOR_ELT(ans, 0));
}

/**
  Process the entities and elements of the DTD, returning a list
  of length 2, irrespective if either is empty.
 */
USER_OBJECT_
RS_XML(createDTDParts)(xmlDtdPtr dtd,  xmlParserCtxtPtr ctxt)
{ 
 xmlEntitiesTablePtr entities;
 xmlElementTable *table;
  USER_OBJECT_ ans;
  PROTECT(ans = NEW_LIST(DTD_NUM_SLOTS));
   table = (xmlElementTable*) dtd->elements;
   if(table)
      SET_VECTOR_ELT(ans, DTD_ELEMENTS_SLOT,  RS_XML(ProcessElements)(table, ctxt));


  entities = (xmlEntitiesTablePtr) dtd->entities;
  if(entities)
     SET_VECTOR_ELT(ans, DTD_ENTITIES_SLOT, RS_XML(ProcessEntities)(entities, ctxt));
   
   RS_XML(SetNames)(DTD_NUM_SLOTS, RS_XML(DtdNames), ans);

   UNPROTECT(1);
 return(ans);
}


#ifdef LIBXML2
struct ElementTableScanner {
  USER_OBJECT_ dtdEls;
  USER_OBJECT_ dtdNames;
  int counter;
};

#ifndef NO_XML_HASH_SCANNER_RETURN
void *RS_xmlElementTableConverter(void *payload, void *data, xmlChar *name);
void* RS_xmlEntityTableConverter(void *payload, void *data, xmlChar *name);
#else
void RS_xmlElementTableConverter(void *payload, void *data, xmlChar *name);
void RS_xmlEntityTableConverter(void *payload, void *data, xmlChar *name);
#endif


#endif

/**
 Convert the elements into a named list of objects with each element
 representing an element.
 */
USER_OBJECT_
RS_XML(ProcessElements)(xmlElementTablePtr table, xmlParserCtxtPtr ctxt)
{
 USER_OBJECT_ dtdEls = NULL_USER_OBJECT;
 int n;
#ifdef LIBXML2
 n = xmlHashSize(table);
#else
 int i;
 xmlElementPtr xmlEl;
 n = table->nb_elements;
#endif

  if(n > 0) {
    USER_OBJECT_ dtdNames = NULL_USER_OBJECT;

    PROTECT(dtdEls = NEW_LIST(n));
    PROTECT(dtdNames = NEW_CHARACTER(n));
#ifdef LIBXML2
 {
   struct ElementTableScanner scanData;
   scanData.dtdEls = dtdEls;
   scanData.dtdNames = dtdNames;
   scanData.counter = 0;

   xmlHashScan(table, RS_xmlElementTableConverter, &scanData);

   SET_LENGTH(dtdEls, scanData.counter);
   SET_LENGTH(dtdNames, scanData.counter);
 }
#else
      for(i = 0; i < n; i++) {
     	xmlEl = table->table[i];
     	SET_VECTOR_ELT(dtdEls, i, RS_XML(createDTDElement)(xmlEl));
     	SET_STRING_ELT(dtdNames , i, COPY_TO_USER_STRING(xmlEl->name));
      }
#endif
    SET_NAMES(dtdEls, dtdNames);
    UNPROTECT(2);
  } 

  return(dtdEls);
}

#ifdef LIBXML2
/* libxml2 2.4.21 (and perhaps earlier) redefines this to have a return type of void,
   rather than void*. Need to figure out if this makes any real difference to the interface
   and also when to 
*/
#ifndef NO_XML_HASH_SCANNER_RETURN
void*
#else
void
#endif
RS_xmlElementTableConverter(void *payload, void *data, xmlChar *name)
{
  struct ElementTableScanner *scanData = (struct ElementTableScanner *)data;

 SET_VECTOR_ELT(scanData->dtdEls, scanData->counter, RS_XML(createDTDElement)( payload));
 SET_STRING_ELT(scanData->dtdNames, scanData->counter, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(name)));

 scanData->counter++;
#ifndef NO_XML_HASH_SCANNER_RETURN
 return(payload);
#endif
}
#endif

/**
  Process the list of entities and convert them into a named list containing
  entity descriptions.
 */
USER_OBJECT_
RS_XML(ProcessEntities)(xmlEntitiesTablePtr table, xmlParserCtxtPtr ctxt)
{
 USER_OBJECT_ dtdEls = NULL_USER_OBJECT;
 int n;
#ifdef LIBXML2
 n = xmlHashSize(table);
#else
 xmlEntity *xmlEl;
 int i;
 n = table->nb_entities;
#endif
  if(n > 0) {
    USER_OBJECT_ dtdNames;

    PROTECT(dtdEls = NEW_LIST(n));
    PROTECT(dtdNames = NEW_CHARACTER(n));

#ifdef LIBXML2
 {
   struct ElementTableScanner scanData;
   scanData.dtdEls = dtdEls;
   scanData.dtdNames = dtdNames;
   scanData.counter = 0;

   xmlHashScan(table, RS_xmlEntityTableConverter, &scanData);
     /* Reset the length to be the actual number rather than the
        capacity of the table.
        See ProcessElements also.
      */

   SET_LENGTH(dtdEls, scanData.counter);
   SET_LENGTH(dtdNames, scanData.counter);

 }
#else
      for(i = 0; i < n; i++) {
     	xmlEl = table->table +i;
     	SET_VECTOR_ELT(dtdEls, i, RS_XML(createDTDEntity)(xmlEl));
     	SET_STRING_ELT(dtdNames, i, COPY_TO_USER_STRING(xmlEl->name));
      }
#endif
    SET_NAMES(dtdEls, dtdNames);
    UNPROTECT(2);
  } 

  return(dtdEls);
}

#ifdef LIBXML2

#ifndef NO_XML_HASH_SCANNER_RETURN
void*
#else
void
#endif
RS_xmlEntityTableConverter(void *payload, void *data, xmlChar *name)
{
  struct ElementTableScanner *scanData = (struct ElementTableScanner *)data;

 SET_VECTOR_ELT(scanData->dtdEls, scanData->counter, RS_XML(createDTDEntity)( payload));
 SET_STRING_ELT(scanData->dtdNames, scanData->counter, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(name)));

 scanData->counter++;
#ifndef NO_XML_HASH_SCANNER_RETURN
 return(payload);
#endif
}
#endif /* End of LIBXML2 for definint RS_xmlEntityTableConverter */

/**
  Convert an entity definition into a user-level object, handling both internal and system entities.

  We could have different slots for the two types of entities, but that may make it harder to program.
  S3/R classes aren't exactly good with inheritance of slots.
 */

/**
  Indices for the slots of the user-level list representing the entity.
 */
enum { DTD_ENTITY_NAME_SLOT,  DTD_ENTITY_CONTENT_SLOT, DTD_ENTITY_ORIG_SLOT, DTD_ENTITY_NUM_SLOTS};
/* 
  Names for the slots of the user-level list representing the entity.
*/
const char *RS_XML(EntityNames)[] = {"name", "value", "original"};

USER_OBJECT_
RS_XML(createDTDEntity)(xmlEntityPtr entity)
{
  USER_OBJECT_ ans;
  const xmlChar *value;
  const char *localClassName;

  PROTECT(ans = NEW_LIST(DTD_ENTITY_NUM_SLOTS));

  SET_VECTOR_ELT(ans, DTD_ENTITY_NAME_SLOT, NEW_CHARACTER(1));
  SET_STRING_ELT(VECTOR_ELT(ans, DTD_ENTITY_NAME_SLOT), 0, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(entity->name)));

   if(entity->content == NULL) {
     value = entity->SystemID;
     localClassName = "XMLSystemEntity";
   } else {
     value = entity->content;
     localClassName = "XMLEntity";
   }

  SET_VECTOR_ELT(ans, DTD_ENTITY_CONTENT_SLOT, NEW_CHARACTER(1));
   SET_STRING_ELT(VECTOR_ELT(ans, DTD_ENTITY_CONTENT_SLOT), 0, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(value)));

   if(entity->orig) {
     SET_VECTOR_ELT(ans, DTD_ENTITY_ORIG_SLOT, NEW_CHARACTER(1));
      SET_STRING_ELT(VECTOR_ELT(ans, DTD_ENTITY_ORIG_SLOT), 0, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(entity->orig)));
   }

   RS_XML(SetNames)(DTD_ENTITY_NUM_SLOTS, RS_XML(EntityNames), ans);

   /* Set the class of the specified object based on whether it is a internal or external entity. */
   SET_CLASS_NAME(localClassName, ans);

   UNPROTECT(1);

  return(ans);
}






enum { DTD_ELEMENT_NAME_SLOT, DTD_ELEMENT_TYPE_SLOT, DTD_ELEMENT_CONTENT_SLOT, DTD_ELEMENT_ATTRIBUTES_SLOT, DTD_ELEMENT_NUM_SLOTS};
const char *RS_XML(ElementNames)[] = {"name", "type", "contents","attributes"};
const char *RS_XML(ElementTypeNames)[] = {"empty", "any", "mixed","element"};

/**
  Creates the user-level object representing the definition of an element within a DTD,
  including its attribute definitions, its type, name and finally contents.
  This is an object of class XMLElementDef.
 */
USER_OBJECT_
RS_XML(createDTDElement)(xmlElementPtr el)
{
 USER_OBJECT_ rel;
 int type;

#ifdef XML_ELEMENT_ETYPE
 type = el->etype;
#else
 type = el->type;
#endif

   PROTECT(rel =  NEW_LIST(DTD_ELEMENT_NUM_SLOTS));

 SET_VECTOR_ELT(rel, DTD_ELEMENT_NAME_SLOT, NEW_CHARACTER(1));
 SET_STRING_ELT(VECTOR_ELT(rel, DTD_ELEMENT_NAME_SLOT), 0, COPY_TO_USER_STRING( XMLCHAR_TO_CHAR( ( el->name ? el->name : (xmlChar*)""))));

 SET_VECTOR_ELT(rel, DTD_ELEMENT_TYPE_SLOT, NEW_INTEGER(1));
 INTEGER_DATA(VECTOR_ELT(rel, DTD_ELEMENT_TYPE_SLOT))[0] = el->type;
 SET_ENUM_NAME(ElementTypeNames, type, VECTOR_ELT(rel, DTD_ELEMENT_TYPE_SLOT));


 if(el->content != NULL)
   SET_VECTOR_ELT(rel, DTD_ELEMENT_CONTENT_SLOT, RS_XML(createDTDElementContents)(el->content, el, 1));

 SET_VECTOR_ELT(rel, DTD_ELEMENT_ATTRIBUTES_SLOT, RS_XML(createDTDElementAttributes)(el->attributes, el));

 RS_XML(SetNames)(DTD_ELEMENT_NUM_SLOTS, RS_XML(ElementNames), rel);

 SET_CLASS_NAME("XMLElementDef", rel);

 UNPROTECT(1);
 return(rel);
}


/* Indices for the slots/elements in the list. */
enum {DTD_CONTENT_TYPE_SLOT, DTD_CONTENT_OCCURANCE_SLOT, DTD_CONTENT_ELEMENTS_SLOT, DTD_CONTENT_NUM_SLOTS};
/* names for the elements */
const char *RS_XML(ContentNames)[] = {"type", "ocur", "elements"};
/* Names for the enumerated types of the entries in the data */
const char *RS_XML(ContentTypeNames)[] = {"PCData", "Element", "Sequence","Or"};
const char *RS_XML(OccuranceNames)[] = {"Once", "Zero or One", "Mult","One or More"};

/**

  Create an object representing the DTD element. The returned value is a list
  with 3 elements. The names are given by the array ContentNames above.  The
  type and ocur elements are simple named integers identifying that the element
  is simple parsed character data, an element or a composite element which is
  either an one of several possible types (that is an OR or |) or an ordered
  sequence of types. The ocur field indicates whether this element is to be
  expected in this position exactly once (default qualifier), zero or one
  (i.e. optional) (?) , any number of times (including omitted) (*) and finally
  , at least once, but possible more(+)


  The recursive argument allows the RS_XML(SequenceContent) routine  to use part of this
  routine.  

*/

USER_OBJECT_
RS_XML(createDTDElementContents)(xmlElementContentPtr vals, xmlElementPtr el, int recursive)
{
  char *localClassName = NULL;
  int num = 0;
  USER_OBJECT_ ans = NULL_USER_OBJECT;

  PROTECT(ans = NEW_LIST(DTD_CONTENT_NUM_SLOTS));

  SET_VECTOR_ELT(ans, DTD_CONTENT_TYPE_SLOT, NEW_INTEGER(1));
  INTEGER_DATA(VECTOR_ELT(ans, DTD_CONTENT_TYPE_SLOT))[0] = vals->type;
  SET_ENUM_NAME(ContentTypeNames, vals->type, VECTOR_ELT(ans, DTD_CONTENT_TYPE_SLOT));

  SET_VECTOR_ELT(ans, DTD_CONTENT_OCCURANCE_SLOT, NEW_INTEGER(1));
  INTEGER_DATA(VECTOR_ELT(ans, DTD_CONTENT_OCCURANCE_SLOT))[0] = vals->ocur;
  SET_ENUM_NAME(OccuranceNames, vals->ocur, VECTOR_ELT(ans, DTD_CONTENT_OCCURANCE_SLOT));


  if(vals->type == XML_ELEMENT_CONTENT_SEQ && recursive) {
       SET_VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT, RS_XML(SequenceContent)(vals, el));
  } else {
    num += (vals->c1 != NULL);
    if(recursive || 1)
      num += (vals->c2 != NULL);

    if(num > 0) {   
      SET_VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT, NEW_LIST(num));
      num = 0;
      if(vals->c1) {
        SET_VECTOR_ELT(VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT), num++, RS_XML(createDTDElementContents)(vals->c1, el, 1));
      }

      if(recursive || 1) {
        if(vals->c2) {
         SET_VECTOR_ELT(VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT), num++, RS_XML(createDTDElementContents)(vals->c2, el, 1));
        }
       }
    } else {
     if(vals->name) {
        SET_VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT,  NEW_CHARACTER(1));
        SET_STRING_ELT(VECTOR_ELT(ans, DTD_CONTENT_ELEMENTS_SLOT), 0, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(vals->name)));
      }
   }
  }
  switch(vals->type) {
    case XML_ELEMENT_CONTENT_SEQ:
      localClassName = "XMLSequenceContent";
      break;
    case XML_ELEMENT_CONTENT_OR:
      localClassName = "XMLOrContent";
      break;
    default:
      localClassName = "XMLElementContent";
  }

      if(localClassName) {
	SET_CLASS_NAME(localClassName, ans);
      }


  RS_XML(SetNames)(DTD_CONTENT_NUM_SLOTS, RS_XML(ContentNames), ans);

  UNPROTECT(1);
  return(ans);
}


/**
  Process the DTD element, knowing that it is a sequence definition.
  Compute the number of elements in the sequence by flattening  out the 
  lob-sided tree and then convert the each element and append it to the list. 
 */
USER_OBJECT_
RS_XML(SequenceContent)(xmlElementContentPtr vals, xmlElementPtr el)
{
  xmlElementContentPtr ptr = vals->c2;
  int ok = 1, n=1, deep = 0;
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  USER_OBJECT_ tmp;

     /* Count the number of elements in this sequence. 
        Descend all the c2's below this one.
      */
  while(ptr && ok) {
    ok = (ptr->type == XML_ELEMENT_CONTENT_SEQ); 
    ptr = ptr->c2;
    n++;
  }

  /* Now build the list and the elements within it.*/
  PROTECT(ans = NEW_LIST(n));
  SET_VECTOR_ELT(ans, 0, RS_XML(createDTDElementContents)(vals->c1, el, 1));

  ptr = vals->c2;
  n = 1;
  do {
      /* Some jumping around here beacuse of the recursion and split types. Should be cleaner. */
    deep = (ptr->c1  != NULL && ptr->type == XML_ELEMENT_CONTENT_SEQ );
    tmp = RS_XML(createDTDElementContents)( deep ? ptr->c1 : ptr, el, deep);
    SET_VECTOR_ELT(ans, n, tmp); 
    ok = (ptr->type == XML_ELEMENT_CONTENT_SEQ); 
    ptr = ptr->c2;
    n++;
  } while(ptr && ok);

  UNPROTECT(1);
  return(ans);
}





/**
   Routine that creates a named list of XMLAttributeDef objects from a collection of 
   attribute definitions associated with the specified XML element definition.
 */
USER_OBJECT_
RS_XML(createDTDElementAttributes)(xmlAttributePtr vals, xmlElementPtr el)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  USER_OBJECT_ names;
  xmlAttributePtr tmp = vals;
  int n = 0, i;

  while(tmp) {
#ifdef LIBXML2
    tmp = tmp->nexth;
#else
    tmp = tmp->next;
#endif
    n++;
  }

  if(n > 0) {
    tmp = vals;
    PROTECT(ans = NEW_LIST(n));
    PROTECT(names = NEW_CHARACTER(n));
    for(i=0; i < n; i++) {
       SET_VECTOR_ELT(ans, i,  RS_XML(createDTDAttribute)(tmp, el));
       SET_STRING_ELT(names, i, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(tmp->name)));
#ifdef LIBXML2
    tmp = tmp->nexth;
#else
    tmp = tmp->next;
#endif
    }
    SET_NAMES(ans, names);
    UNPROTECT(2);
  }

  return(ans);
}


enum {DTD_ATTRIBUTE_NAME_SLOT, DTD_ATTRIBUTE_TYPE_SLOT, DTD_ATTRIBUTE_DEFAULT_SLOT, DTD_ATTRIBUTE_DEFAULT_VALUE_SLOT, DTD_ATTRIBUTE_NUM_SLOTS};

/* Names for the possible types of an attribute. */
const char *RS_XML(AttributeTypeNames)   [] = {"CDATA","Id", "IDRef", "IDRefs", "Entity","Entities", "NMToken", "NMTokens", "Enumeration", "Notation"};
/* Names for the possible modes or default types of an attribute. */
const char *RS_XML(AttributeDefaultNames)[] = {"None", "Required", "Implied", "Fixed"};

/* Names of the elements within the returned list */
const char *RS_XML(AttributeSlotNames)[] = {"name", "type", "defaultType", "defaultValue"};


/**
  Create a user-level version of a DTD attribute within an Attribute list within the DTD.
  Return a vector of length 4 with elements named
       Name, Type, Default Type and Default Value.
   The first is a simple string (character vector of length 1). The next two are enumerated
   types describing the type of the attribute value and whether it is required, fixed, implied, etc.
   The final value is the default value 
 */
USER_OBJECT_
RS_XML(createDTDAttribute)(xmlAttributePtr val, xmlElementPtr el)
{
  USER_OBJECT_ ans;
  int attrType;

#ifdef XML_ATTRIBUTE_ATYPE
  attrType = val->atype;
#else
  attrType = val->type;
#endif

  PROTECT(ans = NEW_LIST(DTD_ATTRIBUTE_NUM_SLOTS));

  SET_VECTOR_ELT(ans, DTD_ATTRIBUTE_NAME_SLOT, NEW_CHARACTER(1));
  SET_STRING_ELT(VECTOR_ELT(ans, DTD_ATTRIBUTE_NAME_SLOT), 0, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(val->name)));

 SET_VECTOR_ELT(ans, DTD_ATTRIBUTE_TYPE_SLOT, NEW_INTEGER(1));
 INTEGER_DATA(VECTOR_ELT(ans, DTD_ATTRIBUTE_TYPE_SLOT))[0] =  val->type;
 SET_ENUM_NAME(AttributeTypeNames, attrType, VECTOR_ELT(ans, DTD_ATTRIBUTE_TYPE_SLOT));

 SET_VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_SLOT, NEW_INTEGER(1));
 INTEGER_DATA(VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_SLOT))[0] =  val->def;
 SET_ENUM_NAME(AttributeDefaultNames, val->def, VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_SLOT));

 if(val->type == XML_ATTRIBUTE_ENUMERATION) {
   SET_VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_VALUE_SLOT, RS_XML(AttributeEnumerationList)(val->tree, val, el));
 } else {
    SET_VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_VALUE_SLOT, NEW_CHARACTER(1));
    SET_STRING_ELT(VECTOR_ELT(ans, DTD_ATTRIBUTE_DEFAULT_VALUE_SLOT), 0, COPY_TO_USER_STRING( XMLCHAR_TO_CHAR( (val->defaultValue ? val->defaultValue : (xmlChar*)""))));
 }
  RS_XML(SetNames)(DTD_ATTRIBUTE_NUM_SLOTS, RS_XML(AttributeSlotNames),  ans);


  SET_CLASS_NAME("XMLAttributeDef", ans);

  UNPROTECT(1);
  return(ans);
}    


/**
  Return a character vector containing the elements listed in the enumeration of possible
  values in the attribute. These arise in DTD entries such as
    <ATTLIST el
               foo   (true | false)
    >
 */
USER_OBJECT_
RS_XML(AttributeEnumerationList)(xmlEnumerationPtr list, xmlAttributePtr attr, xmlElementPtr element)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  xmlEnumerationPtr tmp = list;
  int n = 0;

    /* Count the number of entries in the list/table. */
  while(tmp) {
    n++;
    tmp = tmp->next;
  }

       /* Now convert each entry and add it to a list. */
  if(n > 0) {
    int i;
    PROTECT(ans  = NEW_CHARACTER(n));
    tmp = list;
    for(i = 0; i < n; i++) {
      SET_STRING_ELT(ans, i, COPY_TO_USER_STRING(XMLCHAR_TO_CHAR(tmp->name)));
      tmp = tmp->next;
    }
    UNPROTECT(1);
  }
  return(ans);
}
