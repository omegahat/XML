\name{newXMLNamespace}
\alias{newXMLNamespace}
\title{Add a namespace definition to an XML node}
\description{
 This function, and associated methods,
 define a name space \code{prefix = URI} combination for the
 given XML node.
 It can also optionally make this name space the
 default namespace for the node.
}
\usage{
newXMLNamespace(node, namespace, prefix = names(namespace), set = FALSE)
}
\arguments{
  \item{node}{the XML node for which the name space is to be defined.}
  \item{namespace}{the namespace(s).
     This can be a simple character vector giving the URI,
     a named character vector giving the prefix = URI pairs, with the prefixes being the names 
     of the character vector,
     or one or more (a list) of \code{XMLNamespace} objects, e.g. returned from a call to 
     \code{\link{xmlNamespaceDefinitions}}}
  \item{prefix}{ 
     the prefixes to be associated with the URIs given in \code{namespace}.
  }
  \item{set}{  a logical value indicating whether to 
    set the  namespace for this node to this newly created name space definition.
  }
}
\value{
 An name space definition object whose class corresponds 
 to the type of XML node given in \code{node}.
}
\note{
 Currently, this only applies to XMLInternalNodes. This will be rectified shortly
and apply to RXMLNode and its non-abstract classes.
}
\references{ ~put references to the literature/web site here ~ }
\author{Duncan Temple Lang}

\seealso{
 Constructors for different XML node types - \code{newXMLNode}
 \code{xmlNode}.
 \code{\link{newXMLNamespace}}.
}
\examples{
 foo = newXMLNode("foo")
 ns = newXMLNamespace(foo, "http://www.r-project.org", "r")
 as(ns, "character")
}
\keyword{IO}
\keyword{programming}
\concept{XML}

