\name{getXMLErrors}
\alias{getXMLErrors}
\title{Get XML/HTML document parse errors}
\description{
 This function is intended to be a convenience for 
finding all the errors in an XML or HTML document due
to being malformed, i.e. missing quotes on attributes,
non-terminated elements/nodes, incorrectly terminated
nodes, missing entities, etc.
 The document is parsed and a list of the errors is returned
 along with information about the file, line and column number.
}
\usage{
getXMLErrors(filename, parse = xmlParse, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{ the identifier for the  document to be parsed, one of
  a local file name,  a URL or the XML/HTML content itself}
  \item{parse}{ the function to use to parse the document, usually
  either  \code{\link{xmlTreeParse}} or  \code{\link{htmlTreeParse}}.
  }
  \item{\dots}{additional arguments passed to the function given by \code{parse}}
}
\value{
 A list of S3-style  \code{XMLError} objects.
}
\references{libxml2 (\url{http://xmlsoft.org})}
\author{Duncan Temple Lang}

\seealso{
  \code{error} argument for \code{\link{xmlTreeParse}} and related functions.
}
\examples{
     # Get the "errors" in the HTML that was generated from this Rd file
  getXMLErrors(system.file("html", "getXMLErrors.html", package = "XML"))

\dontrun{
  getXMLErrors("http://www.omegahat.org/index.html")
}

}
\keyword{IO}
\keyword{programming}

