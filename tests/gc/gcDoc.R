library(XML)
x = xmlRoot(xmlParse(system.file("exampleData", "mtcars.xml", package = "XML")))


########

records =
function(x)
{
  doc = xmlParse(x)
        # the namespaces set to character() removes the need to compute the 
        # xmlRoot() to get the namespace definitions on the root.
  getNodeSet(doc, "//path", character())
}

nodeList = replicate(100, records(system.file("exampleData", "boxplot.svg", package = "XML")), simplify = FALSE)
paths = sapply(nodeList, function(nodes) sapply(nodes, xmlGetAttr, "d"))
