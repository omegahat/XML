\name{dtdElementValidEntry}
\alias{dtdElementValidEntry.character}
\alias{dtdElementValidEntry.XMLElementContent}
\alias{dtdElementValidEntry.XMLElementDef}
\alias{dtdElementValidEntry.XMLOrContent}
\alias{dtdElementValidEntry.XMLSequenceContent}
\alias{dtdElementValidEntry}
\title{Determines whether an XML element allows a particular type of sub-element.}
\description{
  This tests whether \code{name} is a legitimate tag to use as a
direct sub-element of the \code{element} tag according to the
definition of the \code{element} element in the specified DTD.  This
is a generic function that dispatches on the element type, so that
different version take effect for \code{XMLSequenceContent},
\code{XMLOrContent}, \code{XMLElementContent}.
}
\usage{
dtdElementValidEntry(element, name, pos=NULL)
}
\arguments{
  \item{element}{The \code{XMLElementDef} defining the tag
in which we are asking whether the sub-element can be used. }
  \item{name}{The name of the sub-element about which we are 
querying the list of sub-tags within \code{element}.
}
  \item{pos}{An optional argument which, if supplied,
queries whether the \code{name} sub-element is valid
as the \code{pos}-th child of \code{element}.
}
}
\details{
This is not intended to be called directly, but
indirectly by the 
\code{\link{dtdValidElement}} function.
}
\value{
 Logical value indicating whether the sub-element
can appear in an \code{element} tag or not.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }


\seealso{
\code{\link{parseDTD}},
\code{\link{dtdValidElement}},
\code{\link{dtdElement}}
}

\examples{
 dtdFile <- system.file("exampleData", "foo.dtd",package="XML")
 dtd <- parseDTD(dtdFile) 
 
  dtdElementValidEntry(dtdElement("variables",dtd), "variable")
}
\keyword{file}
