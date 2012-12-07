doc = xmlParse("transition.eml")
xx = matrix(as.numeric(unlist(xmlToList(doc))), , 5, byrow = TRUE,
             dimnames = list(NULL, names(xmlRoot(doc)[[1]])))


trans = apply(xx, 1, function(x) {
                       tr = newXMLNode("transition")
                       mapply(newXMLNode, names(x), x, MoreArgs = list(parent = tr))
                       tr
                     })
top = newXMLNode("transitionmatrix", .children = trans) 
saveXML(top, "newTransition.xml")



#
      
