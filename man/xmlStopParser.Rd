\name{xmlStopParser}
\alias{xmlStopParser}
\title{Terminate an XML parser}
\description{
  This function allows an R-level function to terminate an
  XML parser before it completes the processing of the XML content.
  This might be useful, for example, in event-driven parsing
  with \code{\link{xmlEventParse}}  when we want 
  to read through an XML file until we find a record of interest.
  Then, having retrieved the necessary information, we want to 
  terminate the parsing rather than let it pointlessly continue.
  Instead of raising an error in our handler function, we can call
  \code{xmlStopParser} and return. The parser will then take control
  again and terminate and return back to the original R function from
  which it was invoked. 

 The only argument to this function is a reference to internal C-level 
  which identifies the parser.   This is passed by the R-XML parser
  mechanism to a function invoked by the parser if that function
  inherits (in the S3 sense) from the class \code{XMLParserContextFunction}.
}
\usage{
xmlStopParser(parser)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{parser}{ an object of class \code{XMLParserContext}
     which must have been obtained by via an
  \code{XMLParserContextFunction} function
    called by the parser. This is just a handler function whose class
    includes \code{XMLParserContextFunction}
  }
}

\value{
   \code{TRUE} if it succeeded and an error is raised 
  if the \code{parser} object  is not valid.
}
\references{libxml2 \url{http://xmlsoft.org}}
\author{Duncan Temple Lang}

\seealso{ 
 \code{\link{xmlEventParse}}
}
\examples{

  ############################################
  # Stopping the parser mid-way and an example of using XMLParserContextFunction.

  startElement =
  function(ctxt, name, attrs, ...)  {
    print(ctxt)
      print(name)
      if(name == "rewriteURI") {
           cat("Terminating parser\n")
	   xmlStopParser(ctxt)
      }
  }
  class(startElement) = "XMLParserContextFunction"  
  endElement =
  function(name, ...) 
    cat("ending", name, "\n")

  fileName = system.file("exampleData", "catalog.xml", package = "XML")
  xmlEventParse(fileName, handlers = list(startElement = startElement, endElement = endElement))
}
\keyword{IO}
\keyword{programming}
\concept{Error handling}
\concept{streaming data}
