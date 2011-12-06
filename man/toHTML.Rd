\name{toHTML}
\alias{toHTML}
\alias{toHTML,vector-method}
\alias{toHTML,matrix-method}
\alias{toHTML,call-method}

\title{Create an HTML representation of the given R object, using
  internal C-level nodes}
\description{
  This generic function and the associated methods are
  intended to create an HTML tree that represents the
  R object in some intelligent manner.
  For example, we represent a vector as a table
  and we represent a matrix also as a table.
  
}
\usage{
toHTML(x, context = NULL)
}
\arguments{
  \item{x}{ the R object which is to be represented via an HTML tree }
  \item{context}{an object which provides context in which the node will
    be used. This is currently arbitrary. It may be used, for example,
    when creating HTML for R documentation and providing information
    about variabes and functions that are available on that page
    and so have internal links.
  }
}
\details{
  It would be nicer if we could pass additional arguments
  to control whether the outer/parent layer is created,
  e.g. when reusing code for a vector for a row of a matrix.
}
\value{
 an object of class \code{XMLInternalNode}
}
%\references{  }
\author{Duncan Temple Lang}

\seealso{
 The \code{R2HTML} package.
}
\examples{
 cat(as(toHTML(rnorm(10)), "character"))
}
\keyword{IO}
\keyword{programming}
\concept{XML}
\concept{serialization}
\concept{data exchange}

