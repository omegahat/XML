\name{Doctype-class}
\docType{class}
\alias{Doctype-class}

\title{Class to describe a reference to an XML DTD}
\description{This class is intended to identify a DTD by SYSTEM file and/or PUBLIC 
  catalog identifier.  This is used in the DOCTYPE element of an XML document.}
\section{Objects from the Class}{
  Objects can be created by calls to the constructor function \code{\link{Doctype}}.
}
\section{Slots}{
  \describe{
    \item{\code{name}:}{Object of class \code{"character"}. This is the name of the 
      top-level element in the XML document.}
    \item{\code{system}:}{Object of class \code{"character"}. This is the name of the file on the
       system where the DTD document can be found. Can this be a URI?}
    \item{\code{public}:}{Object of class \code{"character"}. This gives the PUBLIC 
    identifier for the DTD that can be searched for in a catalog, for example to map the
    DTD reference to a local system element.}
  }
}
\section{Methods}{
  There is a constructor function
  and also methods for \code{\link[methods]{coerce}} to convert an object
  of this class to a character.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.xmlsoft.org}}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{Doctype}}
 \code{\link{saveXML}}
}
\examples{
  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN", "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd"))  
}
\keyword{classes}
