\name{asXMLNode}
\alias{asXMLNode}
\alias{coerce,XMLInternalNode,XMLNode-method}
\title{Converts non-XML node objects to XMLTextNode objects}
\description{
 This function is used to convert S objects that
are not already \code{XMLNode} objects
into objects of that class. Specifically,
it treats  the object as a string and creates
an \code{XMLTextNode} object.

 Also, there is a method for converting an XMLInternalNode
 - the C-level libxml representation of a node - to 
 an explicit R-only object which contains the R values
 of the data in the internal node.
}
\usage{
asXMLNode(x)
}
\arguments{
  \item{x}{the object to be converted to an \code{XMLNode} object.
   This is typically alread an object that inherits from \code{XMLNode}
   or a string.}
}
\value{
 An object of class XMLNode.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{ 
\code{\link{xmlNode}}
\code{\link{xmlTextNode}}
}

\examples{
   # creates an XMLTextNode.
 asXMLNode("a text node")

   # unaltered.
 asXMLNode(xmlNode("p"))
}
\keyword{file}
