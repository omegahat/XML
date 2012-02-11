library(XML)
tp = newXMLNode("top", namespaceDefinitions = c(r = "http://www.r-project.org",
                                                omg = "http://www.omegahat.org")
               )

#gctorture()
cat("Doing two\n")
newXMLNode("two", 
              newXMLNode("three", namespace = "r",
                          newXMLNode("omg:zz")), 
            parent = tp)

cat("Doing wo\n")
newXMLNode("wo", 
              newXMLNode("tee", namespace = "rr",
                          newXMLNode("om:zz")), 
            parent = tp)

print(tp)


cat("Doing xwo\n")
newXMLNode("xwo", 
              newXMLNode("xtee", namespace = "rr",
                          newXMLNode("om:xzz")), 
            parent = tp, suppressNamespaceWarning = TRUE)

gc()
print(tp)

cat("Finished creating nodes\n")
#replicate(10, {print(getNodeSet(tp, "//namespace::*"))})

replicate(10, {
print(xmlNamespace(tp[[1]][[1]]))
print(xmlNamespace(tp[[1]][[1]][[1]]))
gc()
})

#######################################################
# This time with a document object.

doc = newXMLDoc()
tp = newXMLNode("top", namespaceDefinitions = c(r = "http://www.r-project.org",
                                           omg = "http://www.omegahat.org"),
           doc = doc)

newXMLNode("next", newXMLNode("r:code"), parent = tp)
print(doc)






