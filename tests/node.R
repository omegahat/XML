

a = newXMLNode("a", namespaceDefinitions = c("r" = 'http://www.r-project.org',
                                             omg = 'http://www.omegahat.org'))

b1= newXMLNode("r:b1", parent = a)
b2 = newXMLNode("b2", namespace = "r", parent = a)

b4 = newXMLNode("b4", namespace =c("r" = 'http://www.r-project.org'))
xmlNamespace(b4) # empty since it is just the definition.
namespaceDeclarations(b4)  # just the one for R
addChildren(a, b4)

namespaceDeclarations(b4)

b5 = newXMLNode("r:b5", namespace =c("r" = 'http://www.r-project.org'))
xmlNamespace(b5) # this version of r = http://... 
namespaceDeclarations(b5)  # just the one for R
addChildren(a, b5)

namespaceDeclarations(b5)


b5 = newXMLNode("b5", namespace = c("r", "r" = 'http://www.r-project.org'))


# This will fail because we gave it no parent
# and so it cannot find the definition of the namespace r.
b3 = newXMLNode("b3", namespace = "r")



