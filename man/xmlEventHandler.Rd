\name{xmlEventHandler}
\alias{xmlEventHandler}
\title{Default handlers for the SAX-style event XML parser}
\description{
 This is a function that returns a closure instance 
 containing the default handlers for use with 
 \code{\link{xmlEventParse}} for parsing XML documents
 via the SAX-style parsing.
}
\usage{
xmlEventHandler()
}
\details{
 These handlers simply build up the DOM tree and thus 
 perform the same job as \code{xmlTreeParse}.
 It is here more as an example, reference and a base
 that users can extend.
}
\value{
The return value is a list of functions
which are used as callbacks by the internal XML parser
when it encounters certain XML elements/structures.
These include items such as the start of an element,
end of an element, processing instruction, 
text node, comment, entity references and definitions, etc.

  \item{startElement}{}
  \item{endElement}{}
  \item{processingInstruction}{}
  \item{text}{}
  \item{comment}{}
  \item{externalEntity}{}
  \item{entityDeclaration}{}
  \item{cdata}{}
  \item{dom}{}
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }

\seealso{
\code{\link{xmlEventParse}}
\code{\link{xmlTreeParse}}
}

\examples{
 xmlEventParse(system.file("exampleData", "mtcars.xml", package="XML"),
               handlers=xmlEventHandler())
}
\keyword{file}
\keyword{IO}
