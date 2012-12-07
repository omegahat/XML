library(XML)
f =
function()
{  
  doc = xmlParse("<doc><foo><bar>string</bar><xyz id='1'/></foo></doc>")
     # the character() for namespaceDefinitions means that we don't
     # have to access the root node to get the definitions.
  getNodeSet(doc, "//bar", character())
}

##############

nodes = f()
gc()  # this cleans up the doc.

.Call("R_getXMLRefCount", nodes[[1]])
#.Call("R_getXMLRefCount", as(nodes[[1]], "XMLInternalDocument")  )
rm(nodes)
gc()


######

nodes = f()
gc()
rm(nodes)
gc()



############

# This causes the freeing to be done in a different order
# and the regular doc finalizer does the actual freeing.

nodes = f()
rm(nodes)
gc()
      



