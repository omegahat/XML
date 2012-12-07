# Test the mechanism to set the error handlers.

   # Check that we restore to the previous values as NULLs
orig = .Call("RS_XML_getStructuredErrorHandler", PACKAGE = "XML")
invisible(xmlTreeParse("<doc></doc>", asText = TRUE))
current = .Call("RS_XML_getStructuredErrorHandler", PACKAGE = "XML")

all.equal(orig, current)  # Why is this not behaving.

XML:::setXMLErrorHandler(function(...){})
orig = .Call("RS_XML_getStructuredErrorHandler", PACKAGE = "XML")
invisible(xmlTreeParse("<doc></doc>", asText = TRUE))
current = .Call("RS_XML_getStructuredErrorHandler", PACKAGE = "XML")
all.equal(orig, current)

  # Now set a handler.
XML:::setXMLErrorHandler(function(...){})
val = .Call("RS_XML_getStructuredErrorHandler", PACKAGE = "XML")

addr = getNativeSymbolInfo("R_xmlStructuredErrorHandler", "XML")$address
all.equal(addr, val[[2]])

