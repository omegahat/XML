library(XML)

top = xmlRoot(xmlParse("<doc><foo><bar>string</bar><xyz id='1'/></foo></doc>"))

.Call("R_getXMLRefCount", top)
.Call("R_getXMLRefCount", as(top, "XMLInternalDocument")  )

gc()

gc()



