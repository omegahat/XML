\name{dtdElement}
\alias{dtdElement}
\alias{dtdEntity}
\title{Gets the definition of an element or entity from a DTD.}
\description{
 A DTD in R consists of both element and entity definitions.
 These two functions provide simple access to 
individual elements of these two lists, using the name
 of the element or entity.
 The DTD is provided to determine where to look for the
 entry.
} 
\usage{
dtdElement(name,dtd)
dtdEntity(name,dtd)
}
\arguments{
  \item{name}{The name of the element being retrieved/acessed.}
  \item{dtd}{The DTD from which the element is to be retrieved.}
}
\details{
 An element within a DTD  contains
both the list of sub-elements it can contain and a list of attributes
that can be used within this tag type.  
\code{dtdElement} retrieves the
element by name from the specified DTD definition.
Entities within a DTD are like macros or text substitutes used
within a DTD and/or XML documents that use it.
Each consists of a name/label and a definition, the text
that is substituted when the entity is referenced.
\code{dtdEntity} retrieves the entity definition
from the DTD.
\\
One can read a DTD
directly (using \code{\link{parseDTD}}) or implicitly when reading a
document (using \code{\link{xmlTreeParse}}) 
The names of all available elements can be obtained from the expression
 \code{names(dtd$elements)}.
 This function is simply a convenience for
indexing this \code{elements} list.
}
\value{
  An object of class \code{XMLElementDef}.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{ 
\code{\link{parseDTD}},
\code{\link{dtdValidElement}}
}

\examples{
 dtdFile <- system.file("exampleData","foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)
 
   # Get the definition of the `entry1' element
 tmp <- dtdElement("variable", foo.dtd)
 xmlAttrs(tmp)

 tmp <- dtdElement("entry1", foo.dtd)

  # Get the definition of the `img' entity
 dtdEntity("img", foo.dtd)
}
\keyword{file}
