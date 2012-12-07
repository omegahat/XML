

assert = function(cond) {
            e = substitute(cond)
            if(!is.logical(cond) || !cond) 
               stop("Assertion failed ", deparse(e), "\n", paste(cond, collapse = "\n"))
            TRUE
          }
test = 
function(xml)
{  
  node <- xpathApply(xml, "/A/B")[[1]]
  ans = xpathApply(node, "/*") # should be node B
  assert(xmlName(ans[[1]]) == "B")
  ans = xpathApply(node, "/*/*") # should be node C
  assert(xmlName(ans[[1]]) == "C")

  saveXML(node)
}

gctorture(TRUE)

 # with a documennt
xml <- xmlTreeParse('<A><B><C></C></B></A>', useInternal=T)


 # without a document.
top = newXMLNode("A", newXMLNode("B", newXMLNode("C")))

replicate(10, test(xml))
replicate(10, test(top))

