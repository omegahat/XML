.InitSAXMethods <-
  # Defines S4 classes for use with the SAX parser and specifically to do with the
  # state variable.
  # This also defines methods for the 
function(where = "package:XML") {  
   require(methods)

   setClass("SAXState",  "VIRTUAL", where = where)

   setGeneric("startElement.SAX", function(name, atts, .state = NULL)  standardGeneric("startElement.SAX"), where = where)
   setGeneric("endElement.SAX", function(name, .state = NULL) { standardGeneric("endElement.SAX")}, where = where)
   setGeneric("comment.SAX", function(content,  .state = NULL) { standardGeneric("comment.SAX")}, where = where)
   # Note that we drop the . here.
   setGeneric("text.SAX", function(content,  .state = NULL) { standardGeneric("text.SAX")}, where = where)
   setGeneric("cdata.SAX", function(content,  .state = NULL) { standardGeneric("cdata.SAX")}, where = where)   
   setGeneric("processingInstruction.SAX", function(target, content, .state = NULL) { standardGeneric("processingInstruction.SAX")}, where = where)
   setGeneric("entityDeclaration.SAX", function(name, base, sysId, publicId, notationName, .state = NULL) { standardGeneric("entityDeclaration.SAX")}, where = where)

   setMethod("startElement.SAX", signature(.state = "SAXState"),
                function(name, atts, .state = NULL) .state, where = where)
   setMethod("endElement.SAX", signature(.state = "SAXState"),
                function(name, .state = NULL) .state, where = where)
   setMethod("comment.SAX", signature(.state = "SAXState"),
                function(content, .state = NULL) .state, where = where)
   setMethod("text.SAX", signature(.state = "SAXState"),
                function(content, .state = NULL) .state, where = where)
   setMethod("processingInstruction.SAX", signature(.state = "SAXState"),
                function(target, content, .state = NULL) .state, where = where)
   setMethod("entityDeclaration.SAX", signature(.state = "SAXState"),
                function(name, base, sysId, publicId, notationName, .state = NULL) .state, where = where)
   
   return(TRUE)
}

.useNamespacesInXMLPackage = FALSE

if(!.useNamespacesInXMLPackage) {
   setClass("SAXState",  "VIRTUAL")

   setGeneric("startElement.SAX", function(name, atts, .state = NULL)  standardGeneric("startElement.SAX"))
   setGeneric("endElement.SAX", function(name, .state = NULL) { standardGeneric("endElement.SAX")})
   setGeneric("comment.SAX", function(content,  .state = NULL) { standardGeneric("comment.SAX")})
   # Note that we drop the . here.
   setGeneric("text.SAX", function(content,  .state = NULL) { standardGeneric("text.SAX")})
   setGeneric("processingInstruction.SAX", function(target, content, .state = NULL) { standardGeneric("processingInstruction.SAX")})
   setGeneric("entityDeclaration.SAX", function(name, base, sysId, publicId, notationName, .state = NULL) { standardGeneric("entityDeclaration.SAX")})

   setMethod("startElement.SAX", signature(.state = "SAXState"),
                function(name, atts, .state = NULL) .state)
   setMethod("endElement.SAX", signature(.state = "SAXState"),
                function(name, .state = NULL) .state)
   setMethod("comment.SAX", signature(.state = "SAXState"),
                function(content, .state = NULL) .state)
   setMethod("text.SAX", signature(.state = "SAXState"),
                function(content, .state = NULL) .state)
   setMethod("processingInstruction.SAX", signature(.state = "SAXState"),
                function(target, content, .state = NULL) .state)
   setMethod("entityDeclaration.SAX", signature(.state = "SAXState"),
                function(name, base, sysId, publicId, notationName, .state = NULL) .state)
}


genericSAXHandlers  <-
function(include, exclude, useDotNames = FALSE)
{
 if(!exists("startElement.SAX"))
   stop("You must call .InitSAXMethods before calling genericSAXHandlers()n")


 ans <- list(startElement = startElement.SAX,
             endElement = endElement.SAX,
             comment = comment.SAX,
             text = text.SAX,
             processingInstruction = processingInstruction.SAX,
             entityDeclaration = entityDeclaration.SAX)

 if(!missing(include))
   ans <- ans[include]
 else if(!missing(exclude)) {
   which <- match(exclude, names(ans))
   ans <- ans[-which]
 }

  if(useDotNames)
    names(ans) = paste(".", names(ans), sep = "")

 ans
}


