\name{dtdIsAttribute}
\alias{dtdIsAttribute}
\title{Query if a name is a valid attribute of a DTD element.}
\description{
  Examines the definition of the DTD element definition identified
by \code{element} to see if it supports an attribute named
\code{name}.
}
\usage{
dtdIsAttribute(name, element, dtd)
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{name}{The name of the attribute being queried}
  \item{element}{The name of the element whose definition is to be used
to obtain the list of valid attributes.}
  \item{dtd}{The DTD containing the definition of the elements,
specifically \code{element}.}
}

\value{
 A logical value indicating if the
list of attributes suppported by the 
specified element has an entry named
\code{name}.
This does indicate what type of value
that attribute has, whether it is required, implied,
fixed, etc.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
\code{\link{parseDTD}},
\code{\link{dtdElement}},
\code{\link{xmlAttrs}}
}

\examples{
 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)

    # true
  dtdIsAttribute("numRecords", "dataset", foo.dtd)

    # false
  dtdIsAttribute("date", "dataset", foo.dtd)
}
\keyword{file}
