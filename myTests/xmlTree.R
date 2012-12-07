library(XML)

x = summary(rnorm(1000))
d = xmlTree()
d$addNode("table", close = FALSE)

d$addNode("tr", .children = sapply(names(x), function(x) d$addNode("th", x)))
d$addNode("tr", .children = sapply(x, function(x) d$addNode("td", format(x))))

d$closeNode()
cat(saveXML(d))

# Just doctype
za = xmlTree("people", dtd = "people")
# no public element
zb = xmlTree("people", dtd = c("people", "", "http://www.omegahat.org/XML/types.dtd"))
# public and system
zc = xmlTree("people", dtd = c("people", "//a//b//c//d", "http://www.omegahat.org/XML/types.dtd"))

# Using a DTD node directly.
dtd = newXMLDTDNode(c("people", "", "http://www.omegahat.org/XML/types.dtd"))
z1 = xmlTree("people", dtd = dtd)
cat(saveXML(z1))


x = rnorm(3)
z2 = xmlTree("r:data", namespaces = c(r = "http://www.r-project.org"))
z2$addNode("numeric", attrs = c("r:length" = length(x)), close = FALSE)
lapply(x, function(v) z2$addNode("el", x))
z2$closeNode()
cat(saveXML(z2))
# should give   <r:data><numeric r:length="3"/>...</r:data>

# shows namespace prefix on an attribute, and different from the one on the node.
z3 = xmlTree()
z3$addNode("r:data",  namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"), close = FALSE)
x = rnorm(3)
z3$addNode("r:numeric", attrs = c("omg:length" = length(x)))
cat(saveXML(z3))


z = xmlTree("people", namespaces = list(r = "http://www.r-project.org"))
z$setNamespace("r")

z$addNode("person", attrs = c(id = "123"), close = FALSE)
z$addNode("firstname", "Duncan")
z$addNode("surname", "Temple Lang")
z$addNode("title", "Associate Professor")
z$addNode("expertize", close = FALSE)
z$addNode("topic", "Data Technologies")
z$addNode("topic", "Programming Language Design")
z$addNode("topic", "Parallel Computing")
z$addNode("topic", "Data Visualization")
z$closeTag()
z$addNode("address", "4210 Mathematical Sciences Building, UC Davis")

