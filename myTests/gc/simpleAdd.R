library(XML)

b = newXMLNode("bob", namespace = c(r = "http://www.r-project.org", 
    omg = "http://www.omegahat.org"))
addChildren(b, newXMLNode("el", "Red", "Blue", "Green", attrs = c(lang = "en")))


# Simplest example of failing
o = newXMLNode("el", "Red", "Blue", "Green")

b = newXMLNode("bob")
addChildren(b, newXMLNode("el", "Red", "Blue", "Green"))

# test regular nodes
a = newXMLNode("a")
b = newXMLNode("b", parent = a)
c = newXMLNode("c", newXMLNode("d", newXMLNode("e")), parent = b)


# Problems with...
a = newXMLNode("a")
b = newXMLNode("b", parent = a)
c = newXMLNode("c", newXMLNode("d", newXMLNode("e"), parent = b))
