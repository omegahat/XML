library(XML)
doc = xmlParse("~/Projects/org/omegahat/XML/RS/data/catalog.xml")
top = xmlRoot(doc)
rm(doc)
gc()

rm(top)
gc()

doc = xmlParse("~/Projects/org/omegahat/XML/RS/data/catalog.xml")
doc1 = doc
rm(doc)
gc()
top = xmlRoot(doc1)

gc()
rm(top)
gc()

rm(doc1)
gc()
