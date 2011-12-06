\name{xmlChildren}
\alias{xmlChildren}
\alias{xmlChildren<-}
\alias{xmlChildren.XMLNode}
\alias{xmlChildren.XMLInternalNode}
\alias{xmlChildren.XMLInternalDocument}
\alias{xmlChildren<-,XMLInternalNode-method}
\alias{xmlChildren<-,ANY-method}
\title{ Gets the sub-nodes within an XMLNode object. }
\description{
  These functions provide access to the children of the given
  XML node.
  The simple accessor returns a list of child XMLNode objects within an
  XMLNode object.

  The assignment operator (\code{xmlChildren<-}) sets the
  children of the node to the given value and returns the
  updated/modified node.  No checking is currently done
  on the type and values of the right hand side. This allows
  the children of the node to be arbitrary R objects.  This can
  be useful but means that one cannot rely on any structure in a node
  being present..
}
\usage{
xmlChildren(x, addNames= TRUE, ...)
}
\arguments{
  \item{x}{an object of class XMLNode.}
  \item{addNames}{a logical value indicating whether to add the XML
  names of the nodes as names of the R list.
  This is only relevant for XMLInternalNode objects as XMLNode objects
  in R already have R-level names.
}
  \item{\dots}{additional arguments for the particular methods,
                e.g. \code{omitTypes} for an XMLInternalNode.}
}
\value{
 A list whose elements are sub-nodes of the user-specified
XMLNode. These are also of class XMLNode.
}
\references{\url{http://www.w3.org/XML}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{xmlChildren}},\code{\link{xmlSize}},
\code{\link{xmlTreeParse}}
}


\examples{
  fileName <- system.file("exampleData", "mtcars.xml", package="XML")
  doc <- xmlTreeParse(fileName)
  names(xmlChildren(doc$doc$children[["dataset"]]))
}
\keyword{file}
