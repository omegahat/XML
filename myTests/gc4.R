library(XML)
gctorture(TRUE)
b = newXMLNode("b")
newXMLNode("c", parent = b)
b

d = newXMLNode("d", parent = b)
removeNodes(d)

d
rm(d)
gc()




