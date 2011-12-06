\name{xmlAttributeType}
\alias{xmlAttributeType}
\title{The type of an XML attribute for element from the DTD}
\description{
This examines the definition of the 
attribute, usually returned by parsing the DTD with
\code{\link{parseDTD}} and determines 
its type from the possible values:
Fixed, string data, implied, 
required,  an identifier, 
an identifier reference, a list of identifier references,
an entity, a list of entities, 
a name, a list of names, an element of enumerated set, 
a notation entity.
}
\usage{
xmlAttributeType(def, defaultType=FALSE)
}
\arguments{
  \item{def}{the attribute definition object, usually retrieved from
the DTD via \code{\link{parseDTD}}.}
  \item{defaultType}{whether to return the default value
if this attribute is defined as being a value from an enumerated set.}
}
\value{
  A string identifying the type for the sspecified attributed.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.omegahat.org/RSXML}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{parseDTD}}
}


\keyword{file}

