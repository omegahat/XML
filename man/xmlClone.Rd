\name{xmlClone}
\alias{xmlClone}
\alias{xmlClone,XMLInternalNode-method}
\alias{xmlClone,XMLInternalDocument-method}

\title{Create a copy of an internal XML document or node}
\description{
  These methods allow the caller to create a copy of
  an XML internal node.  This is useful, for example, if we want to use
  the node or document in an  additional context, e.g.
  put the node into another document while leaving it in the
  existing document.  Similarly, if we want to remove nodes to simplify
  processing, we probably want to copy it so that the changes are not
  reflected in the original document.

  At present, the newly created object is not garbage collected.
}
\usage{
xmlClone(node, recursive = TRUE, addFinalizer = FALSE, ...)
}
\arguments{
  \item{node}{the object to be cloned}
  \item{recursive}{a logical value indicating whether the
    entire object and all its descendants should be duplicated/cloned (\code{TRUE})
    or just the top-level object (\code{FALSE})}
  \item{addFinalizer}{typically a logical value indicating whether to bring this
    new object under R's regular garbage collection.
     This can also be a reference to a C routine which is to be used as
      the finalizer. See \code{\link[base]{getNativeSymbolInfo}}.
  
   }
  \item{\dots}{additional parameters for methods}
}
\value{
 A new R object representing the object.
}
\references{libxml2}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{xmlParse}}  
  \code{\link{newXMLNode}}
  \code{\link{newXMLDoc}}
}
\examples{
  doc = xmlParse('<doc><author  id="dtl"><firstname>Duncan</firstname><surname>Temple  Lang</surname></author></doc>')

  au = xmlRoot(doc)[[1]]
     # make a copy
  other = xmlClone(au)
     # change it slightly
  xmlAttrs(other) = c(id = "dtl2")
     # add it to the children
  addChildren(xmlRoot(doc), other)
}
\keyword{IO}
\keyword{programming}
\concept{XML}
