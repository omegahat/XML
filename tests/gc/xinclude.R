library(XML)
gctorture()

 f = system.file("exampleData", "functionTemplate.xml", package = "XML")
 doc = xmlParse(f)

  # Get all the para nodes
  # We just want to look at the 2nd and 3rd which are repeats of the
  # first one.
 a = getNodeSet(doc, "//author")
 findXInclude(a[[1]])

 i = findXInclude(a[[1]], TRUE)
 top = getSibling(i)

   # Determine the top-level included nodes
tmp = getSibling(i)
nodes = list()
while(!inherits(tmp, "XMLXIncludeEndNode")) {
  nodes = c(nodes, tmp)
  tmp = getSibling(tmp)
}


