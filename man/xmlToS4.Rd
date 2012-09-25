\name{xmlToS4}
\alias{xmlToS4}
\alias{xmlToS4,XMLInternalNode-method}

\title{General mechanism for mapping an XML node to an S4 object}
\description{
  This generic function  and its methods recursively process
  an XML node and its child nodes ( and theirs and so on)
  to map the nodes to S4 objects.

  This is the run-time function that corresponds to the
  \code{\link{makeClassTemplate}} function.
}
\usage{
xmlToS4(node, obj = new(xmlName(node)), ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{node}{the top-level XML node to convert to an S4 object}
  \item{obj}{the object whose slots are to be filled from the
  information in the XML node}
  \item{\dots}{additional parameters for methods}
}
\value{
 The object \code{obj} whose slots have been modified.
}

\author{Duncan Temple Lang}

\seealso{
 \code{\link{makeClassTemplate}}  
}
\examples{
 txt =
 "<doc><part><name>ABC</name><type>XYZ</type><cost>3.54</cost><status>available</status></part></doc>"
 doc = xmlParse(txt)

 setClass("part", representation(name = "character",
                                 type = "character",
                                 cost = "numeric",
                                 status= "character"))
 xmlToS4(xmlRoot(doc)[["part"]])
}
\keyword{programming}
\keyword{IO}
\concept{meta-computing}

