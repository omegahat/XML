\name{free}
\alias{free}
\alias{free,XMLInternalDocument-method}
\title{Release the specified object and clean up its memory usage}
\description{
  This generic function is available for explicitly releasing
  the memory associated with the given object.
  It is intended for use on external pointer objects
  which do not have an automatic  finalizer
  function/routine that cleans up the memory that is used
  by the native object.
  This is the case, for example, for an XMLInternalDocument.
  We cannot free it with a finalizer in all cases as we may have
  a reference to a node in the associated document tree.
  So the user must explicitly release the XMLInternalDocument object
  to free the memory it occupies.
}
\usage{
free(obj)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{ the object whose memory is to be released,
     typically an external pointer object or object
  that contains a slot that is an external pointer.  }
}
\details{
  The methods will generally call a C routine to free the native
  memory.
}
\value{
  An updated version of the object with the external address set to NIL.
 This is up to the individual methods. 
}

\author{ Duncan Temple Lang}
\seealso{
\code{\link{xmlTreeParse}} with \code{useInternalNodes = TRUE} 
}
\examples{
 f = system.file("exampleData", "boxplot.svg", package = "XML")
 doc = xmlParse(f)
 nodes = getNodeSet(doc, "//path")
 rm(nodes)
 # free(doc)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{IO}
\concept{external memory}
