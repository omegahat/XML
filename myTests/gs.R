library(XML)
filename <-system.file("exampleData","input_dafirstname_cheo.xml", package="XML")
#filename <-"~/input_dafirstname_cheo.xml"
filename = "tests/input_dafirstname_cheo.xml"
doc <- xmlTreeParse(filename)
xroot <- xmlRoot(doc)
xroot[[1]][[2]][[1]][[1]]
input <- toString(xroot)
