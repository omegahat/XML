# Create the concept of a CellValue which gives the attributes
# and the content of the cell.

setClass("CellValue", representation(attributes = "character",
                                     value = "ANY"))

setAs("numeric", "CellValue",
       function(from)
          new("CellValue", attributes = c("Type" = "Number"), value = as.character(from)))

setAs("character", "CellValue",
       function(from)
          new("CellValue", attributes = c("Type" = "String"), value = as.character(from)))

makeCell = function(x) {
  v = as(x, "CellValue")
  attrs = c(Type = as.character(v@attributes))
  newXMLNode("Cell",
             newXMLNode("Data", v@value,  attrs= attrs))
}

z = apply(mtcars, 1, function(x)
                      newXMLNode("Row",
                                 .children = sapply(x, makeCell)))

tt = newXMLNode("Table", .children = z)
saveXML(tt)




if(FALSE) {
WorkSheetTypes = c("numeric" = "Number", "character" = "String")
z = apply(mtcars, 1, function(x)
                        newXMLNode("Row",
                                    .children = sapply(x, function(x)
                                                            newXMLNode("Cell",
                                                                       newXMLNode("Data", x, attrs = c(Type = as.character(WorkSheetTypes[class(x)])))))))
tt = newXMLNode("Table", .children = z)
saveXML(tt)
}


doc = newXMLDoc()
n = newXMLNode("top", doc = doc)
b = newXMLNode("bar", parent = n)

saveXML(doc, prefix = character())
saveXML(doc, prefix = newXMLCommentNode("This is an alternative prefix"))
