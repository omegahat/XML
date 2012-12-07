doc = xmlParse("tests/hashTree.xml")
a = xmlAttrs(xmlRoot(doc)[[2]])

doc = xmlTreeParse("tests/hashTree.xml")
b = xmlAttrs(xmlRoot(doc)[[2]])

doc = as(xmlParse("tests/hashTree.xml"), "XMLHashTree")
c = xmlAttrs(xmlRoot(doc)[[2]])

identical(a, b)
identical(a, c)



############################
#
# Name space definitions on the document, and then on the nodes.
#
doc = xmlParse("tests/hashTree.xml")
xmlNamespaceDefinitions(doc)

node = xmlRoot(doc)
xmlNamespaces(node) = c(ucd = "http://www.ucdavis.edu")
xmlNamespaces(xmlRoot(doc))

xmlNamespaces(node, append = FALSE) = c(ucd = "http://www.ucdavis.edu")

# Fails because xmlRoot<- missing
xmlNamespaces(xmlRoot(doc)) = c(omg = "http://www.omegahat.org")

#

doc = xmlTreeParse("tests/hashTree.xml")
xmlNamespaces(doc)
node = xmlRoot(doc)

xmlNamespaces(node) = c(ucd = "http://www.ucdavis.edu", omg = "http://www.omegahat.org")

xmlNamespaces(node, append = FALSE) = c(ucd = "http://www.ucdavis.edu", omg = "http://www.omegahat.org", omg = "http://www.omegahat.org")

xmlNamespaces(node) = c(ucd = "http://www.ucdavis.edu")
xmlNamespaces(node)




xmlNamespaces(node, append = FALSE) = c(ucd = "http://www.ucdavis.edu")

#XXX Breaks because it doesn't convert the existing namespace to a character vector when appending it.

doc = as(xmlParse("tests/hashTree.xml"), "XMLHashTree")
xmlNamespaceDefinitions(doc)

xmlNamespaces(doc)

