source("tests/simpleTree.R")


test(top, show = TRUE)

gctorture(TRUE)
cat("# children(top)", xmlSize(top), "\n")

 z = xpathApply(top, "//y|//z")
 assert(sapply(z, xmlValue) == c("1", "1", "2", "2"))
 rm(z)
 cat("# children(top)", xmlSize(top), "\n")

 test(top)
 saveXML(top)
 a = xpathApply(top, "//A")
 print(as(a[[1]], "XMLInternalDocument"))
 assert(xmlSize(a[[1]]) == 3)
 assert(xmlValue(a[[1]]) == "111")

 cat("# children(top)", xmlSize(top), "\n")
 test(top)

 xmlName(a[[1]])
 # Lose the node A here
 x = xpathApply(a[[1]], "//x")
 test(top)
 assert(xmlName(x[[1]]) == 'x')
 assert(xmlValue(x[[1]]) == '1')
 rm(a)

 replicate(10, gc())
 replicate(10, saveXML(top))

cat("# children(top)", xmlSize(top), "\n")

#

if(FALSE) {
as(top[[1]][[2]], "XMLInternalDocument")
d = newXMLDoc(node = top)
as(top[[1]][[2]], "XMLInternalDocument")
}
