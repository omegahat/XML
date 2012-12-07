a = newXMLNode("a")
is(a, "XMLAbstractNode")

b = xmlNode("a")
is(b, "RXMLAbstractNode")


b = xmlTextNode("some text")
is(b, "RXMLAbstractNode")

b = xmlPINode("R", "plot(1:10)")
is(b, "RXMLAbstractNode")

f = function(b, classes = c("XMLNode", "RXMLAbstractNode", "XMLAbstractNode"))
        sapply(classes,  function(class) is(b, class))

b = xmlCDataNode("plot(1:10)")
is(b, "RXMLAbstractNode")
f(b)

