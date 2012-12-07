#  filename = system.file("exampleData", "branch.xml", package = "XML")
  parentNames <- character()
  filename = "<top><f><h/></f><g><h/></g></top>"
  xmlTreeParse(filename,
                handlers =
                  list(h = function(x) {
                   cat("start", xmlName(x), "\n")
                   parentNames <<- c(parentNames, xmlName(xmlParent(x)))
                   cat("end", xmlName(x), "\n")
                  }), useInternalNodes = TRUE)

  table(parentNames)
