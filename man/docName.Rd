\name{docName}
\alias{docName}
\alias{docName,XMLDocument-method}
\alias{docName,XMLDocumentContent-method}
\alias{docName,XMLHashTree-method}
\alias{docName,XMLInternalDocument-method}
\alias{docName,XMLInternalNode-method}
\alias{docName,XMLHashTreeNode-method}
\alias{docName,NULL-method}
\alias{docName,XMLNode-method}
\alias{docName<-}
\alias{docName<-,XMLInternalDocument-method}
\alias{docName<-,XMLHashTree-method}
\title{Accessors for name of XML document}
\description{
  These functions and methods allow us to query and set the 
  \dQuote{name} of an XML document. This is intended to be
  its URL or file name or a description of its origin if
  raw XML content provided as a string.
}
\usage{
docName(doc, ...)
}
\arguments{
  \item{doc}{the XML document object, of class
     \code{XMLInternalDocument} or \code{XMLDocument}.
  }
  \item{\dots}{additional methods for methods}
}
\value{
  A character string giving the name.
  If the document was created from text, this is \code{NA}
  (of class character).


  The assignment function returns the updated object,
  but the R assignment operation will return the value
  on the right of the assignment!
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{xmlTreeParse}}
 \code{\link{xmlInternalTreeParse}}
 \code{\link{newXMLDoc}}

}
\examples{
  f = system.file("exampleData", "catalog.xml",  package = "XML")
  doc = xmlInternalTreeParse(f)
  docName(doc)

  doc = xmlInternalTreeParse("<a><b/></a>", asText = TRUE)
      # an NA
  docName(doc)
  docName(doc) = "Simple XML example"
  docName(doc)
}
\keyword{IO}
\keyword{programming}
\concept{XML}
