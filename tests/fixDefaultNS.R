library(XML)

exchData = newXMLNode("g:Envelope",
  namespace = 
     c("http://www.ecb.int.vocabularly/2002-08-01/euroxref",
       g = "http://www.gesmes.org/xml/2002-08-01") )

a = newXMLNode("Cube1", 
                newXMLNode("Cube2",
                           newXMLNode("Cube3", attrs = c(currency = "USD", rate = "1.5898")),    
                           newXMLNode("g:Cube4", attrs = c(currency = "JPY", rate = "164.43")),
                           attrs = c("time" = "2008-04-21")),
                  parent = exchData)

b = newXMLNode("Cube1", 
                newXMLNode("Cube2",
                           newXMLNode("Cube3", attrs = c(currency = "USD", rate = "1.5898")),    
                           newXMLNode("g:Cube4", attrs = c(currency = "JPY", rate = "164.43")),
                           attrs = c("time" = "2008-04-21")),
                  parent = exchData, fixNamespaces = c(dummy = TRUE,  default = FALSE))

xmlNamespace(a)
xmlNamespace(b)
