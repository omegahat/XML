/*
 * See Copyright for the license status of this software.
 */

#ifndef RS_XML_H
#define RS_XML_H

#define RS_XML(a) RS_XML_##a

/* #define R_XML_DEBUG 1    */

#if 0
#if 1
#define XML_REF_COUNT_NODES 1   
#else

#ifdef XML_REF_COUNT_NODES
#undef XML_REF_COUNT_NODES
#endif

#endif
#endif

/* #undef XML_REF_COUNT_NODES */


typedef enum {RS_XML_FILENAME, RS_XML_TEXT, RS_XML_CONNECTION, RS_XML_INVALID_CONTENT} RS_XML_ContentSourceType;

#ifdef _R_

#include "R.h"
#include "Rinternals.h"

#if 0
#if R_VERSION < R_Version(1, 2, 0)
#define STRING_ELT(x,i)   STRING(x)[i]
#define VECTOR_ELT(x,i)   VECTOR(x)[i]
#define SET_STRING_ELT(x,i,v)     (STRING(x)[i]=(v))
#define SET_VECTOR_ELT(x,i,v)     (VECTOR(x)[i]=(v))
#endif
#endif /* end of ignoring version details */

#endif /* end of _R_ */


#endif
