\name{XMLAttributes-class}
\Rdversion{1.1}
\docType{class}
\alias{XMLAttributes-class}
\alias{[,XMLAttributes-method}
\alias{show,XMLAttributes-method}

\title{Class \code{"XMLAttributes"}}
\description{A simple class to represent a named character vector of XML
  attributes some of which may have a namespace.
This maintains the name space}
\section{Objects from the Class}{
Objects can be created by calls of the form \code{new("XMLAttributes", ...)}.
These are typically generated via a call to \code{\link{xmlAttrs}}.
}
\section{Slots}{
  \describe{
    \item{\code{.Data}:}{Object of class \code{"character"}}
  }
}
\section{Extends}{
Class \code{"\linkS4class{character}"}, from data part.
Class \code{"\linkS4class{vector}"}, by class "character", distance 2.
Class \code{"\linkS4class{data.frameRowLabels}"}, by class "character", distance 2.
Class \code{"\linkS4class{SuperClassMethod}"}, by class "character", distance 2.
}
\section{Methods}{
  \describe{
    \item{[}{\code{signature(x = "XMLAttributes")}: ... }
    \item{show}{\code{signature(object = "XMLAttributes")}: ... }
	 }
}
\author{
Duncan Temple Lang
}

\seealso{
  \code{\link{xmlAttrs}}
  \code{\link{newXMLNode}}
  \code{\link{xmlParse}}  
}
\examples{
  nn = newXMLNode("foo", attrs = c(a = "123", 'r:show' = "true"),
                   namespaceDefinitions = c(r = "http://www.r-project.org"))
  a = xmlAttrs(nn)
  a["show"]
}
\keyword{classes}
