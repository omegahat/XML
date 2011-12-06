\name{[.XMLNode}
\alias{[.XMLNode}
\alias{[[.XMLNode}
\alias{[[.XMLInternalElementNode}
\alias{[[.XMLDocumentContent}
\title{Convenience accessors for the children of XMLNode objects.}
\description{
 These provide a simplified syntax for extracting the children
of an XML node.
}
\usage{
\method{[}{XMLNode}(x, ..., all = FALSE)
\method{[[}{XMLNode}(x, ...)
\method{[[}{XMLDocumentContent}(x, ...)
}
\arguments{
  \item{x}{the XML node or the top-level document content in which the children are to be accessed.
  The \code{XMLDocumentContent} is the container for the top-level node that also contains information
  such as the URI/filename and XML version. This accessor method is merely a convenience to get 
  access to children of the top-level node.}
% \item{i}{index of the child of interest or the name of an XML element
%   of interest. In this latter case, only the first matching element is
%   returned, if any.}
  \item{\dots}{the identifiers for the children to be retrieved,
given as integer indices, names, etc. in the usual format for the
generic \code{link{[}} and \code{link{[[}} operators}
  \item{all}{logical value.  When \dots is a character vector, a value
    of \code{TRUE} for \code{all} means to retrieve all of the
    nodes with those names rather than just the first one.
    \code{FALSE} gives the usual result of subsetting a list by name
    which gives just the first element.
    This allows us to avoid the  idiom
       \code{node[ names(node) == "bob" ]}
       which is complicated when node is the result of an inline
       computation
       and instead we use
       \code{node["bob", all = TRUE]}.
  }
}
\value{
 A list or single element containing the
children of the XML node given by \code{obj}
and identified by \dots.
}
\references{\url{http://www.w3.org/XML}, \url{http://www.omegahat.org/RSXML}}
\author{Duncan Temple Lang}


\seealso{
 \code{\link{xmlAttrs}}
 \code{\link{[<-.XMLNode}}
 \code{\link{[[<-.XMLNode}}
}

\examples{

 f = system.file("exampleData", "gnumeric.xml", package = "XML")

 top = xmlRoot(xmlTreeParse(f))

  # Get the first RowInfo element.
 top[["Sheets"]][[1]][["Rows"]][["RowInfo"]]

  # Get a list containing only the first row element
 top[["Sheets"]][[1]][["Rows"]]["RowInfo"]
 top[["Sheets"]][[1]][["Rows"]][1]

  # Get all of the RowInfo elements by position
 top[["Sheets"]][[1]][["Rows"]][1:xmlSize(top[["Sheets"]][[1]][["Rows"]])]

  # But more succinctly and accurately, get all of the RowInfo elements
 top[["Sheets"]][[1]][["Rows"]]["RowInfo", all = TRUE]

}
\keyword{IO}
\keyword{file}

