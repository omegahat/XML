xmlXIncludes =
  #
  # This is similar to getXIncludes() but returns the hierarchical structure
  # if desired.
  #
function(filename, recursive = TRUE,
         omitPattern = "\\.(js|html?|txt|R|c)$",
         namespace = c(xi = "http://www.w3.org/2003/XInclude"),
         addNames = TRUE,
         clean = NULL)
{
   doc = xmlParse(filename, xinclude = FALSE)

   if(missing(namespace)) {
     ns = xmlNamespaceDefinitions(doc, simplify = TRUE)
     if("http://www.w3.org/2001/XInclude" %in% ns)
       namespace = c(xi = "http://www.w3.org/2001/XInclude")
   }

   nodes = getNodeSet(doc, "//xi:include[not(ancestor::ignore)]", namespaces = namespace)
   files = lapply(nodes, xmlGetAttr, "href")
   nonRecursive = as.logical(sapply(nodes, xmlGetAttr, "parse", "") == "text")

   files = doClean(files, clean)
   
   if(length(omitPattern))
      nonRecursive = grepl(omitPattern, unlist(files)) | nonRecursive

   if(recursive) {
     ans = files
     ans[!nonRecursive] =  lapply(files[!nonRecursive],
                                   function(x) {
                                    u = getRelativeURL(x, filename)
                                    u = gsub("#.*$", "", u)
                                    xmlXIncludes(u, recursive = TRUE, addNames = addNames, clean = clean)
                                  })
     if(addNames)
        names(ans) = files
     if(length(ans) == 0 || ans == "")
       ans = list()
     files = ans

       # for D3 output.
     files = lapply(files, function(x) if(is.character(x)) list(name = x) else x)
   } else
     files = unlist(files)

   list(name = doClean(filename, clean), children = files)
}

doClean =
function(txt, clean)
{
   if(!is.null(clean)) {
     if(is.function(clean))
       txt = clean(txt)
     else if(is.character(clean))
       txt = gsub(clean[1], clean[2], txt)
   }

   txt
}
