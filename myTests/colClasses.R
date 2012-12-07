require("XML")
doc <- "http://www.nber.org/cycles/cyclesmain.html"
table <- getNodeSet(htmlParse(doc),"//table") [[2]]        # The  main table is the second one because it's embedded in the page table.
xt <- readHTMLTable(table,
                     header = c("peak","trough","contraction","expansion","trough2trough","peak2peak"),
                     colClasses = c("character","character","character","character","character","character"),
                     trim = TRUE, stringsAsFactors = FALSE
                   )

