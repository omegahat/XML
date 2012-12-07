# r = xmlRoot(xmlInternalTreeParse("~/Projects/org/omegahat/XML/RS/tests/hashTree.xml"))

r = xmlRoot(xmlInternalTreeParse("<top><next/></top>"))
xx = xmlHashTree()
ans = .Call("R_convertDOMToHashTree", r, xx, xx$.children, xx$.parents)




r = xmlRoot(xmlInternalTreeParse("~/Projects/org/omegahat/XML/RS/data/allNodeTypes.xml", xinclude = FALSE))
xx = as(r, "XMLHashTree")
xmlName(xmlRoot(xx)[[2]], TRUE)

r = xmlRoot(xmlInternalTreeParse("~/Projects/org/omegahat/XML/RS/data/allNodeTypes.xml", xinclude = TRUE))
xx = as(r, "XMLHashTree")

# Get the namespace definitions and prefixes printing.


