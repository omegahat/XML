\name{libxmlVersion}
\alias{libxmlVersion}
\alias{libxmlFeatures}
\title{Query the version and available features of the libxml library.}
\description{
\code{libxmlVersion} retrieves the version of the libxml
library used when installing this XML package.
\code{libxmlFeatures} returns a named logical vector
indicating which features are enabled.
}
\usage{
libxmlVersion(runTime = FALSE)
libxmlFeatures()
}
\arguments{
 \item{runTime}{a logical value indicating whether to retrieve the version information
  describing libxml  when the R package was compiled or the run-time version.
  These may be different if a) a new version of libxml2 is installed after the package is installed,
  b) if the package was installed as a binary package built on a different machine.
 }
}
\value{
\code{libxmlVersion} returns a named list with
fields
\item{major}{the major version number, either 1 or 2
  indicating the old or new-style library.}
\item{minor}{the within version release number.}
\item{patch}{the within minor release version number}

\code{libxmlFeatures} returns a logical vector with names given by:
\code{
 [1] "THREAD"     "TREE"       "OUTPUT"     "PUSH"       "READER"    
 [6] "PATTERN"    "WRITER"     "SAX1"       "FTP"        "HTTP"      
[11] "VALID"      "HTML"       "LEGACY"     "C14N"       "CATALOG"   
[16] "XPATH"      "XPTR"       "XINCLUDE"   "ICONV"      "ISO8859X"  
[21] "UNICODE"    "REGEXP"     "AUTOMATA"   "EXPR"       "SCHEMAS"   
[26] "SCHEMATRON" "MODULES"    "DEBUG"      "DEBUG_MEM"  "DEBUG_RUN" 
[31] "ZLIB"      
}
Elements are either \code{TRUE} or \code{FALSE} indicating whether support
was activatd for that feature, or \code{NA} if that feature is not
part of the particular version of libcurl.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.xmlsoft.org},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

%\seealso{}

\examples{
 ver <- libxmlVersion()
 if(is.null(ver)) {
   cat("Relly old version of libxml\n")
 } else {
   if(ver$major > 1) {
     cat("Using libxml2\n")
   }
 }
}
\keyword{IO}
