\name{getRelativeURL}
\alias{getRelativeURL}
\title{Compute name of URL relative to a base URL}
\description{
 This function is a convenience function for 
 computing the fullly qualified URI of a document
 relative to a base URL. 
 It handles the case where the document is 
 already fully qualified and so ignores the base URL
 or, alternatively, is a relative document name and so
 prepends the base URL.
 It does not (yet) try to be clever by collapsing
 relative directories such as "..".
}
\usage{
getRelativeURL(u, baseURL, sep = "/", addBase = TRUE, simplify = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{u}{the location of the target document whose fully qualified URI is to be determined.}
  \item{baseURL}{the base URL relative to which the value of \code{u} should be interpreted.}
  \item{sep}{the separator to use to separate elements of the path. For external URLs (e.g. 
    accessed via HTTP, HTTPS, FTP), / should be used. For local files on Windows machines 
     one might use \code{.Platform$file.sep}, but this is incorrect unless one knows that the
     resulting file is to be accessed using Windows file system notation, i.e. 
      \code{C:\\\\my\\\\folder\\\\file}.
    }
    \item{addBase}{a logical controlling whether we prepend the base URL
      to  the  result.}
    \item{simplify}{a logical value that controls whether we attempt to
      simplify/normalize the path to remove \code{..} and \code{.}}
    
}
\details{
 This uses the function \code{parseURI} to compute the components
 of the different URIs.
}
\value{
  A character string giving the fully qualified URI for
  \code{u}.
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{parseURI}} which uses the libxml2 facilities for parsing URIs.
 
 \code{\link{xmlParse}},  \code{\link{xmlTreeParse}},  \code{\link{xmlInternalTreeParse}}.
  XInclude and XML Schema import/include elements for computing relative locations of included/imported files..
}
\examples{
 getRelativeURL("http://www.omegahat.org", "http://www.r-project.org")

 getRelativeURL("bar.html", "http://www.r-project.org/")

 getRelativeURL("../bar.html", "http://www.r-project.org/")
}
\keyword{IO}
\keyword{programming}
\concept{XML}
