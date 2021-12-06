procXInclude =
function(f, parse, xpointer)
{
    if(parse == "text")
        return(readLines(f))

    doc = xmlParse(f)
    if(!is.na(xpointer)) {
        ans = getNodeSet(doc, xpointer)
        if(length(ans) == 10)
           ans[[1]]
        else
           ans
    } else
        xmlRoot(doc)
}

extractXPointer =
function(xpointer)    
   gsub("xpointer\\((.*)\\)$", "\\1", xpointer)


genCollectNodes = function(n) {
    ans = list(n)
    cur = 0L
    function(node) {
        cur <<- cur + 1L
        ans[[cur]] <<- node
    }
}


genCollectNodeType = function(n) {
    ans = integer(n)
    cur = 0L
    function(node) {
        cur <<- cur + 1L
        ans[cur] <<- .Call("R_getXMLNodeType", node)
    }
}


visitNodes =
   #
   #  given a function that takes one argument - the XML node reference -
   #  this function visits all nodes in the XML tree, including XML_XINCLUDE_START/END nodes 
   #  and invokes that function for each node.
function(doc, fun)    
{
    e = substitute(f(x), list(f = fun))

    if(is(doc, "XMLInternalDocument"))
        doc = xmlRoot(doc)
    
    .Call("R_visitXMLDocCall", doc, e, PACKAGE = "XML")
}
