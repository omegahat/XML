\name{append.xmlNode}
\alias{append.xmlNode}
\alias{append.XMLNode}
\title{Add children to an XML node}
\description{
 This appends one or more XML nodes as children of an existing node.
}
\usage{
append.XMLNode(to, ...)
append.xmlNode(to, ...)
}
\arguments{
  \item{to}{the XML node to which the sub-nodes are to be added.}
  \item{\dots}{the sub-nodes which are to be added to the \code{to} node.
   If this is a \code{list} of \code{XMLNode} objects (e.g. create by a call to 
   \code{\link{lapply}}), then that list is used.}
}
\value{
 The original \code{to} node containing its new children nodes.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml},
\url{http://www.omegahat.org}  }
\author{ Duncan Temple Lang }


\seealso{
\code{\link{[<-.XMLNode}}
\code{\link{[[<-.XMLNode}}
\code{\link{[.XMLNode}}
\code{\link{[[.XMLNode}}
}

\examples{
  # Create a very simple representation of a simple dataset.
  # This is just an example. The result is
   # <data numVars="2" numRecords="3">
   # <varNames>
   #  <string>
   #   A
   #  </string>
   #  <string>
   #   B
   #  </string>
   # </varNames>
   # <record>
   #  1.2 3.5
   # </record>
   # <record>
   #  20.2 13.9
   # </record>
   # <record>
   #  10.1 5.67
   # </record>
   # </data>


 n = xmlNode("data", attrs = c("numVars" = 2, numRecords = 3))
 n = append.xmlNode(n, xmlNode("varNames", xmlNode("string", "A"), xmlNode("string", "B")))
 n = append.xmlNode(n, xmlNode("record", "1.2 3.5"))
 n = append.xmlNode(n, xmlNode("record", "20.2 13.9"))
 n = append.xmlNode(n, xmlNode("record", "10.1 5.67"))

 print(n)


\dontrun{
   tmp <-  lapply(references, function(i) {
                                  if(!inherits(i, "XMLNode"))
                                    i <- xmlNode("reference", i)
                                  i
                              })

   r <- xmlNode("references")
   r[["references"]] <- append.xmlNode(r[["references"]], tmp)
}
}
\keyword{file}
\keyword{IO}
