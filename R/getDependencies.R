getXIncludes =
function(filename, recursive = TRUE, skip = character(),
         omitPattern = "\\.(js|html?|txt|R|c)$",
          namespace = c(xi = "http://www.w3.org/2003/XInclude"),
          duplicated = TRUE)
{
   doc = xmlParse(filename, xinclude = FALSE)

   nodes = getNodeSet(doc, "//xi:include", namespaces = namespace)
   files = sapply(nodes, xmlGetAttr, "href")
   nonRecursive = as.logical(sapply(nodes, xmlGetAttr, "text", FALSE))

   if(length(omitPattern))
      nonRecursive = grepl(omitPattern, files) | nonRecursive

   if(recursive) {
     processed = c(filename, skip)
     for(f in unique(files[!nonRecursive])) {
           # path name relative to the base document of the XInclude
        f = getRelativeURL(f, dirname(filename))
        if(file.exists(f))
           files = c(files, getXIncludes(f, TRUE, skip = processed))
        else
           warning(f, " doesn't exist")
        processed = c(processed, f)
     }
   }
   files = unlist(files)
   if(!duplicated)
     unique(files)
   else
     files
}
