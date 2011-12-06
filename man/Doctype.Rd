\name{Doctype}
\alias{Doctype}
\alias{coerce,Doctype,character-method}
\title{Constructor for DTD reference}
\description{
  This is a constructor for the \code{Doctype} class
  that can be provided at the top of an XML document
  to provide information about the class of document,
  i.e. its DTD or schema.
  Also, there is a method for converting such a \code{Doctype}
  object to a character string.
}
\usage{
Doctype(system = character(), public = character(), name = "")
}
\arguments{
  \item{system}{the system URI that locates the DTD. }
  \item{public}{the identifier for locating the DTD in a catalog, for
    example. This should be a character vector of length 2, giving
    the public identifier and a URI.  If just the public identifier
    is given and a string is given for \code{system} argument,
    the \code{system} value is used as the second element of
    \code{public}.
    The public identifer should be of the form
    \code{+//creator//name//language}
    where the first element is either + or -, and
    the language is described by a code in the ISO 639 document.
  }
  \item{name}{the name of the root element in the document.
    This should be the first parameter, but is left this way
  for backward compatability.  And }
}
\value{
 An object of class \code{Doctype}.
}
\references{\url{http://www.w3.org/XML}
 XML Elements of Style, Simon St. Laurent.
}
\author{ Duncan Temple Lang }


\seealso{
 \code{\link{saveXML}}
}
\examples{

  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN", "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd"))
  as(d, "character")

   # this call switches the system to the URI associated with the PUBLIC element.
  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN"), system = "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd")
}
\keyword{IO}

