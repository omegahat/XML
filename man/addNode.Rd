\name{addNode}
\alias{addNode}
\alias{addNode.XMLHashTree}
\title{Add a node to a tree}
\description{

  This generic function allows us to add a node to a tree
  for different types of trees.
  Currently it just works for XMLHashTree, but it could
  be readily extended to the more general XMLFlatTree class.
  However, the concept in this function is to change the tree
  and return the node. This does not work unless the tree
  is directly mutable without requiring reassignment,
  i.e. the changes do not induce a new copy of the original tree object.
  DOM trees which are lists of lists of lists do not fall into this category.
  
  }
\usage{
addNode(node, parent, to, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{node}{the node to be added as a child of the parent.}
  \item{parent}{the parent node or identifier}
  \item{to}{the tree object}
  \item{\dots}{additional arguments that are understood by the different methods for the different types of 
   trees/nodes. These can include \code{attrs}, \code{namespace}, \code{namespaceDefinitions},
    \code{.children}.}
}
\value{
  The new node object.
  For flat trees, this will be the \code{node} after it has been
  coerced to be compatible with a flat tree, i.e. has an id and the
  host tree added to it.
}
\references{\url{http://www.w3.org} }
\author{Duncan Temple Lang}



\seealso{
  \code{\link{xmlHashTree}}
  \code{\link{asXMLTreeNode}}  
}
\examples{

  tt = xmlHashTree()

  top = addNode(xmlNode("top"), character(), tt)
  addNode(xmlNode("a"), top, tt)
  b = addNode(xmlNode("b"), top, tt)
  c = addNode(xmlNode("c"), b, tt)
  addNode(xmlNode("c"), top, tt)
  addNode(xmlNode("c"), b, tt)    
  addNode(xmlTextNode("Some text"), c, tt)

  xmlElementsByTagName(tt$top, "c")

  tt
}
\keyword{IO}
\concept{tree}


