% insert facilities
\name{newXMLDoc}
\alias{newXMLDoc}
\alias{newHTMLDoc}
\alias{newXMLNode}
\alias{newXMLPINode}
\alias{newXMLCDataNode}
\alias{newXMLCommentNode}
\alias{newXMLTextNode}
\alias{newXMLDTDNode}
\alias{xmlDoc}
\alias{coerce,vector,XMLInternalNode-method}
\title{Create internal XML node or document object}
\description{
These are used to create internal `libxml' nodes and top-level document objects 
that are used to write XML trees.  While the functions are available,
their direct use is not encouraged. Instead, use \code{\link{xmlTree}}
as the functions need to be used within a strict regime to avoid
corrupting C level structures.

\code{xmlDoc} creates a new XMLInternalDocument
object by copying the given node and all of its
descendants and putting them into a new document.
This is useful when we want to work with sub-trees
with general tools that work on documents, e.g. XPath queries.


\code{newXMLDoc} allows one to create a regular XML node
with a name and attributes.
One can provide new namespace definitions via
\code{namespaceDefinitions}. While these might also
be given in the attributes in the slightly more verbose
form of \code{c('xmlns:prefix' = 'http://...')},
the result is that the XML node does not interpret that
as a namespace definition but merely an attribute with
a name 'xmlns:prefix'.
Instead, one should specify the namespace definitions via
the \code{namespaceDefinitions} parameter.

In addition to namespace definitions, a node name can also have a
namespace definition.  This can be specified in the \code{name} argument
as \code{prefix:name} and \code{newXMLDoc} will do the right thing in
separating this into the namespace and regular name.  Alternatively, one
can specify a namespace separately via the \code{namespace} argument.
This can be either a simple name or an internal namespace object defined
earlier.

How do we define a default namespace?
}
\usage{
xmlDoc(node, addFinalizer = TRUE)
newXMLDoc(dtd = "", namespaces=NULL, addFinalizer = TRUE, 
           name = character(), node = NULL, isHTML = FALSE)
newHTMLDoc(dtd = "loose", addFinalizer = TRUE, name = character(), 
            node = newXMLNode("html",
                               newXMLNode("head", addFinalizer = FALSE), 
                               newXMLNode("body", addFinalizer = FALSE),
                              addFinalizer = FALSE)) 
newXMLNode(name, ..., attrs = NULL, namespace = character(),
            namespaceDefinitions = character(),
             doc = NULL, .children = list(...), parent = NULL,
	     at = NA, cdata = FALSE,
             suppressNamespaceWarning =
                 getOption("suppressXMLNamespaceWarning", FALSE),
             sibling = NULL, addFinalizer = NA,
              noNamespace = length(namespace) == 0 && !missing(namespace),
               fixNamespaces = c(dummy = TRUE, default = TRUE))
newXMLTextNode(text, parent = NULL, doc = NULL, cdata = FALSE, 
                escapeEntities = is(text, "AsIs"), addFinalizer = NA)
newXMLCDataNode(text, parent = NULL, doc = NULL, at = NA, sep = "\n",
                   addFinalizer = NA)
newXMLCommentNode(text, parent = NULL, doc = NULL, at = NA, addFinalizer = NA)
newXMLPINode(name, text, parent = NULL, doc = NULL, at = NA, addFinalizer = NA)
newXMLDTDNode(nodeName, externalID = character(),
              systemID = character(), doc = NULL, addFinalizer = NA)  
}
\arguments{
  \item{node}{a \code{XMLInternalNode} object that will be copied to
    create a subtree for a new document.}
  \item{dtd}{the name of the DTD to use for the XML document.
    Currently ignored!}
  \item{namespaces}{a named character vector
  with each element specifying a name space identifier and the
  corresponding URI for that namespace
  that are to be declared and used in the XML document, \\
  e.g. \code{c(shelp = "http://www.omegahat.org/XML/SHelp")}}
 \item{addFinalizer}{a logical value indicating whether the
  default finalizer routine should be registered to
  free the internal xmlDoc when R no longer has a reference to this
  external pointer object.
  This can also be the name of a C routine or a reference
  to a C routine retrieved using
  \code{\link[base]{getNativeSymbolInfo}}. }
 \item{name}{the tag/element name for the XML node and
   the for a Processing Instruction (PI) node, this is the "target",
   e.g. the identifier for the system for whose attention this PI node is intended.}
  \item{...}{the children of this node. These can be other nodes created
  earlier or R strings that are converted to text nodes and added as children
  to this newly created node.}
  \item{attrs}{a named list of name-value pairs to be used as 
    attributes for the XML node.
    One should not use this argument to define namespaces,
    i.e. attributes of the form \code{xmlns:prefix='http:/...'}.
    Instead, such definitions should be specified
    ideally via the \code{namespaceDefinitions} argument,
    or even the \code{namespace} argument.
    The reason is that namespace definitions are special attributes
    that are shared across nodes wherease regular attributes are
    particular to a node. So a namespace needs to be explicitly defined
    so that the XML representation can recognize it as such.
  }
  \item{namespace}{a character vector specifying the namespace for this
    new node.
    Typically this is used to specify  i) the prefix
    of the namespace to use, or ii) one or more namespace definitions,
    or iii) a combination of both.
    If this is a character vector with a) one element
    and b) with an empty \code{names} attribute
    and c) whose value does not start with \code{http:/} or
    \code{ftp:/}, then it is assumed that the value is a
    namespace prefix for a namespace defined in an ancestor node.
    To be able to resolve this prefix to a namespace definition,
    \code{parent} must be specified so that we can traverse the chain of ancestor nodes.
    However, if c) does not hold, i.e. the string starts with \code{http:/} or
    \code{ftp:/},
    then we take this single element to be a namespace definition and
    the since it has no name b), this is the definition for the default namespace for this
    new node, i.e. corresponding to \code{xmlns='http:/...'}.
    It is cumbersome to specify \code{""} as a  name for an element in a
    character vector (as \code{c('' = 'value') gives an unnecessary
      error!}.
    Elements with names are expanded to namespace definitions
    with the name as the prefix and the value as the namespace URI.
  }
  \item{doc}{the \code{XMLInternalDocument} object created with
    \code{newXMLDoc} that is used to root the node.}
  \item{.children}{a list containing XML node elements or content.
    This is an alternative form of specifying the child nodes than \dots
  which is useful for programmatic interaction when the "sub"-content is
  already in a list rather than a loose collection of values.}
\item{text}{the text content for the new XML node}
\item{nodeName}{the name of the node to put in the DOCTYPE element
  that will appear as the top-most node in the XML document.}

\item{externalID}{the PUBLIC identifier for the document type.
  This is a string of the form \code{A//B//C//D}.
  A is either + or -; B identifies the person or insitution that defined
  the format (i.e. the "creator");
  C is the name of the format; and language is an encoding for the
  language that comes from the ISO 639 document.}
\item{systemID}{the SYSTEM identifier for the DTD for the document.
  This is a URI}
\item{namespaceDefinitions}{a character vector or a list
  with each element being a string.
  These give the URIs identifying the namespaces uniquely.
  The elements should have names which are used as prefixes.
  A default namespace has "" as the name.
  This argument can be used to remove any ambiguity
  that arises when specifying a single string
  with no names attribute as the value for \code{namespace}.
  The values here are used only for defining new namespaces
  and not for determining the namespace to use for this
  particular node.
}
\item{parent}{the node which will act as the parent of this newly
  created node. This need not be specified and one can add the new node
  to another node in a separate operation via
  \code{\link{addChildren}}.}
\item{sibling}{if this is specified (rather than \code{parent})
this should be an \code{XMLInternalNode} and the new node is added as
a sibling of this node, after this node, i.e. to the right.
This is just a convenient form of \code{parent = xmlParent(node)}.}

  \item{cdata}{a logical value indicating whether to enclose the text
  within a CDATA node (\code{TRUE}) or not (\code{FALSE}). This is a
  convenience mechanism to avoid having to create the text node and
  then the CDATA node.  If one is not certain what characters are in
  the text,  it is useful to use \code{TRUE} to ensure that they are
  \dQuote{escaped}.
 
  It is an argument for \code{newXMLNode} as the child nodes can be
  given as simple strings and are converted to text nodes. This
  \code{cdata} value is passed to the calls to create these text nodes
  and so controls whether they are enclosed within CDATA nodes.
  }
  \item{suppressNamespaceWarning}{see \code{\link{addChildren}}}

  \item{at}{this allows one to control the position in the list of children at which the node should be
  added. The default means at the end and this can be any position
  from 0 to the current number of children.}
  \item{sep}{when adding text nodes, this is used as an additional separator text to insert between the specified strings.}

  \item{escapeEntities}{a logical value indicating whether to mark the 
  internal text node in such a way that protects characters in its contents from
  being escaped as entities when being serialized via
  \code{\link{saveXML}}}
 \item{noNamespace}{a logical value that allows the caller to specify
  that the new node has no namespace. This can avoid searching parent
  and ancestor nodes up the tree for the default namespace.}
  \item{isHTML}{a logical value that indicates whether the XML document
  being created is HTML or generic XML. This helps to create an object
  that is identified as an HTML document.}
  \item{fixNamespaces}{a logical vector controlling how namespaces in
  child nodes are to be processed. The two entries should be named
  \code{dummy} and \code{default}.  The \code{dummy} element controls
  whether we process child nodes that have a namespace which was not
  defined when the node was created. These are created as \dQuote{dummy}
  namespaces and can be resolved now that the parent node is defined and
  the name space may be defined. When we know it is not yet defined, but
  will be defined in an ancestor node, we can turn off this processing
  with a value of \code{FALSE}.

  The \code{default} element controls how we process the child nodes
  and give them the default name space defined in the parent or ancestor nodes.}
}
\details{
These create internal C level objects/structure instances
that can be added to a libxml DOM and subsequently
inserted into other document objects or ``serialized''
to textual form.
}
\value{
 Each function returns an R object that points to the
C-level structure instance.
These are of class \code{XMLInternalDocument}
and \code{XMLInternalNode}, respectively
}

\references{\url{http://www.w3.org/XML}, \url{http://www.xmlsoft.org},
\url{http://www.omegahat.org}}
\author{ Duncan Temple Lang }

\note{These functions are used to build up an internal XML tree.
This can be used in the Sxslt package (\url{http://www.omegahat.org/Sxslt})
when creating content in R that is to be dynamically inserted into an XML
document.}

\seealso{
\code{\link{xmlTree}}
\code{saveXML}
}


\examples{

doc = newXMLDoc()

 # Simple creation of an XML tree using these functions
top = newXMLNode("a")
newXMLNode("b", attrs = c(x = 1, y = 'abc'), parent = top)
newXMLNode("c", "With some text", parent = top)
d = newXMLNode("d", newXMLTextNode("With text as an explicit node"), parent = top)
newXMLCDataNode("x <- 1\n x > 2", parent = d)

newXMLPINode("R", "library(XML)", top)
newXMLCommentNode("This is a comment", parent = top)

o = newXMLNode("ol", parent = top)

kids = lapply(letters[1:3],
               function(x)
                  newXMLNode("li", x))
addChildren(o, kids)

cat(saveXML(top))


x = newXMLNode("block", "xyz", attrs = c(id = "bob"),
                      namespace = "fo",
                      namespaceDefinitions = c("fo" = "http://www.fo.org"))

xmlName(x, TRUE) == "fo"

  # a short cut to define a name space and make it the prefix for the
  # node, thus avoiding repeating the prefix via the namespace argument.
x = newXMLNode("block", "xyz", attrs = c(id = "bob"),
                      namespace = c("fo" = "http://www.fo.org"))


 # name space on the attribute
x = newXMLNode("block", attrs = c("fo:id" = "bob"),
                      namespaceDefinitions = c("fo" = "http://www.fo.org"))




x = summary(rnorm(1000))
d = xmlTree()
d$addNode("table", close = FALSE)

d$addNode("tr", .children = sapply(names(x), function(x) d$addNode("th", x)))
d$addNode("tr", .children = sapply(x, function(x) d$addNode("td", format(x))))

d$closeNode()


# Just doctype
z = xmlTree("people", dtd = "people")
# no public element
z = xmlTree("people", dtd = c("people", "", "http://www.omegahat.org/XML/types.dtd"))
# public and system
z = xmlTree("people", dtd = c("people", "//a//b//c//d", "http://www.omegahat.org/XML/types.dtd"))

# Using a DTD node directly.
dtd = newXMLDTDNode(c("people", "", "http://www.omegahat.org/XML/types.dtd"))
z = xmlTree("people", dtd = dtd)


x = rnorm(3)
z = xmlTree("r:data", namespaces = c(r = "http://www.r-project.org"))
z$addNode("numeric", attrs = c("r:length" = length(x)), close = FALSE)
lapply(x, function(v) z$addNode("el", x))
z$closeNode()
# should give   <r:data><numeric r:length="3"/></r:data>


# shows namespace prefix on an attribute, and different from the one on the node.
z = xmlTree()
z$addNode("r:data",  namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"), close = FALSE)
x = rnorm(3)
z$addNode("r:numeric", attrs = c("omg:length" = length(x)))


z = xmlTree("people", namespaces = list(r = "http://www.r-project.org"))
z$setNamespace("r")

z$addNode("person", attrs = c(id = "123"), close = FALSE)
z$addNode("firstname", "Duncan")
z$addNode("surname", "Temple Lang")
z$addNode("title", "Associate Professor")
z$addNode("expertize", close = FALSE)
z$addNode("topic", "Data Technologies")
z$addNode("topic", "Programming Language Design")
z$addNode("topic", "Parallel Computing")
z$addNode("topic", "Data Visualization")
z$closeTag()
z$addNode("address", "4210 Mathematical Sciences Building, UC Davis")



   # 
txt = newXMLTextNode("x &lt; 1")
txt # okay
saveXML(txt) # x &amp;lt; 1

   # By escaping the text, we ensure the entities don't
   # get expanded, i.e. &lt; doesn't become &amp;lt;
txt = newXMLTextNode(I("x &lt; 1"))
txt # okay
saveXML(txt) # x &lt; 1


newXMLNode("r:expr", newXMLTextNode(I("x < 1")),
            namespaceDefinitions = c(r = "http://www.r-project.org"))

}
\keyword{IO}
