library(XML)
gctorture()
 b = newXMLNode("bob")
 saveXML(b)

 f = tempfile()
 saveXML(b, f)
 doc = xmlInternalTreeParse(f)
 saveXML(doc)

con <- xmlOutputDOM()
con$addTag("author", "Duncan Temple Lang")
con$addTag("address",  close=FALSE)
con$addTag("office", "2C-259")
con$addTag("street", "Mountain Avenue.")
con$addTag("phone", close=FALSE)
con$addTag("area", "908", attrs=c(state="NJ"))
con$addTag("number", "582-3217")
con$closeTag() # phone
con$closeTag() # address

saveXML(con$value(), file="out.xml")
