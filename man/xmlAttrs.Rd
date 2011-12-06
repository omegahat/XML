\name{xmlAttrs}
\alias{xmlAttrs}
\alias{xmlAttrs<-}
\alias{xmlAttrs.XMLElementDef}
\alias{xmlAttrs<-,XMLNode}
\alias{xmlAttrs<-,XMLInternalNode}
\alias{xmlAttrs<-,XMLNode-method}
\alias{xmlAttrs<-,XMLInternalElementNode-method}
\alias{xmlAttrs.XMLNode}
\alias{xmlAttrs.XMLInternalNode}
\title{ Get the list of attributes of an XML node. }
\description{
 This returns a named character vector giving the 
 name-value pairs of attributes of an XMLNode object which is part of
 an XML document.
}
\usage{
 xmlAttrs(node, ...)
 'xmlAttrs<-'(node, append = TRUE, suppressNamespaceWarning = getOption("suppressXMLNamespaceWarning", FALSE), value)
}
\arguments{
  \item{node}{The \code{XMLNode} object
    whose attributes are to be extracted. }
  \item{append}{a logical value indicating whether to add the attributes in \code{value} to the existing attributes 
   within the XML node, or to replace the set of any existing attributes with this new set, i.e. remove the existing ones and 
   then set the attributes with the contents of \code{value}.}
  \item{...}{additional arguments for the specific methods. For XML
    internal nodes, these are \code{addNamespacePrefix} and
    \code{addNamespaceURLs}. These are both logical values and indicate
    whether to prepend the name of the attribute with the namespace
    prefix and also whether to return the namespace prefix and URL as a
    vector in the  \code{namespaces} attribute.}
  \item{value}{a named character vector giving the new attributes to be
    added to the node.}
  \item{suppressNamespaceWarning}{see \code{\link{addChildren}}}
}
\value{
A named character vector, where the names
are the attribute names and the 
elements are the corresponding values.
This corresponds to the (attr<i>, "value<i>")
pairs in the XML tag
\code{<tag attr1="value1"  attr2="value2"}
}
\references{\url{http://www.w3.org} }
\author{Duncan Temple Lang}
\seealso{ \code{\link{xmlChildren}}, \code{\link{xmlSize}},
\code{\link{xmlName}}}

\examples{
 fileName <- system.file("exampleData", "mtcars.xml", package="XML") 
 doc <- xmlTreeParse(fileName)

 xmlAttrs(xmlRoot(doc))

 xmlAttrs(xmlRoot(doc)[["variables"]])


 doc <- xmlParse(fileName)
 d = xmlRoot(doc)

 xmlAttrs(d)
 xmlAttrs(d) <- c(name = "Motor Trend fuel consumption data",
                  author = "Motor Trends")
 xmlAttrs(d)

   # clear all the attributes and then set new ones.
 removeAttributes(d)
 xmlAttrs(d) <- c(name = "Motor Trend fuel consumption data",
                  author = "Motor Trends")


     # Show how to get the attributes with and without the prefix and
     # with and without the URLs for the namespaces.
  doc = xmlParse('<doc xmlns:r="http://www.r-project.org">
                    <el r:width="10" width="72"/>
                    <el width="46"/>
                    </doc>')

  xmlAttrs(xmlRoot(doc)[[1]], TRUE, TRUE)
  xmlAttrs(xmlRoot(doc)[[1]], FALSE, TRUE)
  xmlAttrs(xmlRoot(doc)[[1]], TRUE, FALSE)
  xmlAttrs(xmlRoot(doc)[[1]], FALSE, FALSE)
}
\keyword{IO}
\keyword{file}
