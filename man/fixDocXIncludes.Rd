\name{fixDocXIncludes}
\alias{fixDocXIncludes}
\title{Fix the href attributes on XML_XINCLUDE_START nodes}
\description{
  This attempts to fix the C-level XML nodes that libxml2
  creates to represent content included by XInclude \code{xi:include}
  nodes.
}
\usage{
fixDocXIncludes(doc, xinc = getXIncludes2(docName(doc)))
}
\arguments{
  \item{doc}{the XML document or node}
  \item{xinc}{the data frame containing the information
    about which XML file includes which other XML files, in
    the order they are included in the XML tree.}
}
\value{
The updated document/XML tree with the href attribute set.
}
\references{
libxml2 and XInclude nodes.
}
\author{
Duncan Temple Lang
}


\seealso{
\code{\link{xmlParse}}
\code{\link{getXIncludes2}}
\code{\link{getNodeLocation}}
}
\examples{
m = xmlParse(system.file("examples/multi.xml", package = "XML"))
invisible(fixDocXIncludes(m))
getNodeLocation(getNodeSet(m, "//C"))
}
\keyword{IO}
