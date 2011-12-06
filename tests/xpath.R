assert = function(cond) {
            e = substitute(cond)
            if(!is.logical(cond) || !cond)
             stop("Assertion failed ", deparse(e))
            TRUE
          }


test = 
function(top, nodes, subnodes, doAssert = TRUE)
{
 if(!doAssert)
    assert = function(x) TRUE
 
 cat(saveXML(top))

 z = xpathApply(top, "//y|//z")
 assert(all.equal(z, unlist(lapply(subnodes, function(x) x[2:3]), recursive = FALSE)))

 a = xpathApply(top, "//A")
 assert(all.equal(a[[1]], nodes[[1]]))

 x = xpathApply(a[[1]], "//x")
 assert(all.equal(subnodes[[1]][[1]], x[[1]]))
}


# When we use xmlDoc() to create a new xmlDocPtr, we end up with new nodes.
# So a[[1]] and nodes[[1]] are no longer the same.

# Can we temporarily set the doc pointer to  a new one and reset it.
# Have to worry about getting the namespaces right from the ancestors.



top = newXMLNode("top")
nodes = lapply(c("A", "B", "C"), newXMLNode, parent = top)
subnodes = lapply(c(1, 2),
                  function(i)
                    lapply(c("x", "y", "z"), newXMLNode, i, parent = nodes[[i]]))



test(top, nodes, subnodes)

#- do this with a regular document to avoid the attribute "document" being set and so
# confusing the all.equal() !!!! 

xml = '<top>
  <A>
    <x>1</x>
    <y>1</y>
    <z>1</z>
  </A>
  <B>
    <x>2</x>
    <y>2</y>
    <z>2</z>
  </B>
  <C/>
</top>'
doc = xmlInternalTreeParse(xml, asText = TRUE, trim = TRUE)
doc.top = xmlRoot(doc)
doc.nodes = xmlChildren(doc.top)[1:2]
doc.subnodes = structure(lapply(doc.nodes, function(x) structure(xmlChildren(x), names = NULL)), names = NULL)
 
test(doc.top, doc.nodes, doc.subnodes)

# Cannot remove the doc and gc() it and then run this.


# From Martin (Morgan).

xml <- xmlTreeParse("<A><B></B></A>", useInternal=TRUE, asText=TRUE)
nds <- xpathApply(xml, "/*/*")
assert(length(xpathApply(nds[[1]], "/*/*", xmlName)) == 0)

#[[1]]
#[1] "B"
# Should return 
#list()
