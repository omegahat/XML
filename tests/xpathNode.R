
doc = xmlInternalTreeParse("xpathTest.xml")
n = xmlRoot(doc)[[1]]
getNodeSet(n, ".//b")

getNodeSet(n, "ancestor::namespace")

# But 
getNodeSet(n, "//b")


