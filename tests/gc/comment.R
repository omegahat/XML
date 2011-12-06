doc = newXMLDoc()

top = newXMLNode("a")

d = newXMLNode("d", newXMLTextNode("With text as an explicit node"), parent = top)
newXMLCDataNode("x <- 1\n x > 2", parent = d)

newXMLPINode("R", "library(XML)", top)
newXMLCommentNode("This is a comment", parent = top)

o = newXMLNode("ol", parent = top)

kids = lapply(letters[1:3],
               function(x)
                  newXMLNode("li", x))
addChildren(o, kids)
