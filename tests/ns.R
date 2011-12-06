# Illustrate that the name space is inherited/accessible from an ancestor and not (top)
# and not just the immediate parent (desc) when creating the r:func node.
top = newXMLNode("rhelp:help", 
                   namespaceDefinitions = c("r" = "http://www.r-project.org",
                                               "rhelp" = "http://www.r-project.org/help"))

desc = newXMLNode("rhelp:description", parent = top)

addChildren(desc, "This describes a function similar to ", newXMLNode("r:func", "source", parent = desc), " in base, but which works on XML")


# Separate from above
b = newXMLNode("bob", namespaceDefinitions = c("http://www.r-project.org/help", r = "http://www.r-project.org"))
xmlNamespaceDefinitions(b)
