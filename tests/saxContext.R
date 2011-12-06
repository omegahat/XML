# Test the SAX parser with the XMLParserContextFunction
# Now in man/xmlEventParse.Rd

startElement =
function(ctxt, name, attrs, ...)
{
  print(ctxt)
  print(name)

  if(name == "rewriteURI") {
     cat("Terminating parser\n")
     xmlStopParser(ctxt)
   }
}  

class(startElement) = "XMLParserContextFunction"

endElement =
function(name, ...) 
  cat("ending", name, "\n")

  
xmlEventParse("data/catalog.xml", handlers = list(startElement = startElement, endElement = endElement))
