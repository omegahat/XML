\name{genericSAXHandlers}
\alias{genericSAXHandlers}
\title{SAX generic callback handler list}
\description{
  This is a convenience function to get the collection
  of generic functions that make up the callbacks
  for the SAX parser.
  The return value can be used directly
  as the value of the \code{handlers}
  argument in \code{\link{xmlEventParse}}.
  One can easily specify a  subset
  of the handlers by giving the names of
  the elements to include or exclude.
}
\usage{
genericSAXHandlers(include, exclude, useDotNames = FALSE)
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{include}{if supplied, this gives the names of the subset of elements to
    return.
  }
  \item{exclude}{if supplied (and \code{include} is not),
    this gives the names of the elements to remove from the list of
    functions.
  }
  \item{useDotNames}{ a logical value.
    If this is \code{TRUE}, the names of the elements in the list of
    handler functions are prefixed with '.'. This is the newer format
   used to differentiate general element handlers and node-name-specific handlers.}
}
\value{
  A list of functions.
  By default, the elements are named
  startElement, endElement, comment, text,
  processingInstruction, entityDeclaration
  and contain the corresponding
  generic SAX callback function, i.e. given by
  the element name with the .SAX suffix.

  If \code{include} or \code{exclude} is specified,
  a subset of this list is returned.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }



\seealso{
   \code{\link{xmlEventParse}}
   \code{\link{startElement.SAX}}
   \code{\link{endElement.SAX}}
   \code{\link{comment.SAX}}
   \code{\link{processingInstruction.SAX}}
   \code{\link{entityDeclaration.SAX}}
   \code{\link{.InitSAXMethods}}
}

\examples{
\testonly{
# .InitSAXMethods()
names(genericSAXHandlers())
names(genericSAXHandlers(inc=c("startElement", "endElement", "text")))
names(genericSAXHandlers(ex=c("startElement", "endElement", "text")))
}
}
\keyword{file}

