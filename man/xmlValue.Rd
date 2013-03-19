\name{xmlValue}
\alias{xmlValue}
\alias{xmlValue.XMLCDataNode}
\alias{xmlValue.XMLNode}
\alias{xmlValue.XMLProcessingInstruction}
\alias{xmlValue.XMLTextNode}
\alias{xmlValue.XMLComment}
\alias{xmlValue<-}
\alias{xmlValue<-,XMLAbstractNode-method}
\alias{xmlValue<-,XMLInternalTextNode-method}
\alias{xmlValue<-,XMLTextNode-method}
\alias{coerce,XMLInternalTextNode,character-method}
\title{Extract or set the contents of a leaf XML node}
\description{
  Some types of XML nodes have no children nodes, but are leaf nodes and
  simply contain text. Examples are \code{XMLTextMode}, \code{XMLProcessingInstruction}.
  This function provides access to their raw contents.
  This has been extended to operate recursivel on arbitrary XML nodes
  that contain a single text node.
}
\usage{
xmlValue(x, ignoreComments = FALSE, recursive = TRUE,
          encoding = getEncoding(x), trim = FALSE)
}
\arguments{
  \item{x}{the \code{XMLNode} object whose
    contents are to be  returned.}
  \item{ignoreComments}{a logical value which, if \code{TRUE}
    does not include the text in XML comment nodes.
    If this is \code{FALSE}, the text in the comments is part
    of the return value.
  }
  \item{recursive}{a logical value indicating whether to process all
    sub-nodes (\code{TRUE}) or only the text nodes within the node \code{x}.
  }
%XXX
 \item{encoding}{experimental functionality and parameter related to
   encoding.}
 \item{trim}{a logical value controlling whether we remove leading or
   trailing white space when returning the string value}
}
\value{
 The object stored in the 
 \code{value} slot of the \code{XMLNode} object.
 This is typically a string.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
 \code{\link{xmlChildren}}
 \code{\link{xmlName}}
 \code{\link{xmlAttrs}}
 \code{\link{xmlNamespace}}
}

\examples{
 node <- xmlNode("foo", "Some text")
 xmlValue(node)

 xmlValue(xmlTextNode("some more raw text"))

  # Setting the xmlValue().
 a = newXMLNode("a")
 xmlValue(a) = "the text"
 xmlValue(a) = "different text"

 a = newXMLNode("x", "bob")
 xmlValue(a) = "joe"

 b = xmlNode("bob")
 xmlValue(b) = "Foo"
 xmlValue(b) = "again"

 b = newXMLNode("bob", "some text")
 xmlValue(b[[1]]) = "change"
 b
}
\keyword{file}
