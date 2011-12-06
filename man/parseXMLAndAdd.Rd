\name{parseXMLAndAdd}
\alias{parseXMLAndAdd}
\title{Parse XML content and add it to a node}
\description{
  This function parses the given XML content as a string
  by putting it inside a top-level node and then returns
  the document or adds the children to the specified parent.
  The motivation for this function is when we can use
  string manipulation to efficiently create the  XML content
  by using vectorized operations in R, but then
  converting that content into parsed nodes.

  Generating XML/HTML content by glueing strings together
  is a poor approach. It is often convenient, but rarely
  good general software design. It makes for bad software that is not
  very extensible and difficult to maintain and enhance.
  Structure that it is
  programmatically accessible is much better. The tree
  approach provides this structure.
  Using strings is convenient and somewhat appropriate when done
  atomically for large amounts of highly regular content.
  But then the results should be converted to the structured tree
  so that they can be modified and extended.
  This function facilitates using strings and returning structured content.
}
\usage{
parseXMLAndAdd(txt, parent = NULL, top = "tmp", nsDefs = character())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{txt}{the XML content to parse}
  \item{parent}{an XMLInternalNode to which the top-level nodes in
    \code{txt} will be added as children}
  \item{top}{the name for the top-level node. If \code{parent} is
    specified, this is used but irrelevant.}
  \item{nsDefs}{a character vector of name = value pairs giving
  namespace definitions to be added to the top node.}
}
\value{
  If \code{parent} is \code{NULL}, the root node of the
  parsed document is returned.  This will be an element
  whose name is given by \code{top} unless the XML content in \code{txt}
  is AsIs or \code{code} is empty.

  If \code{parent} is non-\code{NULL}, .
}

\author{
Duncan Temple Lang
}

\seealso{
  \code{\link{newXMLNode}}
  \code{\link{xmlParse}}  
  \code{\link{addChildren}}  
}
\examples{
  long = runif(10000, -122, -80)
  lat = runif(10000, 25, 48)

  txt = sprintf("<Placemark><Point><coordinates>\%.3f,\%.3f,0</coordinates></Point></Placemark>",
                  long, lat)
  f = newXMLNode("Folder")
  parseXMLAndAdd(txt, f)
  xmlSize(f)


\dontrun{
      # this version is much slower as i) we don't vectorize the
      #  creation of the XML nodes, and ii) the parsing of the XML
      # as a string is very fast as it is done in C.
  f = newXMLNode("Folder")
  mapply(function(a, b) {
           newXMLNode("Placemark", 
                       newXMLNode("Point", 
                                   newXMLNode("coordinates", 
                                               paste(a, b, "0", collapse = ","))), 
		       parent = f)
           },
         long, lat) 
  xmlSize(f)


  o = c("<x>dog</x>", "<omg:x>cat</omg:x>")
  node = parseXMLAndAdd(o, nsDefs  = c("http://cran.r-project.org",
                                       omg = "http://www.omegahat.org"))
  xmlNamespace(node[[1]])
  xmlNamespace(node[[2]])

  tt = newXMLNode("myTop")
  node = parseXMLAndAdd(o, tt, nsDefs  = c("http://cran.r-project.org",
                                           omg = "http://www.omegahat.org"))
  tt
}


}
\keyword{IO}

