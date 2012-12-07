# This shows how to use state in two different ways.
# The first uses a simple state object and a specialized handler for startElement
# events in the SAX parser.

# The second uses an S4 class and the generic function startElement.SAX as the
# handler function for these events.


xmlElementCumulator <-
function(name, atts, .state) {
  .state[name] <- ifelse(is.na(.state[name]), 1, .state[name] + 1)

  .state
}

fileName <- system.file("exampleData", "gnumeric.xml", package="XML")

xmlEventParse(fileName, handlers=list(startElement=xmlElementCumulator), state=numeric(0))


# Mechanism 2

require(methods)
.InitSAXMethods()
setClass("XMLElementCounter", representation("numeric"))
setMethod("startElement.SAX", signature(.state = "XMLElementCounter"), xmlElementCumulator)

xmlEventParse(fileName, handlers=genericSAXHandlers("startElement"), state=new("XMLElementCounter"))
