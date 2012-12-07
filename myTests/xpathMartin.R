fl = system.file("exampleData", "mtcars.xml", package="XML")
xml <- xmlTreeParse(fl, useInternal=TRUE)

node <- xpathApply(xml, "/*/*")
xpathApply(node[[1]], "/*/*")
xpathApply(node[[1]], "./*/text()|./*/*")

