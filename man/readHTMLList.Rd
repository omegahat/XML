\name{readHTMLList}
\alias{readHTMLList}
\alias{readHTMLList,HTMLInternalDocument-method}
\alias{readHTMLList,XMLInternalNode-method}
\alias{readHTMLList,character-method}
\title{Read data in an HTML list or all lists in a document}
\description{
  This function and its methods are somewhat similar to
  \code{\link{readHTMLTable}} but read the contents of
  lists in an HTML document.
  We can specify the URL of the document or
  an already parsed document or an individual node within the document.
}
\usage{
readHTMLList(doc, trim = TRUE, elFun = xmlValue, which = integer(), ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{doc}{the URL of the document or the parsed HTML document
    or an individual node.}
  \item{trim}{a logical value indicating whether we should
   remove leading and trailing white space in each list item when
   returning it}
  \item{elFun}{a function that is used to process each list item node
    (\code{li}).
   This provides an opportunity to customize how each node is processed,
   for example accessing attributes on the list item or on its contents
   such as links in the items.}
  \item{which}{an index or name which or vector of same which identifies
    which list nodes to process in the overall document. This is for
    subsetting particular lists rather than processing them all.}
  \item{\dots}{additional arguments passed to \code{\link{htmlParse}}
    and for the specific methods.}
}
\value{
  A list of character vectors or lists,
  with one element for each list in the document.
  If only one list is being read (by specifying \code{which} as a single
  identifier), that is  returned as is.
}
\author{
Duncan Temple Lang
}
\seealso{
\code{\link{readHTMLTable}}
}
\examples{
  readHTMLList("http://www.omegahat.org")
}
\keyword{IO}
\keyword{programming}

