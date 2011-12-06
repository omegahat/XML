top = newXMLNode("a")

#d = newXMLNode("d", newXMLTextNode("With text as an explicit node"), parent = top)
newXMLCDataNode("x <- 1\n x > 2", parent = top)

o = newXMLNode("ol", parent = top)
rm(top)
gc()
print(o)
print(xmlParent(o))
gc()


