setClass("ExternalReference", representation(ref = "externalptr"))

setClass("libxmlTypeTable",
          representation(ref = "ExternalReference"))



# Identifies the class of the element within a libxmlTypeTable sub-class.
setGeneric("getTableElementType", function(table) standardGeneric("getTableElementType"))


# The name of the element is the name of the class of the table without the Table suffix and,
# with Ref tagged on and with xml  as a suffix.
setMethod("getTableElementType", "libxmlTypeTable",
                function(table)
                    paste("xml", gsub("Table$", "Ref", class(table)), sep = "")
         )


setMethod("$<-", "libxmlTypeTable",
           function(x, name, value) {
             stop("These tables are read-only for the moment")
           })


setMethod("names", "libxmlTypeTable",
            function(x) {
               .Call("R_libxmlTypeTable_names", x, character(0), PACKAGE = "XML")
            })


setAs("libxmlTypeTable", "list",
            function(from) {
               .Call("R_libxmlTypeTable_names", from, getTableElementType(from), PACKAGE = "XML")
            })


setMethod("$", "libxmlTypeTable",
           function(x, name) {
               .Call("R_libxmlTypeTable_lookup", x, name, getTableElementType(x), PACKAGE = "XML")
           })


#################################################################


setClass("xmlSchemaRef", contains = "ExternalReference")

SchemaRefFields = c("name", "targetNamespace", "version", "id",
                    "typeDecl", "attrDecl", "attrgrpDecl", "elemDecl", "notaDecl", "schemasImports"
                   )

setMethod("$", "xmlSchemaRef",
           function(x, name) {

            idx = pmatch(name, SchemaRefFields)
            if(is.na(idx))
              stop("No field ", name, " in ", paste(SchemaRefFields, collapse = ", "))

            .Call(paste("R_libxmlTypeTable", SchemaRefFields[idx], sep = "_"),  x, PACKAGE = "XML")
           })

setMethod("names", "xmlSchemaRef", function(x) SchemaRefFields)




setClass("SchemaElementTable", contains = "libxmlTypeTable")
setClass("xmlSchemaElementRef", contains = "ExternalReference")


setClass("SchemaTypeTable", contains = "libxmlTypeTable")
setClass("xmlSchemaTypeRef", contains = "ExternalReference")

setClass("SchemaAttributeTable", contains = "libxmlTypeTable")
setClass("xmlSchemaAttributeRef", contains = "ExternalReference")

setClass("SchemaAttributeGroupTable", contains = "libxmlTypeTable")
setClass("xmlSchemaAttributeGroupRef", contains = "ExternalReference")


setClass("SchemaNotationTable", contains = "libxmlTypeTable")
setClass("xmlSchemaNotationRef", contains = "ExternalReference")

schemaValidationErrorHandler =
function()  
{
  errors = character()
  warnings = character()
  h = function(msg) {
     if(inherits(msg, "XMLSchemaWarning"))
       warnings <<- c(warnings, msg)
     else
       errors <<- c(errors, msg)       
  }
  structure(list(handler = h, results = function() list(errors = errors, warnings = warnings)), class = "XMLSchemaValidateHandler")
}

xmlSchemaValidate =
#  schemaValidationErrorHandler()
function(schema, doc, errorHandler = xmlErrorFun(), options = 0L)
{
  if(is.character(doc))
    doc = xmlParse(doc)

  if(is.character(schema))
    schema = xmlSchemaParse(schema)

  .oldErrorHandler = XML:::setXMLErrorHandler(if(is.list(errorHandler)) errorHandler[[1]] else errorHandler)
  on.exit(.Call("RS_XML_setStructuredErrorHandler", .oldErrorHandler, PACKAGE = "XML"), add = TRUE)
  
  status = .Call("RS_XML_xmlSchemaValidateDoc", schema@ref, doc, as.integer(options), NULL, PACKAGE = "XML") # errorHandler)

  if(inherits(errorHandler, "XMLStructuredErrorCumulator"))
    structure(list(status = status, errors = errorHandler[[2]]()), class = "XMLSchemaValidationResults")
  else if(inherits(errorHandler, "XMLSchemaValidateHandler"))
    c(status = status, errorHandler$results())
  else
    status
}

setOldClass("XMLSchemaValidationResults")
setMethod("show", "XMLSchemaValidationResults",
          function(object)
             show(object$errors))

