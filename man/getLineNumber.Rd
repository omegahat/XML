\name{getLineNumber}
\alias{getNodeLocation}
\alias{getNodePosition}
\alias{getLineNumber}
\title{Determine the location - file \& line number of an (internal) XML node}
\description{
  The \code{getLineNumber} function is used to query the location of an internal/C-level
  XML node within its original "file". This gives us the line number.
  \code{getNodeLocation} gives both the line number and the name of the
  file in which the node is located, handling XInclude files in a
  top-level document  and identifying the included file, as appropriate.
  \code{getNodePosition} returns a simplified version of
  \code{getNodeLocation},
  combining the file and line number into a string and ignoring the
  \code{XPointer} component.

  This is useful when we identify a node with a particular charactestic
  and want to view/edit the original document, e.g. when authoring an
  Docbook article.
}
\usage{
getLineNumber(node, ...)
getNodeLocation(node, recursive = TRUE, fileOnly = FALSE)
}
\arguments{
  \item{node}{the node whose location or line number is of interest}
  \item{\dots}{additional parameters for methods should they be defined.}
  \item{recursive}{a logical value that controls whether the 
    full path of the nested includes is returned or just the
    path in the immediate XInclude element.}
  \item{fileOnly}{a logical value which if \code{TRUE} means that only
  the name of the file is returned, and not the \code{xpointer} attribute or
  line number .}
}

\value{
  \code{getLineNumber} returns an integer.
  \code{getNodeLocation} returns a list with two elements -
  \code{file} and \code{line} which are a character string
  and the integer line number.

  For text nodes, the line number is taken from the previous sibling
  nodes or the parent node.
}
\references{libxml2 }
\author{Duncan Temple Lang}
\seealso{
  \code{\link{findXInclude}}
  \code{\link{xmlParse}}
  \code{\link{getNodeSet}}
  \code{\link{xpathApply}}    
}
\examples{
f = system.file("exampleData", "xysize.svg", package = "XML")
doc = xmlParse(f)
e = getNodeSet(doc, "//ellipse")
sapply(e, getLineNumber)
}
\keyword{IO}
\concept{XML}
