# All the possible names, empirically
# unique(xpathSApply(it, "//*", xmlName))

# On a file that has 549,286 nodes (JasonLibrary.xml)
# this took 37 seconds to process the entire file.
#
#  array    data    date    dict   false integer     key   plist  string 
#      5      14   22104   33103       3  133465  263594       1   96631 
#   true 
#    366 
setGeneric("readKeyValueDB", 
           function(doc, ...)
             standardGeneric("readKeyValueDB"))

setMethod("readKeyValueDB", "character",
           function(doc, ...)
              readKeyValueDB(xmlParse(doc), ...))

setMethod("readKeyValueDB", "XMLInternalDocument",
           function(doc, ...)
              readKeyValueDB(xmlRoot(doc)[["dict"]], ...))


setMethod("readKeyValueDB", "XMLInternalNode",
           function(doc, ...) {
             kids = xmlChildren(doc)
             if(length(kids) == 0)
                return(list())

             i = seq(by = 2, length = length(kids)/2)
             keys = sapply(kids[ i ], xmlValue)
             structure(lapply(kids[i + 1], readPlistNodeValue),
                       names = keys)
           })


readPlistNodeValue =
function(node)
{
  id = xmlName(node)
  switch(id, integer = if(abs(tmp <- as.numeric(xmlValue(node))) > .Machine$integer.max) tmp else as.integer(xmlValue(node)),
             string = xmlValue(node),
             data = xmlValue(node),
             key = xmlValue(node),         
             dict = readKeyValueDB(node),
             true = TRUE,
             false = FALSE,
             date = as.POSIXct(strptime(xmlValue(node), "%Y-%m-%dT%H:%M:%SZ")),
             array = xmlSApply(node,readPlistNodeValue) # We might want xmlApply() so as to allow different types with classes, e.g. POSIXct that doesn't collapse down to a string or whatever.
            )
}


readPlist = readKeyValueDB

  
