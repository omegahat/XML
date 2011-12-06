library(XML)
doit = 
function(node)
{
  id = xmlGetAttr(node, "id")
  el = getNodeSet(xmlDoc(node, TRUE), sprintf("//el[@id='%s']", id))[[1]]
  print(xmlValue(el))
}

 # In this version, we'll store the nodes.
 # This means that the documents shouldn't  be released
nodes = list()
doit = 
function(node)
{
  a = xmlValue(node[["el"]])
  nodes[[length(nodes) + 1]] <<- node
#  print(a)
}

xmlEventParse("branch.xml", list(), branches = list(doit = doit))
gc()
gc()
gctorture()
print(nodes[[1]])
rm(nodes)
cat("No releasing the documents until now.\n")
gc()


