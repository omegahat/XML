\name{ensureNamespace}
\alias{ensureNamespace}
\title{Ensure that the node has a definition for particular XML namespaces}
\description{
  This function is a helper function for use in creating XML content.
  We often want to create a node that will be part of a larger XML tree
  and use a particular namespace for that node name. Rather than
  defining the namespace in each  new node, we want to ensure that
  it is define on an ancestor node.  This function aids in that task.
  We call the function with  the ancestor node or top-level document
  and have it check whether the namespace is already defined or have
  it add it to the node and return.

  This is intended for use with \code{XMLInternalNode} objects
  which are direclty mutable (rather than changing a copy of the node
  and having to insert that back into the larger tree.)
}
\usage{
ensureNamespace(doc, what)
}
\arguments{
  \item{doc}{an \code{XMLInternalDocument} or \code{XMLInternalNode} on
  which the namespace is to be defined.  If this is a documentm, we use
  the root node.}
  \item{what}{a named character vector giving the URIs for the namespace
  definitions and the names giving the desired prefixes}
}
\value{
  This is used for the potential side effects of modifying the
  XML node to add (some of) the namespaces as needed.
}
\references{XML namespaces}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{newXMLNamespace}}
  \code{\link{newXMLNode}}
}
\examples{
  doc = newXMLDoc()
  top = newXMLNode("article", doc = doc)
  ensureNamespace(top, c(r = "http://www.r-project.org"))
  b = newXMLNode("r:code", parent = top)
  print(doc)
}
\keyword{IO}
\concept{XML}

