/*
 * See Copyright for the license status of this software.
 */

#ifndef EVENT_PARSE_H
#define EVENT_PARSE_H

#include <ctype.h>
#include <stdlib.h> 

#include "RSCommon.h"
#include "RS_XML.h"

#ifdef LIBEXPAT
#include "xmlparse.h"
#else
typedef char XML_Char;
#endif

#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif


   /* Extensible Struct for carrying information about the parser and its 
      options as specified by the caller from R or S.
    */
typedef struct {
  /**
    The name of the source file which is being parsed.
   */
  char *fileName;

  /**
     Flag indicating whether blank (white-space only) text entries should be discarded
     and not reported.
   */
  int ignoreBlankLines;

  /**
     Flag indicating whether the methods in the user-level functions
     should be invoked with additional information about the current
     context of the parser, specifically the level or depth of the current node in the 
     tree, potentially the index sequence (i_child1, i_child2, i_child3,...) which 
     identifies the node relative to the root of the tree.

     Specify this in the call to xmlEventParse().
   */
  int addContextInfo;

  /* Flag indicating whether an attempt should be made when calling
     startElement to lookup a method matching the tag name rather than
     the vanilla startElement method.

     Set this in the call xmlEventParse().
   */
  int callByTagName;

   /* The R object in which to search for appropriate methods, usually a closure. */
  USER_OBJECT_ methods;

  USER_OBJECT_ endElementHandlers;

   /* 
      The current depth in the XML document tree. 
      Used when constructing
    */
  int depth;

  /*
     Flag indicating whether we should trim the 
   */
  int trim;


   /* S object used in event parsing to share state across calls. */
  USER_OBJECT_ stateObject;


    /* For identifying which element names are to be created into regular nodes. */
  USER_OBJECT_ branches;
  xmlNodePtr current;
  xmlNodePtr top;
  int        branchIndex;

    /* */
  int        useDotNames;


    /* The XML context */
  xmlParserCtxtPtr ctx;

    /* A function which is used to process a branch "anonymously, i.e
       not one that is actively identified in the branches = list(....)
       but a function that is returned from a regular startElement handler
       that indicates collect up the node and call this.
     */
  USER_OBJECT_ dynamicBranchFunction;


  USER_OBJECT_ finalize;

} RS_XMLParserData;

/* The name of the R element to call fo the general case.
   if useDotNames is on, then we paste a . to the regular name.
*/
#define HANDLER_FUN_NAME(ctx, txt) \
    ((RS_XMLParserData *)(ctx))->useDotNames ? "." txt : txt



void
R_processBranch(RS_XMLParserData * rinfo, 
                int branchIndex, 
                const xmlChar * localname, 
                const xmlChar * prefix, 
                const xmlChar * URI, 
                int nb_namespaces, 
                const xmlChar ** namespaces, 
                int nb_attributes, 
                int nb_defaulted, 
                const xmlChar ** attributes,
		Rboolean sax1);
int
R_isBranch(const xmlChar *localname, RS_XMLParserData *rinfo);
void
R_endBranch(RS_XMLParserData *rinfo,
            const xmlChar * localname, 
            const xmlChar * prefix, 
            const xmlChar * URI);

#if 0
typedef struct NodeList NodeList;
struct NodeList {
  xmlNodePtr *el;
  NodeList *next
};
#endif


/* Allocate a data structure for use with the parser */
RS_XMLParserData *createRSXMLParserData(USER_OBJECT_ handlers) ;

USER_OBJECT_ RS_XML(callUserFunction)(const char *opName, const char *preferredName, RS_XMLParserData *parser, USER_OBJECT_ opArgs) ;
/*Made static now: USER_OBJECT_ RS_XML(createAttributesList)(const char **atts); */


void RS_XML(entityDeclarationHandler)(void *userData, const XML_Char *entityName, 
                          const XML_Char *base, const XML_Char *systemId, 
                          const XML_Char *publicId, const XML_Char *notationName);


void RS_XML(entityDeclarationHandler)(void *userData, const XML_Char *entityName, 
                                      const XML_Char *base, const XML_Char *systemId, 
				     const XML_Char *publicId, const XML_Char *notationName);

void RS_XML(commentHandler)(void *userData, const XML_Char *data);

void RS_XML(endElement)(void *userData, const char *name);
void RS_XML(startElement)(void *userData, const char *name, const char **atts);
void RS_XML(processingInstructionHandler)(void *userData, const XML_Char *target, const XML_Char *data); 
void RS_XML(textHandler)(void *userData,  const XML_Char *s, int len);
void RS_XML(startCdataSectionHandler)(void *userData) ;
void RS_XML(endCdataSectionHandler)(void *userData) ;
RS_XMLParserData *RS_XML(createParserData)(USER_OBJECT_ handlers, USER_OBJECT_ finalize);


int RS_XML(parseBufferWithParserData)(char *buf, RS_XMLParserData *parserData);
int RS_XML(notStandAloneHandler)(void *userData);

int RS_XML(libXMLEventParse)(const char *fileName, RS_XMLParserData *parserData, RS_XML_ContentSourceType asText,
			      int saxVersion);


USER_OBJECT_ findEndElementFun(const char *name, RS_XMLParserData *rinfo);

void updateState(USER_OBJECT_ val, RS_XMLParserData *parserData);

#endif
