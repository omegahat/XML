library(XML)
doc = xmlParse("~/Austria-Map-withFonts.ps.xml")
nd = getNodeSet(doc, "//text[12]")[[1]]
xmlAttrs(nd)["string"]
str = getNodeSet(doc, "//text[12]/@string") 
