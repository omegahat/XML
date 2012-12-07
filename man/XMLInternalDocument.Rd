\name{XMLInternalDocument-class}
\docType{class}
\alias{XMLAbstractDocument-class} %XXX put somewhere else.
\alias{XMLInternalDocument-class}
\alias{HTMLInternalDocument-class}
\alias{coerce,XMLInternalNode,XMLInternalDocument-method}
\alias{coerce,XMLInternalDocument,XMLInternalNode-method}
\alias{coerce,XMLDocument,XMLInternalDocument-method}

\title{Class to represent reference to C-level data structure for an XML
  document}
\description{
  This class is used to provide a handle/reference to a C-level
  data structure that contains the information from parsing 
  parsing XML content.
  This leaves the nodes in the DOM or tree as C-level nodes
  rather than converting them to explicit R \code{XMLNode}
  objects.  One can then operate on this tree in much the same
  way as one can the \code{XMLNode} representations,
  but we a) avoid copying the nodes to R, and b) can navigate
  the tree both down and up using \code{\link{xmlParent}}
  giving greater flexibility.
  Most importantly, one can use an \code{XMLInternalDocument}
  class object with an XPath expression to easily and relatively efficiently
  find nodes within a document that satisfy some criterion.
  See \code{\link{getNodeSet}}.
}
\section{Objects from the Class}{
  Objects of this type are created via
  \code{\link{xmlTreeParse}}
  and   \code{\link{htmlTreeParse}}
  with the argument  \code{useInternalNodes} given as \code{TRUE}.
}
\section{Extends}{
Class \code{\linkS4class{oldClass}}, directly.
}
\section{Methods}{
  There are methods to serialize (dump) a document to a file or as a
  string, and to coerce it to a node by finding the top-level node of
  the document.
  There are functions to search the document for nodes specified by
  an XPath expression.
}
\references{
 XPath  \url{http://www.w3.org/TR/xpath}
}
\seealso{

  \code{\link{xmlTreeParse}}
  \code{\link{htmlTreeParse}}
  \code{\link{getNodeSet}}  
}
\examples{

 f = system.file("exampleData", "mtcars.xml", package="XML")
 doc = xmlParse(f)
 getNodeSet(doc, "//variables[@count]")
 getNodeSet(doc, "//record")

 getNodeSet(doc, "//record[@id='Mazda RX4']")

 # free(doc)
}
\keyword{classes}
