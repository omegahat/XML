library(XML)
xml <- xmlTreeParse(system.file("exampleData", "tagnames.xml", package = "XML"), useInternalNodes = TRUE)
func <- function(node) xpathApply(node, "/*")
nchar(saveXML(xml))
x1 <- xpathApply(xml, "/doc", func)
nchar(saveXML(xml))
x1 <- xpathApply(xml, "/doc", func)



xml <- xmlTreeParse(system.file("exampleData", "tagnames.xml", package = "XML"), useInternalNodes = TRUE)
node = getNodeSet(xml, "/doc")
nchar(saveXML(xml))
tmp = xpathApply(node[[1]], "//a", xmlName)
cat(saveXML(xml))

