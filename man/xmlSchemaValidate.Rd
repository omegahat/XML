\name{xmlSchemaValidate}
\alias{xmlSchemaValidate}
\alias{schemaValidationErrorHandler}
\title{Validate an XML document relative to an XML schema}
\description{
 This function validates an XML document relative to an
 XML schema to ensure that it has the correct structure,
 i.e. valid sub-nodes, attributes, etc.

 The \code{xmlSchemaValidationErrorHandler} is a function
 that returns a list of functions which can be used to cumulate or
 collect the errors and warnings from the schema validation  operation.
}
\usage{
xmlSchemaValidate(schema, doc, 
                                 errorHandler = xmlErrorFun(),
                                  options = 0L)

schemaValidationErrorHandler()
}
\arguments{
  \item{schema}{an object of class \code{xmlSchemaRef} which is
  usually the result of a call to \code{\link{xmlInternalTreeParse}}
  with \code{isSchema = TRUE}, or \code{\link{xmlSchemaParse}}.}
  \item{doc}{an XML document which has already been parsed into
a \code{XMLInternalDocument} or which is a file name or string
   which is coerced to an \code{\link{XMLInternalDocument-class}} object}
  \item{options}{an integer giving the options controlling the
  validation.  At present, this is either 0 or 1 and is essentially
  irrelevant to us. It may be of value in the future.
   }
  \item{errorHandler}{ a function or a list whose first element is a function
   which is then used as the collector for the warning and error
   messages reported during the validation. For each warning or error,
  this function is invoked and the class of the message is either
  \code{XMLSchemaWarning} or \code{XMLSchemaError} respectively.
  }
}
\value{
 Typically, a list with 3 elements:
  \item{status}{0 for validated, and non-zero for invalid}
  \item{errors}{a character vector}
  \item{warnings}{a character vector}

  If an empty error handler is provided (i.e. \code{NULL})
  just an integer indicating the status of the validation
 is returned.  0 indicates everything was okay; a non-zero
 value indicates a validation error. (-1 indicates an internal error
  in libxml2)
}
\references{libxml2 www.xmlsoft.org }

\seealso{
 \code{\link{xmlSchemaParse}}
}
\examples{
if(FALSE) {
  xsd = xmlParse(system.file("exampleData", "author.xsd", package = "XML"), isSchema =TRUE)
  doc = xmlInternalTreeParse(system.file("exampleData", "author.xml",  package = "XML"))
  xmlSchemaValidate(xsd, doc)
}
}
\keyword{IO}
\concept{validation}
\concept{XML}
\concept{schema}
