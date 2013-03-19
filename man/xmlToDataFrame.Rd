\name{xmlToDataFrame}
\alias{xmlToDataFrame}
\alias{xmlToDataFrame,character,ANY,ANY,ANY,ANY-method}
\alias{xmlToDataFrame,XMLInternalDocument,ANY,ANY,ANY,missing-method}
\alias{xmlToDataFrame,ANY,ANY,ANY,ANY,XMLNodeSet-method}
\alias{xmlToDataFrame,ANY,ANY,ANY,ANY,XMLInternalNodeList-method}
\alias{xmlToDataFrame,ANY,ANY,ANY,ANY,list-method}
\alias{xmlToDataFrame,XMLInternalNodeList,ANY,ANY,ANY,ANY-method}
\alias{xmlToDataFrame,XMLInternalElementNode,ANY,ANY,ANY,ANY-method}
\alias{xmlToDataFrame,XMLNodeSet,ANY,ANY,ANY,ANY-method}
\alias{xmlToDataFrame,list,ANY,ANY,ANY,ANY-method}
\title{Extract data from a simple XML document}
\description{
  This function can be used to extract data from
  an XML document (or sub-document) that has a simple, shallow structure
  that does appear reasonably commonly.
  The idea is that there is a collection of nodes which have
  the same fields (or a subset of common fields)
  which contain primitive values, i.e. numbers, strings, etc.
  Each node corresponds to an "observation" and each of its
  sub-elements correspond to a variable.
  This function then builds the corresponding data frame,
  using the union of the variables in the different observation nodes.
  This can handle the case where the nodes do not all have all of the variables.
}
\usage{
xmlToDataFrame(doc, colClasses = NULL, homogeneous = NA,
               collectNames = TRUE, nodes = list(),
               stringsAsFactors = default.stringsAsFactors())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{doc}{the XML content. This can be the name of a file containing
    the XML, the parsed XML document. If one wants to work on a subset
    of nodes, specify these via the \code{nodes} parameter.}
  \item{colClasses}{a list/vector giving the names of the R types for the
    corresponding variables and this is used to coerce the resulting
    column in the data frame to this type. These can be named. This is similar to
    the \code{colClasses} parameter for \code{\link[utils]{read.table}}.
    If this is given as a list, columns in the data frame
    corresponding to elements that are \code{NULL} are omitted from the
    answer.
    This can be slightly complex to specify if the
    different nodes have the "variables" in quite different order
    as there is not a well defined order for the variables
    corresponding to \code{colClasses}.
   }
  \item{homogeneous}{a logical value that indicates whether each of the
    nodes contains all of the variables (\code{TRUE}) or if there
    may be some nodes which have only a subset of them.
    The function determines this if the caller does not specify
    \code{homogeneous} or uses \code{NA} as the value.
    It is a parameter to allow  the caller to specify this information
    and avoid these "extra" computations. If the caller knows this
    information it is more efficient to specify it.
    }
  \item{collectNames}{a logical value indicating whether we compute the
    names by explicitly computing the union of all variable names
    or, if \code{FALSE}, we use the names from the node with the most
    children.
    This latter case is useful when the caller knows that the
    there is at least one node with all the variables.
  }
  \item{nodes}{a list of XML nodes which are to be processed}
  \item{stringsAsFactors}{a logical value that controls whether
    character vectors are converted to factor objects in the resulting
    data frame.}
}

\value{
 A data frame.
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{xmlParse}}
  \code{\link{getNodeSet}}  
}
\examples{
 f = system.file("exampleData", "size.xml", package = "XML")
 xmlToDataFrame(f, c("integer", "integer", "numeric"))

   # Drop the middle variable.
 z = xmlToDataFrame(f, colClasses = list("integer", NULL, "numeric"))


   #  This illustrates how we can get a subset of nodes and process
   #  those as the "data nodes", ignoring the others.
  f = system.file("exampleData", "tides.xml", package = "XML")
  doc = xmlParse(f)
  xmlToDataFrame(nodes = xmlChildren(xmlRoot(doc)[["data"]]))

    # or, alternatively
  xmlToDataFrame(nodes = getNodeSet(doc, "//data/item"))


  f = system.file("exampleData", "kiva_lender.xml", package = "XML")
  doc = xmlParse(f)
  dd = xmlToDataFrame(getNodeSet(doc, "//lender"))
}
\keyword{IO}
