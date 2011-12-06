b = newXMLNode("bob", namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"))

cat(saveXML(b), "\n")

addAttributes(b, a = 1, b = "xyz", "r:version" = "2.4.1", "omg:len" = 3)
cat(saveXML(b), "\n")

removeAttributes(b, "a", "r:version")
cat(saveXML(b), "\n")

removeAttributes(b, .attrs = names(xmlAttrs(b)))

addChildren(b, newXMLNode("el", "Red", "Blue", "Green",
                           attrs = c(lang ="en")))

k = lapply(letters, newXMLNode)
addChildren(b, kids = k)

cat(saveXML(b), "\n")

removeChildren(b, "a", "b", "c", "z")

  # can mix numbers and names
removeChildren(b, 2, "e")  # d and e

cat(saveXML(b), "\n")

i = xmlChildren(b)[[5]]
xmlName(i)

 # have the identifiers
removeChildren(b, kids = c("m", "n", "q"))


x <- xmlNode("a", 
               xmlNode("b", "1"),
               xmlNode("c", "1"),
               "some basic text")

v = removeChildren(x, "b")

  # remove c and b
v = removeChildren(x, "c", "b")

  # remove the text and "c" leaving just b
v = removeChildren(x, 3, "c")
