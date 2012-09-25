\name{compareXMLDocs}
\alias{compareXMLDocs}
\title{Indicate differences between two XML documents}
\description{
 This function is an attempt to provide some assistance
in determining if two XML documents are the same and if
not, how they differ.  Rather than comparing
the tree structure, this function compares
the frequency distributions of the names of the
node. It omits position, attributes, simple content
from the comparison. Those are left to the functions
that have more contextual information to compare two documents.
}
\usage{
compareXMLDocs(a, b, ...)
}
\arguments{
  \item{a,b}{two parsed XML documents that must be internal documents, i.e. created with
  \code{\link{xmlParse}} or created with \code{\link{newXMLNode}}.}
  \item{\dots}{additional parameters that are passed on to the \code{summary} method for an internal document.}
}
\value{
 A list with elements
 \item{inA}{the names and counts of the XML elements that only appear in the first document}
 \item{inB}{the names and counts of the XML elements that only appear in the second document}
 \item{countDiffs}{a vector giving the difference in number of nodes with a particular name.}
These give a description of what is missing from one document relative to the other.
}
%\references{}
\author{
Duncan Temple Lang
}


\seealso{
 \code{\link{getNodeSet}}
}
\examples{

tt = 
 '<x>
     <a>text</a>
     <b foo="1"/>
     <c bar="me">
        <d>a phrase</d>
     </c>
  </x>'

  a = xmlParse(tt, asText = TRUE)
  b = xmlParse(tt, asText = TRUE)
  d = getNodeSet(b, "//d")[[1]]
  xmlName(d) = "bob"
  addSibling(xmlParent(d), newXMLNode("c"))
  
  compareXMLDocs(a, b)
}

\keyword{IO}

