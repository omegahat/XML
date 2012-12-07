library(XML)
doc = newXMLDoc()
newXMLNode("svg", doc = doc)
tmp = newXMLPINode("xml-stylesheet", 'href="foo.css"')
xmlRoot(doc)
addSibling(xmlRoot(doc), tmp, after = FALSE)
doc

