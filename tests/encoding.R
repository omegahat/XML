library(XML)
doc = xmlTreeParse("../data/utf.xml")
Encoding(xmlName(xmlRoot(doc)))
# "unknown"
xmlName(xmlRoot(doc)[[2]])
# [1] "<U+212B>ob"
Encoding(xmlName(xmlRoot(doc)[[2]]))
# [1] "UTF-8"
Sys.setlocale(, "en_US.UTF-8")
 xmlName(xmlRoot(doc)[[2]])
#[1] "â«ob"

xmlName(xmlRoot(doc)[[3]])
#[1] "garÃon"
Encoding(xmlName(xmlRoot(doc)[[3]]))
#[1] "UTF-8"
Encoding(xmlValue(xmlRoot(doc)[[4]]))
#[1] "unknown"
xmlValue(xmlRoot(doc)[[4]])
#[1] "Simple text"


doc = xmlInternalTreeParse("../data/utf.xml")
xmlname(xmlRoot(doc)[[2]])
# [1] "â«ob"

u<-"<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><t>estimados de �ndices</t>"

hh<-function(){
  tt<-character(0)
  text<-function(x) { print(x) ; tt <<- c(tt, x)}
  list(text = text,
       ft = function(){ tt })
}
z<-xmlEventParse(u,asText=T,handlers=hh())
