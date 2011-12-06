library(XML)
gctorture(TRUE)
b = newXMLNode("bob", namespace = c(r = "http://www.r-project.org", omg = "http://www.omegahat.org"))
addChildren(b, newXMLNode("el", "Red", "Blue", "Green",
                           attrs = c(lang ="en")))

#newXMLNode("foo", 1, 2, 3, parent = b)
newXMLNode("foo", "other", parent = b)

b


