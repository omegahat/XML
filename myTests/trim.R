library(XML)
doc = xmlParse("../inst/examples/trim.xml")
xpathSApply(doc, "//a", xmlValue, trim = TRUE)
# [1] "some text\n      and some more"
xpathSApply(doc, "//a", xmlValue, trim = TRUE, recursive = FALSE)
# [1] "some text"

