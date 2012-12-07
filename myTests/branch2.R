
#
# Testing the SAX2 interface for branches.
#
f = "~/UNdata_Export_20080807_094337562.xml"

vals = list()
record = 
function(node)
{
 v = structure(xmlSApply(node, xmlValue), names = xmlSApply(node, xmlGetAttr, "name"))
cat(saveXML(node))
 vals[[length(vals) + 1]] <<- v
 TRUE
}

xmlEventParse(f, branches = list(record = record))

#XXX Shouldn't need handlers = NULL

xmlEventParse(f, branches = list(record = record), saxVersion = 2, handlers = NULL, ignoreBlanks = TRUE, trim = TRUE)



# This does a two step saving of specific nodes.

ctr = 0
nodes = list()

store = 
function(node)
{
  nodes[[length(nodes) + 1 ]] <<- node
cat("saved node", length(nodes), "\n")
  TRUE
}
class(store) = "SAXBranchFunction"

afghanistan = 
function(name, attrs, ns, namespaceDefs)
{
  ctr <<- ctr + 1  
  if(ctr < 4) {
     return(store)
  }

}

xmlEventParse(f, handlers = list(record = afghanistan), saxVersion = 2)

