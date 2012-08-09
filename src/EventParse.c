
/*
 File that provides the entry point for an event driven XML parser
 that performs callbacks to the different user-level functions in
 the closure passed to it.

 * See Copyright for the license status of this software.

 */

#include "EventParse.h"


#define R_USE_XML_ENCODING 1
#include "Utils.h" /* For the findFunction and invokeFunction. */
#undef R_USE_XML_ENCODING    /*XXX */

#include "RSCommon.h"

extern void R_PreserveObject(SEXP);
extern void R_ReleaseObject(SEXP);


/*
  Read the specified file as an XML document and invoke functions/methods in
  the handlers closure object when each node in the tree is encountered by 
  the parser. These events are startElement,endElement, character data, etc.
  The remaining arguments control how the calls to the user level functions
  are made. The first (addContext) indicates whether information about the position
  in the tree (an integer index path)

 */

typedef Rboolean Sboolean;

Sboolean
IsConnection(USER_OBJECT_ obj)
{
   int i;
   USER_OBJECT_ k = GET_CLASS(obj);
   if(GET_LENGTH(k) == 0)
     return(FALSE);

   for(i = 0; i < GET_LENGTH(k); i++) {
      if(strcmp("connection", CHAR_DEREF(STRING_ELT(k, i))) == 0)
	return(TRUE);
   }

   return(FALSE);
}


static USER_OBJECT_ 
RS_XML(createAttributesList)(const char **atts, const xmlChar *encoding) 
{
  int n=0, i;
  const char **ptr = atts;
  USER_OBJECT_ attr_names;
  USER_OBJECT_ attr_values;


  while(ptr && ptr[0]) {
    n++;
    ptr += 2;
  }

 
  if(n < 1)
    return(NULL_USER_OBJECT);

  PROTECT(attr_values = NEW_CHARACTER(n));
  PROTECT(attr_names = NEW_CHARACTER(n));
     ptr = atts;
     for(i=0; i < n; i++, ptr+=2) {
      SET_STRING_ELT(attr_values, i, ENC_COPY_TO_USER_STRING(ptr[1]));
      SET_STRING_ELT(attr_names, i,  ENC_COPY_TO_USER_STRING(ptr[0]));
     }
    SET_NAMES(attr_values, attr_names);
  UNPROTECT(2);

  return(attr_values);
}


USER_OBJECT_ 
RS_XML(Parse)(USER_OBJECT_ fileName, USER_OBJECT_ handlers, USER_OBJECT_ endElementHandlers,
               USER_OBJECT_ addContext, 
                USER_OBJECT_ ignoreBlanks,  USER_OBJECT_ useTagName, USER_OBJECT_ asText,
                 USER_OBJECT_ trim, USER_OBJECT_ useExpat, USER_OBJECT_ stateObject,
                  USER_OBJECT_ replaceEntities, USER_OBJECT_ validate, USER_OBJECT_ saxVersion,
	      USER_OBJECT_ branches, USER_OBJECT_ useDotNames, USER_OBJECT_ errorFun,
              USER_OBJECT_ manageMemory)
{
#ifdef LIBEXPAT
  FILE *file = NULL;
  int expat = 0;
#endif
  char *name, *input;
  RS_XML_ContentSourceType asTextBuffer;
  RS_XMLParserData *parserData;
  USER_OBJECT_ ans;
  int status;


  if(IsConnection(fileName) || isFunction(fileName))
     asTextBuffer = RS_XML_CONNECTION;
  else 
     asTextBuffer = LOGICAL_DATA(asText)[0] ? RS_XML_TEXT : RS_XML_FILENAME;

#ifdef LIBEXPAT
   expat = LOGICAL_DATA(useExpat)[0];
  if(expat && asTextBuffer == 0) {
#ifdef USE_R
    name = R_ExpandFileName(CHAR(STRING(fileName)[0]));
#else
    name = CHARACTER_DATA(fileName)[0];
#endif
    file = fopen(name,"r");
    if(file == NULL) {
      PROBLEM "Can't find file %s", name
      ERROR;
    }

  } else
#endif /* ifdef LIBEXPAT */


  if(asTextBuffer == RS_XML_CONNECTION) {
    name = strdup("<connection>");
    input = (char *)fileName;/*XXX*/
  } else {
    name = strdup(CHAR_DEREF(STRING_ELT(fileName, 0)));
    input = name;
  }

  parserData = RS_XML(createParserData)(handlers, manageMemory);
  parserData->endElementHandlers = endElementHandlers;
  parserData->branches         = branches;
  parserData->fileName         = name; 
  parserData->callByTagName    = LOGICAL_DATA(useTagName)[0]; 
  parserData->addContextInfo   = LOGICAL_DATA(addContext)[0]; 
  parserData->trim             = LOGICAL_DATA(trim)[0]; 
  parserData->ignoreBlankLines = LOGICAL_DATA(ignoreBlanks)[0]; 
  parserData->stateObject = (stateObject == NULL_USER_OBJECT ? NULL : stateObject);
  parserData->useDotNames = LOGICAL_DATA(useDotNames)[0];
  parserData->dynamicBranchFunction = NULL;

  /*Is this necessary? Shouldn't it already be protected? Or is there a chance that we may 
    be doing this asynchronously in a pull approach. */
  if(parserData->stateObject && parserData->stateObject != NULL_USER_OBJECT)
    R_PreserveObject(parserData->stateObject);


#ifdef LIBEXPAT
  if(expat) {
      if(asTextBuffer == 0) {
     	RS_XML(parseWithParserData)(file, parserData);
      } else {
     	parserData->fileName = "<buffer>"; 
     	RS_XML(parseBufferWithParserData)(name, parserData);
     	free(name); /* match the strdup() above */
      }
  } else 
#endif /* ifdef LIBEXPAT */

#if 0
    /* If one wants entities expanded directly and to appear as text.  */
   xmlSubstituteEntitiesDefault(LOGICAL_DATA(replaceEntities)[0]);   
#endif

  status = RS_XML(libXMLEventParse)(input, parserData, asTextBuffer, INTEGER_DATA(saxVersion)[0]);

/* How about using R_alloc() here so that it is freed, i.e. for the fileName and the parserData itself. */
  ans = parserData->stateObject ? parserData->stateObject : handlers;
  free(parserData->fileName);


  if(parserData->stateObject && parserData->stateObject != NULL_USER_OBJECT)
     R_ReleaseObject(parserData->stateObject);

  if(status != 0) {
    RSXML_structuredStop(errorFun, NULL);
  }

  /* free(parserData); Now using R_alloc */

  return(ans);
}



/**
Handler that receives declarations of unparsed entities. These are entity declarations that have a notation (NDATA) field: 

                  <!ENTITY logo SYSTEM "images/logo.gif" NDATA gif>
*/
void 
RS_XML(entityDeclarationHandler)(void *userData, const XML_Char *entityName, 
                                 const XML_Char *base, const XML_Char *systemId, 
                                   const XML_Char *publicId, const XML_Char *notationName)
{
 RS_XMLParserData *parserData = (RS_XMLParserData*)userData;
 USER_OBJECT_ opArgs;
 int i, num;
  const XML_Char *xml_args[5];

  DECL_ENCODING_FROM_EVENT_PARSER(parserData)

   num = sizeof(xml_args)/sizeof(xml_args[0]);

   xml_args[0] = entityName; xml_args[1] = base;
   xml_args[2] = systemId; xml_args[3] = publicId;
   xml_args[4] = notationName;

  opArgs = NEW_LIST(num);
  for(i =0;i < num; i++) {
   SET_VECTOR_ELT(opArgs, i,  NEW_CHARACTER(1));
   SET_STRING_ELT(VECTOR_ELT(opArgs, i), 0, ENC_COPY_TO_USER_STRING(xml_args[i] ? xml_args[i] :  "")); 
  }

  RS_XML(callUserFunction)(HANDLER_FUN_NAME(parserData, "entityDeclaration"), 
                           (const char*)NULL, parserData, opArgs);
}


void 
RS_XML(startElement)(void *userData, const char *name, const char **atts)
{
  USER_OBJECT_ opArgs;
  int i;
  RS_XMLParserData *rinfo = (RS_XMLParserData*) userData;
  DECL_ENCODING_FROM_EVENT_PARSER(rinfo)

  if((i = R_isBranch(CHAR_TO_XMLCHAR(name), rinfo)) != -1) {
      R_processBranch(rinfo, i, CHAR_TO_XMLCHAR(name), NULL, NULL, 0, NULL, 0, 0, (const xmlChar ** /*XXX*/) atts, 1);
      return;
  }

  PROTECT(opArgs = NEW_LIST(2));
  SET_VECTOR_ELT(opArgs, 0, NEW_CHARACTER(1));
  SET_STRING_ELT(VECTOR_ELT(opArgs, 0), 0, ENC_COPY_TO_USER_STRING(name)); 

  /* Now convert the attributes list. */
   SET_VECTOR_ELT(opArgs, 1, RS_XML(createAttributesList)(atts, encoding));
   RS_XML(callUserFunction)(HANDLER_FUN_NAME(rinfo, "startElement"), name, ((RS_XMLParserData*) userData), opArgs);
   UNPROTECT(1);
}

void 
RS_XML(commentHandler)(void *userData, const XML_Char *data)
{
  USER_OBJECT_ opArgs = NEW_LIST(1);
  RS_XMLParserData *rinfo = (RS_XMLParserData *) userData;
  DECL_ENCODING_FROM_EVENT_PARSER(rinfo)

  PROTECT(opArgs);
  SET_VECTOR_ELT(opArgs, 0, NEW_CHARACTER(1));
     SET_STRING_ELT(VECTOR_ELT(opArgs, 0), 0, ENC_COPY_TO_USER_STRING(data));
     RS_XML(callUserFunction)(HANDLER_FUN_NAME(rinfo, "comment"), 
			      (const char *)NULL, ((RS_XMLParserData*)userData), opArgs);
  UNPROTECT(1);
}


USER_OBJECT_
findEndElementFun(const char *name, RS_XMLParserData *rinfo)
{
    int i, n;
    USER_OBJECT_ names = GET_NAMES(rinfo->endElementHandlers);
    n = GET_LENGTH(rinfo->endElementHandlers);
    for(i = 0 ; i < n ; i++) {
	if(strcmp(CHAR_DEREF(STRING_ELT(names, i)), name) == 0)
	    return(VECTOR_ELT(rinfo->endElementHandlers, i));
    }
    return(NULL);
}


void RS_XML(endElement)(void *userData, const char *name)
{
 USER_OBJECT_ opArgs, fun;
 RS_XMLParserData *rinfo = (RS_XMLParserData *) userData;
 DECL_ENCODING_FROM_EVENT_PARSER(rinfo)


 if(rinfo->current) {
     /*  Dealing with a branch, so close up. */
     R_endBranch(rinfo, CHAR_TO_XMLCHAR(name), NULL, NULL);
     return;
 }

 ((RS_XMLParserData*)userData)->depth++; /* ??? should this be depth-- */

  PROTECT(opArgs = NEW_LIST(1));
  SET_VECTOR_ELT(opArgs, 0, NEW_CHARACTER(1));
     SET_STRING_ELT(VECTOR_ELT(opArgs, 0), 0, ENC_COPY_TO_USER_STRING(name));

  fun = findEndElementFun(name, rinfo);
  if(fun)  {
      USER_OBJECT_ val = RS_XML(invokeFunction)(fun, opArgs, rinfo->stateObject, rinfo->ctx);
      updateState(val, rinfo);
  }
  else
     RS_XML(callUserFunction)(HANDLER_FUN_NAME(rinfo, "endElement"), NULL, ((RS_XMLParserData*) userData), opArgs);

  UNPROTECT(1);
}




/**
 Called for inline expressions of the form
  <?target data-text>
 such as 
  <?R plot(1:10)>
*/
void 
RS_XML(processingInstructionHandler)(void *userData, const XML_Char *target, const XML_Char *data) 
{
 USER_OBJECT_ opArgs;
 RS_XMLParserData *parserData = (RS_XMLParserData *) userData;
  DECL_ENCODING_FROM_EVENT_PARSER(parserData)


 PROTECT(opArgs = NEW_LIST(2));
 SET_VECTOR_ELT(opArgs, 0, NEW_CHARACTER(1));
   SET_STRING_ELT(VECTOR_ELT(opArgs, 0), 0, ENC_COPY_TO_USER_STRING(target));
 SET_VECTOR_ELT(opArgs, 1, NEW_CHARACTER(1));
   SET_STRING_ELT(VECTOR_ELT(opArgs, 1), 0, ENC_COPY_TO_USER_STRING(data));
   RS_XML(callUserFunction)(HANDLER_FUN_NAME(parserData, "processingInstruction"), 
                             (const char *)NULL, (RS_XMLParserData*)userData, opArgs);
 UNPROTECT(1);
}

void 
RS_XML(startCdataSectionHandler)(void *userData) 
{
}

void 
RS_XML(endCdataSectionHandler)(void *userData) 
{
}



char *
fixedTrim(char *str,  int len, int *start, int *end)
{
  char *tmp;
  *end  = len;
  *start = 0;

    /* If a degenerate string, just return. */
  if(len == 0 || str == (char*)NULL || str[0] == '\0')
    return(str);

   /* Jump to the end */
  tmp = str + len - 2;
  while(tmp >= str && isspace(*tmp)) {
      tmp--;
      (*end)--;
  }
  if(tmp == str) {
   return(str);
  }

  tmp = str;

  while(*start <= *end && *tmp && isspace(*tmp)) {
    tmp++;
    (*start)++;
  }

    return(tmp);
}


void 
RS_XML(textHandler)(void *userData,  const XML_Char *s, int len)
{
 char *tmpString, *tmp;
 USER_OBJECT_ opArgs = NULL;
 RS_XMLParserData *parserData = (RS_XMLParserData*)userData; 
 DECL_ENCODING_FROM_EVENT_PARSER(parserData)

   /* XXX Here is where we have to ignoreBlankLines and use the trim setting in parserData */
  if(parserData->current) {
      xmlChar *tmp;
      int newLen = len, start = 0, end = len;
#if 1
      if(parserData->trim) {
          tmpString =  fixedTrim(XMLCHAR_TO_CHAR(s), len, &start, &end);
	  newLen = end - start; 
      } else 
          tmpString = XMLCHAR_TO_CHAR(s);

      if(newLen < 0 && parserData->ignoreBlankLines)
	    return;
#else
      tmpString = s;
#endif
      if(newLen < 0)
	tmp = strdup("");
      else {
         tmp = (xmlChar *) S_alloc(newLen + 2, sizeof(xmlChar));
         memcpy(tmp, tmpString, newLen); tmp[newLen] = '\0';
      }
      xmlAddChild(parserData->current, xmlNewText(tmp));
//XXX???
      if(newLen < 0) free(tmp);
      return;
  }
  /* Last case handles ignoring the new line between the two nodes if trim is TRUE.
     <abc/>
     <next>
     */
 if(s == (XML_Char*)NULL || s[0] == (XML_Char)NULL || len == 0 
       || (len == 1 && ((const char *) s)[0] == '\n' && parserData->trim))
    return;

           /*XXX Deal with encoding, memory cleanup, 
             1 more than length so we can put a \0 on the end. */
    tmp = tmpString = (char*)calloc(len+1, sizeof(char));
    strncpy(tmpString, s, len);
 
    if(parserData->trim) {
      tmpString = trim(tmpString);
      len = strlen(tmpString);
    }

  if(len > 0 || parserData->ignoreBlankLines == 0 ) {
    PROTECT(opArgs = NEW_LIST(1));
     SET_VECTOR_ELT(opArgs, 0, NEW_CHARACTER(1));
     SET_STRING_ELT(VECTOR_ELT(opArgs, 0), 0, ENC_COPY_TO_USER_STRING(tmpString));
  }

  free(tmp);

    /* If we are ignoring blanks and the potentially newly computed length is non-zero, then
       call the user function.
     */

  if(opArgs != NULL) {
      RS_XML(callUserFunction)(HANDLER_FUN_NAME(parserData, "text"), (const char *)NULL, ((RS_XMLParserData*) userData), opArgs);
     UNPROTECT(1);
  }
}


int
RS_XML(notStandAloneHandler)(void *userData)
{
  /*  printf("In NotStandalone handler\n"); */
 return(1);
}


/**
  Create the parser data which contains the 
  the collection of functions to call for each 
  event type.

  This allocates the parser memory using calloc.
  The caller should arrange to free it.
*/
RS_XMLParserData *
RS_XML(createParserData)(USER_OBJECT_ handlers, USER_OBJECT_ finalize) 
{
 RS_XMLParserData *parser = (RS_XMLParserData *) R_alloc(1, sizeof(RS_XMLParserData));

 memset(parser, '\0', sizeof(RS_XMLParserData));
 parser->methods = handlers;
 parser->finalize = finalize;

return(parser);
}

/**
  Routine that locates and invokes the R function in the collection of handlers.

   opName is the  identifier for the generic operation, i.e. startElement, text, etc.
   perferredName is the identifier for the node.
   
*/
USER_OBJECT_
RS_XML(callUserFunction)(const char *opName, const char *preferredName, RS_XMLParserData *parserData, USER_OBJECT_ opArgs) 
{
  USER_OBJECT_ fun = NULL, val;
  USER_OBJECT_ _userObject = parserData->methods;
  int general = 0;

  R_CHECK_INTERRUPTS

  if(preferredName && parserData->callByTagName) {
    fun = RS_XML(findFunction)(preferredName, _userObject);
  }

  if(fun == NULL) {
    general = 1;
    fun = RS_XML(findFunction)(opName, _userObject);
  }

  if(fun == NULL || isFunction(fun) == 0 ) {  
/* || (general && R_isInstanceOf(fun, "AsIs"))) Should we do this? */
      /* FAILED */
   return(NULL_USER_OBJECT);
  }

  val = RS_XML(invokeFunction)(fun, opArgs, parserData->stateObject, parserData->ctx);
  updateState(val, parserData);
  return(val); 
}

void
updateState(USER_OBJECT_ val, RS_XMLParserData *parserData)
{
    if(!parserData->stateObject || parserData->stateObject == NULL_USER_OBJECT) {
       return;
    }

#ifdef _R_
    R_ReleaseObject(parserData->stateObject);
    R_PreserveObject(val);
#else
    decr_ref_count(parserData->stateObject, TRUE, Local_data, S_evaluator);
    incr_ref_count(val, TRUE, Local_data, S_evaluator);
#endif
    parserData->stateObject = val;
}
