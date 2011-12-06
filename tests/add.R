
f = "~/Books/RPackages/RXMLDoc/inst/xml/functionTemplate.xml"

doc = xmlTreeParse(f, useInternal = TRUE)
z = xmlRoot(doc)
names(z)

addChildren(z, newXMLNode("duncan"), at = 1)
names(z)

topics = sapply(c("bob", "jane", "hannah"), newXMLNode, doc = doc)

addChildren(z, kids = topics, at = 2)

 # Add siblings directly to the first child node.
addSibling(z[[1]], kids = lapply(c("get", "assign", "exists"), newXMLNode, doc = doc), after = FALSE)


