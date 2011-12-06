\name{[<-.XMLNode}
\alias{[<-.XMLNode}
\alias{[[<-.XMLNode}
\title{Assign sub-nodes to an XML node}
\description{
 These functions allow one to assign a sub-node
to an existing XML node by name or index.
 These are the assignment equivalents of the 
subsetting accessor functions.
They are typically called indirectly
via the assignment operator, such as 
\code{x[["myTag"]] <- xmlNode("mySubTag")}.
}
\usage{
\method{[}{XMLNode}(x, i) <- value
\method{[}{XMLNode}(x, i) <-  value
\method{[[}{XMLNode}(x, i) <- value
}
\arguments{
  \item{x}{the \code{XMLNode} object to which the sub-node is to be assigned.}
  \item{i}{the identifier for the position  in the list of children
  of \code{x} into which the right-hand-side node(s) should be assigned.
  These can be either numbers or names.}
  \item{value}{one or more \code{XMLNode} objects which are to be the sub-nodes
 of \code{x}.}
}
\value{
 The XML node \code{x} containing the new or modified
nodes.
}
\references{\url{http://www.w3.org}, \url{http://www.omegahat.org/RSXML}}
\author{Duncan Templle Lang}


\seealso{
\code{\link{[.XMLNode}}
\code{\link{[[.XMLNode}}
\code{\link{append.xmlNode}}
\code{\link{xmlSize}}
}

\examples{
 top <- xmlNode("top", xmlNode("next","Some text"))
 top[["second"]] <- xmlCDataNode("x <- 1:10")
 top[[3]] <- xmlNode("tag",attrs=c(id="name"))
}
\keyword{IO}
\keyword{file}
