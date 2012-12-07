library(XML)

p = newXMLNode("top")
newXMLNode("section", attrs = c(id = "a"), parent = p)
newXMLNode("section", attrs = c(id = "b"), parent = p)

.Call("R_clearNodeMemoryManagement", p, PACKAGE = "XML")
rm(p)
gc()
gc()


