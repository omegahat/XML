fileName = "~/Music/iTunes/iTunes\ Music\ Library.xml"
doc = xmlTreeParse(fileName, useInternal = TRUE)
r = xmlRoot(doc)
v = r[["dict"]][["dict"]]
replicate(10, print(v[["dict"]]))

replicate(10, print(v[[4]]))

print(xmlChildren(v))

