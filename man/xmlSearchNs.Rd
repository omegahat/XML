\name{xmlSearchNs}
\alias{xmlSearchNs}
\alias{coerce,XMLNamespaceRef,character-method}
\title{Find a namespace definition object by searching ancestor nodes}
\description{
  This function allows one to search an XML tree from a particular node
  and find the namespace definition for a given namespace prefix or URL.
  This namespace definition can then be used to set it on a node to
  make it the effective namespace for that node.
}
\usage{
xmlSearchNs(node, ns, asPrefix = TRUE, doc = as(node, "XMLInternalDocument"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{node}{an \code{XMLInternaElementNode}}
  \item{ns}{a character string (vector of length 1).
    If \code{asPrefix} is \code{TRUE}, this is the namespace
    alias/prefix.
   If \code{asPrefix} is \code{FALSE}, this is the URL of the namespace definition}
  \item{asPrefix}{a logical value. See \code{ns}.}
  \item{doc}{the XML document in which the node(s) are located}
}
\value{
 An object of class XMLNamespaceRef.
}
\references{
  libxml2
}
\author{
Duncan Temple Lang
}
\seealso{
 \code{\link{newXMLNode}}
}
\examples{
 txt = '<top xmlns:r="http://www.r-project.org"><section><bottom/></section></top>'

 doc = xmlParse(txt)
 bottom = xmlRoot(doc)[[1]][[1]]
 xmlSearchNs(bottom, "r")
}
\keyword{programming}
\keyword{data}

