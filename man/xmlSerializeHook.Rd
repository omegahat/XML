\name{xmlSerializeHook}
\alias{xmlSerializeHook}
\alias{xmlDeserializeHook}
\title{Functions that help serialize and deserialize XML internal objects}
\description{
  These functions can be used to control
  how the C-level data structures associated with XML documents, nodes,
  XPath queries, etc. are serialized to a a file or connection
  and deserialized back into an R session.
  Since these C-level data structures are represented
  in R as external pointers, they would normally be serialized
  and deserialized in a way that loses all the information about
  the contents of the memory being referenced.
  \code{xmlSerializeHook} arranges to serialize these pointers
  by saving the corresponding XML content as a string
  and also the class of the object.
  The deserialize function converts such objects back to their
  original form.

  These functions are used in calls to \code{\link[base]{saveRDS}}
  and \code{\link[base]{readRDS}} via the
  \code{refhook} argument.
\code{
saveRDS(obj, filename, refhook = xmlSerializeHook)
readRDS(filename, refhook = xmlDeserializeHook)
}  
}
\usage{
xmlSerializeHook(x)
xmlDeserializeHook(x)
}
\arguments{
  \item{x}{the object to be deserialized, and the character vector to be
   deserialized.}
}
\value{
  \code{xmlSerializeHook} returns a character version of the XML
  document or node, along with the basic class.
  If it is called with an object that is not an native/internal XML
  object, it returns \code{NULL}

  \code{xmlDeserializeHook} returns the parsed XML object, either a
  document or a node.
}
\references{
 The R Internals Manual.
}
\author{
Duncan Temple Lang
}

\seealso{
\code{\link[base]{saveRDS}}  and \code{\link[base]{readRDS}}
}
\examples{
z = newXMLNode("foo")
f = system.file("exampleData", "tides.xml", package = "XML")
doc = xmlParse(f)
hdoc = as(doc, "XMLHashTree")

nodes = getNodeSet(doc, "//pred")

saveRDS(list(a = 1:10, z = z, doc = doc, hdoc = hdoc, nodes = nodes), "tmp.rda",
          refhook = xmlSerializeHook)

v = readRDS("tmp.rda", refhook = xmlDeserializeHook)
}
\keyword{IO}

