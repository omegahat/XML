\name{asXMLTreeNode}
\alias{asXMLTreeNode}
\title{Convert a regular XML node to one for use in a "flat" tree}
\description{
 This coerces a regular R-based XML node (i.e. not an internal C-level
 node) to a form that can be inserted into a flat tree, i.e.
 one that stores the nodes in a non-hierarchical manner.
 It is thus used in conjunction with
 \code{\link{xmlHashTree}}
 and
 \code{\link{xmlFlatListTree}}.
 It adds \code{id} and \code{env} fields to the
 node and specializes the class by prefixing \code{className}
 to the class attribute.

 This is not used very much anymore as we use the internal nodes for
 most purposes.
}
\usage{
asXMLTreeNode(node, env, id = get(".nodeIdGenerator", env)(xmlName(node)), className = "XMLTreeNode")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{node}{the original XML node}
  \item{env}{the \code{XMLFlatTree} object into which this node will be inserted.}
  \item{id}{the identifier for the node in the flat tree. If this is not
    specified, we consult the tree itself and its built-in identifier
    generator.  By default, the name of the node is used as its
    identifier unless there is another node with that name.
  }
  \item{className}{a vector of class names to be prefixed to the
    existing class vector of the node.}

}
\value{
  An object of class \code{className}, i.e. by default
  \code{"XMLTreeNode"}.
}
\references{\url{http://www.w3.org/XML}}
\author{ Duncan Temple Lang }

\seealso{
  \code{\link{xmlHashTree}}
  \code{\link{xmlFlatListTree}}  
}
\examples{
  txt = '<foo a="123" b="an attribute"><bar>some text</bar>other text</foo>'
  doc = xmlTreeParse(txt)

  class(xmlRoot(doc))

  as(xmlRoot(doc), "XMLInternalNode")
}
\keyword{IO}
\concept{XML}
