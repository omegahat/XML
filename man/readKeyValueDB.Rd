\name{readKeyValueDB}
\alias{readKeyValueDB}
\alias{readKeyValueDB,character-method}
\alias{readKeyValueDB,XMLInternalDocument-method}
\alias{readKeyValueDB,XMLInternalNode-method}
\alias{readKeyValueDB,AsIs-method}

\title{Read an XML property-list style document}
\description{
  This function and its methods reads an XML document
  that is in the format of name-value or key-value
  pairs made up of a \code{plist} and
  \code{dict} nodes, each of which is made up \code{key}, and value node
  pairs.  These used to be used for property lists on OS X and
  can represetn arbitrary data relatively conveniently.
}
\usage{
readKeyValueDB(doc, ...)
}
\arguments{
  \item{doc}{the object containing the data. This can be the name of a
    file, a parsed XML document or an XML node.}
  \item{\dots}{additional parameters for the methods.
    One can pass \code{dropComments} as a logical value to control
    whether comment nodes are processed or ignored (\code{TRUE}).
  }
}
\value{
  An R object representing the data read from the XML content.
  This is typically a named list or vector where the names are the keys
  and the values are collected into an R "container".
}
\references{
  Property lists.
}
\author{
Duncan Temple Lang
}
\seealso{
  \code{\link{readSolrDoc}},
  \code{\link{xmlToList}},
  \code{\link{xmlToDataFrame}},
  \code{\link{xmlParse}}
}
\examples{
 if(file.exists("/usr/share/hiutil/Stopwords.plist")) {
  o = readKeyValueDB("/usr/share/hiutil/Stopwords.plist")
 }

 if(file.exists("/usr/share/java/Tools/Applet Launcher.app/Contents/Info.plist"))
    javaInfo = readKeyValueDB('/usr/share/java/Tools/Applet Launcher.app/Contents/Info.plist')
}
\keyword{IO}
\concept{XML}

