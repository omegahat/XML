\name{replaceNodeWithChildren}
\alias{replaceNodeWithChildren}
\title{Replace an XML node with it child nodes}
\description{
  This function can be used to flatten parts of an XML tree.
  This takes a node and removes itself from the tree, but places
  its kids in it place.
}
\usage{
replaceNodeWithChildren(node)
}
\arguments{
 \item{node}{an \code{XMLInternalNode} object}
}
\value{
  \code{NULL}. The purpose of this function is to modify the internal document.
}
\references{
libxml2 documentation.
}
\author{
Duncan Temple Lang
}

\examples{
doc = xmlParse('<doc>
                 <page>
                  <p>A</p>
                  <p>B</p>
                  <p>C</p>
                 </page>
                 <page>
                  <p>D</p>
                  <p>E</p>
                  <p>F</p>
                 </page>
                </doc>')

pages = getNodeSet(doc, "//page")
invisible(lapply(pages, replaceNodeWithChildren))
doc
}
\keyword{IO}


