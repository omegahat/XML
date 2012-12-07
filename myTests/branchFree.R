f = system.file("exampleData", "boxplot.svg", package = "XML")

styles = list()

gctorture(TRUE)
xmlEventParse(f, branches = list(g = function(node) styles <<- c(styles, node)))
