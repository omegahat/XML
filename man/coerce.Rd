\name{coerceNodes}
\alias{coerce,XMLHashTreeNode,XMLHashTree-method}
\alias{coerce,XMLInternalDocument,XMLHashTree-method}
\alias{coerce,XMLInternalNode,XMLHashTree-method}
\alias{coerce,XMLNode,XMLInternalNode-method}
\alias{coerce,XMLAbstractDocument,XMLAbstractNode-method}
\title{Transform between XML representations}
\description{
 This collection of coercion methods (i.e. \code{as(obj, "type")})
 allows users of the \code{XML} package to switch between different
 representations of XML nodes and to map from an XML document to
 the root node and from a node to the document. 
 This helps to manage the nodes 
}
%\usage{}
\value{
 An object of the target type.
}
\seealso{
\code{\link{xmlTreeParse}}
\code{\link{xmlParse}}
}
\keyword{IO}
\keyword{programming}
\concept{XML}


