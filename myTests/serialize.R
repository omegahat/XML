library(XML)
z = newXMLNode("foo")
doc = xmlParse("hashTree.xml")
hdoc = as(doc, "XMLHashTree")

nodes = getNodeSet(doc, "//a|//c")

saveRDS(list(a = 1:10, z = z, doc = doc, hdoc = hdoc, nodes = nodes), "/tmp/x.rda",
            refhook = xmlSerializeHook)

v = readRDS("/tmp/x.rda",  refhook = xmlDeserializeHook)

