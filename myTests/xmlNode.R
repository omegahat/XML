library(XML)

n = xmlNode("foo")
xmlName(n)
xmlName(n) = "bob"
n
xmlAttrs(n) = c(a = 1, b = "dog")
xmlAttrs(n) = c(a = 1, b = "cat")
xmlAttrs(n) = c(a = 1, b = "cat", c = "other")
xmlAttrs(n, append = FALSE) = c(x = 1, y = 2)
xmlGetAttr(n, "y")
xmlGetAttr(n, "y")
xmlGetAttr(n, "yz")
xmlGetAttr(n, "yz", 3)

xmlChildren(n)
xmlSize(n)
xmlSApply(n, class)

n = addChildren(n, "Some text", xmlNode("sub", "2"))
xmlChildren(n)
xmlSize(n)
xmlSApply(n, class)


b = xmlNode('bob')
xmlChildren(b) = list(xmlNode('a', "Some text"), xmlNode("sub", "2"))
xmlChildren(b) = list(xmlNode('a', "Some text"), xmlNode("sub", "2"), "Other text")


z = newXMLNode("foo")
xmlChildren(z) = newXMLNode("bar")
xmlChildren(z) = list(newXMLNode("bar"), "Some other text")


doc = as(xmlParse("tests/hashTree.xml"), "XMLHashTree")
docName(doc)
docName(xmlRoot(doc)[[1]])
