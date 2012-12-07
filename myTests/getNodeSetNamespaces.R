txt = '<doc xmlns="http://www.bogus.org" xmlns:r="http://www.r-project.org">
 <top><r:code>x = 1:10</r:code></top>
</doc>'

doc = xmlParse(txt, asText = TRUE)

getNodeSet(doc, "//r:code")
xpathApply(doc, "//r:code", xmlValue)


getNodeSet(doc, "//r:code", "r")
xpathApply(doc, "//r:code", xmlValue, namespaces = "r")

