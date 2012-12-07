setOldClass("XMLAbstractNode")
setOldClass(c("RXMLAbstractNode", "XMLAbstractNode"))
setOldClass(c("XMLNode", "RXMLAbstractNode"))
setOldClass(c("XMLTextNode", "XMLNode"))
setOldClass(c("XMLEntitiesEscapedTextNode", "XMLTextNode"))

xmlName =
function(x)
  UseMethod("xmlName")

xmlName.XMLNode =
function(x)
  x$name


a = xmlTextNode("a")
a = xmlTextNode("a")
a = structure(list(name = "text"), class = "XMLTextNode")

setGeneric("xxmlName", function(x) standardGeneric("xxmlName"))
setMethod("xxmlName", "XMLNode",
           function(x)
               x$name)

b = structure(list(name = "foo"), class = "XMLNode")

xxmlName(a)
xmlName(a)



####################################################

b = structure(list(name = "foo"), class = c("XMLTextNode", "EntitiesEscaped"))




