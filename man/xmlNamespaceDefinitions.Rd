\name{xmlNamespaceDefinitions}
\alias{xmlNamespaceDefinitions}
\alias{getDefaultNamespace}
\alias{xmlNamespaces}
\alias{xmlNamespaces<-}
\alias{xmlNamespaces<-,XMLInternalNode-method}
\alias{xmlNamespaces<-,XMLNode-method}
\alias{coerce,NULL,XMLNamespaceDefinitions-method}
\alias{coerce,XMLNamespace,character-method}
\alias{coerce,XMLNamespaceDefinition,character-method}
\alias{coerce,XMLNamespaceDefinitions,character-method}
\alias{coerce,character,XMLNamespaceDefinitions-method}
\title{Get definitions of any namespaces defined in this XML node}
\description{
  If the given node has any namespace definitions declared within it,
  i.e. of the form \code{xmlns:myNamespace="http://www.myNS.org"},
  \code{xmlNamespaceDefinitions} provides access to these definitions.
  While they appear in the XML node in the document as attributes,
  they are treated differently by the parser and so do not show up
  in the nodes attributes via \code{\link{xmlAttrs}}.

  \code{getDefaultNamespace} is used to get the default namespace
  for the top-level node in a document.

  The \code{recursive} parameter allows one to   conveniently find all the namespace
  definitions in a document or sub-tree without having to examine the file.
  This can be useful when working with XPath queries via
  \code{\link{getNodeSet}}.
}
\usage{
xmlNamespaceDefinitions(x, addNames = TRUE, recursive = FALSE, simplify = FALSE, ...)
xmlNamespaces(x, addNames = TRUE, recursive = FALSE,  simplify = FALSE, ...)
getDefaultNamespace(doc, ns = xmlNamespaceDefinitions(doc, simplify = simplify),  
                      simplify = FALSE) 
}
\arguments{
  \item{x}{the \code{XMLNode} object in which to find any namespace
    definitions}
  \item{addNames}{a logical indicating whether to compute the names for
    the elements in the resulting list. The names are convenient, but
    one can avoid the (very small) overhead of computing these with this
    parameter.}
  \item{doc}{the XMLInternalDocument object obtained from a call to
    \code{\link{xmlParse}}
  }
  \item{recursive}{a logical value indicating whether to extract the
    namespace definitions for just this node (\code{FALSE})
    or all of the descendant nodes as well (\code{TRUE}).
    If this is \code{TRUE}, all the namespace definitions are
    collected into a single "flat" list and so there may be duplicate
    names.
  }
 \item{simplify}{a logical value. If this is \code{TRUE}, 
     a character vector of prefix-URI pairs is returned.
   This can be used directly in calls to functions such as
      \code{\link{xpathApply}}  and \code{\link{getNodeSet}}.
    The default value of \code{FALSE} returns a list
    of name space definitions which also identify 
   whether the definition is local to the particular node or inherited
   from an ancestor.
 }
 \item{ns}{the collection of namespaces. This is typically omitted
   but can be specified if it has been computed in an earlier step.}
 \item{\dots}{additional parameters for methods}
}
\value{
  A list with as many elements as there are namespace definitions.
  Each element is an object of class XMLNameSpace,
  containing fields giving the local identifier, the associated defining
  URI and a logical value indicating whether the definition is local to
  this node.
  The name of each element is the prefix or alias used  for that
  namespace definition, i.e. the value of the \code{id} field in the
  namespace definition. For default namespaces, i.e. those that have no
  prefix/alias, the name is \code{""}.
}
\references{\url{http://www.w3.org/XML}}
\author{ Duncan Temple Lang }

\seealso{
  \code{\link{xmlTreeParse}}
  \code{\link{xmlAttrs}}
  \code{\link{xmlGetAttr}}  
}
\examples{
  f = system.file("exampleData", "longitudinalData.xml", package = "XML")
  n = xmlRoot(xmlTreeParse(f))
  xmlNamespaceDefinitions(n)
  xmlNamespaceDefinitions(n, recursive = TRUE)


    # Now using internal nodes.
  f = system.file("exampleData", "namespaces.xml", package = "XML")
  doc = xmlInternalTreeParse(f)
  n = xmlRoot(doc)
  xmlNamespaceDefinitions(n)

  xmlNamespaceDefinitions(n, recursive = TRUE)
}
\keyword{IO}
\concept{XML}
