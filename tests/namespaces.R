i = newXMLNode("foo", namespace = "r", namespaceDefinitions = c(r = "http://www.r-project.org"))
as(i, "character")

xmlNamespaceDefinitions(x)
xmlNamespaces(i) = c( omg = "http://www.omegahat.org")

j = xmlNode("foo", namespaceDefinitions = c(r = "http://www.r-project.org"))


txt = '
 <top xmlns="http://www.r-projectorg.">
    <a/>
 </top>
'

doc = xmlParse(txt, asText = TRUE)

getNodeSet(doc, "//a") # Won't work.
getNodeSet(doc, "//r:a", "r") #
b = newXMLNode("b", parent = xmlRoot(doc))
getNodeSet(doc, "//r:b", "r") # No namespace on this.
getNodeSet(doc, "//b", "r") # No namespace on this.
ns = XML:::namespaceDeclarations(xmlRoot(doc), TRUE)[[1]]

XML:::setXMLNamespace(b, ns)
getNodeSet(doc, "//r:b", "r") # No namespace on this.
