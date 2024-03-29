# All the possible names, empirically
# table(xpathSApply(it, "//*", xmlName))

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

setMethod("readKeyValueDB", "AsIs",
           function(doc, ...)
              readKeyValueDB(xmlParse(doc), ...))

setMethod("readKeyValueDB", "XMLInternalDocument",
          function(doc, ...) {
              r = xmlRoot(doc)
              readPlistNodeValue(r, ...)
#              readKeyValueDB(r, ...)
          })


# Some shared duties  between this method and readPlistNodeValue
setMethod("readKeyValueDB", "XMLInternalNode",
          function(doc, dropComments = TRUE, ...) {
#       cat("XMLInternalNode method", xmlName(doc), "\n");   print(list(...))
             kids = xmlChildren(doc)
             if(dropComments)
                kids = kids[!sapply(kids, is, "XMLInternalCommentNode")]

             if(length(kids) == 0)
                return(list())

             if(xmlName(doc) == "plist") 
                 return(readPlistNodeValue(kids[[1]], dropComments = dropComments, ...))
             
             # Assumes a dict. Generalize.
             if(xmlName(doc) == "dict") {
                 i = seq(by = 2, length = length(kids)/2)
                 keys = sapply(kids[ i ], xmlValue)
                 structure(lapply(kids[i + 1], readPlistNodeValue, dropComments = dropComments, ...),
                           names = keys)
             } else {
browser()
             }
           })


readPlistNodeValue =
function(node, dropComments = TRUE, simplify = TRUE)
{
  id = xmlName(node)
#cat("readPlistNodeValue", id, ", dropComments =", dropComments, ", simplify =", simplify, "\n")    
  switch(id, integer = if(abs(tmp <- as.numeric(xmlValue(node))) > .Machine$integer.max)
                           tmp
                       else
                           as.integer(xmlValue(node)),
             real = as.numeric(xmlValue(node)),
             string = xmlValue(node),
             data = xmlValue(node),
             key = xmlValue(node),
             dict = ,
             plist = readKeyValueDB(node, dropComments = dropComments, simplify = simplify),
             true = TRUE,
             false = FALSE,
             date = as.POSIXct(strptime(xmlValue(node), "%Y-%m-%dT%H:%M:%SZ")),
             array = { tmp = if(dropComments)
                                 node[!xmlSApply(node, inherits, "XMLInternalCommentNode")]
                             else
                                 xmlChildren(node)
                           # We might want lapply/xmlApply() so as to allow different types with classes,
                           # e.g. POSIXct that doesn't collapse down to a string or whatever.
                        ans = unname(lapply(tmp, readPlistNodeValue, dropComments = dropComments, simplify = simplify))
                        if(simplify)
                           simplify2array(ans)
                        else
                           ans
             }
            )
}


readPlist = readKeyValueDB


