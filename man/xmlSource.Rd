\name{xmlSource}
\alias{xmlSource}
\alias{xmlSource,character-method}
\alias{xmlSource,XMLNodeSet-method}
\alias{xmlSource,XMLInternalDocument-method}

\alias{xmlSourceFunctions}
\alias{xmlSourceFunctions,character-method}
\alias{xmlSourceFunctions,XMLInternalDocument-method}
\alias{xmlSourceSection}
\alias{xmlSourceSection,character-method}
\alias{xmlSourceSection,XMLInternalDocument-method}


\alias{xmlSourceThread}
\alias{xmlSourceThread,XMLInternalDocument-method}
\alias{xmlSourceThread,character-method}
\alias{xmlSourceThread,list-method}

\title{Source the R code, examples, etc. from an XML document}
\description{
  This is the equivalent of a smart \code{\link[base]{source}}
  for extracting the R code elements from an XML document and
  evaluating them. This allows for a \dQuote{simple} way to collect
  R functions definitions or a sequence of (annotated) R code segments in an XML
  document along with other material such as notes, documentation,
  data, FAQ entries, etc.,  and still  be able to
  access the R code directly from within an R session.
  The approach enables one to use the XML document as a container for
  a heterogeneous collection of related material, some of which
  is R code.
  In the literate programming parlance, this function essentially
  dynamically "tangles" the document within R, but can work on
  small subsets of it that are easily specified in the
  \code{xmlSource} function call.
  This is a convenient way to annotate code in a rich way
  and work with source files in a new and potentially more effective
  manner.
  
  \code{xmlSourceFunctions} provides a convenient way to read only
  the function definitions, i.e. the \code{<r:function>} nodes.
  We can restrict to a subset by specifying the node ids of interest.

  \code{xmlSourceSection} allows us to evaluate the code in one or more
  specific sections.
  
  This style of authoring code supports mixed language support
  in which we put, for example, C and R code together in the same
  document.
  Indeed, one can use the document to store arbitrary content
  and still retrieve the R code.  The more structure there is,
  the easier it is to create tools to extract that information
  using XPath expressions.

  We can identify individual \code{r:code} nodes in the document to
  process, i.e. evaluate. We do this using their \code{id} attribute
  and specifying which to process via the \code{ids} argument.
  Alternatively, if a document has a node \code{r:codeIds} as a child of
  the top-level node (or within an invisible node), we read its contents as  a sequence of line
  separated \code{id} values as if they had been specified via the
  argument \code{ids} to this function.

  
  We can also use XSL to extract the code. See \code{getCode.xsl}
  in the Omegahat XSL collection.

  This particular version (as opposed to other implementations) uses
  XPath to conveniently find the nodes of interest.
}
\usage{
xmlSource(url, ...,
          envir = globalenv(),
          xpath = character(),
          ids = character(),
          omit = character(),
          ask = FALSE,
          example = NA,
          fatal = TRUE, verbose = TRUE, echo = verbose, print = echo,
          xnodes = DefaultXMLSourceXPath,
          namespaces = DefaultXPathNamespaces, section = character(),
          eval = TRUE, init = TRUE, setNodeNames = FALSE, parse = TRUE,
          force = FALSE)
xmlSourceFunctions(doc, ids = character(), parse = TRUE, ...)
xmlSourceSection(doc, ids = character(),
                 xnodes = c(".//r:function", ".//r:init[not(@eval='false')]", 
                            ".//r:code[not(@eval='false')]",
                            ".//r:plot[not(@eval='false')]"),
                 namespaces = DefaultXPathNamespaces, ...)
}
\arguments{
  \item{url}{the name of the file, URL  containing the XML document, or
    an XML string. This is passed to \code{\link[XML]{xmlTreeParse}}
    which is called with \code{useInternalNodes = TRUE}.
  }
  \item{\dots}{additional arguments passed to \code{\link[XML]{xmlTreeParse}}}
  \item{envir}{the environment in which the code elements of the XML
    document are to be evaluated. By default, they are evaluated
    in the global environment so that assignments take place there.
  }
  \item{xpath}{a string giving an XPath expression which is used after
    parsing the document to filter the document to a particular subset of
    nodes.  This allows one to restrict the evaluation to a subset of
    the original document. One can do this directly by
    parsing the XML document, applying the XPath query and then passing
    the resulting node set to this \code{xmlSource} function's
    appropriate method.  This argument merely allows for a more
    convenient form of those steps, collapsing it into one action.
  }
  \item{ids}{a character vector.  XML nodes containing R code
    (e.g. \code{r:code}, \code{r:init}, \code{r:function},
    \code{r:plot}) can have an id attribute. This vector
    allows the caller to specify the subset of these nodes
    to process, i.e. whose code will be evaluated.
    The order is currently not important. It may be used
    in the future to specify the order in which the nodes are evaluated.

    If this is not specified and the document has a node
    \code{r:codeIds} as an immediate child of the top-most node,
    the contents of this node or contained within an \code{invisible}
    node (so that it doesn't have to be filtered when rendering the
    document), the names of the r:code id values to process are taken
    as the individual lines from the body of this node.
  }
  \item{omit}{a character vector. The values of the id attributes of the
    nodes that we want to skip or omit from the evaluation. This allows
    us to specify the set that we don't want evaluated, in contrast to the
    \code{ids} argument.
    The order is not important.
  }
  \item{ask}{logical}
  \item{example}{a character or numeric vector specifying the values of the id
    attributes of any \code{r:example} nodes in the document.
    A single document may contain numerous, separate examples
    and these can be marked uniquely using an \code{id} attribute,
    e.g. \code{<r:example id=''}.  This argument allows the caller to
    specify which example (or examples) to run.
    If this is not specified by the caller and there are r:example
    nodes in the document, the user is prompted to select an example via
    a (text-based) menu.
    If a character vector is given by the caller, we use
    partial matching against the collection of \code{id} attributes
    of the r:example nodes to identify the examples of interest.
    Alternatively, one can specify the example(s) to run by number.
  }
  \item{fatal}{(currently unused) a logical value. The idea is to
    control how we handle errors when evaluating individual code
    segments.  We could recover from errors and continue processing
    subsequent nodes.}
  \item{verbose}{a logical value. If \code{TRUE}, information about what
   code segments are being evaluated is displayed on the console.
   \code{echo} controls whether code is displayed, but this controls
   whether additional informatin is also displayed.
   See \code{\link[base]{source}}.
  }
  \item{xnodes}{a character vector.  This is a collection of xpath
    expressions given as individual strings which find the
    nodes whose contents we evaluate.
  }
 \item{echo}{a logical value indicating whether to display the code
    before it is evaluated.}
  \item{namespaces}{a named character vector (i.e. name = value pairs of
    strings) giving the prefix - URI pairings for the namespaces used in
    the XPath expressions. The URIs must match those in the document,
    but the prefixes are local to the XPath expression.
    The default provides mappings for the prefixes "r", "omg",
    "perl", "py", and so on. See \code{XML:::DefaultXPathNamespaces}.
  }    
 \item{section}{a vector of numbers or  strings.  This allows the caller to 
   specify that the function should only look for R-related 
  nodes within the specified section(s). This is useful
  for being able to easily  process only the code in a particular subset of the document
  identified by a DocBook \code{section} node.  A string value is used to
    match  the \code{id} attribute of the \code{section} node.
   A number (assumed to be an integer) is used to index the set of 
  \code{section} nodes. These amount to XPath expressions of the form
  \code{//section[number]} and \code{//section[@id = string]}.
  }
  \item{print}{a logical value indicating whether to print the results}
  \item{eval}{a logical value indicating whether to evaluate the code in
  the specified nodes or to just return the result of parsing the text
  in each node.}
 \item{init}{a logical controlling whether to run the R code in any
    r:init nodes.}
 \item{doc}{the XML document, either a file name, the content of the document or the parsed document.}
 \item{parse}{a logical value that controls whether we parse the code or
   just return the text representation from the XML without parsing it.
   This allows us to get just the code.}
 \item{setNodeNames}{a logical value that controls whether we compute
    the name for each node (or result) by finding is id or name
    attribute or enclosing task node.
  }
  \item{force}{a logical value. If this is \code{TRUE}, the function
    will evaluate the code in a node even if it is explicitly marked
  as not to be evaluated with \code{eval = "false"}, either on the node
    itself or an ancestor.}
}
\details{
  This evaluates the \code{code}, \code{function} and \code{example}
  elements in the XML content that have the appropriate namespace
  (i.e. r, s, or no namespace)
  and discards all others. It also discards r:output nodes
  from the text, along with processing instructions and comments.
  And it resolves \code{r:frag} or \code{r:code} nodes with a \code{ref}
  attribute by identifying the corresponding \code{r:code} node with the
  same value for its \code{id} attribute and then evaluating that node
  in place of the \code{r:frag} reference.
}
\value{
  An R object (typically a list) that contains the results of
  evaluating the content of the different selected code segments
  in the XML document.  We use \code{\link[base]{sapply}} to
  iterate over the nodes and so If the results of all the nodes
  A list giving the pairs of expressions and evaluated objects
  for each of the different XML elements processed.
}

\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
 \code{\link[XML]{xmlTreeParse}}
}

\examples{
 xmlSource(system.file("exampleData", "Rsource.xml", package="XML"))

  # This illustrates using r:frag nodes.
  # The r:frag nodes are not processed directly, but only
  # if referenced in the contents/body of a r:code node
 f = system.file("exampleData", "Rref.xml", package="XML")
 xmlSource(f)
}
\keyword{IO}
\keyword{programming}
\concept{Annotated code}
\concept{Literate Programming}
\concept{Mixed language}
