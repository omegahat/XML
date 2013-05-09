library(XML)
doc <- xmlParse('test.xml')
n <- xpathApply(doc,'/xml/parameter1')
xmlValue(n[[1]]) <- 1
