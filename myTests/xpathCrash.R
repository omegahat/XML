xml <- xmlTreeParse('<A><B><C></C></B></A>', useInternal=T)
node <- xpathApply(xml, "/A/B")[[1]]
xpathApply(node, "/*") # should be node B
xpathApply(node, "/*/*") # should be node C
list()
saveXML(node)

