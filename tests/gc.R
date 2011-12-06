library(XML)

z = xmlParse("<doc><foo><bar>string</bar><xyz id='1'/></foo></doc>")

.Call("R_getXMLRefCount", z)

xmlRoot(z)
top = xmlRoot(z)

.Call("R_getXMLRefCount", top)  # 2 since we have referred to it twice, but only assigned once.
                                # when we gc()
gc()   # This will remove one of the references to xmlRoot(z) - the one that was not assigned.

rm(top)
gc()

.Call("R_getXMLRefCount", z)
rm(z)
gc()



