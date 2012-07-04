library(XML)

n = newXMLNode("r:code", "x = rnorm(100)", namespace = "r")
top = newXMLNode("top", namespaceDefinitions = c(r = 'http://www.r-project.org'))
addChildren(top, n)

top2 = newXMLNode("top", namespaceDefinitions = c(r = 'http://www.r-project.org'),
                  newXMLNode("r:code", "x = rnorm(100)", namespace = "r"))


n = newXMLNode("r:code", "x = rnorm(100)", namespace = "r")
top = newXMLNode("top", newXMLNode("section"), namespaceDefinitions = c(r = 'http://www.r-project.org'))
addChildren(top[[1]], n)
