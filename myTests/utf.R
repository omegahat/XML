Sys.setlocale(, "en_US.UTF-8")
doc = xmlInternalTreeParse("input_dafirstname_cheo.xml")
el = getNodeSet(doc, "//parametergroup[@name='firstname']")[[1]]
xmlValue(el[[1]][[2]])
