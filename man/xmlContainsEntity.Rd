\name{xmlContainsEntity}
\alias{xmlContainsEntity}
\alias{xmlContainsElement}
\title{Checks if an entity is defined within a DTD.}
\description{
A DTD contains entity and element definitions.
These functions test whether a DTD contains a definition
for a particular named element or entity.
}
\usage{
xmlContainsEntity(name, dtd)
xmlContainsElement(name, dtd)
}
\arguments{
  \item{name}{ The name of the element
or entity being queried.}
  \item{dtd}{ The DTD in which to search for the entry.}
}
\details{
 See \code{\link{parseDTD}} for more information about
DTDs, entities and elements.
}
\value{
 A logical value indicating whether the entry
was found in the appropriate list of 
entitiy or element definitions.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }
\seealso{ \code{\link{parseDTD}},
\code{\link{dtdEntity}},
\code{\link{dtdElement}},
}

\examples{
 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)
 
  # Look for entities.
 xmlContainsEntity("foo", foo.dtd)
 xmlContainsEntity("bar", foo.dtd)

  # Now look for an element
 xmlContainsElement("record", foo.dtd)
}
\keyword{file}
