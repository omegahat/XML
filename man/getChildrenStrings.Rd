\name{getChildrenStrings}
\alias{getChildrenStrings}
\title{Get the individual }
\description{
  This is different from \code{xmlValue} applied to the node.
  That concatenates all of the text in the child nodes (and their descendants)
  This is a faster version of \code{xmlSApply(node, xmlValue)}
}
\usage{
getChildrenStrings(node, encoding = getEncoding(node),
                    asVector = TRUE, len = xmlSize(node), addNames = TRUE)
}
\arguments{
  \item{node}{the parent node whose child nodes we want to process}
  \item{encoding}{the encoding to use for the text. This should come
    from the document itself. However, it can be useful to specify it if
  the encoding has not been set for the document (e.g. if we are
  constructing it node-by-node).}
\item{asVector}{a logical value that controls whether the result is
   returned as a character vector or as a list (\code{FALSE}).
}
  \item{len}{an integer giving the number of elements we expect
    returned. This is best left unspecified but can be provided if the
    caller already knows the number of child nodes. This avoids
    recomputing this and so provides a marginal speedup.}
  \item{addNames}{a logical value that controls whether we add the
    element names to each element of the resulting vector. This makes it
  easier to identify from which element each string came.}
}
\value{
 A character vector.
}
\author{
Duncan Temple Lang
}

\seealso{
  \code{\link{xmlValue}}
}
\examples{
doc = xmlParse("<doc><a>a string</a> some text <b>another piece of text</b></doc>")
getChildrenStrings(xmlRoot(doc))

doc = xmlParse("<doc><a>a string</a> some text <b>another piece of text</b><c/><d>abc<e>xyz</e></d></doc>")
getChildrenStrings(xmlRoot(doc))
}
\keyword{programming}
