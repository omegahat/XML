\name{startElement.SAX}
\alias{startElement.SAX}
\alias{endElement.SAX}
\alias{text.SAX}
\alias{comment.SAX}
\alias{processingInstruction.SAX}
\alias{entityDeclaration.SAX}
\alias{.InitSAXMethods}
\alias{text.SAX,ANY,SAXState-method}
\alias{comment.SAX,ANY,SAXState-method}
\alias{endElement.SAX,ANY,SAXState-method}
\alias{startElement.SAX,ANY,ANY,SAXState-method}
\alias{processingInstruction.SAX,ANY,ANY,SAXState-method}
\alias{entityDeclaration.SAX,ANY,ANY,ANY,ANY,ANY,SAXState-method}
\title{Generic Methods for SAX callbacks}
\description{
  This is a collection of generic functions
  for which one can write methods
  so that they are called in repsonse to
  different SAX events.
  The idea is that one defines methods for different
  classes of the \code{.state} argument
  and dispatch to different methods based on that
  argument.
  The functions represent the different SAX events.
}
\usage{
startElement.SAX(name, atts, .state = NULL)
endElement.SAX(name, .state = NULL)
comment.SAX(content, .state = NULL)
processingInstruction.SAX(target, content, .state = NULL)
text.SAX(content, .state = NULL)
entityDeclaration.SAX(name, base, sysId, publicId, notationName,  .state = NULL)
.InitSAXMethods(where = "package:XML")
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{name}{the name of the XML element or entity being declared}
  \item{atts}{named character vector of XML attributes}
  \item{content}{the value/string in the processing instruction or comment}
  \item{target}{the target of the processing instruction, e.g. the R in
    \code{<?R....>}}
  \item{base}{x}
  \item{sysId}{the system identifier for this entity}
  \item{publicId}{the public identifier for the entity}
  \item{notationName}{name of the notation specification}
  \item{.state}{the state object on which the user-defined methods
    should dispatch.}
  \item{where}{the package in which the class and method definitions
    should be defined. This is almost always unspecified.}
  
}
\value{
  Each method should return the (potentially modified)
  state value.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.xmlsoft.org}}
\author{Duncan Temple Lang}
\note{ This no longer requires the Expat XML parser to be installed.
Instead, we use libxml's SAX parser.}

\seealso{
\code{\link{xmlEventParse}}
}

%\examples{}
\keyword{file}

