\name{getHTMLLinks}
\alias{getHTMLLinks}
\alias{getHTMLExternalFiles}
\title{Get links or names of external files in HTML document} 
\description{
  These functions allow us to retrieve either the links
  within an HTML document, or the collection of names of
  external files referenced in an HTML document.
  The external files include images, JavaScript and CSS documents.
}
\usage{
getHTMLLinks(doc, externalOnly = TRUE, xpQuery = "//a/@href",
               baseURL = docName(doc), relative = FALSE)
getHTMLExternalFiles(doc, xpQuery = c("//img/@src", "//link/@href",
                                      "//script/@href", "//embed/@src"),
                     baseURL = docName(doc), relative = FALSE,
                     asNodes = FALSE, recursive = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{doc}{the HTML document as a URL, local file name, parsed
    document or an XML/HTML node}
  \item{externalOnly}{a logical value that indicates whether we should
    only return links to external documents and not references to
    internal anchors/nodes within this document, i.e. those that of the
    form \code{#foo}.}
  \item{xpQuery}{a vector of XPath elements which match the elements of interest}
\item{baseURL}{the URL of the container document. This is used
    to resolve relative references/links.
}
\item{relative}{a logical value indicating whether to leave the
  references as relative to the base URL or to expand them to their full paths.
}
\item{asNodes}{a logical value that indicates whether we want the actual
  HTML/XML   nodes in the document that reference external documents
  or just the names of the external documents.}
\item{recursive}{a logical value that controls whether we recursively
  process the external documents we find in the top-level document
  examining them for their external files.}
}

\value{
  \code{getHTMLLinks} returns a character vector of the links.

  \code{getHTMLExternalFiles} returns a character vector.
}
\author{
Duncan Temple Lang
}
\seealso{
  \code{\link{getXIncludes}}
}
\examples{
  getHTMLLinks("http://www.omegahat.org")

  getHTMLLinks("http://www.omegahat.org/RSXML")

  unique(getHTMLExternalFiles("http://www.omegahat.org"))
}
\keyword{IO}
\keyword{programming}

