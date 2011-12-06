library(XML)

doc = newXMLDoc() 
top = newXMLNode("top", namespace = "omg",
                 namespaceDefinitions = c(omg = "http://www.omegahat.org",
                                          r = "http://www.r-project.org"),
                 doc = doc)
newXMLNode("a", parent = top)
newXMLNode("b", parent = top, namespace = character())
newXMLNode("c", parent = top, namespace = NULL)
newXMLNode("d", parent = top)
newXMLNode("r:e", parent = top)

top
getNodeSet(top, "//b")
getNodeSet(top, "//a") # no result
getNodeSet(top, "//omg:a", "omg") # no result

getNodeSet(top, "//r:e", "r")

