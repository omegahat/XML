library(XML)
ok =  require(maps) && require(SVGAnnotation)
if(ok) {

  svgs = replicate(5, svgPlot(map('usa')), simplify = FALSE)

  main = xmlRoot(svgs[[1]])[["g"]][["g"]]

#  i = 1
#  els = xmlChildren(xmlRoot(svgs[[i]])[["g"]][["g"]])
#  removeNodes(els)
#  g = newXMLNode("g", attrs = c(id = sprintf("day%d", i)), parent = main)
#  addChildren(g, kids = els)

  invisible(lapply(seq(along = svgs),
                   function(i) {
                       tt = xmlChildren(xmlRoot(svgs[[i]])[["g"]][["g"]])
#removeNodes(tt)
                       g = newXMLNode("g", attrs = c(id = sprintf("day%d", i)), parent = main)
                       addChildren(g, kids = tt)
                    }))
  print(getNodeSet(svgs[[1]], "//g/@id"))
}
