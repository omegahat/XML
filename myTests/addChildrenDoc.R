library(XML)
src = '<doc xmlns:r="http://www.r-project.org" xmlns:omg="http://www.omegahat.org">
  <r:code>plot(1:10)<r:output>NULL</r:output></r:code>
 </doc>
'
src.doc = xmlParse(src, asText = TRUE)

new = newXMLNode("newDoc")
addChildren(new, xmlRoot(src.doc)[[1]])


if(FALSE) {
 # Lost the r:code and is now simply code.
xmlNamespace(new)
xmlNamespace(new[[1]])


 # it has been removed from the original doc.
xmlRoot(src.doc)
}

################################################

