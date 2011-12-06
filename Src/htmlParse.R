htmlTreeParse <- 
#
# HTML parser that reads the entire `document' tree into memory
# and then converts it to an R/S object. 
# Uses the libxml from Daniel Veillard at W3.org. 
#
# asText  treat the value of file as XML text, not the name of a file containing
#       the XML text, and parse that.
# See also xml
#
function(file, ignoreBlanks = TRUE, handlers = NULL,
           replaceEntities = FALSE, asText = FALSE, trim = TRUE, 
            isURL = FALSE, asTree = FALSE, useInternalNodes = FALSE,
            encoding = character(),
            useDotNames = length(grep("^\\.", names(handlers))) > 0,
            xinclude = FALSE, addFinalizer = TRUE, error = function(...){})
{

  if(length(file) > 1) {
   file = paste(file, collapse = "\n")
    if(!missing(asText) && !asText) 
      stop("multiple URIs passed to xmlTreeParse. If this is the content of the file,  specify asText = TRUE")   
   asText = TRUE
 }


  if(missing(asText) && substring(file, 1, 1) == "<")
    asText = TRUE
  
  if(!asText && missing(isURL)) {
     isURL <- length(grep("^(http|ftp)://", file, useBytes = TRUE, perl = TRUE)) 
  }

    # check whether we are treating the file name as
    # a) the XML text itself, or b) as a URL.
    # Otherwise, check if the file exists and report an error.
 if(asText == FALSE && isURL == FALSE) {
  if(file.exists(file) == FALSE)
     stop(paste("File", file, "does not exist "))
 }

 if(!asText && !isURL)
   file = path.expand(file)

 old = setEntitySubstitution(replaceEntities)
 on.exit(setEntitySubstitution(old))

 if(!is.logical(xinclude)) {
   if(inherits(xinclude, "numeric"))
    xinclude = bitlist(xinclude)
   else
     xinclude = as.logical(xinclude)   
 }

 .oldErrorHandler = setXMLErrorHandler(error)
 on.exit(.Call("RS_XML_setStructuredErrorHandler", .oldErrorHandler, PACKAGE = "XML"), add = TRUE)
  
 ans <- .Call("RS_XML_ParseTree", as.character(file), handlers, 
         as.logical(ignoreBlanks), as.logical(replaceEntities),
          as.logical(asText), as.logical(trim), 
           FALSE, FALSE, 
           as.logical(isURL), FALSE, 
           as.logical(useInternalNodes), TRUE, FALSE, FALSE, as.character(encoding),
           as.logical(useDotNames), xinclude, error, addFinalizer, PACKAGE = "XML")

 if(!missing(handlers) & !as.logical(asTree))
   return(handlers)

  if(inherits(ans, "XMLInternalDocument")) {
    addDocFinalizer(ans, addFinalizer)
    class(ans) = c("HTMLInternalDocument", class(ans))
  }

 ans
}

htmlParse = htmlTreeParse
formals(htmlParse)$useInternalNodes = TRUE


parseURI =
function(uri)
{
  if(is.na(uri))
    return(structure(as.character(uri), class = "URI"))
  
  u = .Call("R_parseURI", as.character(uri), PACKAGE = "XML")
  if(u$port == 0)
    u$port = as.integer(NA)

  class(u) = "URI"
  
  u
}  

setOldClass("URI")
setOldClass("URL")

setAs("URI", "character",
      function(from) {
           sprintf("%s://%s%s%s%s%s%s%s",
                                    from[["scheme"]],
                                    from[["user"]],
                                    if(from[["user"]] != "") "@" else "",
                                    from[["server"]],
                                    if(!is.na(from[["port"]])) sprintf(":%d", as.integer(from[["port"]])) else "",
                                    from["path"],
                                    if(from[["query"]] != "") sprintf("?%s", from[["query"]]) else "",
                                    if(from[["fragment"]] != "") sprintf("#%s", from[["fragment"]]) else ""                   
                   )
      })

