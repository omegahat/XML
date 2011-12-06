\name{SAXState-class}
\docType{class}
\alias{SAXState-class}
\title{A virtual base class defining methods for SAX parsing}
\description{
  This is a degenerate virtual class which others are
  expected to sub-class  when they want to
  use S4 methods as handler functions for SAX-based XML parsing.
  The idea is that one can pass both i)  a collection of handlers
  to \code{\link{xmlEventParse}} which are simply 
  the generic functions for the different SAX actions,
  and ii) a suitable object to maintain state across
  the different SAX calls.
  This is used to perform the method dispatching to get
  the appropriate behavior for the action.
  Each of these methods is expected to return the
  updated state object and the SAX parser
  will pass this in the next callback.

  We define this class here so that we can provide
  default methods for each of the different handler
  actions. This allows other programmers to define
  new classes to maintain state that are sub-class
  of \code{SAXState} and then they do not have to
  implement methods for each of the
  different handlers.
}  
\section{Objects from the Class}{A virtual Class: No objects may be created from it.}


\section{Methods}{
  \describe{
    \item{comment.SAX}{\code{signature(content = "ANY", .state = "SAXState")}: ... }
    \item{endElement.SAX}{\code{signature(name = "ANY", .state = "SAXState")}: ... }
    \item{entityDeclaration.SAX}{\code{signature(name = "ANY", base = "ANY", sysId = "ANY", publicId = "ANY", notationName = "ANY", .state = "SAXState")}: ... }
    \item{processingInstruction.SAX}{\code{signature(target = "ANY", content = "ANY", .state = "SAXState")}: ... }
    \item{startElement.SAX}{\code{signature(name = "ANY", atts = "ANY", .state = "SAXState")}: ... }
    \item{text.SAX}{\code{signature(content = "ANY", .state = "SAXState")}: ... }
  }
}

\references{\url{http://www.w3.org/XML}, \url{http://www.xmlsoft.org}}
\author{Duncan Temple Lang}


\seealso{
 \code{\link{xmlEventParse}}
}

\examples{

# For each element in the document, grab the node name
# and increment the count in an vector for this name.

# We define an S4 class named ElementNameCounter which
# holds the vector of frequency counts for the node names.

 setClass("ElementNameCounter",
             representation(elements = "integer"), contains = "SAXState")

# Define a method for handling the opening/start of any XML node
# in the SAX streams.

 setMethod("startElement.SAX",  c(.state = "ElementNameCounter"),
           function(name, atts, .state = NULL) {

             if(name \%in\% names(.state@elements))
                 .state@elements[name] = as.integer(.state@elements[name] + 1)
             else
                 .state@elements[name] = as.integer(1)
             .state
           })

 filename = system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML")

# Parse the file, arranging to have our startElement.SAX method invoked.
 z = xmlEventParse(filename, genericSAXHandlers(), state = new("ElementNameCounter"), addContext = FALSE)

 z@elements

  # Get the contents of all the comments in a character vector.

 setClass("MySAXState",
             representation(comments = "character"), contains = "SAXState")

 setMethod("comment.SAX",  c(.state = "MySAXState"),
           function(content, .state = NULL) {
             cat("comment.SAX called for MySAXState\n")
             .state@comments <- c(.state@comments, content)
             .state
           })

 filename = system.file("exampleData", "charts.svg", package = "XML")
 st = new("MySAXState")
 z = xmlEventParse(filename, genericSAXHandlers(useDotNames = TRUE), state = st)
 z@comments


}
\keyword{classes}
