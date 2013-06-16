\name{xmlCleanNamespaces}
\alias{xmlCleanNamespaces}
\title{Remove redundant namespaces on an XML document}
\description{
  This is a convenience function that removes redundant
  repeated namespace definitions in an XML node.
  It removes namespace definitions in nodes
  where an ancestor node also has that definition.
  It does not remove unused namespace definitions.

  This uses the \code{NSCLEAN} option for \code{\link{xmlParse}}
}
\usage{
xmlCleanNamespaces(doc, options = integer(), out = docName(doc), ...)
}
\arguments{
  \item{doc}{either the name of an XML documentor the XML content
    itself, or an already parsed document}
  \item{options}{options for the XML parser. \code{NSCLEAN} is added to this.}
  \item{\dots}{additional arguments passed to \code{\link{xmlParse}}}
  \item{out}{the name of a file to which to write the resulting XML
    document, or an empty character vector or logical value \code{FALSE}
    to avoid writing the new document.
   }
}
\value{
  If the new document is written to a file, the name of the file is
  returned.
  Otherwise, the new parsed XML document is returned.
}
\references{
libxml2 documentation \url{http://xmlsoft.org/html/libxml-parser.html}
}
\author{
Duncan Temple Lang
}
\seealso{
\code{\link{xmlParse}}
}
\examples{
f = system.file("exampleData", "redundantNS.xml", package = "XML")
doc = xmlParse(f)
print(doc)
newDoc = xmlCleanNamespaces(f, out = FALSE)
}
\keyword{programming} 
\keyword{IO}
