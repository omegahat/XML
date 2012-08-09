/*
 * See Copyright for the license status of this software.
 */

#ifndef XMLPARSE_H
#define XMLPARSE_H

#include <ctype.h>
#include <stdlib.h> 

#include "RSCommon.h"

#include "RS_XML.h"

#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif


typedef struct {
    int skipBlankLines;
    int trim;
    int xinclude;
    USER_OBJECT_ converters;
    int addAttributeNamespaces;
    int internalNodeReferences;

    int fullNamespaceInfo;

    int useDotNames;

    SEXP finalize;
} R_XMLSettings;


enum {DOWN, SIDEWAYS};



USER_OBJECT_ RS_XML(convertXMLDoc)(const char *fileName, xmlDocPtr doc, USER_OBJECT_ converterFunctions, R_XMLSettings *settings);
/*USER_OBJECT_ RS_XML(createXMLNode)(xmlNodePtr node, int recursive, int direction, R_XMLSettings *settings, USER_OBJECT_ parentUserNode);*/
USER_OBJECT_ RS_XML(AttributeList)(xmlNodePtr node, R_XMLSettings *settings);
USER_OBJECT_ RS_XML(createNodeChildren)(xmlNodePtr node, int direction, R_XMLSettings *parserSettings);

USER_OBJECT_ RS_XML(lookupGenericNodeConverter)(xmlNodePtr node, USER_OBJECT_ methods, R_XMLSettings *parserSettings);


USER_OBJECT_ RS_XML(createNameSpaceIdentifier)(xmlNs *space, xmlNodePtr node);

USER_OBJECT_ RS_XML_xmlXIncludeProcessFlags(USER_OBJECT_ r_doc, USER_OBJECT_ r_flags);

USER_OBJECT_ processNamespaceDefinitions(xmlNs *ns, xmlNodePtr node, R_XMLSettings *parserSettings);



typedef struct _R_NodeGCInfo {

    struct _R_NodeGCInfo  *prev;
    struct _R_NodeGCInfo  *next;
    xmlNodePtr node;
    int count;

} R_NodeGCInfo;


void initDocRefCounter(xmlDocPtr doc);
#endif
