\name{toString.XMLNode}
\alias{toString.XMLNode}
\title{Creates string representation of XML node}
\description{
  This creates a string from a hierarchical XML node and its children
  just as it prints on the console or one might see it in
  a document.
}
\usage{
\method{toString}{XMLNode}(x, ...)
}
\arguments{
  \item{x}{an object of class \code{XMLNode}.}
  \item{\dots}{currently ignored}
}
\details{
  This uses a textConnection object using the name
  .tempXMLOutput. Since this is global, it will overwrite
  any existing object of that name! As a result, this
  function cannot be used recursively in its present form.
}
\value{
  A character vector with one element, that being the
  string corresponding to the XML node's contents.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml}}
\author{Duncan Temple Lang}
\note{ This requires the Expat XML parser to be installed. }


\seealso{
  \code{\link{xmlNode}}
  \code{\link{xmlTreeParse}}
}

\examples{
 x <- xmlRoot(xmlTreeParse(system.file("exampleData", "gnumeric.xml", package = "XML")))

 toString(x)
}
\keyword{file}

