\name{xmlApply}
\alias{xmlApply}
\alias{xmlApply.XMLNode}
\alias{xmlApply.XMLDocument}
\alias{xmlApply.XMLDocumentContent}
\alias{xmlSApply}
\alias{xmlSApply.XMLNode}
\alias{xmlSApply.XMLDocument}
\alias{xmlSApply.XMLDocumentContent}
\title{Applies a function to each of the children of an XMLNode}
\description{
 These methods are simple wrappers for the 
 \code{\link{lapply}} and \code{\link{sapply}} functions.
 They operate on the 
 sub-nodes of the XML node, and not on the fields of the node object itself.
}
\usage{
xmlApply(X, FUN, ...)
\method{xmlApply}{XMLNode}(X, FUN, ...)
\method{xmlApply}{XMLDocument}(X, FUN, ...)
\method{xmlApply}{XMLDocumentContent}(X, FUN, ...)
xmlSApply(X, FUN, ...)
\method{xmlSApply}{XMLNode}(X, FUN, ...)
\method{xmlSApply}{XMLDocument}(X, FUN, ...)
}

\arguments{
  \item{X}{the \code{XMLNode} on whose children the regular
   \code{\link{apply}} or \code{\link{sapply}} is to be performed}
  \item{FUN}{the function to apply to each child node. This is passed
   directly to the relevant \code{\link{apply}} function.}
  \item{\dots}{additional arguments to be given to each invocation of
    \code{FUN}. This is passed directly to the relevant \code{\link{apply}} function.}
}
\value{
 The result is that obtained from calling 
the \code{\link{apply}} or \code{\link{sapply}}
on \code{xmlChildren(x)}.
}

\references{
  \url{http://www.w3.org/XML},
  \url{http://www.jclark.com/xml},
  \url{http://www.omegahat.org}
}

\author{Duncan Temple Lang}


\seealso{
 \code{\link{xmlChildren}}
 \code{\link{xmlRoot}}
 \code{\link{[.XMLNode}}
 \code{\link{sapply}}
 \code{\link{lapply}}
}

\examples{
 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 r <- xmlRoot(doc)
 xmlSApply(r[[2]], xmlName)

 xmlApply(r[[2]], xmlAttrs)

 xmlSApply(r[[2]], xmlSize)

}
\keyword{file}

