\name{removeXMLNamespaces}
%\Rdversion{1.1}
\alias{removeXMLNamespaces}
\alias{removeXMLNamespaces,XMLInternalNode-method}
\alias{removeXMLNamespaces,XMLInternalElementNode-method}
\alias{removeXMLNamespaces,XMLInternalDocument-method}
\title{Remove namespace definitions from a XML node or document}
\description{
  This function and its methods allow one to remove one
  or more XML namespace definitions on XML nodes within a document.
}
\usage{
removeXMLNamespaces(node, ..., all = FALSE, .els = unlist(list(...)))
}
\arguments{
  \item{node}{an XMLInternalNode or XMLInternalDocument object}
  \item{\dots}{the names of the namespaces to remove or an
    XMLNamespaceRef object returned via \code{\link{getNodeSet}} or \code{\link{xpathApply}}.}
  \item{all}{a logical value indicating whether to remove all the
    namespace definitions on a node.}
  \item{.els}{a list which is sometimes a convenient way to specify the
    namespaces to remove.}
}
\value{
This function is used for its side-effects and changing the internal node.}
\author{
Duncan Temple Lang
}

\seealso{
  \code{\link{newXMLNamespace}}
}
%\examples{}

\keyword{IO}
