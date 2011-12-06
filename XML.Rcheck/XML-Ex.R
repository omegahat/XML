pkgname <- "XML"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('XML')

assign(".oldSearch", search(), pos = 'CheckExEnv')
cleanEx()
nameEx("AssignXMLNode")
### * AssignXMLNode

flush(stderr()); flush(stdout())

### Name: [<-.XMLNode
### Title: Assign sub-nodes to an XML node
### Aliases: [<-.XMLNode [[<-.XMLNode
### Keywords: IO file

### ** Examples

 top <- xmlNode("top", xmlNode("next","Some text"))
 top[["second"]] <- xmlCDataNode("x <- 1:10")
 top[[3]] <- xmlNode("tag",attrs=c(id="name"))



cleanEx()
nameEx("Doctype-class")
### * Doctype-class

flush(stderr()); flush(stdout())

### Name: Doctype-class
### Title: Class to describe a reference to an XML DTD
### Aliases: Doctype-class
### Keywords: classes

### ** Examples

  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN", "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd"))  



cleanEx()
nameEx("Doctype")
### * Doctype

flush(stderr()); flush(stdout())

### Name: Doctype
### Title: Constructor for DTD reference
### Aliases: Doctype coerce,Doctype,character-method
### Keywords: IO

### ** Examples


  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN", "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd"))
  as(d, "character")

   # this call switches the system to the URI associated with the PUBLIC element.
  d = Doctype(name = "section", public = c("-//OASIS//DTD DocBook XML V4.2//EN"), system = "http://oasis-open.org/docbook/xml/4.2/docbookx.dtd")



cleanEx()
nameEx("SAXState-class")
### * SAXState-class

flush(stderr()); flush(stdout())

### Name: SAXState-class
### Title: A virtual base class defining methods for SAX parsing
### Aliases: SAXState-class
### Keywords: classes

### ** Examples


# For each element in the document, grab the node name
# and increment the count in an vector for this name.

# We define an S4 class named ElementNameCounter which
# holds the vector of frequency counts for the node names.

 setClass("ElementNameCounter",
             representation(elements = "integer"), contains = "SAXState")

# Define a method for handling the opening/start of any XML node
# in the SAX streams.

 setMethod("startElement.SAX",  c(.state = "ElementNameCounter"),
           function(name, atts, .state = NULL) {

             if(name %in% names(.state@elements))
                 .state@elements[name] = as.integer(.state@elements[name] + 1)
             else
                 .state@elements[name] = as.integer(1)
             .state
           })

 filename = system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML")

# Parse the file, arranging to have our startElement.SAX method invoked.
 z = xmlEventParse(filename, genericSAXHandlers(), state = new("ElementNameCounter"), addContext = FALSE)

 z@elements

  # Get the contents of all the comments in a character vector.

 setClass("MySAXState",
             representation(comments = "character"), contains = "SAXState")

 setMethod("comment.SAX",  c(.state = "MySAXState"),
           function(content, .state = NULL) {
             cat("comment.SAX called for MySAXState\n")
             .state@comments <- c(.state@comments, content)
             .state
           })

 filename = system.file("exampleData", "charts.svg", package = "XML")
 st = new("MySAXState")
 z = xmlEventParse(filename, genericSAXHandlers(useDotNames = TRUE), state = st)
 z@comments





cleanEx()
nameEx("XMLInternalDocument")
### * XMLInternalDocument

flush(stderr()); flush(stdout())

### Name: XMLInternalDocument-class
### Title: Class to represent reference to C-level data structure for an
###   XML document
### Aliases: XMLAbstractDocument-class XMLInternalDocument-class
###   HTMLInternalDocument-class
###   coerce,XMLInternalNode,XMLInternalDocument-method
###   coerce,XMLInternalDocument,XMLInternalNode-method
### Keywords: classes

### ** Examples


 f = system.file("exampleData", "mtcars.xml", package="XML")
 doc = xmlParse(f)
 getNodeSet(doc, "//variables[@count]")
 getNodeSet(doc, "//record")

 getNodeSet(doc, "//record[@id='Mazda RX4']")

 # free(doc)



cleanEx()
nameEx("XMLNode-class")
### * XMLNode-class

flush(stderr()); flush(stdout())

### Name: XMLNode-class
### Title: Classes to describe an XML node object.
### Aliases: XMLAbstractNode-class XMLAbstractNode-class RXMLNode-class
###   XMLNode-class XMLTreeNode-class XMLInternalNode-class
###   XMLInternalTextNode-class XMLInternalElementNode-class
###   XMLInternalCommentNode-class XMLInternalPINode-class
###   XMLInternalCDataNode-class XMLAttributeDeclNode-class
###   XMLDocumentFragNode-class XMLDocumentNode-class
###   XMLDocumentTypeNode-class XMLEntityDeclNode-class
###   XMLNamespaceDeclNode-class XMLXIncludeStartNode-class
###   XMLXIncludeEndNode-class XMLDTDNode-class
###   coerce,XMLAbstractNode,Date-method
###   coerce,XMLAbstractNode,POSIXct-method
###   coerce,XMLAbstractNode,URL-method
###   coerce,XMLAbstractNode,character-method
###   coerce,XMLAbstractNode,integer-method
###   coerce,XMLAbstractNode,logical-method
###   coerce,XMLAbstractNode,numeric-method XMLNamespaceDefinitions-class
### Keywords: classes

### ** Examples


           # An R-level XMLNode object
   a <- xmlNode("arg", attrs = c(default="T"),
                 xmlNode("name", "foo"), xmlNode("defaultValue","1:10"))

  xmlAttrs(a) = c(a = 1, b = "a string")



cleanEx()
nameEx("addChildren")
### * addChildren

flush(stderr()); flush(stdout())

### Name: addChildren
### Title: Add child nodes to an XML node
### Aliases: addChildren xmlParent<- removeChildren removeNodes
###   removeNodes.list removeNodes.XMLNodeSet removeNodes.XMLInternalNode
###   replaceNodes addAttributes removeAttributes
###   addChildren,XMLInternalNode-method addChildren,XMLNode-method
###   addAttributes,XMLInternalElementNode-method
###   addAttributes,XMLNode-method
###   removeAttributes,XMLInternalElementNode-method
###   removeAttributes,XMLNode-method
### Keywords: IO programming

### ** Examples


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

## Not run: 
##D     # this won't work as the 10 gets coerced to a 
##D     # character vector element to be combined with 'w'
##D     # and there is no node name 10.
##D  removeChildren(b, kids = c(10, "w"))
## End(Not run)


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




cleanEx()
nameEx("addNode")
### * addNode

flush(stderr()); flush(stdout())

### Name: addNode
### Title: Add a node to a tree
### Aliases: addNode addNode.XMLHashTree
### Keywords: IO

### ** Examples


  tt = xmlHashTree()

  top = addNode(xmlNode("top"), character(), tt)
  addNode(xmlNode("a"), top, tt)
  b = addNode(xmlNode("b"), top, tt)
  c = addNode(xmlNode("c"), b, tt)
  addNode(xmlNode("c"), top, tt)
  addNode(xmlNode("c"), b, tt)    
  addNode(xmlTextNode("Some text"), c, tt)

  xmlElementsByTagName(tt$top, "c")

  tt



cleanEx()
nameEx("addSibling")
### * addSibling

flush(stderr()); flush(stdout())

### Name: getSibling
### Title: Manipulate sibling XML nodes
### Aliases: getSibling addSibling
### Keywords: IO

### ** Examples

  
          # Reading Apple's iTunes files
     # 
     #           Here we read  a "censored" "database" of songs from Apple's  iTune application
     #           which is stored in a property list.  The format is quite generic and 
     #            the fields for each song are given in the form
     #           
     #             <key>Artist</key><string>Person's name</string>
     # 	  
     #           So to find the names of the artists for all the songs, we want to 
     #           find all the <key>Artist<key> nodes and then get their next sibling
     #           which has the actual value.
     #         
     #           More information can be found in .
     # 	
           fileName = system.file("exampleData", "iTunes.plist", package = "XML")

           doc = xmlParse(fileName)
           nodes = getNodeSet(doc, "//key[text() = 'Artist']")
           sapply(nodes, function(x)  xmlValue(getSibling(x)))
	

      f = system.file("exampleData", "simple.xml", package = "XML")
      tt = as(xmlParse(f), "XMLHashTree") 

       tt

      e = getSibling(xmlRoot(tt)[[1]])
        # and back to the first one again by going backwards along the sibling list.
      getSibling(e, after = FALSE)


         # This also works for multiple top-level "root" nodes
      f = system.file("exampleData", "job.xml", package = "XML")
      tt = as(xmlParse(f), "XMLHashTree")
       x = xmlRoot(tt, skip = FALSE)
       getSibling(x)
       getSibling(getSibling(x), after = FALSE)



cleanEx()
nameEx("append.XMLNode")
### * append.XMLNode

flush(stderr()); flush(stdout())

### Name: append.xmlNode
### Title: Add children to an XML node
### Aliases: append.xmlNode append.XMLNode
### Keywords: file IO

### ** Examples

  # Create a very simple representation of a simple dataset.
  # This is just an example. The result is
   # <data numVars="2" numRecords="3">
   # <varNames>
   #  <string>
   #   A
   #  </string>
   #  <string>
   #   B
   #  </string>
   # </varNames>
   # <record>
   #  1.2 3.5
   # </record>
   # <record>
   #  20.2 13.9
   # </record>
   # <record>
   #  10.1 5.67
   # </record>
   # </data>


 n = xmlNode("data", attrs = c("numVars" = 2, numRecords = 3))
 n = append.xmlNode(n, xmlNode("varNames", xmlNode("string", "A"), xmlNode("string", "B")))
 n = append.xmlNode(n, xmlNode("record", "1.2 3.5"))
 n = append.xmlNode(n, xmlNode("record", "20.2 13.9"))
 n = append.xmlNode(n, xmlNode("record", "10.1 5.67"))

 print(n)


## Not run: 
##D    tmp <-  lapply(references, function(i) {
##D                                   if(!inherits(i, "XMLNode"))
##D                                     i <- xmlNode("reference", i)
##D                                   i
##D                               })
##D 
##D    r <- xmlNode("references")
##D    r[["references"]] <- append.xmlNode(r[["references"]], tmp)
## End(Not run)



cleanEx()
nameEx("asXMLNode")
### * asXMLNode

flush(stderr()); flush(stdout())

### Name: asXMLNode
### Title: Converts non-XML node objects to XMLTextNode objects
### Aliases: asXMLNode coerce,XMLInternalNode,XMLNode-method
### Keywords: file

### ** Examples

   # creates an XMLTextNode.
 asXMLNode("a text node")

   # unaltered.
 asXMLNode(xmlNode("p"))



cleanEx()
nameEx("catalogResolve")
### * catalogResolve

flush(stderr()); flush(stdout())

### Name: catalogResolve
### Title: Look up an element via the XML catalog mechanism
### Aliases: catalogResolve
### Keywords: IO

### ** Examples


if(!exists("Sys.setenv")) Sys.setenv = Sys.putenv

Sys.setenv("XML_CATALOG_FILES" = system.file("exampleData", "catalog.xml", package = "XML"))



catalogResolve("-//OASIS//DTD DocBook XML V4.4//EN", "public")

catalogResolve("http://www.omegahat.org/XSL/foo.xsl")

catalogResolve("http://www.omegahat.org/XSL/article.xsl", "uri")
catalogResolve("http://www.omegahat.org/XSL/math.xsl", "uri")


  # This one does not resolve anything, returning an empty value.
catalogResolve("http://www.oasis-open.org/docbook/xml/4.1.2/foo.xsl", "uri")


   # Vectorized and returns NA for the first and /tmp/html.xsl
   # for the second.

 catalogAdd("http://made.up.domain", "/tmp")
 catalogResolve(c("ddas", "http://made.up.domain/html.xsl"), asIs = TRUE)



cleanEx()
nameEx("catalogs")
### * catalogs

flush(stderr()); flush(stdout())

### Name: catalogLoad
### Title: Manipulate XML catalog contents
### Aliases: catalogLoad catalogClearTable catalogAdd catalogDump
### Keywords: IO

### ** Examples

  
          # Add a rewrite rule
     # 
     # 	
          catalogAdd(c("http://www.omegahat.org/XML" = system.file("XML", package = "XML")))
          catalogAdd("http://www.omegahat.org/XML", system.file("XML", package = "XML"))
          catalogAdd("http://www.r-project.org/doc/", paste(R.home(), "doc", "", sep = .Platform$file.sep))
	
          # 
     #          This shows how we can load a catalog and then resolve a system identifier 
     #           that it maps.
     # 	
          catalogLoad(system.file("exampleData", "catalog.xml", package = "XML"))

	  catalogResolve("docbook4.4.dtd", "system")
	  catalogResolve("-//OASIS//DTD DocBook XML V4.4//EN", "public")
	
   



cleanEx()
nameEx("compareXMLDocs")
### * compareXMLDocs

flush(stderr()); flush(stdout())

### Name: compareXMLDocs
### Title: Indicate differences between two XML documents
### Aliases: compareXMLDocs
### Keywords: IO

### ** Examples


tt = 
 '<x>
     <a>text</a>
     <b foo="1"/>
     <c bar="me">
        <d>a phrase</d>
     </c>
  </x>'

  a = xmlParse(tt, asText = TRUE)
  b = xmlParse(tt, asText = TRUE)
  d = getNodeSet(b, "//d")[[1]]
  xmlName(d) = "bob"
  addSibling(xmlParent(d), newXMLNode("c"))
  
  compareXMLDocs(a, b)



cleanEx()
nameEx("docName")
### * docName

flush(stderr()); flush(stdout())

### Name: docName
### Title: Accessors for name of XML document
### Aliases: docName docName,XMLDocument-method
###   docName,XMLDocumentContent-method docName,XMLHashTree-method
###   docName,XMLInternalDocument-method docName,XMLInternalNode-method
###   docName,XMLHashTreeNode-method docName,NULL-method
###   docName,XMLNode-method docName<- docName<-,XMLInternalDocument-method
###   docName<-,XMLHashTree-method
### Keywords: IO programming

### ** Examples

  f = system.file("exampleData", "catalog.xml",  package = "XML")
  doc = xmlInternalTreeParse(f)
  docName(doc)

  doc = xmlInternalTreeParse("<a><b/></a>", asText = TRUE)
      # an NA
  docName(doc)
  docName(doc) = "Simple XML example"
  docName(doc)



cleanEx()
nameEx("dtdElement")
### * dtdElement

flush(stderr()); flush(stdout())

### Name: dtdElement
### Title: Gets the definition of an element or entity from a DTD.
### Aliases: dtdElement dtdEntity
### Keywords: file

### ** Examples

 dtdFile <- system.file("exampleData","foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)
 
   # Get the definition of the `entry1' element
 tmp <- dtdElement("variable", foo.dtd)
 xmlAttrs(tmp)

 tmp <- dtdElement("entry1", foo.dtd)

  # Get the definition of the `img' entity
 dtdEntity("img", foo.dtd)



cleanEx()
nameEx("dtdElementValidEntry")
### * dtdElementValidEntry

flush(stderr()); flush(stdout())

### Name: dtdElementValidEntry
### Title: Determines whether an XML element allows a particular type of
###   sub-element.
### Aliases: dtdElementValidEntry.character
###   dtdElementValidEntry.XMLElementContent
###   dtdElementValidEntry.XMLElementDef dtdElementValidEntry.XMLOrContent
###   dtdElementValidEntry.XMLSequenceContent dtdElementValidEntry
### Keywords: file

### ** Examples

 dtdFile <- system.file("exampleData", "foo.dtd",package="XML")
 dtd <- parseDTD(dtdFile) 
 
  dtdElementValidEntry(dtdElement("variables",dtd), "variable")



cleanEx()
nameEx("dtdIsAttribute")
### * dtdIsAttribute

flush(stderr()); flush(stdout())

### Name: dtdIsAttribute
### Title: Query if a name is a valid attribute of a DTD element.
### Aliases: dtdIsAttribute
### Keywords: file

### ** Examples

 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)

    # true
  dtdIsAttribute("numRecords", "dataset", foo.dtd)

    # false
  dtdIsAttribute("date", "dataset", foo.dtd)



cleanEx()
nameEx("dtdValidElement")
### * dtdValidElement

flush(stderr()); flush(stdout())

### Name: dtdValidElement
### Title: Determines whether an XML tag is valid within another.
### Aliases: dtdValidElement
### Keywords: file

### ** Examples

 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)

  # The following are true.
 dtdValidElement("variable","variables", dtd = foo.dtd)
 dtdValidElement("record","dataset", dtd = foo.dtd)

  # This is false.
 dtdValidElement("variable","dataset", dtd = foo.dtd)



cleanEx()
nameEx("ensureNamespace")
### * ensureNamespace

flush(stderr()); flush(stdout())

### Name: ensureNamespace
### Title: Ensure that the node has a definition for particular XML
###   namespaces
### Aliases: ensureNamespace
### Keywords: IO

### ** Examples

  doc = newXMLDoc()
  top = newXMLNode("article", doc = doc)
  ensureNamespace(top, c(r = "http://www.r-project.org"))
  b = newXMLNode("r:code", parent = top)
  print(doc)



cleanEx()
nameEx("findXInclude")
### * findXInclude

flush(stderr()); flush(stdout())

### Name: findXInclude
### Title: Find the XInclude node associated with an XML node
### Aliases: findXInclude
### Keywords: IO

### ** Examples


 f = system.file("exampleData", "functionTemplate.xml", package = "XML")

 cat(readLines(f), "\n")

 doc = xmlParse(f)

  # Get all the para nodes
  # We just want to look at the 2nd and 3rd which are repeats of the
  # first one.
 a = getNodeSet(doc, "//author")
 findXInclude(a[[1]])

 i = findXInclude(a[[1]], TRUE)
 top = getSibling(i)

   # Determine the top-level included nodes
 tmp = getSibling(i)
 nodes = list()
 while(!inherits(tmp, "XMLXIncludeEndNode")) {
   nodes = c(nodes, tmp)
   tmp = getSibling(tmp)
 }



cleanEx()
nameEx("free")
### * free

flush(stderr()); flush(stdout())

### Name: free
### Title: Release the specified object and clean up its memory usage
### Aliases: free free,XMLInternalDocument-method
### Keywords: IO

### ** Examples

 f = system.file("exampleData", "boxplot.svg", package = "XML")
 doc = xmlParse(f)
 nodes = getNodeSet(doc, "//path")
 rm(nodes)
 # free(doc)



cleanEx()
nameEx("genericSAXHandlers")
### * genericSAXHandlers

flush(stderr()); flush(stdout())

### Name: genericSAXHandlers
### Title: SAX generic callback handler list
### Aliases: genericSAXHandlers
### Keywords: file

### ** Examples

## Don't show: 
# .InitSAXMethods()
names(genericSAXHandlers())
names(genericSAXHandlers(inc=c("startElement", "endElement", "text")))
names(genericSAXHandlers(ex=c("startElement", "endElement", "text")))
## End Don't show



cleanEx()
nameEx("getEncoding")
### * getEncoding

flush(stderr()); flush(stdout())

### Name: getEncoding
### Title: Determines the encoding for an XML document or node
### Aliases: getEncoding getEncoding,XMLInternalDocument-method
###   getEncoding,XMLInternalNode-method
### Keywords: IO

### ** Examples

  f = system.file("exampleData", "charts.svg", package = "XML")
  doc = xmlParse(f)
  getEncoding(doc)
  n = getNodeSet(doc, "//g/text")[[1]]
  getEncoding(n)

  f = system.file("exampleData", "iTunes.plist", package = "XML")
  doc = xmlParse(f)
  getEncoding(doc)



cleanEx()
nameEx("getLineNumber")
### * getLineNumber

flush(stderr()); flush(stdout())

### Name: getLineNumber
### Title: Determine the location - file & line number of an (internal) XML
###   node
### Aliases: getNodeLocation getLineNumber
### Keywords: IO

### ** Examples

f = system.file("exampleData", "xysize.svg", package = "XML")
doc = xmlParse(f)
e = getNodeSet(doc, "//ellipse")
sapply(e, getLineNumber)



cleanEx()
nameEx("getNodeSet")
### * getNodeSet

flush(stderr()); flush(stdout())

### Name: getNodeSet
### Title: Find matching nodes in an internal XML tree/DOM
### Aliases: getNodeSet xpathApply xpathSApply matchNamespaces
### Keywords: file IO

### ** Examples

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
 strptime(names(rates), "%Y-%m-%d")


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

## Not run: 
##D      # Will fail because it doesn't know what the namespace x is
##D      # and we have to have one eventhough it has no prefix in the document.
##D     xpathApply(doc, "//x:b")
## End(Not run)    
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







cleanEx()
nameEx("getXMLErrors")
### * getXMLErrors

flush(stderr()); flush(stdout())

### Name: getXMLErrors
### Title: Get XML/HTML document parse errors
### Aliases: getXMLErrors
### Keywords: IO programming

### ** Examples

     # Get the "errors" in the HTML that was generated from this Rd file
  getXMLErrors(system.file("html", "getXMLErrors.html", package = "XML"))

## Not run: 
##D   getXMLErrors("http://www.omegahat.org/index.html")
## End(Not run)




cleanEx()
nameEx("isXMLString")
### * isXMLString

flush(stderr()); flush(stdout())

### Name: isXMLString
### Title: Facilities for working with XML strings
### Aliases: isXMLString xml xmlParseString XMLString-class
### Keywords: IO

### ** Examples

 isXMLString("a regular string < 20 characters long")
 isXMLString("<a><b>c</b></a>")

 xmlParseString("<a><b>c</b></a>")

  # We can lie!
 isXMLString(xml("foo"))



cleanEx()
nameEx("length.XMLNode")
### * length.XMLNode

flush(stderr()); flush(stdout())

### Name: length.XMLNode
### Title: Determine the number of children in an XMLNode object.
### Aliases: length.XMLNode
### Keywords: file

### ** Examples

  doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
  r <- xmlRoot(doc, skip=TRUE)
  length(r)
    # get the last entry
  r[[length(r)]]



cleanEx()
nameEx("libxmlVersion")
### * libxmlVersion

flush(stderr()); flush(stdout())

### Name: libxmlVersion
### Title: Query the version and available features of the libxml library.
### Aliases: libxmlVersion libxmlFeatures
### Keywords: IO

### ** Examples

 ver <- libxmlVersion()
 if(is.null(ver)) {
   cat("Relly old version of libxml\n")
 } else {
   if(ver$major > 1) {
     cat("Using libxml2\n")
   }
 }



cleanEx()
nameEx("names.XMLNode")
### * names.XMLNode

flush(stderr()); flush(stdout())

### Name: names.XMLNode
### Title: Get the names of an XML nodes children.
### Aliases: names.XMLNode
### Keywords: file

### ** Examples

 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 names(xmlRoot(doc))

 r <- xmlRoot(doc)
 r[names(r) == "variables"]



cleanEx()
nameEx("newXMLDoc")
### * newXMLDoc

flush(stderr()); flush(stdout())

### Name: newXMLDoc
### Title: Create internal XML node or document object
### Aliases: newXMLDoc newXMLNode newXMLPINode newXMLCDataNode
###   newXMLCommentNode newXMLTextNode newXMLDTDNode xmlDoc
###   coerce,vector,XMLInternalNode-method
### Keywords: IO

### ** Examples


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
saveXML(txt) # x &amp;lt; 1


newXMLNode("r:expr", newXMLTextNode(I("x < 1")),
            namespaceDefinitions = c(r = "http://www.r-project.org"))




cleanEx()
nameEx("parseDTD")
### * parseDTD

flush(stderr()); flush(stdout())

### Name: parseDTD
### Title: Read a Document Type Definition (DTD)
### Aliases: parseDTD
### Keywords: file IO

### ** Examples

 dtdFile <- system.file("exampleData", "foo.dtd",package="XML")
 parseDTD(dtdFile)

txt <- readLines(dtdFile)
txt <- paste(txt,  collapse="\n")
d <- parseDTD(txt, asText=TRUE)


## Not run: 
##D  url <- "http://www.omegahat.org/XML/DTDs/DatasetByRecord.dtd"
##D  d <- parseDTD(url, asText=FALSE)  
## End(Not run)



cleanEx()
nameEx("parseURI")
### * parseURI

flush(stderr()); flush(stdout())

### Name: parseURI
### Title: Parse a URI string into its elements
### Aliases: parseURI URI-class coerce,URI,character-method
### Keywords: IO

### ** Examples

  parseURI("http://www.omegahat.org:8080/RCurl/index.html")
  parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html")

  parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html#my_anchor")

  as(parseURI("http://duncan@www.omegahat.org:8080/RCurl/index.html#my_anchor"), "character")

  as(parseURI("ftp://duncan@www.omegahat.org:8080/RCurl/index.html?foo=1&bar=axd"), "character")



cleanEx()
nameEx("parseXMLAndAdd")
### * parseXMLAndAdd

flush(stderr()); flush(stdout())

### Name: parseXMLAndAdd
### Title: Parse XML content and add it to a node
### Aliases: parseXMLAndAdd
### Keywords: IO

### ** Examples

  long = runif(10000, -122, -80)
  lat = runif(10000, 25, 48)

  txt = sprintf("<Placemark><Point><coordinates>%.3f,%.3f,0</coordinates></Point></Placemark>",
                  long, lat)
  f = newXMLNode("Folder")
  parseXMLAndAdd(txt, f)
  xmlSize(f)


## Not run: 
##D       # this version is much slower as i) we don't vectorize the
##D       #  creation of the XML nodes, and ii) the parsing of the XML
##D       # as a string is very fast as it is done in C.
##D   f = newXMLNode("Folder")
##D   mapply(function(a, b) {
##D            newXMLNode("Placemark", 
##D                        newXMLNode("Point", 
##D                                    newXMLNode("coordinates", 
##D                                                paste(a, b, "0", collapse = ","))), 
##D 		       parent = f)
##D            },
##D          long, lat) 
##D   xmlSize(f)
##D 
##D 
##D   o = c("<x>dog</x>", "<omg:x>cat</omg:x>")
##D   node = parseXMLAndAdd(o, nsDefs  = c("http://cran.r-project.org",
##D                                        omg = "http://www.omegahat.org"))
##D   xmlNamespace(node[[1]])
##D   xmlNamespace(node[[2]])
##D 
##D   tt = newXMLNode("myTop")
##D   node = parseXMLAndAdd(o, tt, nsDefs  = c("http://cran.r-project.org",
##D                                            omg = "http://www.omegahat.org"))
##D   tt
## End(Not run)





cleanEx()
nameEx("print")
### * print

flush(stderr()); flush(stdout())

### Name: print.XMLAttributeDef
### Title: Methods for displaying XML objects
### Aliases: print.XMLAttributeDef print.XMLCDataNode
###   print.XMLElementContent print.XMLElementDef print.XMLEntity
###   print.XMLEntityRef print.XMLNode print.XMLTextNode print.XMLComment
###   print.XMLOrContent print.XMLSequenceContent
###   print.XMLProcessingInstruction
### Keywords: IO file

### ** Examples

  fileName <- system.file("exampleData", "event.xml", package ="XML")

     # Example of how to get faithful copy of the XML.
  doc = xmlRoot(xmlTreeParse(fileName, trim = FALSE, ignoreBlanks = FALSE))
  print(doc, indent = FALSE, tagSeparator = "")

     # And now the default mechanism
  doc = xmlRoot(xmlTreeParse(fileName))
  print(doc)



cleanEx()
nameEx("processXInclude")
### * processXInclude

flush(stderr()); flush(stdout())

### Name: processXInclude
### Title: Perform the XInclude substitutions
### Aliases: processXInclude processXInclude.list
###   processXInclude.XMLInternalDocument
###   processXInclude.XMLInternalElement
### Keywords: IO programming

### ** Examples


  f = system.file("exampleData", "include.xml", package = "XML")
  doc = xmlInternalTreeParse(f, xinclude = FALSE)

  cat(saveXML(doc))
  sects = getNodeSet(doc, "//section")
  sapply(sects, function(x) xmlName(x[[2]]))
  processXInclude(doc)

  cat(saveXML(doc))

  f = system.file("exampleData", "include.xml", package = "XML")
  doc = xmlInternalTreeParse(f, xinclude = FALSE)
  section1 = getNodeSet(doc, "//section")[[1]]

     # process 
  processXInclude(section1[[2]])



cleanEx()
nameEx("readHTMLTable")
### * readHTMLTable

flush(stderr()); flush(stdout())

### Name: readHTMLTable
### Title: Read data from one or more HTML tables
### Aliases: readHTMLTable readHTMLTable,character-method
###   readHTMLTable,HTMLInternalDocument-method
###   readHTMLTable,XMLInternalElementNode-method
###   coerce,character,FormattedInteger-method
###   coerce,character,FormattedNumber-method
###   coerce,character,Percent-method FormattedInteger-class
###   FormattedNumber-class Percent-class
### Keywords: IO data

### ** Examples

 u = "http://en.wikipedia.org/wiki/World_population"
 
 tables = readHTMLTable(u)
 names(tables)

 tables[[2]]
  # Print the table. Note that the values are all characters
  # not numbers. Also the column names have a preceding X since
  # R doesn't allow the variable names to start with digits.
 tmp = tables[[2]]

  # We can transform this to get the rows to be years and the columns
  # to be population counts. We'll create a matrix.
 vals = cbind(year = as.integer(gsub("X", "", names(tmp)[-1])),
              matrix(as.integer(gsub(",", "", as.character(unlist(tmp[-1])))),
                      ncol(tmp)-1, byrow = TRUE, dimnames = list(NULL, as.character(tmp[[1]]))))

   # Let's just read the second table directly by itself.
 doc = htmlParse(u)
 tableNodes = getNodeSet(doc, "//table")
 tb = readHTMLTable(tableNodes[[2]])

  # Let's try to adapt the values on the fly.
  # We'll create a function that turns a th/td node into a val
 tryAsInteger = function(node) {
                  val = xmlValue(node)
                  ans = as.integer(gsub(",", "", val))
                  if(is.na(ans))
                      val
                  else
                      ans
                }

 tb = readHTMLTable(tableNodes[[2]], elFun = tryAsInteger)

 tb = readHTMLTable(tableNodes[[2]], elFun = tryAsInteger,
                       colClasses = c("character", rep("integer", 9)))


  zz = readHTMLTable("http://www.inflationdata.com/Inflation/Consumer_Price_Index/HistoricalCPI.aspx")
  if(any(i <- sapply(zz, ncol) == 14)) {  # guard against the structure of the page changing.
    zz = zz[[which(i)[1]]]  # 4th table
        # convert columns to numeric.  Could use colClasses in the call to readHTMLTable()
    zz[-1] = lapply(zz[-1], function(x) as.numeric(gsub(".* ", "", as.character(x))))
    matplot(1:12, t(zz[-c(1, 14)]), type = "l")
  }


# From Marsh Feldman on R-help
doc <- "http://www.nber.org/cycles/cyclesmain.html"
     # The  main table is the second one because it's embedded in the page table.
table <- getNodeSet(htmlParse(doc),"//table") [[2]]   
xt <- readHTMLTable(table,
                    header = c("peak","trough","contraction",
                               "expansion","trough2trough","peak2peak"),
                    colClasses = c("character","character","character",
                                   "character","character","character"),
                    trim = TRUE, stringsAsFactors = FALSE
                   )


if(FALSE) {
 # Here is a totally different way of reading tables from HTML documents.
 # The data are formatted using a PRE and so can be read via read.table
 u = "http://tidesonline.nos.noaa.gov/data_read.shtml?station_info=9414290+San+Francisco,+CA"
 h = htmlParse(u)
 p = getNodeSet(h, "//pre")
 con = textConnection(xmlValue(p[[2]]))
 tides = read.table(con)
}

   # header as a logical vector
 tt = readHTMLTable("http://www.sfgate.com/weather/rainfall.shtml",
                     header = c(FALSE, FALSE, TRUE, FALSE, FALSE))

   #
 tt = readHTMLTable("http://www.sfgate.com/weather/rainfall.shtml",
                        which = 3, header = TRUE)


if(require(RCurl)) {
  tt =  getURL("http://www.omegahat.org/RCurl/testPassword/table.html",  userpwd = "bob:duncantl")
  readHTMLTable(tt)
}



cleanEx()
nameEx("saveXML")
### * saveXML

flush(stderr()); flush(stdout())

### Name: saveXML
### Title: Output internal XML Tree
### Aliases: saveXML saveXML.XMLInternalDocument saveXML.XMLInternalDOM
###   saveXML.XMLInternalNode saveXML.XMLNode saveXML.XMLOutputStream
###   coerce,XMLInternalDocument,character-method
###   coerce,XMLInternalDOM,character-method
###   coerce,XMLInternalNode,character-method saveXML,XMLFlatTree-method
###   saveXML,XMLInternalDocument-method saveXML,XMLInternalDOM-method
###   saveXML,XMLInternalNode-method saveXML,XMLNode-method
###   saveXML,XMLOutputStream-method saveXML,HTMLInternalDocument-method
### Keywords: IO file

### ** Examples


 b = newXMLNode("bob")
 saveXML(b)

 f = tempfile()
 saveXML(b, f)
 doc = xmlInternalTreeParse(f)
 saveXML(doc)


con <- xmlOutputDOM()
con$addTag("author", "Duncan Temple Lang")
con$addTag("address",  close=FALSE)
con$addTag("office", "2C-259")
con$addTag("street", "Mountain Avenue.")
con$addTag("phone", close=FALSE)
con$addTag("area", "908", attrs=c(state="NJ"))
con$addTag("number", "582-3217")
con$closeTag() # phone
con$closeTag() # address

saveXML(con$value(), file="out.xml")


# Work with entities

 f = system.file("exampleData", "test1.xml", package = "XML")
 doc = xmlRoot(xmlTreeParse(f))
 outFile = tempfile()
 saveXML(doc, outFile)
 alt = xmlRoot(xmlTreeParse(outFile))
 if(! identical(doc, alt) )
  stop("Problems handling entities!")

 con = textConnection("test1.xml", "w")
 saveXML(doc, con)
 close(con)
 alt = get("test1.xml")
 identical(doc, alt)



 x = newXMLNode("a", "some text", newXMLNode("c", "sub text"), "more text")

 cat(saveXML(x), "\n")

 cat(as(x, "character"), "\n")


     # Showing the prefix parameter
  doc = newXMLDoc()
  n = newXMLNode("top", doc = doc)
  b = newXMLNode("bar", parent = n)

     # suppress the <?xml ...?>
  saveXML(doc, prefix = character())

     # put our own comment in
  saveXML(doc, prefix = "<!-- This is an alternative prefix -->")
     # or use a comment node.
  saveXML(doc, prefix = newXMLCommentNode("This is an alternative prefix"))



cleanEx()
nameEx("supportsExpat")
### * supportsExpat

flush(stderr()); flush(stdout())

### Name: supportsExpat
### Title: Determines which native XML parsers are being used.
### Aliases: supportsExpat supportsLibxml
### Keywords: file

### ** Examples

     # use Expat if possible, otherwise libxml
  fileName <- system.file("exampleData", "mtcars.xml", package="XML")
  xmlEventParse(fileName, useExpat = supportsExpat())



cleanEx()
nameEx("toHTML")
### * toHTML

flush(stderr()); flush(stdout())

### Name: toHTML
### Title: Create an HTML representation of the given R object, using
###   internal C-level nodes
### Aliases: toHTML toHTML,vector-method toHTML,matrix-method
###   toHTML,call-method
### Keywords: IO programming

### ** Examples

 cat(as(toHTML(rnorm(10)), "character"))



cleanEx()
nameEx("toString")
### * toString

flush(stderr()); flush(stdout())

### Name: toString.XMLNode
### Title: Creates string representation of XML node
### Aliases: toString.XMLNode
### Keywords: file

### ** Examples

 x <- xmlRoot(xmlTreeParse(system.file("exampleData", "gnumeric.xml", package = "XML")))

 toString(x)



cleanEx()
nameEx("xmlApply")
### * xmlApply

flush(stderr()); flush(stdout())

### Name: xmlApply
### Title: Applies a function to each of the children of an XMLNode
### Aliases: xmlApply xmlApply.XMLNode xmlApply.XMLDocument
###   xmlApply.XMLDocumentContent xmlSApply xmlSApply.XMLNode
###   xmlSApply.XMLDocument xmlSApply.XMLDocumentContent
### Keywords: file

### ** Examples

 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 r <- xmlRoot(doc)
 xmlSApply(r[[2]], xmlName)

 xmlApply(r[[2]], xmlAttrs)

 xmlSApply(r[[2]], xmlSize)




cleanEx()
nameEx("xmlAttrs")
### * xmlAttrs

flush(stderr()); flush(stdout())

### Name: xmlAttrs
### Title: Get the list of attributes of an XML node.
### Aliases: xmlAttrs xmlAttrs<- xmlAttrs.XMLElementDef xmlAttrs<-,XMLNode
###   xmlAttrs<-,XMLInternalNode xmlAttrs<-,XMLNode-method
###   xmlAttrs<-,XMLInternalElementNode-method xmlAttrs.XMLNode
###   xmlAttrs.XMLInternalNode
### Keywords: IO file

### ** Examples

 fileName <- system.file("exampleData", "mtcars.xml", package="XML") 
 doc <- xmlTreeParse(fileName)

 xmlAttrs(xmlRoot(doc))

 xmlAttrs(xmlRoot(doc)[["variables"]])


 doc <- xmlParse(fileName)
 d = xmlRoot(doc)

 xmlAttrs(d)
 xmlAttrs(d) <- c(name = "Motor Trend fuel consumption data",
                  author = "Motor Trends")
 xmlAttrs(d)

   # clear all the attributes and then set new ones.
 removeAttributes(d)
 xmlAttrs(d) <- c(name = "Motor Trend fuel consumption data",
                  author = "Motor Trends")


     # Show how to get the attributes with and without the prefix and
     # with and without the URLs for the namespaces.
  doc = xmlParse('<doc xmlns:r="http://www.r-project.org">
                    <el r:width="10" width="72"/>
                    <el width="46"/>
                    </doc>')

  xmlAttrs(xmlRoot(doc)[[1]], TRUE, TRUE)
  xmlAttrs(xmlRoot(doc)[[1]], FALSE, TRUE)
  xmlAttrs(xmlRoot(doc)[[1]], TRUE, FALSE)
  xmlAttrs(xmlRoot(doc)[[1]], FALSE, FALSE)



cleanEx()
nameEx("xmlChildren")
### * xmlChildren

flush(stderr()); flush(stdout())

### Name: xmlChildren
### Title: Gets the sub-nodes within an XMLNode object.
### Aliases: xmlChildren xmlChildren<- xmlChildren.XMLNode
###   xmlChildren.XMLInternalNode xmlChildren.XMLInternalDocument
###   xmlChildren<-,XMLInternalNode-method xmlChildren<-,ANY-method
### Keywords: file

### ** Examples

  fileName <- system.file("exampleData", "mtcars.xml", package="XML")
  doc <- xmlTreeParse(fileName)
  names(xmlChildren(doc$doc$children[["dataset"]]))



cleanEx()
nameEx("xmlContainsEntity")
### * xmlContainsEntity

flush(stderr()); flush(stdout())

### Name: xmlContainsEntity
### Title: Checks if an entity is defined within a DTD.
### Aliases: xmlContainsEntity xmlContainsElement
### Keywords: file

### ** Examples

 dtdFile <- system.file("exampleData", "foo.dtd", package="XML")
 foo.dtd <- parseDTD(dtdFile)
 
  # Look for entities.
 xmlContainsEntity("foo", foo.dtd)
 xmlContainsEntity("bar", foo.dtd)

  # Now look for an element
 xmlContainsElement("record", foo.dtd)



cleanEx()
nameEx("xmlDOMApply")
### * xmlDOMApply

flush(stderr()); flush(stdout())

### Name: xmlDOMApply
### Title: Apply function to nodes in an XML tree/DOM.
### Aliases: xmlDOMApply
### Keywords: file

### ** Examples

 dom <- xmlTreeParse(system.file("exampleData","mtcars.xml", package="XML"))
 tagNames <- function() {
    tags <- character(0)
    add <- function(x) {
      if(inherits(x, "XMLNode")) {
        if(is.na(match(xmlName(x), tags)))
           tags <<- c(tags, xmlName(x))
      }

      NULL
    }

    return(list(add=add, tagNames = function() {return(tags)}))
 }

 h <- tagNames()
 xmlDOMApply(xmlRoot(dom), h$add) 
 h$tagNames()



cleanEx()
nameEx("xmlElementSummary")
### * xmlElementSummary

flush(stderr()); flush(stdout())

### Name: xmlElementSummary
### Title: Frequency table of names of elements and attributes in XML
###   content
### Aliases: xmlElementSummary
### Keywords: IO

### ** Examples

  xmlElementSummary(system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML"))



cleanEx()
nameEx("xmlElementsByTagName")
### * xmlElementsByTagName

flush(stderr()); flush(stdout())

### Name: xmlElementsByTagName
### Title: Retrieve the children of an XML node with a specific tag name
### Aliases: xmlElementsByTagName
### Keywords: IO file

### ** Examples

## Not run: 
##D  doc <- xmlTreeParse("http://www.omegahat.org/Scripts/Data/mtcars.xml")
##D  xmlElementsByTagName(doc$children[[1]], "variable")
## End(Not run)

 doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
 xmlElementsByTagName(xmlRoot(doc)[[1]], "variable")



cleanEx()
nameEx("xmlEventHandler")
### * xmlEventHandler

flush(stderr()); flush(stdout())

### Name: xmlEventHandler
### Title: Default handlers for the SAX-style event XML parser
### Aliases: xmlEventHandler
### Keywords: file IO

### ** Examples

 xmlEventParse(system.file("exampleData", "mtcars.xml", package="XML"),
               handlers=xmlEventHandler())



cleanEx()
nameEx("xmlEventParse")
### * xmlEventParse

flush(stderr()); flush(stdout())

### Name: xmlEventParse
### Title: XML Event/Callback element-wise Parser
### Aliases: xmlEventParse
### Keywords: file IO

### ** Examples

 fileName <- system.file("exampleData", "mtcars.xml", package="XML")

   # Print the name of each XML tag encountered at the beginning of each
   # tag.
   # Uses the libxml SAX parser.
 xmlEventParse(fileName,
                list(startElement=function(name, attrs){
                                    cat(name,"\n")
                                  }),
                useTagName=FALSE, addContext = FALSE)


## Not run: 
##D   # Parse the text rather than a file or URL by reading the URL's contents
##D   # and making it a single string. Then call xmlEventParse
##D xmlURL <- "http://www.omegahat.org/Scripts/Data/mtcars.xml"
##D xmlText <- paste(scan(xmlURL, what="",sep="\n"),"\n",collapse="\n")
##D xmlEventParse(xmlText, asText=TRUE)
## End(Not run)

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



cleanEx()
nameEx("xmlFlatListTree")
### * xmlFlatListTree

flush(stderr()); flush(stdout())

### Name: xmlFlatListTree
### Title: Constructors for trees stored as flat list of nodes with
###   information about parents and children.
### Aliases: xmlFlatListTree xmlHashTree
### Keywords: IO

### ** Examples

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



cleanEx()
nameEx("xmlGetAttr")
### * xmlGetAttr

flush(stderr()); flush(stdout())

### Name: xmlGetAttr
### Title: Get the value of an attribute in an XML node
### Aliases: xmlGetAttr
### Keywords: file

### ** Examples

 node <- xmlNode("foo", attrs=c(a="1", b="my name"))

 xmlGetAttr(node, "a")
 xmlGetAttr(node, "doesn't exist", "My own default value")

 xmlGetAttr(node, "b", "Just in case")



cleanEx()
nameEx("xmlHandler")
### * xmlHandler

flush(stderr()); flush(stdout())

### Name: xmlHandler
### Title: Example XML Event Parser Handler Functions
### Aliases: xmlHandler
### Keywords: file IO

### ** Examples

## Not run: 
##D xmlURL <- "http://www.omegahat.org/Scripts/Data/mtcars.xml"
##D xmlText <- paste(scan(xmlURL, what="", sep="\n"),"\n",collapse="\n")
## End(Not run)

xmlURL <- system.file("exampleData", "mtcars.xml", package="XML")
xmlText <- paste(readLines(xmlURL), "\n", collapse="")
xmlEventParse(xmlText, handlers = NULL, asText=TRUE)
xmlEventParse(xmlText, xmlHandler(), useTagName=TRUE, asText=TRUE)



cleanEx()
nameEx("xmlName")
### * xmlName

flush(stderr()); flush(stdout())

### Name: xmlName
### Title: Extraces the tag name of an XMLNode object.
### Aliases: xmlName xmlName<- xmlName.XMLComment xmlName.XMLNode
###   xmlName.XMLInternalNode
### Keywords: file

### ** Examples

 fileName <- system.file("exampleData", "test.xml", package="XML") 
 doc <- xmlTreeParse(fileName)
 xmlName(xmlRoot(doc)[[1]])

 tt = xmlRoot(doc)[[1]]
 xmlName(tt)
 xmlName(tt) <- "bob"


  # We can set the node on an internal object also.
 n = newXMLNode("x")

 xmlName(n)
 xmlName(n) <- "y"

 
 xmlName(n) <- "r:y"




cleanEx()
nameEx("xmlNamespace")
### * xmlNamespace

flush(stderr()); flush(stdout())

### Name: xmlNamespace
### Title: Retrieve the namespace value of an XML node.
### Aliases: xmlNamespace xmlNamespace.XMLNode xmlNamespace.XMLInternalNode
###   xmlNamespace.character XMLNamespace-class xmlNamespace<-
###   xmlNamespace<-,XMLInternalNode-method
### Keywords: file

### ** Examples

  doc <- xmlTreeParse(system.file("exampleData", "job.xml", package="XML"))
  xmlNamespace(xmlRoot(doc))
  xmlNamespace(xmlRoot(doc)[[1]][[1]])


  doc <- xmlInternalTreeParse(system.file("exampleData", "job.xml", package="XML"))
     # Since the first node, xmlRoot() will skip that, by default.
  xmlNamespace(xmlRoot(doc))
  xmlNamespace(xmlRoot(doc)[[1]][[1]])

  node <- xmlNode("arg", xmlNode("name", "foo"), namespace="R")
  xmlNamespace(node)


   doc = xmlParse('<top xmlns:r="http://www.r-project.org"><bob><code>a = 1:10</code></bob></top>')
   node = xmlRoot(doc)[[1]][[1]]
   xmlNamespace(node) = "r"
   node


   doc = xmlParse('<top xmlns:r="http://www.r-project.org"><bob><code>a = 1:10</code></bob></top>')
   node = xmlRoot(doc)[[1]][[1]]
   xmlNamespaces(node, set = TRUE) = c(omg = "http://www.omegahat.org")
   node



cleanEx()
nameEx("xmlNamespaceDefinitions")
### * xmlNamespaceDefinitions

flush(stderr()); flush(stdout())

### Name: xmlNamespaceDefinitions
### Title: Get definitions of any namespaces defined in this XML node
### Aliases: xmlNamespaceDefinitions getDefaultNamespace xmlNamespaces
###   xmlNamespaces<- xmlNamespaces<-,XMLInternalNode-method
###   xmlNamespaces<-,XMLNode-method
###   coerce,NULL,XMLNamespaceDefinitions-method
###   coerce,XMLNamespace,character-method
###   coerce,XMLNamespaceDefinition,character-method
###   coerce,XMLNamespaceDefinitions,character-method
###   coerce,character,XMLNamespaceDefinitions-method
### Keywords: IO

### ** Examples

  f = system.file("exampleData", "longitudinalData.xml", package = "XML")
  n = xmlRoot(xmlTreeParse(f))
  xmlNamespaceDefinitions(n)
  xmlNamespaceDefinitions(n, recursive = TRUE)


    # Now using internal nodes.
  f = system.file("exampleData", "namespaces.xml", package = "XML")
  doc = xmlInternalTreeParse(f)
  n = xmlRoot(doc)
  xmlNamespaceDefinitions(n)

  xmlNamespaceDefinitions(n, recursive = TRUE)



cleanEx()
nameEx("xmlNode")
### * xmlNode

flush(stderr()); flush(stdout())

### Name: xmlNode
### Title: Create an XML node
### Aliases: xmlNode xmlTextNode xmlPINode xmlCDataNode xmlCommentNode
### Keywords: file

### ** Examples


 # node named arg with two children: name and defaultValue
 # Both of these have a text node as their child.
 n <- xmlNode("arg", attrs = c(default="TRUE"),
               xmlNode("name", "foo"), xmlNode("defaultValue","1:10"))


  # internal C-level node.
 a = newXMLNode("arg", attrs = c(default = "TRUE"),
                newXMLNode("name", "foo"),
                newXMLNode("defaultValue", "1:10"))

 xmlAttrs(a) = c(a = 1, b = "a string")

 xmlAttrs(a) = c(a = 1, b = "a string", append = FALSE)

 newXMLNamespace(a, c("r" = "http://www.r-project.org"))
 xmlAttrs(a) = c("r:class" = "character") 


 xmlAttrs(a[[1]]) = c("r:class" = "character") 


  # Using a character vector as a namespace definitions
 x = xmlNode("bob",
             namespaceDefinitions = c(r = "http://www.r-project.org",
                                      omg = "http://www.omegahat.org"))



cleanEx()
nameEx("xmlOutput")
### * xmlOutput

flush(stderr()); flush(stdout())

### Name: xmlOutputBuffer
### Title: XML output streams
### Aliases: xmlOutputBuffer xmlOutputDOM
### Keywords: file IO

### ** Examples

 con <- xmlOutputDOM()
con$addTag("author", "Duncan Temple Lang")
con$addTag("address",  close=FALSE)
 con$addTag("office", "2C-259")
 con$addTag("street", "Mountain Avenue.")
 con$addTag("phone", close = FALSE)
   con$addTag("area", "908", attrs=c(state="NJ"))
   con$addTag("number", "582-3217")
 con$closeTag() # phone
con$closeTag() # address

con$addTag("section", close = FALSE)
 con$addNode(xmlTextNode("This is some text "))
 con$addTag("a","and a link", attrs=c(href="http://www.omegahat.org"))
 con$addNode(xmlTextNode("and some follow up text"))

 con$addTag("subsection", close = FALSE)
   con$addNode(xmlTextNode("some addtional text "))
   con$addTag("a", attrs=c(href="http://www.omegahat.org"), close=FALSE)
     con$addNode(xmlTextNode("the content of the link"))
   con$closeTag() # a
 con$closeTag() # "subsection"
con$closeTag() # section


 d <- xmlOutputDOM()
 d$addPI("S", "plot(1:10)")
 d$addCData('x <- list(1, a="&");\nx[[2]]')
 d$addComment("A comment")
 print(d$value())
 print(d$value(), indent = FALSE, tagSeparator = "")


 d = xmlOutputDOM("bob", xmlDeclaration = TRUE)
 print(d$value())

 d = xmlOutputDOM("bob", xmlDeclaration = "encoding='UTF-8'")
 print(d$value())


 d = xmlOutputBuffer("bob", header = "<?xml version='1.0' encoding='UTF-8'?>", 
                      dtd = "foo.dtd")
 d$addTag("bob")
 cat(d$value())



cleanEx()
nameEx("xmlParent")
### * xmlParent

flush(stderr()); flush(stdout())

### Name: xmlParent
### Title: Get parent node of XMLInternalNode or ancestor nodes
### Aliases: xmlParent xmlAncestors xmlParent.XMLInternalNode
###   xmlParent,XMLInternalNode-method xmlParent,XMLHashTreeNode-method
###   xmlParent,XMLTreeNode-method
### Keywords: file IO

### ** Examples


  top = newXMLNode("doc")
  s = newXMLNode("section", attr = c(title = "Introduction"))
  a = newXMLNode("article", s)
  addChildren(top, a)

  xmlName(xmlParent(s))
  xmlName(xmlParent(xmlParent(s)))


    # Find the root node.
  root = a
  while(!is.null(xmlParent(root)))
      root = xmlParent(root)

   # find the names of the parent nodes of each 'h' node.
   # use a global variable to "simplify" things and not use a closure.

  filename = system.file("exampleData", "branch.xml", package = "XML")
  parentNames <- character()
  xmlParse(filename,
                handlers =
                  list(h = function(x) {
                   parentNames <<- c(parentNames, xmlName(xmlParent(x)))
                  }))

  table(parentNames)



cleanEx()
nameEx("xmlParseDoc")
### * xmlParseDoc

flush(stderr()); flush(stdout())

### Name: xmlParseDoc
### Title: Parse an XML document with options controlling the parser.
### Aliases: xmlParseDoc COMPACT DTDATTR DTDLOAD DTDVALID HUGE NOBASEFIX
###   NOBLANKS NOCDATA NODICT NOENT NOERROR NONET NOWARNING NOXINCNODE
###   NSCLEAN OLDSAX PEDANTIC RECOVER XINCLUDE OLD10 SAX1
### Keywords: data

### ** Examples

 f = system.file("exampleData", "mtcars.xml", package="XML")
     # Same as xmlParse()
 xmlParseDoc(f)

 txt =
     '<top xmlns:r="http://www.r-project.org">
        <b xmlns:r="http://www.r-project.org">
          <c xmlns:omg="http:/www.omegahat.org"/>
        </b>
      </top>'

 xmlParseDoc(txt,  NSCLEAN, asText = TRUE)

 txt =
     '<top xmlns:r="http://www.r-project.org"  xmlns:r="http://www.r-project.org">
        <b xmlns:r="http://www.r-project.org">
          <c xmlns:omg="http:/www.omegahat.org"/>
        </b>
      </top>'

 xmlParseDoc(txt, c(NSCLEAN, NOERROR), asText = TRUE)



cleanEx()
nameEx("xmlRoot")
### * xmlRoot

flush(stderr()); flush(stdout())

### Name: xmlRoot
### Title: Get the top-level XML node.
### Aliases: xmlRoot xmlRoot.XMLDocument xmlRoot.XMLInternalDocument
###   xmlRoot.XMLInternalDOM xmlRoot.XMLDocumentRoot
###   xmlRoot.XMLDocumentContent xmlRoot.HTMLDocument
### Keywords: file

### ** Examples

  doc <- xmlTreeParse(system.file("exampleData", "mtcars.xml", package="XML"))
  xmlRoot(doc)
   # Note that we cannot use getSibling () on a regular R-level XMLNode object
   # since we cannot go back up or across the tree from that node, but
   # only down to the children.

    # Using an internal node via xmlParse (== xmlInternalTreeParse())
  doc <- xmlParse(system.file("exampleData", "mtcars.xml", package="XML"))
  n = xmlRoot(doc, skip = FALSE)
     # skip over the DTD and the comment
  d = getSibling(getSibling(n))



cleanEx()
nameEx("xmlSchemaValidate")
### * xmlSchemaValidate

flush(stderr()); flush(stdout())

### Name: xmlSchemaValidate
### Title: Validate an XML document relative to an XML schema
### Aliases: xmlSchemaValidate schemaValidationErrorHandler
### Keywords: IO

### ** Examples

if(FALSE) {
  xsd = xmlParse(system.file("exampleData", "author.xsd", package = "XML"), isSchema =TRUE)
  doc = xmlInternalTreeParse(system.file("exampleData", "author.xml",  package = "XML"))
  xmlSchemaValidate(xsd, doc)
}



cleanEx()
nameEx("xmlSerializeHook")
### * xmlSerializeHook

flush(stderr()); flush(stdout())

### Name: xmlSerializeHook
### Title: Functions that help serialize and deserialize XML internal
###   objects
### Aliases: xmlSerializeHook xmlDeserializeHook
### Keywords: IO

### ** Examples

z = newXMLNode("foo")
f = system.file("exampleData", "tides.xml", package = "XML")
doc = xmlParse(f)
hdoc = as(doc, "XMLHashTree")

nodes = getNodeSet(doc, "//pred")

saveRDS(list(a = 1:10, z = z, doc = doc, hdoc = hdoc, nodes = nodes), "tmp.rda",
          refhook = xmlSerializeHook)

v = readRDS("tmp.rda", refhook = xmlDeserializeHook)



cleanEx()
nameEx("xmlSize")
### * xmlSize

flush(stderr()); flush(stdout())

### Name: xmlSize
### Title: The number of sub-elements within an XML node.
### Aliases: xmlSize xmlSize.default xmlSize.XMLDocument xmlSize.XMLNode
### Keywords: file

### ** Examples

  fileName <- system.file("exampleData", "mtcars.xml", package="XML") 
  doc <- xmlTreeParse(fileName)
  xmlSize(doc)
  xmlSize(doc$doc$children[["dataset"]][["variables"]])



cleanEx()
nameEx("xmlSource")
### * xmlSource

flush(stderr()); flush(stdout())

### Name: xmlSource
### Title: Source the R code, examples, etc. from an XML document
### Aliases: xmlSource xmlSource,character-method
###   xmlSource,XMLNodeSet-method xmlSource,XMLInternalDocument-method
###   xmlSourceFunctions xmlSourceFunctions,character-method
###   xmlSourceFunctions,XMLInternalDocument-method xmlSourceSection
###   xmlSourceSection,character-method
###   xmlSourceSection,XMLInternalDocument-method xmlSourceThread
###   xmlSourceThread,XMLInternalDocument-method
###   xmlSourceThread,character-method xmlSourceThread,list-method
### Keywords: IO programming

### ** Examples

 xmlSource(system.file("exampleData", "Rsource.xml", package="XML"))

  # This illustrates using r:frag nodes.
  # The r:frag nodes are not processed directly, but only
  # if referenced in the contents/body of a r:code node
 f = system.file("exampleData", "Rref.xml", package="XML")
 xmlSource(f)



cleanEx()
nameEx("xmlStopParser")
### * xmlStopParser

flush(stderr()); flush(stdout())

### Name: xmlStopParser
### Title: Terminate an XML parser
### Aliases: xmlStopParser
### Keywords: IO programming

### ** Examples


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



cleanEx()
nameEx("xmlStructuredStop")
### * xmlStructuredStop

flush(stderr()); flush(stdout())

### Name: xmlStructuredStop
### Title: Condition/error handler functions for XML parsing
### Aliases: xmlStructuredStop xmlErrorCumulator
### Keywords: IO programming

### ** Examples

  tryCatch( xmlTreeParse("<a><b></a>", asText = TRUE, error = NULL),
                 XMLError = function(e) {
                    cat("There was an error in the XML at line", 
                          e$line, "column", e$col, "\n",
                         e$message, "\n")
                })



cleanEx()
nameEx("xmlSubset")
### * xmlSubset

flush(stderr()); flush(stdout())

### Name: [.XMLNode
### Title: Convenience accessors for the children of XMLNode objects.
### Aliases: [.XMLNode [[.XMLNode [[.XMLInternalElementNode
###   [[.XMLDocumentContent
### Keywords: IO file

### ** Examples


 f = system.file("exampleData", "gnumeric.xml", package = "XML")

 top = xmlRoot(xmlTreeParse(f))

  # Get the first RowInfo element.
 top[["Sheets"]][[1]][["Rows"]][["RowInfo"]]

  # Get a list containing only the first row element
 top[["Sheets"]][[1]][["Rows"]]["RowInfo"]
 top[["Sheets"]][[1]][["Rows"]][1]

  # Get all of the RowInfo elements by position
 top[["Sheets"]][[1]][["Rows"]][1:xmlSize(top[["Sheets"]][[1]][["Rows"]])]

  # But more succinctly and accurately, get all of the RowInfo elements
 top[["Sheets"]][[1]][["Rows"]]["RowInfo", all = TRUE]




cleanEx()
nameEx("xmlToDataFrame")
### * xmlToDataFrame

flush(stderr()); flush(stdout())

### Name: xmlToDataFrame
### Title: Extract data from a simple XML document
### Aliases: xmlToDataFrame xmlToDataFrame,character,ANY,ANY,ANY,ANY-method
###   xmlToDataFrame,XMLInternalDocument,ANY,ANY,ANY,missing-method
###   xmlToDataFrame,ANY,ANY,ANY,ANY,XMLNodeSet-method
###   xmlToDataFrame,ANY,ANY,ANY,ANY,XMLInternalNodeList-method
###   xmlToDataFrame,ANY,ANY,ANY,ANY,list-method
###   xmlToDataFrame,XMLInternalNodeList,ANY,ANY,ANY,ANY-method
###   xmlToDataFrame,XMLNodeSet,ANY,ANY,ANY,ANY-method
###   xmlToDataFrame,list,ANY,ANY,ANY,ANY-method
### Keywords: IO

### ** Examples

 f = system.file("exampleData", "size.xml", package = "XML")
 xmlToDataFrame(f, c("integer", "integer", "numeric"))

   # Drop the middle variable.
 z = xmlToDataFrame(f, colClasses = list("integer", NULL, "numeric"))


   #  This illustrates how we can get a subset of nodes and process
   #  those as the "data nodes", ignoring the others.
  f = system.file("exampleData", "tides.xml", package = "XML")
  doc = xmlParse(f)
  xmlToDataFrame(nodes = xmlChildren(xmlRoot(doc)[["data"]]))

    # or, alternatively
  xmlToDataFrame(nodes = getNodeSet(doc, "//data/item"))


  f = system.file("exampleData", "kiva_lender.xml", package = "XML")
  doc = xmlParse(f)
  dd = xmlToDataFrame(getNodeSet(doc, "//lender"))



cleanEx()
nameEx("xmlToList")
### * xmlToList

flush(stderr()); flush(stdout())

### Name: xmlToList
### Title: Convert an XML node/document to a more R-like list
### Aliases: xmlToList
### Keywords: IO data

### ** Examples

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



cleanEx()
nameEx("xmlTree")
### * xmlTree

flush(stderr()); flush(stdout())

### Name: xmlTree
### Title: An internal, updatable DOM object for building XML trees
### Aliases: xmlTree
### Keywords: IO

### ** Examples


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
     z$addNode("topic", "Meta-Computing")
     z$addNode("topic", "Inter-system interfaces")
  z$closeTag()
  z$addNode("address", "4210 Mathematical Sciences Building, UC Davis")
z$closeTag()

  tr <- xmlTree("CDataTest")
  tr$addTag("top", close=FALSE)
  tr$addCData("x <- list(1, a='&');\nx[[2]]")
  tr$addPI("S", "plot(1:10)")
  tr$closeTag()
  cat(saveXML(tr$value()))


  f = tempfile()
  saveXML(tr, f, encoding = "UTF-8")


  # Creating a node
x = rnorm(3)
z = xmlTree("r:data", namespaces = c(r = "http://www.r-project.org"))
z$addNode("numeric", attrs = c("r:length" = length(x)))


  # shows namespace prefix on an attribute, and different from the one on the node.
  z = xmlTree()
z$addNode("r:data",  namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"), close = FALSE)
x = rnorm(3)
z$addNode("r:numeric", attrs = c("omg:length" = length(x)))


z = xmlTree("examples")
z$addNode("example", namespace = list(r = "http://www.r-project.org"), close = FALSE)
z$addNode("code", "mean(rnorm(100))", namespace = "r")


x = summary(rnorm(1000))
d = xmlTree()
d$addNode("table", close = FALSE)

d$addNode("tr", .children = sapply(names(x), function(x) d$addNode("th", x)))
d$addNode("tr", .children = sapply(x, function(x) d$addNode("td", format(x))))

d$closeNode()
cat(saveXML(d))

# Dealing with DTDs and system and public identifiers for DTDs.
# Just doctype
za = xmlTree("people", dtd = "people")
# no public element
zb = xmlTree("people", dtd = c("people", "", "http://www.omegahat.org/XML/types.dtd"))
# public and system
zc = xmlTree("people", dtd = c("people", "//a//b//c//d", "http://www.omegahat.org/XML/types.dtd"))






cleanEx()
nameEx("xmlTreeParse")
### * xmlTreeParse

flush(stderr()); flush(stdout())

### Name: xmlTreeParse
### Title: XML Parser
### Aliases: xmlTreeParse htmlTreeParse htmlParse xmlInternalTreeParse
###   xmlNativeTreeParse xmlParse xmlSchemaParse
### Keywords: file IO

### ** Examples

 fileName <- system.file("exampleData", "test.xml", package="XML")
   # parse the document and return it in its standard format.

 xmlTreeParse(fileName)

   # parse the document, discarding comments.
  
 xmlTreeParse(fileName, handlers=list("comment"=function(x,...){NULL}), asTree = TRUE)

   # print the entities
 invisible(xmlTreeParse(fileName,
            handlers=list(entity=function(x) {
                                    cat("In entity",x$name, x$value,"\n")
                                    x}
                                  ), asTree = TRUE
                          )
          )

 # Parse some XML text.
 # Read the text from the file
 xmlText <- paste(readLines(fileName), "\n", collapse="")

 print(xmlText)
 xmlTreeParse(xmlText, asText=TRUE)


    # with version 1.4.2 we can pass the contents of an XML
    # stream without pasting them.
 xmlTreeParse(readLines(fileName), asText=TRUE)


 # Read a MathML document and convert each node
 # so that the primary class is 
 #   <name of tag>MathML
 # so that we can use method  dispatching when processing
 # it rather than conditional statements on the tag name.
 # See plotMathML() in examples/.
 fileName <- system.file("exampleData", "mathml.xml",package="XML")
m <- xmlTreeParse(fileName, 
                  handlers=list(
                   startElement = function(node){
                   cname <- paste(xmlName(node),"MathML", sep="",collapse="")
                   class(node) <- c(cname, class(node)); 
                   node
                }))



  # In this example, we extract _just_ the names of the
  # variables in the mtcars.xml file. 
  # The names are the contents of the <variable>
  # tags. We discard all other tags by returning NULL
  # from the startElement handler.
  #
  # We cumulate the names of variables in a character
  # vector named `vars'.
  # We define this within a closure and define the 
  # variable function within that closure so that it
  # will be invoked when the parser encounters a <variable>
  # tag.
  # This is called with 2 arguments: the XMLNode object (containing
  # its children) and the list of attributes.
  # We get the variable name via call to xmlValue().

  # Note that we define the closure function in the call and then 
  # create an instance of it by calling it directly as
  #   (function() {...})()

  # Note that we can get the names by parsing
  # in the usual manner and the entire document and then executing
  # xmlSApply(xmlRoot(doc)[[1]], function(x) xmlValue(x[[1]]))
  # which is simpler but is more costly in terms of memory.
 fileName <- system.file("exampleData", "mtcars.xml", package="XML")
 doc <- xmlTreeParse(fileName,  handlers = (function() { 
                                 vars <- character(0) ;
                                list(variable=function(x, attrs) { 
                                                vars <<- c(vars, xmlValue(x[[1]])); 
                                                NULL}, 
                                     startElement=function(x,attr){
                                                   NULL
                                                  }, 
                                     names = function() {
                                                 vars
                                             }
                                    )
                               })()
                     )

  # Here we just print the variable names to the console
  # with a special handler.
 doc <- xmlTreeParse(fileName, handlers = list(
                                  variable=function(x, attrs) {
                                             print(xmlValue(x[[1]])); TRUE
                                           }), asTree=TRUE)


  # This should raise an error.
  try(xmlTreeParse(
            system.file("exampleData", "TestInvalid.xml", package="XML"),
            validate=TRUE))

## Not run: 
##D  # Parse an XML document directly from a URL.
##D  # Requires Internet access.
##D  xmlTreeParse("http://www.omegahat.org/Scripts/Data/mtcars.xml", asText=TRUE)
## End(Not run)

  counter = function() {
              counts = integer(0)
              list(startElement = function(node) {
                                     name = xmlName(node)
                                     if(name %in% names(counts))
                                          counts[name] <<- counts[name] + 1
                                     else
                                          counts[name] <<- 1
                                  },
                    counts = function() counts)
            }

   h = counter()
   xmlParse(system.file("exampleData", "mtcars.xml", package="XML"),  handlers = h)
   h$counts()



 f = system.file("examples", "index.html", package = "XML")
 htmlTreeParse(readLines(f), asText = TRUE)
 htmlTreeParse(readLines(f))

  # Same as 
 htmlTreeParse(paste(readLines(f), collapse = "\n"), asText = TRUE)


 getLinks = function() { 
       links = character() 
       list(a = function(node, ...) { 
                   links <<- c(links, xmlGetAttr(node, "href"))
                   node 
                }, 
            links = function()links)
     }

 h1 = getLinks()
 htmlTreeParse(system.file("examples", "index.html", package = "XML"), handlers = h1)
 h1$links()

 h2 = getLinks()
 htmlTreeParse(system.file("examples", "index.html", package = "XML"), handlers = h2, useInternalNodes = TRUE)
 all(h1$links() == h2$links())

  # Using flat trees
 tt = xmlHashTree()
 f = system.file("exampleData", "mtcars.xml", package="XML")
 xmlTreeParse(f, handlers = list(.startElement = tt[[".addNode"]]))
 xmlRoot(tt)



 doc = xmlTreeParse(f, useInternalNodes = TRUE)

 sapply(getNodeSet(doc, "//variable"), xmlValue)
         
 #free(doc) 


  # character set encoding for HTML
 f = system.file("exampleData", "9003.html", package = "XML")
   # we specify the encoding
 d = htmlTreeParse(f, encoding = "UTF-8")
   # get a different result if we do not specify any encoding
 d.no = htmlTreeParse(f)
   # document with its encoding in the HEAD of the document.
 d.self = htmlTreeParse(system.file("exampleData", "9003-en.html",package = "XML"))
   # XXX want to do a test here to see the similarities between d and
   # d.self and differences between d.no


  # include
 f = system.file("exampleData", "nodes1.xml", package = "XML")
 xmlRoot(xmlTreeParse(f, xinclude = FALSE))
 xmlRoot(xmlTreeParse(f, xinclude = TRUE))

 f = system.file("exampleData", "nodes2.xml", package = "XML")
 xmlRoot(xmlTreeParse(f, xinclude = TRUE))

  # Errors
  try(xmlTreeParse("<doc><a> & < <?pi > </doc>"))

    # catch the error by type.
 tryCatch(xmlTreeParse("<doc><a> & < <?pi > </doc>"),
                "XMLParserErrorList" = function(e) {
                                                      cat("Errors in XML document\n", e$message, "\n")
                                                    })

    #  terminate on first error            
  try(xmlTreeParse("<doc><a> & < <?pi > </doc>", error = NULL))

    #  see xmlErrorCumulator in the XML package 


  f = system.file("exampleData", "book.xml", package = "XML")
  doc.trim = xmlInternalTreeParse(f, trim = TRUE)
  doc = xmlInternalTreeParse(f, trim = FALSE)
  xmlSApply(xmlRoot(doc.trim), class)
      # note the additional XMLInternalTextNode objects
  xmlSApply(xmlRoot(doc), class)


  top = xmlRoot(doc)
  textNodes = xmlSApply(top, inherits, "XMLInternalTextNode")
  sapply(xmlChildren(top)[textNodes], xmlValue)


     # Storing nodes
   f = system.file("exampleData", "book.xml", package = "XML")
   titles = list()
   xmlTreeParse(f, handlers = list(title = function(x)
                                  titles[[length(titles) + 1]] <<- x))
   sapply(titles, xmlValue)
   rm(titles)



cleanEx()
nameEx("xmlValue")
### * xmlValue

flush(stderr()); flush(stdout())

### Name: xmlValue
### Title: Extract or set the contents of a leaf XML node
### Aliases: xmlValue xmlValue.XMLCDataNode xmlValue.XMLNode
###   xmlValue.XMLProcessingInstruction xmlValue.XMLTextNode
###   xmlValue.XMLComment xmlValue<- xmlValue<-,XMLAbstractNode-method
###   xmlValue<-,XMLInternalTextNode-method xmlValue<-,XMLTextNode-method
###   coerce,XMLInternalTextNode,character-method
### Keywords: file

### ** Examples

 node <- xmlNode("foo", "Some text")
 xmlValue(node)

 xmlValue(xmlTextNode("some more raw text"))

  # Setting the xmlValue().
 a = newXMLNode("a")
 xmlValue(a) = "the text"
 xmlValue(a) = "different text"

 a = newXMLNode("x", "bob")
 xmlValue(a) = "joe"

 b = xmlNode("bob")
 xmlValue(b) = "Foo"
 xmlValue(b) = "again"

 b = newXMLNode("bob", "some text")
 xmlValue(b[[1]]) = "change"
 b



### * <FOOTER>
###
cat("Time elapsed: ", proc.time() - get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
