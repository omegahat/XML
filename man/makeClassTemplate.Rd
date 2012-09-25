\name{makeClassTemplate}
\alias{makeClassTemplate}
\title{Create S4 class definition based on XML node(s)}
\description{
  This function is used to create an S4 class definition
  by examining an XML node and  mapping the sub-elements
  to S4 classes. This works very simply with child nodes
  being mapped to other S4 classes that are defined recursively in the
  same manner. Simple text elements are mapped to a generic character string.
  Types can be mapped to more specific types (e.g. boolean, Date, integer)
  by the caller (via the \code{types}) parameter.
  The function also generates a coercion method from an
  \code{XMLAbstractNode} to an instance of this new class.
   

  This function can either return the code that defines the class
  or it can define the new class in the R session.
}
\usage{
makeClassTemplate(xnode, types = character(), default = "ANY",
                   className = xmlName(xnode), where = globalenv())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{xnode}{the XML node to analyze}
  \item{types}{a character vector mapping XML elements to R classes}
  \item{default}{the default class to map an element to}
  \item{className}{the name of the new top-level class to be defined.
    This is the name of the XML node (without the name space)}
  \item{where}{ typically either an environment or NULL.
       This is used to control where the class and coercion method are
       defined
       or if \code{NULL} inhibits the code being evaluated. In this
       case, the code is returned as strings.}
}
%\details{}
\value{
  A list with 4 elements:
  \item{name}{the name of the new class}
  \item{slots}{a character vector giving the slot name and type name pairs}
  \item{def}{code for defining the class}
  \item{coerce}{code for defining the coercion method from an
    XMLAbstractNode to an instance of the new class}
  
  If \code{where} is not \code{NULL}, the class and coercion code
  is actually evaluated and the class and method will be defined
  in the R session as a side effect.
}

\author{Duncan Temple Lang}

\seealso{
 \code{\link{xmlToS4}}  
}
\examples{
 txt =
 "<doc><part><name>ABC</name><type>XYZ</type><cost>3.54</cost><status>available</status></part></doc>"
 doc = xmlParse(txt)

 code = makeClassTemplate(xmlRoot(doc)[[1]], types = c(cost = "numeric"))

 as(xmlRoot(doc)[["part"]], "part")
}
\keyword{programming}
\concept{reflection}
\concept{meta-programming}

