d = xmlTreeParse("~/Projects/org/omegahat/XML/XSL/S/libxslt/examples/embeddedXSL.xml", useInternal = TRUE)
o = getNodeSet(d, "//xsl:stylesheet[@format='html']", c(xsl="http://www.w3.org/1999/XSL/Transform"))[[1]]
doc = newXMLDoc()
n  = .Call("RS_XML_clone", o, TRUE, PACKAGE = "XML")
addChildren(doc, n)
newXMLNode("xsl:template", attrs = c(match = "xsl:stylesheet|xsl:stylesheets"), parent = n)

sapply(rev(xsl),
       function(x)
          addChildren(sty, newXMLNode("fo:import", attrs = c(href = x), namespaceDefinitions = FO.ns), at = 1))

xsltParseStyleSheet(doc)



d = xmlTreeParse("~/Projects/org/omegahat/XML/XSL/S/libxslt/examples/embeddedXSL.xml", useInternal = TRUE)
o = getNodeSet(d, "//xsl:stylesheet[@format='html']", c(xsl="http://www.w3.org/1999/XSL/Transform"))[[1]]
doc = .Call("RS_XML_createDocFromNode", o, PACKAGE = "XML")
newXMLNode("xsl:template", attrs = c(match = "xsl:stylesheet|xsl:stylesheets"), parent = xmlRoot(doc))

