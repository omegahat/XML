\name{supportsExpat}
\alias{supportsExpat}
\alias{supportsLibxml}
\title{ Determines which native XML parsers are being used.}
\description{
 Use of the Gnome libxml and Expat parsers is supported
in this R/S XML package, but both need not be used when
compiling the package. These functions determine whether
each is available in the underlying native code.
}
\usage{
supportsExpat()
supportsLibxml()
}
\details{
 One might to use different parsers to test 
validity of a document in different ways and
to get different error messages. Additionally,
one parser may be more efficient than the other.
These methods allow one to write code in such
a way that one parser is preferred and is used
if it is available, but the other is used
if the first is not available.
}
\value{
 Returns \code{TRUE} if the corresponding library
has been linked into the package.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
\code{\link{xmlEventParse}}
}

\examples{
     # use Expat if possible, otherwise libxml
  fileName <- system.file("exampleData", "mtcars.xml", package="XML")
  xmlEventParse(fileName, useExpat = supportsExpat())
}
\keyword{file}
