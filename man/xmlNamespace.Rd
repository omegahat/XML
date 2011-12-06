\name{xmlNamespace}
\alias{xmlNamespace}
\alias{xmlNamespace.XMLNode}
\alias{xmlNamespace.XMLInternalNode}
\alias{xmlNamespace.character}
\alias{XMLNamespace-class}
\alias{xmlNamespace<-}
\alias{xmlNamespace<-,XMLInternalNode-method}
\title{Retrieve the namespace value of an XML node.}
\description{
Each XML node has a namespace identifier which is a string indicating
in which DTD (Document Type Definition) the definition of that element
can be found.  This avoids the problem of having different document
definitions using the same names for XML elements that have different
meaning.
To resolve the name space, i.e. 
 i.e. find out to where the identifier points,
one can use the
expression \code{xmlNamespace(xmlRoot(doc))}.

The class of the result is
 is an S3-style object of class \code{XMLNamespace}.
}
\usage{
xmlNamespace(x)
xmlNamespace(x, ...) <- value
}
\arguments{
  \item{x}{the object whose namespace is to be computed}
  \item{value}{the prefix for a namespace that is defined in the node or
 any of the ancestors.}
  \item{\dots}{additional arguments for setting the name space}
}
\value{
 For non-root nodes, this returns a string giving the identifier
 of the name space for this node.
For the root node,
this returns a list with 2 elements:
\item{id}{the identifier by which other nodes refer to this
namespace.}
\item{uri}{the URI or location that defines this namespace.}
\item{local}{? (can't remember off-hand).}
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
 \code{\link{xmlName}}
 \code{\link{xmlChildren}}
 \code{\link{xmlAttrs}}
 \code{\link{xmlValue}}
 \code{\link{xmlNamespaceDefinitions}} 
}

\examples{
  doc <- xmlTreeParse(system.file("exampleData", "job.xml", package="XML"))
  xmlNamespace(xmlRoot(doc))
  xmlNamespace(xmlRoot(doc)[[1]][[1]])


  doc <- xmlInternalTreeParse(system.file("exampleData", "job.xml", package="XML"))
     # Since the first node, xmlRoot() will skip that, by default.
  xmlNamespace(xmlRoot(doc))
  xmlNamespace(xmlRoot(doc)[[1]][[1]])

  node <- xmlNode("arg", xmlNode("name", "foo"), namespace="R")
  xmlNamespace(node)


   doc = xmlParse('<top xmlns:r="http://www.r-project.org"><bob><code>a = 1:10</code></bob></top>')
   node = xmlRoot(doc)[[1]][[1]]
   xmlNamespace(node) = "r"
   node


   doc = xmlParse('<top xmlns:r="http://www.r-project.org"><bob><code>a = 1:10</code></bob></top>')
   node = xmlRoot(doc)[[1]][[1]]
   xmlNamespaces(node, set = TRUE) = c(omg = "http://www.omegahat.org")
   node
}
\keyword{file}
