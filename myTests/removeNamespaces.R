library(XML)

doc = xmlParse(system.file("exampleData", "namespaces2.xml", package = "XML"))
#doc = xmlParse("data/namespaces2.xml")
nodes = getNodeSet(doc, "//*[namespace::*]")

ids = names(xmlNamespaceDefinitions(nodes[[1]]))
removeXMLNamespaces(nodes[[1]], ids)

print(nodes[[2]])
removeXMLNamespaces(nodes[[2]], all = TRUE)
print(nodes[[2]])

doc = xmlParse(system.file("exampleData", "namespaces2.xml", package = "XML"))
nodes = getNodeSet(doc, "/*/namespace::*")

library(XML)
doc = xmlParse(system.file("exampleData", "namespaces2.xml", package = "XML"))
nodes = getNodeSet(doc, "//c:c/namespace::*", c("c" = "http://www.c.org"))
lapply(nodes, function(x) .Call("R_convertXMLNsRef", x))




#.Call("RS_XML_removeNodeNamespaces", nodes[[1]], lapply(ids, function(x) x))
#lapply(nodes, function(x) {
#                 ids = names(xmlNamespaceDefinitions(x))
#                 .Call("RS_XML_removeNodeNamespaces", x, lapply(ids, function(x) x))
#              })
