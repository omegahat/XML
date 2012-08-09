/*
 * See Copyright for the license status of this software.
 */

#ifndef RSDTD_H
#define RSDTD_H


#include "RSCommon.h"

#define RS_XML(a)  RS_XML_##a

#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/valid.h>
#include <gnome-xml/parser.h> 
#include <gnome-xml/parserInternals.h> 
#include <gnome-xml/tree.h>
#include <gnome-xml/entities.h>
#else
#if 0
/* Problems with xmlValidCtxt in libxml2-2.4.[n] where n >= 21*/
#include <libxml/valid.h>
#endif

#include <libxml/parser.h> 
#include <libxml/parserInternals.h> 
#include <libxml/tree.h>
#include <libxml/entities.h>
#endif


USER_OBJECT_ RS_XML(createDTDElement)(xmlElementPtr el);
USER_OBJECT_ RS_XML(createDTDElementContents)(xmlElementContentPtr vals, xmlElementPtr el, int recursive);
USER_OBJECT_ RS_XML(createDTDElementAttributes)(xmlAttributePtr vals, xmlElementPtr el);
USER_OBJECT_ RS_XML(createDTDAttribute)(xmlAttributePtr val, xmlElementPtr el);

USER_OBJECT_ RS_XML(AttributeEnumerationList)(xmlEnumerationPtr list, xmlAttributePtr attr, xmlElementPtr element);


USER_OBJECT_ RS_XML(SequenceContent)(xmlElementContentPtr vals, xmlElementPtr el);

USER_OBJECT_ RS_XML(ProcessElements)(xmlElementTablePtr table, xmlParserCtxtPtr ctxt);
USER_OBJECT_ RS_XML(ProcessEntities)(xmlEntitiesTablePtr table, xmlParserCtxtPtr ctxt);
USER_OBJECT_ RS_XML(createDTDEntity)(xmlEntityPtr entity);

USER_OBJECT_ RS_XML(createDTDParts)(xmlDtdPtr dtd, xmlParserCtxtPtr ctxt);

USER_OBJECT_ RS_XML(ConstructDTDList)(xmlDocPtr myDoc, int processInternals, xmlParserCtxtPtr ctxt);

#endif
