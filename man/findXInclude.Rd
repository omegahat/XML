\name{findXInclude}
\alias{findXInclude}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Find the XInclude node associated with an XML node}
\description{
 This function is used to traverse the ancestors of an 
 internal XML node to find the associated XInclude 
 node that identifies it as being an XInclude'd node.
 Each top-level node that results from an include href=... in the libxml2 parser
 is sandwiched between nodes of class
  XMLXIncludeStartNode and XMLXIncludeStartNode.
  These are the sibling nodes.

  Another approach to finding the origin of the XInclude for a given
  node is to search for an attribute xml:base. This only works if the
  document being XInclude'd is in a different directory than the base document.
  If this is the case, we can use an XPath query to find the node
  containing the attribute via \code{"./ancestor::*[@xml:base]"}.
}
\usage{
findXInclude(x, asNode = FALSE, recursive = FALSE)
}
\arguments{
  \item{x}{the node whose XInclude "ancestor" is to be found}
  \item{asNode}{a logical value indicating whether to return the node itself or
       the attributes of the node which are typically the immediately interesting 
       aspect of the node.}
  \item{recursive}{a logical value that controls whether the 
    full path of the nested includes is returned or just the
    path in the immediate XInclude element.}  
}
\value{
  Either \code{NULL} if there was no node of class XMLXIncludeStartNode
  found.
  Otherwise, if \code{asNode} is \code{TRUE}, that  XMLXIncludeStartNode
  node is returned, or alternatively its attribute character vector.
}
\references{www.libxml.org}
\author{Duncan Temple Lang}

\seealso{
\code{\link{xmlParse}} and the \code{xinclude} parameter.  
}
\examples{

 f = system.file("exampleData", "functionTemplate.xml", package = "XML")

 cat(readLines(f), "\n")

 doc = xmlParse(f)

  # Get all the para nodes
  # We just want to look at the 2nd and 3rd which are repeats of the
  # first one.
 a = getNodeSet(doc, "//author")
 findXInclude(a[[1]])

 i = findXInclude(a[[1]], TRUE)
 top = getSibling(i)

   # Determine the top-level included nodes
 tmp = getSibling(i)
 nodes = list()
 while(!inherits(tmp, "XMLXIncludeEndNode")) {
   nodes = c(nodes, tmp)
   tmp = getSibling(tmp)
 }
}
\keyword{IO}

