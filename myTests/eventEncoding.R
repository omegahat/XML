library(XML)
f = system.file("exampleData", "utf.xml", package = "XML")

startElement = function(name, attrs, ...) {
    cat("elementName:", name, "\n")
}

text = function(x, ...) {
    cat("text:", x, "\n")
}

xmlEventParse(f, handlers = list(startElement = startElement, text = text))


xmlEventParse(f, handlers = list(startElement = startElement, text = text), encoding = "UTF8")

