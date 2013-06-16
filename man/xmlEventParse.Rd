\name{xmlEventParse}
\alias{xmlEventParse}

\title{ XML Event/Callback element-wise Parser}
\description{
  This is the event-driven or SAX (Simple API for XML)
  style parser which process XML without building the tree
  but rather identifies tokens in the stream of characters
  and passes them to handlers which can make sense of them
  in context.
  This reads and processes the contents of an XML file or string by
  invoking user-level functions associated with different
  components of the XML tree. These components include
  the beginning and end  of XML elements, e.g
  \code{<myTag x="1">}
  and \code{</myTag>} respectively,
  comments, CDATA (escaped character data), entities, processing
 instructions, etc.
 This allows the caller to create the appropriate data structure from the
 XML document contents rather than the default tree (see
 \link{xmlTreeParse})
 and so avoids having the entire document in memory.
 This is important for large documents and where we would end up with
 essentially 2 copies of the data in memory at once, i.e
 the tree and the R data structure containing the information taken
 from the tree.
 When dealing with classes of XML documents whose instances could be large,
 this approach is desirable but a little more cumbersome to program
 than the standard DOM (Document Object Model) approach provided
 by \code{XMLTreeParse}.

 Note that \code{xmlTreeParse} does  allow a hybrid style of
 processing that allows us to apply handlers to nodes in the tree
 as they are being converted to R objects.  This is a style of
 event-driven or asynchronous calling

 In addition to the generic token event handlers such as
 "begin an XML element" (the \code{startElement} handler), one can 
 also provide handler functions for specific tags/elements such
 as \code{<myTag>} with handler elements  with the same name as the
 XML element of interest, i.e. \code{"myTag" = function(x, attrs)}.

 When the event parser is reading text nodes,
 it may call the text handler function with different
 sub-strings  of the text within the node.
 Essentially, the parser collects up n characters into a buffer and
 passes this as a single string the text handler and then continues
 collecting more text until the buffer is full or there is no more text.
 It passes each sub-string to the text handler.
 If \code{trim} is \code{TRUE}, it removes leading and trailing white
 space from the substring before calling the text handler. If the
 resulting text is empty and \code{ignoreBlanks} is \code{TRUE},
 then we don't bother calling the text handler function.

 So the key thing to remember about dealing with text is that the
 entire text of a node may come in multiple separate calls
 to the text handler. A common idiom is to have the text handler
 concatenate the values it is passed in separate calls and
 to have the end element handler process the entire text and reset
 the text variable to be empty.
}
\usage{
xmlEventParse(file, handlers = xmlEventHandler(), 
               ignoreBlanks = FALSE, addContext=TRUE,
                useTagName = TRUE, asText = FALSE, trim=TRUE, 
                 useExpat=FALSE, isURL = FALSE,
                  state = NULL, replaceEntities = TRUE, validate = FALSE,
                   saxVersion = 1, branches = NULL,
                    useDotNames = length(grep("^\\\\.", names(handlers))) > 0,
                     error = xmlErrorCumulator(), addFinalizer = NA)
}
\arguments{
  \item{file}{the source of the XML content.
    This can be a string giving the name of a file or remote URL,
    the XML itself, a connection object, or a function.
    If this is a string, and \code{asText} is \code{TRUE},
    the value is the XML content.
    This allows one to read the content separately from parsing
    without having to write it to a file.
    If \code{asText} is \code{FALSE} and a string is passed
    for \code{file}, this is taken as the name of a
    file or remote URI. If one is using the libxml parser (i.e. not expat),
    this can be a URI accessed via HTTP or FTP or a compressed local file.
    If it is the name of a local file,
    it can include \code{~}, environment variables, etc. which will be expanded by R.
    (Note this is not the case in S-Plus, as far as I know.)

    If a connection is given, the parser incrementally reads one line at
    a time by calling the function \code{\link[base]{readLines}} with
    the connection as the first argument (and \code{1} as the number of
    lines to read).  The parser calls this function each time it needs
    more input.

    If invoking the \code{readLines} function to get each line is
    excessively slow or is inappropriate, one can provide a function as the value
    of \code{fileName}. Again, when the XML parser needs more content
    to process, it invokes this function to get a string.
    This function is called with a single argument, the maximum size
    of the string that can be returned.
    The function is responsible for accessing the correct connection(s),
    etc. which is typically done via lexical scoping/environments.
    This mechanism allows the user to control how the XML content
    is retrieved in very general ways. For example, one might
    read from a set of files, starting one when the contents
    of the previous file have been consumed. This allows for the
    use of hybrid connection objects.

    Support for connections and functions in this form is only
    provided if one is using libxml2 and not libxml version 1.
}
 \item{handlers}{ a closure object that contains  functions which will be invoked
as the XML components in the document are encountered by the parser. 
 The standard function or handler names are
\code{startElement()}, \code{endElement()}
\code{comment()}, \code{getEntity},
\code{entityDeclaration()}, \code{processingInstruction()},
\code{text()}, \code{cdata()},
\code{startDocument()}, and \code{endDocument()},
or alternatively and preferrably,
these names  prefixed with a '.',
i.e. .startElement, .comment, ...


The call signature for the entityDeclaration function was changed in
version 1.7-0.  Note that in earlier versions, the C routine did not
invoke any R function and so no code will actually break.
Also, we have renamed \code{externalEntity} to \code{getEntity}.
These were based on the expat parser.

The new signature is
\code{c(name = "character",
        type = "integer",
	content = "",
        system = "character",
        public = "character"
)}
\code{name} gives the name of the entity being
defined.
The \code{type} identifies
the type of the entity using the value
of a C-level enumerated constant used in libxml2,
but also gives the human-readable form
as the name of the single element in the integer vector.
The possible values are
\code{"Internal_General"},
\code{"External_General_Parsed"},
\code{"External_General_Unparsed"}, \code{"Internal_Parameter"},
\code{"External_Parameter"}, \code{"Internal_Predefined"}.

If we are dealing with an internal entity,
the content will be the string containing
the value of the entity.
If we are dealing with an external entity,
then \code{content} will be a character vector of length
0, i.e. empty.
Instead, either or both of the system and public
arguments will be non-empty and identify the
location of the external content.
\code{system} will be a string containing a URI, if non-empty,
and \code{public} corresponds to the PUBLIC identifier used
to identify content using an SGML-like approach.
The use of PUBLIC identifiers is less common.
}
 \item{ignoreBlanks}{a logical value indicating whether
text elements made up entirely of white space should be included
in the resulting `tree'. }
 \item{addContext}{ logical value indicating whether the callback functions 
in `handlers' should be invoked with contextual  information about
the parser and the position in the tree, such as node depth, 
path indices for the node relative the root, etc.
If this is True, each callback function  should support 
\dots.
}
 \item{useTagName}{ a logical value.
 If this is \code{TRUE}, when the SAX parser signals an event for the
 start of an XML element, it will first look for an element in the
 list of handler functions whose name matches (exactly) the name of
 the XML element.  If such an element is found, that function is
 invoked.  Otherwise, the generic \code{startElement} handler function
 is invoked.  The benefit of this is that the author of the handler
 functions can write node-specific handlers for the different element
 names in a document and not have to establish a mechanism to invoke
 these functions within the \code{startElement} function. This is done
 by the XML package directly.
 
 If the value is \code{FALSE}, then the \code{startElement} handler
 function will be called without any effort to find a node-specific
 handler.  If there are no node-specific handlers, specifying
 \code{FALSE} for this parameter will make the computations very
 slightly faster.
}
  \item{asText}{logical value indicating that the first argument,
    `file', 
     should be treated as the XML text to parse, not the name of 
     a file. This allows the contents of documents to be retrieved 
     from different sources (e.g. HTTP servers, XML-RPC, etc.) and still
     use this parser.}
 \item{trim}{
  whether to strip white space from the beginning and end of text strings.
}
% \item{restartCounter}{}
 \item{useExpat}{
   a logical value indicating whether to use the expat SAX parser,
  or to default to the libxml.
   If this is TRUE, the library must have been compiled with support for expat.
   See \link{supportsExpat}.
 }
 \item{isURL}{
   indicates whether the \code{file}  argument refers to a URL
  (accessible via ftp or http) or a regular file on the system.
  If \code{asText} is TRUE, this should not be specified.
}
\item{state}{an optional S object that is passed to the
  callbacks and can be modified to communicate state between
  the callbacks. If this is given, the callbacks should accept
  an argument  named \code{.state} and it should return an object
  that will be used as the updated value of this state object.
  The new value can be any S object and will be passed to the next 
  callback where again it will be updated by that functions return
  value, and so on. 
  If this not specified in the call to \code{xmlEventParse},
  no \code{.state} argument is passed to the callbacks. This makes the
  interface compatible with previous releases.
  }
  \item{replaceEntities}{
   logical value indicating whether to substitute entity references
    with their text directly. This should be left as False.
    The text still appears as the value of the node, but there
    is more information about its source, allowing the parse to be reversed
    with full reference information.
  }
  \item{saxVersion}{an integer value which should be either 1 or 2.
    This specifies which SAX interface to use in the C code.
    The essential difference is the number of arguments passed to the
    \code{startElement} handler function(s).  Under SAX 2, in addition to the name of
    the element and the named-attributes vector, two additional arguments
    are provided.
    The first identifies the namespace of the element.
    This is a named character vector of length 1,
    with the value being the URI of the namespace and the name
    being the prefix that identifies that namespace within the document.
    For example, \code{xmlns:r="http://www.r-project.org"}
    would be passed as \code{c(r = "http://www.r-project.org")}.
    If there is no prefix because the namespace is being used as the
    default, the result of calling \code{\link[base]{names}} on
    the string is \code{""}.
    The second additional argument (the fourth in total) gives the collection of all the namespaces
    defined within this element.
    Again, this is a named character vector.
  }
  \item{validate}{
  Currently, this has no effect as the libxml2 parser uses a
  document structure to do validation.
  a logical indicating whether to use a validating parser or not, or in other words
  check the contents against the DTD specification. If this is true, warning
  messages will be displayed about errors in the DTD and/or document, but the parsing 
  will proceed except for the presence of terminal errors.
}
\item{branches}{a named list of functions.
  Each element identifies an XML element name.
  If an XML element of that name is encountered in
  the SAX stream, the stream is processed until the
  end of that element and an internal node (see
  \code{\link{xmlTreeParse}} and its \code{useInternalNodes} parameter)
  is created. The function in our branches list corresponding to this
  XML element is then invoked with the (internal) node as the only
  argument.
  This allows one to use the DOM model on a sub-tree of the entire
  document and thus use both SAX and DOM together to get the
  efficiency of SAX and the simpler programming model of DOM.

  Note that the branches mechanism works top-down and does not
  work for nested tags. If one specifies an element name in the
  \code{branches} argument, e.g. myNode, and
  there is a nested myNode instance within a branch, the branches
  handler will not be called for that nested instance.
  If there is an instance where this is problematic, please
  contact the maintainer of this package.

  One can cause the parser to collect a branch without identifying
  the  node within the \code{branches} list. Specifically, within
  a  regular start-element handler, one can return a function 
  whose class is \code{SAXBranchFunction}.
  The SAX parser recognizes this and collects up the branch
  starting at the current node being processed  and when it is
  complete, invokes this function. 
  This allows us to dynamically determine which nodes to treat as
  branches rather than just matching names. This is necessary when
  a node name has different meanings in different parts of the XML
  hierarchy, e.g. dict in an iTunes song list.

  See the file \code{itunesSax2.R} inthe examples for an example of this.

  This is a two step process. In the future, we might make it so that
  the R function handling the start-element event could directly
  collect  the branch and continue its operations without having
  to call another function asynchronously.
}
\item{useDotNames}{a logical value
  indicating whether to use the
  newer format for identifying general element function handlers
  with the '.' prefix, e.g. .text, .comment, .startElement.
  If this is \code{FALSE}, then the older format
  text, comment, startElement, ...
  are used. This causes problems when there are indeed nodes
  named text or comment or startElement as a
  node-specific handler are confused with the corresponding
  general handler of the same name. Using \code{TRUE}
  means that your list of handlers should have names that use
  the '.' prefix for these general element handlers.
  This is the preferred way to write new code.
}
\item{error}{a function that is called when an XML error is encountered.
   This is called with 6 arguments and is described in \code{\link{xmlTreeParse}}.
 }
\item{addFinalizer}{a logical value or identifier for a C routine
        that controls whether we register finalizers on the intenal node.}
}
\details{
 This is now implemented using the libxml parser.
 Originally, this was implemented via the Expat XML parser by
 Jim Clark (\url{http://www.jclark.com}).
}
\value{
  The return value is the `handlers'
argument. It is assumed that this is a closure and that
the callback functions have manipulated variables
local to it and that the caller knows how to extract this.
}

\references{\url{http://www.w3.org/XML}, \url{http://www.jclark.com/xml}}
\author{Duncan Temple Lang}
\note{
 The libxml parser can read URLs via http or ftp.
 It does not require the support of \code{wget} as used
 in other parts of \R, but uses its own facilities
 to connect to remote servers.

 The idea for the hybrid SAX/DOM mode where we consume tokens in the
 stream to create an entire node for a sub-tree of the document was
 first suggested to me by Seth Falcon at the Fred Hutchinson Cancer
 Research Center.  It is similar to the  XML::Twig module in Perl
 by Michel Rodriguez.
}

\seealso{
  \code{\link{xmlTreeParse}}
  \code{\link{xmlStopParser}}
  XMLParserContextFunction
}

\examples{
 fileName <- system.file("exampleData", "mtcars.xml", package="XML")

   # Print the name of each XML tag encountered at the beginning of each
   # tag.
   # Uses the libxml SAX parser.
 xmlEventParse(fileName,
                list(startElement=function(name, attrs){
                                    cat(name,"\n")
                                  }),
                useTagName=FALSE, addContext = FALSE)


\dontrun{
  # Parse the text rather than a file or URL by reading the URL's contents
  # and making it a single string. Then call xmlEventParse
xmlURL <- "http://www.omegahat.org/Scripts/Data/mtcars.xml"
xmlText <- paste(scan(xmlURL, what="",sep="\n"),"\n",collapse="\n")
xmlEventParse(xmlText, asText=TRUE)
}

    # Using a state object to share mutable data across callbacks
f <- system.file("exampleData", "gnumeric.xml", package = "XML")
zz <- xmlEventParse(f,
                    handlers = list(startElement=function(name, atts, .state) {
                                                     .state = .state + 1
                                                     print(.state)
                                                     .state
                                                 }), state = 0)
print(zz)




    # Illustrate the startDocument and endDocument handlers.
xmlEventParse(fileName,
               handlers = list(startDocument = function() {
                                                 cat("Starting document\n")
                                               },
                               endDocument = function() {
                                                 cat("ending document\n")
                                             }),
               saxVersion = 2)




if(libxmlVersion()$major >= 2) {


 startElement = function(x, ...) cat(x, "\n")

 xmlEventParse(file(f), handlers = list(startElement = startElement))


 # Parse with a function providing the input as needed.
 xmlConnection = 
  function(con) {

   if(is.character(con))
     con = file(con, "r")
  
   if(isOpen(con, "r"))
     open(con, "r")

   function(len) {

     if(len < 0) {
        close(con)
        return(character(0))
     }

      x = character(0)
      tmp = ""
    while(length(tmp) > 0 && nchar(tmp) == 0) {
      tmp = readLines(con, 1)
      if(length(tmp) == 0)
        break
      if(nchar(tmp) == 0)
        x = append(x, "\n")
      else
        x = tmp
    }
    if(length(tmp) == 0)
      return(tmp)
  
    x = paste(x, collapse="")

    x
  }
 }

 ff = xmlConnection(f)
 xmlEventParse(ff, handlers = list(startElement = startElement))

  # Parse from a connection. Each time the parser needs more input, it
  # calls readLines(<con>, 1)
 xmlEventParse(file(f),  handlers = list(startElement = startElement))


  # using SAX 2
 h = list(startElement = function(name, attrs, namespace, allNamespaces){ 
                                 cat("Starting", name,"\n")
                                 if(length(attrs))
                                     print(attrs)
                                 print(namespace)
                                 print(allNamespaces)
                         },
          endElement = function(name, uri) {
                          cat("Finishing", name, "\n")
            }) 
 xmlEventParse(system.file("exampleData", "namespaces.xml", package="XML"), handlers = h, saxVersion = 2)


 # This example is not very realistic but illustrates how to use the
 # branches argument. It forces the creation of complete nodes for
 # elements named <b> and extracts the id attribute.
 # This could be done directly on the startElement, but this just
 # illustrates the mechanism.
 filename = system.file("exampleData", "branch.xml", package="XML")
 b.counter = function() {
                nodes <- character()
                f = function(node) { nodes <<- c(nodes, xmlGetAttr(node, "id"))}
                list(b = f, nodes = function() nodes)
             }

  b = b.counter()
  invisible(xmlEventParse(filename, branches = b["b"]))
  b$nodes()


  filename = system.file("exampleData", "branch.xml", package="XML")
   
  invisible(xmlEventParse(filename, branches = list(b = function(node) {print(names(node))})))
  invisible(xmlEventParse(filename, branches = list(b = function(node) {print(xmlName(xmlChildren(node)[[1]]))})))
}

  
  ############################################
  # Stopping the parser mid-way and an example of using XMLParserContextFunction.

  startElement =
  function(ctxt, name, attrs, ...)  {
    print(ctxt)
      print(name)
      if(name == "rewriteURI") {
           cat("Terminating parser\n")
	   xmlStopParser(ctxt)
      }
  }
  class(startElement) = "XMLParserContextFunction"  
  endElement =
  function(name, ...) 
    cat("ending", name, "\n")

  fileName = system.file("exampleData", "catalog.xml", package = "XML")
  xmlEventParse(fileName, handlers = list(startElement = startElement, endElement = endElement))
}
\keyword{file}
\keyword{IO}
