 a = newXMLNode("arg", attrs = c(default = "TRUE"),
                newXMLNode("name", "foo"),
                newXMLNode("defaultValue", "1:10"))

 xmlAttrs(a) = c(a = 1, b = "a string")


  # Note, append on LHS, not RHS.
 xmlAttrs(a, append = FALSE) = c(a = 1, b = "a string")

 newXMLNamespace(a, c("r" = "http://www.r-project.org"))
 xmlAttrs(a) = c("r:class" = "character") 

  #XXX
 xmlAttrs(a[[1]]) = c("r:class" = "character")
 xmlAttrs(xmlChildren(a)[[1]]) = c("r:class" = "xx") 



#####################################


 a = xmlNode("arg", attrs = c(default = "TRUE"),
              xmlNode("name", "foo"),
              xmlNode("defaultValue", "1:10"))

 xmlAttrs(a) = c("r:class" = "character") 

 newXMLNamespace(a, c("r" = "http://www.r-project.org"))
 xmlAttrs(a) = c("r:id" = "bob")





 a = newXMLNode("arg", attrs = c(default = "TRUE"),
                newXMLNode("name", "foo"),
                newXMLNode("defaultValue", "1:10"))
 xmlAttrs(a[[1]]) = c("xxx" = "bob")

