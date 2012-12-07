#                top
#              a     b
#                    c
#                  d e f


library(XML)

e = new.env()
tt = xmlFlatListTree(nodes = list(xmlNode("top", e),
                          "002" = xmlNode( "a", e), "003" = xmlNode("b", e),
                          "004" = xmlNode("c", e), "005" = xmlNode("d", e),
                           "e" = xmlNode("e", e), "f" = xmlNode("f", e)),
          parents = c("001" = "", "002" = "001", "003" = "001", "004" = "003",
                       "005" = "004", "e" = "004", "f" = "004"),
          children = list("top" = c("002", "003"),
                          "003" = "004",
                          "004" = c("005", "e", "f")),
          e)

tt[[".addNode"]](xmlNode("new"), "top")
print(tt)

