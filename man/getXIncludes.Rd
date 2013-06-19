\name{getXIncludes}
\alias{getXIncludes}
\alias{xmlXIncludes}
\title{Find the documents that are XInclude'd in an XML document}
\description{
  The \code{getXMLIncludes} function finds the names of the  documents
  that are XIncluded in a given XML document,
  optionally processing these documents recursively.

  \code{xmlXIncludes} returns the hierarchy of included documents.
}
\usage{
getXIncludes(filename, recursive = TRUE, skip = character(),
             omitPattern = "\\\\.(js|html?|txt|R|c)$",
             namespace = c(xi = "http://www.w3.org/2003/XInclude"),
            duplicated = TRUE)
xmlXIncludes(filename, recursive = TRUE,
         omitPattern = "\\.(js|html?|txt|R|c)$",
         namespace = c(xi = "http://www.w3.org/2003/XInclude"),
         addNames = TRUE,
         clean = NULL, ignoreTextParse = FALSE)
}
\arguments{
  \item{filename}{the name of the XML document's URL or file or the
    parsed document itself.}
  \item{recursive}{a logical value controlling whether to recursively
   process the XInclude'd files for their XInclude'd files}
  \item{skip}{a character vector of file names to ignore or skip over}
  \item{omitPattern}{a regular expression for indentifying files that
    are included that we do not want to recursively process}
  \item{namespace}{the namespace to use for the XInclude. There are two
    that are in use 2001 and 2003.}
  \item{duplicated}{a logical value that controls whether only the
    unique names of the files are returned, or if we get all references
    to all files.}
  \item{addNames}{a logical that controls whether we add the name of
    the parent file as the names vector for the collection of included
    file names. This is useful, but sometimes we want to disable this,
    e.g. to create a \code{JSON} representation of the hierarchy for use
  in, e.g., D3.}
  \item{clean}{how to process the names of the files. This can be a
    function or a character vector of two regular expressions passed to
    \code{gsub}.
    The function is called with a vector of file names. The regular
    expressions are used in a call to \code{gsub}.}
}
\value{
 If \code{recursive} is \code{FALSE}, a character vector giving the
 names of the included files.

 For \code{recursive} is \code{TRUE}, currently the same character
 vector form. However, this will be a hierarchical list.
}
\author{
Duncan Temple Lang
}

\seealso{
 \code{\link{getHTMLExternalFiles}}
}
\examples{

  f = system.file("exampleData", "xinclude", "a.xml", package = "XML")

  getXIncludes(f, recursive = FALSE)

}
\keyword{IO}
\concept{XML}
