getXIncludes2 =
    #
    #
function(file, recursive = TRUE, xpointer = "", parse = "", from = file)
{
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

    if(length(href)) 
        href = getRelativeURL(href, file)
    
    ans = data.frame(href = href, parse = parse, xpointer = xpointer, file = rep(file, length(href)), from = rep(from, length(href)), stringsAsFactors = FALSE)
    
    if(recursive && length(href) > 0) {
   ##     isParse = (parse == "text")
   ##    tmp = mapply(getXIncludes, href[!isParse], xpointer[!isParse], MoreArgs = list(recursive = TRUE), SIMPLIFY = FALSE)
        tmp = mapply(getXIncludes2, href, xpointer, parse, MoreArgs = list(recursive = TRUE, from = file), SIMPLIFY = FALSE)

        tmp2 = mapply(function(i, info) rbind(ans[i,], info), seq(along = tmp), tmp, SIMPLIFY = FALSE)
        ans = do.call(rbind, tmp2)
    }
    ans
}

