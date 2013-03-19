\name{getXIncludes}
\alias{getXIncludes}
\title{Find the documents that are XInclude'd in an XML document}
\description{
  This function finds the names of the  documents
  that are XIncluded in a given XML document,
  optionally processing these documents recursively.
}
\usage{
getXIncludes(filename, recursive = TRUE, skip = character(),
             omitPattern = "\\\\.(js|html?|txt|R|c)$",
             namespace = c(xi = "http://www.w3.org/2003/XInclude"),
            duplicated = TRUE)
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
