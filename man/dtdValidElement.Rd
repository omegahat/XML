\name{dtdValidElement}
\alias{dtdValidElement}
\title{Determines whether an XML tag is valid within another.}
\description{
  This tests whether \code{name} is a legitimate tag 
to use as a direct sub-element of the \code{within} tag
according to the definition of the \code{within}
element in the specified DTD.
}
\usage{
dtdValidElement(name, within, dtd, pos=NULL)
}
\arguments{
  \item{name}{The name of the tag which is to be inserted inside the
\code{within} tag.}
  \item{within}{The name of the parent tag the definition of which we are checking
to determine if it contains \code{name}.}
  \item{dtd}{The DTD in which the elements \code{name} and \code{within} are defined. }
  \item{pos}{ An optional position at which we might add the
\code{name} element inside \code{within}. If this is specified, we have a stricter
test that accounds for sequences in which elements must appear in order.
These are comma-separated entries in the element definition.}
}
\details{
This applies to direct sub-elements
or children of the \code{within} tag and not tags nested 
within children of that tag, i.e. descendants.
}
\value{
 Returns a logical value.
TRUE indicates that a \code{name} element
can be used inside a \code{within} element.
FALSE indicates that it cannot.
}


\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }


\seealso{
\code{\link{parseDTD}},
\code{\link{dtdElement}},
\code{\link{dtdElementValidEntry}},
}

\examples{
 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)

  # The following are true.
 dtdValidElement("variable","variables", dtd = foo.dtd)
 dtdValidElement("record","dataset", dtd = foo.dtd)

  # This is false.
 dtdValidElement("variable","dataset", dtd = foo.dtd)
}
\keyword{file}
