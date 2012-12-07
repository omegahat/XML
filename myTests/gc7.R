# The idea is to test adding nodes to a document
library(XML)
f = system.file("exampleData", "catalog.xml", package = "XML")
doc = xmlParse(f)

gctorture()
n = newXMLNode("foo", "bob")
addChildren(xmlRoot(doc), n)
rm(n)
gc()
rm(doc)
gc()
