\name{xmlFlatListTree}
\alias{xmlFlatListTree}
\alias{xmlHashTree}
\title{Constructors for trees stored as flat list of nodes with
    information about parents and children.}
\description{

  These (and related internal) functions allow us to represent trees as
  a simple, non-hierarchical collection of nodes along with
  corresponding tables that identify the parent and child relationships.
  This is different from representing a tree as a list of lists of lists
  ...  in which each node has a list of its own children. In a
  functional language like R, it is not possible then for the children
  to be able to identify their parents.
  
  We use an environment to represent these flat trees.  Since these are
  mutable without requiring the change to be reassigned, we can modify a
  part of the tree locally without having to reassign the top-level
  object.

  We can use either a list (with names) to store the nodes or a hash
  table/associative array that uses names. There is a non-trivial
  performance difference.
}
\usage{
xmlHashTree(nodes = list(), parents = character(), children = list(), 
             env = new.env(TRUE, parent = emptyenv()))
xmlFlatListTree(nodes = list(), parents = character(), children = list(),
                env = new.env(), n = 200)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{nodes}{ a collection of existing nodes that are to be added to
    the tree. These are used to initialize the tree. If this is
    specified, you must also specify \code{children} and \code{parents}.
    }
  \item{parents}{ the parent relationships for the nodes given by \code{nodes}.}
  \item{children}{the children relationships for the nodes given by \code{nodes}.}
  \item{env}{an environment in which the information for the tree  will
    be stored. This is essentially the tree object as it allows us to
    modify parts of the tree without having to reassign the top-level
    object.    Unlike most R data types, environments are mutable.
   }
  \item{n}{for \code{xmlFlatListTree}, this is used as the default size
    to allocate for the list containing the nodes}
}

\value{
  An object of class XMLFlatTree which is specialized
  to \code{XMLFlatListTree} by the \code{xmlFlatListTree}
  function and \code{XMLHashTree} by the \code{xmlHashTree} function.
  Both objects are simply the environment which contains information
  about the tree elements and functions to access this information.

  An \code{xmlHashTree} object has an accessor method via
  \code{$} for accessing individual  nodes within the tree.
  One can use the node name/identifier in an expression such as
  \code{tt$myNode} to obtain the element.
  The name of a node is either its XML node name or if that is already
  present in the tree, a machine generated name.

  One can find the names of all the nodes using the
  \code{objects} function since these trees are regular
  environments in R.
  Using the \code{all = TRUE} argument, one can also find the
  \dQuote{hidden} elements that make define the tree's structure.
  These are \code{.children} and \code{.parents}.
  The former is an (hashed) environment. Each element is identified by the
  node in the tree by the node's identifier (corresponding to the
  name of the node in the tree's environment).
  The value of that element is simply a character vector giving the
  identifiers of all of the children of that node.

  The \code{.parents} element is also an environemnt.
  Each element in this gives the pair of node and parent identifiers
  with the parent identifier being the value of the variable in the
  environment. In other words, we look up the parent of a node
  named 'kid' by retrieving the value of the variable 'kid' in the
  \code{.parents} environment of this hash tree.

  The function \code{.addNode} is used to insert a new node into the
  tree.

  The structure of this tree allows one to easily travers all nodes,
  navigate up the tree from a node via its parent.  Certain tasks are
  more complex as the hierarchy is not implicit within a node.
}
\references{\url{http://www.w3.org/XML}}
\author{ Duncan Temple Lang }

\seealso{
  \code{\link{xmlTreeParse}}
  \code{\link{xmlTree}}
  \code{\link{xmlOutputBuffer}}
  \code{\link{xmlOutputDOM}}    
}
\examples{
 f = system.file("exampleData", "dataframe.xml", package = "XML")
 tr  = xmlHashTree()
 xmlTreeParse(f, handlers = list(.startElement = tr[[".addNode"]]))

 tr # print the tree on the screen

  # Get the two child nodes of the dataframe node.
 xmlChildren(tr$dataframe)

  # Find the names of all the nodes.
 objects(tr)
  # Which nodes have children
 objects(tr$.children)

  # Which nodes are leaves, i.e. do not have children
 setdiff(objects(tr), objects(tr$.children))

  # find the class of each of these leaf nodes.
 sapply(setdiff(objects(tr), objects(tr$.children)),
         function(id) class(tr[[id]]))

  # distribution of number of children
 sapply(tr$.children, length)


  # Get the first A node
 tr$A

  # Get is parent node.
 xmlParent(tr$A)


 f = system.file("exampleData", "allNodeTypes.xml", package = "XML")

   # Convert the document
 r = xmlInternalTreeParse(f, xinclude = TRUE)
 ht = as(r, "XMLHashTree")
 ht
 
  # work on the root node, or any node actually
 as(xmlRoot(r), "XMLHashTree")

  # Example of making copies of an XMLHashTreeNode object to create a separate tree.
 f = system.file("exampleData", "simple.xml", package = "XML")
 tt = as(xmlParse(f), "XMLHashTree")

 xmlRoot(tt)[[1]]
 xmlRoot(tt)[[1, copy = TRUE]]

 table(unlist(eapply(tt, xmlName)))
 # if any of the nodes had any attributes
 # table(unlist(eapply(tt, xmlAttrs)))
}
\keyword{IO}
\concept{XML}
