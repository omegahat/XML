\name{xmlOutputBuffer}
\alias{xmlOutputBuffer}
\alias{xmlOutputDOM}
\title{XML output streams}
\description{

These two functions provide different ways to construct XML documents
incrementally.  They provide a single, common interface for adding and
closing tags, and inserting nodes.  The buffer version stores the XML
representation as a string.  The DOM version builds the tree of XML
node objects entirely within R.

}
\usage{
xmlOutputBuffer(dtd=NULL, nameSpace="", buf=NULL,
                             nsURI=NULL, header="<?xml version=\"1.0\"?>")

xmlOutputDOM(tag="doc", attrs = NULL, dtd=NULL,
                          nameSpace=NULL, nsURI=character(0),
                          xmlDeclaration = NULL)
}

\arguments{
  \item{dtd}{a DTD object (see \code{\link{parseDTD}} and
 \code{\link{xmlTreeParse}}) which contains specifications about
 what elements are valid within other elements and what attributes
 are supported by different elements. This can be used to validate the
 document as it is being constructed incrementally.}
  \item{attrs}{attributes for the top-level node, in the form of a named
    vector or list.}
  \item{nameSpace}{the default namespace identifier to be used when
an element is created without an explicit namespace.
This provides a convenient way to specify the default name space that appers in tags throughout the resulting document.}
 \item{buf}{a connection object or a string into which the XML content is written.
  This is currently a simplistic implementation since we will use the OOP-style classes
  from the Omegahat projects in the future.}
 \item{nsURI}{the URI or value for the name space which is used
  when declaring the namespace.
  For \code{xmlOuputDOM}, this is a named character vector with each
  element giving the name space identifier and the
  corresponding URI, \\
  e.g \code{c(shelp = "http://www.omegahat.org/XML/SHelp")}
}
 \item{header}{if non-NULL, this is immediately written to the output stream allowing
  one to control the initial section of the XML document.}
 \item{tag}{the name of the top-level node/element in the DOM being
  created.}
 \item{xmlDeclaration}{ a logical value or a string.
   If this is a logical value and \code{TRUE}, the default <?xml version='1.0'?>
    processing instruction is emitted at the top of the document.  
   If it is \code{FALSE}, no xml declaration is emitted at the top of
   the document.
    If this is provided as a string, the contents of this is added
    as the content of the processing instruction.   A version='1.0' is
    added if there is no  'version=' content within the given string.
  }
}
\details{

  These functions create a closure instance which provides methods or
functions that operate on shared data used to represent the contents
of the XML document being created and the current state of that
creation.

}
\value{
 Both of these functions return  a list
of functions which operate on the XML data in a shared environment.

  \item{value}{get the contents of the XML document as they are currently 
  defined.}
  \item{addTag}{add a new element to the document, specifying its name and attributes.
   This allows the tag to be left open so that new elements will be added as children
   of it.}
  \item{closeTag}{close the currently open tag, indicating that new elements will be added,
  by default,  as siblings of this one.}
  \item{reset}{discard the current contents of the document so that we can start over
  and free the resources (memory) associated with this document.}

The following are specific to \code{xmlOutputDOM}:
  \item{addNode}{insert an complete \code{XMLNode} object
      into the currently active (i.e. open)  node.}
  \item{current}{obtain the path or collection of indices to 
   to the currently active/open node from the root node.}
}
\references{\url{http://www.omegahat.org/RSXML},
\url{http://www.w3.org/xml}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{xmlTree}} for a native/internal (C-level) representation of the tree,
\code{\link{xmlNode}},
\code{\link{xmlTextNode}},
\code{\link{append.xmlNode}}

And a different representation of a tree is available
via \code{\link{xmlHashTree}}.
}

\examples{
 con <- xmlOutputDOM()
con$addTag("author", "Duncan Temple Lang")
con$addTag("address",  close=FALSE)
 con$addTag("office", "2C-259")
 con$addTag("street", "Mountain Avenue.")
 con$addTag("phone", close = FALSE)
   con$addTag("area", "908", attrs=c(state="NJ"))
   con$addTag("number", "582-3217")
 con$closeTag() # phone
con$closeTag() # address

con$addTag("section", close = FALSE)
 con$addNode(xmlTextNode("This is some text "))
 con$addTag("a","and a link", attrs=c(href="http://www.omegahat.org"))
 con$addNode(xmlTextNode("and some follow up text"))

 con$addTag("subsection", close = FALSE)
   con$addNode(xmlTextNode("some addtional text "))
   con$addTag("a", attrs=c(href="http://www.omegahat.org"), close=FALSE)
     con$addNode(xmlTextNode("the content of the link"))
   con$closeTag() # a
 con$closeTag() # "subsection"
con$closeTag() # section


 d <- xmlOutputDOM()
 d$addPI("S", "plot(1:10)")
 d$addCData('x <- list(1, a="&");\nx[[2]]')
 d$addComment("A comment")
 print(d$value())
 print(d$value(), indent = FALSE, tagSeparator = "")


 d = xmlOutputDOM("bob", xmlDeclaration = TRUE)
 print(d$value())

 d = xmlOutputDOM("bob", xmlDeclaration = "encoding='UTF-8'")
 print(d$value())


 d = xmlOutputBuffer("bob", header = "<?xml version='1.0' encoding='UTF-8'?>", 
                      dtd = "foo.dtd")
 d$addTag("bob")
 cat(d$value())
}
\keyword{file}
\keyword{IO}
