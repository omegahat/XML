\name{xmlParserContextFunction}
\alias{xmlParserContextFunction}
\title{Identifies function as expecting an xmlParserContext argument}
\description{
 This is a convenience function for setting the class of the
specified function to include \code{"XMLParserContextFunction"}.
This identifies it as expecting an 
\code{xmlParserCtxt} object as its first argument.
The resulting function can be passed to the
internal/native XML parser as a handler/callback function.
When the parser calls it, it recognizes this class information
and includes a reference to the C-level \code{xmlParserCtxt} 
object as the first argument in the call.

This \code{xmlParserCtxt} object can be used to gracefully
terminate the parsing (without an error), 
and in the future will also provide access to details
about the current state of the parser,
e.g. the encoding of the file, the XML version, 
whether entities are being replaced, 
line and column number for each node processed.
}
\usage{
 xmlParserContextFunction(f, class = "XMLParserContextFunction")
}
\arguments{
  \item{f}{the function whose class information is to be augmented.}
  \item{class}{the name of the class which is to be added to the \code{class}
    attribute of the function.}
}
\value{
 The function object \code{f} whose class attribute has been prepended
  with the value of \code{class}.
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{xmlInternalTreeParse}}/\code{\link{xmlParse}}
and the \code{branches} parameter of  \code{\link{xmlEventParse}}.
}
\examples{

  fun = function(context, ...) {
             # do things to parse the node
             # using the context if necessary.
           cat("In XMLParserContextFunction\n")
           xmlStopParser(context)
         }
  fun = xmlParserContextFunction(fun)

  txt = "<doc><a/></doc>"
  # doesn't work for xmlTreeParse()
  #   xmlTreeParse(txt, handlers = list(a = fun))

  #  but does in xmlEventParse().
  xmlEventParse(txt, handlers = list(startElement = fun), asText = TRUE)

}
\keyword{IO}
\keyword{programming}
\concept{XML}

