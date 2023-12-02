\name{xmlToList}
\alias{xmlToList}
\title{Convert an XML node/document to a more R-like list}
\description{
 This function is an early and simple approach to converting
an XML node or document into a more typical R list containing
the data values directly (rather than as XML nodes).
It is useful for dealing with data that is returned from
REST requests or other Web queries or generally when parsing
XML and wanting to  be able to access the content
as elements in a list indexed by the name of the node.
For example, if given a node of the form
\code{
  <x>
     <a>text</a>
     <b foo="1"/>
     <c bar="me">
        <d>a phrase</d>
     </c>
  </x>
}
We would end up with a list with elements named "a", "b" and "c".
"a" would be the string "text", b would contain the named character
vector \code{c(foo = "1")} (i.e. the attributes) and "c" would
contain the list with two elements named "d" and ".attrs".
The element corresponding to "d" is a
character vector with the single element "a phrase".
The ".attrs" element of the list is the character vector of
attributes from the node \code{<c>...</c>}.
}
\usage{
xmlToList(node, addAttributes = TRUE, simplify = FALSE,
          attributesAsElements = FALSE)
}
\arguments{
  \item{node}{the XML node or document to be converted to an R list.
   This can be an "internal" or C-level node (i.e. \code{\link{XMLInternalNode-class}})
   or a regular R-level node (either \code{\link{XMLNode-class}} or \code{XMLHashNode}).}
  \item{addAttributes}{a logical value which controls whether the attributes of a node
    are added to the list as a character vector element named \code{.attrs},
    or set as R attributes on the resulting list.
    In other words, suppose we have a node of the
    form \code{<foo a="1" b="xyz" c="true"><f>123</f><g>2.2</g></foo>},
    \code{addAttributes = TRUE} will result in a list with elements named
    \code{f}, \code{g} and \code{.attrs} with the last of these being a named
    character vector \code{c(a = "1", b = "xyz", c = "true")}.
    If \code{addAttributes = FALSE}, we get a list with two elements
    (corresponding to the subnodes \code{f} and \code{g}) and
      the attributes named \code{a}, \code{b} and \code{c} awith the string values from the node
      attributes of \code{foo} are added as R attributes to the 2-element (f and g) list.
   }
  \item{attributesAsElements}{if \code{TRUE} and also \code{addAttributes} is \code{TRUE},
     add each attribute of the XML node as a separate element of the resulting list
      rather than having them in a single character vector in an element named \code{.attr}.
      In other words, in the example in \code{addAttributes},
      the result would be a list with elements named
      \code{f}, \code{g}, \code{a}, \code{b} and \code{c}.}
  \item{simplify}{a logical value that controls whether we collapse
   the list to a vector if the elements all have a common compatible
   type. Basically, this controls whether we use \code{sapply} or \code{lapply}.
 }
}
\value{
 A list whose elements correspond to the children of the top-level nodes.
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{xmlTreeParse}}
 \code{\link{getNodeSet}} and \code{\link{xpathApply}}
 \code{\link{xmlRoot}},  \code{\link{xmlChildren}},  \code{\link{xmlApply}}, \code{[[}, etc. for
 accessing the content of XML nodes.
}
\examples{
tt =
 '<x>
     <a>text</a>
     <b foo="1"/>
     <c bar="me">
        <d>a phrase</d>
     </c>
  </x>'

  doc = xmlParse(tt)
  xmlToList(doc)

   # use an R-level node representation
  doc = xmlTreeParse(tt)
  xmlToList(doc)


   # add the attributes a and b from foo as attributes to the list
  v1 = xmlToList('<foo a="1" b="xyz"><f>123</f><g>2.2</g></foo>', FALSE)

   # add the attributes a and b as a character vector to the resulting list in an
   # element named .attrs
  v2 = xmlToList('<foo a="1" b="xyz"><f>123</f><g>2.2</g></foo>', TRUE)

   # add a and b as regular elements to the resulting list to get
   #  f, g, a and b
  v3 = xmlToList('<foo a="1" b="xyz"><f>123</f><g>2.2</g></foo>', TRUE, attributesAsElements = TRUE)
}
\keyword{IO}
\keyword{data}

