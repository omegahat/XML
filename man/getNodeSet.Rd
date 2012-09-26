\name{getNodeSet}
\alias{getNodeSet}
\alias{xpathApply}
\alias{xpathSApply}
\alias{matchNamespaces}
\title{Find matching nodes in an internal XML tree/DOM}
\description{
  These functions provide a way to find XML nodes that match a particular
  criterion. It uses the XPath syntax and allows very powerful
  expressions to identify nodes of interest within a document both
  clearly and efficiently.  The XPath language requires some
  knowledge, but tutorials are available on the Web and in books.
  XPath queries can result in different types of values such as numbers,
  strings, and node sets. It allows simple identification of nodes
  by name, by path (i.e. hierarchies or sequences of
  node-child-child...), with a particular attribute  or matching
  a particular attribute with a given value. It also supports
  functionality for navigating nodes in the tree within a query
  (e.g. \code{ancestor()}, \code{child()}, \code{self()}),
  and also for manipulating the content of one or more nodes
  (e.g. \code{text}).
  And it allows for criteria identifying nodes by position, etc.
  using some counting operations.  Combining  XPath with R
  allows for quite flexible node identification and manipulation.
  XPath offers an alternative way to find nodes of interest 
  than recursively or iteratively navigating the entire tree in R
  and performing the navigation explicitly.

  One can search an entire document or start the search from a
  particular node.  Such node-based searches can even search up the tree
  as well as within the sub-tree that the node parents.  Node specific
  XPath expressions are typically started with a "." to indicate the
  search is relative to that node.
  

  The set of matching nodes corresponding to an XPath expression
  are returned in R as a list.  One can then  iterate over these elements to process the 
  nodes in whatever way one wants. Unfortunately, this involves two loops -
  one in the XPath query over the entire tree, and another in R.
  Typically, this is fine as the number of matching nodes is reasonably small.
  However, if repeating this on numerous files, speed may become an issue.
  We can avoid the second loop (i.e. the one in R) by applying a function to each node
  before it is returned to R as part of the node set.  The result of the function
  call is then returned, rather than the node itself.

  One can provide an R expression rather than an R function for \code{fun}. This is expected to be a call
  and the first argument of the call will be replaced with the node.

  Dealing with expressions that relate to the default namespaces in the
  XML document can be confusing. 

  \code{xpathSApply} is a version of \code{xpathApply}
  which attempts to simplify the result if it can be converted
  to a vector or matrix rather than left as a list.
  In this way, it has the same relationship to  \code{xpathApply}
  as \code{\link[base]{sapply}} has to  \code{\link[base]{lapply}}.

  \code{matchNamespaces} is a separate function that is used to
  facilitate
  specifying the mappings from namespace prefix  used in the
  XPath expression and their definitions, i.e. URIs,
  and connecting these with the namespace definitions in the
  target XML document in which the XPath expression will be evaluated.

  \code{matchNamespaces} uses rules that are very slightly awkard or
  specifically involve a special case. This is because this mapping of
  namespaces from  XPath to XML targets is difficult, involving
   prefixes in the XPath expression, definitions in the XPath evaluation
   context and matches of URIs with those in the XML document.
   The function aims to avoid having to specify all the prefix=uri pairs
   by using "sensible" defaults and also matching the prefixes in the
   XPath expression to the  corresponding definitions in the XML
   document.

   The rules are as follows.
   \code{namespaces} is a character vector. Any element that has a
   non-trivial name (i.e. other than "") is left as is and the name
   and value define the prefix = uri mapping.
   Any elements that have a trivial name (i.e. no name at all or "")
   are resolved by first matching the prefix to those of the defined
   namespaces anywhere within the target document, i.e. in any node and
   not just the root one.
   If there is no match for the first element of the \code{namespaces}
   vector, this is treated specially and is mapped to the
   default namespace of the target document. If there is no default
   namespace defined, an error occurs.

   It is best to give explicit the argument in the form
   \code{c(prefix = uri, prefix = uri)}.
   However, one can use the same namespace prefixes as in the document
   if one wants.  And one can use an arbitrary namespace prefix
   for the default namespace URI of the target document provided it is
   the first element of \code{namespaces}.

   See the 'Details' section below for some more information.
}
\usage{
getNodeSet(doc, path, namespaces = xmlNamespaceDefinitions(doc, simplify = TRUE), 
                    fun = NULL, sessionEncoding = CE_NATIVE, addFinalizer = NA, ...)
xpathApply(doc, path, fun, ... ,
            namespaces =  xmlNamespaceDefinitions(doc, simplify = TRUE),
              resolveNamespaces = TRUE, addFinalizer = NA)
xpathSApply(doc, path, fun = NULL, ... ,
             namespaces = xmlNamespaceDefinitions(doc, simplify = TRUE),
               resolveNamespaces = TRUE, simplify = TRUE, addFinalizer = NA)
matchNamespaces(doc, namespaces,
                 nsDefs = xmlNamespaceDefinitions(doc, recursive = TRUE, simplify = FALSE),
                 defaultNs = getDefaultNamespace(doc, simplify = TRUE))
}
\arguments{
  \item{doc}{an object of class \code{XMLInternalDocument}}
  \item{path}{a string (character vector of length 1) giving the
    XPath expression to evaluate.}
  \item{namespaces}{ a named character vector giving the
    namespace prefix and URI pairs that are to be used
    in the XPath expression and matching of nodes.
   The prefix is just a simple string that acts as a short-hand 
   or alias for the URI that is the unique identifier for the
   namespace.
   The URI is the element in this vector and the prefix is the
   corresponding element name.
    One only needs to specify the namespaces in the XPath expression and
    for the nodes of interest rather than requiring all the
    namespaces for the entire document.
    Also note that the prefix used in this vector is local only to the
    path. It does not have to be the same as the prefix used in the
    document to identify the namespace. However, the URI in this
    argument must be identical to the target namespace URI in the
    document.  It is the namespace URIs that are matched (exactly)
    to find correspondence. The prefixes are used only to refer to
    that URI.
  }
 \item{fun}{a function object, or an expression or call, which is used when the result is a node set
     and evaluated for each node element in the node set.  If this is a call, the first argument is replaced 
     with the current node.
 }
 \item{...}{any additional arguments to be passed to \code{fun} for each
   node in the node set.}
 \item{resolveNamespaces}{a logical value indicating whether
   to process the collection of namespaces and resolve those that have
   no name by looking in the default namespace and the namespace
   definitions within the target document to match by prefix.}
 \item{nsDefs}{a list giving the namespace definitions in which to match
  any prefixes. This is typically computed directly from the target
  document and the default value is most appropriate.}
\item{defaultNs}{the default namespace prefix-URI mapping given as a
  named character vector. This is not a namespace definition object.
  This is used when matching a simple prefix that has no corresponding
  entry in \code{nsDefs} and is the first element in the
  \code{namespaces} vector.
 }
 \item{simplify}{a logical value indicating whether the function
   should attempt to perform the simplification of the result
   into a vector rather  than leaving it as a list.
   This is the same as \code{\link[base]{sapply}} does
   in comparison to \code{\link[base]{lapply}}.
 }
%XXX
\item{sessionEncoding}{experimental functionality and parameter related
  to encoding.}
  \item{addFinalizer}{a logical value or identifier for a C routine
        that controls whether we register finalizers on the intenal node.}   
}
\details{
  When a namespace is defined on a node in the XML document,
  an XPath expressions must use a namespace, even if it is the default
  namespace for the XML document/node.
  For example, suppose we have an XML document
\code{<help xmlns="http://www.r-project.org/Rd"><topic>...</topic></help>}  
To find all the topic nodes, we might want to use
the XPath expression \code{"/help/topic"}.
However, we must use an explicit namespace prefix that is associated
with the URI \code{http://www.r-project.org/Rd} corresponding to the one in
the XML document.
So we would use
   \code{getNodeSet(doc, "/r:help/r:topic", c(r = "http://www.r-project.org/Rd"))}.

   As described above, the functions attempt to allow
   the namespaces to be specified easily by the R user
   and matched to the namespace definitions in the
   target document.
   
   
  This calls the libxml routine \code{xmlXPathEval}.
}
\value{
  The results can currently be different
  based on the returned value from the XPath expression evaluation:
  \item{list}{a node set}
  \item{numeric}{a number}
  \item{logical}{a boolean}
  \item{character}{a string, i.e. a single character element.}

  If \code{fun} is supplied and the result of the XPath query is a node set, 
  the result in R is a list.
}

\references{\url{http://xmlsoft.org}, 
  \url{http://www.w3.org/xml}
  \url{http://www.w3.org/TR/xpath}
  \url{http://www.omegahat.org/RSXML}
}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\note{
  In order to match nodes in the default name space for
 documents with a non-trivial default namespace, e.g. given as
  \code{xmlns="http://www.omegahat.org"}, you will need to use a prefix
  for the default namespace in this call.
  When specifying the namespaces, give a name - any name - to the
  default namespace URI and then use this as the prefix in the
  XPath expression, e.g.
  \code{getNodeSet(d, "//d:myNode", c(d = "http://www.omegahat.org"))}
  to match myNode in the default name space
  \code{http://www.omegahat.org}.
  
  This default namespace of the document is now computed for us and
  is the default value for the namespaces argument.
  It can be referenced using the prefix 'd',
  standing for default but sufficiently short to be
  easily used within the XPath expression.

  
  More of the XPath functionality provided by libxml can and may be
  made available to the R package.
  Facilities such as compiled XPath expressions, functions, ordered node
  information are examples.
   
  Please send requests to the package maintainer.
}

\seealso{
 \code{\link{xmlTreeParse}} with \code{useInternalNodes} as \code{TRUE}.
}
\examples{
 doc = xmlParse(system.file("exampleData", "tagnames.xml", package = "XML"))
 
 els = getNodeSet(doc, "/doc//a[@status]")
 sapply(els, function(el) xmlGetAttr(el, "status"))

   # use of namespaces on an attribute.
 getNodeSet(doc, "/doc//b[@x:status]", c(x = "http://www.omegahat.org"))
 getNodeSet(doc, "/doc//b[@x:status='foo']", c(x = "http://www.omegahat.org"))

   # Because we know the namespace definitions are on /doc/a
   # we can compute them directly and use them.
 nsDefs = xmlNamespaceDefinitions(getNodeSet(doc, "/doc/a")[[1]])
 ns = structure(sapply(nsDefs, function(x) x$uri), names = names(nsDefs))
 getNodeSet(doc, "/doc//b[@omegahat:status='foo']", ns)[[1]]

 # free(doc) 

 #####
 f = system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML") 
 e = xmlParse(f)
 ans = getNodeSet(e, "//o:Cube[@currency='USD']", "o")
 sapply(ans, xmlGetAttr, "rate")

  # or equivalently
 ans = xpathApply(e, "//o:Cube[@currency='USD']", xmlGetAttr, "rate", namespaces = "o")
 # free(e)



  # Using a namespace
 f = system.file("exampleData", "SOAPNamespaces.xml", package = "XML") 
 z = xmlParse(f)
 getNodeSet(z, "/a:Envelope/a:Body", c("a" = "http://schemas.xmlsoap.org/soap/envelope/"))
 getNodeSet(z, "//a:Body", c("a" = "http://schemas.xmlsoap.org/soap/envelope/"))
 # free(z)


  # Get two items back with namespaces
 f = system.file("exampleData", "gnumeric.xml", package = "XML") 
 z = xmlParse(f)
 getNodeSet(z, "//gmr:Item/gmr:name", c(gmr="http://www.gnome.org/gnumeric/v2"))

 #free(z)

 #####
 # European Central Bank (ECB) exchange rate data

  # Data is available from "http://www.ecb.int/stats/eurofxref/eurofxref-hist.xml"
  # or locally.

 uri = system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML")
 doc = xmlParse(uri)

   # The default namespace for all elements is given by
 namespaces <- c(ns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref")


     # Get the data for Slovenian currency for all time periods.
     # Find all the nodes of the form <Cube currency="SIT"...>

 slovenia = getNodeSet(doc, "//ns:Cube[@currency='SIT']", namespaces )

    # Now we have a list of such nodes, loop over them 
    # and get the rate attribute
 rates = as.numeric( sapply(slovenia, xmlGetAttr, "rate") )
    # Now put the date on each element
    # find nodes of the form <Cube time=".." ... >
    # and extract the time attribute
 names(rates) = sapply(getNodeSet(doc, "//ns:Cube[@time]", namespaces ), 
                      xmlGetAttr, "time")

    #  Or we could turn these into dates with strptime()
 strptime(names(rates), "\%Y-\%m-\%d")


   #  Using xpathApply, we can do
 rates = xpathApply(doc, "//ns:Cube[@currency='SIT']", xmlGetAttr, "rate", namespaces = namespaces )
 rates = as.numeric(unlist(rates))

   # Using an expression rather than  a function and ...
 rates = xpathApply(doc, "//ns:Cube[@currency='SIT']", quote(xmlGetAttr(x, "rate")), namespaces = namespaces )

 #free(doc)

   #
  uri = system.file("exampleData", "namespaces.xml", package = "XML")
  d = xmlParse(uri)
  getNodeSet(d, "//c:c", c(c="http://www.c.org"))

  getNodeSet(d, "/o:a//c:c", c("o" = "http://www.omegahat.org", "c" = "http://www.c.org"))

   # since http://www.omegahat.org is the default namespace, we can
   # just the prefix "o" to map to that.
  getNodeSet(d, "/o:a//c:c", c("o", "c" = "http://www.c.org"))


   # the following, perhaps unexpectedly but correctly, returns an empty
   # with no matches
   
  getNodeSet(d, "//defaultNs", "http://www.omegahat.org")

   # But if we create our own prefix for the evaluation of the XPath
   # expression and use this in the expression, things work as one
   # might hope.
  getNodeSet(d, "//dummy:defaultNs", c(dummy = "http://www.omegahat.org"))

   # And since the default value for the namespaces argument is the
   # default namespace of the document, we can refer to it with our own
   # prefix given as 
  getNodeSet(d, "//d:defaultNs", "d")

   # And the syntactic sugar is 
  d["//d:defaultNs", namespace = "d"]


   # this illustrates how we can use the prefixes in the XML document
   # in our query and let getNodeSet() and friends map them to the
   # actual namespace definitions.
   # "o" is used to represent the default namespace for the document
   # i.e. http://www.omegahat.org, and "r" is mapped to the same
   # definition that has the prefix "r" in the XML document.

  tmp = getNodeSet(d, "/o:a/r:b/o:defaultNs", c("o", "r"))
  xmlName(tmp[[1]])


  #free(d)


   # Work with the nodes and their content (not just attributes) from the node set.
   # From bondsTables.R in examples/

  doc = htmlTreeParse("http://finance.yahoo.com/bonds/composite_bond_rates", useInternalNodes = TRUE)
  if(is.null(xmlRoot(doc))) 
     doc = htmlTreeParse("http://finance.yahoo.com/bonds", useInternalNodes = TRUE)

     # Use XPath expression to find the nodes 
     #  <div><table class="yfirttbl">..
     # as these are the ones we want.

  if(!is.null(xmlRoot(doc))) {

   o = getNodeSet(doc, "//div/table[@class='yfirttbl']")

    # Write a function that will extract the information out of a given table node.
   readHTMLTable =
   function(tb)
    {
          # get the header information.
      colNames = sapply(tb[["thead"]][["tr"]]["th"], xmlValue)
      vals = sapply(tb[["tbody"]]["tr"],  function(x) sapply(x["td"], xmlValue))
      matrix(as.numeric(vals[-1,]),
              nrow = ncol(vals),
              dimnames = list(vals[1,], colNames[-1]),
              byrow = TRUE
            )
    }  


     # Now process each of the table nodes in the o list.
    tables = lapply(o, readHTMLTable)
    names(tables) = lapply(o, function(x) xmlValue(x[["caption"]]))
  }


     # this illustrates an approach to doing queries on a sub tree
     # within the document.
     # Note that there is a memory leak incurred here as we create a new
     # XMLInternalDocument in the getNodeSet().

    f = system.file("exampleData", "book.xml", package = "XML")
    doc = xmlParse(f)
    ch = getNodeSet(doc, "//chapter")
    xpathApply(ch[[2]], "//section/title", xmlValue)

      # To fix the memory leak, we explicitly create a new document for
      # the subtree, perform the query and then free it _when_ we are done
      # with the resulting nodes.
    subDoc = xmlDoc(ch[[2]])
    xpathApply(subDoc, "//section/title", xmlValue)
    free(subDoc)


    txt = '<top xmlns="http://www.r-project.org" xmlns:r="http://www.r-project.org"><r:a><b/></r:a></top>'
    doc = xmlInternalTreeParse(txt, asText = TRUE)

\dontrun{
     # Will fail because it doesn't know what the namespace x is
     # and we have to have one eventhough it has no prefix in the document.
    xpathApply(doc, "//x:b")
}    
      # So this is how we do it - just  say x is to be mapped to the
      # default unprefixed namespace which we shall call x!
    xpathApply(doc, "//x:b", namespaces = "x")

       # Here r is mapped to the the corresponding definition in the document.
    xpathApply(doc, "//r:a", namespaces = "r")
       # Here, xpathApply figures this out for us, but will raise a warning.
    xpathApply(doc, "//r:a")

       # And here we use our own binding.
    xpathApply(doc, "//x:a", namespaces = c(x = "http://www.r-project.org"))



       # Get all the nodes in the entire tree.
    table(unlist(sapply(doc["//*|//text()|//comment()|//processing-instruction()"],
    class)))




}
\keyword{file}
\keyword{IO}


