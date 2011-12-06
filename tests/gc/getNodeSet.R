 doc = xmlTreeParse(system.file("exampleData", "tagnames.xml", package = "XML"), useInternalNodes = TRUE)
 
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
 e = xmlTreeParse(f, useInternal = TRUE)
 ans = getNodeSet(e, "//o:Cube[@currency='USD']", "o")
 sapply(ans, xmlGetAttr, "rate")

  # or equivalently
 ans = xpathApply(e, "//o:Cube[@currency='USD']", xmlGetAttr, "rate", namespaces = "o")
 # free(e)



  # Using a namespace
 f = system.file("exampleData", "SOAPNamespaces.xml", package = "XML") 
 z = xmlTreeParse(f, useInternal = TRUE)
 getNodeSet(z, "/a:Envelope/a:Body", c("a" = "http://schemas.xmlsoap.org/soap/envelope/"))
 getNodeSet(z, "//a:Body", c("a" = "http://schemas.xmlsoap.org/soap/envelope/"))
 # free(z)


  # Get two items back with namespaces
 f = system.file("exampleData", "gnumeric.xml", package = "XML") 
 z = xmlTreeParse(f, useInternalNodes = TRUE)
 getNodeSet(z, "//gmr:Item/gmr:name", c(gmr="http://www.gnome.org/gnumeric/v2"))

 #free(z)

 #####
 # European Central Bank (ECB) exchange rate data

  # Data is available from "http://www.ecb.int/stats/eurofxref/eurofxref-hist.xml"
  # or locally.

 uri = system.file("exampleData", "eurofxref-hist.xml.gz", package = "XML")
 doc = xmlTreeParse(uri, useInternalNodes = TRUE)

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
  d = xmlTreeParse(uri, useInternalNodes = TRUE)
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
    doc = xmlTreeParse(f, useInternal = TRUE)
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


     # Will fail because it doesn't know what the namespace x is
     # and we have to have one eventhough it has no prefix in the document.
    xpathApply(doc, "//x:b")
    
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
    table(unlist(sapply(doc["//*|//text()|//comment()|//processing-instruction()"], class)))
