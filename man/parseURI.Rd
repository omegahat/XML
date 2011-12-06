\name{parseURI}
\alias{parseURI}
\alias{URI-class}
\alias{coerce,URI,character-method}
\title{Parse a URI string into its elements}
\description{
  This breaks a URI given as a string into its different elements such as
  protocol/scheme, host, port, file name, query.
  This information can be used, for example, when constructing URIs
  relative to a base URI.

  The return value is an S3-style object of class \code{URI}.
  
  This function uses libxml routines to perform the parsing.
}
\usage{
parseURI(uri)
}
\arguments{
  \item{uri}{a single string}
}

\value{
  A list with 8 elements
  \item{scheme}{the name of the protocol being used, http, ftp as a string.}
  \item{authority}{a string represeting a rarely used aspect of URIs}
  \item{server}{a string identifying the host, e.g. www.omegahat.org}
  \item{user}{a string giving the name of the user, e.g. in FTP
  "ftp://duncan@www.omegahat.org", this would yield "duncan"}
  \item{path}{a string identifying the path of the target file}
  \item{query}{the CGI query part of the string, e.g.
         the bit after '?' of the form \code{name=value&name=value}}
  \item{fragment}{a string giving the coo}
  \item{port}{an integer identifying the port number on which the
  connection is to be made}    
}

\seealso{
 \code{\link{getRelativeURL}}
}
\examples{
  parseURI("http://www.omegahat.org:8080/RCurl/index.html")
  parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html")

  parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html#my_anchor")

  as(parseURI("http://duncan@www.omegahat.org:8080/RCurl/index.html#my_anchor"), "character")

  as(parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html?foo=1&bar=axd"), "character")
}
\keyword{IO}
\concept{URI}
\concept{Web}
