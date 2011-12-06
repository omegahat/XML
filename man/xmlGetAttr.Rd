\name{xmlGetAttr}
\alias{xmlGetAttr}
\title{Get the value of an attribute in an XML node}
\description{
  This is a convenience function that retrieves
  the value of a named attribute in an XML node,
  taking care of checking for its existence.
  It also allows the caller to provide a default
  value to use as the return value if the
  attribute is not present.
}
\usage{
xmlGetAttr(node, name, default = NULL, converter = NULL,
            namespaceDefinition = character(),
             addNamespace = length(grep(":", name)) > 0)
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{node}{the XML node}
  \item{name}{the name of the attribute}
  \item{default}{a value to use as the default return if the attribute
    is not present in the XML node. }
  \item{converter}{an optional function which if supplied is invoked
    with the attribute value and the value returned.
    This can be used to convert the string to an arbitrary
    value which is useful if it is, for example, a number.
    This is only called if the attribute exists within the node.
   In other words, it is not applied to the \code{default} value.}
  \item{namespaceDefinition}{a named character vector giving
      name space prefixes and URIs to use when resolving for the
      the attribute with a namespace.
       The values are used to compare the name space prefix used in
       the \code{name} given by the user to the name space 
       definition in the node to ensure they match.
     This is important as we might ask for an attribute named
    \code{r:width} assuming that the prefix \code{r} corresponded to the
     URI \code{http://www.r-project.org}. However, there may 
     be a name space prefix \code{r} defined on the node that points
     to  a different URI and so this would be an erroneous match.
  }
  \item{addNamespace}{a logical value that indicates whether we should put the 
   namespace prefix on the resulting name.
   This is passed on to \code{\link{xmlAttrs}} and so controls whether the resulting
   attribute names  have the prefix attached. 
   So one specifies \code{TRUE} for this argument if the attribute identifier
   has a namespace prefix.
  }
}
\details{
  This just checks that the attribute list is
  non-NULL and that there is an element with
  the specified name.
}
\value{
  If the
  attribute is present,
  the return value is  a string which is the value of the attribute.
  Otherwise, the value of \code{default} is returned.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
 \code{\link{xmlAttrs}}
}

\examples{
 node <- xmlNode("foo", attrs=c(a="1", b="my name"))

 xmlGetAttr(node, "a")
 xmlGetAttr(node, "doesn't exist", "My own default value")

 xmlGetAttr(node, "b", "Just in case")
}
\keyword{file}

