\name{names.XMLNode}
\alias{names.XMLNode}
\title{Get the names of an XML nodes children.}
\description{
This is a convenient way to obtain the XML tag name
of each of the sub-nodes of a given 
\code{XMLNode} object.
}
\usage{
\method{names}{XMLNode}(x)
}
\arguments{
  \item{x}{the \code{XMLNode} whose sub-node tag names are being
  queried.}
}

\value{
 A character vector returning the
tag names of the sub-nodes of the given
\code{XMLNode} argument.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\note{ This overrides the regular names method
which would display the names of the internal
fields of an \code{XMLNode} object.
Since these are intended to be invisible and
queried via the accessor methods (\code{\link{xmlName}},
\code{\link{xmlAttrs}}, etc.), this should not
be a problem. If you really need the names
of the fields, use \code{names(unclass(x))}.
}

\seealso{
 \code{\link{xmlApply}}
 \code{\link{xmlSApply}}
}

\examples{
 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 names(xmlRoot(doc))

 r <- xmlRoot(doc)
 r[names(r) == "variables"]
}
\keyword{file}
