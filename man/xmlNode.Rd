\name{xmlNode}
\alias{xmlNode}
\alias{xmlTextNode}
\alias{xmlPINode}
\alias{xmlCDataNode}
\alias{xmlCommentNode}
\title{Create an XML node}
\description{
 These functions allow one to create XML nodes
as are created in C code when reading XML documents.
Trees of XML nodes can be constructed and 
integrated with other trees generated manually
or with via the parser.
}
\usage{
xmlNode(name, ..., attrs=NULL, namespace="", namespaceDefinitions = NULL, .children = list(...))
xmlTextNode(value, namespace="", entities = XMLEntities, cdata = FALSE)
xmlPINode(sys, value, namespace="")
xmlCDataNode(...)
xmlCommentNode(text)
}
\arguments{
  \item{name}{The tag or element name of the XML node. This is what appears
   in the elements as \code{<name> .. </name>}}
  \item{\dots}{The children nodes of this XML node.
    These can be objects of class \code{XMLNode}
   or arbitrary values that will be converted to a string
   to form an \code{XMLTextNode} object.}
 \item{.children}{an alternative mechanism to specifying the children
   which is useful for programmatic use when one has the children
   in an existing list.  The \dots mechanism is for use when the
    children are specified directly and individually.
 }
  \item{attrs}{A named character vector giving the 
     name, value pairs of attributes for this XML node.}
  \item{value}{This is the text that is to be used when forming
     an \code{XMLTextNode}.}
    \item{cdata}{a logical value which controls whether the text 
     being used for the child node is to be first
      enclosed within a CDATA node to escape special characters such
      as \code{>} and \code{&}.
   }
  \item{namespace}{The XML namespace identifier for this node.}
  \item{namespaceDefinitions}{a collection of name space definitions, containing the prefixes and the corresponding URIs.
    This is most conveniently specified as a character vector whose names attribute is the vector of prefixes
   and whose values are the URIs.  Alternatively, one can provide a list of name space definition objects 
   such as those returned}
  \item{sys}{the name of the system for which the processing instruction
    is targeted. This is the value that appears in the
     \code{<?sys value?>}}
   \item{text}{character string giving the contents of the comment.}
   \item{entities}{a character vector giving the mapping
     from special characters to their entity equivalent.
     This provides the  character-expanded
     entity pairings of 'character = entity' , e.g. '<' = "lt" which are
     used to make the content valid XML
     so that it can be used within a text node.  
     The text searched sequentially
     for instances of each character in the names and each instance is
     replaced with the corresponding '&entity;' }
}
\value{
 An object of class \code{XMLNode}.
In the case of \code{xmlTextNode},
this also inherits from \code{XMLTextNode}.
The fields or slots that objects
of these classes have
include
\code{name}, \code{attributes}, \code{children} and \code{namespace}.
However, one should 
the accessor functions
\code{\link{xmlName}},
\code{\link{xmlAttrs}},
\code{\link{xmlChildren}}
and
\code{\link{xmlNamespace}}
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
 \code{\link{addChildren}}  
 \code{\link{xmlTreeParse}}
 \code{\link{asXMLNode}}
 \code{\link{newXMLNode}}
 \code{\link{newXMLPINode}}
 \code{\link{newXMLCDataNode}}
 \code{\link{newXMLCommentNode}}
}

\examples{

 # node named arg with two children: name and defaultValue
 # Both of these have a text node as their child.
 n <- xmlNode("arg", attrs = c(default="TRUE"),
               xmlNode("name", "foo"), xmlNode("defaultValue","1:10"))


  # internal C-level node.
 a = newXMLNode("arg", attrs = c(default = "TRUE"),
                newXMLNode("name", "foo"),
                newXMLNode("defaultValue", "1:10"))

 xmlAttrs(a) = c(a = 1, b = "a string")

 xmlAttrs(a) = c(a = 1, b = "a string", append = FALSE)

 newXMLNamespace(a, c("r" = "http://www.r-project.org"))
 xmlAttrs(a) = c("r:class" = "character") 


 xmlAttrs(a[[1]]) = c("r:class" = "character") 


  # Using a character vector as a namespace definitions
 x = xmlNode("bob",
             namespaceDefinitions = c(r = "http://www.r-project.org",
                                      omg = "http://www.omegahat.org"))
}
\keyword{file}
