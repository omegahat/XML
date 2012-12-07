library("XML")
doc <- htmlParse("http://en.wikipedia.org/wiki/List_of_ISO_639-2_codes")
tab <- readHTMLTable(getNodeSet(doc, "//table")[[2L]], stringsAsFactors = FALSE)

sapply(tab, class)
sapply(tab[ sapply(tab, is, "character") ], function(x) table(Encoding(x)))


# xmlParse("<doc>العربية</doc>")
