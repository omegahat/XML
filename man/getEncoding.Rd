\name{getEncoding}
%\Rdversion{1.1}
\alias{getEncoding}
\alias{getEncoding,XMLInternalDocument-method}
\alias{getEncoding,XMLInternalNode-method}
\alias{getEncoding,ANY-method}
\title{Determines the encoding for an XML document or node}
\description{
 This function and its methods are intended to return the
 encoding of n XML .
 It is similar to \code{\link[base]{Encoding}} but currently
 restricted to  XML nodes and documents.
}
\usage{
getEncoding(obj, ...)
}
\arguments{
  \item{obj}{the object whose encoding is being queried.}
  \item{\dots}{any additional parameters which can be customized by the methods.}
}

\value{
 A character vector of length 1 giving the encoding of the XML document.
}
\author{ Duncan Temple Lang}
\examples{
  f = system.file("exampleData", "charts.svg", package = "XML")
  doc = xmlParse(f)
  getEncoding(doc)
  n = getNodeSet(doc, "//g/text")[[1]]
  getEncoding(n)

  f = system.file("exampleData", "iTunes.plist", package = "XML")
  doc = xmlParse(f)
  getEncoding(doc)
}
\keyword{IO}

