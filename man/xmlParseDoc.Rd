\name{xmlParseDoc}
\Rdversion{1.1}
\alias{xmlParseDoc}
\alias{COMPACT}
\alias{DTDATTR}
\alias{DTDLOAD}
\alias{DTDVALID}
\alias{HUGE}
\alias{NOBASEFIX}
\alias{NOBLANKS}
\alias{NOCDATA}
\alias{NODICT}
\alias{NOENT}
\alias{NOERROR}
\alias{NONET}
\alias{NOWARNING}
\alias{NOXINCNODE}
\alias{NSCLEAN}
\alias{OLDSAX}
\alias{PEDANTIC}
\alias{RECOVER}
\alias{XINCLUDE}
\alias{OLD10}
\alias{SAX1}

\title{Parse an XML document with options controlling the parser.}

\description{
This function is a generalization of \code{\link{xmlParse}}
that parses an XML document.  With this function, we can specify
a combination of different options that control the operation of the
parser. The options control many different aspects the parsing process
 
}
\usage{
xmlParseDoc(file, options = 1L, encoding = character(), asText = !file.exists(file), baseURL = file)
}
\arguments{
  \item{file}{the name of the file or URL or the XML content itself}
  \item{options}{options controlling the behavior of the parser.
    One specifies the different options as elements of an integer
    vector. These are then bitwised OR'ed together. The possible options are
    \code{RECOVER}, \code{NOENT}, \code{DTDLOAD},
    \code{DTDATTR}, \code{DTDVALID}, \code{NOERROR}, \code{NOWARNING},
    \code{PEDANTIC}, \code{NOBLANKS}, \code{SAX1}, \code{XINCLUDE},
    \code{NONET}, \code{NODICT}, \code{NSCLEAN}, \code{NOCDATA},
    \code{NOXINNODE}, \code{COMPACT}, \code{OLD10}, \code{NOBASEFIX},
    \code{HUGE}, \code{OLDSAX}.
     ( These options are also listed in the (non-exported) variable
      \code{parserOptions}.)
  }
  \item{encoding}{character string that provides the encoding of the
    document if it is not explicitly contained within the document itself.}
  \item{asText}{a logical value indicating whether \code{file} is the
    XML content (\code{TRUE}) or the name of a file or URL (\code{FALSE})}
  \item{baseURL}{the base URL used for resolving relative documents,
    e.g. XIncludes. This is important if \code{file} is the actual XML
    content rather than a URL}
}
\value{
 An object of class \code{XMLInternalDocument}.  
}
\references{libxml2}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{xmlParse}}
}
\examples{
 f = system.file("exampleData", "mtcars.xml", package="XML")
     # Same as xmlParse()
 xmlParseDoc(f)

 txt =
     '<top xmlns:r="http://www.r-project.org">
        <b xmlns:r="http://www.r-project.org">
          <c xmlns:omg="http:/www.omegahat.org"/>
        </b>
      </top>'

 xmlParseDoc(txt,  NSCLEAN, asText = TRUE)

 txt =
     '<top xmlns:r="http://www.r-project.org"  xmlns:r="http://www.r-project.org">
        <b xmlns:r="http://www.r-project.org">
          <c xmlns:omg="http:/www.omegahat.org"/>
        </b>
      </top>'

 xmlParseDoc(txt, c(NSCLEAN, NOERROR), asText = TRUE)
}

\keyword{data}
\concept{XML}
