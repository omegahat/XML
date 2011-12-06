txt = '<top xmlns="http://www.r-project.org" xmlns:r="http://www.r-project.org"><r:a><b/></r:a></top>'
doc = xmlInternalTreeParse(txt, asText = TRUE)

# Will fail
#  xpathApply(doc, "//x:b")

xpathApply(doc, "//x:b", namespaces = "x")
xpathApply(doc, "//r:a", namespaces = "r")
xpathApply(doc, "//r:a")

xpathApply(doc, "//x:a", namespaces = c(x = "http://www.r-project.org"))
