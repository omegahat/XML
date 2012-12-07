library(XML)
doc = xmlParse("utf.xml")

xmlSApply(xmlRoot(doc), xmlName)
Encoding(xmlSApply(xmlRoot(doc), xmlName))

xmlAttrs(xmlRoot(doc)[[5]])

xmlRoot(doc)[["झ"]]
xmlRoot(doc)[["\u091D"]]
names(xmlRoot(doc)) == "झ"


at = xmlAttrs(xmlRoot(doc)[["\u091D"]])
names(at)
Encoding(names(at))

invisible(xmlEventParse("utf.xml",
               handlers = list(startElement = function(name, ats, ...) {
                                            cat("name", name, Encoding(name), "\n")
                                            if(!is.null(ats)) {
                                               cat("attributes", ats, Encoding(ats), "\n")
                                               cat("names of attributes", names(ats), Encoding(names(ats)), "\n")
                                             }
                                         },
                               endElement = function(name)
                                              cat("end of", name, Encoding(name), "\n"),
                               text = function(value, ...)
                                         cat("text content", Encoding(value), "\n")
                              )))
