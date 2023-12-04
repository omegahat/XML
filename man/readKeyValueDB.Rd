\name{readKeyValueDB}
\alias{readKeyValueDB}
\alias{readKeyValueDB,character-method}
\alias{readKeyValueDB,XMLInternalDocument-method}
\alias{readKeyValueDB,XMLInternalNode-method}
\alias{readKeyValueDB,AsIs-method}
\title{Read an XML property-list (plist) style document}
\description{
  This function and its methods reads a property-list/plist XML document
  used on some operating systems and other places to serialize
  data.   These used to be used for property lists on OS X and
  can represent arbitrary data relatively conveniently.
  The format has a root node named \code{plist} and
  then typically an object such as a dictionary or array.
  A dictionary is a series of name-value or key-value
  pairs.
  An array is a sequence of elements.
  While the function is named readKeyValueDB, it can now
  read more generally, i.e., plist files whose
  primary element is not a \code{dict} object.
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
    Also, one can specify a value of \code{TRUE} or \code{FALSE} for
    a \code{simplify} argument. This controls whether we attempt to 
    simplify the result of \code{array} nodes to a vector (using
    \code{\link{simplify2array}}) or not.
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
  b = readKeyValueDB(system.file("examples/BoxEdit.launch.plist", package = "XML"))

  # an array not a dict as the top node in the plist.
  f = system.file("examples/array.plist", package = "XML")
  a = readKeyValueDB(f)
  a2 = readKeyValueDB(f, simplify = FALSE)

  readKeyValueDB("<plist><string>XYZ</string></plist>")

  readKeyValueDB("<plist><array><string>XYZ</string><real>3.1415</real></array></plist>")

  readKeyValueDB("<plist><array><string>XYZ</string><real>3.1415</real></array></plist>", simplify = FALSE)

  if(file.exists("/usr/share/hiutil/Stopwords.plist")) 
     o = readKeyValueDB("/usr/share/hiutil/Stopwords.plist")

  if(file.exists("/usr/share/java/Tools/Applet Launcher.app/Contents/Info.plist"))
     javaInfo = readKeyValueDB('/usr/share/java/Tools/Applet Launcher.app/Contents/Info.plist')
}
\keyword{IO}
\concept{XML}

