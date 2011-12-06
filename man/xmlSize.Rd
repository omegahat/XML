\name{xmlSize}
\alias{xmlSize}
\alias{xmlSize.default}
\alias{xmlSize.XMLDocument}
\alias{xmlSize.XMLNode}
\title{The number of sub-elements within an XML node.}
\description{
  XML elements can contain other, nested sub-elements.
 This generic function determines the number of
such elements within a specified node.
It applies to an object of class XMLNode or XMLDocument.
}
\usage{
xmlSize(obj)
}
\arguments{
  \item{obj}{ An an object of class XMLNode
or XMLDocument.}
}
\value{
 an integer which is the \code{\link{length}}
 of the value from \code{\link{xmlChildren}}.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
\code{\link{xmlChildren}},
\code{\link{xmlAttrs}},
\code{\link{xmlName}},
\code{\link{xmlTreeParse}}
}

\examples{
  fileName <- system.file("exampleData", "mtcars.xml", package="XML") 
  doc <- xmlTreeParse(fileName)
  xmlSize(doc)
  xmlSize(doc$doc$children[["dataset"]][["variables"]])
}
\keyword{file}

