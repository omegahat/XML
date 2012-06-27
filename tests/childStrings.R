library(XML)
doc = xmlParse("childStrings.xml")
getChildrenStrings(xmlRoot(doc))
#.Call("R_childStringValues", xmlRoot(doc), 26L, TRUE, 0L)
