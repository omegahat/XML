\name{xmlElementSummary}
\alias{xmlElementSummary}
\title{Frequency table of names of elements and attributes in XML content}
\description{
  This function is used to get an understanding of the use
  of element and attribute names in an XML document.
  It uses a collection of handler functions to gather 
  the information via a SAX-style parser.  
  The distribution of attribute names is done within each
  "type" of element (i.e. element name)
}
\usage{
xmlElementSummary(url, handlers = xmlElementSummaryHandlers(url))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{url}{the source of the XML content, e.g. a file, a URL,  a
  compressed file, or a character string}
  \item{handlers}{the list of handler functions used to collect the
   information. These are passed to the function
   \code{\link{xmlEventParse}}
   as the value for the \code{handlers} parameter.
}
}
\value{
A list with two elements
 \item{nodeCounts}{a named vector of counts where the names are the
 (XML namespace qualified) element names in the XML content}
 \item{attributes}{a list with as many elements as there are elements
 in the \code{nodeCounts} element of the result. Each element of this
 sub-list gives the frequency counts for the different attributes seen within
 the XML elements with that name.}
}

\author{Duncan Temple Lang}

\seealso{
 \code{\link{xmlEventParse}}
}
\examples{
  xmlElementSummary(system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML"))
}

\keyword{IO}
\concept{XML}

