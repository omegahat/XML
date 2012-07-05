library(XML)
node = newXMLNode("top", newXMLNode("abc"), newXMLNode("def"))
node[["abc"]] = "some text" #  should replace "abc"?
xmlValue(node[[1]]) == "some text"


node[[1]] = "new text"
xmlValue(node[[1]]) == "new text"
node[[3]] = "other text"
xmlValue(node[[3]]) == "other text"
node[[4]] = newXMLNode("bob", "other text")
xmlName(node[[4]]) == "bob" && xmlValue(node[[4]]) == "other text"
node[["def"]] = newXMLNode("code", "x = rnorm(100)")

node[["temp"]] = I("some text")

