library(XML)

NS = c(r = 'http://www.r-project.org',
       omg = 'http://www.omegahat.org')
top = newXMLNode("top", namespaceDefinitions = NS)

newXMLNode("bob", attrs = c('r:length' = 3, abc = "true"), parent = top)

names(attr(xmlAttrs(top[[1]]), "namespaces"))[1] == NS["r"]



