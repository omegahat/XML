library(XML)
doc = xmlParse("data/reparent.xml")
a = xmlRoot(doc)[[1]]
n = newXMLNode("new", parent = a)
#removeNodes(xmlChildren(a)[1:2])
invisible(addChildren(n, kids = xmlChildren(a)[1:2]))
doc


