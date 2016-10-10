libxmlVersion <-
function(runTime = FALSE)
{
 sym = if(runTime) "RS_XML_libxmlVersionRuntime" else "RS_XML_libxmlVersion"
 v <- .Call(sym, PACKAGE = "XML")
 v <- as.character(v)
 els <- substring(v, 1:nchar(v), 1:nchar(v))
 list(major=els[1], minor=paste(els[2:3],sep="", collapse=""), patch=paste(els[4:5], sep="", collapse=""))
}


setEntitySubstitution =
function(val)
  .Call("RS_XML_SubstituteEntitiesDefault", as.logical(val), PACKAGE = "XML")
