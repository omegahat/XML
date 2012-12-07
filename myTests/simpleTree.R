top = newXMLNode("top")
nodes = lapply(c("A", "B", "C"), newXMLNode, parent = top)
subnodes = lapply(c(1, 2),
                  function(i)
                    lapply(c("x", "y", "z"), newXMLNode, i, parent = nodes[[i]]))


assert = function(cond) {
            e = substitute(cond)
            if(!is.logical(cond) || !cond) 
               stop("Assertion failed ", deparse(e), "\n", paste(cond, collapse = "\n"))
            TRUE
          }


test =
function(node, hasDoc = FALSE, show = FALSE) {  
 if(show)
    cat(saveXML(node))
 assert(xmlSize(node) == 3)
 assert( is.null(as(node, "XMLInternalDocument")) == !hasDoc)
 assert(all.equal( sapply(xmlChildren(node), as, "XMLInternalDocument"), list(A = NULL, B = NULL, C = NULL)))
 assert(all.equal(xmlApply(top, function(x) xmlApply(x, as, "XMLInternalDocument")),
                  list(A = list(x = NULL, y = NULL, z = NULL), B = list(x = NULL, y = NULL, z = NULL), C = structure(list(), names = character(0)))))
}
