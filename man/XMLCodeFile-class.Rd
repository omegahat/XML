\name{XMLCodeFile-class}
%\Rdversion{1.1}
\docType{class}
\alias{XMLCodeFile-class}
\alias{XMLCodeDoc-class}
\alias{xmlCodeFile}
\alias{[[,XMLCodeFile-method}
%\alias{[[,XMLCodeFile,ANY,ANY-method}
\alias{[[,XMLCodeFile,ANY-method}
\alias{coerce,XMLCodeFile,XMLCodeDoc-method}
\alias{coerce,character,XMLCodeDoc-method}
\alias{coerce,character,XMLCodeFile-method}
\alias{source,XMLCodeFile-method}

\title{Simple classes for identifying an XML document containing R code}
\description{
 These two classes allow the user to identify an XML document or file
 as containing R code (amongst other content). Objects of either of these
 classes can then be passed to \code{\link{source}} to read the 
 code into R and also used in \code{link{xmlSource}} to read just parts of it.
 \code{XMLCodeFile} represents the file by its name;
 \code{XMLCodeDoc} parses the contents of the file when the R object is created.
 Therefore, an \code{XMLCodeDoc} is a snapshot of the contents at a moment in time
 while an \code{XMLCodeFile} object re-reads the file each time and so reflects
 any "asynchronous" changes.
}
\section{Objects from the Class}{
  One can create these objects using coercion methods, e.g
 \code{as("file/name", "XMLCodeFile")}
  or  \code{as("file/name", "XMLCodeDoc")}.
  One can also use  \code{xmlCodeFile}.
}
\section{Slots}{
	 \describe{
    \item{\code{.Data}:}{Object of class \code{"character"}}
  }
}
\section{Extends}{
Class \code{"\linkS4class{character}"}, from data part.
Class \code{"\linkS4class{vector}"}, by class "character", distance 2.
%Class \code{"\linkS4class{data.frameRowLabels}"}, by class "character", distance 2.
%Class \code{"\linkS4class{EnumerationValue}"}, by class "character", distance 2.
%Class \code{"\linkS4class{NodeIndex}"}, by class "character", distance 2.
%Class \code{"\linkS4class{RAnonymousFunctionOrCode}"}, by class "character", distance 2.
}
\section{Methods}{
  \describe{
    \item{[[}{\code{signature(x = "XMLCodeFile", i = "ANY", j = "ANY")}: 
       this method allows one to retrieve/access an individual R code element
       in the XML document. This is typically done by specifying the value of the XML element's 
       "id" attribute.
       }
    \item{coerce}{\code{signature(from = "XMLCodeFile", to = "XMLCodeDoc")}:
        parse the XML document from the "file" and treat the result as a
       \code{XMLCodeDoc} object. 
     }
    \item{source}{\code{signature(file = "XMLCodeFile")}: read and evaluate all the
      R code in the XML document. For more control, use \code{\link{xmlSource}}.}
	 }
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{xmlSource}}
}
\examples{
 src =  system.file("exampleData", "Rsource.xml", package = "XML")
   # mark the string as an XML file containing R code
 k = xmlCodeFile(src)

   # read and parse the code, but don't evaluate it.
 code = xmlSource(k, eval = FALSE)

   # read and evaluate the code in a special environment.
 e = new.env()
 ans = xmlSource(k, envir = e)
 ls(e)
}
\keyword{classes}
