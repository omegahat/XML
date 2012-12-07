# An input file for autoconf to configure 
# the XML parsing facilities for both R and S.
# Currently this works for R.
#
# This was originally implemented by Friedrich Leisch
# with modifications for subsequent versions 
# by Duncan Temple Lang.
#

AC_INIT(DESCRIPTION)


dnl The different command line arguments for configure.
dnl They can also be specified by setting environment variables.


dnl
dnl Establish the command line arguments accepted by this script.
dnl
dnl

 dnl whether to use Splus.
AC_ARG_WITH(splus,[  --with-splus	Compile as an SPlus library (rather than R). Value can be the (fully qualified) name of the Splus script.], USE_SPLUS=1)

 dnl explicitly force the use of the old names. If this doesn't match the header
 dnl files that are actually found, then 
AC_ARG_WITH(oldlibxml,[], USE_OLD_ROOT_CHILD_NAMES=1; FORCE_OLD=1;echo "Using old libxml names")

 dnl tell the configuration that we are using libxml2.
AC_ARG_WITH(libxml2,[  --with-libxml2    indicate that the libxml version is 2.0 or higher],
               [ if test "${withval}" = "yes" ; then
                    LIBXML2="-DLIBXML2=1";
                    USE_XML2="yes" ;
                 fi], USE_XML2="yes")


AC_ARG_WITH(xml-config,[  --with-xml-config    the name of the xml-config program to use.],
               [ XML_CONFIG=${withval}])


  dnl compile for use with libxml. This is the default.
AC_ARG_WITH(libxml, [  --with-libxml           use the libxml library (default)],
  [ if test "${withval}" = no; then
      USE_LIBXML=false;
    else
      USE_LIBXML=true;
    fi],
  USE_LIBXML=true)

# Default is false for expat since we can 
# do event driven parsing with libxml.
AC_ARG_WITH(expat,
  [  --with-expat            use expat library (off by default)],
  [ if test "${withval}" = no; then
      USE_EXPAT= ;
    else
      USE_EXPAT=true;
    fi],
  USE_EXPAT= )

dnl Here we add a flag which we will use below in the case that 
dnl the user declaratively adds this option in. 
AC_ARG_WITH(xml_output_buffer,
	[  --with-xml-output-buffer	use ADD_XML_OUTPUT_BUFFER_CODE (conditionally on)],
	[ if test "${withval}" = "yes" ; then
	     ADD_XML_OUTPUT_BUFFER="yes";
	  else
	     ADD_XML_OUTPUT_BUFFER="no";
	  fi],
	  ADD_XML_OUTPUT_BUFFER=no)

dnl
dnl End of command line argument declarations.
dnl Now compute the relevant settings.
dnl


 dnl Get the C compiler, including any values set by the user
 dnl We need this to perform compilation and link checks.
AC_PROG_CC
AC_PROG_CPP



dnl ======================================================

dnl Check whether we are compiling this for use with SPlus
dnl and if so, figure out which version.
if test -n "${USE_SPLUS}" ; then
  # Allows the user to say --with-splus=/usr/local/bin/Splus5
  # This could be fooled, but unlikely unless the user does something
  # "clever"
 if test -x ${with_splus} ; then
   SPLUS=${with_splus}
 else
   SPLUS=Splus
 fi

   # Get the major version of the Splus being run.
   dnl Shouldn't this be perl -epn
 SPLUS_VERSION=`echo 'cat(version$major,"\n",sep="")' | ${SPLUS} | perl -e 'while(<STDIN>){ $x = $_;} printf $x;'`
  
   # If this is version 3, we are in trouble.
 if test ${SPLUS_VERSION} -lt 5 ; then
    echo "This package does not work with SPlus 3, but only SPlus 5 and 6" 
    exit 1
 fi
fi  # end of USE_SPLUS.



AC_ARG_WITH(xmlsec, [  --with-xmlsec           add support (experimental) for XML security with xmlsec. Specify no, xmlsec1 or xmlsec1-openssl],
  [ if test "${withval}" = no; then
      USE_XMLSEC=false
    else
      USE_XMLSEC=${withval}
    fi],
  USE_XMLSEC=true)


dnl


dnl Redirection: http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-3.html
if test -n "" ; then

  # turned off for now
  #XXX get the redirection correct
"$R_HOME/bin/R" CMD SHLIB testRemoveFinalizers.c &> AS_MESSAGE_FD
if test "$?" = 0 ;  then
 $R_HOME/bin/R --slave --vanilla < testRemoveFinalizers.R &> AS_MESSAGE_FD
fi

if ! test "$?" = 0 ; then
  echo "No ability to remove finalizers on externalptr objects in this verison of R";
  EXPORT_MEMORY_MANAGEMENT="FALSE"
else
 echo "Have R_RemoveExtPtrWeakRef" ; 
 PKG_CPPFLAGS="$PKG_CPPFLAGS -DR_HAS_REMOVE_FINALIZERS=1"; 
 EXPORT_MEMORY_MANAGEMENT="TRUE"
fi
else
  EXPORT_MEMORY_MANAGEMENT="FALSE"
fi

dnl ======================================================

AC_PATH_PROGS(SED, sed)

AC_PATH_PROGS(PKG_CONFIG, pkg-config)

dnl In this section, we try to find the different
dnl characteristics of the libxml library.

dnl We are looking to see if
dnl a) it is version 1.8.* or version 2.*
dnl b) whether it is installed with include files in <wherever>/gnome-xml
dnl    or in a private, uninstalled form in which case the include
dnl    directory is usually libxml/

if test -n "${USE_LIBXML}" ; then

   dnl If the user gave us xml*-config, then use that. 
  if test -n "${XML_CONFIG}" && test -x "${XML_CONFIG}" ; then
    USING_USER_XML_CONFIG="yes"

    XML_VERSION="`${XML_CONFIG} --version | ${SED} -e 's/\..*//g'`"
    if test "${XML_VERSION}" = "2" ; then
       USE_XML2="yes"
       LIBXML2="-DLIBXML2=1";
    fi
    echo "User defined xml-config: ${XML_CONFIG}, XML Version: ${XML_VERSION}, XML2: ${USE_XML2}"
  fi


  LANGUAGE_DEFS="${LANGUAGE_DEFS} -DHAVE_VALIDITY=1"

  dnl if the user has not specified anything about libxml,
  dnl then lets look for xml-config. We let the user give this
  dnl as an environment variable `XML_CONFIG'.

 if test -z "${LIBXML_INCDIR}" && test -z "${LIBXML_LIBDIR}" ; then

    dnl find xml*-config 

   dnl If they ask explicitly for xml2, find it or fail otherwise.
  if test  "${USE_XML2}" = "yes" ; then
     if test -z "${XML_CONFIG}" ; then 
       AC_PATH_PROGS(XML_CONFIG, xml2-config)      
       if test -z "${XML_CONFIG}" ; then
         echo "Cannot find xml2-config"
         exit 1
       fi
     fi
   fi

   dnl Otherwise, if they implicitly ask for xml-config
   dnl find that.
   if test -z "${XML_CONFIG}" ; then
       AC_PATH_PROGS(XML_CONFIG, xml-config)
   fi

   dnl and if they don't have libxml version 1, see if they
   dnl have libxml2 

  if test "${USE_XML2}" = "maybe" ; then
     if test -z "${XML_CONFIG}" ; then 
       AC_PATH_PROGS(XML_CONFIG, xml2-config)      
       if test -z "${XML_CONFIG}" ; then
         echo "Cannot find xml2-config"
         exit 1
       else
         echo "Using libxml version `$XML_CONFIG --version`"
       fi
     fi
   fi

   if test -n "${XML_CONFIG}" ; then

       echo "USE_XML2 = ${USE_XML2}"
       if test "${USE_XML2}" != "no" && test -z "${FORCE_XML2}"; then

dnl This is not needed now, but is a way to test whether we should use -E or -r to get 
dnl extended regular expression usage with this version of sed.
         echo "foo" | sed -Ee 's/foo/bar/'  > /dev/null 2>&1
	 if test "$?" = "0" ; then
           SED_EXTENDED_ARG="-E"
         else
           SED_EXTENDED_ARG="-r"
         fi

         echo  "SED_EXTENDED_ARG: ${SED_EXTENDED_ARG}"


         MINOR=`${XML_CONFIG} --version | ${SED} -e 's/^2\.\([[0-9]]\{1,\}\).*/\1/'`
         PATCH=`${XML_CONFIG} --version | ${SED} -e 's/^2\.[[0-9]]\{1,\}\.\([[0-9]]\{1,\}\)$/\1/'`

         echo "Minor $MINOR, Patch $PATCH for `$XML_CONFIG --version`"
         if test $MINOR -lt 6 ;  then
           echo ""
           echo "****    You should use a recent version of libxml2, i.e. 2.6.22 or higher  ****"
           echo ""
           exit 1
         fi

         if test "$MINOR" -eq 6 -a "$PATCH" -lt 3 ; then
            echo ""
            echo "**** There are problems compiling this package with libxml2-2.6.1 or libmxml2-2.6.2.  ****"
            echo "**** You will probably encounter compilation errors, so we are terminating the build.  ****"
            echo ""
            exit 1
         fi
        
       fi


       LIBXML_INCDIR=`${XML_CONFIG} --cflags`
       LIBXML_LIBDIR=`${XML_CONFIG} --libs`   
       FOUND_LIBXML_INCLUDES="Ok"
   fi
  fi  dnl USE_XML2 



    dnl If the user has specified LIBXML_INCDIR, then
    dnl we use that.
    dnl Otherwise, we try to find the parser.h file.

  if test -n "${LIBXML_INCDIR}" && test -z "${XML_CONFIG}" ; then
echo "Checking directory of LIBXML_INCDIR"
   if test -d $LIBXML_INCDIR ; then

        dnl Maybe also test for ${LIBXML_INCDIR}/parser.h 
        dnl in case somebody points us directly at the include directory.

      if test -r ${LIBXML_INCDIR}/libxml/parser.h ; then
        FOUND_LIBXML_INCLUDES="Ok"
      elif test -r ${LIBXML_INCDIR}/gnome-xml/parser.h ; then
        FOUND_LIBXML_INCLUDES="Ok"
        PKG_CPPFLAGS="${PKG_CPPFLAGS} -DFROM_GNOME_XML_DIR=1"
      else 
        echo "You specified LIBXML_INCDIR, but we couldn't find parser.h"
        echo "Please specify it correctly and re-run the INSTALL'ation."
        exit 1
      fi
   else
      echo "The LIBXML_INCDIR value you specified ($LIBXML_INCDIR) is not a directory."
      echo "Please specify it correctly and re-run the INSTALL'ation."
      exit 1
   fi
  fi


     dnl We should have exited if we cannot find parser.h
     dnl LIBXML_INCDIR.

  if test -z "${FOUND_LIBXML_INCLUDES}" ; then

     dnl the idea is that we loop over different directories
     dnl looking for parser.h. We look in the sub-directory 
     dnl gnome-xml/ 
    TMP_CPPFLAGS=${CPPFLAGS}
    for dir in ${LIBXML_INCDIR} /usr/local/include /usr/include ; do
 
       CPPFLAGS="${TMP_CPPFLAGS} -I${dir}"
       AC_CHECK_HEADER(libxml/parser.h, FROM_LIBXML_DIR=1)
       if test -n "${FROM_LIBXML_DIR}" ; then
         LIBXML_INCDIR="-I${dir}"
         CPPFLAGS="${TMP_CPPFLAGS} -I${dir} -I${dir}/libxml"
         PKG_CPPFLAGS="${TMP_CPPFLAGS} -I${dir} -I${dir}/libxml"
         echo "Found the libxml parser.h in $dir/libxml/"
         break
       fi      
     
       CPPFLAGS="${TMP_CPPFLAGS} -I${dir}/gnome-xml"

       AC_CHECK_HEADER(gnome-xml/parser.h, FROM_GNOME_XML_DIR=1)
       if test -n "${FROM_GNOME_XML_DIR}" ; then
         PKG_CPPFLAGS="${PKG_CPPFLAGS} -DFROM_GNOME_XML_DIR=1"
         CPPFLAGS="${CPPFLAGS} -DFROM_GNOME_XML_DIR=1"
         LIBXML_INCDIR="-I${dir}"
         echo "Found the gnome-xml parser in $dir"
         break
       fi
    done

   if test -z "${FROM_GNOME_XML_DIR}" ; then
    CPPFLAGS=${TMP_CPPFLAGS}
   fi

  fi    # end of -z FOUND_LIBXML_INCLUDES


  if test -z "${LIBXML_INCDIR}"; then
    AC_CHECK_HEADER(libxml/parser.h, LIBXML_INCDIR="libxml/")
  fi

  if test -z "${LIBXML_INCDIR}" ; then
   echo "Cannot find parser.h. Set the value of the environment variable"
   echo "    LIBXML_INCDIR"
   echo "to point to where it can be found."
   exit 1;
  else
   echo "Located parser file ${LIBXML_INCDIR}/parser.h"
  fi

dnl Do we need this? XXX
#LIBS="${LIBS} ${LIBXML_INCDIR}"

  if test -z "${LIBXML2}" ; then
CPPFLAGS="${PKG_CPPFLAGS} ${LIBXML_INCDIR}"
echo "Checking for 1.8: ${CPPFLAGS}"
  AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif],
[ xmlAttr *attr;
   attr->val = NULL;
], [echo "Using libxml 1.8.*!"],[LIBXML2="-DLIBXML2=1"; echo "Using libxml2.*" ])
  fi

#  AC_EGREP_HEADER(xmlParseFile, ${LIBXML_INCDIR}parser.h,
#	HAVE_LIBXML_HEADER=true,
#	AC_MSG_ERROR("header files for libxml seem to be incorrect"))


  AC_CHECK_LIB(z, gzopen)
  if test -n "${LIBXML2}" ; then
    AC_CHECK_LIB(xml2, xmlParseFile, LIBS="${LIBS} -lxml2"; USE_XMLLIB_NAME=xml2, NO_XML_LIB=1, "${LIBXML_LIBDIR--L.}")
  else
     NO_XML_LIB=1
  fi

  if test -n "${NO_XML_LIB}" ; then
    AC_CHECK_LIB(xml, xmlParseFile, LIBS="${LIBS} -lxml";USE_XMLLIB_NAME=xml, AC_MSG_ERROR("libxml not found"), "${LIBXML_LIBDIR--L.}")
  fi

  if test -n "${LIBXML_LIBDIR}" ; then
     LIBS="${LIBXML_LIBDIR--L.} ${LIBS}"
     LD_PATH="${LIBXML_LIBDIR-.}"
  fi

  PKG_CPPFLAGS="${PKG_CPPFLAGS} -DLIBXML"
  if test -z "${FROM_GNOME_XML_DIR}" ; then
   PKG_CPPFLAGS="${PKG_CPPFLAGS} ${LIBXML_INCDIR--I.}"
  fi


if test -z "${LIBXML2}" ; then
 dnl Now we try to test whether we have a really old libxml
 dnl which uses childs and root instead of xmlChildren and xmlRootNode

   if test -z "${USE_OLD_ROOT_CHILD_NAMES}" ; then
       CPPFLAGS=${PKG_CPPFLAGS}
       AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif],
       [ xmlDocPtr node;
         node->xmlRootNode = NULL;
       ], [echo "New style libxml!"],[USE_OLD_ROOT_CHILD_NAMES=1; echo "Need to use old-style libxml names"])

       echo "Using old root child names? ${USE_OLD_ROOT_CHILD_NAMES-0}" 
   fi  # USE_OLD_ROOT_CHILD_NAMES
else   # -z "${LIBXML2}"
   CPPFLAGS=${PKG_CPPFLAGS}
   if test -d "${LIBXML_LIBDIR}" ; then
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBXML_LIBDIR}
    export LD_LIBRARY_PATH
   fi
   AC_TRY_RUN([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif
int 
main(int argc, char *argv[])
{
  xmlCheckVersion(20000);
  return(0);
}
    ],[ LIBXML2_OK=1],[LIBXML2_OK=0])

    if test "${LIBXML2_OK}" = "0" ; then 
     echo "You are trying to use a version 2.* edition of libxml"
     echo "but an incompatible library. The header files and library seem to be"
     echo "mismatched. If you have specified LIBXML_INCDIR, make certain to also"
     echo "specify an appropriate LIBXML_LIBDIR if the libxml2 library is not in the default"
     echo "directories."
     exit 1
    fi
  fi

  if test -n "${USE_OLD_ROOT_CHILD_NAMES}" ; then
   PKG_CPPFLAGS="${PKG_CPPFLAGS} -DUSE_OLD_ROOT_CHILD_NAMES=1"
  fi
fi



if test "${USE_XMLLIB_NAME}" = "xml2" ; then
  AC_CHECK_LIB(xml2, xmlHashSize, echo "Using built-in xmlHashSize", PKG_CPPFLAGS="${PKG_CPPFLAGS} -DOWN_XML_HASH_SIZE=1")
fi

if test "${USE_LIBXML}" ; then
  
  echo "Checking DTD parsing (presence of externalSubset)..."

  AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif],
  [
    xmlParserCtxtPtr ctxt;
     ctxt->inSubset = 0;
     ctxt->sax->externalSubset = NULL;
  ], USE_EXT_SUBSET=1)

 if test -n "${USE_EXT_SUBSET}" ; then
   PKG_CPPFLAGS="${PKG_CPPFLAGS} -DUSE_EXTERNAL_SUBSET=1"
 fi



  AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif],
  [
     xmlNodePtr node;
     int x;
      x =  node->type == XML_DTD_NODE;

  ], ROOT_HAS_DTD_NODE=1, echo "No XML_DTD_NODE defined")

 if test -n "${ROOT_HAS_DTD_NODE}" ; then
   PKG_CPPFLAGS="${PKG_CPPFLAGS} -DROOT_HAS_DTD_NODE=1"
 fi

  AC_CHECK_LIB(${USE_XMLLIB_NAME},xmlHashSize, echo "Found xmlHashSize", echo "No xmlHashSize")



  AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif],
  [
    xmlEntityPtr ent;
    ent->checked = 1;
  ], ENTITY_HAS_CHECKED="yes", ENTITY_HAS_CHECKED="no")

 if test "${ENTITY_HAS_CHECKED}" = "no" ; then
   PKG_CPPFLAGS="${PKG_CPPFLAGS} -DNO_CHECKED_ENTITY_FIELD=1"
 fi



fi

dnl Here we added the check of the flag to determine if the user wants to force
dnl the XML_OUTPUT_BUFFER code in XMLTree.c
AC_CHECK_LIB(${USE_XMLLIB_NAME}, xmlOutputBufferCreateBuffer, [echo "have xmlOutputBufferCreateBuffer()"; if test "${ADD_XML_OUTPUT_BUFFER}" = "yes" ; then PKG_CPPFLAGS="${PKG_CPPFLAGS} -DADD_XML_OUTPUT_BUFFER_CODE=1"; else ADD_XML_OUTPUT_BUFFER=no ; fi; ], [ echo "Using local xmlOutputBufferCreateBuffer.  You might think about installing a newer version of libxml2, at least 2.6.23" ; PKG_CPPFLAGS="${PKG_CPPFLAGS} -DADD_XML_OUTPUT_BUFFER_CODE=1"; ADD_XML_OUTPUT_BUFFER=1])

AC_CHECK_LIB(${USE_XMLLIB_NAME}, xmlDocDumpFormatMemoryEnc, PKG_CPPFLAGS="${PKG_CPPFLAGS} -DDUMP_WITH_ENCODING=1")

if test -z "${FROM_GNOME_XML_DIR}" ; then
  AC_CHECK_HEADER(libxml/xmlversion.h, PKG_CPPFLAGS="${PKG_CPPFLAGS} -DUSE_XML_VERSION_H=1")
fi

AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/tree.h>
#else
#include <libxml/tree.h>
#endif],
[
 xmlElementPtr el;
 int x;
  x = el->etype;
], PKG_CPPFLAGS="${PKG_CPPFLAGS} -DXML_ELEMENT_ETYPE=1"
)

AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/tree.h>
#else
#include <libxml/tree.h>
#endif],
[
 xmlAttributePtr el;
 int x;
  x = el->atype;
], PKG_CPPFLAGS="${PKG_CPPFLAGS} -DXML_ATTRIBUTE_ATYPE=1"
)



if test -n "${USE_EXPAT}" ; then
  AC_CHECK_HEADER(xmltok/xmlparse.h, XMLPARSE_INCDIR="xmltok/")
  if test -z "${XMLPARSE_INCDIR}" ; then 
    AC_CHECK_HEADER(xmlparse/xmlparse.h, XMLPARSE_INCDIR="xmlparse/")
  fi
  AC_EGREP_HEADER(XML_Parse, ${XMLPARSE_INCDIR}xmlparse.h,
	HAVE_EXPAT_HEADER=true,
	AC_MSG_ERROR("header file xmlparse.h seems to be incorrect"))	
  AC_CHECK_LIB(xmltok, XmlInitEncoding,,AC_MSG_ERROR("libxmltok not found"))
  AC_CHECK_LIB(xmlparse, XML_Parse,,
		AC_MSG_ERROR("libxmlparse not found"), -lxmltok)
  PKG_CPPFLAGS="${PKG_CPPFLAGS} -DLIBEXPAT -I${XMLPARSE_INCDIR}"
  LD_PATH="${LD_PATH}:${LIBXML_LIBDIR}"
fi


if test -n "${USE_EXPAT}" ; then
  SUPPORTS_EXPAT="TRUE"
else
  SUPPORTS_EXPAT="FALSE"
fi

echo "Expat: ${USE_EXPAT} ${SUPPORTS_EXPAT}"

if test -n "${USE_LIBXML}" ; then
  SUPPORTS_LIBXML="TRUE"
else
  SUPPORTS_LIBXML="FALSE"
fi



if test -z "${USE_SPLUS}" ; then

  LANGUAGE_DEFS="-DUSE_R=1 -D_R_=1 ${LANGUAGE_DEFS}"
dnl   PKG_SYS_FILE='system.file("scripts", name, pkg="RSPerl")'

else 

  dnl Test to see if the patch has been made to renamin the attribute()
  dnl routine in libxml

 if test ${SUPPORTS_LIBXML}="TRUE" ; then

   AC_CHECK_LIB(xml, attribute, NEED_LIBXML_PATCH=1)
   if test -n "${NEED_LIBXML_PATCH}" ; then
    echo "The XML package will not work with S-Plus and the current libxml"
    echo "because of a conflict from both having a routine named attribute()"
    echo "We suggest that you modify the SAX.c file in the libxml and re-install."
    echo "See PATCH.attribute in this package's distribution."
    exit 1
   fi

 fi # ? SUPPORTS_LIBXML = "TRUE"

 LANGUAGE_DEFS="-D_S_=1 -DUSE_S=1 -D_S4_=1 -D_SPLUS${SPLUS_VERSION}_ -DNO_SPLUS_THREAD_DEF=1 ${LANGUAGE_DEFS}"
 INSTALL_DIR=`pwd`
 PKG_SYS_FILE="paste(\"${INSTALL_DIR}/inst/scripts/\", name,sep=\"\")"

fi   dnl end of if S-Plus.


AC_TRY_LINK(
[
#include "parser.h"
],
[
  extern int xmlSkipBlankChars(xmlParserCtxtPtr ctxt);
  xmlParserCtxtPtr p;
  xmlSkipBlankChars(p);
],
 echo "No need for old SKIP_BLANKS definition"
, BLANKS_DEF="-DOLD_SKIP_BLANKS=1"
)


if test -n "LIBXML2" ; then

TMP_CFLAGS="${CFLAGS}"
CFLAGS="${CFLAGS} -pedantic-errors"
echo "Checking for return type of xmlHashScan element routine."

AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/SAX.h>
#include <gnome-xml/hash.h>
#else
#include <libxml/SAX.h>
#include <libxml/hash.h>
#endif
],
[
  void *(*foo)(void *, void *, xmlChar*);
  xmlElementTablePtr table;
  xmlHashScan(table, foo, NULL);
], [echo "xmlHashScan wants a return value."],
  [echo "No return value for xmlHashScan"; PKG_CPPFLAGS="${PKG_CPPFLAGS} -DNO_XML_HASH_SCANNER_RETURN=1"]
)

CFLAGS="${TMP_CFLAGS}"


  AC_TRY_COMPILE([
  #include <libxml/tree.h>
  ],
  [
  xmlNsPtr ns;
   ns->context;
 ],
 [PKG_CPPFLAGS="$PKG_CPPFLAGS -DLIBXML_NAMESPACE_HAS_CONTEXT=1"; echo "xmlNs has a context field"], 
 [echo "No context field in xmlNs structure."])


fi


CPPFLAGS="$CPPFLAGS -I$R_HOME/include"
echo "Checking for cetype_t enumeration"
AC_TRY_COMPILE([
   #include <Rinternals.h>
],
[
   cetype_t t;
],
[PKG_CPPFLAGS="${PKG_CPPFLAGS} -DHAVE_R_CETYPE_T=1"; echo "Using recent version of R with cetype_t enumeration type for encoding"], 
[echo "No cetype_t enumeration defined in R headers."])

AC_SUBST(DUMP_WITH_ENCODING)

PKG_LIBS=${LIBS}


dnl ----------------------------------------------------
dnl Add -m to the linker flags (actually libraries)
dnl to supress errors about multiple definitions of 
dnl symbols.
dnl
dnl This is not needed anymore as we no longer define 
dnl xmlParserError in our code and override the one
dnl in libmxml. If we do find a situation (e.g. version
dnl of libxml that doesn't allow us to play with routine
dnl pointers to do this, we will need to define
dnl  NEED_XML_PARSER_ERROR
dnl
dnl AC_CANONICAL_HOST
dnl Doesn't work on my machine. Where do we find it - R?

if test -n "${NEED_XML_PARSER_ERROR}" ; then
 AC_PATH_PROG(UNAME, uname)
 if test -n "${UNAME}" ; then
   host_os=`${UNAME}`
   if test "${host_os}" = "Darwin" ; then
     PKG_LIBS="-m $PKG_LIBS"
   fi
 fi
fi


dnl  ---------------------------------------------------


AC_PATH_PROGS(XMLSEC_CONFIG, xmlsec1-config)

if test -n "$XMLSEC_CONFIG" ; then
  PKG_CPPFLAGS="$PKG_CPPFLAGS `$XMLSEC_CONFIG --cflags`"
  PKG_LIBS="$PKG_LIBS `$XMLSEC_CONFIG --libs`"
  XMLSEC_DEFS=-DHAVE_LIBXML_SEC=1
fi

AC_ARG_ENABLE(nodegc, [  --enable-nodegc  enable node garbage collection], 
               [ if test "${enableval}" = "yes" || test "${enableval}" = "default" ; then
                     LANGUAGE_DEFS="${LANGUAGE_DEFS} -DXML_REF_COUNT_NODES=1"
                 fi;
                 echo "enabling nodegc? ${enableval}"],
                 [echo "nodegc default $enableval"; LANGUAGE_DEFS="${LANGUAGE_DEFS} -DXML_REF_COUNT_NODES=1"])



AC_ARG_ENABLE(xml-debug, [  --enable-xml-debug  enable debugging information, primarily for memory management], 
               [ if test "${enableval}" = "yes" || test "${enableval}" = "default" ; then
                     LANGUAGE_DEFS="${LANGUAGE_DEFS} -DR_XML_DEBUG=1"
                 fi;
                 echo "enabling xml-debug? ${enableval}"],
                 [echo "xml-debug default $enableval"; LANGUAGE_DEFS="${LANGUAGE_DEFS}"])


dnl  ---------------------------------------------------

AC_DEFUN([CHECK_ENUM], [

AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif
],
[
  int val;
  val = $1;
],
[PKG_CPPFLAGS="$PKG_CPPFLAGS -DHAVE_$1=1"; echo "Version has $1"], 
[echo "No $1 enumeration value."])
])


CHECK_ENUM(XML_WITH_ZLIB)



AC_TRY_COMPILE([
#ifdef FROM_GNOME_XML_DIR
#include <gnome-xml/parser.h>
#else
#include <libxml/parser.h>
#endif
],
[
   xmlFeature f;
   xmlHasFeature(f);
],
[PKG_CPPFLAGS="$PKG_CPPFLAGS -DHAVE_XML_HAS_FEATURE=1"; echo "Version has xmlHasFeature()"], 
[echo "No xmlHasFeature."])




dnl   ---------------------------------------------


AC_SUBST(XMLSEC_DEFS)

AC_SUBST(LIBXML2)

AC_SUBST(LANGUAGE_DEFS)
AC_SUBST(LIBXML_INCDIR)
AC_SUBST(XMLPARSE_INCDIR)
AC_SUBST(PKG_LIBS)
AC_SUBST(PKG_CPPFLAGS)

AC_SUBST(SUPPORTS_LIBXML)
AC_SUBST(SUPPORTS_EXPAT)

AC_SUBST(LD_PATH)

AC_SUBST(EXPORT_MEMORY_MANAGEMENT)

if test -n "${USE_SPLUS}" ; then
  AC_SUBST(SPLUS)
  SPLUS_MAKEFILE=GNUmakefile.Splus
fi


echo ""
echo "****************************************"
echo "Configuration information:"
echo ""
echo "Libxml settings"
echo ""
echo "libxml include directory: ${LIBXML_INCDIR}"
echo "libxml library directory: ${LIBS}"
echo "libxml 2:                 ${LIBXML2-no}"
echo ""
echo "Compilation flags:        ${PKG_CPPFLAGS} ${LANGUAGE_DEFS} $XMLSEC_DEFS"
echo "Link flags:               ${PKG_LIBS}"


echo ""
echo "****************************************"

if test "$ADD_XML_OUTPUT_BUFFER" = "no" ; then
  ADD_XML_OUTPUT_BUFFER=0
fi
if test "$ADD_XML_OUTPUT_BUFFER" = "yes" ; then
  ADD_XML_OUTPUT_BUFFER=1
fi

AC_SUBST(ADD_XML_OUTPUT_BUFFER)


if test -n "${_R_CHECK_TIMINGS_}" ; then
  PKG_CPPFLAGS="$PKG_CPPFLAGS -DNO_XML_MEMORY_SHOW_ROUTINE=1"
fi


 dnl create the different targets
 dnl We had NAMESPACE here when were conditionally exporting the functions to 
 dnl remove finalizers on a node or document.  Need to add NAMESPACE.in in 
 dnl Install/GNUmakefile.admin
AC_OUTPUT(src/Makevars R/supports.R inst/scripts/RSXML.csh inst/scripts/RSXML.bsh ${SPLUS_MAKEFILE})
chmod +x cleanup


 dnl Set things up for an S-Plus chapter.
if test -n "${USE_SPLUS}" ; then
 mv GNUmakefile.Splus GNUmakefile

 echo "Creating S-Plus chapter"
 cd src 
 C_SRC_FILES="DocParse.c RSDTD.c Utils.c"
 ${SPLUS} CHAPTER ${C_SRC_FILES}
 echo "include Makevars" >> makefile
 echo 'CFLAGS:= $(PKG_CPPFLAGS) $(CFLAGS)' >> makefile
 echo 'LOCAL_LIBS=$(PKG_LIBS) ' >> makefile
 cd ..
fi


