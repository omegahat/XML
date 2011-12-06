\name{processXInclude}
\alias{processXInclude}
\alias{processXInclude.list}
\alias{processXInclude.XMLInternalDocument}
\alias{processXInclude.XMLInternalElement}
\title{Perform the XInclude substitutions}
\description{
  This function and its methods process the XInclude directives
  within the document of the form \code{<xi:include href="..."
    xpointer=".."}
  and perform the actual substitution.

  These are only relevant for "internal nodes" as generated
  via \code{\link{xmlInternalTreeParse}} and
  \code{\link{newXMLNode}} and their related functions.
  When dealing with XML documents via \code{\link{xmlTreeParse}}
  or \code{\link{xmlEventParse}}, the XInclude nodes are controlled
  during the parsing.
}
\usage{
processXInclude(node, flags = 0L)
}
\arguments{
  \item{node}{an XMLInternalDocument object or an XMLInternalElement
    node or a list of such internal nodes,
    e.g. returned from \code{\link{xpathApply}}.}
  \item{flags}{an integer value that provides information to control
    how the XInclude substitutions are done, i.e. how they are parsed. This is a bitwise OR'ing
    of some or all of the xmlParserOption values.
   This will be turned into an enum in R in the future.}
}

\value{
  These functions are used for their side-effect to modify the
  document and its nodes.
}
\references{
  libxml2 \url{http://www.xmlsoft.org}
  XInclude
}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{xmlInternalTreeParse}}
  \code{\link{newXMLNode}}
}
\examples{

  f = system.file("exampleData", "include.xml", package = "XML")
  doc = xmlInternalTreeParse(f, xinclude = FALSE)

  cat(saveXML(doc))
  sects = getNodeSet(doc, "//section")
  sapply(sects, function(x) xmlName(x[[2]]))
  processXInclude(doc)

  cat(saveXML(doc))

  f = system.file("exampleData", "include.xml", package = "XML")
  doc = xmlInternalTreeParse(f, xinclude = FALSE)
  section1 = getNodeSet(doc, "//section")[[1]]

     # process 
  processXInclude(section1[[2]])
}

\keyword{IO }
\keyword{programming}
\concept{XML}
