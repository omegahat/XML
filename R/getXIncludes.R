getXIncludes2 =
    # This doesn't work exactly in the correct manner.
    # For example, if file A xi:include's several files
    # but there is an XPointer in effect and one of the files included
    # is B that also includes others, then those indirect includes
    # are also subject to the original XPointer.
    # e.g., ExploreCode.xml includes ExploringCode.xml[@xpointer = /doc/section]
    # and ExploringCode.xml includes, e.g., Random.xml, VariableDepends.xml, ...
    # and these define <sections> as their top-level elements.
    # So the Random.xml file needs to include the /section.
    # But the xpointer needs to come from the ancestor XInclude, i.e., in ExploreCode.xml
    # We need to include the sub-documents and then apply the xpointers.
    #
    # For this reason, we "fixed"! the libxml2 code to include the attributes from
    # the XML_XINCLUDE_START.  This provides a different approach to collecting the
    # XInclude chain of files.
    #
    #
    # Also, see getXIncludes() in xincludes.R for another earlier/different approach.
    #
function(file, recursive = TRUE, xpointer = "", parse = "", from = file)
{
    if(parse == "text")
        return(data.frame(href = character(), parse = character(), xpointer = character(), file = character(), line = integer(), from = character()))        
#        return(data.frame(href = file, parse = parse, xpointer = xpointer, file = file, line = 1, from = from))
    
    doc = xmlParse(file, xinclude = FALSE)
    if(!is.na(xpointer) && xpointer != "") {
        xp = sub("^xpointer\\(([^)]+))$", "\\1", xpointer)
        nodes = getNodeSet(doc, xp)
        # Need to remove this from its document and make a completely new document
        # Otherwise, getNodeSet will find the other nodes in the original document
        #
        if(length(nodes) > 1) {
            doc = newXMLDoc()
            newXMLNode("dummy", .children = nodes, doc = doc)
        } else
            doc = newXMLDoc(node = nodes[[1]])
    }
    
    nodes = getNodeSet(doc, "//xi:include", namespaces= c(xi="http://www.w3.org/2003/XInclude"))
    href = sapply(nodes, xmlGetAttr, "href")
    parse = sapply(nodes, xmlGetAttr, "parse", "")
    xpointer = sapply(nodes, xmlGetAttr, "xpointer", NA)
    lineNumbers = sapply(nodes, getLineNumber)

    if(length(href)) 
        href = getRelativeURL(href, file)
    
    ans = data.frame(href = href, parse = parse, xpointer = xpointer, file = rep(file, length(href)), line = lineNumbers, from = rep(from, length(href)), stringsAsFactors = FALSE)
    
    if(recursive && length(href) > 0) {
   ##     isParse = (parse == "text")
   ##    tmp = mapply(getXIncludes, href[!isParse], xpointer[!isParse], MoreArgs = list(recursive = TRUE), SIMPLIFY = FALSE)
        tmp = mapply(getXIncludes2, href, xpointer, parse, MoreArgs = list(recursive = TRUE, from = file), SIMPLIFY = FALSE)

        tmp2 = mapply(function(i, info) rbind(ans[i,], info), seq(along = tmp), tmp, SIMPLIFY = FALSE)
        ans = do.call(rbind, tmp2)
    }
    ans
}

