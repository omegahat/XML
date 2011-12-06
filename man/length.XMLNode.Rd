\name{length.XMLNode}
\alias{length.XMLNode}
\title{Determine the number of children in an XMLNode object.}
\description{
This function is a simple way to compute the number
of sub-nodes (or children) an \code{XMLNode} object
possesses.
It is provided as a convenient form of calling the
\code{\link{xmlSize}} function.
}
\usage{
\method{length}{XMLNode}(x)
}
\arguments{
\item{x}{the \code{XMLNode} object whose length is to be queried.}
}
\value{
 An integer giving the number of sub-nodes
 of this node.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }


\seealso{
\code{\link{xmlSize}}
\code{\link{xmlChildren}}
}

\examples{
  doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
  r <- xmlRoot(doc, skip=TRUE)
  length(r)
    # get the last entry
  r[[length(r)]]
}
\keyword{file}
