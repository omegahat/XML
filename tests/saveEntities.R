library(XML)
txt = newXMLTextNode("x &lt; 1")

txt # okay

saveXML(txt) # x &amp;lt; 1

txt = newXMLTextNode(I("x &lt; 1"))

txt # okay

saveXML(txt) # x &amp;lt; 1

.Call("R_setXMLInternalTextNode_noenc", txt)

saveXML(txt)


#
xml <- xmlTree("tree")
xml$addNode("test", "a &cap; b")
xml$addNode("test", I("a &cap; b"))
xml$value()

