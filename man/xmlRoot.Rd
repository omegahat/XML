\name{xmlRoot}
\alias{xmlRoot}
\alias{xmlRoot.XMLDocument}
\alias{xmlRoot.XMLInternalDocument}
\alias{xmlRoot.XMLInternalDOM}
\alias{xmlRoot.XMLDocumentRoot}
\alias{xmlRoot.XMLDocumentContent}
\alias{xmlRoot.HTMLDocument}

\title{Get the top-level XML node.}
\description{
 These are a collection of methods for providing easy access to the
top-level \code{XMLNode} object resulting from parsing an XML
document.  They simplify accessing this node in the presence of
auxillary information such as DTDs, file name and version information
that is returned as part of the parsing.
}
\usage{
xmlRoot(x, skip = TRUE, ...)
\method{xmlRoot}{XMLDocumentContent}(x, skip = TRUE, ...)
\method{xmlRoot}{XMLInternalDocument}(x, skip = TRUE, addFinalizer = NA, ...)
\method{xmlRoot}{HTMLDocument}(x, skip = TRUE, ...)
}
\arguments{
  \item{x}{the object whose root/top-level XML node is to be returned.}
  \item{skip}{a logical value that controls whether DTD nodes and/or
    XMLComment objects that appear
    before the \dQuote{real} top-level node of the document should be ignored (\code{TRUE})
   or not (\code{FALSE}) when returning the root node.}
  \item{...}{arguments that are passed by the generic to the different specialized 
    methods of this generic.}
  \item{addFinalizer}{a logical value or identifier for a C routine
        that controls whether we register finalizers on the intenal node.}
}
\value{
 An object of class \code{XMLNode}.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }
\note{One cannot obtain the parent or top-level node
  of an XMLNode object in S. This is different from 
  languages like C, Java, Perl, etc. and is primarily 
  because S does not provide support for references.}
\seealso{
\code{\link{xmlTreeParse}}
\code{\link{[[.XMLNode}}
}

\examples{
  doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
  xmlRoot(doc)
   # Note that we cannot use getSibling () on a regular R-level XMLNode object
   # since we cannot go back up or across the tree from that node, but
   # only down to the children.

    # Using an internal node via xmlParse (== xmlInternalTreeParse())
  doc <- xmlParse(system.file("exampleData", "mtcars.xml", package="XML"))
  n = xmlRoot(doc, skip = FALSE)
     # skip over the DTD and the comment
  d = getSibling(getSibling(n))
}
\keyword{file}

