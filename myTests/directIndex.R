# This is for comparing the time of accessing an individual child node 
# in internal nodes.
# There are 3 approaches.
#   walk the linked list to find the element and return that.
#   get all the children as an R list and then use regular indexing
#   
library(XML)
doc = xmlParse("<top><a/><b/><c/></top>")
top = xmlRoot(doc)
top[[1]]


txt = paste(sprintf("<%s/>", rep(letters, 200)), collapse = "")
doc = xmlParse(paste("<top>", txt, "</top>", collapse = ""))

top = xmlRoot(doc)
w = sample(seq(along = xmlSize(top)), 200, replace = TRUE)

system.time({for(i in w) top[[i]]; gc()})

kids = xmlChildren(top)
system.time({for(i in w) kids[[i]]; gc()})

class(top) = class(top)[-1]
system.time({for(i in w) top[[i]]; gc()})
