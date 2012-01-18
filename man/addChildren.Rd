\name{addChildren}
\alias{addChildren}
\alias{xmlParent<-}
\alias{removeChildren}
\alias{removeNodes}
\alias{removeNodes.list}
\alias{removeNodes.XMLNodeSet}
\alias{removeNodes.XMLNodeList}
\alias{removeNodes.XMLInternalNode}
\alias{replaceNodes}
\alias{addAttributes}
\alias{removeAttributes}
\alias{addChildren,XMLInternalNode-method}
\alias{addChildren,XMLNode-method}
\alias{addAttributes,XMLInternalElementNode-method}
\alias{addAttributes,XMLNode-method}
\alias{removeAttributes,XMLInternalElementNode-method}
\alias{removeAttributes,XMLNode-method}
\title{Add child nodes to an XML node}
\description{
  This collection of functions
  allow us to add, remove and replace children from an XML node
  and also to and and remove attributes on an XML node.
  These are generic functions that work on
  both internal C-level \code{XMLInternalElementNode} objects
  and regular R-level  \code{XMLNode} objects.

  \code{addChildren} is similar to \code{\link{addNode}}
  and the two may be consolidated into a single generic
  function and methods in the future.
}
\usage{
addChildren(node, ..., kids = list(...), at = NA, cdata = FALSE, append = TRUE)
removeChildren(node, ..., kids = list(...), free = FALSE)
removeNodes(node, free = rep(FALSE, length(node)))
replaceNodes(oldNode, newNode, ...)
addAttributes(node, ..., .attrs = NULL, 
               suppressNamespaceWarning = getOption("suppressXMLNamespaceWarning", FALSE),
                append = TRUE)
removeAttributes(node, ..., .attrs = NULL, .namespace = FALSE,
                  .all = (length(list(...)) + length(.attrs)) == 0)
%xmlParent(node) = value
}
\arguments{
  \item{node}{the XML node whose state is to be modified,
      i.e. to which the child nodes are to be added or whose attribute list
      is to be changed.}
    \item{\dots}{This is for use in interactive settings when specifying a collection of
      values individuall. In programming contexts when one obtains the
      collection as a vector or list from another call, use the
      \code{kids} or \code{.attrs} parameter.
    }
    \item{kids}{when adding children to a node, this is a list of
      children nodes which should be of
      the same "type" (i.e. internal or R-level nodes)
      as the \code{node} argument. However, they can also be
      regular strings in which case they are converted to
      XML text nodes.

      For \code{removeChildren}, this is again a list
      which identifies the child nodes to be
      removed using 
      the integer identifier of the child, or
      the name of the XML node (but this will only remove the first such
      node and not necessarily do what you expect when there are
      multiple nodes with the same name),
      or the \code{XMLInternalNode} object itself.
    }
    \item{at}{if specified, an integer identifying
      the position in the original
      list of children at which the new children should be added.
      The children are added after that child.
      This can also be a vector of indices which is as long
      as the number of children being added and specifies the position
      for each child being added. If the vector is shorter than the
      number of children being added, it is padded with NAs
      and so the corresponding children are added at the end of the
      list.

      This parameter is only implemented for internal nodes at present.
     }
    \item{cdata}{a logical value which controls whether children that
     are specified as strings/text are enclosed within a CDATA node
     when converted to actual nodes.  This value is passed on to the
     relevant function that creates the text nodes, e.g. 
     \code{\link{xmlTextNode}} and \code{\link{newXMLTextNode}}.
   }
    \item{.attrs}{a character vector identifying the names of the
      attributes.  These strings can have name space prefixes,
      e.g. \code{r:length}
      and the namespaces will be resolved relative to the
      list supported by \code{node} to ensure those namespaces  are defined.
    }
    \item{.namespace}{This is currently ignored and may never be
      supported.
      The intent is to identify on which set of attributes the operation is
      to perform  - the name space declarations or the regular
      node attributes.
      This is a logical value indicating
      if  \code{TRUE} that  the attributes of interested are name space declarations,
      i.e. of the form \code{xmlns:prefix} or \code{xmlns}.
      If a value of  \code{FALSE} is supplied this indicates that we
      are identifying regular attributes.
      Note that we can still identify attributes with a name space
      prefix as, e.g., \code{ns:attr} without this value
    }
    \item{free}{a logical value indicating whether to free the C-level
      memory associated with the  child      nodes that were removed.
      \code{TRUE} means to free that memory.
      This is only applicable for the internal nodes created
      with \code{xmlTree} and \code{newXMLNode} and related functions.
      It is necessary as automated garbage collection is tricky in this
      tree-based context spanning both R and C data structures and
      memory managers. 
    }
    \item{.all}{a logical value indicating whether to remove all of the
      attributes within the XML node without having to specify them by
     name.}
   \item{oldNode}{the node which is to be replaced}
   \item{newNode}{the node which is to take the place of
     \code{oldNode} in the list of children of the parent of
     \code{oldNode}}
   \item{suppressNamespaceWarning}{a logical value or a character string. 
      This is used to control the situation when an  XML node
      or attribute is created with a name space prefix that currently has no
      definition for that node. 
      This is not necessarily an error but can lead to one.
      This argument controls whether a warning is issued
       or if a separate function is called.
      A value of \code{FALSE} means not to suppress the warning and 
      so it is issued. A value of \code{TRUE} causes the potential
      problem to be ignored assuming that the namespace will be added
      to this node or one of its ancestors at a later point.
      And if this value is a character string, we search for a
      function of that name and invoke it. 
     }
  \item{append}{a logical value that indicates whether (\code{TRUE}) the specified
   attributes or children should be added to the existing  attributes on the XML node
   (if any exist), or, if \code{FALSE} these should replace any existing attributes.}
}
%\details{}
\value{
 Each of these functions returns the modified node.
 For an internal node, this is the same R object   and
 only the C-level data structures have changed.
 For an R \code{XMLNode} object, this is is an entirely
 separate object from the original node.
 It must be inserted back into its parent "node" or context if the changes are to be
 seen in that wider context. 
}
\references{
libxml2 \url{http://www.xmlsoft.org}
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{xmlTree}}
  \code{\link{newXMLNode}}
}
\examples{

b = newXMLNode("bob", namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"))

cat(saveXML(b), "\n")

addAttributes(b, a = 1, b = "xyz", "r:version" = "2.4.1", "omg:len" = 3)
cat(saveXML(b), "\n")

removeAttributes(b, "a", "r:version")
cat(saveXML(b), "\n")


removeAttributes(b, .attrs = names(xmlAttrs(b)))


addChildren(b, newXMLNode("el", "Red", "Blue", "Green",
                           attrs = c(lang ="en")))

k = lapply(letters, newXMLNode)
addChildren(b, kids = k)

cat(saveXML(b), "\n")

removeChildren(b, "a", "b", "c", "z")

  # can mix numbers and names
removeChildren(b, 2, "e")  # d and e

cat(saveXML(b), "\n")


i = xmlChildren(b)[[5]]
xmlName(i)

 # have the identifiers
removeChildren(b, kids = c("m", "n", "q"))



x <- xmlNode("a", 
               xmlNode("b", "1"),
               xmlNode("c", "1"),
	       "some basic text")

v = removeChildren(x, "b")

  # remove c and b
v = removeChildren(x, "c", "b")

  # remove the text and "c" leaving just b
v = removeChildren(x, 3, "c")

\dontrun{
    # this won't work as the 10 gets coerced to a 
    # character vector element to be combined with 'w'
    # and there is no node name 10.
 removeChildren(b, kids = c(10, "w"))
}


 # for R-level nodes (not internal)

z = xmlNode("arg", attrs = c(default="TRUE"),
              xmlNode("name", "foo"), xmlNode("defaultValue","1:10"))

o = addChildren(z,
                "some text",
                xmlNode("a", "a link", attrs = c(href = "http://www.omegahat.org/RSXML")))
o


  # removing nodes

 doc = xmlParse("<top><a/><b/><c><d/><e>bob</e></c></top>")
 top = xmlRoot(doc)
 top
 
 removeNodes(list(top[[1]], top[[3]]))

    # a and c have disappeared.
 top

}
\keyword{IO }
\keyword{programming}
\concept{XML}
\concept{document tree}
