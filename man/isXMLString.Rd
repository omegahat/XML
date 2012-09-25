\name{isXMLString}
\Rdversion{1.1}
\alias{isXMLString}
\alias{xml}
\alias{xmlParseString}
\alias{XMLString-class}
\title{Facilities for working with XML strings}
\description{
 These functions and classes are used to represent and parse a
 string whose content is known to be XML.
 \code{xml} allows us to mark a character vector as containing XML,
 i.e. of class \code{XMLString}.

 \code{xmlParseString} is a convenience routine for converting an
 XML string into an XML node/tree.

 \code{isXMLString} is examines a strings content and heuristically 
 determines whether it is XML.
}
\usage{
isXMLString(str)
xmlParseString(content, doc = NULL, namespaces = RXMLNamespaces,
                clean = TRUE, addFinalizer = NA) 
xml(x) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{str,x,content}{the string containing the XML material.}
  \item{doc}{if specified, an \code{XMLInternalDocument} object which is
   used to "house" the new nodes. Specifically, when the nodes are
   created, they are made as part of this document. This may not be as
   relevant now with the garbage collection being done at a node and
   document level. But it still potentially of some value.}
  \item{namespaces}{a character vector giving the URIs for the XML namespaces which are to be removed if \code{clean} is \code{TRUE}.}
  \item{clean}{a logical value that controls whether namespaces are removed after the document is parsed..}
  \item{addFinalizer}{a logical value or identifier for a C routine
        that controls whether we register finalizers on the intenal node.}   
}
%\details{}
\value{
  \code{isXMLString} returns a logical value.

  \code{xmlParseString} returns an object of class
  \code{XMLInternalElementNode}.

  \code{xml} returns an object of class \code{XMLString}
  identifying the  text as \code{XML}.
}
%\references{}
\author{Dncan Temple Lang}

\seealso{
\code{\link{xmlParse}}
\code{\link{xmlTreeParse}}
}
\examples{
 isXMLString("a regular string < 20 characters long")
 isXMLString("<a><b>c</b></a>")

 xmlParseString("<a><b>c</b></a>")

  # We can lie!
 isXMLString(xml("foo"))
}
\keyword{IO}
\concept{XML}
