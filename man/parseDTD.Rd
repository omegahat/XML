\name{parseDTD}
\alias{parseDTD}
\title{Read a Document Type Definition (DTD)}
\description{
 Represents the contents of a DTD as a user-level object containing the element and entity definitions.
}
\usage{
parseDTD(extId, asText=FALSE, name="", isURL=FALSE, error = xmlErrorCumulator())
}
\arguments{
 \item{extId}{The name of the file containing the DTD to be processed.}
 \item{asText}{logical indicating whether the value of `extId' is the name of a file
or the DTD content itself. Use this when the DTD is read as a character vector, before being parsed 
and handed to the parser as content only.}
 \item{name}{Optional name to provide to the parsing mechanism.}
 \item{isURL}{A logical value indicating whether the input source is to be
  considred a URL or a regular file or string containing the XML.}
 \item{error}{an R function that is called when an error is
 encountered. This can report it and continue or terminate by raising
 an error in R.  See the error parameter for \code{link{xmlTreeParse}}.}
}
\details{
 Parses and converts the contents of the DTD in the specified file 
into a user-level object containing all the information about the DTD.
}
\value{
 A list with two entries, one for the entities and the other for the elements
defined within the DTD.
  \item{entities}{a named list of the entities defined in the DTD. 
Each entry is indexed by the name of the corresponding entity.
Each is an object of class \code{XMLEntity}
or alternatively \code{XMLExternalEntity} if the entity refers
to an external definition.
The fields of these types of objects are 
\itemize{
 \item{name}{the name of the entity by which users refer to it.}
 \item{content}{the expanded value or definition of the entity}
 \item{original}{the value of the entity, but with references to other entities not expanded, but
    maintained in symbolic form.}
 }
}
\item{elements}{a named list of the elements defined in the DTD, with the name of each element being
the identifier of the element being defined.
Each entry is an object of class \code{XMLElementDef}
which has 4 fields.
\itemize{
 \item{name}{the name of the element.}
 \item{type}{a named integer indicating the type of entry in the DTD, usually
either \code{element} or \code{mixed}.
The name of the value is a user-level type. The value is used for programming, both
internally and externally.
}
 \item{contents}{a description of the elements that can be nested within this element.
This is an object of class \code{XMLElementContent}
or one of its specializations - \code{XMLSequenceContent}, \code{XMLOrContent}.
Each of these encodes the number of such elements permitted 
(one, one or more, zero or one, or zero or more);
the type indicating whether the contents consist of a single element type,
an ordered sequence of elements, or one of a set of elements.
Finally, the actual contents description is described in the
\code{elements} field. This is a list of
one or more \code{XMLElementContent}, \code{XMLSequenceContent} and \code{XMLOrContent} 
objects.
}
 \item{attributes}{a named list of the attributes defined for this element in the DTD.
 Each element is of class \code{XMLAttributeDef} which has 4 fields.
  \item{name}{name of the attribute, i.e. the left hand side}
  \item{type}{the type of the value, e.g. an CDATA, Id, Idref(s), Entity(s), NMToken(s),  Enumeration, Notation}
  \item{defaultType}{the defined type, one of  None, Implied, Fixed or Required.}
  \item{defaultValue}{the default value if it is specified, or the enumerated values as a character vector, if the type is Enumeration.}
}
}
}
}
\references{ \url{http://www.w3.org} }
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}
\note{Needs libxml (currently version 1.8.7) from \url{}}

\section{WARNING}{Errors in the DTD are stored as warnings for programmatic access.} 

\seealso{\code{\link{xmlTreeParse}}, 
 WritingXML.html in the distribution.}

\examples{
 dtdFile <- system.file("exampleData", "foo.dtd",package="XML")
 parseDTD(dtdFile)

txt <- readLines(dtdFile)
txt <- paste(txt,  collapse="\n")
d <- parseDTD(txt, asText=TRUE)


\dontrun{
 url <- "http://www.omegahat.org/XML/DTDs/DatasetByRecord.dtd"
 d <- parseDTD(url, asText=FALSE)  
}
}
\keyword{file}
\keyword{IO}
