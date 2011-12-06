# The idea is to test adding nodes to a document
library(XML)
f = system.file("exampleData", "catalog.xml", package = "XML")
doc = xmlParse(f)

gctorture()
n = newXMLNode("foo", "bob")
  # now add a new child to n.
newXMLNode("bar", "bob", parent = n)
addChildren(xmlRoot(doc), n)
rm(doc)
gc()
n
rm(n)
gc()

gc()
