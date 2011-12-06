\name{print.XMLAttributeDef}
\alias{print.XMLAttributeDef}
\alias{print.XMLCDataNode}
\alias{print.XMLElementContent}
\alias{print.XMLElementDef}
\alias{print.XMLEntity}
\alias{print.XMLEntityRef}
\alias{print.XMLNode}
\alias{print.XMLTextNode}
\alias{print.XMLComment}
\alias{print.XMLOrContent}
\alias{print.XMLSequenceContent}
\alias{print.XMLProcessingInstruction}
\title{Methods for displaying XML objects}
\description{
 These different methods attempt to provide a convenient
way to display R objects representing XML elements
when they are printed in the usual manner on
the console, files, etc. via the \code{\link{print}}
function.
Each typically outputs its contents in the way
that they would appear in an XML document.
}
\usage{
\method{print}{XMLNode}(x, ..., indent= "", tagSeparator = "\n")
\method{print}{XMLComment}(x, ..., indent = "", tagSeparator = "\n")
\method{print}{XMLTextNode}(x, ..., indent = "", tagSeparator = "\n")
\method{print}{XMLCDataNode}(x, ..., indent="", tagSeparator = "\n")
\method{print}{XMLProcessingInstruction}(x, ..., indent="", tagSeparator = "\n")
\method{print}{XMLAttributeDef}(x, ...)
\method{print}{XMLElementContent}(x, ...)
\method{print}{XMLElementDef}(x, ...)
\method{print}{XMLEntity}(x, ...)
\method{print}{XMLEntityRef}(x, ..., indent= "", tagSeparator = "\n")
\method{print}{XMLOrContent}(x, ...)
\method{print}{XMLSequenceContent}(x, ...)
}
\arguments{
  \item{x}{the XML object to be displayed}
  \item{...}{additional arguments for controlling the output from
  print. Currently unused.}
  \item{indent}{a prefix that is emitted before the node to indent it relative to its
    parent and child nodes. This is appended with a space at each
    succesive level of the tree.
    If no indentation is desired (e.g. when \code{\link{xmlTreeParse}}
    is called with \code{trim} and \code{ignoreBlanks}
    being \code{FALSE}) and \code{TRUE} respectively,
    one can pass the value \code{FALSE} for this \code{indent} argument.
  }
  \item{tagSeparator}{when printing nodes, successive nodes and children
    are by default displayed on new lines for easier reading.
    One can specify a string for this argument to control how the
    elements are separated in the output.  The primary purpose of this
    argument is to allow no space between the elements, i.e. a value of \code{""}.
  }
}
\value{
 Currently, \code{NULL}.
}
\references{\url{http://www.w3.org}, \url{http://www.omegahat.org/RSXML}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{xmlTreeParse}}
}
\note{We could make the node classes self describing with information
  about whether \code{ignoreBlanks} was \code{TRUE} or \code{FALSE} and
  if trim was TRUE or FALSE.
  This could then be used to determine the appropriate values for
  \code{indent} and \code{tagSeparator}. Adding an S3 class element
  would allow this to be done without the addition of an excessive
  number of classes.
}
\examples{
  fileName <- system.file("exampleData", "event.xml", package ="XML")

     # Example of how to get faithful copy of the XML.
  doc = xmlRoot(xmlTreeParse(fileName, trim = FALSE, ignoreBlanks = FALSE))
  print(doc, indent = FALSE, tagSeparator = "")

     # And now the default mechanism
  doc = xmlRoot(xmlTreeParse(fileName))
  print(doc)
}
\keyword{IO}
\keyword{file}

