library(XML)
gctorture()
        
b = newXMLNode("b")
 # Contiguous text causes problems.
addChildren(b, newXMLNode("el", "Red", "Blue"))
b

####################

b = newXMLNode("b")
addChildren(b, newXMLNode("el", "Red", newXMLNode("foo"), "Blue"))
b
