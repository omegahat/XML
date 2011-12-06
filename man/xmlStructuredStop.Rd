\name{xmlStructuredStop}
\alias{xmlStructuredStop}
\alias{xmlErrorCumulator}

\title{Condition/error handler functions for XML parsing}
\description{
  These functions provide basic error handling for the XML parser in
  R. They also illustrate the basics which will allow others to
  provide customized error handlers that make more use of the
  information provided in each error reported.
 
  The \code{xmlStructuredStop} function provides a simple R-level handler for errors
  raised by the XML parser.
  It collects the information provided by the XML parser and
  raises an R error.
  This is only used if \code{NULL} is specified for the
  \code{error} argument of \code{\link{xmlTreeParse}},
  \code{\link{xmlTreeParse}} and \code{\link{htmlTreeParse}}.

  The default is to use the function returned by a call to 
  \code{xmlErrorCumulator} as the error handler.
  This, as the name suggests, cumulates errors.
  The idea is to catch each error and let the parser continue
  and then report them all.
  As each error is encountered, it is collected by the function.
  If \code{immediate} is \code{TRUE}, the error is also reported on
  the console.
  When the parsing is complete and has failed, this function is
  invoked again with a zero-length character vector as the 
  message (first argument) and then it raises an error.
  This function will then raise an R condition of class \code{class}.
}
\usage{
xmlStructuredStop(msg, code, domain, line, col, level, filename, 
                    class = "XMLError") 
xmlErrorCumulator(class = "XMLParserErrorList", immediate = TRUE)
}
\arguments{
  \item{msg}{character string, the text of the message being reported}
  \item{code}{     an integer code giving an identifier for the error (see
    xmlerror.h) for the moment,}
  \item{domain}{     an integer domain indicating in which "module" or part of the
    parsing the error occurred, e.g. name space, parser, tree, xinclude, etc.}
  \item{line}{    an integer giving the line number in the XML content
  being processed corresponding to the error,  }
  \item{col}{    an integer giving the column position of the error,  }
  \item{level}{     an integer giving the severity of the error ranging from 1 to 3 in
    increasing severity (warning, error, fatal),}
  \item{filename}{character string,   the name of the document being processed, i.e. its file name or
    URL.}
  \item{class}{ character vector,  any classes to prepend to the class
    attribute to make the error/condition. These are prepended to those
   returned via \code{\link[base]{simpleError}}.}
  \item{immediate}{logical value,  if  \code{TRUE} errors are
    displayed on the R console as they are encountered. Otherwise, the
  errors are collected and displayed at the end of the XML parsing.}
}

\value{
  This calls \code{\link[base]{stop}} and so does not return a value.
}
\references{libxml2 and its error handling facilities (\url{http://xmlsoft.org}}
\author{ Duncan Temple Lang}

\seealso{ 
 \code{\link{xmlTreeParse}}
 \code{\link{xmlInternalTreeParse}}
 \code{\link{htmlTreeParse}}
}
\examples{
  tryCatch( xmlTreeParse("<a><b></a>", asText = TRUE, error = NULL),
                 XMLError = function(e) {
                    cat("There was an error in the XML at line", 
                          e$line, "column", e$col, "\n",
                         e$message, "\n")
                })
}
\keyword{IO }
\keyword{programming}
\concept{error handling}
