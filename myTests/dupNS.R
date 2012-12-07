
doc = xmlParse("tests/hashTree.xml")
node = xmlRoot(doc)
xmlNamespaces(node)
xmlNamespaces(node) = c(xmlNamespaces(node), bob = "http://bob.org")
