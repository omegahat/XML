library(XML)

exchData = newXMLNode("g:Envelope",
  namespace = 
     c("http://www.ecb.int.vocabularly/2002-08-01/euroxref",
       g = "http://www.gesmes.org/xml/2002-08-01") )

xx = newXMLNode("Cube", 
   newXMLNode("Cube",
      newXMLNode("Cube", attrs = c(currency = "USD", rate = "1.5898")),    
      newXMLNode("Cube", attrs = c(currency = "JPY", rate = "164.43")),
      attrs = c("time" = "2008-04-21")),
   parent = exchData)

xmlNamespace(xx)
