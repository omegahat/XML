\name{xmlParent}
\alias{xmlParent}
\alias{xmlAncestors}
\alias{xmlParent.XMLInternalNode}
\alias{xmlParent,XMLInternalNode-method}
\alias{xmlParent,XMLHashTreeNode-method}
\alias{xmlParent,XMLTreeNode-method}
\title{Get parent node of XMLInternalNode or ancestor nodes}
\description{
 \code{xmlParent} operates on an XML node
 and returns a reference to its parent node 
 within the document tree.
 This works for an internal, C-level
 \code{XMLInternalNode} object
 created, for examply, using \code{\link{newXMLNode}}
 and related functions or \code{\link{xmlTree}}
 or  from \code{\link{xmlTreeParse}} with the
 \code{useInternalNodes} parameter.

 It is possible to find the parent of an R-level
 XML node when using a tree
 created with, for example,  \code{\link{xmlHashTree}}
 as the parent information is stored separately.

 \code{xmlAncestors} walks the chain of parens to the
 top of the document and either returns a list of those
 nodes, or alternatively a list of the values obtained
 by applying a function to each of the nodes.
 
}
\usage{
xmlParent(x, ...)
xmlAncestors(x, fun = NULL, ..., addFinalizer = NA, count = -1L)
}
\arguments{
  \item{x}{an object of class \code{XMLInternalNode} whose parent is being requested. }
  \item{fun}{an R function which is invoked for each  node as we walk up
    the tree.}
  \item{\dots}{any additional arguments that are passed in calls to
    \code{fun} after the node object and for \code{xmlParent} this allows methods to define their
    own additional parameters.}
\item{addFinalizer}{a logical value indicating whether the
  default finalizer routine should be registered to
  free the internal xmlDoc when R no longer has a reference to this
  external pointer object.
  This can also be the name of a C routine or a reference
  to a C routine retrieved using
  \code{\link[base]{getNativeSymbolInfo}}.
}
 \item{count}{an integer that indicates how many levels of the hierarchy
   to traverse. This allows us to get the \code{count} most recent
   ancestors of the node.}
}
\details{
 This uses the internal libxml structures to access the parent in the DOM tree. 
 This function is generic so that we can add methods for other types of nodes
 if we so want in the future.
}
\value{
  \code{xmlParent} returns object of class \code{XMLInternalNode}.

  If \code{fun} is \code{NULL}, \code{xmlAncestors} returns a list of the nodes in order of
  top-most node or root of the tree, then its child, then the child of
  that child, etc. This is the reverse order in which the nodes are
  visited/found.

  If \code{fun} is a function, \code{xmlAncestors} returns a list
  whose elements are the results of calling that function for
  each node. Again, the order is top down.
}

\references{\url{http://www.w3.org/XML}}
\author{ Duncan Temple Lang }

\seealso{
 \code{\link{xmlChildren}}
 \code{\link{xmlTreeParse}}
 \code{\link{xmlNode}}
}
\examples{

  top = newXMLNode("doc")
  s = newXMLNode("section", attr = c(title = "Introduction"))
  a = newXMLNode("article", s)
  addChildren(top, a)

  xmlName(xmlParent(s))
  xmlName(xmlParent(xmlParent(s)))


    # Find the root node.
  root = a
  while(!is.null(xmlParent(root)))
      root = xmlParent(root)

   # find the names of the parent nodes of each 'h' node.
   # use a global variable to "simplify" things and not use a closure.

  filename = system.file("exampleData", "branch.xml", package = "XML")
  parentNames <- character()
  xmlParse(filename,
                handlers =
                  list(h = function(x) {
                   parentNames <<- c(parentNames, xmlName(xmlParent(x)))
                  }))

  table(parentNames)
}
\keyword{file}
\keyword{IO}


