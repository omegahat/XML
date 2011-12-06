# Check xmlValue() setting on children of a node
b = newXMLNode("bob", "some text")
xmlValue(b[[1]]) = "change"
#test
xmlValue(b[[1]]) == "change"

a = newXMLNode("top", newXMLNode("o", b))
xmlValue(a[[1]][[2]]) = "foo"
#test
xmlValue(a[[1]][[2]]) == "foo"


