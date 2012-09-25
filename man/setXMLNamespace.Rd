\name{setXMLNamespace}
\alias{setXMLNamespace}
\title{Set the name space on a node}
\description{
  This function sets the name space for an XML node, typically
  an internal node. We can use it to either define a new namespace
  and use that, or refer to a name space definition in an ancestor
  of the current node.
}
\usage{
setXMLNamespace(node, namespace, append = FALSE)
}
\arguments{
  \item{node}{the node on which the name space is to be set}
  \item{namespace}{the name space to use for the node. This can be a
    name space prefix (string) defined in an ancestor node, or a named
    character vector of the form \code{c(prefix = URI)} that defines a
    new namespace on this node, or we can use a name space object
    created with \code{\link{newXMLNamespace}}.}
  \item{append}{currently ignored.}
}
\value{
  An object of class \code{XMLNamespaceRef} which is a reference to the
  native/internal/C-level name space object.
}
%\references{}
\author{
Duncan Temple Lang
}

\seealso{
  \code{\link{newXMLNamespace}}

  \code{\link{removeXMLNamespaces}}
}
\examples{
  # define a new namespace
 e = newXMLNode("foo")
 setXMLNamespace(e, c("r" = "http://www.r-project.org"))

  # use an existing namespace on an ancestor node
 e = newXMLNode("top", namespaceDefinitions = c("r" = "http://www.r-project.org"))
 setXMLNamespace(e, "r")
 e

 
}
\keyword{programming}

