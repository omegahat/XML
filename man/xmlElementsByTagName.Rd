\name{xmlElementsByTagName}
\alias{xmlElementsByTagName}
\title{Retrieve the children of an XML node with a specific tag name}
\description{
 This returns a list of the children or sub-elements of
an XML node whose tag name matches the one specified by
the user.
}
\usage{
xmlElementsByTagName(el, name, recursive = FALSE)
}
\arguments{
  \item{el}{the node whose matching children are to be retrieved.}
  \item{name}{a string giving the name of the tag to match in each of 
    \code{el}'s children.}
  \item{recursive}{a logical value. If this is \code{FALSE}, the
    default, only the direct child nodes are searched.
    Alternatively, if this is \code{TRUE},  all sub-nodes
    at all levels  are searched. In other words,
    we find all descendants of the node \code{el}
    and return a list with the nodes having the given name.
    The relationship between the nodes in the resulting list
    cannot be determined. This is a set of nodes. See the note. 
  }
}
\details{
 This does a simple matching of names and subsets the XML node's
 children list.
 If \code{recursive} is \code{TRUE}, then the function is applied
 recursively to the children of the given node and so on.
}
\note{
  The addition of the \code{recursive} argument makes this
  function behave like the \code{getElementsByTagName}
  in other language APIs such as Java, C\#.
  However, one should be careful to understand that
  in those languages, one would get back a set of
  node objects. These nodes have references to their
  parents and children. Therefore one can navigate the
  tree from each node, find its relations, etc.
  In the current version of this package (and for the forseeable
  future),  the node set is a \dQuote{copy} of the
  nodes in the original tree. And these have no facilities
  for finding their siblings or parent.
  Additionally, one can consume a large amount of memory by taking
  a copy of numerous large nodes using this facility.
  If one does not modify the nodes, the extra memory may be small. But
  modifying them means that the contents will be copied.

  Alternative implementations of the tree, e.g. using unique identifiers
  for nodes or via internal data structures from libxml can allow us to
  implement this function with different semantics, more similar to
  the other APIs.

}
\value{
 A list containing those child nodes of \code{el} whose
 tag name matches that specified by the user.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.omegahat.org/RSXML},
}
\author{Duncan Temple Lang}
\seealso{
\code{\link{xmlChildren}}
\code{\link{xmlTreeParse}}
}

\examples{
\dontrun{
 doc <- xmlTreeParse("http://www.omegahat.org/Scripts/Data/mtcars.xml")
 xmlElementsByTagName(doc$children[[1]], "variable")
}

 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 xmlElementsByTagName(xmlRoot(doc)[[1]], "variable")
}
\keyword{IO}
\keyword{file}
