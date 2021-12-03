# These are functions that examine an XML node and
# defines a class for each complex type.

#
# Need to make this work recursively
#


xmlToS4List =
function(from, class = xmlName(from), type = gsub("s$", "", xmlName(from)))
{
  new(class, xmlApply(from, as, type))
}

setGeneric("xmlToS4",
function(node, obj = new(xmlName(node)), ...)
 standardGeneric("xmlToS4")
)


setMethod("xmlToS4", "XMLInternalNode",
          # really should use XMLSchema define the classes
          # and 
 function(node, obj = new(xmlName(node)), ...)
{
  if(is(obj, "character") && !isS4(obj))
    obj = new(obj)
    
#  if(xmlSize(node) == 1 && node[[1]])
#    return(as())
  ids = names(node)
  nodes = xmlChildren(node)
  obj = addXMLAttributes(obj, xmlAttrs(node, addNamespacePrefix = TRUE))
  
  slotIds = slotNames(obj)
  slots = getClass(class(obj))@slots


if(any(duplicated(ids))) {
     # experimenting with a different way of doing this.
     # Group the nodes with the same names and the process those.
  groupedNodes = split(nodes, ids)
  ids = intersect(names(groupedNodes), slotIds)
  for(i in ids) {
    tmp = groupedNodes[[i]]
    slot = slots[[i]]
    if(length(tmp) > 1) {
      val = lapply(tmp, convertNode, slot)
      val = if(isAtomicType(slot))
              unlist(val)
            else
              as(val, slot) # may be a specific sub-type of list
    } else {
       el = tmp[[1]]
       val = convertNode(el, slot)
    }
    slot(obj, i) <- val 

  }
} else {

  # This was the original mechanism but it doesn't handle multiple nodes of the same name.
  for(i in seq(along = nodes)) {
     if(ids[i] %in% slotIds) {

       val = if(slots[[ids[i]]] == "character")
                xmlValue(nodes[[i]])
             else
                tryCatch(as(nodes[[i]], slots[[ids[i]]]),
                         error = function(e)
                                    xmlToS4(nodes[[i]]))
       
       slot(obj, ids[i]) <- val #    xmlToS4(nodes[[i]])
     }
     # obj = addAttributes(obj,  xmlAttrs(nodes[[i]]))
  }
}
  
  obj
})

convertNode =
function(el, slot)
{
  if(slot == "character")
    xmlValue(el)
  else
    tryCatch(as(el, slot),
             error = function(e)
                         xmlToS4(el))
}

isAtomicType =
  #
  # check if className refers to a primitive/atomic type
  # or not.
function(className)
{
  atomicTypes = c("logical", "integer", "numeric", "character")
  if(className %in% atomicTypes)
    return(TRUE)

  k = getClassDef(className)
  length(intersect(names(k@contains), atomicTypes)) > 0
}


addXMLAttributes =
function(obj, attrs)
{
  slots = getClass(class(obj))@slots
  i = match(names(attrs), names(slots))

   # handle any namespace prefix
  if(any(is.na(i))) {
     w = grepl(":", names(attrs)) & is.na(i)
     if(any(w))
       i[which(w)] = match(gsub(".*:", "", names(attrs)[which(w)]), names(slots))
  }

  if(any(!is.na(i))) {
    vals = structure(attrs[!is.na(i)], names = names(slots)[i [!is.na(i)] ])
    for(i in names(vals))
      slot(obj, i) <- as(vals[i], slots[[i]])
  }
  
  obj
}


makeClassTemplate =
  #
  # Get the class representation information to represent the contents of
  # an XML node.
  #
  #
function(xnode, types = character(), default = "ANY", className = xmlName(xnode),
         where = globalenv())
{
  user.types = types
  
  slots = names(xnode)
  types =
    xmlSApply(xnode, function(x) {
                      if(xmlSize(x) == 0)
                        default
                      else if(xmlSize(x) == 1 || is(x, "XMLInternalTextNode"))
                        "character"
                      else
                          xmlName(x)
                    })
  names(types) = slots
  types[names(xmlAttrs(xnode))] = "character"

  if(length(user.types))
    types[names(user.types)] = user.types

  coerce = sprintf("setAs('XMLAbstractNode', '%s', function(from) xmlToS4(from))", className)
  def = if(length(types))
           sprintf("setClass('%s',\n    representation(%s))", className,
                      paste(sQuote(names(types)), sQuote(types), sep = " = ", collapse = ",\n\t"))
        else
          sprintf("setClass('%s')", className)

  if(!is.null(where) && !(is.logical(where) && !where)) {
    eval(parse(text = def), envir = where)
    eval(parse(text = coerce), envir = where)
  }
  
  list(name = className, slots = types,
       def = def, coerce = coerce)
}
  


setAs("XMLAbstractNode", "integer",
      function(from)
       as.integer(xmlValue(from)))


setAs("XMLAbstractNode", "numeric",
      function(from)
       as.numeric(xmlValue(from)))

setAs("XMLAbstractNode", "character",
      function(from)
        xmlValue(from))

setAs("XMLAbstractNode", "URL",
      function(from)
        new("URL", xmlValue(from)))

setAs("XMLAbstractNode", "logical",
      function(from)
        as.logical(xmlValue(from)))

setAs("XMLAbstractNode", "Date",
      function(from)
        as.Date(xmlValue(from), "%Y-%m-%d"))

setAs("XMLAbstractNode", "POSIXct",
      function(from)
        as.POSIXct(strptime(xmlValue(from), "%Y-%m-%d %H:%M:%S")))



makeXMLClasses =
function(doc, omit = character(), eval = FALSE)
{
  a = getNodeSet(doc, "//*")
  ids = unique(sapply(a, xmlName))
  if(length(omit))
    ids = setdiff(ids, omit)
  lapply(ids, function(id) makeClassTemplate(getNodeSet(doc, sprintf("//%s", id))[[1]], where = eval))
}
