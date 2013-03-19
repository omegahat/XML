\name{readSolrDoc}
\alias{readSolrDoc}
\alias{readSolrDoc,XMLInternalDocument-method}
\alias{readSolrDoc,XMLInternalNode-method}
\alias{readSolrDoc,character-method}
\alias{readSolrDoc,AsIs-method}

\title{Read the data from a Solr document}
\description{
  Solr documents are used to represent
  general data in a reasonably simple format
  made up of lists, integers, logicals, longs,
  doubles, dates, etc. each with an optional name.
  These correspond very naturally to R objects.
}
\usage{
readSolrDoc(doc, ...)
}
\arguments{
  \item{doc}{the object containing the data. This can be the name of a
    file, a parsed XML document or an XML node.}
  \item{\dots}{additional parameters for the methods.}
}
\value{
  An R object representing the data in the Solr document,
  typically a named vector or named list.
}
\references{
  Lucene text search system.
}
\author{
Duncan Temple Lang
}


\seealso{
  \code{\link{readKeyValueDB}},
    \code{\link{xmlToList}},
  \code{\link{xmlToDataFrame}},
  \code{\link{xmlParse}}
}
\examples{
f = system.file("exampleData", "solr.xml", package = "XML")
readSolrDoc(f)
}
\keyword{IO}
\concept{Solr}
