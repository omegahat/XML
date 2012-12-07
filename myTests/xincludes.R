o = XML:::findXIncludeStartNodes(system.file("exampleData", "xinclude", "top.xml", package = "XML"))
names(o)
sapply(o, xmlAttrs)


