if(FALSE) {
    library(XML, lib.loc = "~/Sandbox/Rpackages4")
    source("../../R/xincludes2.R")
    source("setHRef.R")
    source("xml.R")

    inc = getXIncludes("A.xml")

    xi.nodes.a = .Call("R_inc_findXIncludeStartNodes", xmlRoot(z), 1L, PACKAGE = "XML")

    xi.nodes.b = .Call("R_inc_findXIncludeStartNodes", getSibling(xi.nodes.a[[1]]), 1L, PACKAGE = "XML")

    xi.nodes.b[[1]]
    xmlAttrs(xi.nodes.b[[1]])


##########    
    m = xmlParse("multi.xml")
    inc = getXIncludes("multi.xml")
    xi.nodes1 = .Call("R_inc_findXIncludeStartNodes", xmlRoot(m), nrow(inc), PACKAGE = "XML")

    mapply(setXIncludeHref, xi.nodes1, lapply(inc$href, function(x) c(href = x)))


    inc.nodes1 = lapply(xi.nodes1, getSibling)
    names(inc.nodes1) = inc$href

    inc$index = as.integer(ordered(inc$file, inc$file[!duplicated(inc$file)]))
    diff(inc$index)
    g = split(inc, cumsum(c(0, diff(inc$index)) != 0))



fixDocXIncludes =
function(doc, xinc = getXIncludes2(docName(doc)))
{
    if(is.character(doc))
        doc = xmlParse(doc)

    start.nodes = .Call("R_inc_findXIncludeStartNodes", xmlRoot(doc), nrow(xinc), PACKAGE = "XML")
    mapply(setXIncludeHref, start.nodes, lapply(gsub("^./", "", xinc$href), function(x) c(href = x)))
    invisible(doc)
#    w = xinc$file == docName(doc)
#    fixXIncludeStartNodes(doc, docName(doc), xinc)
}

if(FALSE) {
 fixXIncludeStartNodes =
 function(doc, filename, xincludes)    
    subs = xincludes[ xincludes$file == filename, ]
}

setXIncludeHref =
    # Will probably do this in C directly in an "atomic" operation,
    # maybe the entire traversal.
function(x, attrs)
{
    if(is.null(x))
        stop("setXIncludeHref called with NULL for node")
    
    oclass = class(x)

    # temporarily set to an ELEMENT_NODE so we find xmlAttrs<-()
    # and libxml2 sets the attribute(s).
    .Call("R_setXMLNodeType", x, 1L, PACKAGE = "XML") # ELEMENT_NODE
    class(x) = c("XMLInternalElementNode", "XMLInternalNode", "XMLAbstractNode")

    xmlAttrs(x) = attrs

    # reset
    .Call("R_setXMLNodeType", x, 19L, PACKAGE = "XML") # XINCLUDE_START
    class(x) = oclass
    
    x
}
}
