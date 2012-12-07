library(XML)
ok =  require(maps) && require(SVGAnnotation)
if(ok) {
  svgs = replicate(5, svgPlot(map('usa')), simplify = FALSE)
  main = xmlRoot(svgs[[1]])[["g"]][["g"]]

  tt = xmlChildren(xmlRoot(svgs[[1]])[["g"]][["g"]])
  g = newXMLNode("g", attrs = c(id = "day1"), parent = main)
  addChildren(g, kids = tt)

  saveXML(svgs[[1]], "")
}
