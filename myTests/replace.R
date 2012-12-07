library(XML)

top = xmlRoot(xmlTreeParse("replace.xml", useInternalNodes = TRUE))

top[[2]]
tmp = newXMLNode("duncan")
replaceNode(top[[2]], tmp)

saveXM(top)

