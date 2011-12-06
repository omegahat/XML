\name{xmlName}
\alias{xmlName}
\alias{xmlName<-}
\alias{xmlName.XMLComment}
\alias{xmlName.XMLNode}
\alias{xmlName.XMLInternalNode}
\title{ Extraces the tag name of an XMLNode object.}
\description{
  Each XMLNode object has an element or tag name introduced
in the \code{<name ...>} entry in an XML document.
This function returns that name.

We can also set that name using \code{xmlName(node) <- "name"}
and the value can have an XML name space prefix, e.g.
\code{"r:name"}.
}
\usage{
xmlName(node, full = FALSE)
}
\arguments{
  \item{node}{The XMLNode object whose tag name is being requested.}
  \item{full}{a logical value indicating whether to prepend the
    namespace prefix, if there is one, or return just the
    name of the XML element/node. \code{TRUE} means prepend the prefix.}
}

\value{
 A character vector of length 1
 which is the \code{node$name} entry.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }


\seealso{
\code{\link{xmlChildren}},
\code{\link{xmlAttrs}},
\code{\link{xmlTreeParse}}
}

\examples{
 fileName <- system.file("exampleData", "test.xml", package="XML") 
 doc <- xmlTreeParse(fileName)
 xmlName(xmlRoot(doc)[[1]])

 tt = xmlRoot(doc)[[1]]
 xmlName(tt)
 xmlName(tt) <- "bob"


  # We can set the node on an internal object also.
 n = newXMLNode("x")

 xmlName(n)
 xmlName(n) <- "y"

 
 xmlName(n) <- "r:y"

}
\keyword{file}
