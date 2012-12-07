#
#  We create a node with a text node as its child.
#  Then we create a new text node explicitly so we can 
#  look at its contents

library(XML)
gctorture()
 # Create a node. We will implicitly create an xmlTextNode
 # containing "foo". This will be garbage collected.
b = newXMLNode("bob", "foo")
gc()
k = newXMLTextNode("bar")
addChildren(b, k)


b = newXMLNode("bob", "foo", "bar")

