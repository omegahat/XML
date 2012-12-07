b = newXMLNode("r:a")
a = newXMLNode("r:a", attrs = c("x" = 1, 'r:id' = 2), namespaceDefinitions = c(r = "http://www.r-project.org"))

xmlAttrs(a, FALSE)
xmlAttrs(a)

xmlGetAttr(a, "x")
xmlGetAttr(a, "r:id")

xmlGetAttr(a, "r:id", namespaceDefinition = c(r = "http://www.r-project.org"))
