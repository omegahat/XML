library(XML)

html <- xmlTree("html",
                  attrs=c(xmlns="http://www.w3.org/1999/xhtml",
                            "xml:lang"="en", lang="en"),
                  dtd=c('html',
                        '-//W3C//DTD XHTML 1.0 Strict//EN',
                        'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'))

z = newXMLNode("foo")
html$addNode(z)


xmlName(xmlRoot(html))
xmlNamespace(xmlRoot(html))

xmlAttrs(xmlRoot(html))

saveXML(html)


