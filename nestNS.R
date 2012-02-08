library(XML)
tp = newXMLNode("top", namespaceDefinitions = c(r = "http://www.r-project.org",
                                                omg = "http://www.omegahat.org")
               )

newXMLNode("two", 
              newXMLNode("three", namespace = "r",
                          newXMLNode("omg:zz")), 
            parent = tp)


newXMLNode("wo", 
              newXMLNode("tee", namespace = "rr",
                          newXMLNode("om:zz")), 
            parent = tp)

newXMLNode("wo", 
              newXMLNode("tee", namespace = "rr",
                          newXMLNode("om:zz")), 
            parent = tp, suppressNamespaceWarning = TRUE)

gc()

replicate(10, {print(getNodeSet(tp, "//namespace::*"))})

replicate(1000, {
print(xmlNamespace(tp[[1]][[1]]))
print(xmlNamespace(tp[[1]][[1]][[1]]))
gc()
})




