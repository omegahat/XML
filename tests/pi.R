svg = newXMLNode("svg")
newXMLPINode("xml-stylesheet", 'href="rw.css"', parent = svg)
cat(saveXML(svg))

svg = newXMLNode("svg")
newXMLPINode("xml-stylesheet", 'href="rw.css"', parent = svg, at = 0)
cat(saveXML(svg))

svg = newXMLNode("svg")
newXMLPINode("xml-stylesheet", 'href="rw.css"', parent = svg, at = 1)
cat(saveXML(svg))
