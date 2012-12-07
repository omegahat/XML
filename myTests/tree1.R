tt = xmlFlatListTree()

add = get(".addParentNode", tt)

add(xmlTextNode("some text"))

add(xmlNode("a"), "text")
add(xmlNode("b"))

names(tt)

add(xmlNode("c"), c("a", "b"))

add(xmlNode("d"))

add(xmlNode("e"), c("c", "d"))






