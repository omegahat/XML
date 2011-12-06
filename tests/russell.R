# Examples taken from an email from Russel Almond
# that described and fixed bugs in the nodes that were
# created in the XML package using xmlNode.
#
library(XML)

fb <- xmlRoot(xmlTreeParse("<foo><bar/></foo>"))
fb1 <- xmlNode("foo",xmlNode("bar"))
fb[["bar"]]
fb1[["bar"]]


fb1[["x"]] = xmlNode("foo")
fb1[[3]] = xmlNode("foobar")


fb2 = append.xmlNode(fb1, xmlNode("myNode"))


doc<-xmlNode("val", "1 < 2")
saveXML("doc.xml")
