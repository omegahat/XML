
# Adapt this to be able to specify an XPath expression to identify a list of nodes.

setGeneric("xmlToDataFrame",
  #
  # Read a relatively flat, 2-level deep XML document into a data frame.
  # The document is assumed to be something of the form
  #  <top>
  #   <obs>
  #     <var1>value</var1>
  #     <var2>value</var2>
  #     <var3>value</var3>
  #   </obs>
  #   <obs>
  #     <var1>value</var1>
  #     <var2>value</var2>
  #     <var3>value</var3>
  #   </obs>  
  #  </top>
  #
  # This can handle cases where not all observations have the same
  # fields.
  #
  # z = xmlToDataFrame("~/size.xml")
  # z = xmlToDataFrame("~/size.xml", c("integer", "integer", "numeric"))
  #
           
           function(doc, colClasses = NULL, homogeneous = NA, collectNames = TRUE, nodes = list(), stringsAsFactors = default.stringsAsFactors())
              standardGeneric("xmlToDataFrame"))

setMethod("xmlToDataFrame", "character",
             # parse the XML document if it is a file name and
             # not a regular XML document already.          
          function(doc, colClasses = NULL, homogeneous = NA, collectNames = TRUE, nodes = list(), stringsAsFactors = default.stringsAsFactors())
               xmlToDataFrame(xmlParse(doc), colClasses, homogeneous, collectNames, stringsAsFactors = stringsAsFactors))



setMethod("xmlToDataFrame", c("XMLInternalDocument", nodes = "missing"),
  function(doc, colClasses = NULL, homogeneous = NA, collectNames = TRUE, nodes = list(), stringsAsFactors = default.stringsAsFactors())
      xmlToDataFrame(doc, colClasses, homogeneous, collectNames, nodes = xmlChildren(xmlRoot(doc)), stringsAsFactors))

tmp = 
function(doc, colClasses = NULL, homogeneous = NA, collectNames = TRUE, nodes = list(), stringsAsFactors = default.stringsAsFactors())
{

  if(length(nodes) == 0)
    return(data.frame())
  
    # Find out how many fields there.
  nfields = sapply(nodes, xmlSize)
  nvar = max(nfields)

  if(collectNames)
     varNames = unique(unlist( lapply(nodes, names) ))
  else
     varNames = names(nodes[[which.max(nfields)]])
  
  if(is.na(homogeneous)) {
    homogeneous = all(nfields == nvar) && all(sapply(nodes[-1], function(x) all(names(x) == varNames)))
  }

  if(!homogeneous) 
    return(fromRaggedXML2DataFrame(nodes, varNames, c(length(nfields), length(varNames)), colClasses, stringsAsFactors))
    
     # Function to operate on each 
  fun = function(x) {
           tmp = xmlSApply(x, xmlValue)
           length(tmp) = nvar
           tmp
        }
    # Get the individual values
  vals = unlist(lapply(nodes, fun))

  ans = matrix(vals, length(nfields), byrow = TRUE)


  
  ans =
    if(length(colClasses)) {
       as.data.frame(lapply(seq(along = colClasses),
                                       function(i) {
                                          as(ans[, i], colClasses[i])
                                       }), stringsAsFactors = stringsAsFactors)
  } else
     as.data.frame(ans, stringsAsFactors = stringsAsFactors)

  names(ans) = varNames

  ans
}

bob =
function(doc, colClasses = NULL, homogeneous = NA, collectNames = TRUE, nodes = list(), stringsAsFactors = default.stringsAsFactors())
  xmlToDataFrame(nodes = doc, colClasses = colClasses, homogeneous = homogeneous, collectNames = collectNames, stringsAsFactors = stringsAsFactors)

setMethod("xmlToDataFrame", c(nodes = "XMLNodeSet"), tmp)
setMethod("xmlToDataFrame", c(nodes = "list"), tmp)
setOldClass("XMLInternalNodeList")
setMethod("xmlToDataFrame", c(nodes = "XMLInternalNodeList"), tmp)

setMethod("xmlToDataFrame", "XMLNodeSet",   bob)
setMethod("xmlToDataFrame", "XMLInternalNodeList",   bob)
setMethod("xmlToDataFrame", "list",   bob)

fromRaggedXML2DataFrame =
  #
  # This reads data from the nodes of an XML document and assumes
  # that they do not all have the same number or even names of fields.
  # So this does extra work to match each observation to the union of
  # the field names across all nodes.
  #
  # o = fromRaggedXML2DataFrame("size2.xml")
  # o = fromRaggedXML2DataFrame("size1.xml")  
  #
function(nodes, varNames = unique(unlist( lapply(nodes, names) )),
          dims = c(length(nodes), length(varNames)),   colClasses = NULL,
          stringsAsFactors = default.stringsAsFactors())
{
  #XXX
  if(is.character(nodes))
    nodes = xmlChildren(xmlRoot(xmlParse(nodes)))
  
   # create an empty data frame with as many rows and columns as needed.
  ans = as.data.frame(replicate(dims[2], rep(as.character(NA), dims[1]), simplify = FALSE), stringsAsFactors = FALSE)
  names(ans) = varNames

    # Fill in the rows based on the names.
  for(i in seq(length = dims[1])) 
     ans[i, names(nodes[[i]])] = xmlSApply(nodes[[i]], xmlValue)


    # Convert the columns to the specified classes if specified.
    # Should drop cols with NULL. Also guess those with NA.
  if(length(colClasses))  {
    i = ! sapply(colClasses, is.null) 
    ans = ans[ i ]
    varNames = varNames[i]
    colClasses = colClasses[ i ]
    ans = as.data.frame(lapply(seq(length = ncol(ans)),
                                function(i) {
                                  as(ans[, i], colClasses[[i]])
                                }), stringsAsFactors = stringsAsFactors)
  }

  names(ans) = varNames  

  ans
}
