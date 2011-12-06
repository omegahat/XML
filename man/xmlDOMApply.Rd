\name{xmlDOMApply}
\alias{xmlDOMApply}
\title{Apply function to nodes in an XML tree/DOM.}
\description{

 This recursively applies the specified function to each node in an
 XML tree, creating a new tree,
 parallel to the original input tree.
 Each  element in the new tree is the return
 value obtained from invoking the specified function
 on the corresponding element
 of the original tree.
 The order in which the function is recursively applied
 is "bottom-up". In other words, 
 function is first applied to each of the children
 nodes first and then to the  parent node
 containing the newly computed results for the children.
}
\usage{
xmlDOMApply(dom, func)
}
\arguments{
  \item{dom}{a node in the XML tree or DOM on which to recursively
apply the given function.
This should not be the \code{XMLDocument}
itself returned from
\code{\link{xmlTreeParse}}
but an object of class \code{XMLNode}.
This is typically obtained by
calling \code{\link{xmlRoot}} on the
return value from \code{\link{xmlTreeParse}}.
}
  \item{func}{ 
 the function to be applied to each node in the XML tree.
 This is passed the node object for the and the return
 value is inserted into the new tree that is to be returned
 in the corresponding position as the node being processed.
 If the return value is \code{NULL}, this node is dropped from the tree.}
}
\details{
 This is a native (C code) implementation that 
understands the structure of an XML DOM returned
from \code{\link{xmlTreeParse}} and iterates
over the nodes in that tree.
}
\value{
 A tree that parallels the structure in the 
\code{dom} object passed to it.
}
\author{Duncan Temple Lang}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\seealso{\link{xmlTreeParse}}

\examples{
 dom <- xmlTreeParse(system.file("exampleData","mtcars.xml", package="XML"))
 tagNames <- function() {
    tags <- character(0)
    add <- function(x) {
      if(inherits(x, "XMLNode")) {
        if(is.na(match(xmlName(x), tags)))
           tags <<- c(tags, xmlName(x))
      }

      NULL
    }

    return(list(add=add, tagNames = function() {return(tags)}))
 }

 h <- tagNames()
 xmlDOMApply(xmlRoot(dom), h$add) 
 h$tagNames()
}
\keyword{file}
